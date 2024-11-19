// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import "./interface/IPool.sol";
// import "./library/SharedData.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {CrossChainMessenger} from "./utils/CrossChainMessenger.sol";

// interface IUniswapV2Router {
//     function addLiquidity(
//         address tokenA,
//         address tokenB,
//         uint amountADesired,
//         uint amountBDesired,
//         uint amountAMin,
//         uint amountBMin,
//         address to,
//         uint deadline
//     ) external returns (uint amountA, uint amountB, uint liquidity);
// }

contract UniswapTest {
    address userAddr = msg.sender;
    uint32 chainId = 11155111;  // Sepolia chain ID
    address target = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;  // Uniswap Router address on Sepolia

    function swapTokensForExactTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external {

        bytes memory message = abi.encodeWithSignature(
            "swapExactTokensForTokens(uint,uint,address[],address,uint)",
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + deadline
        );

        CrossChainMessenger.sendMessage(
            userAddr,
            chainId,
            message,
            target
        );
    }

}