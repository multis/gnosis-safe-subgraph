#!/bin/bash

GRAPH_NODE_THEGRAPH=https://api.thegraph.com/deploy/
GRAPH_NODE_LOCAL=http://localhost:8020/

IPFS_NODE_THEGRAPH=https://api.thegraph.com/ipfs/
IPFS_NODE_LOCAL=http://localhost:5001/

PROJECT_ID_MAINNET=gjeanmart/gnosis-safe-mainnet
PROJECT_ID_RINKEBY=gjeanmart/gnosis-safe-rinkeby
PROJECT_ID_ROPSTEN=gjeanmart/gnosis-safe-ropsten
PROJECT_ID_KOVAN=gjeanmart/gnosis-safe-kovan
PROJECT_ID_POLYGON=gjeanmart/gnosis-safe-polygon
PROJECT_ID_MUMBAI=gjeanmart/gnosis-safe-mumbai

LOCAL=0
NETWORK=mainnet
PROJECT_ID=$PROJECT_ID_MAINNET
ACCESS_TOKEN=$THEGRAPH_ACCESS_TOKEN

while (( "$#" )); do
  case "$1" in
    -l|--local)
      LOCAL=1
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

if [ $LOCAL -eq "1" ]; then
    GRAPH_NODE=$GRAPH_NODE_LOCAL
    IPFS_NODE=$IPFS_NODE_LOCAL
else
    GRAPH_NODE=$GRAPH_NODE_THEGRAPH
    IPFS_NODE=$IPFS_NODE_THEGRAPH
fi

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
if [ $NETWORK = "polygon" ]; then
    PROJECT_ID=$PROJECT_ID_POLYGON
fi
if [ $NETWORK = "mumbai" ]; then
    PROJECT_ID=$PROJECT_ID_MUMBAI
fi

graph deploy --debug --access-token $ACCESS_TOKEN --node $GRAPH_NODE --ipfs $IPFS_NODE $PROJECT_ID
