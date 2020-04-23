# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gmcc android ios gmcc-cross swarm evm all test clean
.PHONY: gmcc-linux gmcc-linux-386 gmcc-linux-amd64 gmcc-linux-mips64 gmcc-linux-mips64le
.PHONY: gmcc-linux-arm gmcc-linux-arm-5 gmcc-linux-arm-6 gmcc-linux-arm-7 gmcc-linux-arm64
.PHONY: gmcc-darwin gmcc-darwin-386 gmcc-darwin-amd64
.PHONY: gmcc-windows gmcc-windows-386 gmcc-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gmcc:
	build/env.sh go run build/ci.go install ./cmd/gmcc
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gmcc\" to launch gmcc."

swarm:
	build/env.sh go run build/ci.go install ./cmd/swarm
	@echo "Done building."
	@echo "Run \"$(GOBIN)/swarm\" to launch swarm."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gmcc.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Geth.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

clean:
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/jteeuwen/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go install ./cmd/abigen

# Cross Compilation Targets (xgo)

gmcc-cross: gmcc-linux gmcc-darwin gmcc-windows gmcc-android gmcc-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-*

gmcc-linux: gmcc-linux-386 gmcc-linux-amd64 gmcc-linux-arm gmcc-linux-mips64 gmcc-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-*

gmcc-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gmcc
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep 386

gmcc-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gmcc
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep amd64

gmcc-linux-arm: gmcc-linux-arm-5 gmcc-linux-arm-6 gmcc-linux-arm-7 gmcc-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep arm

gmcc-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gmcc
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep arm-5

gmcc-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gmcc
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep arm-6

gmcc-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gmcc
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep arm-7

gmcc-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gmcc
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep arm64

gmcc-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gmcc
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep mips

gmcc-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gmcc
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep mipsle

gmcc-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gmcc
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep mips64

gmcc-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gmcc
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-linux-* | grep mips64le

gmcc-darwin: gmcc-darwin-386 gmcc-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-darwin-*

gmcc-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gmcc
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-darwin-* | grep 386

gmcc-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gmcc
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-darwin-* | grep amd64

gmcc-windows: gmcc-windows-386 gmcc-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-windows-*

gmcc-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gmcc
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-windows-* | grep 386

gmcc-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gmcc
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gmcc-windows-* | grep amd64
