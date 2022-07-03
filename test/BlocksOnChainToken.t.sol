// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.10;

import "@std/Test.sol";
import "../src/BlocksOnChainToken.sol";

contract BlocksOnChainTokenTest is Test {
    BlocksOnChainToken private sut; 

    function setUp() public {
        sut = new BlocksOnChainToken("Name", "Symbol", "baseURI");
    }

    function testFailNoMintPricePaid() public {
        sut.mint(address(1), 1);
    }
}