package main

import (
	"JSR/go-utils"
	"flag"
	"fmt"
	"log"

	"github.com/docker/cli/cli/command/stack/options"
	// dockerclient "github.com/docker/docker/client"
)

var (
	EnvVars     = make(map[string]string)
	mode        *string
	action      *string
	packagePath *string
)

func init() {
	// EnvVars["JS_REPORT_INSTANCES"] = os.Getenv("JS_REPORT_INSTANCES")

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
	composeFiles := []string{*packagePath + "/compose/docker-compose.yml"}
	if *mode == "dev" {
		composeFiles = append(composeFiles, *packagePath+"/compose/docker-compose.dev.yml")
	}

	var err error
	switch *action {
	case "init":
		err = packageInit(*packagePath, composeFiles...)
		if err != nil {
			fmt.Println(err)
		}

	case "destroy":
		err = packageDestroy()
		if err != nil {
			fmt.Println(err)
		}
	}
}

func packageInit(dir string, composeFiles ...string) error {
	option := options.Deploy{
		Composefiles: composeFiles,
		Namespace:    "instant",
		ResolveImage: "always",
	}

	// This function uses Docker's stack deploy function
	// err := utils.StackDeploy(option, composeFiles...)
	// if err != nil {
	// 	return err
	// }

	// option := options.Deploy{
	// 	Composefiles: []string{*packagePath + "/compose/docker-compose.await-helper.yml"},
	// 	Namespace:    "instant",
	// 	ResolveImage: "always",
	// }

	// err := utils.StackDeploy(option, option.Composefiles...)
	// if err != nil {
	// 	return err
	// }

	// This function simply runs a stack deploy using a bash command
	// err := utils.StackDeployFromBash(dir, composeFiles...)
	// if err != nil {
	// 	return err
	// }

	// This function creates a swarm service, in a much more configurable manner
	err := utils.CreateService(option)
	if err != nil {
		return err
	}

	err = utils.CreateService(options.Deploy{
		Composefiles: []string{*packagePath + "/compose/docker-compose.await-helper.yml"},
		Namespace:    "instant",
		ResolveImage: "always",
	})
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
