// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title USDGs
contract USDGs is ERC20, Ownable {
    event Mint(address to, uint256 amount);
    event NewHolder(address holder);
    event Withdraw(address to, uint256 amount);
    event MaxSupplyIncreased(uint256 amount);
    event Burned(uint256 amount);

    IERC20 public custodyToken;
    address[] public holders;

    mapping(address => bool) private holderIndices;

    constructor(address _owner, address _token) ERC20("USDGs", "USDGs") Ownable(_owner) {
        custodyToken = IERC20(_token);
        // 首次發行 1,000,000,000 USDGs
        _mint(address(this), 1_000_000_000 * 10 ** decimals());
    }

    /// @notice 公開鑄造
    /// @param _amount 數量
    function mint(uint256 _amount) external {
        require(_amount <= balanceOf(address(this)), "tokens for mint are not enough.");

        uint256 allowance = custodyToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "allowance is not enough.");

        bool succeeded = custodyToken.transferFrom(msg.sender, address(this), _amount);
        require(succeeded, "transfer from USD token not succeeded.");

        _transfer(address(this), msg.sender, _amount);
        emit Mint(msg.sender, _amount);
    }

    /// @notice 提領
    function withdraw(uint256 _amount) external {
        require(balanceOf(msg.sender) >= _amount, "balance is insufficient to cover the withdrawal amount.");

        _transfer(msg.sender, address(this), _amount);

        bool succeeded = custodyToken.transfer(msg.sender, _amount);
        if (succeeded) emit Withdraw(msg.sender, _amount);
    }

    /// @notice 新增供應上限
    function increaseMaxSupply(uint256 _amount) external onlyOwner {
        uint256 total = _amount * 10 ** decimals();
        _mint(address(this), total);
        emit MaxSupplyIncreased(total);
    }

    /// @notice 減少供應上限
    function burn(uint256 _amount) external onlyOwner {
        uint256 total = _amount * 10 ** decimals();
        require(balanceOf(address(this)) >= total, "not enough balance to burn.");

        _burn(address(this), total);
        emit Burned(total);
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
