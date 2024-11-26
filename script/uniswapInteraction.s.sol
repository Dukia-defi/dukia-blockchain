// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../src/uniswap/Uniswap.sol";
import "../src/interface/IERC20.sol";


interface IVariableDebtToken {
    function approveDelegation(address delegatee, uint256 amount) external;
}

interface IAtoken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract UniswapInteractionScript is Script {
    address constant ROUTER_ADDRESS = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;
    address constant USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; // 0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2
    address constant DAI = 0x68194a729C2450ad26072b3D33ADaCbcef39D574; //0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6
    address constant WETH = 0x7b79995e5F793A07bc00C7c19C34e753eB6e08Fd;

    UniswapIntegration public uniswapIntegration;

    function setUp() public {
        uniswapIntegration = new UniswapIntegration(ROUTER_ADDRESS); // Deploy the integration contract
    }

    function run() external {
        vm.startBroadcast();

        IERC20 usdc = IERC20(USDC);
        IERC20 dai = IERC20(DAI);

        uint256 usdcAmount = 0.5 * 10 ** 6; // 2 USDC (6 decimals)
        uint256 daiAmount = 0.5 * 10 ** 18; // 2 DAI (18 decimals)
        uint256 slippagePercent = 50; // 0.5% slippage tolerance
      

        console.log("uniswapIntegration deployed at:", address(uniswapIntegration));

        // Approve UniswapIntegration to spend tokens
        usdc.approve(address(uniswapIntegration), usdcAmount);
        dai.approve(address(uniswapIntegration), daiAmount);

        uniswapIntegration.addLiquidity(address(usdc),address(dai),usdcAmount,daiAmount,slippagePercent);

        console.log("Adding liquidity with:");
        console.log("USDC:", usdcAmount);
        console.log("DAI:", daiAmount);

        vm.stopBroadcast();
    }
}


// Submitting verification for [src/uniswap/Uniswap.sol:UniswapIntegration] 0x519c4b5B2AC3746cf9b97E23b797C7190dca0e4F.
// Submitted contract for verification:
//         Response: `OK`
//         GUID: `nfqqekjgt9ria7eusd9xlz7tf9yba8quqbmbiswpnzzl3sraul`
//         URL: https://sepolia.etherscan.io/address/0x519c4b5b2ac3746cf9b97e23b797c7190dca0e4f