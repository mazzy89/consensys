package eth

import (
	"crypto/ecdsa"
	"fmt"

	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rpc"
)

type Ethereum struct {
	PrivateKey *ecdsa.PrivateKey
	RPCNode    string

	client *ethclient.Client
}

func NewClient(RPCApi, privateKey string) (*Ethereum, error) {
	pkey, err := crypto.HexToECDSA(privateKey)
	if err != nil {
		return nil, err
	}

	eth := &Ethereum{
		PrivateKey: pkey,
	}

	rpcClient, err := rpc.Dial(RPCApi)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to ethereum node: %w", err)
	}

	eth.client = ethclient.NewClient(rpcClient)

	return eth, nil
}
