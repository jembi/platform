package utils

import (
	"fmt"

	"github.com/docker/cli/cli/command/stack/options"
	deploy "github.com/docker/cli/cli/command/stack/swarm"
)

func StackDeployFromBash(dir string, composeFiles ...string) error {
	var fileString string
	for _, file := range composeFiles {
		fileString += " -c " + file
	}

	output, err := Bash("docker stack deploy" + fileString + " instant")
	if err != nil {
		return err
	}
	fmt.Println(output)

	return err
}

func StackDeploy(options options.Deploy, composeFiles ...string) error {
	cli, config, err := NewCliFromCompose(options, composeFiles...)
	if err != nil {
		return err
	}

	return deploy.RunDeploy(cli, options, config)
}
