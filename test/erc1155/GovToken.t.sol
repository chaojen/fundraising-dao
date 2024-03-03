// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "src/erc1155/GovToken.sol";
import "src/ActionCenter.sol";

contract GovTokenTest is Test, ERC1155Holder {
    ActionCenter actionCenter;
    GovToken token;

    function setUp() external {
        actionCenter = new ActionCenter();
        token = new GovToken(address(actionCenter));
    }

    function testMintBatch() external {
        // arrange
        uint256[] memory ids = new uint256[](1);
        ids[0] = 0;
        uint256[] memory quantities = new uint256[](1);
        quantities[0] = 1;

        // act
        token.mintBatch{value: 0.0001 ether}(ids, quantities);

        // assert
        uint256 balance = token.balanceOf(address(this), 0);
        assertEq(balance, 1);
    }

    function testGetVotes() external {
        // arrange
        uint256[] memory ids = new uint256[](1);
        ids[0] = 0;
        uint256[] memory quantities = new uint256[](1);
        quantities[0] = 1;

        // act
        token.mintBatch{value: 0.3 ether}(ids, quantities);

        // assert
        uint256 votes = token.getVotes(address(this));
        assertEq(votes, 1);
    }

    receive() external payable {}

    fallback() external payable {}
}
