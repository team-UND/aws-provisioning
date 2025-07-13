package main

import (
	"fmt"
	"os"
	"os/exec"
	"sync"

	"gopkg.in/yaml.v2"
)

type Config struct {
	Directories []string `yaml:"directories"`
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

func runTerraformApply(cfg *Config) error {
	// Apply order: vpc -> rds, elasticache, networking (parallel) -> iam -> ecs -> services, lambda (parallel)

	// 1. vpc
	fmt.Printf("Running terraform apply in %s\n", cfg.Directories[0])
	if err := runTerraformCommand(cfg.Directories[0], "apply"); err != nil {
		return err
	}
	fmt.Println("Step 1 (vpc) completed.")

	// 2. rds, elasticache, networking (parallel)
	var wg sync.WaitGroup
	errCh := make(chan error, 3)

	for _, dir := range cfg.Directories[1:4] {
		wg.Add(1)
		go func(d string) {
			defer wg.Done()
			fmt.Printf("Running terraform apply in %s\n", d)
			if err := runTerraformCommand(d, "apply"); err != nil {
				errCh <- err
			}
		}(dir)
	}
	wg.Wait()
	close(errCh)
	for err := range errCh {
		if err != nil {
			return err
		}
	}
	fmt.Println("Step 2 (rds, elasticache, networking) completed.")

	// 3. iam
	fmt.Printf("Running terraform apply in %s\n", cfg.Directories[4])
	if err := runTerraformCommand(cfg.Directories[4], "apply"); err != nil {
		return err
	}
	fmt.Println("Step 3 (iam) completed.")

	// 4. ecs
	fmt.Printf("Running terraform apply in %s\n", cfg.Directories[5])
	if err := runTerraformCommand(cfg.Directories[5], "apply"); err != nil {
		return err
	}
	fmt.Println("Step 4 (ecs) completed.")

	// 5. services, lambda (parallel)
	var wg2 sync.WaitGroup
	errCh2 := make(chan error, 2)

	for _, dir := range cfg.Directories[6:8] {
		wg2.Add(1)
		go func(d string) {
			defer wg2.Done()
			fmt.Printf("Running terraform apply in %s\n", d)
			if err := runTerraformCommand(d, "apply"); err != nil {
				errCh2 <- err
			}
		}(dir)
	}
	wg2.Wait()
	close(errCh2)
	for err := range errCh2 {
		if err != nil {
			return err
		}
	}
	fmt.Println("Step 5 (services, lambda) completed.")

	return nil
}

func runTerraformDestroy(cfg *Config) error {
	// Destroy order: services, lambda (parallel) -> ecs -> iam -> rds, elasticache, networking (parallel) -> vpc

	// 1. services, lambda (parallel)
	var wg sync.WaitGroup
	errCh := make(chan error, 2)

	for _, dir := range cfg.Directories[6:8] {
		wg.Add(1)
		go func(d string) {
			defer wg.Done()
			fmt.Printf("Running terraform destroy in %s\n", d)
			if err := runTerraformCommand(d, "destroy"); err != nil {
				errCh <- err
			}
		}(dir)
	}
	wg.Wait()
	close(errCh)
	for err := range errCh {
		if err != nil {
			return err
		}
	}
	fmt.Println("Step 1 (services, lambda) destroyed.")

	// 2. ecs
	fmt.Printf("Running terraform destroy in %s\n", cfg.Directories[5])
	if err := runTerraformCommand(cfg.Directories[5], "destroy"); err != nil {
		return err
	}
	fmt.Println("Step 2 (ecs) destroyed.")

	// 3. iam
	fmt.Printf("Running terraform destroy in %s\n", cfg.Directories[4])
	if err := runTerraformCommand(cfg.Directories[4], "destroy"); err != nil {
		return err
	}
	fmt.Println("Step 3 (iam) destroyed.")

	// 4. rds, elasticache, networking (parallel)
	var wg2 sync.WaitGroup
	errCh2 := make(chan error, 3)

	for _, dir := range cfg.Directories[1:4] {
		wg2.Add(1)
		go func(d string) {
			defer wg2.Done()
			fmt.Printf("Running terraform destroy in %s\n", d)
			if err := runTerraformCommand(d, "destroy"); err != nil {
				errCh2 <- err
			}
		}(dir)
	}
	wg2.Wait()
	close(errCh2)
	for err := range errCh2 {
		if err != nil {
			return err
		}
	}
	fmt.Println("Step 4 (rds, elasticache, networking) destroyed.")

	// 5. vpc
	fmt.Printf("Running terraform destroy in %s\n", cfg.Directories[0])
	if err := runTerraformCommand(cfg.Directories[0], "destroy"); err != nil {
		return err
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

	if len(cfg.Directories) < 8 {
		fmt.Fprintln(os.Stderr, "Error: config must have at least 8 directories")
		os.Exit(1)
	}

	var operationErr error
	if command == "apply" {
		fmt.Println("Starting Terraform apply process...")
		operationErr = runTerraformApply(cfg)
	} else {
		fmt.Println("Starting Terraform destroy process...")
		operationErr = runTerraformDestroy(cfg)
	}

	if operationErr != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", operationErr)
		os.Exit(1)
	}

	fmt.Printf("Terraform %s completed successfully in all directories.\n", command)
}
