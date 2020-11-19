pragma solidity ^0.6.0;

import "./Roles.sol";

contract AdminRole {

    using Roles for Roles.Role;

    event AdminAdded(address indexed acount);
    event AdminRemoved(address indexed account);

    Roles.Role internal admins;

    constructor () public {
        admins.bearer[msg.sender] = true;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
    }

    function addAdmin(address account) public onlyAdmin {
        admins.add(account);
        emit AdminAdded(account);
    }

    function isAdmin(address account) public view returns(bool) {
        return admins.has(account);
    }
}
