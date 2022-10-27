// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import './templeregistry.sol';
import './safemath.sol';
import './safemath8.sol';
import './RealMath.sol';

contract TempleHelpers is TempleRegistry {
    using SafeMath for uint256;
    using SafeMath8 for uint8;
    using RealMath for int128;

    function _getTempleByAddress(address _address) internal view returns (Temple storage) {
        require(addressOwnsTemple[_address], 'No temple is assigned to this address.');
        uint256 templeId = ownerToTemple[_address];
        return temples[templeId];
    }

    function getTemple() public view returns (Temple memory) {
        return _getTempleByAddress(msg.sender);
    }

    /*
     * @dev
     * Inspired by the slow formula from the Pokemon EXP system
     * Source: https://bulbapedia.bulbagarden.net/wiki/Experience
     */
    function getNextLevelExp(uint8 _currentLevel) public pure returns (uint256 exp) {
        uint256 n = (uint256(_currentLevel)).add(1);
        return (n.mul(n).mul(n).mul(5)).div(4);
    }

    /*
     * @dev
     * Inspired by the scaled formula used in Pokemon Gen. VII games
     * Source: https://bulbapedia.bulbagarden.net/wiki/Experience
     * dExp = (b * Ld / 5) * [(2Ld + 10)/(Ld + La + 10)]**2 + 1
     * with:
     *   Ld = defender's level
     *   La = attacker's level
     *   b arbitrarily set to 150
     * and we tranform the 2.5 exponent into a 2 in order to simplify the calculations
     */
    function getGainedExp(uint8 _attackerLevel, uint8 _defenderLevel)
        public
        pure
        returns (uint256 exp)
    {
        uint256 La = uint256(_attackerLevel);
        uint256 Ld = uint256(_defenderLevel);
        uint256 firstTerm = Ld.mul(30);
        uint256 secondTerm = ((Ld.mul(2)).add(10));
        uint256 thirdTerm = Ld.add(La).add(10);
        return (firstTerm.mul(secondTerm).mul(secondTerm)).div(thirdTerm * thirdTerm).add(1);
    }

    function _addExp(uint256 _templeId, uint256 _exp) internal {
        temples[_templeId].exp = temples[_templeId].exp.add(_exp);
        if (getNextLevelExp(temples[_templeId].level) <= temples[_templeId].exp) {
            temples[_templeId].level = temples[_templeId].level.add(1);
        }
    }

    function _refreshTempleEnergy(uint256 _templeId) internal {
        (uint8 waterEnergy, uint8 fireEnergy, uint8 grassEnergy) = _getRandomEnergy();

        temples[_templeId].waterEnergy = waterEnergy;
        temples[_templeId].fireEnergy = fireEnergy;
        temples[_templeId].grassEnergy = grassEnergy;
    }

    function _triggerCooldown(Temple storage _temple) internal {
        _temple.readyTime = uint32(block.timestamp + COOLDOWN_TIME);
    }

    function _isReady(Temple storage _temple) internal view returns (bool) {
        return (_temple.readyTime <= block.timestamp);
    }

    /*
     * @dev
     *  f(tA, tD, lA, lD) = [ (Ta-Td)/2 × 50×atan(La-Ld) ]/100 + 50 ∈ ⟦0;100⟧
     *  Even though the mathematical theory shows that the answer should be between 0 and 100,
     *  we make sure the function may not fail due to a miscalculation.
     */
    function _winningFormula(
        int128 _tA,
        int128 _tD,
        int128 _lA,
        int128 _lD
    ) internal pure returns (uint8) {
        int128 formulaResult = (25 * (_tA - _tD) * (_lA - _lD).atan2(1)) / 100 + 50;
        if (formulaResult <= 0 || formulaResult >= 100) {
            formulaResult = 50;
        }
        return uint8(uint128(formulaResult));
    }

    /*
     * @dev
     * type = 0 => water on fire
     * type = 1 => fire on grass
     * type = 2 => grass on water
     */
    function _getAttackIssue(
        Temple storage _templeA,
        Temple storage _templeD,
        uint8 _type
    ) internal view returns (bool) {
        int128 tA;
        int128 tD;
        if (_type == 0) {
            tA = int128(uint128(_templeA.waterEnergy));
            tD = int128(uint128(_templeD.fireEnergy));
        }
        if (_type == 1) {
            tA = int128(uint128(_templeA.fireEnergy));
            tD = int128(uint128(_templeD.grassEnergy));
        }
        if (_type == 2) {
            tA = int128(uint128(_templeA.grassEnergy));
            tD = int128(uint128(_templeD.waterEnergy));
        }
        uint8 rand = uint8(
            uint256(
                keccak256(abi.encodePacked(msg.sender, block.difficulty, block.timestamp, _type))
            ) % TEMPLE_ENERGY
        );
        return
            rand <=
            _winningFormula(
                tA,
                tD,
                int128(uint128(_templeA.level)),
                int128(uint128(_templeD.level))
            );
    }
}
