// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "src/erc1155/GovToken.sol";
import "src/ActionCenter.sol";
import "src/governance/SDGsDAO.sol";
import "src/governance/Timelock.sol";

contract SDGsDAOTest is Test, ERC1155Holder {
    ActionCenter actionCenter;
    GovToken token;
    Timelock timelock;
    SDGsDAO governor;

    function setUp() external {
        actionCenter = new ActionCenter();
        token = new GovToken(address(actionCenter));
        timelock = new Timelock(1 minutes, address(this));
        governor = new SDGsDAO(token, 1 minutes, 1 minutes, 0, timelock);
    }

    function testPropose() external {
        // arrange
        address[] memory targets = new address[](1);
        targets[0] = address(0x0);

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";

        string memory description = "test";

        // act
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // assert
        assertTrue(proposalId != 0);
    }
}
