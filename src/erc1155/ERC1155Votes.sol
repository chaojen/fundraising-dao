// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/governance/utils/Votes.sol";

abstract contract ERC1155Votes is ERC1155, Votes {
    mapping(address => uint256) private _votingUnits;

    function powerOfToken(uint256 /*id*/ ) public view virtual returns (uint256);

    function _getVotingUnits(address account) internal view override returns (uint256) {
        uint256 votingUnit = _votingUnits[account];
        return votingUnit;
    }

    function _update(address _from, address _to, uint256[] memory _ids, uint256[] memory _values)
        internal
        virtual
        override
    {
        for (uint256 i = 0; i < _ids.length; ++i) {
            uint256 units = powerOfToken(_ids[i]) * _values[i];
            _transferVotingUnits(_from, _to, units);
        }
        super._update(_from, _to, _ids, _values);
    }

    function _transferVotingUnits(address _from, address _to, uint256 _values) internal virtual override {
        if (_from != address(0)) {
            _votingUnits[_from] = _votingUnits[_from] - _values;
        }
        if (_to != address(0)) {
            _votingUnits[_to] = _votingUnits[_to] + _values;
        }
        super._transferVotingUnits(_from, _to, _values);
    }
}
