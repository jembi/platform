package main

import (
	"JSR/go-utils"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/docker/cli/cli/command/stack/options"
)

var (
	mode          *string
	action        *string
	packagePath   *string
	statefulNodes *string

	esLeaderNode string
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

	esLeaderNode = os.Getenv("ES_LEADER_NODE")
	if esLeaderNode == "" {
		esLeaderNode = "analytics-datastore-elastic-search"
	}
}

func main() {
	switch *action {
	case "init":
		err := packageInit("instant")
		if err != nil {
			log.Println(err)
		}

	case "destroy":
		err := packageDestroy()
		if err != nil {
			log.Println(err)
		}
	}
}

func packageInit(namespace string) error {
	var composeFiles []string
	if *statefulNodes == "cluster" {
		fmt.Println("Running in cluster mode")

		// TODO: implement remaining cluster functionality
		err := createCerts(namespace)
		if err != nil {
			return err
		}

		composeFiles = append(composeFiles, "docker-compose.cluster.yml")
	} else {
		composeFiles = append(composeFiles, "docker-compose.yml")
	}

	if *mode == "dev" {
		composeFiles = append(composeFiles, "docker-compose.dev.yml")
	}

	option := options.Deploy{
		Composefiles: utils.PathPrepend(composeFiles, *packagePath, "compose"),
		Namespace:    namespace,
		ResolveImage: "always",
	}

	err := utils.StackDeploy(option)
	if err != nil {
		return err
	}

	configImporter := options.Deploy{
		Composefiles: []string{filepath.Join(*packagePath, "importer", "docker-compose.config.yml")},
		Namespace:    namespace,
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

	err = utils.SetElasticsearchPasswords(*packagePath)
	if err != nil {
		return err
	}

	err = utils.NetworkJoinAwait(option.Namespace+"_"+esLeaderNode, option.Namespace+"_default")
	if err != nil {
		return err
	}

	err = utils.StackDeploy(configImporter)
	if err != nil {
		return err
	}

	err = utils.AwaitContainerComplete(namespace + "_elastic-search-config-importer")
	if err != nil {
		return err
	}

	return utils.RemoveService(namespace + "_elastic-search-config-importer")
}

func packageDestroy() error {
	output, err := utils.Bash("docker service rm instant_" + esLeaderNode)
	if err != nil {
		return err
	}
	fmt.Println(output)

	return nil
}

func createCerts(namespace string) error {
	option := options.Deploy{
		Composefiles: utils.PathPrepend([]string{"docker-compose.certs.yml"}, *packagePath, "compose"),
		Namespace:    namespace,
		ResolveImage: "always",
	}

	err := utils.StackDeploy(option)
	if err != nil {
		return err
	}

	err = utils.AwaitContainerComplete(namespace + "_create_certs")
	if err != nil {
		return err
	}

	return utils.RemoveService(namespace + "_create_certs")
}
