#!/bin/bash

RESET=0
CODE_GEN=0
NETWORK=mainnet

while (( "$#" )); do
  case "$1" in
    -r|--reset)
      RESET=1
      shift
      ;;
    -c|--code-gen)
      CODE_GEN=1
      shift
      ;;
    -n|--network)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        NETWORK=$2
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

if [ $RESET -eq "1" ]; then
    rm -rf build/ generated/ subgraph.yaml
    CODE_GEN="1"
fi

# Prepare subgraph (--network)
yarn prepare:$NETWORK

# Generate code
if [ $CODE_GEN -eq "1" ]; then
    npx graph codegen
fi

# Build
npx graph build


echo "success!"
