// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DefautsBatiment {
    struct Defaut {
        string id;
        string description;
        string imageUrl;
        string localisation;
        uint256 timestamp;
        string defectType;
    }

    Defaut[] public defauts;
    mapping(string => uint256) private defautIndex;

    event DefautAjoute(
        string id,
        string description,
        string localisation,
        uint256 timestamp,
        string defectType
    );

    function ajouterDefaut(
        string memory _id,
        string memory _description,
        string memory _imageUrl,
        string memory _localisation,
        string memory _defectType
    ) public {
        require(defautIndex[_id] == 0, "Id deja utilise");

        defauts.push(
            Defaut({
                id: _id,
                description: _description,
                imageUrl: _imageUrl,
                localisation: _localisation,
                timestamp: block.timestamp,
                defectType: _defectType
            })
        );
        defautIndex[_id] = defauts.length;

        emit DefautAjoute(_id, _description, _localisation, block.timestamp, _defectType);
    }

    function getDefaut(string memory _id) public view returns (Defaut memory) {
        uint256 idx = defautIndex[_id];
        require(idx != 0, "Defaut non trouve");
        return defauts[idx - 1];
    }

    function getAllDefauts() public view returns (Defaut[] memory) {
        return defauts;
    }

    function getDefautCount() public view returns (uint256) {
        return defauts.length;
    }
}
