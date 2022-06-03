package utils

import (
	"bufio"
	"fmt"
	"os/exec"
	"strings"
	"time"

	"github.com/pkg/errors"
)

func Bash(command string, pathChange ...string) (string, error) {
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

func timeoutCheck(startTime time.Time, warningTime, exitTime time.Duration, serviceName string) error {
	timeDiff := time.Since(startTime)
	if timeDiff >= warningTime && timeDiff <= warningTime+1*time.Second {
		fmt.Println("[WARN]:", serviceName, "is taking a while to start")
	} else if timeDiff >= exitTime {
		return errors.New(fmt.Sprintln("[FATAL]:", serviceName, "is taking too long to start. Exiting..."))
	}

	return nil
}
