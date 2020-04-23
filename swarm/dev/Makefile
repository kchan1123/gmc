.PHONY: build cluster test

default: build

build:
	go build -o bin/swarm    github.com/ethereum/gmcc/cmd/swarm
	go build -o bin/geth     github.com/ethereum/gmcc/cmd/geth
	go build -o bin/bootnode github.com/ethereum/gmcc/cmd/bootnode

cluster: build
	scripts/boot-cluster.sh

test:
	go test -v github.com/ethereum/gmcc/swarm/...
