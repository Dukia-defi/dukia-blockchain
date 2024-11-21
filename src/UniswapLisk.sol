// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import "./interface/IPool.sol";
// import "./library/SharedData.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./library/SharedData.sol";
import {CrossChainMessenger} from "./utils/CrossChainMessenger.sol";

contract UniswapTest {
    address userAddr = msg.sender;
    uint32 chainId = 11155111; // Sepolia chain ID
    address target = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3; // Uniswap Router address on Sepolia
    address public liskCCM = SharedData.LISK_SEPOLIA_CCM;

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

        CrossChainMessenger(liskCCM).sendMessage(userAddr, chainId, message, target);
    }


    function addLiquidity( uint32 _toChainId,uint256 usdcAmount, uint256 daiAmount,uint256 slippagePercent) external {
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

         CrossChainMessenger(liskCCM).sendMessage(userAddr, chainId, message,target);
    }
}


// $ forge create --rpc-url $SEPOLIA_RPC_URL --private-key $RIVATE_KEY src/AddLiquidityLisk.sol:UniswapTest