package utils

import (
	"bufio"
	"fmt"
	"log"
	"os/exec"
	"strings"
	"time"

	"github.com/pkg/errors"
)

func Bash(command string, pathChange ...string) (string, error) {
	return checkSubCommand(command)
}

func BashExecute(command string, pathChange ...string) (string, error) {
	strSlice := strings.Split(command, " ")
	cmd := exec.Command(strSlice[0], strSlice[1:]...)

	stdOutReader, err := cmd.StdoutPipe()
	if err != nil {
		return "", err
	}

	var stdout string
	stdOutScanner := bufio.NewScanner(stdOutReader)
	go func() {
		for stdOutScanner.Scan() {
			stdout += stdOutScanner.Text()
		}
	}()

	stdErrReader, err := cmd.StderrPipe()
	if err != nil {
		return "", err
	}

	var stderr string
	stdErrScanner := bufio.NewScanner(stdErrReader)
	go func() {
		for stdErrScanner.Scan() {
			stderr += stdErrScanner.Text()
		}
	}()

	err = cmd.Run()
	if err != nil {
		return "", errors.Wrap(err, stderr)
	}

	return stdout, nil
}

func checkSubCommand(command string) (string, error) {
	splitStrings := strings.SplitAfter(command, "$")
	var output string
	var err error
	if len(splitStrings) > 1 {
		str := splitStrings[1]
		output, err = BashExecute(str[1 : len(str)-1])
		if err != nil {
			fmt.Println(err)
			return "", err
		}
	} else {
		return BashExecute(command)
	}

	str := splitStrings[0]
	// exec := str[:len(str)-1] + output
	// output, err = BashExecute(str[:len(str)-1] + output)
	// output, err = Bash()

	// strings.spl

	return BashExecute(str[:len(str)-1] + output)
}

func ValidateArgs(args ...string) error {
	// TODO(MarkL): Validate variable content
	for _, arg := range args {
		if arg == "" {
			return errors.New("[FATAL] empty command line argument")
		}
	}

	return nil
}

func StackDeploy(dir string, composeFiles ...string) error {
	var fileString string
	for _, file := range composeFiles {
		fileString += " -c " + dir + "/compose/" + file
	}

	output, err := Bash("docker stack deploy" + fileString + " instant")
	if err != nil {
		return err
	}

	fmt.Println(output)
	return err
}

func AwaitServiceRunning(serviceName, instances string, warningTime, exitTime time.Duration) error {
	startTime := time.Now()
	if warningTime == 0 {
		warningTime = 1 * time.Minute
	}
	if exitTime == 0 {
		exitTime = 5 * time.Minute
	}

	output, err := Bash("docker service ls -f name=instant_dashboard-visualiser-jsreport --format \"{{.Replicas}}\"")
	if err != nil {
		return err
	}
	for !strings.Contains(output, fmt.Sprintf("%s/%s", instances, instances)) {
		output, err = Bash("docker service ls -f name=instant_dashboard-visualiser-jsreport --format \"{{.Replicas}}\"")
		if err != nil {
			return err
		}

		err = timeoutCheck(startTime, warningTime, exitTime, serviceName)
		if err != nil {
			return err
		}

		time.Sleep(1 * time.Second)
	}

	output, err = Bash("docker service ps instant_await-helper --format \"{{.CurrentState}}\"")
	if err != nil && !strings.Contains(err.Error(), "no such service: instant_await-helper") {
		return err
	}
	for !strings.Contains(output, "Complete") {
		output, err = Bash("docker service ps instant_await-helper --format \"{{.CurrentState}}\"")
		if err != nil && !strings.Contains(err.Error(), "no such service: instant_await-helper") {
			return err
		}

		err = timeoutCheck(startTime, warningTime, exitTime, serviceName)
		if err != nil {
			return err
		}

		if strings.Contains(output, "Failed") || strings.Contains(output, "Rejected") {
			return errors.New(fmt.Sprintln("[FATAL]:", serviceName, "is not reachable... exiting"))
		}

		time.Sleep(1 * time.Second)
	}
	_, err = Bash("docker service rm instant_await-helper")
	if err != nil && !strings.Contains(err.Error(), "no such service: instant_await-helper") {
		return err
	}

	return nil
}

func AwaitContainerStartup(serviceName string, warningTime, exitTime time.Duration) error {
	startTime := time.Now()
	if warningTime == 0 {
		warningTime = 1 * time.Minute
	}
	if exitTime == 0 {
		exitTime = 5 * time.Minute
	}

	output, err := Bash("docker ps -qlf name=instant_analytics-datastore-elastic-search")
	if err != nil {
		return err
	}
	for output == "" {
		output, err = Bash("docker ps -qlf name=instant_analytics-datastore-elastic-search")
		if err != nil {
			return err
		}

		err = timeoutCheck(startTime, warningTime, exitTime, serviceName)
		if err != nil {
			return err
		}

		time.Sleep(1 * time.Second)
	}
	fmt.Println("Container started")

	return nil
}

func AwaitContainerReady(serviceName string, warningTime, exitTime time.Duration) error {
	startTime := time.Now()
	if warningTime == 0 {
		warningTime = 1 * time.Minute
	}
	if exitTime == 0 {
		exitTime = 5 * time.Minute
	}

	output, err := Bash("docker inspect -f '{{.State.Status}}' $(docker ps -qlf name=instant_analytics-datastore-elastic-search)")
	if err != nil {
		log.Println(err)
		fmt.Println("oops")
		return err
	}
	for !strings.Contains(output, "running") {
		output, err = Bash("docker inspect -f '{{.State.Status}}' $(docker ps -qlf name=instant_analytics-datastore-elastic-search)")
		if err != nil {
			return err
		}

		err = timeoutCheck(startTime, warningTime, exitTime, serviceName)
		if err != nil {
			return err
		}

		time.Sleep(1 * time.Second)
	}
	fmt.Println("Container ready")

	return nil
}

func InstallExpect() error {
	fmt.Println("Installing expect...")
	_, err := Bash("apt-get install -y expect")
	if err != nil {
		return err
	}

	return nil
}

func SetElasticsearchPasswords(dir string) error {
	fmt.Println("Setting passwords...")
	elasticSearchContainerId, err := Bash("docker ps -qlf name=instant_analytics-datastore-elastic-search")
	if err != nil {
		return err
	}
	_, err = Bash(dir + "/set-elastic-passwords.exp " + elasticSearchContainerId)
	if err != nil {
		return err
	}

	return nil
}

func timeoutCheck(startTime time.Time, warningTime, exitTime time.Duration, serviceName string) error {
	timeDiff := time.Since(startTime)
	if timeDiff >= warningTime && timeDiff <= warningTime+1*time.Second {
		fmt.Println("[WARN]:", serviceName, "is taking a while to start")
	} else if timeDiff >= exitTime {
		return errors.New(fmt.Sprintln("[FATAL]:", serviceName, "is taking too long to start. Exiting..."))
	}

	return nil
}

// #!/bin/bash

// # COMPOSE_FILE_PATH=$(
// #   cd "$(dirname "${BASH_SOURCE[0]}")" || exit
// #   pwd -P
// # )

// # S_NODES="${STATEFUL_NODES:-"cluster"}"

// COMPOSE_FILE_PATH="/home/markl/Documents/Projects/platform/analytics-datastore-elastic-search"

// GOOS=linux GOARCH=amd64 go build -o swarm
// # echo "1 = $1"
// # echo "2 = $2"
// # echo "COMPOSE_FILE_PATH = $COMPOSE_FILE_PATH"
// # echo "S_NODES = $S_NODES"

// # "$COMPOSE_FILE_PATH"/swarm -action="$1" -mode="$2" -path="$COMPOSE_FILE_PATH" -statefulNodes="$S_NODES"
// "$COMPOSE_FILE_PATH"/swarm -action="init" -mode="dev" -path="$COMPOSE_FILE_PATH" -statefulNodes="single"
