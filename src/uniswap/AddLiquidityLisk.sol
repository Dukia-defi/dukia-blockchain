// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../interface/IPool.sol";
import "../library/SharedData.sol";
import {CrossChainMessenger} from "../utils/CrossChainMessenger.sol";

interface IUniswapV2Router {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
}

contract UniswapTest {
    address userAddr = msg.sender;
    uint32 chainId = 11155111; // Sepolia chain ID
    address target = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3; // Uniswap Router address on Sepolia

    // Token addresses on Sepolia
    address constant USDC = 0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2;
    address constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;

    function addLiquidity() external {
        // Calculate minimum amounts (e.g., 95% of desired amounts)
        uint256 usdcAmount = 2 * 10 ** 6; // 2 USDC
        uint256 daiAmount = 2 * 10 ** 18; // 2 DAI
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

        // CrossChainMessenger.Dispatcher(address(this)).dispatch(
        //     userAddr,
        //     chainId,
        //     message,
        //     target
        // );
    }
}
