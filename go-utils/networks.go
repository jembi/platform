package utils

import (
	"context"
	"time"

	"github.com/docker/docker/api/types"
	"github.com/pkg/errors"
)

func NetworkJoinAwait(serviceName, networkName string) error {
	cli, err := NewDummyCli()
	if err != nil {
		return err
	}
	client := cli.Client()

	startTime := time.Now()
	for time.Since(startTime) < 1*time.Minute {
		netResources, err := client.NetworkInspect(context.Background(), networkName, types.NetworkInspectOptions{Verbose: true})
		if err != nil {
			return err
		}

		if netResources.Services != nil && len(netResources.Services[serviceName].Tasks) > 0 {
			return nil
		}
	}

	return errors.New(serviceName + " network join timed out.")
}
