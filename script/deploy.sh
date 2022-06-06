#!/bin/bash

PROJECT_ID_MAINNET=gnosis-safe-mainnet
PROJECT_ID_RINKEBY=gnosis-safe-rinkeby
PROJECT_ID_ROPSTEN=gnosis-safe-ropsten
PROJECT_ID_KOVAN=gnosis-safe-kovan
PROJECT_ID_GOERLI=gnosis-safe-goerli
PROJECT_ID_POLYGON=gnosis-safe-polygon
PROJECT_ID_MUMBAI=gnosis-safe-mumbai

NETWORK=mainnet
PROJECT_ID=$PROJECT_ID_MAINNET
ACCESS_TOKEN=$THEGRAPH_ACCESS_TOKEN
PRODUCT=studio

while (( "$#" )); do
  case "$1" in
    -n|--network)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        NETWORK=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -p|--product)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PRODUCT=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -a|--access-token)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ACCESS_TOKEN=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

eval set -- "$PARAMS"

if [ $NETWORK = "mainnet" ]; then
    PROJECT_ID=$PROJECT_ID_MAINNET
fi
if [ $NETWORK = "rinkeby" ]; then
    PROJECT_ID=$PROJECT_ID_RINKEBY
fi
if [ $NETWORK = "ropsten" ]; then
    PROJECT_ID=$PROJECT_ID_ROPSTEN
fi
if [ $NETWORK = "kovan" ]; then
    PROJECT_ID=$PROJECT_ID_KOVAN
fi
if [ $NETWORK = "goerli" ]; then
    PROJECT_ID=$PROJECT_ID_GOERLI
fi
if [ $NETWORK = "polygon" ]; then
    PROJECT_ID=$PROJECT_ID_POLYGON
fi
if [ $NETWORK = "mumbai" ]; then
    PROJECT_ID=$PROJECT_ID_MUMBAI
fi
if [ $PRODUCT = "hosted-service" ]; then
    PROJECT_ID=gjeanmart/$PROJECT_ID
    PRODUCT_TARGET="--product $PRODUCT"
fi
if [ $PRODUCT = "studio" ]; then
    PRODUCT_TARGET=--studio
fi

npx graph auth $PRODUCT_TARGET $ACCESS_TOKEN
npx graph deploy --debug $PRODUCT_TARGET $PROJECT_ID
