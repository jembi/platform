package main

import (
	"JSR/go-utils"
	"context"
	"fmt"
	"log"

	"github.com/docker/cli/cli/command"

	"github.com/docker/cli/cli/command/stack/loader"
	"github.com/docker/cli/cli/command/stack/options"

	// "github.com/docker/cli/cli/command/stack/swarm"
	// deploy "github.com/docker/cli/cli/command/stack/swarm"
	composeTypes "github.com/docker/cli/cli/compose/types"
	cliflags "github.com/docker/cli/cli/flags"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/swarm"
	"github.com/docker/docker/client"
	// composetypes "github.com/docker/cli/cli/compose/types"
	// client "github.com/moby/moby/client"
)

var (
	EnvVars     = make(map[string]string)
	mode        *string
	action      *string
	packagePath *string
)

type ServiceSpec struct {
	Replicas  uint64
	Resources swarm.ResourceRequirements
}

func init() {
	// EnvVars["JS_REPORT_INSTANCES"] = os.Getenv("JS_REPORT_INSTANCES")

	// mode = flag.String("mode", "", "dev | prod")
	// action = flag.String("action", "", "init | up | down | destroy")
	// packagePath = flag.String("path", "", "path to package")

	// flag.Parse()
	// err := utils.ValidateArgs(*mode, *action, *packagePath)
	// if err != nil {
	// 	log.Fatal(err)
	// }
}

func main() {
	v1 := "init"
	v2 := "prod"
	v3 := "/home/markl/Documents/Projects/platform/dashboard-visualiser-jsreport"
	action = &v1
	mode = &v2
	packagePath = &v3

	// stack.RunDeploy()

	composeFiles := []string{"docker-compose.yml"}
	if *mode == "dev" {
		composeFiles = append(composeFiles, "docker-compose.dev.yml")
	}

	var err error
	switch *action {
	case "init":
		err = packageInit(*packagePath, composeFiles...)
		if err != nil {
			log.Println(err)
		}

	case "destroy":
		err = packageDestroy()
		if err != nil {
			log.Println(err)
		}
	}
}

func packageInit(dir string, composeFiles ...string) error {
	options := options.Deploy{
		Composefiles: composeFiles,
		Namespace:    "instant",
	}

	cli, err := command.NewDockerCli()
	if err != nil {
		log.Println(err)
		return err
	}

	err = cli.Initialize(cliflags.NewClientOptions())
	if err != nil {
		log.Println(err)
		return err
	}

	config, err := loader.LoadComposefile(cli, options)
	if err != nil {
		log.Println(err)
		return err
	}

	// err = deploy.RunDeploy(cli, options, config)
	// if err != nil {
	// 	return err
	// }

	containerSpec, err := parseContainerOptions(config)
	if err != nil {
		return err
	}

	serviceSpec, err := parseServiceOptions(config)
	if err != nil {
		return err
	}

	// swarm.RunDeploy

	spec := swarm.ServiceSpec{
		Annotations: swarm.Annotations{
			Name: "dashboard-visualiser-jsreport",
		},
		TaskTemplate: swarm.TaskSpec{
			ContainerSpec: containerSpec,
			// Resources: serviceSpec.Resources,
		},
		Mode: swarm.ServiceMode{
			Replicated: &swarm.ReplicatedService{
				Replicas: &serviceSpec.Replicas,
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

	fmt.Println(config)

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

	// service.Deploy.Resources
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

func packageDestroy() error {
	output, err := utils.Bash("docker service rm instant_dashboard-visualiser-jsreport instant_jsreport-config-importer instant_await-helper")
	if err != nil {
		return err
	}
	fmt.Println(output)

	return nil
}

// vp := viper.New()
// vp.SetConfigType("yaml")
// vp.AutomaticEnv()

// yfile, err := ioutil.ReadFile("docker-compose.yml")
// if err != nil {
// 	return err
// }
// err = vp.ReadConfig(bytes.NewBuffer(yfile))
// if err != nil {
// 	return err
// }

// myConf := goconfig.NewConfig("./docker-compose.yml", goconfig.Yaml)
// fmt.Println(myConf)
// myConf.GetString("root.family1.key1")

// yMap, err := loader.ParseYAML(yfile)
// if err != nil {
// 	log.Println(err)
// 	return err
// }

// configFiles := []compose.ConfigFile{
// 	compose.ConfigFile{
// 		Filename: "docker-compose.yml",
// 		Config:   yMap,
// 	},
// }

// myConfig := compose.ConfigDetails{
// 	Version:     "3.3",
// 	ConfigFiles: configFiles,
// }

// proj, err := loader.Load(myConfig, func(o *loader.Options) {})
// if err != nil {
// 	log.Println(err)
// 	return err
// }

// fmt.Println(proj)

// myConfig := compose.ServiceConfig{
// 	Name: "docker-compose.yml",
// }

// inter, err := myConfig.Services.MarshalYAML()
// if err != nil {
// 	return err
// }

// myMap := make(map[string]string)
// myMap["co.elastic.metrics/module"] = "docker"
// myMap["co.elastic.metrics/metricsets"] = "cpu,memory,diskio,info,healthcheck,container"

// myspec := swarm.ServiceSpec{
// 	Annotations: swarm.Annotations{
// 		Name:   "dashboard-visualiser-jsreport",
// 		Labels: myMap,
// 	},
// 	TaskTemplate: swarm.TaskSpec{},
// 	Mode:         swarm.ServiceMode{},
// }

// myoptions := apiTypes.ServiceCreateOptions{
// 	QueryRegistry: false,
// }

// var myserv client.ServiceAPIClient
// resp, err := myserv.ServiceCreate(context.Background(), myspec, myoptions)
// if err != nil {
// 	return err
// }

// fmt.Println(resp.Warnings)
