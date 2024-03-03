// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/erc1155/IGovToken.sol";
import "src/erc1155/ERC1155Votes.sol";

/// @notice 治理代幣
contract GovToken is IGovToken, ERC1155, ERC1155Votes, Ownable {
    address public treasury;

    uint256[] public ids = [0, 1, 2, 3];
    mapping(uint256 id => uint256 price) public priceOf;
    mapping(uint256 id => uint256 votingPower) public votingPowerOf;

    constructor(address _treasury) ERC1155("https://example/api/item/") EIP712("GovToken", "1") Ownable(msg.sender) {
        treasury = _treasury;

        priceOf[0] = 0.0001 ether;
        priceOf[1] = 0.0001 ether;
        priceOf[2] = 0.0001 ether;
        priceOf[3] = 0.0001 ether;

        votingPowerOf[0] = 1;
        votingPowerOf[1] = 1;
        votingPowerOf[2] = 1;
        votingPowerOf[3] = 1;
    }

    /// @notice 公開鑄造
    function mintBatch(uint256[] calldata _ids, uint256[] calldata _quantities) external payable override {
        require(_ids.length == _quantities.length, "arrays length mismatch.");

        uint256 totalPrice;
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            require(id == ids[0] || id == ids[1] || id == ids[2] || id == ids[3], "id is not validate.");

            totalPrice += priceOf[id] * _quantities[i];
        }
        require(msg.value >= totalPrice, "value is not enough.");

        (bool sentTreasurySucceeded, bytes memory sentTreasuryMsg) = payable(treasury).call{value: totalPrice}("");
        require(sentTreasurySucceeded, string(sentTreasuryMsg));

        _mintBatch(msg.sender, _ids, _quantities, "");
        if (delegates(msg.sender) == address(0x0)) delegate(msg.sender);

        // 多餘退款
        if (msg.value > totalPrice) {
            (bool refundSucceeded, bytes memory refundMsg) = msg.sender.call{value: msg.value - totalPrice}("");
            require(refundSucceeded, string(refundMsg));
        }

        emit Minted(msg.sender, _ids, _quantities);
    }

    /// @notice 更新
    function renew(uint256[] calldata _prices, uint256[] calldata _votingPowers) external override onlyOwner {
        require(_prices.length == 4 && _votingPowers.length == 4, "arrays length mismatch.");

        ids[0] += 4;
        ids[1] += 4;
        ids[2] += 4;
        ids[3] += 4;

        priceOf[ids[0]] = _prices[0];
        priceOf[ids[1]] = _prices[1];
        priceOf[ids[2]] = _prices[2];
        priceOf[ids[3]] = _prices[3];

        votingPowerOf[ids[0]] = _votingPowers[0];
        votingPowerOf[ids[1]] = _votingPowers[1];
        votingPowerOf[ids[2]] = _votingPowers[2];
        votingPowerOf[ids[3]] = _votingPowers[3];
    }

    /// @notice 更新 token 元資料
    function setURI(string calldata _newURI) external onlyOwner {
        _setURI(_newURI);
        emit URIUpdated(_newURI);
    }

    /// @notice 取得 token 元資料
    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(id), id, ".json"));
    }

    // The functions below are overrides required by Solidity.

    function powerOfToken(uint256 id) public view override returns (uint256) {
        return votingPowerOf[id];
    }

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    function _update(address _from, address _to, uint256[] memory _ids, uint256[] memory _values)
        internal
        override(ERC1155, ERC1155Votes)
    {
        super._update(_from, _to, _ids, _values);
    }
}
