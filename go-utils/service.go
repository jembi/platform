package utils

import (
	"context"
	"fmt"
	"time"

	"github.com/docker/cli/cli/command/stack/options"
	sw "github.com/docker/cli/cli/command/stack/swarm"
	"github.com/docker/cli/cli/compose/convert"
	composeTypes "github.com/docker/cli/cli/compose/types"
	"github.com/docker/cli/opts"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/filters"
	"github.com/docker/docker/api/types/swarm"
	"github.com/luno/jettison/errors"
)

type ServiceSpec struct {
	Name      string
	Replicas  uint64
	Resources swarm.ResourceRequirements
	Ports     []swarm.PortConfig
}

// Create a service as a replicated job
func CreateService(option options.Deploy) error {
	config, err := ConfigFromCompose(option.Namespace, option.Composefiles...)
	if err != nil {
		return err
	}

	client, err := NewApiClient()
	if err != nil {
		return err
	}

	services, err := convert.Services(convert.NewNamespace(option.Namespace), config, client)
	if err != nil {
		return errors.Wrap(err, "")
	}

	service := services[config.Services[0].Name]
	service.Mode = swarm.ServiceMode{
		ReplicatedJob: &swarm.ReplicatedJob{},
	}

	_, err = client.ServiceCreate(context.Background(), service, types.ServiceCreateOptions{
		QueryRegistry: false,
	})
	if err != nil {
		return errors.Wrap(err, "")
	}

	return nil
}

// Create a service by manually parsing config from configFromCompose(), this function
// won't attach the service to the instant namespace (and all related networks, as such)
func CreateServiceWithParse(option options.Deploy) error {
	config, err := ConfigFromCompose(option.Namespace, option.Composefiles...)
	if err != nil {
		return err
	}

	client, err := NewApiClient()
	if err != nil {
		return err
	}

	containerSpec := parseContainerOptions(config)
	serviceSpec := parseServiceOptions(config)

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

	_, err = client.ServiceCreate(context.Background(), spec, createOptions)
	if err != nil {
		return errors.Wrap(err, "")
	}

	return nil
}

func ParseServiceSpec(option options.Deploy) (swarm.ServiceSpec, error) {
	config, err := ConfigFromCompose(option.Namespace, option.Composefiles...)
	if err != nil {
		return swarm.ServiceSpec{}, err
	}

	serviceSpec := parseServiceOptions(config)
	containerSpec := parseContainerOptions(config)

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
			// Replicated:    &swarm.ReplicatedService{},
			ReplicatedJob: &swarm.ReplicatedJob{},
		},
		EndpointSpec: &swarm.EndpointSpec{
			Ports: serviceSpec.Ports,
		},
	}

	return spec, nil
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

func AwaitJobComplete(serviceName string, option options.Deploy) error {
	cli, err := NewCli()
	if err != nil {
		return err
	}
	client, err := NewApiClient()
	if err != nil {
		return err
	}

	fils := opts.NewFilterOpt()
	fils.Value().Add("name", serviceName)

	startTime := time.Now()
	for time.Since(startTime) < 1*time.Minute {
		services, err := sw.GetServices(cli, options.Services{
			Filter: fils,
		})
		if err != nil {
			return errors.Wrap(err, "")
		} else if len(services) == 0 {
			return errors.Wrap(errors.New("No such job: "+serviceName), "")
		}
		service := services[0]

		tasks, err := client.TaskList(context.Background(), types.TaskListOptions{
			Filters: filters.NewArgs(filters.KeyValuePair{
				Key:   "service",
				Value: service.ID,
			})},
		)
		if err != nil {
			return err
		}
		if len(tasks) == 0 {
			continue
		}

		latestTask, err := LatestTask(tasks)
		if err != nil {
			return err
		}

		if latestTask.DesiredState == "shutdown" && latestTask.Status.ContainerStatus.ExitCode == 0 {
			return nil
		} else if latestTask.DesiredState == "shutdown" && latestTask.Status.ContainerStatus.ExitCode != 0 {
			exitCodeString := fmt.Sprint(latestTask.Status.ContainerStatus.ExitCode)
			return errors.Wrap(errors.New("service "+serviceName+" failed with exit code "+exitCodeString), "")
		}
	}

	return errors.Wrap(errors.New("waited 60 seconds for "+serviceName+" to complete, aborting..."), "")
}
