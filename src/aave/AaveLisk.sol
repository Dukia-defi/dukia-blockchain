// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../interface/IPool.sol";
import "../interface/IERC20.sol";
import "../library/SharedData.sol";
import {CrossChainMessenger} from "../utils/CrossChainMessenger.sol";

// interface IAave {
//     function supply(
//         address asset,
//         uint256 amount,
//         address onBehalfOf,
//         uint16 referralCode
//     ) external;
// }

contract AaveLisk {
    address userAddr = msg.sender;
    uint32 chainId = 11155111;
    address immutable OWNER;
    address public target = SharedData.AAVE_SEPOLIA; //Aave pool address
    address public liskCCM = SharedData.LISK_SEPOLIA_CCM;

    constructor() {
        OWNER = msg.sender;
    }

    error Unathorized();

    event ApproveAndSupplySuccessful(address ercTarget, uint256 value);
    event ApproveAndWithdrawSuccessful(address tokenAdress, uint256 amount);
    event ApproveAndBorrowSuccessful(address asset, uint256 amount);
    event RepaySuccessful(address asset, uint256 amount);

    function approveAndSupply(address _userAddr, uint32 _chainId, address tokenAddress, uint256 amount) external {
        // require(erc20Approve(asset, amount), "approval not successful");
        // supply(asset, amount);
        bytes memory message = abi.encodeWithSignature(
            "function approveAndSupply(address contractAddress, address tokenAddress, uint256 amount) external;",
            address(this),
            tokenAddress,
            amount
        );

        CrossChainMessenger(liskCCM).sendMessage(_userAddr, _chainId, message, target);

        emit ApproveAndSupplySuccessful(tokenAddress, amount);
    }

    function approveAndBorrow(
        address _userAddr,
        uint32 _chainId,
        address asset,
        uint256 amount,
        uint256 interestRateMode
    ) external {
        // require(erc20Approve(asset, amount), "approval not successful");
        // supply(asset, amount);
        bytes memory message = abi.encodeWithSignature(
            "function approveAndBorrow(address contractAddress, address asset, uint256 amount, uint256 interestRateMode) external;",
            address(this),
            asset,
            amount,
            interestRateMode
        );

        CrossChainMessenger(liskCCM).sendMessage(_userAddr, _chainId, message, target);

        emit ApproveAndBorrowSuccessful(asset, amount);
    }

    function approveAndWithdraw(
        address _userAddr,
        uint32 _chainId,
        address contractAddress,
        address tokenAddress,
        uint256 amount
    ) external {
        bytes memory message = abi.encodeWithSignature(
            "function approveAndWithdraw(address contractAddress, address tokenAddress, uint256 amount) external;",
            address(this),
            tokenAddress,
            amount
        );

        CrossChainMessenger(liskCCM).sendMessage(_userAddr, _chainId, message, target);

        emit ApproveAndWithdrawSuccessful(tokenAddress, amount);
    }

    function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf) external {
        bytes memory message = abi.encodeWithSignature(
            "function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf) external returns (uint256)",
            asset,
            amount,
            interestRateMode,
            msg.sender
        );

        CrossChainMessenger(liskCCM).sendMessage(userAddr, chainId, message, target);

        emit RepaySuccessful(asset, amount);
    }

    function changeTarget(address _newTarget) external {
        if (msg.sender != OWNER) revert Unathorized();

        target = _newTarget;
    }

    function changeLiskCCM(address _newLiskCCM) external {
        if (msg.sender != OWNER) revert Unathorized();

        liskCCM = _newLiskCCM;
    }
}
