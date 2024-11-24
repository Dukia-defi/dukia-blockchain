// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./library/SharedData.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./library/SharedData.sol";
import {CrossChainMessenger} from "./utils/CrossChainMessenger.sol";

contract UniswapTest {
    error Unathorized();

    address userAddr = msg.sender;
    address public immutable owner;
    uint32 chainId = 11155111; // Sepolia chain ID
    address target = SharedData.UNISWAP_SEPOLIA; // Uniswap Router address on Sepolia
    address public liskCCM = SharedData.LISK_SEPOLIA_CCM;
    // Token addresses on Sepolia
    address constant USDC = 0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2;
    address constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;

    constructor() {
        owner = msg.sender;
    }

    function swapTokensForExactTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        // address to,
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

        CrossChainMessenger(liskCCM).sendMessage(msg.sender, chainId, message, target);

        // emit TokensSwapped(msg.sender, amountIn, amountOutMin, path, to, deadline, amounts);
    }

    function changeTarget(address _newTarget) external {
        if (msg.sender != owner) revert Unathorized();

        target = _newTarget;
    }

    function changeLiskCCM(address _newLiskCCM) external {
        if (msg.sender != owner) revert Unathorized();

        liskCCM = _newLiskCCM;
    }

    function addLiquidity(uint32 _toChainId, uint256 usdcAmount, uint256 daiAmount, uint256 slippagePercent) external {
        // Calculate minimum amounts (e.g., 95% of desired amounts)

        uint256 minUsdcAmount = (usdcAmount * 95) / 100;
        uint256 minDaiAmount = (daiAmount * 95) / 100;

        bytes memory message = abi.encodeWithSignature(
            "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)",
            USDC,
            DAI,
            usdcAmount,
            daiAmount,
            minUsdcAmount,
            minDaiAmount,
            msg.sender,
            block.timestamp + 15
        );

        CrossChainMessenger(liskCCM).sendMessage(userAddr, chainId, message, target);
    }
}

// $ forge create --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY src/AddLiquidityLisk.sol:UniswapTest
//forge create src/Uniswap.sol:UniswapIntegration --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --etherscan-api-key $(ETHERSCAN_API_KEY) --verify
