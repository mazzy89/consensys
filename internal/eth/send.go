package eth

import (
	"context"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/params"
)

func (e Ethereum) SendTransaction(ctx context.Context, toAddress common.Address, amountWei int64) (*types.Transaction, error) {
	chainID, err := e.client.ChainID(ctx)
	if err != nil {
		return nil, err
	}

	fromAddress := crypto.PubkeyToAddress(e.PrivateKey.PublicKey)
	nonce, err := e.client.NonceAt(context.Background(), fromAddress, nil)
	if err != nil {
		return nil, err
	}

	signer := types.LatestSignerForChainID(chainID)
	tx, err := types.SignNewTx(e.PrivateKey, signer, &types.LegacyTx{
		Nonce:    nonce,
		Value:    big.NewInt(amountWei),
		GasPrice: big.NewInt(params.InitialBaseFee),
		Gas:      22000,
		To:       &toAddress,
	})

	return tx, e.client.SendTransaction(ctx, tx)
}
