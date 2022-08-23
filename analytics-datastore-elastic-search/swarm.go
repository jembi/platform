package main

import (
	"JSR/go-utils"
	"flag"
	"fmt"
	"log"
	"path/filepath"

	"github.com/docker/cli/cli/command/stack/options"
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
	option := options.Deploy{
		Composefiles: utils.PathPrepend(composeFiles, dir, "compose"),
		Namespace:    "instant",
		ResolveImage: "always",
	}

	err := utils.StackDeploy(option)
	if err != nil {
		return err
	}

	configImporter := options.Deploy{
		Composefiles: []string{filepath.Join(*packagePath, "importer", "docker-compose.config.yml")},
		Namespace:    "instant",
		ResolveImage: "always",
	}

	err = utils.SetConfigDigests(configImporter.Composefiles...)
	if err != nil {
		return err
	}

	err = utils.RemoveStaleServiceConfigs(configImporter.Composefiles...)
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

	err = utils.NetworkJoinAwait(option.Namespace+"_analytics-datastore-elastic-search", option.Namespace+"_default")
	if err != nil {
		return err
	}

	err = utils.StackDeploy(configImporter)
	if err != nil {
		return err
	}

	return nil
}

func packageDestroy() error {
	output, err := utils.Bash("docker service rm instant_analytics-datastore-elastic-search")
	if err != nil {
		return err
	}
	fmt.Println(output)

	return nil
}
