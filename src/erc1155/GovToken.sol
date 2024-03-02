// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/erc1155/IGovToken.sol";

/// @notice 治理代幣
contract GovToken is IGovToken, ERC1155, Ownable {
    modifier tokenExisted(Rarity[] memory _raritys) {
        for (uint256 i = 0; i < _raritys.length; i++) {
            require(tokenInfos[_raritys[i]].id != 0, "token does not exist.");
        }
        _;
    }

    address public treasury;
    mapping(Rarity => TokenInfo) public tokenInfos;

    constructor(address _owner, address _treasury) ERC1155("https://example/api/item/") Ownable(_owner) {
        treasury = _treasury;

        TokenInfo storage commonTokenInfo = tokenInfos[Rarity.Common];
        commonTokenInfo.id = 1_000;
        commonTokenInfo.price = 0.1 ether;

        TokenInfo storage rareTokenInfo = tokenInfos[Rarity.Rare];
        rareTokenInfo.id = 2_000;
        rareTokenInfo.price = 0.2 ether;

        TokenInfo storage epicTokenInfo = tokenInfos[Rarity.Epic];
        epicTokenInfo.id = 3_000;
        epicTokenInfo.price = 0.3 ether;

        TokenInfo storage legendaryTokenInfo = tokenInfos[Rarity.Legendary];
        legendaryTokenInfo.id = 4_000;
        legendaryTokenInfo.price = 0.4 ether;
    }

    /// @notice 公開鑄造
    function mintBatch(Rarity[] calldata _raritys, uint256[] calldata _quantities)
        external
        payable
        override
        tokenExisted(_raritys)
    {
        require(_raritys.length == _quantities.length, "arrays length mismatch.");

        uint256 totalPrice;
        uint256[] memory tokenIds = new uint256[](_raritys.length);
        for (uint256 i = 0; i < _raritys.length; i++) {
            TokenInfo memory tokenInfo = tokenInfos[_raritys[i]];
            totalPrice += tokenInfo.price * _quantities[i];
            tokenIds[i] = tokenInfo.id;
        }
        require(msg.value >= totalPrice, "value is not enough.");

        (bool sentTreasurySucceeded, bytes memory sentTreasuryMsg) = payable(treasury).call{value: totalPrice}("");
        require(sentTreasurySucceeded, string(sentTreasuryMsg));

        _mintBatch(msg.sender, tokenIds, _quantities, "");
        emit Minted(msg.sender, _raritys, _quantities);

        // 多餘退款
        if (msg.value > totalPrice) {
            (bool refundSucceeded, bytes memory refundMsg) = msg.sender.call{value: msg.value - totalPrice}("");
            require(refundSucceeded, string(refundMsg));
        }
    }

    /// @notice 遞增 tokenId
    function increaseTokenId() external override onlyOwner {
        tokenInfos[Rarity.Common].id++;
        tokenInfos[Rarity.Rare].id++;
        tokenInfos[Rarity.Epic].id++;
        tokenInfos[Rarity.Legendary].id++;
        emit TokenIdUpdated();
    }

    /// @notice 更新價格
    function updatePrice(Rarity[] memory _raritys, uint256[] memory _prices)
        external
        override
        onlyOwner
        tokenExisted(_raritys)
    {
        require(_raritys.length == _prices.length, "arrays length mismatch.");

        for (uint256 i = 0; i < _raritys.length; i++) {
            tokenInfos[_raritys[i]].price = _prices[i];
        }
        emit PriceUpdated(_raritys, _prices);
    }

    /// @notice 更新 token 元資料
    function setURI(string memory _newURI) external onlyOwner {
        _setURI(_newURI);
        emit URIUpdated(_newURI);
    }

    /// @notice 取得 token 元資料
    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(id), id, ".json"));
    }
}
