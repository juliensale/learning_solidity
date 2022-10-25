// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import './CryptoTemples.sol';

contract CryptoTemplesTest is CryptoTemples {
    function test_winningAttack(address _attackerAddress, address _defenderAddress) public {
        require(addressOwnsTemple[_attackerAddress] && addressOwnsTemple[_defenderAddress]);
        _winningAttack(_attackerAddress, _defenderAddress);
    }
}
