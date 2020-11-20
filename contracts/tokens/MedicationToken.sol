pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MedicationToken is ERC721 {

    constructor () ERC721("MedicationToken", "MTK") public {

    }

    enum State {
        Produced, InStore, Sold
    }

    struct Drug {
        uint256 id;
        string name;
        bool requiresPrescription;
        address locationAddress;
        uint256 creationDate;
        State currentState;
    }

    mapping(uint256 => Drug) public drugs;

    function drugExists(uint256 _id) public view returns(bool) {
        return drugs[_id].creationDate > 0;
    }

    function isDrugInStore(uint256 _id) public view returns(bool) {
        require(drugExists(_id));
        return drugs[_id].currentState == State.InStore;
    }

    function isDrugProduced(uint256 _id) public view returns(bool) {
        require(drugExists(_id));
        return drugs[_id].currentState == State.Produced;
    }

    function sellToken(uint256 _id) public {
        require(isDrugInStore(_id));
        drugs[_id].currentState = State.Sold;
        drugs[_id].locationAddress = 0x0;
    }

    function transferTkToStore(uint256 _id, address account) public {
        require(isDrugProduced(_id));
        drugs[_id].currentState = State.InStore;
        drugs[_id].locationAddress = account;
    }

    function createToken(uint256 _id, string memory _name, bool _requiresPrescription, address account, uint256 creationTime) public {
        drugs[_id] = Drug(_id, _name, _requiresPrescription, account, creationTime, State.Produced);
    }

}
