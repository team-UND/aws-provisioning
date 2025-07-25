package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"sync"

	"gopkg.in/yaml.v2"
)

// DirectoryConfig defines the structure for each directory within a stage
type DirectoryConfig struct {
	Path    string `yaml:"path"`
	Enabled bool   `yaml:"enabled"`
}

// Stage defines the structure for each stage in the config
type Stage struct {
	Name        string            `yaml:"name"`
	Parallel    bool              `yaml:"parallel"`
	Directories []DirectoryConfig `yaml:"directories"`
}

// Config defines the overall structure of the config.yaml
type Config struct {
	ApplyStages   []Stage `yaml:"apply_stages"`
	DestroyStages []Stage `yaml:"destroy_stages"`
}

// MultiError is a custom error type to hold multiple errors
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

func runTerraformCommand(dir, command string) error {
	displayDir := strings.TrimPrefix(dir, "../../")

	// 1. Run terraform init
	fmt.Printf("  [INFO] Initializing Terraform in %s...\n", displayDir)
	cmd := exec.Command("terraform", "init")
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("terraform init failed in %s: %w", displayDir, err)
	}
	fmt.Printf("  [INFO] Terraform initialized successfully in %s.\n", displayDir)

	// 2. Run terraform validate
	fmt.Printf("  [INFO] Validating Terraform configuration in %s...\n", displayDir)
	cmd = exec.Command("terraform", "validate")
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("terraform validate failed in %s: %w", displayDir, err)
	}
	fmt.Printf("  [INFO] Terraform configuration validated successfully in %s.\n", displayDir)

	// 3. Run terraform apply or destroy
	var args []string
	var action string
	switch command {
	case "apply":
		args = []string{"apply", "-parallelism=30", "-auto-approve"}
		action = "applying"
	case "destroy":
		args = []string{"destroy", "-parallelism=30", "-auto-approve"}
		action = "destroying"
	default:
		return fmt.Errorf("unsupported command: %s", command)
	}

	fmt.Printf("  [INFO] %s Terraform resources in %s...\n", action, displayDir)
	cmd = exec.Command("terraform", args...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("terraform %s failed in %s: %w", command, displayDir, err)
	}
	fmt.Printf("  [INFO] Terraform %s completed successfully in %s.\n", command, displayDir)

	return nil
}

func loadConfig(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	var cfg Config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("failed to unmarshal config: %w", err)
	}

	return &cfg, nil
}

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

func processStages(stages []Stage, command string) error {
	for i, stage := range stages {
		fmt.Printf("--- Starting Stage %d: %s ---\n", i+1, stage.Name)

		var stageErrors []error // Collect errors for the current stage

		if stage.Parallel {
			var wg sync.WaitGroup
			errCh := make(chan error, len(stage.Directories))

			for _, dirConfig := range stage.Directories {
				if !dirConfig.Enabled {
					fmt.Printf("Skipping terraform %s in %s (disabled by config)\n", command, strings.TrimPrefix(dirConfig.Path, "../../"))
					continue
				}

				wg.Add(1)
				go func(d string) {
					defer wg.Done()
					if err := runTerraformCommand(d, command); err != nil {
						errCh <- err
					}
				}(dirConfig.Path)
			}
			wg.Wait()
			close(errCh)

			for err := range errCh {
				if err != nil {
					fmt.Fprintf(os.Stderr, "  [ERROR] Error in parallel task for stage '%s': %v\n", stage.Name, err)
					stageErrors = append(stageErrors, err)
				}
			}
		} else { // Sequential
			for _, dirConfig := range stage.Directories {
				if !dirConfig.Enabled {
					fmt.Printf("Skipping terraform %s in %s (disabled by config)\n", command, strings.TrimPrefix(dirConfig.Path, "../../"))
					continue
				}

				if err := runTerraformCommand(dirConfig.Path, command); err != nil {
					fmt.Fprintf(os.Stderr, "  [ERROR] Error in sequential task for stage '%s': %v\n", stage.Name, err)
					// In sequential mode, if an error occurs, we stop processing this stage
					// and return the error to prevent subsequent stages from running.
					return fmt.Errorf("sequential stage '%s' failed: %w", stage.Name, err)
				}
			}
		}

		if len(stageErrors) > 0 {
			// If there were errors in a parallel stage, return them to stop subsequent stages.
			return &MultiError{Errors: stageErrors}
		}
		fmt.Printf("--- Completed Stage %d: %s ---\n\n", i+1, stage.Name)
	}

	return nil
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <apply|destroy>\n", os.Args[0])
		os.Exit(1)
	}

	command := os.Args[1]
	if command != "apply" && command != "destroy" {
		fmt.Fprintf(os.Stderr, "Error: command must be 'apply' or 'destroy', got '%s'\n", command)
		os.Exit(1)
	}

	cfg, err := loadConfig("config.yaml")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading config: %v\n", err)
		os.Exit(1)
	}

	var stagesToProcess []Stage
	var operationErr error

	if command == "apply" {
		if len(cfg.ApplyStages) == 0 {
			fmt.Fprintln(os.Stderr, "Error: no apply_stages defined in config.yaml")
			os.Exit(1)
		}
		stagesToProcess = cfg.ApplyStages
	} else {
		if len(cfg.DestroyStages) == 0 {
			fmt.Fprintln(os.Stderr, "Error: no destroy_stages defined in config.yaml")
			os.Exit(1)
		}
		stagesToProcess = cfg.DestroyStages
	}

	// Show the execution plan first
	previewExecutionPlan(stagesToProcess, command)

	// Confirmation step
	fmt.Printf("Are you sure you want to %s the resources listed above? Type 'yes' to continue: ", command)
	reader := bufio.NewReader(os.Stdin)
	confirmation, _ := reader.ReadString('\n')
	if strings.TrimSpace(confirmation) != "yes" {
		fmt.Println("Operation cancelled by user.")
		os.Exit(0)
	}

	fmt.Printf("Starting Terraform %s process...\n", command)
	operationErr = processStages(stagesToProcess, command)

	if operationErr != nil {
		fmt.Fprintf(os.Stderr, "Terraform %s process completed with errors:\n%v\n", command, operationErr)
		os.Exit(1)
	}

	fmt.Printf("Terraform %s completed successfully.\n", command)
}
