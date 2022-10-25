// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import './templeregistry.sol';
import './safemath.sol';

contract TempleHelpers is TempleRegistry {
    using SafeMath for uint256;

    function _getTempleByAddress(address _address) internal view returns (Temple memory) {
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
}
