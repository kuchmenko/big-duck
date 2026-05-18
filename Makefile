.PHONY: all build test clean engine gateway run-engine run-gateway

all: build

build: engine gateway

engine:
	$(MAKE) -C engine

gateway:
	cargo build --manifest-path gateway/Cargo.toml

test:
	$(MAKE) -C engine test
	cargo test --manifest-path gateway/Cargo.toml

run-engine: engine
	./engine/build/engine

run-gateway: gateway
	cargo run --manifest-path gateway/Cargo.toml

clean:
	$(MAKE) -C engine clean
	cargo clean --manifest-path gateway/Cargo.toml
