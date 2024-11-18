pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract SwapExactTokensForTokenScript is Script {
    // Contract addresses
    address constant ROUTER_ADDRESS = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;
    address constant USDC = 0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2;
    address constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;

    // Token holder addresses
    address daiHolder = 0x511243992D17992E34125EF1274C7DCA4a94C030;

    function run() external {
        // Setup fork environment
        uint256 sepoliaFork = vm.createFork(vm.envString("SEPOLIA_RPC_URL"));
        vm.selectFork(sepoliaFork);

        // Start impersonating the DAI holder
        vm.startPrank(daiHolder);

        // Setup contracts
        IERC20 dai = IERC20(DAI);
        IERC20 usdc = IERC20(USDC);
        IUniswapV2Router02 router = IUniswapV2Router02(ROUTER_ADDRESS);

        // Log initial balances
        console.log("Initial DAI balance:", dai.balanceOf(daiHolder));
        console.log("Initial USDC balance:", usdc.balanceOf(daiHolder));

        // Calculate amounts
        uint256 amountIn = 50 * 10**18; // 50 DAI (18 decimals)

        // Step 1: First approve the router to spend our DAI
        console.log("Approving DAI...");
        dai.approve(ROUTER_ADDRESS, amountIn);

        // Create the swap path
        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = USDC;

        // Get expected amount out for calculating slippage
        try router.getAmountsOut(amountIn, path) returns (uint256[] memory amounts) {
            console.log("Expected DAI in:", amounts[0]);
            console.log("Expected USDC out:", amounts[1]);
            
            // Calculate minimum amount out with 1% slippage tolerance
            uint256 amountOutMin = amounts[1] * 99 / 100; // 1% slippage
            console.log("Minimum USDC to receive (with 1% slippage):", amountOutMin);

            // Step 2: Execute the swap
            console.log("Executing swap...");
            try router.swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                daiHolder,
                block.timestamp + 15
            ) returns (uint256[] memory swapAmounts) {
                console.log("\nSwap successful!");
                console.log("DAI spent:", swapAmounts[0]);
                console.log("USDC received:", swapAmounts[1]);
            } catch Error(string memory reason) {
                console.log("\nSwap failed:", reason);
            }
        } catch Error(string memory reason) {
            console.log("Getting amounts out failed:", reason);
        }

        // Log final balances
        console.log("\nFinal balances:");
        console.log("DAI balance:", dai.balanceOf(daiHolder));
        console.log("USDC balance:", usdc.balanceOf(daiHolder));

        vm.stopPrank();
    }
}


// contract SwapExactTokensForTokenScript is Script {
//     address constant ROUTER_ADDRESS = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;  
//     address constant USDC = 0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2;  
//     address constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;  
//     address usdcTokenHolder = 0x245C6D6cd75753A4003946897E9B0f046186e797; 
//     address daiTokenHolder = 0x511243992D17992E34125EF1274C7DCA4a94C030;

//     function run() external {
//         uint256 sepoliaFork = vm.createFork(vm.envString("SEPOLIA_RPC_URL"));
//         vm.selectFork(sepoliaFork);

//         vm.startPrank(usdcTokenHolder);

//         IERC20 usdc = IERC20(USDC);
//         IERC20 dai = IERC20(DAI);

//         IUniswapV2Router02 router = IUniswapV2Router02(ROUTER_ADDRESS);

//         console.log("Initial USDC balance:", usdc.balanceOf(usdcTokenHolder));

//         uint256 usdcAmount = 2 * 10**6;  // 2 USDC (6 decimals)
//         usdc.transfer(daiTokenHolder, usdcAmount);
        
//         vm.stopPrank(); 

//         vm.startPrank(daiTokenHolder);
      
//         console.log("Initial DAI balance:", dai.balanceOf(daiTokenHolder));

//         uint256 daiAmount = 2 * 10**18; // 2 DAI (18 decimals)

//         dai.approve(ROUTER_ADDRESS, daiAmount);
//         usdc.approve(ROUTER_ADDRESS, usdcAmount);

//         // Swap USDC to DAI using swapExactTokensForTokens
//         uint256 minDAIAmount = daiAmount * 95 / 100; // Slippage tolerance 5%

//         try router.swapExactTokensForTokens(
//             usdcAmount,               // Amount of USDC to swap
//             minDAIAmount,             // Minimum amount of DAI to receive (slippage tolerance)
//             getPathForUSDCtoDAI(),    // Path from USDC to DAI
//             daiTokenHolder,           // Recipient of DAI
//             block.timestamp + 15      // Deadline (timestamp)
//         ) returns (uint256[] memory amounts) {
//             console.log("Swap successful!");
//             console.log("USDC amount swapped:", amounts[0]);
//             console.log("DAI amount received:", amounts[amounts.length - 1]);
//         } catch Error(string memory reason) {
//             console.log("Failed to swap tokens:", reason);
//         }

//         console.log("Final USDC balance:", usdc.balanceOf(daiTokenHolder));
//         console.log("Final DAI balance:", dai.balanceOf(daiTokenHolder));

//         vm.stopPrank();
//     }

//     // Helper function to get the swap path for USDC -> DAI
//     function getPathForUSDCtoDAI() private pure returns (address[] memory path) {
//         path = new address[](2);
//         path[0] = USDC;         // Set the first address to USDC
//         path[1] = DAI;          // Set the second address to DAI
//         return path;            // Return the path
//     }


// }