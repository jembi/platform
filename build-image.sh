#!/bin/bash

packages=(
    # "dashboard-visualiser-jsreport"
    "analytics-datastore-elastic-search"
)

build_go_binary() {
    for ((i = 0; i < ${#packages[@]}; i++)); do
        cd ${packages[$i]} || exit
        GOOS=linux GOARCH=amd64 go build -o swarm
        cd ..
    done
}

remove_go_binary() {
    for ((i = 0; i < ${#packages[@]}; i++)); do
        local package=${packages[$i]}
        cd "$package" || exit
        rm -f "swarm"
        cd ..
    done
}

build_go_binary "$packages"

TAG_NAME=${1:-latest}
docker build -t jembi/platform:"$TAG_NAME" .

remove_go_binary "$packages"
