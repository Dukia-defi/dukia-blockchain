// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interface/IPool.sol";
import "../src/interface/IERC20.sol";
import "./library/SharedData.sol";
import {CrossChainMessenger} from "./utils/CrossChainMessenger.sol";

// interface IAave {
//     function supply(
//         address asset,
//         uint256 amount,
//         address onBehalfOf,
//         uint16 referralCode
//     ) external;
// }

contract AaveTest {
    address userAddr = msg.sender;
    uint32 chainId = 11155111;
    address target = SharedData.AAVE_SEPOLIA;

    event ApproveAndSupplySuccessful(address ercTarget, uint256 value);
    event ApproveAndWithdrawSuccessful(address tokenAdress, uint256 amount);
    event BorrowSuccessful(address asset, uint256 amount);

    function supply(address asset,uint256 amount) external {
        bytes memory message = abi.encodeWithSignature(
            "function supply(address asset,uint256 amount,address onBehalfOf,uint16 referralCode) external;",
            asset,
            amount,
            msg.sender,
            0
        );

        CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            target
        );
    }

    function erc20Approve(address ercTarget, uint256 value) external {
        bytes memory message = abi.encodeWithSignature(
            "function approve(address spender, uint256 value) external returns (bool);",
            address(this),
            value
        );

        CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            ercTarget
        );
    }

    function approveAndSupply(address asset,uint256 amount) external {
        require(erc20Approve(asset, amount), "approval not successful");
        supply(asset, amount);

        emit ApproveAndSupplySuccessful(ercTarget, value);
    }

    function getVariableDebtTokenAddress(address asset) external {
        bytes memory message = abi.encodeWithSignature(
            "function getVariableDebtTokenAddress(address asset) external view returns (address);",
            asset
        );

        bytes32 msgHash = CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            target
        );
    }

    function approveDelegation(address delegatee) external {
        bytes memory message = abi.encodeWithSignature(
            "function approveDelegation(address delegatee, uint256 amount) external;",
            delegatee,
            type(uint256).max
        );

        CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            target // supposed to be the address gotten from the previous function I guess
        );
    }

    function borrow(address asset, uint256 amount, uint256 interestRateMode) external {
        bytes memory message = abi.encodeWithSignature(
            "function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf) external;",
            asset,
            amount,
            interestRateMode,
            0,
            msg.sender
        );

        CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            target
        );
    }

    function approveAndBorrow(address asset, address delegatee, uint256 amount, uint256 interestRateMode) external {
        getVariableDebtTokenAddress(asset);
        approveDelegation(delegatee, type(uint256).max);
        borrow(asset, amount, interestRateMode);

        emit BorrowSuccessful(asset, amount);
    }

    function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf) external {
        bytes memory message = abi.encodeWithSignature(
            "function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf) external returns (uint256)",
            asset,
            amount,
            interestRateMode,
            msg.sender
        );

        CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            target
        );
    }

    function getAToken(address asset) external {
        bytes memory message = abi.encodeWithSignature(
            "function getAToken(address asset) external view returns (address)",
            asset
        );

        CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            target
        );
    }

    function withdraw(address tokenAddress, uint256 amount) external {
        bytes memory message = abi.encodeWithSignature(
            "function withdraw(address tokenAddress, uint256 amount) external view returns (address)",
            tokenAddress,
            amount
        );

        CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            target
        );
    }

    function approveAndWithdraw(address tokenAddress, uint256 amount) external {
        // address atoken = getAToken(tokenAddress);
        require(erc20Approve(tokenAddress, amount), "approval failed");
        withdraw(tokenAddress, amount);

        emit ApproveAndWithdrawSuccessful(tokenAddress, amount);
    }
}