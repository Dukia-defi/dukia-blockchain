// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;



import "./library/SharedData.sol";
import {CrossChainMessenger} from "./utils/CrossChainMessenger.sol";

interface IUniswapV2Router {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

contract UniswapTest {
    address userAddr = msg.sender;
    uint32 chainId = 11155111;  // Sepolia chain ID
    address target = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;  // Uniswap Router address on Sepolia
    address public liskCCM = SharedData.LISK_SEPOLIA_CCM;

    // Token addresses on Sepolia
    address constant USDC = 0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2;
    address constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;

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
