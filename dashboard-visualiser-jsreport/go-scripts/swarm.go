package main

import (
	"fmt"
	"log"

	"JSR/go-utils"
)

func main() {
	// myVar := os.Args[1:]

	// args := utils.SortArgs(myVar)

	// fmt.Println(args["action"], args["mode"])

	output, err := utils.Bash("pwd")
	if err != nil {
		log.Println(err)
	}
	fmt.Println(output)
}
