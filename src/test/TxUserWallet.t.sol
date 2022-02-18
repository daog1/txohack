// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../TxUserWallet.sol";
import "../TxAttackWallet.sol";
import "forge-std/stdlib.sol";
import "forge-std/Vm.sol";

contract TxUserWalletTest is DSTest, stdCheats {
    TxUserWallet alice;
    TxAttackWallet bob;

    function setUp() public {
        startHoax(address(0x9BEF5148fD530244a14830f4984f2B76BCa0dC58), 8 ether);
        alice = new TxUserWallet();
        hoax(address(alice), 5 ether);
        bob = new TxAttackWallet();
        hoax(address(bob), 5 ether);
        emit log_named_uint("alice", address(alice).balance);
        emit log_named_address("alice", address(alice));
        emit log_named_address("bob", address(bob));
    }

    function testExample() public payable {
        //startHoax(address(0x9BEF5148fD530244a14830f4984f2B76BCa0dC58));
        alice.transferTo(payable(bob), 1 ether);
        emit log_named_uint("alice", address(alice).balance);
        emit log_named_uint("bob", address(bob).balance);
        emit log_string("testok");
    }
}
