package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/alecthomas/kong"
	"github.com/ethereum/go-ethereum/common"

	"github.com/mazzy89/consensys/internal/eth"
)

type Flags struct {
	RpcApi     string        `required:"" help:"RPC API address to connect to the Ethereum network"`
	PrivateKey string        `env:"PRIVATE_KEY" required:"" help:"private-key represents the sender's private key for transaction signing"`
	ToAddress  string        `help:"ToAddress is the recipient's Ethereum address"`
	Interval   time.Duration `help:"Interval defines the time between consecutive sends" default:"1s"`
	AmountWei  int64         `help:"AmountWei specifies the amount to send in wei" default:"10"`
}

func main() {
	if err := run(); err != nil {
		os.Exit(1)
	}
}

func run() error {
	opts, err := parseFlags()
	if err != nil {
		return err
	}

	client, err := eth.NewClient(opts.RpcApi, opts.PrivateKey)
	if err != nil {
		return fmt.Errorf("failed to create client: %w", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	go func() {
		<-sigChan
		slog.Info("Received shutdown signal, stopping...")
		cancel()
	}()

	ticker := time.NewTicker(opts.Interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			tx, err := client.SendTransaction(ctx, common.HexToAddress(opts.ToAddress), opts.AmountWei)
			if err != nil {
				slog.Error("Failed to send transaction", "error", err)
				continue
			}

			slog.Info("Transaction sent successfully", "hash", tx.Hash().Hex())
		}
	}
}

func parseFlags() (Flags, error) {
	var opts Flags

	ctx := kong.Parse(&opts,
		kong.Name("sender"),
		kong.Description("Sender signs and broadcasts fixed-amount Wei token."),
		kong.UsageOnError(),
		kong.ConfigureHelp(kong.HelpOptions{
			Compact: true,
		}))

	return opts, ctx.Error
}
