package utils

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/docker/docker/api/types"
	cont "github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/filters"
	"github.com/pkg/errors"
)

var ErrEmptyContainersObject = errors.New("empty supplied/returned container object")

func ListContainerByName(containerName string) (types.Container, error) {
	client, err := NewApiClient()
	if err != nil {
		return types.Container{}, err
	}

	filtersPair := filters.KeyValuePair{
		Key:   "name",
		Value: containerName,
	}

	containers, err := client.ContainerList(context.Background(), types.ContainerListOptions{
		Filters: filters.NewArgs(filtersPair),
		All:     true,
	})
	if err != nil {
		return types.Container{}, err
	}

	return LatestContainer(containers, false)
}

// This code attempts to combat old/dead containers lying around and being selected instead of the new container
func LatestContainer(containers []types.Container, allowAllFails bool) (types.Container, error) {
	if len(containers) == 0 {
		return types.Container{}, ErrEmptyContainersObject
	}

	var latestContainer types.Container
	for _, container := range containers {
		if container.Created > latestContainer.Created {
			latestContainer = container
		}
	}

	return latestContainer, nil
}

func AwaitContainerComplete(containerName string) error {
	cli, err := NewCli()
	if err != nil {
		return err
	}
	client := cli.Client()

	startTime := time.Now()
	var container types.Container
	var warned bool
	for time.Since(startTime) < 1*time.Minute {
		container, err = ListContainerByName(containerName)
		if err != nil && err != ErrEmptyContainersObject {
			return err
		}

		if time.Since(startTime) > 10*time.Second && !warned {
			fmt.Println("Waited 10 seconds for " + containerName + " container to start")
			warned = true
		}

		if len(container.Names) > 0 {
			break
		}
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)

	statusCh, errCh := client.ContainerWait(ctx, container.ID, cont.WaitConditionNotRunning)
	select {
	case err := <-errCh:
		if err != nil && !strings.Contains(err.Error(), "No such container") {
			cancel()
			return err
		}
		// errors.New("Waited 60 seconds for " + containerName + " container to complete, aborting...")
	case status := <-statusCh:
		if status.StatusCode != 0 {
			fmt.Println("[WARN]", containerName, "exited with code", status.StatusCode)
		}
	}

	cancel()
	return nil
}
