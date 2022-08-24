package utils

import (
	"context"
	"time"

	"github.com/docker/docker/api/types"
	"github.com/luno/jettison/errors"
)

func NetworkJoinAwait(serviceName, networkName string) error {
	cli, err := NewCli()
	if err != nil {
		return err
	}
	client := cli.Client()

	startTime := time.Now()
	for time.Since(startTime) < 1*time.Minute {
		netResources, err := client.NetworkInspect(context.Background(), networkName, types.NetworkInspectOptions{Verbose: true})
		if err != nil {
			return errors.Wrap(err, "")
		}

		if netResources.Services != nil && len(netResources.Services[serviceName].Tasks) > 0 {
			return nil
		}
	}

	return errors.Wrap(errors.New(serviceName+" network join timed out."), "")
}
