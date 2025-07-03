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
	// Apply order: VPC → Prometheus → Server → RDS, ElastiCache, CodeDeploy

	// 1. vpc
	fmt.Printf("Running terraform apply in %s\n", cfg.Directories[0])
	if err := runTerraformCommand(cfg.Directories[0], "apply"); err != nil {
		return err
	}

	// 2. prometheus
	fmt.Printf("Running terraform apply in %s\n", cfg.Directories[2])
	if err := runTerraformCommand(cfg.Directories[2], "apply"); err != nil {
		return err
	}

	// 3. server
	fmt.Printf("Running terraform apply in %s\n", cfg.Directories[1])
	if err := runTerraformCommand(cfg.Directories[1], "apply"); err != nil {
		return err
	}

	// 4. rds, elasticache, codedeploy
	var wg sync.WaitGroup
	errCh := make(chan error, 3)

	for _, dir := range cfg.Directories[3:6] {
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

	return nil
}

func runTerraformDestroy(cfg *Config) error {
	// Destroy order: RDS, ElastiCache, CodeDeploy → Server → Prometheus → VPC

	// 1. rds, elasticache, codedeploy
	var wg sync.WaitGroup
	errCh := make(chan error, 3)

	for _, dir := range cfg.Directories[3:6] {
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

	// 2. server
	fmt.Printf("Running terraform destroy in %s\n", cfg.Directories[1])
	if err := runTerraformCommand(cfg.Directories[1], "destroy"); err != nil {
		return err
	}

	// 3. prometheus
	fmt.Printf("Running terraform destroy in %s\n", cfg.Directories[2])
	if err := runTerraformCommand(cfg.Directories[2], "destroy"); err != nil {
		return err
	}

	// 4. vpc
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

	if len(cfg.Directories) < 6 {
		fmt.Fprintln(os.Stderr, "Error: config must have at least 6 directories")
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
