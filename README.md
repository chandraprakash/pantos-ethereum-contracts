<img src="https://raw.githubusercontent.com/pantos-io/ethereum-contracts/img/pantos-logo-full.svg" alt="Pantos logo" align="right" width="120" />

[![CI](https://github.com/pantos-io/ethereum-contracts/actions/workflows/ci.yaml/badge.svg)](https://github.com/pantos-io/ethereum-contracts/actions/workflows/ci.yaml) 

# Pantos on-chain components for Ethereum and compatible blockchains

This repository contains the Pantos smart contracts for Ethereum-compatible
blockchains.

## Install Foundry 
```shell
$ curl -L https://foundry.paradigm.xyz | bash
$ foundryup
```

## Usage

### Install dependencies

```shell
$ forge install
$ npm install
```

### Build

```shell
$ forge build
```

### Format

```shell
$ make format
```

### Lint

```shell
$ make lint
```

### Test

```shell
$ make test
```

### Coverage

```shell
$ make coverage
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Docker

You can run local blockchain nodes using `make docker`. This will start two nodes in ports `8545` and `8546` (called eth and bnb respectively) with the contracts deployed on the same addresses.

This will also create two docker volumes, `eth-data` and `bnb-data`, containing the list of deployed addresses (both in json and .env formats) alongside with the keystore and accounts used. You can access these by using either a docker GUI or by mounting it into a container like this `docker run --rm -v bnb-data:/volume alpine ls /volume`

If using this project alongside the service or validator node projects one can run the full stack by first starting the blockchain nodes with `make docker` and, after these are running, doing the same in the other projects. They will automatically pick up the data exposed by this project.

### Deploy & Operations

Please see ```scripts/README.md```

## Contributions

Check our [code of conduct](CODE_OF_CONDUCT.md)