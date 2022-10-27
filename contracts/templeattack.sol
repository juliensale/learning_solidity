// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import './templehelpers.sol';
import './safemath.sol';

contract TempleAttack is TempleHelpers {
    using SafeMath for uint256;

    event Attack(address attacker, address defender, bool won);

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

    function attack(address _target, uint8 _type) external {
        require(_type < 3, 'The _type parameter must be either 0, 1 or 2.');
        require(
            addressOwnsTemple[msg.sender] && addressOwnsTemple[_target],
            'One user does not have a temple.'
        );
        require(msg.sender != _target, 'A user cannot attack himself.');
        Temple storage templeA = _getTempleByAddress(msg.sender);
        Temple storage templeD = _getTempleByAddress(_target);
        require(_isReady(templeA), 'One can only attack once per day.');

        if (_getAttackIssue(templeA, templeD, _type)) {
            _winningAttack(msg.sender, _target);
            emit Attack(msg.sender, _target, true);
        } else {
            emit Attack(msg.sender, _target, false);
        }
        _triggerCooldown(templeA);
    }
}
