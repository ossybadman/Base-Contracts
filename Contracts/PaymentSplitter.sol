// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PaymentSplitter {
    uint256 public totalReceived;

    event PaymentSplit(
        address indexed sender,
        address[] recipients,
        uint256[] amounts
    );

    // Anyone calls this with their own recipients and shares
    // shares must add up to 10000 (100%)
    // e.g. [5000, 3000, 2000] = 50%, 30%, 20%
    function splitPayment(
        address[] calldata recipients,
        uint256[] calldata shares
    ) external payable {
        require(msg.value > 0, "Must send ETH");
        require(recipients.length == shares.length, "Mismatch");
        require(recipients.length > 0, "No recipients");
        require(recipients.length <= 10, "Max 10 recipients");

        uint256 total = 0;
        for (uint i = 0; i < shares.length; i++) {
            total += shares[i];
        }
        require(total == 10000, "Shares must add up to 10000");

        uint256[] memory amounts = new uint256[](recipients.length);

        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid address");
            amounts[i] = (msg.value * shares[i]) / 10000;
            if (amounts[i] > 0) {
                (bool sent,) = payable(recipients[i]).call{value: amounts[i]}("");
                require(sent, "Transfer failed");
            }
        }

        totalReceived += msg.value;
        emit PaymentSplit(msg.sender, recipients, amounts);
    }

    // Check contract balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
