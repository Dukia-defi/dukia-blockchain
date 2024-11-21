// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./library/SharedData.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {CrossChainMessenger} from "./utils/CrossChainMessenger.sol";

contract UniswapTest {
    address userAddr = msg.sender;
    address public immutable owner;
    uint32 chainId = 11155111; // Sepolia chain ID
    address target = SharedData.UNISWAP_SEPOLIA; // Uniswap Router address on Sepolia
    address public liskCCM = SharedData.LISK_SEPOLIA_CCM;

    constructor() {
        owner = msg.sender;
    }

    error Unathorized();

    function swapTokensForExactTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external {
        bytes memory message = abi.encodeWithSignature(
            "swapExactTokensForTokens(uint,uint,address[],address,uint)",
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + deadline
        );

        CrossChainMessenger(liskCCM).sendMessage(userAddr, chainId, message, target);

        emit TokensSwapped(msg.sender, amountIn, amountOutMin, path, to, deadline, amounts);
    }

    function changeTarget(address _newTarget) external {
        if (msg.sender != owner) revert Unathorized();

        target = _newTarget;
    }

    function changeLiskCCM(address _newLiskCCM) external {
        if (msg.sender != owner) revert Unathorized();

        liskCCM = _newLiskCCM;
    }
}
