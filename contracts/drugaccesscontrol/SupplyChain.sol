pragma solidity ^0.4.0;

import "./Roles.sol";
import "../tokens/MedicationToken.sol";

contract SupplyChain {

    using Roles for Roles.Role;

    event RoleAdded(address indexed account, RoleType role);
    event RoleRemoved(address indexed account, RoleType role);

    Roles.Role admins;
    Roles.Role hospitals;
    Roles.Role producers;
    Roles.Role pharmacies;
    Roles.Role doctors;
    Roles.Role patients;

    struct

    enum RoleType {
        Admin, Hospital, Producer, Pharmacy, Doctor, Patient
    }

    constructor () public {
        admins.bearer[msg.sender] = true;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    modifier onlyHospital() {
        require(isHospital(msg.sender));
        _;
    }


    function isAdmin(address account) public view returns (bool) {
        return admins.has(account);
    }

    function isHospital(address account) public view returns (bool) {
        return hospitals.has(account);
    }

    function isProducer(address account) public view returns (bool) {
        return producers.has(account);
    }

    function isPharmacy(address account) public view returns (bool) {
        return pharmacies.has(account);
    }

    function isDoctor(address account) public view returns (bool) {
        return doctors.has(account);
    }

    function isPatient(address account) public view returns (bool) {
        return patients.has(account);
    }

    function addAdmin(address account) public onlyAdmin {
        admins.add(account);
        emit RoleAdded(account, RoleType.Admin);
    }

    function addHospital(address account) public onlyAdmin {
        hospitals.add(account);
        emit RoleAdded(account, RoleType.Hospital);
    }

    function addProducer(address account) public onlyAdmin {
        producers.add(account);
        emit RoleAdded(account, RoleType.Producer);
    }

    function addPharmacy(address account) public onlyAdmin {
        doctors.add(account);
        emit RoleAdded(account, RoleType.Pharmacy);
    }

    function addDoctor(address account) public onlyHospital {
        doctors.add(account);
        emit RoleAdded(account, RoleType.Doctor);
    }

    function addPatient(address account) public onlyHospital {
        patients.add(account);
        emit RoleAdded(account, RoleType.Patient);
    }

    function addPrescription(address account, uint256 medicationId) public {
        require(isDoctor(account));
        require(MedicationToken.isDrugInStore(medicationId));

    }
}
