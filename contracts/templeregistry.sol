// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract TempleRegistry {
    event NewTemple(uint256 templeId, string name);

    uint8 templeEnergy = 100;

    struct Temple {
        string name;
        uint8 waterEnergy;
        uint8 fireEnergy;
        uint8 grassEnergy;
        uint256 exp;
    }

    Temple[] public temples;

    mapping(address => uint256) public ownerToTemple;
    mapping(address => bool) public addressOwnsTemple;

    function _getRandomEnergy()
        private
        view
        returns (
            uint8 waterEnergy,
            uint8 fireEnergy,
            uint8 grassEnergy
        )
    {
        waterEnergy = uint8(
            uint256(
                keccak256(abi.encodePacked(msg.sender, block.difficulty, block.timestamp, 'water'))
            ) % 100
        );
        fireEnergy = uint8(
            uint256(
                keccak256(abi.encodePacked(msg.sender, block.difficulty, block.timestamp, 'fire'))
            ) % (100 - waterEnergy)
        );
        grassEnergy = 100 - waterEnergy - fireEnergy;
        return (waterEnergy, fireEnergy, grassEnergy);
    }

    function createTemple(string memory _name) public {
        require(!addressOwnsTemple[msg.sender], 'A user may only have one temple.');
        (uint8 waterEnergy, uint8 fireEnergy, uint8 grassEnergy) = _getRandomEnergy();
        temples.push(Temple(_name, waterEnergy, fireEnergy, grassEnergy, 0));
        uint256 id = temples.length - 1;
        addressOwnsTemple[msg.sender] = true;
        ownerToTemple[msg.sender] = id;
        emit NewTemple(id, _name);
    }
}
