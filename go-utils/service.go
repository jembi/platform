package utils

import (
	"context"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/filters"
	"github.com/docker/docker/api/types/swarm"
	"github.com/docker/docker/client"

	"github.com/docker/cli/cli/command/stack/options"
	composeTypes "github.com/docker/cli/cli/compose/types"
	"github.com/luno/jettison/errors"
	// composeTypes "github.com/docker/cli/cli/compose/types"
	// dockerclient "github.com/docker/docker/client"
)

type ServiceSpec struct {
	Name      string
	Replicas  uint64
	Resources swarm.ResourceRequirements
	Ports     []swarm.PortConfig
}

func CreateService(option options.Deploy) error {
	// dockerCli, config, err := NewCliFromCompose(option, option.Composefiles...)
	// if err != nil {
	// 	return errors.Wrap(err, "")
	// }

	// services, err := convert.Services(convert.NewNamespace(option.Namespace), config, dockerCli.Client())
	// if err != nil {
	// 	return errors.Wrap(err, "")
	// }

	config, err := ConfigFromCompose(option.Namespace)
	if err != nil {
		return err
	}

	containerSpec:= parseContainerOptions(config)
	serviceSpec:= parseServiceOptions(config)

	spec := swarm.ServiceSpec{
		Annotations: swarm.Annotations{
			Name: serviceSpec.Name,
		},
		TaskTemplate: swarm.TaskSpec{
			ContainerSpec: containerSpec,
			Resources: &swarm.ResourceRequirements{
				Limits:       serviceSpec.Resources.Limits,
				Reservations: serviceSpec.Resources.Reservations,
			},
			RestartPolicy: &swarm.RestartPolicy{
				Condition: swarm.RestartPolicyConditionNone,
			},
			Runtime: swarm.RuntimeContainer,
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
		EndpointSpec: &swarm.EndpointSpec{
			Ports: serviceSpec.Ports,
		},
	}

	createOptions := types.ServiceCreateOptions{
		QueryRegistry: false,
	}

	sClient, err := client.NewClientWithOpts()
	if err != nil {
		return errors.Wrap(err, "")
	}

	_, err = sClient.ServiceCreate(context.Background(), spec, createOptions)
	if err != nil {
		return errors.Wrap(err, "")
	}

	// _, err = sClient.ServiceCreate(context.Background(), services["await-helper"], createOptions)
	// if err != nil {
	// 	return errors.Wrap(err, "")
	// }

	// fmt.Println(spec)

	return nil
}

func RemoveService(serviceName string) error {
	client, err := NewApiClient()
	if err != nil {
		return err
	}

	filtersPair := filters.KeyValuePair{
		Key:   "name",
		Value: serviceName,
	}

	serv, err := client.ServiceList(context.Background(), types.ServiceListOptions{
		Filters: filters.NewArgs(filtersPair),
	})
	if err != nil {
		return errors.Wrap(err, "")
	}

	err = client.ServiceRemove(context.Background(), serv[0].ID)
	if err != nil {
		return errors.Wrap(err, "")
	}
	return nil
}

func parseContainerOptions(conf *composeTypes.Config) *swarm.ContainerSpec {
	service := conf.Services[0]

	var environment []string
	for k, v := range service.Environment {
		environment = append(environment, k+"="+*v)
	}

	containerSpec := &swarm.ContainerSpec{
		Image:  service.Image,
		Args:   service.Command,
		Labels: service.Labels,
		Env:    environment,
	}

	return containerSpec
}

func parseServiceOptions(conf *composeTypes.Config) ServiceSpec {
	service := conf.Services[0]

	var replicas uint64 = 1
	if service.Deploy.Replicas != nil {
		replicas = *service.Deploy.Replicas
	}

	limits := &swarm.Limit{}
	if service.Deploy.Resources.Limits != nil {
		limits.MemoryBytes = int64(service.Deploy.Resources.Limits.MemoryBytes)
	}

	reservations := &swarm.Resources{}
	if service.Deploy.Resources.Reservations != nil {
		reservations.MemoryBytes = int64(service.Deploy.Resources.Reservations.MemoryBytes)
	}

	return ServiceSpec{
		Name:     service.Name,
		Replicas: replicas,
		Resources: swarm.ResourceRequirements{
			Reservations: reservations,
			Limits:       limits,
		},
		Ports: parsePorts(service),
	}
}

func parsePorts(service composeTypes.ServiceConfig) []swarm.PortConfig {
	var servicePorts []swarm.PortConfig
	for _, port := range service.Ports {
		servicePorts = append(servicePorts, swarm.PortConfig{
			TargetPort:    port.Target,
			PublishedPort: port.Published,
			PublishMode:   swarm.PortConfigPublishMode(port.Mode),
		})
	}

	return servicePorts
}
