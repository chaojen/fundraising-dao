// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovToken {
    event Minted(address minter, uint256[] rarity, uint256[] amount);
    event TokenIdUpdated();
    event URIUpdated(string newURI);

    function mintBatch(uint256[] calldata _raritys, uint256[] calldata _quantities) external payable;
    function renew(uint256[] calldata _prices, uint256[] calldata _votingPowers) external;
    function setURI(string calldata _newURI) external;
}
