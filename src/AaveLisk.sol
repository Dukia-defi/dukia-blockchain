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

contract AaveLisk {
    error Unathorized();

    address immutable OWNER;
    address public target = SharedData.AAVE_SEPOLIA; //Aave pool address
    address public liskCCM = SharedData.LISK_SEPOLIA_CCM;

    constructor() {
        OWNER = msg.sender;
    }

    function supply(address _userAddr, uint32 _chainId, address _asset, uint256 _amount) external {
        //this is for the actual aave contract, this would also require the approve and transferfrom calls.
        bytes memory message = abi.encodeWithSignature(
            "function supply(address asset,uint256 amount,address onBehalfOf,uint16 referralCode) external",
            _asset,
            _amount,
            _userAddr,
            0
        );

        //this is for the new aave interaction contract...choose the one guys intend to interact with

        /*
        bytes memory message = abi.encodeWithSignature(
            "function supply(address tokenAddress, uint256 amount) external",
            _asset,
            _amount,
        );
        */

        CrossChainMessenger(liskCCM).sendMessage(
            _userAddr,
            _chainId,
            message,
            target
        );
    }

    function changeTarget(address _newTarget) external {
        if(msg.sender != OWNER) revert Unathorized();

        target = _newTarget;
    }

      function changeLiskCCM(address _newLiskCCM) external {
        if(msg.sender != OWNER) revert Unathorized();

        liskCCM = _newLiskCCM;
    }
}