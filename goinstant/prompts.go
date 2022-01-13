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
		selectDefaultOrCustom()
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
		Label: "Startup Package List (Comma Delimited). e.g. iol-openhim,reverse-proxy-nginx",
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
			"Initialise IOL - OpenHIM",
			"Initialise Reverse Proxy - NGINX",
			"Initialise FHIR Data Store - HAPI-FHIR",
			"Initialise Message Bus - Kafka",
			"Initialise Elastic-Analytics - ElasticSearch and Kibana",
			"Initialise Elastic-Pipeline - LogStash",
			"Initialise Elastic Monitoring - MetricBeats and FileBeats",
			"Initialise System Monitoring - Prometheus and Grafana",
			"Stop All Services and Cleanup Docker",
			"Stop and Cleanup IOL - OpenHIM",
			"Stop and Cleanup Reverse Proxy - NGINX",
			"Stop and Cleanup FHIR Data Store - HAPI-FHIR",
			"Stop and Cleanup Message Bus - Kafka",
			"Stop and Cleanup Elastic-Analytics - ElasticSearch and Kibana",
			"Stop and Cleanup Elastic-Pipeline - LogStash",
			"Stop and Cleanup Elastic Monitoring - MetricBeats and FileBeats",
			"Stop and Cleanup System Monitoring - Prometheus and Grafana",
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

	case "Initialise IOL - OpenHIM":
		fmt.Println("...Setting up IOL - OpenHIM Package")
		RunDirectDockerCommand([]string{"docker", "iol-openhim", "init"})
		selectDefaultInstall()

	case "Initialise Reverse Proxy - NGINX":
		fmt.Println("...Setting up Reverse Proxy - NGINX Package")
		RunDirectDockerCommand([]string{"docker", "reverse-proxy-nginx", "init"})
		selectDefaultInstall()

	case "Initialise FHIR Datastore - HAPI-FHIR":
		fmt.Println("...Setting up FHIR Datastore - HAPI-FHIR Package")
		RunDirectDockerCommand([]string{"docker", "fhir-datastore-hapi-fhir", "init"})
		selectDefaultInstall()

	case "Initialise Message Bus - Kafka":
		fmt.Println("...Setting up Message Bus - Kafka Package")
		RunDirectDockerCommand([]string{"docker", "message-bus-kafka", "init"})
		selectDefaultInstall()

	case "Initialise Elastic-Analytics - ElasticSearch and Kibana":
		fmt.Println("...Setting up Elastic-Analytics - ElasticSearch and Kibana Package")
		RunDirectDockerCommand([]string{"docker", "elastic-analytics-elasticsearch-kibana", "init"})
		selectDefaultInstall()

	case "Initialise Elastic-Pipeline - LogStash":
		fmt.Println("...Setting up Elastic-Pipeline - LogStash Package")
		RunDirectDockerCommand([]string{"docker", "elastic-pipeline-logstash", "init"})
		selectDefaultInstall()

	case "Initialise Elastic Monitoring - MetricBeats and FileBeats":
		fmt.Println("...Setting up Elastic Monitoring - MetricBeats and FileBeats Package")
		RunDirectDockerCommand([]string{"docker", "elastic-monitoring-metricbeats-filebeats", "init"})
		selectDefaultInstall()

	case "Initialise System Monitoring - Prometheus and Grafana":
		fmt.Println("...Setting up System Monitoring - Prometheus and Grafana Package")
		RunDirectDockerCommand([]string{"docker", "system-monitoring-prometheus-grafana", "init"})
		selectDefaultInstall()

	case "Stop All Services and Cleanup Docker":
		fmt.Println("Stopping and Cleaning Up Everything...")
		RunDirectDockerCommand([]string{"docker", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup IOL - OpenHIM":
		fmt.Println("Stopping and Cleaning Up IOL - OpenHIM...")
		RunDirectDockerCommand([]string{"docker", "iol-openhim", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Reverse Proxy - NGINX":
		fmt.Println("Stopping and Cleaning Up Reverse Proxy - NGINX...")
		RunDirectDockerCommand([]string{"docker", "reverse-proxy-nginx", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup FHIR Datastore - HAPI-FHIR":
		fmt.Println("Stopping and Cleaning Up FHIR Datastore - HAPI-FHIR...")
		RunDirectDockerCommand([]string{"docker", "fhir-datastore-hapi-fhir", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Message Bus - Kafka":
		fmt.Println("Stopping and Cleaning Up Message Bus - Kafka...")
		RunDirectDockerCommand([]string{"docker", "message-bus-kafka", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Elastic-Analytics - ElasticSearch and Kibana":
		fmt.Println("Stopping and Cleaning Up Elastic-Analytics - ElasticSearch and Kibana...")
		RunDirectDockerCommand([]string{"docker", "elastic-analytics-elasticsearch-kibana", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Elastic-Pipeline - LogStash":
		fmt.Println("Stopping and Cleaning Up Elastic-Pipeline - LogStash...")
		RunDirectDockerCommand([]string{"docker", "elastic-pipeline-logstash", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup Elastic Monitoring - MetricBeats and FileBeats":
		fmt.Println("Stopping and Cleaning Up Elastic Monitoring - MetricBeats and FileBeats...")
		RunDirectDockerCommand([]string{"docker", "elastic-monitoring-metricbeats-filebeats", "destroy"})
		selectDefaultInstall()

	case "Stop and Cleanup System Monitoring - Prometheus and Grafana":
		fmt.Println("Stopping and Cleaning Up System Monitoring - Prometheus and Grafana...")
		RunDirectDockerCommand([]string{"docker", "system-monitoring-prometheus-grafana", "destroy"})
		selectDefaultInstall()

	case "Quit":
		quit()

	case "Back":
		selectDefaultOrCustom()
	}

	return nil
}
