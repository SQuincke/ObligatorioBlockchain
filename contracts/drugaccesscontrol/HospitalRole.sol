pragma solidity ^0.4.0;

import "./Roles.sol";
import "./AdminRole.sol";

contract HospitalRole {

    using Roles for Roles.Role;

    event HospitalAdded(address indexed account);
    event HospitalRemoved(address indexed account);

//    event ProducerAdded(address indexed account);
//    event ProducerRemoved(address indexed account);
//
//    event PharmacyAdded(address indexed account);
//    event PharmacyRemoved(address indexed account);

    Roles.Role public hospitals;

    modifier onlyAdmin {
        require(AdminRole.isAdmin(msg.sender));
        _;
    }

    function addHospital(address account) public onlyAdmin {
        hospitals.add(account);
        emit HospitalAdded(account);
    }

    function isHospital(address account) public view returns (bool) {
        return hospitals.has(account);
    }
}
