// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title SDGsETH
contract SDGsETH is ERC20, Ownable {
    event PublicMint(address to, uint256 amount);
    event NewHolder(address holder);
    event Withdraw(address to, uint256 amount);

    address[] public holders;

    mapping(address => bool) private holderIndices;

    constructor(address _owner) ERC20("SDGs Ether", "SDGsETH") Ownable(_owner) {
        // 首次發行 1,000,000,000 SDGsETH
        _mint(address(this), 1_000_000_000 * 10 ** decimals());
    }

    receive() external payable {
        this.publicMint(msg.value);
    }

    /// @notice 公開鑄造
    /// @param _amount 數量
    function publicMint(uint256 _amount) external payable {
        require(_amount <= balanceOf(address(this)), "tokens for public mint are not enough.");
        require(msg.value >= _amount, "value is not enough.");

        _transfer(address(this), msg.sender, _amount);
        emit PublicMint(msg.sender, _amount);

        // 多餘退款
        if (msg.value > _amount) {
            (bool success, bytes memory data) = msg.sender.call{value: msg.value - _amount}("");
            require(success, string(data));
        }
    }

    /// @notice 鑄造新代幣
    function mint(uint256 _amount) external onlyOwner {
        _mint(address(this), _amount * 10 ** decimals());
    }

    /// @notice 燃燒代幣
    function burn(uint256 _amount) external onlyOwner {
        _burn(address(this), _amount);
    }

    /// @notice 提領
    function withdraw(uint256 _amount) external {
        require(balanceOf(msg.sender) >= _amount, "balance is insufficient to cover the withdrawal amount.");

        _transfer(msg.sender, address(this), _amount);
        emit Withdraw(msg.sender, _amount);

        (bool success, bytes memory data) = msg.sender.call{value: _amount}("");
        require(success, string(data));
    }

    function _update(address from, address to, uint256 amount) internal override {
        super._update(from, to, amount);
        if (to != address(this) && !holderIndices[to]) {
            holders.push(to);
            holderIndices[to] = true;
            emit NewHolder(to);
        }
    }
}
