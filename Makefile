.PHONY: all build test clean engine gateway run-engine run-gateway

all: build

build: engine gateway

engine:
	cd engine && zig build

gateway:
	cargo build --manifest-path gateway/Cargo.toml

test:
	cd engine && zig build test
	cargo test --manifest-path gateway/Cargo.toml

run-engine:
	cd engine && zig build run

run-gateway:
	cargo run --manifest-path gateway/Cargo.toml

clean:
	rm -rf engine/zig-out engine/.zig-cache
	cargo clean --manifest-path gateway/Cargo.toml
