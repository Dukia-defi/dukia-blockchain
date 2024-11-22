// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BatchExecutor {
    function executeBatch(address[] calldata targets, bytes[] calldata data) public payable {
        require(targets.length == data.length, "Mismatched inputs");

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].call(data[i]);
            require(success, string(abi.encodePacked("Execution failed: ", result)));
        }
    }

    function executeETHFlashLoan(
        address flashLoanProvider,
        uint256 amount,
        uint256 feePercentage,
        address[] calldata targets,
        bytes[] calldata data
    ) external {
        (bool success,) = flashLoanProvider.call(abi.encodeWithSignature("flashLoan(uint256)", amount));

        require(success, "Flash loan failed");

        executeBatch(targets, data);

        uint256 repaymentAmount = calculateRepaymentAmount(amount, feePercentage);

        (success,) = flashLoanProvider.call{value: repaymentAmount}("");

        require(success, "Repayment failed");
    }

    function executeERC20FlashLoan(
        address flashLoanProvider,
        address token,
        uint256 amount,
        uint256 feePercentage,
        address[] calldata targets,
        bytes[] calldata data
    ) external {
        require(targets.length == data.length, "Mismatched inputs");

        IERC20(token).transferFrom(flashLoanProvider, address(this), amount);

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].call(data[i]);
            require(success, string(abi.encodePacked("Call failed: ", result)));
        }

        uint256 repaymentAmount = calculateRepaymentAmount(amount, feePercentage);

        require(IERC20(token).balanceOf(address(this)) >= repaymentAmount, "Insufficient balance for repayment");

        IERC20(token).transfer(flashLoanProvider, repaymentAmount);
    }

    function calculateRepaymentAmount(uint256 amount, uint256 feePercentage) internal pure returns (uint256) {
        uint256 fee = (amount * feePercentage) / 10000;
        return amount + fee;
    }
}
