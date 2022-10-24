// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import './templeregistry.sol';

contract TempleHelpers is TempleRegistry {
    function _getTempleByAddress(address _address) internal view returns (Temple memory) {
        require(addressOwnsTemple[_address], 'No temple is assigned to this address.');
        uint256 templeId = ownerToTemple[_address];
        return temples[templeId];
    }

    function getTemple() public view returns (Temple memory) {
        return _getTempleByAddress(msg.sender);
    }
}
