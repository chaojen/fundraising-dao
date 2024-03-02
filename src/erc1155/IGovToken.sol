// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovToken {
    event Minted(address minter, Rarity[] rarity, uint256[] amount);
    event TokenIdUpdated();
    event PriceUpdated(Rarity[] raritys, uint256[] prices);
    event URIUpdated(string newURI);

    enum Rarity {
        Common,
        Rare,
        Epic,
        Legendary
    }

    struct TokenInfo {
        uint256 id;
        uint256 price;
    }

    function mintBatch(Rarity[] calldata _rarity, uint256[] calldata _amount) external payable;
    function increaseTokenId() external;
    function updatePrice(Rarity[] memory _raritys, uint256[] memory _prices) external;
}
