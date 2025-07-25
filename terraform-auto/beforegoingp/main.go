package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"sync"

	"gopkg.in/yaml.v2"
)

// --- Constants ---
const (
	commandApply   = "apply"
	commandDestroy = "destroy"
	configFile     = "config.yaml"
)

// --- Structs ---

// DirectoryConfig defines the structure for each directory within a stage.
type DirectoryConfig struct {
	Path    string `yaml:"path"`
	Enabled bool   `yaml:"enabled"`
}

// Stage defines the structure for each stage in the config.
type Stage struct {
	Name        string            `yaml:"name"`
	Parallel    bool              `yaml:"parallel"`
	Directories []DirectoryConfig `yaml:"directories"`
}

// Config defines the overall structure of the config.yaml.
type Config struct {
	ApplyStages   []Stage `yaml:"apply_stages"`
	DestroyStages []Stage `yaml:"destroy_stages"`
}

// MultiError is a custom error type to hold multiple errors.
type MultiError struct {
	Errors []error
}

func (m *MultiError) Error() string {
	if len(m.Errors) == 0 {
		return "(no errors)"
	}
	errStrings := make([]string, len(m.Errors))
	for i, err := range m.Errors {
		errStrings[i] = err.Error()
	}
	return fmt.Sprintf("%d errors occurred:\n%s", len(errStrings), strings.Join(errStrings, "\n"))
}

// --- Core Logic ---

// executeCommand runs a given command in a specific directory and captures its output for logging.
func executeCommand(dir string, displayDir string, writer *strings.Builder, command string, args ...string) error {
	var stderr bytes.Buffer
	cmd := exec.Command(command, args...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout // Stream stdout directly to the console
	cmd.Stderr = &stderr

	err := cmd.Run()

	// Capture stderr for logging purposes, especially on error.
	stderrOutput := stderr.String()
	if stderrOutput != "" {
		writer.WriteString(fmt.Sprintf("[STDERR from %s]:\n%s\n", displayDir, stderrOutput))
	}

	if err != nil {
		return fmt.Errorf("command '%s %s' failed in %s: %w", command, strings.Join(args, " "), displayDir, err)
	}
	return nil
}

// runTerraformCommand orchestrates the sequence of terraform commands (init, validate, apply/destroy).
// It now returns the captured stderr output for better logging.
func runTerraformCommand(dir, command string) (string, error) {
	displayDir := strings.TrimPrefix(dir, "../../")
	var outputLog strings.Builder

	fmt.Printf("  [INFO] Starting Terraform operations for '%s' in %s...\n", command, displayDir)

	// 1. Run terraform init
	outputLog.WriteString(fmt.Sprintf("--- Terraform Init in %s ---\n", displayDir))
	if err := executeCommand(dir, displayDir, &outputLog, "terraform", "init", "-input=false"); err != nil {
		return outputLog.String(), err
	}
	fmt.Printf("    - Terraform initialized successfully in %s.\n", displayDir)

	// 2. Run terraform validate
	outputLog.WriteString(fmt.Sprintf("--- Terraform Validate in %s ---\n", displayDir))
	if err := executeCommand(dir, displayDir, &outputLog, "terraform", "validate"); err != nil {
		return outputLog.String(), err
	}
	fmt.Printf("    - Terraform configuration validated successfully in %s.\n", displayDir)

	// 3. Run terraform apply or destroy
	var args []string
	var action string
	switch command {
	case commandApply:
		args = []string{"apply", "-parallelism=30", "-auto-approve", "-input=false"}
		action = "Applying"
	case commandDestroy:
		args = []string{"destroy", "-parallelism=30", "-auto-approve", "-input=false"}
		action = "Destroying"
	default:
		return outputLog.String(), fmt.Errorf("unsupported command: %s", command)
	}

	outputLog.WriteString(fmt.Sprintf("--- Terraform %s in %s ---\n", command, displayDir))
	fmt.Printf("    - %s Terraform resources in %s...\n", action, displayDir)
	if err := executeCommand(dir, displayDir, &outputLog, "terraform", args...); err != nil {
		return outputLog.String(), err
	}

	fmt.Printf("  [INFO] Terraform %s completed successfully in %s.\n", command, displayDir)
	return outputLog.String(), nil
}

// loadConfig reads and parses the YAML configuration file.
func loadConfig(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file '%s': %w", path, err)
	}

	var cfg Config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("failed to unmarshal YAML from '%s': %w", path, err)
	}

	return &cfg, nil
}

// previewExecutionPlan displays a summary of what will be executed.
func previewExecutionPlan(stages []Stage, command string) {
	fmt.Printf("\n--- Execution Plan for '%s' ---\n", command)
	hasEnabledTasks := false
	for i, stage := range stages {
		mode := "Sequential"
		if stage.Parallel {
			mode = "Parallel"
		}
		fmt.Printf("\nStage %d: %s (Execution: %s)\n", i+1, stage.Name, mode)

		for _, dirConfig := range stage.Directories {
			if dirConfig.Enabled {
				displayDir := strings.TrimPrefix(dirConfig.Path, "../../")
				fmt.Printf("  - Will run `terraform %s` in: %s\n", command, displayDir)
				hasEnabledTasks = true
			}
		}
	}
	if !hasEnabledTasks {
		fmt.Println("\nNo enabled tasks found in the configuration for this command.")
	}
	fmt.Println("\n---------------------------------")
}

type stageResult struct {
	log string
	err error
}

// processStages executes all the stages for a given command (apply/destroy).
func processStages(stages []Stage, command string) error {
	for i, stage := range stages {
		fmt.Printf("--- Starting Stage %d: %s ---\n", i+1, stage.Name)

		var stageErrors []error

		if stage.Parallel {
			var wg sync.WaitGroup
			resultCh := make(chan stageResult, len(stage.Directories))

			for _, dirConfig := range stage.Directories {
				if !dirConfig.Enabled {
					fmt.Printf("Skipping terraform %s in %s (disabled by config)\n", command, strings.TrimPrefix(dirConfig.Path, "../../"))
					continue
				}

				wg.Add(1)
				go func(path string) {
					defer wg.Done()
					log, err := runTerraformCommand(path, command)
					resultCh <- stageResult{log: log, err: err}
				}(dirConfig.Path)
			}
			wg.Wait()
			close(resultCh)

			for result := range resultCh {
				if result.err != nil {
					stageErrors = append(stageErrors, result.err)
					// Print the log from the failed command for immediate feedback
					fmt.Fprintf(os.Stderr, "[ERROR LOGS]\n%s\n[END ERROR LOGS]\n", result.log)
				}
			}
		} else { // Sequential execution
			for _, dirConfig := range stage.Directories {
				if !dirConfig.Enabled {
					fmt.Printf("Skipping terraform %s in %s (disabled by config)\n", command, strings.TrimPrefix(dirConfig.Path, "../../"))
					continue
				}

				log, err := runTerraformCommand(dirConfig.Path, command)
				if err != nil {
					fmt.Fprintf(os.Stderr, "[ERROR LOGS]\n%s\n[END ERROR LOGS]\n", log)
					return fmt.Errorf("sequential stage '%s' failed: %w", stage.Name, err)
				}
			}
		}

		if len(stageErrors) > 0 {
			return &MultiError{Errors: stageErrors}
		}
		fmt.Printf("--- Completed Stage %d: %s ---\n\n", i+1, stage.Name)
	}

	return nil
}

// --- Main Function ---

func main() {
	// 1. Argument validation
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <%s|%s>\n", os.Args[0], commandApply, commandDestroy)
		os.Exit(1)
	}
	command := os.Args[1]
	if command != commandApply && command != commandDestroy {
		fmt.Fprintf(os.Stderr, "Error: command must be '%s' or '%s', got '%s'\n", commandApply, commandDestroy, command)
		os.Exit(1)
	}

	// 2. Load configuration
	cfg, err := loadConfig(configFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading config: %v\n", err)
		os.Exit(1)
	}

	// 3. Select stages based on command
	var stagesToProcess []Stage
	switch command {
	case commandApply:
		if len(cfg.ApplyStages) == 0 {
			fmt.Fprintln(os.Stderr, "Error: no apply_stages defined in config.yaml")
			os.Exit(1)
		}
		stagesToProcess = cfg.ApplyStages
	case commandDestroy:
		if len(cfg.DestroyStages) == 0 {
			fmt.Fprintln(os.Stderr, "Error: no destroy_stages defined in config.yaml")
			os.Exit(1)
		}
		stagesToProcess = cfg.DestroyStages
	}

	// 4. Show execution plan and ask for confirmation
	previewExecutionPlan(stagesToProcess, command)
	fmt.Printf("Are you sure you want to %s the resources listed above? Type 'yes' to continue: ", command)
	reader := bufio.NewReader(os.Stdin)
	confirmation, _ := reader.ReadString('\n')
	if strings.TrimSpace(confirmation) != "yes" {
		fmt.Println("Operation cancelled by user.")
		os.Exit(0)
	}

	// 5. Execute stages
	fmt.Printf("\nStarting Terraform %s process...\n", command)
	if err := processStages(stagesToProcess, command); err != nil {
		fmt.Fprintf(os.Stderr, "\n[ERROR] Terraform %s process failed.\n", command)
		if multiErr, ok := err.(*MultiError); ok {
			fmt.Fprintln(os.Stderr, "The following errors occurred in a parallel stage:")
			for _, e := range multiErr.Errors {
				fmt.Fprintf(os.Stderr, "  - %v\n", e)
			}
		} else {
			fmt.Fprintf(os.Stderr, "%v\n", err)
		}
		os.Exit(1)
	}

	fmt.Printf("\nTerraform %s completed successfully.\n", command)
}
