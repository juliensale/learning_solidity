// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import './templehelpers.sol';
import './safemath.sol';

contract TempleAttack is TempleHelpers {
    using SafeMath for uint256;

    event Attack(uint256 attackerId, uint256 defenderId, bool won);

    function _winningAttack(address _attacker, address _defender) internal {
        require(addressOwnsTemple[_attacker] && addressOwnsTemple[_defender]);

        uint256 attackerTempleId = ownerToTemple[_attacker];
        uint256 defenderTempleId = ownerToTemple[_defender];
        _addExp(
            attackerTempleId,
            getGainedExp(temples[attackerTempleId].level, temples[defenderTempleId].level)
        );
        _refreshTempleEnergy(attackerTempleId);
    }
}
