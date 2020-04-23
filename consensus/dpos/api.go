// Copyright 2017 The go-ethereum Authors
// This file is part of the go-ethereum library.
//
// The go-ethereum library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-ethereum library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-ethereum library. If not, see <http://www.gnu.org/licenses/>.

package dpos

import (
	"github.com/gmc/gmcc/common"
	"github.com/gmc/gmcc/consensus"
	"github.com/gmc/gmcc/core/types"
	"github.com/gmc/gmcc/core/state"
	"github.com/gmc/gmcc/rpc"

	"math/big"
)

// API is a user facing RPC API to allow controlling the delegate and voting
// mechanisms of the delegated-proof-of-stake
type API struct {
	chain consensus.ChainReader
	dpos  *Dpos
}

// GetValidators retrieves the list of the validators at specified block
func (api *API) GetValidators(number *rpc.BlockNumber) ([]common.Address, error) {
	var header *types.Header
	if number == nil || *number == rpc.LatestBlockNumber {
		header = api.chain.CurrentHeader()
	} else {
		header = api.chain.GetHeaderByNumber(uint64(number.Int64()))
	}
	if header == nil {
		return nil, errUnknownBlock
	}

	epochTrie, err := types.NewEpochTrie(header.DposContext.EpochHash, api.dpos.db)
	if err != nil {
		return nil, err
	}
	dposContext := types.DposContext{}
	dposContext.SetEpoch(epochTrie)
	validators, err := dposContext.GetValidators()
	if err != nil {
		return nil, err
	}
	return validators, nil
}

// GetConfirmedBlockNumber retrieves the latest irreversible block
func (api *API) GetConfirmedBlockNumber() (*big.Int, error) {
	var err error
	header := api.dpos.confirmedBlockHeader
	if header == nil {
		header, err = api.dpos.loadConfirmedBlockHeader(api.chain)
		if err != nil {
			return nil, err
		}
	}
	return header.Number, nil
}


func (api *API) GetVotes() (map[common.Address]string, error){
	var header *types.Header
	header = api.chain.CurrentHeader()
	if header == nil {
		return nil, errUnknownBlock
	}

	dposContext, _ := types.NewDposContextFromProto(api.dpos.db, header.DposContext)
	statedb, _ := state.New(header.Root, state.NewDatabase(api.dpos.db))
	epochContext := &EpochContext{
		statedb:     statedb,
		DposContext: dposContext,
		TimeStamp:   header.Time.Int64(),
	}

	votes, _ := epochContext.countVotes()
	newVotes := map[common.Address]string{}
	for _addr, _vote := range votes {
		newVotes[_addr] = _vote.String()
	}
	return newVotes, nil
}

func (api *API) GetMintCnts() (mintcnt map[common.Address]int64, err error){
	var header *types.Header
	header = api.chain.CurrentHeader()
	if header == nil {
		return nil, errUnknownBlock
	}

	dposContext, err := types.NewDposContextFromProto(api.dpos.db, header.DposContext)
	epochContext := &EpochContext{
		DposContext: dposContext,
		TimeStamp:   header.Time.Int64(),
	}

	mintcnts, cnt_err := epochContext.countMintCnts(header)
	return mintcnts, cnt_err
}

func (api *API) GetHistoryMintCnts() (mintcnt map[common.Address]int64, err error){
	var header *types.Header
	header = api.chain.CurrentHeader()
	if header == nil {
		return nil, errUnknownBlock
	}

	dposContext, err := types.NewDposContextFromProto(api.dpos.db, header.DposContext)
	epochContext := &EpochContext{
		DposContext: dposContext,
		TimeStamp:   header.Time.Int64(),
		chain:		 api.chain,
	}

	mintcnts, cnt_err := epochContext.countHistoryMintCnts(header)
	return mintcnts, cnt_err
}