// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "ds-test/test.sol";

contract TxUserWallet is DSTest {
    address owner;

    constructor() {
        owner = msg.sender;
        //emit log_named_address("owner", owner);
    }

    function transferTo(address payable dest, uint256 amount) public payable {
        emit log_named_address("tx.origin", tx.origin);
        emit log_named_address("owner", owner);
        require(tx.origin == owner);
        dest.call{value: amount}("");
    }
}
