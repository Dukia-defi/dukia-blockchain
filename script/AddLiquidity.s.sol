// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract AddLiquidityScript is Script {
    address constant ROUTER_ADDRESS = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;
    address constant USDC = 0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2;
    address constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;
    address usdcTokenHolder = 0x245C6D6cd75753A4003946897E9B0f046186e797;
    address daiTokenHolder = 0x511243992D17992E34125EF1274C7DCA4a94C030;
    function run() external {
        uint256 sepoliaFork = vm.createFork(vm.envString("SEPOLIA_RPC_URL"));

        vm.selectFork(sepoliaFork);

        vm.startPrank(usdcTokenHolder);

        IERC20 usdc = IERC20(USDC);
        IERC20 dai = IERC20(DAI);

        IUniswapV2Router02 router = IUniswapV2Router02(ROUTER_ADDRESS);
        console.log("Initial USDC balance:", usdc.balanceOf(usdcTokenHolder));

        uint256 usdcAmount = 2 * 10**6;
        usdc.transfer(daiTokenHolder, usdcAmount);
        
        vm.stopPrank();

        vm.startPrank(daiTokenHolder);
        console.log("Initial DAI balance:", dai.balanceOf(daiTokenHolder));

        uint256 daiAmount = 2 * 10**18; // 2 DAI (18 decimals)
 
        dai.approve(ROUTER_ADDRESS, daiAmount);
        usdc.approve(ROUTER_ADDRESS, usdcAmount);


        try router.addLiquidity(
            USDC,
            DAI,
            usdcAmount,
            daiAmount,
            usdcAmount * 95 / 100,
            daiAmount * 95 / 100,
            daiTokenHolder,
            block.timestamp + 15
        ) returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        ) {
           console.log("Liquidity added successfully!");
           console.log("USDC amount used:", amountA);
           console.log("DAI amount used:", amountB);
           console.log("LP tokens received:", liquidity);
        } catch Error(string memory reason) {
            console.log("Failed to add liquidity:", reason);
        }

         console.log("Final USDC balance:", usdc.balanceOf(usdcTokenHolder));
         console.log("Final DAI balance:", dai.balanceOf(daiTokenHolder));

        vm.stopPrank();
    }
}



// forge script script/AddLiquidity.s.sol:AddLiquidityScript --fork-url $SEPOLIA_RPC_URL --broadcast