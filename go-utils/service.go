package utils

import (
	"context"
	"log"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/swarm"
	"github.com/docker/docker/client"

	"github.com/docker/cli/cli/command/stack/options"
	composeTypes "github.com/docker/cli/cli/compose/types"
	// composeTypes "github.com/docker/cli/cli/compose/types"
)

type ServiceSpec struct {
	Replicas  uint64
	Resources swarm.ResourceRequirements
}

func CreateService(options options.Deploy, composeFiles ...string) error {
	_, config, err := NewCliFromCompose(options, composeFiles...)
	if err != nil {
		return err
	}

	containerSpec, err := parseContainerOptions(config)
	if err != nil {
		return err
	}

	serviceSpec, err := parseServiceOptions(config)
	if err != nil {
		return err
	}

	spec := swarm.ServiceSpec{
		Annotations: swarm.Annotations{
			Name: "dashboard-visualiser-jsreport",
		},
		TaskTemplate: swarm.TaskSpec{
			ContainerSpec: containerSpec,
			Resources: &swarm.ResourceRequirements{
				Limits:       serviceSpec.Resources.Limits,
				Reservations: serviceSpec.Resources.Reservations,
			},
		},
		Mode: swarm.ServiceMode{
			Replicated: &swarm.ReplicatedService{
				Replicas: &serviceSpec.Replicas,
			},
		},
		Networks: []swarm.NetworkAttachmentConfig{
			{
				Target: "test-network",
			},
		},
	}

	createOptions := types.ServiceCreateOptions{
		QueryRegistry: false,
	}

	sClient, err := client.NewClientWithOpts()
	if err != nil {
		return err
	}

	_, err = sClient.ServiceCreate(context.Background(), spec, createOptions)
	if err != nil {
		log.Println(err)
		return err
	}

	return nil
}

func parseContainerOptions(conf *composeTypes.Config) (*swarm.ContainerSpec, error) {
	service := conf.Services[0]

	var environment []string
	for k, v := range service.Environment {
		environment = append(environment, k+"="+*v)
	}

	containerSpec := &swarm.ContainerSpec{
		Image:   service.Image,
		Command: service.Command,
		Labels:  service.Labels,
		Env:     environment,
	}

	return containerSpec, nil
}

func parseServiceOptions(conf *composeTypes.Config) (ServiceSpec, error) {
	service := conf.Services[0]

	return ServiceSpec{
		Replicas: *service.Deploy.Replicas,
		Resources: swarm.ResourceRequirements{
			Reservations: &swarm.Resources{
				MemoryBytes: int64(service.Deploy.Resources.Reservations.MemoryBytes),
			},
			Limits: &swarm.Limit{
				MemoryBytes: int64(service.Deploy.Resources.Limits.MemoryBytes),
			},
		},
	}, nil
}
