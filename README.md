
# Gnosis Safe subgraph

This Subgraph dynamically tracks activity on any Gnosis Safe multisignature wallets deployed through the factory (current support for versions 1.1.1 and 1.3.0)

### Subgraphs

#### Hosted service
- Mainnet https://thegraph.com/explorer/subgraph/gjeanmart/gnosis-safe-mainnet
- Ropsten https://thegraph.com/explorer/subgraph/gjeanmart/gnosis-safe-ropsten
- Kovan https://thegraph.com/explorer/subgraph/gjeanmart/gnosis-safe-kovan
- Goerli https://thegraph.com/explorer/subgraph/gjeanmart/gnosis-safe-goerli
- Polygon https://thegraph.com/explorer/subgraph/gjeanmart/gnosis-safe-polygon
- Mumbai (Polygon testnet) https://thegraph.com/explorer/subgraph/gjeanmart/gnosis-safe-mumbai

#### Decentralized network

- Mainnet https://thegraph.com/studio/subgraph/gnosis-safe-mainnet/

## Prerequiste

- libsecret-1-dev (ubuntu)
```
$ sudo apt-get install libsecret-1-dev
```

- yarn
```
$ sudo apt-get install yarn
```

- graph-cli

```
$ yarn global add @graphprotocol/graph-cli
```

## Getting started

0. Get the source and install the dependencies

```
$ git git@github.com:multis/gnosis-safe-subgraph.git
$ cd ./gnosis-safe-subgraph
$ npm install
```

1. Build

```
$ ./script/build.sh [--reset] [--code-gen] [--network mainnet|ropsten|kovan|goerli|mumbai|polygon]
```

- `--reset -r` deletes the build and generated code folders [optional, default: false]
- `--code-gen -c` (re)generate code from schema [optional, default: false]
- `--network -n` select a target network (mainnet, ropsten, kovan, goerli, mumbai, polygon) [optional, default: mainnet]


## Deployment

```
$ ./script/deploy.sh [--network mainnet|ropsten|kovan|goerli|mumbai|polygon] [--local] [--access-token xxxxxxxxxxxx] [--product studio]
```

- `--network -n` select a target network (mainnet, ropsten, kovan, goerli, mumbai, polygon) [optional, default: mainnet]
- `--access-token -t` access token to deploy the subgraph [optional, default: env variable $THEGRAPH_ACCESS_TOKEN]
- `--product -p` select a target TheGraph product (studio, hosted-service) [optional, default: studio]


## Model

- Wallet
    -  Transaction

## Query samples

### Get Wallet details 

```graphql
{
  wallet(id: "0x12312312.....") {
    id
    version
    creator
    network
    stamp
    hash
    factory
    mastercopy
    version
    owners
    threshold
    currentNonce
    transactions {
      id
      stamp
      hash
      status
      value
      destination
      data
      signatures
      nonce
      operation
      estimatedSafeTxGas
      estimatedBaseGas
      estimatedGasPrice
      gasToken
      refundReceiver
      gasUsed
      gasPrice
    }
  }
}

```

