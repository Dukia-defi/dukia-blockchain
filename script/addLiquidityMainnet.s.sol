// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Script.sol";
// import "forge-std/console.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";



// contract AddLiquidityScript is Script {
//     // Sepolia Testnet Addresses
//     address constant ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
//     address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
//     address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
//     address constant TOKEN_HOLDER = 0xf584F8728B874a6a5c7A8d4d387C9aae9172D621;
//     // address TOKEN_HOLDER = 0x245C6D6cd75753A4003946897E9B0f046186e797; // Impersonated Account
//     // address daiTokenHolder = 0x511243992D17992E34125EF1274C7DCA4a94C030;

    
//     // Whale address with both USDC and DAI on Sepolia
//     // address constant WHALE = 0x5BC40cA7E44244742409Fd9B7A6848777C8AEf0B;

//     function run() external {
//         uint256 sepoliaFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
//         vm.selectFork(sepoliaFork);

//            // Start impersonating the USDC holder
//         vm.startPrank(TOKEN_HOLDER);

//         // Get token instances
//         IERC20 usdc = IERC20(USDC);
//         IERC20 dai = IERC20(DAI);
//         IUniswapV2Router02 router = IUniswapV2Router02(ROUTER_ADDRESS);

//         // Print initial balances for USDC holder
//         console.log("Initial USDC balance:", usdc.balanceOf(TOKEN_HOLDER));

//         uint256 usdcAmount = 1 * 10**6; // 2 USDC (6 decimals)
//         uint256 usdcAmount1 = 5 * 10**6; // 2 USDC (6 decimals)
//         uint256 daiAmount = 2 * 10**18; // 2 USDC (6 decimals)
//         uint256 deadline = Math.floor(Date.now() / 1000) + (60 * 10);
        
//         usdc.approve(ROUTER_ADDRESS, usdcAmount1);
//         vm.stopPrank(); // Stop USDC holder prank

//         // Add liquidity
//         try router.addLiquidity(
//             USDC,
//             DAI,
//             usdcAmount,
//             daiAmount,
//             0,
//             0,
//             TOKEN_HOLDER,               
//             deadline
//         ) returns (
//             uint256 amountA,
//             uint256 amountB,
//             uint256 liquidity
//         ) {
//             console.log("Liquidity added successfully!");
//             console.log("USDC amount used:", amountA);
//             console.log("DAI amount used:", amountB);
//             console.log("LP tokens received:", liquidity);
//         } catch Error(string memory reason) {
//             console.log("Failed to add liquidity:", reason);
//         }

//         // Print final balances
//         console.log("Final USDC balance:", usdc.balanceOf(TOKEN_HOLDER));

//         vm.stopPrank();
//     }
// }