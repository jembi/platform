package main

import (
	"JSR/go-utils"
	"flag"
	"fmt"
	"log"
)

var (
	mode          *string
	action        *string
	packagePath   *string
	statefulNodes *string
)

func init() {
	mode = flag.String("mode", "", "dev | prod")
	action = flag.String("action", "", "init | up | down | destroy")
	packagePath = flag.String("path", "", "path to package")
	statefulNodes = flag.String("statefulNodes", "", "single | cluster")

	flag.Parse()
	err := utils.ValidateArgs(*mode, *action, *packagePath, *statefulNodes)
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	composeFiles := []string{"docker-compose.yml"}
	if *mode == "dev" {
		composeFiles = append(composeFiles, "docker-compose.dev.yml")
	}
	if *statefulNodes == "cluster" {
		composeFiles = append(composeFiles, "docker-compose.cluster.yml")
		fmt.Println("Running in cluster mode")
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

	err = utils.AwaitContainerStartup("analytics-datastore-elastic-search", 0, 0)
	if err != nil {
		return err
	}

	err = utils.AwaitContainerReady("analytics-datastore-elastic-search", 0, 0)
	if err != nil {
		return err
	}

	err = utils.InstallExpect()
	if err != nil {
		return err
	}

	err = utils.SetElasticsearchPasswords(dir)
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
