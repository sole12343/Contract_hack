// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
核心逻辑：
Roulette合约： 是一个游戏，每个人玩游戏先打10eth到合约账户，
              看谁的交易区块时间戳正好可以被15整除，谁就可以赢得全部余额
漏洞：矿工可以自己先算一个交易的时间满足15整除，
      让自己的区块那个时间完成打包交易，就会生成相应的哈希，他就会赢得奖励

Roulette is a game where you can win all of the Ether in the contract
if you can submit a transaction at a specific timing.
A player needs to send 10 Ether and wins if the block.timestamp % 15 == 0.
*/

/*
1. Deploy Roulette with 10 Ether
2. Eve runs a powerful miner that can manipulate the block timestamp.
3. Eve sets the block.timestamp to a number in the future that is divisible by
   15 and finds the target block hash.
4. Eve's block is successfully included into the chain, Eve wins the
   Roulette game.
*/

contract Roulette {
    uint public pastBlockTime;

    constructor() payable {}

    function spin() external payable {
        require(msg.value == 10 ether); // must send 10 ether to play
        require(block.timestamp != pastBlockTime); // only 1 transaction per block

        pastBlockTime = block.timestamp;

        if (block.timestamp % 15 == 0) {
            (bool sent, ) = msg.sender.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
    }
}
