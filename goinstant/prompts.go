package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/manifoldco/promptui"
	"github.com/pkg/errors"
)

func quit() {
	stopContainer()
	os.Exit(0)
}

func selectDefaultOrCustom() error {
	prompt := promptui.Select{
		Label: "Great, now choose an installation type",
		Items: []string{"Default Install Options", "Custom Install Options", "Quit", "Back"},
		Size:  12,
	}
	_, result, err := prompt.Run()
	if err != nil {
		return errors.Wrap(err, "default/custom prompt failed")
	}

	fmt.Printf("You chose %q\n========================================\n", result)

	switch result {
	case "Default Install Options":
		selectDefaultInstall()
	case "Custom Install Options":
		selectCustomOptions()
	case "Quit":
		quit()
	case "Back":
		selectSetup()
	}

	return nil
}

func selectCustomOptions() error {
	prompt := promptui.Select{
		Label: "Great, now choose an action",
		Items: []string{
			"Choose deploy action (default is init)",
			"Specify deploy packages",
			"Specify environment variable file location",
			"Specify environment variables",
			"Specify custom package locations",
			"Toggle only flag",
			"Specify Instant Version",
			"Toggle dev mode (default mode is prod)",
			"Execute with current options",
			"View current options set",
			"Reset to default options",
			"Quit",
			"Back",
		},
		Size: 12,
	}

	_, result, err := prompt.Run()
	if err != nil {
		return errors.Wrap(err, "Custom options prompt failed")
	}

	switch result {
	case "Choose deploy action (default is init)":
		err = setStartupAction()
		if err != nil {
			fmt.Println(err)
		}
	case "Specify deploy packages":
		setStartupPackages()
	case "Specify environment variable file location":
		setEnvVarFileLocation()
	case "Specify environment variables":
		setEnvVars()
	case "Specify custom package locations":
		setCustomPackages()
	case "Toggle only flag":
		toggleOnlyFlag()
	case "Toggle dev mode (default mode is prod)":
		toggleDevMode()
	case "Specify Instant Version":
		setInstantVersion()
	case "Execute with current options":
		printAll(false)
		executeCommand()
	case "View current options set":
		printAll(true)
	case "Reset to default options":
		resetAll()
		printAll(true)
	case "Quit":
		quit()
	case "Back":
		selectDefaultOrCustom()
	}

	return nil
}

func resetAll() {
	customOptions.startupAction = "init"
	customOptions.startupPackages = make([]string, 0)
	customOptions.envVarFileLocation = ""
	customOptions.envVars = make([]string, 0)
	customOptions.customPackageFileLocations = make([]string, 0)
	customOptions.onlyFlag = false
	customOptions.instantVersion = "latest"
	customOptions.devMode = false
	fmt.Println("\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\nAll custom options have been reset to default.\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
}

func setStartupAction() error {
	prompt := promptui.Select{
		Label: "Great, now choose a deploy action",
		Items: []string{"init", "destroy", "up", "down", "test", "Quit", "Back"},
		Size:  12,
	}

	_, result, err := prompt.Run()
	if err != nil {
		return errors.Wrap(err, "Startup action prompt failed")
	}

	fmt.Printf("You chose %q\n========================================\n", result)

	switch result {
	case "init", "destroy", "up", "down", "test":
		customOptions.startupAction = result
		selectCustomOptions()
	case "Quit":
		quit()
	case "Back":
		selectCustomOptions()
	}

	return nil
}

func executeCommand() {
	startupCommands := []string{"docker", customOptions.startupAction}

	if len(customOptions.startupPackages) == 0 {
		fmt.Printf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n" +
			"Warning: No package IDs specified, all default packages will be included in your command.\n" +
			">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n")
	}

	startupCommands = append(startupCommands, customOptions.startupPackages...)

	if customOptions.envVarFileLocation != "" && len(customOptions.envVarFileLocation) > 0 {
		startupCommands = append(startupCommands, "--env-file="+customOptions.envVarFileLocation)
	}
	if customOptions.envVars != nil && len(customOptions.envVars) > 0 {
		for _, e := range customOptions.envVars {
			startupCommands = append(startupCommands, "-e="+e)
		}
	}
	if customOptions.customPackageFileLocations != nil && len(customOptions.customPackageFileLocations) > 0 {
		for _, c := range customOptions.customPackageFileLocations {
			startupCommands = append(startupCommands, "-c="+c)
		}
	}
	if customOptions.onlyFlag {
		startupCommands = append(startupCommands, "--only")
	}
	if customOptions.devMode {
		startupCommands = append(startupCommands, "--dev")
	}
	startupCommands = append(startupCommands, "--instant-version="+customOptions.instantVersion)
	RunDirectDockerCommand(startupCommands)
}

func printSlice(slice []string) {
	for _, s := range slice {
		fmt.Printf("-%q\n", s)
	}
	fmt.Println()
}

func printAll(loopback bool) {
	fmt.Println("\nCurrent Custom Options Specified\n---------------------------------")
	fmt.Println("Startup Action:")
	fmt.Printf("-%q\n", customOptions.startupAction)
	fmt.Println("Startup Packages:")
	if customOptions.startupPackages != nil && len(customOptions.startupPackages) > 0 {
		printSlice(customOptions.startupPackages)
	}
	fmt.Println("Environment Variable File Path:")
	if customOptions.envVarFileLocation != "" && len(customOptions.envVarFileLocation) > 0 {
		fmt.Printf("-%q\n", customOptions.envVarFileLocation)
	}
	fmt.Println("Environment Variables:")
	if customOptions.envVars != nil && len(customOptions.envVars) > 0 {
		printSlice(customOptions.envVars)
	}
	if customOptions.customPackageFileLocations != nil && len(customOptions.customPackageFileLocations) > 0 {
		fmt.Println("Custom Packages:")
		printSlice(customOptions.customPackageFileLocations)
	}
	fmt.Println("Instant Image Version:")
	fmt.Printf("-%q\n", customOptions.instantVersion)

	fmt.Println("Only Flag Setting:")
	if customOptions.onlyFlag {
		fmt.Printf("-%q\n\n", "On")
	} else {
		fmt.Printf("-%q\n\n", "Off")
	}
	fmt.Println("Dev Mode Setting:")
	if customOptions.devMode {
		fmt.Printf("-%q\n\n", "On")
	} else {
		fmt.Printf("-%q\n\n", "Off")
	}
	if loopback {
		selectCustomOptions()
	}
}

func setStartupPackages() {
	if customOptions.startupPackages != nil && len(customOptions.startupPackages) > 0 {
		fmt.Println("\nCurrent Startup Packages Specified:")
		printSlice(customOptions.startupPackages)
	}
	prompt := promptui.Prompt{
		Label: "Startup Package List(Comma Delimited). e.g. core,cdr",
	}
	packageList, err := prompt.Run()
	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
		selectCustomOptions()
	}

	startupPackages := strings.Split(packageList, ",")

	for _, p := range startupPackages {
		if !sliceContains(customOptions.startupPackages, p) {
			customOptions.startupPackages = append(customOptions.startupPackages, p)
		} else {
			fmt.Printf(p + " package already exists in the list.\n")
		}
	}
	selectCustomOptions()
}

func setCustomPackages() {
	if customOptions.customPackageFileLocations != nil && len(customOptions.customPackageFileLocations) > 0 {
		fmt.Println("Current Custom Packages Specified:")
		printSlice(customOptions.customPackageFileLocations)
	}
	prompt := promptui.Prompt{
		Label: "Custom Package List(Comma Delimited). e.g. " + filepath.FromSlash("../project/cdr") + "," + filepath.FromSlash("../project/demo"),
	}
	customPackageList, err := prompt.Run()
	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
		selectCustomOptions()
	}

	newCustomPackages := strings.Split(customPackageList, ",")

	for _, cp := range newCustomPackages {
		if strings.Contains(cp, "http") {
			if !sliceContains(customOptions.customPackageFileLocations, cp) {
				customOptions.customPackageFileLocations = append(customOptions.customPackageFileLocations, cp)
			} else {
				fmt.Printf(cp + " URL already exists in the list.\n")
			}
		} else {
			exists, fileErr := fileExists(cp)
			if exists {
				if !sliceContains(customOptions.customPackageFileLocations, cp) {
					customOptions.customPackageFileLocations = append(customOptions.customPackageFileLocations, cp)
				} else {
					fmt.Printf(cp + " path already exists in the list.\n")
				}
			} else {
				fmt.Printf("\nFile at location %q could not be found due to error: %v\n", cp, fileErr)
				fmt.Println("\n-----------------\nPlease try again.\n-----------------")
			}
		}
	}
	selectCustomOptions()
}

func setEnvVarFileLocation() {
	if customOptions.envVarFileLocation != "" && len(customOptions.envVarFileLocation) > 0 {
		fmt.Println("Current Environment Variable File Location Specified:")
		fmt.Printf("-%q\n", customOptions.envVarFileLocation)
	}
	prompt := promptui.Prompt{
		Label: "Environment Variable file location e.g. " + filepath.FromSlash("../project/prod.env"),
	}
	envVarFileLocation, err := prompt.Run()
	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
		selectCustomOptions()
	}
	exists, fileErr := fileExists(envVarFileLocation)
	if exists {
		customOptions.envVarFileLocation = envVarFileLocation
	} else {
		fmt.Printf("\nFile at location %q could not be found due to error: %v\n", envVarFileLocation, fileErr)
		fmt.Println("\n-----------------\nPlease try again.\n-----------------")
	}
	selectCustomOptions()
}

func setInstantVersion() {
	if customOptions.instantVersion != "latest" && len(customOptions.instantVersion) > 0 {
		fmt.Println("Current Instant OpenHIE Image Version Specified:")
		fmt.Printf("-%q\n", customOptions.instantVersion)
	}
	prompt := promptui.Prompt{
		Label: "Instant OpenHIE Image Version e.g. 0.0.9",
	}
	instantVersion, err := prompt.Run()

	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
		selectCustomOptions()
	}

	customOptions.instantVersion = instantVersion
	selectCustomOptions()
}

func setEnvVars() {
	if customOptions.envVars != nil && len(customOptions.envVars) > 0 {
		fmt.Println("Current Environment Variables Specified:")
		printSlice(customOptions.envVars)
	}
	prompt := promptui.Prompt{
		Label: "Environment Variable List(Comma Delimited). e.g. NODE_ENV=PROD,DOMAIN_NAME=instant.com",
	}
	envVarList, err := prompt.Run()
	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
		selectCustomOptions()
	}

	newEnvVars := strings.Split(envVarList, ",")

	for _, env := range newEnvVars {
		if !sliceContains(customOptions.envVars, env) {
			customOptions.envVars = append(customOptions.envVars, env)
		} else {
			fmt.Printf(env + " environment variable already exists in the list.\n")
		}
	}
	selectCustomOptions()
}

func toggleOnlyFlag() {
	customOptions.onlyFlag = !customOptions.onlyFlag
	if customOptions.onlyFlag {
		fmt.Println("Only flag is now on")
	} else {
		fmt.Println("Only flag is now off")
	}
	selectCustomOptions()
}

func toggleDevMode() {
	customOptions.devMode = !customOptions.devMode
	if customOptions.devMode {
		fmt.Println("Dev mode is now on")
	} else {
		fmt.Println("Dev mode is now off")
	}
	selectCustomOptions()
}

// fileExists returns whether the given file or directory exists
func fileExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, err
	}

	return false, err
}

func selectDefaultInstall() error {
	prompt := promptui.Select{
		Label: "Great, now choose an action (Packages will start up their dependencies automatically)",
		Items: []string{
			"Initialise All Packages",
			"Initialise Core",
			"Initialise Client",
			"Initialise Elastic-Analytics",
			"Initialise Elastic-Pipeline",
			"Initialise Electronic Medical Record",
			"Initialise Health Management Information System",
			"Initialise Health Worker", "Initialise Facility Registry",
			"Initialise Workforce",
			"Stop All Services and Cleanup Docker",
			"Stop and Cleanup Core",
			"Stop and Cleanup Client",
			"Stop and Cleanup Elastic-Analytics",
			"Stop and Cleanup Elastic-Pipeline",
			"Stop and Cleanup Electronic Medical Record",
			"Stop and Cleanup Health Management Information System",
			"Stop and Cleanup Health Worker",
			"Stop and Cleanup Facility Registry",
			"Stop and Cleanup Workforce",
			"Quit",
			"Back",
		},
		Size: 12,
	}

	_, result, err := prompt.Run()
	if err != nil {
		return errors.Wrap(err, "Default install prompt failed")
	}

	fmt.Printf("You chose %q\n========================================\n", result)

	switch result {
	case "Initialise All Packages":
		fmt.Println("...Setting up All Packages")
		RunDirectDockerCommand([]string{"docker", "init"})
		selectDefaultInstall()

	case "Initialise Core":
		fmt.Println("...Setting up Core Package")
		RunDirectDockerCommand([]string{"docker", "core", "init"})
		selectDefaultInstall()

	case "Initialise Client":
		fmt.Println("...Setting up Client Package")
		RunDirectDockerCommand([]string{"docker", "client", "init"})
		selectDefaultInstall()

	case "Initialise Elastic-Analytics":
		fmt.Println("...Setting up Elastic-Analytics Package")
		RunDirectDockerCommand([]string{"docker", "elastic-analytics", "init"})
		selectDefaultInstall()

	case "Initialise Elastic-Pipeline":
		fmt.Println("...Setting up Elastic-Pipeline Package")
		RunDirectDockerCommand([]string{"docker", "elastic-pipeline", "init"})
		selectDefaultInstall()

	case "Initialise Electronic Medical Record":
		fmt.Println("...Setting up Electronic Medical Record Package")
		RunDirectDockerCommand([]string{"docker", "emr", "init"})
		selectDefaultInstall()

	case "Initialise Health Management Information System":
		fmt.Println("...Setting up Health Management Information System Package")
		RunDirectDockerCommand([]string{"docker", "hmis", "init"})
		selectDefaultInstall()

	case "Initialise Health Worker":
		fmt.Println("...Setting up Health Worker Package")
		RunDirectDockerCommand([]string{"docker", "healthworker", "init"})
		selectDefaultInstall()

	case "Initialise Facility Registry":
		fmt.Println("...Setting up Facility Registry Package")
		RunDirectDockerCommand([]string{"docker", "facility", "init"})
		selectDefaultInstall()

	case "Initialise Workforce":
		fmt.Println("...Setting up Workforce Package")
		RunDirectDockerCommand([]string{"docker", "mcsd", "init"})
		selectDefaultInstall()

	case "Stop All Services and Cleanup Docker":
		fmt.Println("Stopping and Cleaning Up Everything...")
		RunDirectDockerCommand([]string{"docker", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Core":
		fmt.Println("Stopping and Cleaning Up Core...")
		RunDirectDockerCommand([]string{"docker", "core", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Client":
		fmt.Println("Stopping and Cleaning Up Client...")
		RunDirectDockerCommand([]string{"docker", "client", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Elastic-Analytics":
		fmt.Println("Stopping and Cleaning Up Elastic-Analytics...")
		RunDirectDockerCommand([]string{"docker", "elastic-analytics", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Elastic-Pipeline":
		fmt.Println("Stopping and Cleaning Up Elastic-Pipeline...")
		RunDirectDockerCommand([]string{"docker", "elastic-pipeline", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Electronic Medical Record":
		fmt.Println("Stopping and Cleaning Up Electronic Medical Record...")
		RunDirectDockerCommand([]string{"docker", "emr", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Health Management Information System":
		fmt.Println("Stopping and Cleaning Up Health Management Information System...")
		RunDirectDockerCommand([]string{"docker", "hmis", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Health Worker":
		fmt.Println("Stopping and Cleaning Up Health Worker...")
		RunDirectDockerCommand([]string{"docker", "healthworker", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Facility Registry":
		fmt.Println("Stopping and Cleaning Up Facility Registry...")
		RunDirectDockerCommand([]string{"docker", "facility", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Workforce":
		fmt.Println("Stopping and Cleaning Up Workforce...")
		RunDirectDockerCommand([]string{"docker", "mcsd", "destroy"})
		selectDefaultInstall()

	case "Quit":
		quit()

	case "Back":
		selectDefaultOrCustom()
	}

	return nil
}

func selectPackageCluster() error {
	prompt := promptui.Select{
		Label: "Great, now choose an action",
		Items: []string{"Initialise Core (Required, Start Here)", "Launch Facility Registry", "Launch Workforce", "Stop and Cleanup Core", "Stop and Cleanup Facility Registry", "Stop and Cleanup Workforce", "Stop All Services and Cleanup Kubernetes", "Quit", "Back"},
		Size:  12,
	}

	_, result, err := prompt.Run()
	if err != nil {
		return errors.Wrap(err, "Package cluster prompt failed")
	}

	fmt.Printf("\nYou chose %q\n========================================\n", result)

	switch result {
	case "Launch Core (Required, Start Here)":
		fmt.Println("...Setting up Core Package")
		RunDirectDockerCommand([]string{"k8s", "core", "init"})
		selectPackageCluster()

	case "Launch Facility Registry":
		fmt.Println("...Setting up Facility Registry Package")
		RunDirectDockerCommand([]string{"k8s", "facility", "up"})
		selectPackageCluster()

	case "Launch Workforce":
		fmt.Println("...Setting up Workforce Package")
		RunDirectDockerCommand([]string{"k8s", "healthworker", "up"})
		selectPackageCluster()

	case "Stop and Cleanup Core":
		fmt.Println("Stopping and Cleaning Up Core...")
		RunDirectDockerCommand([]string{"k8s", "core", "destroy"})
		selectPackageCluster()

	case "Stop and Cleanup Facility Registry":
		fmt.Println("Stopping and Cleaning Up Facility Registry...")
		RunDirectDockerCommand([]string{"k8s", "facility", "destroy"})
		selectPackageCluster()

	case "Stop and Cleanup Workforce":
		fmt.Println("Stopping and Cleaning Up Workforce...")
		RunDirectDockerCommand([]string{"k8s", "healthworker", "destroy"})
		selectPackageCluster()

	case "Stop All Services and Cleanup Kubernetes":
		fmt.Println("Stopping and Cleaning Up Everything...")
		RunDirectDockerCommand([]string{"k8s", "core", "destroy"})
		RunDirectDockerCommand([]string{"k8s", "facility", "destroy"})
		RunDirectDockerCommand([]string{"k8s", "healthworker", "destroy"})
		selectPackageCluster()

	case "Quit":
		quit()

	case "Back":
		selectDefaultOrCustom()
	}

	return nil
}
