package utils

import (
	"bufio"
	"bytes"
	"os/exec"
	"strings"
)

func Bash(command string, pathChange ...string) (string, error) {
	strSlice := strings.Split(command, " ")
	cmd := &exec.Cmd{
		Path: "/bin/bash/" + strSlice[0],
		Args: strSlice,
	}

	cmdReader, err := cmd.StdoutPipe()
	if err != nil {
		return "", err
	}
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	var stdout string

	scanner := bufio.NewScanner(cmdReader)
	go func() {
		for scanner.Scan() {
			stdout += scanner.Text()
		}
	}()

	err = cmd.Start()
	if err != nil {
		return "", err
	}

	err = cmd.Wait()
	if err != nil {
		return "", err
	}

	return stdout, nil
}

func ValidateArgs(args []string) {

}

func SortArgs(args []string) map[string]string {
	argMap := make(map[string]string)
	for _, arg := range args {
		switch arg {
		case "init", "up", "down", "destroy":
			argMap["action"] = arg

		case "dev":
			argMap["mode"] = arg

		case "cluster", "single":
			argMap["stateful-nodes"] = arg

		}
	}

	return argMap
}
