#!/bin/sh

rm -f ./testchain/geth/chaindata/*

geth --datadir ./testchain init genesis.json

geth --datadir ./testchain --unlock 0 --password ./testpassword --rpc --rpccorsdomain '*' --rpcport 8646 --port 32323 --mine --minerthreads 1 --maxpeers 0 console

