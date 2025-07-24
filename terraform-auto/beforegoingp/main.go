package main

import (
	"fmt"
	"os"
	"os/exec"
	"sync"

	"gopkg.in/yaml.v2"
)

type Stage struct {
	Name        string   `yaml:"name"`
	Parallel    bool     `yaml:"parallel"`
	Directories []string `yaml:"directories"`
}

type Config struct {
	ApplyStages   []Stage `yaml:"apply_stages"`
	DestroyStages []Stage `yaml:"destroy_stages"`
}

func runTerraformCommand(dir, command string) error {
	cmd := exec.Command("terraform", "init")
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("terraform init failed in %s: %w", dir, err)
	}

	var args []string
	switch command {
	case "apply":
		args = []string{"apply", "-parallelism=30", "-auto-approve"}
	case "destroy":
		args = []string{"destroy", "-parallelism=30", "-auto-approve"}
	default:
		return fmt.Errorf("unsupported command: %s", command)
	}

	cmd = exec.Command("terraform", args...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("terraform %s failed in %s: %w", command, dir, err)
	}

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

func processStages(stages []Stage, command string) error {
	for i, stage := range stages {
		fmt.Printf("--- Starting Stage %d: %s ---\n", i+1, stage.Name)

		if stage.Parallel {
			var wg sync.WaitGroup
			errCh := make(chan error, len(stage.Directories))

			for _, dir := range stage.Directories {
				wg.Add(1)
				go func(d string) {
					defer wg.Done()
					fmt.Printf("Running terraform %s in %s\n", command, d)
					if err := runTerraformCommand(d, command); err != nil {
						errCh <- err
					}
				}(dir)
			}
			wg.Wait()
			close(errCh)

			for err := range errCh {
				if err != nil {
					return fmt.Errorf("error in parallel stage '%s': %w", stage.Name, err)
				}
			}
		} else {
			for _, dir := range stage.Directories {
				fmt.Printf("Running terraform %s in %s\n", command, dir)
				if err := runTerraformCommand(dir, command); err != nil {
					return fmt.Errorf("error in sequential stage '%s' (directory: %s): %w", stage.Name, dir, err)
				}
			}
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
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	var operationErr error
	if command == "apply" {
		fmt.Println("Starting Terraform apply process...")
		if len(cfg.ApplyStages) == 0 {
			fmt.Fprintln(os.Stderr, "Error: no apply_stages defined in config.yaml")
			os.Exit(1)
		}
		operationErr = processStages(cfg.ApplyStages, "apply")
	} else {
		fmt.Println("Starting Terraform destroy process...")
		if len(cfg.DestroyStages) == 0 {
			fmt.Fprintln(os.Stderr, "Error: no destroy_stages defined in config.yaml")
			os.Exit(1)
		}
		operationErr = processStages(cfg.DestroyStages, "destroy")
	}

	if operationErr != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", operationErr)
		os.Exit(1)
	}

	fmt.Printf("Terraform %s completed successfully.\n", command)
}
