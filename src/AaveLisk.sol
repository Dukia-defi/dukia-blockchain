// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interface/IPool.sol";
import "./library/SharedData.sol";
import {CrossChainMessenger} from "./utils/CrossChainMessenger.sol";

interface IAave {
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
}

contract AaveTest {
    address userAddr = msg.sender;
    uint32 chainId = 11155111;
    address target = SharedData.AAVE_SEPOLIA; //Aave pool address

    function supply() external {
        bytes memory message = abi.encodeWithSignature(
            "function supply(address asset,uint256 amount,address onBehalfOf,uint16 referralCode) external;",
            address(0),
            100,
            msg.sender,
            0
        );

        CrossChainMessenger.Dispatcher(address(this)).dispatch(
            userAddr,
            chainId,
            message,
            target
        );
    }
}