// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "src/erc1155/GovToken.sol";
import "src/erc1155/IGovToken.sol";

contract GovTokenTest is Test, ERC1155Holder {
    GovToken token;

    function setUp() external {
        token = new GovToken(address(this), address(this));
    }

    function testMintBatch() external {
        // arrange
        IGovToken.Rarity[] memory raritys = new IGovToken.Rarity[](1);
        uint256[] memory quantities = new uint256[](1);
        raritys[0] = IGovToken.Rarity.Common;
        quantities[0] = 1;

        // act
        token.mintBatch{value: 0.3 ether}(raritys, quantities);

        // assert
        uint256 balance = token.balanceOf(address(this), 1000);
        assertEq(balance, 1);
    }

    receive() external payable {}

    fallback() external payable {}
}
