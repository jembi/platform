package main

import (
	"errors"
	"fmt"
	"os"
)

func CLI() error {
	startupCommands := os.Args[1:]

	switch startupCommands[0] {
	case "docker":
		if len(startupCommands) < 3 {
			return errors.New("Incorrect arguments list passed to CLI. Requires at least 3 arguments when in non-interactive mode.")
		}

		err := RunDirectDockerCommand(startupCommands)
		if err != nil {
			return err
		}
	case "help":
		fmt.Println(`
Commands: 
	help 		this menu
	docker		manage package in docker
				usage: docker <package> <state>

				docker core init
				docker core up
				docker core destroy

				note: only one package can be instantiated at a time using the CLI

	`)

	default:
		fmt.Println("The deploy command is not recognized: ", startupCommands)
	}

	return nil
}
