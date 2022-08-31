package main

import (
	"JSR/go-utils"
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"github.com/docker/cli/cli/command/stack/options"
	"github.com/luno/jettison/log"
)

var (
	mode          *string
	action        *string
	packagePath   *string
	statefulNodes *string

	kafkaInstances string
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

	kafkaInstances = os.Getenv("KAFKA_INSTANCES")
	if kafkaInstances == "" {
		kafkaInstances = "1"
	}

	err = os.Setenv("KAFKA_INSTANCES", kafkaInstances)
	if err != nil {
		log.Error(context.Background(), err)
	}
}

func main() {
	switch *action {
	case "init":
		err := packageInit("instant")
		if err != nil {
			log.Error(context.Background(), err)
		}

	case "destroy":
		err := packageDestroy()
		if err != nil {
			log.Error(context.Background(), err)
		}
	}
}

func packageInit(namespace string) error {
	var composeFiles []string
	if *statefulNodes == "cluster" {
		fmt.Println("Running in cluster mode")

		composeFiles = append(composeFiles, "docker-compose.cluster.yml")
	} else {
		fmt.Println("Running in single-node mode")
		composeFiles = append(composeFiles, "docker-compose.yml")
	}

	if *mode == "dev" {
		fmt.Println("Running in DEV mode")
		composeFiles = append(composeFiles, "docker-compose.dev.yml")
	} else {
		fmt.Println("Running in PROD mode")
	}
	awaitHelper := options.Deploy{
		Composefiles: []string{filepath.Join(*packagePath, "compose", "docker-compose.await-helper.yml")},
		Namespace:    namespace,
		ResolveImage: "always",
	}

	errChan := make(chan error)
	kafkaDone := make(chan bool)

	// TODO: Fix writing on closed channel
	// defer close(errChan)
	// defer close(kafkaDone)
	go func() {
		kafka := options.Deploy{
			Composefiles: utils.PathPrepend(composeFiles, *packagePath, "compose"),
			Namespace:    namespace,
			ResolveImage: "always",
		}
		err := utils.StackDeploy(kafka)
		if err != nil {
			errChan <- err
		}

		kafkaDone <- true
	}()

	awaitDone := make(chan bool)

	// TODO: Fix writing on closed channel
	// defer close(awaitDone)
	go func() {
		awaitHelper := options.Deploy{
			Composefiles: []string{filepath.Join(*packagePath, "compose", "docker-compose.await-helper.yml")},
			Namespace:    namespace,
			ResolveImage: "always",
		}

		// Launch service as replicated job, when using this approach
		// it is possible to monitor completed jobs vs desired jobs, the downside is that the completed container
		// will stick around even after removing the service, which doesn't happen with a normal service
		// err = utils.CreateService(awaitHelper)
		// if err != nil {
		// 	errChan <- err
		// }

		err := utils.StackDeploy(awaitHelper)
		if err != nil {
			errChan <- err
		}

		awaitDone <- true
	}()

	for !<-kafkaDone && !<-awaitDone {
		if <-errChan != nil {
			return <-errChan
		}
	}

	err := utils.AwaitJobComplete(namespace+"_await-helper", awaitHelper)
	if err != nil {
		return err
	}
	err = utils.RemoveService(namespace + "_await-helper")
	if err != nil {
		return err
	}

	configImporter := options.Deploy{
		Composefiles: []string{filepath.Join(*packagePath, "importer", "docker-compose.config.yml")},
		Namespace:    namespace,
		ResolveImage: "always",
	}

	err = utils.SetConfigDigests(configImporter.Namespace, configImporter.Composefiles...)
	if err != nil {
		return err
	}

	err = utils.StackDeploy(configImporter)
	if err != nil {
		return err
	}

	err = utils.AwaitContainerComplete(namespace + "_message-bus-kafka-config-importer")
	if err != nil {
		return err
	}

	err = utils.RemoveService(namespace + "_message-bus-kafka-config-importer")
	if err != nil {
		return err
	}

	return utils.RemoveStaleServiceConfigs(configImporter.Namespace, configImporter.Composefiles...)
}

func packageDestroy() error {
	output, err := utils.Bash("")
	if err != nil {
		return err
	}
	fmt.Println(output)

	return nil
}
