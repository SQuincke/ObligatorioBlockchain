pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MedicationToken is ERC721 {

    string public name = "MedicationToken";
    string public symbol = "MTK";
    address minter;

    constructor() public {
        minter = msg.sender;
    }

    enum State {
        Produced, InStore, Sold
    }

    struct Drug {
        uint256 id;
        string name;
        bool requiresPrescription;
        uint256 creationDate;
        State currentState;
    }

    mapping(uint256 => Drug) public drugs;

    modifier onlyAdmin() {
        require(msg.sender == minter);
        _;
    }

    function drugExists(uint256 _id) public view returns(bool) {
        return drugs[_id].creationDate > 0;
    }

    function isDrugInStore(uint256 _id) public view returns(bool) {
        require(drugExists(_id));
        return drugs[_id].currentState == State.InStore;
    }

    function mint(address memory _receiver, uint256 _id, string _name, bool _requiresPrescription) public {
        drugs[_id] = Drug(_id, _name, _requiresPrescription, now, State.Produced);
    }

}
