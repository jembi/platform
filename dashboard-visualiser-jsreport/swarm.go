package main

import (
	"JSR/go-utils"
	"flag"
	"fmt"
	"log"
	"os"
)

var (
	EnvVars     = make(map[string]string)
	mode        *string
	action      *string
	packagePath *string
)

func init() {
	EnvVars["JS_REPORT_INSTANCES"] = os.Getenv("JS_REPORT_INSTANCES")

	mode = flag.String("mode", "", "dev | prod")
	action = flag.String("action", "", "init | up | down | destroy")
	packagePath = flag.String("path", "", "path to package")

	flag.Parse()
	err := utils.ValidateArgs(*mode, *action, *packagePath)
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	composeFiles := []string{"docker-compose.yml"}
	if *mode == "dev" {
		composeFiles = append(composeFiles, "docker-compose.dev.yml")
	}

	var err error
	switch *action {
	case "init":
		err = packageInit(*packagePath, composeFiles...)
		if err != nil {
			log.Println(err)
		}

	case "destroy":
		err = packageDestroy()
		if err != nil {
			log.Println(err)
		}
	}
}

func packageInit(dir string, composeFiles ...string) error {
	err := utils.StackDeploy(dir, composeFiles...)
	if err != nil {
		return err
	}

	err = utils.StackDeploy(dir, "docker-compose.await-helper.yml")
	if err != nil {
		return err
	}

	err = utils.AwaitServiceRunning("dashboard-visualiser-jsreport", EnvVars["JS_REPORT_INSTANCES"], 0, 0)
	if err != nil {
		return err
	}

	return nil
}

func packageDestroy() error {
	output, err := utils.Bash("docker service rm instant_dashboard-visualiser-jsreport instant_jsreport-config-importer instant_await-helper")
	if err != nil {
		return err
	}
	fmt.Println(output)

	return nil
}
