package utils

import (
	"fmt"

	"github.com/docker/cli/cli/command/stack/options"
	deploy "github.com/docker/cli/cli/command/stack/swarm"
	"github.com/luno/jettison/errors"
)

func StackDeployFromBash(dir string, composeFiles ...string) error {
	var fileString string
	for _, file := range composeFiles {
		fileString += " -c " + file
	}

	output, err := Bash("docker stack deploy" + fileString + " instant")
	if err != nil {
		return errors.Wrap(err, "")
	}
	fmt.Println(output)

	return nil
}

func StackDeploy(option options.Deploy) error {
	cli, err := NewCli()
	if err != nil {
		return err
	}

	config, err := ConfigFromCompose(option.Namespace, option.Composefiles...)
	if err != nil {
		return err
	}

	err = deploy.RunDeploy(cli, option, config)
	if err != nil {
		return errors.Wrap(err, "")
	}
	return nil
}
