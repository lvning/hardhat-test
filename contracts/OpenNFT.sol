// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpenNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    uint64 public constant MAX_MINT = 3;
    uint64 public constant FIRST_ORDER_NUM = 500;
    uint64 public constant MIN_MINT_PRICE = 0.1 ether;
    uint256 public constant FREE_NUM = 10000;
    uint256 public constant TOTAL_NUM = 15000;
    uint256 public currentPrice = MIN_MINT_PRICE;
    uint256 public nftSupply = 0;
    uint256 public immutable DEADLINE;
    Counters.Counter public personNum;

    constructor() ERC721("OpenNFT", "OPT") {
        DEADLINE = block.timestamp + 2 * 24 * 60 * 60;
    }

    function mint(uint256 num) public payable {
        if (block.timestamp <= DEADLINE) {
            require(
                personNum.current() <= FIRST_ORDER_NUM,
                "Exceeded free person num"
            );
            require(nftSupply < FREE_NUM, "free mint num is over");
            require(num <= MAX_MINT, "max free mint num is 3");
            require(
                balanceOf(_msgSender()) + num <= MAX_MINT,
                "you max mint 3 nfts"
            );
            personNum.increment();
            for (uint256 index = 0; index < num; index++) {
                nftSupply += 1;
                if (nftSupply == FREE_NUM) {
                    revert("Exceeded max free nft supply");
                }
                _safeMint(_msgSender(), nftSupply);
            }
        } else {
            require((nftSupply + num) < TOTAL_NUM, "Exceeded max nft supply");
            require(msg.value > currentPrice * num, "price is too low");
            currentPrice = msg.value / num;
            for (uint256 index = 0; index < num; index++) {
                nftSupply += 1;
                _safeMint(_msgSender(), nftSupply);
            }
        }
    }

    function withdraw() public onlyOwner {
        (bool sent, ) = owner().call{value: address(this).balance}("");
        require(sent, "withdraw failed");
    }
}
