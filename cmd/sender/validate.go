package main

import (
	"fmt"
	"net/url"

	"github.com/ethereum/go-ethereum/common"
)

func (f Flags) Validate() error {
	if !common.IsHexAddress(f.ToAddress) {
		return fmt.Errorf("invalid address format: %s", f.ToAddress)
	}

	if f.AmountWei <= 0 {
		return fmt.Errorf("invalid amount: %d wei", f.AmountWei)
	}

	if _, err := url.Parse(f.RpcApi); err != nil {
		return fmt.Errorf("invalid RPC node URL: %s", f.RpcApi)
	}

	return nil
}
