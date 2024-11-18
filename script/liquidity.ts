// import { ethers } from "hardhat";
// const helpers = require("@nomicfoundation/hardhat-network-helpers");
// async function main(){
//     const ROUTER_ADDRESS = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
//     const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
//     const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
//     // const AddLiquidityAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

//     const TOKEN_HOLDER = "0xf584F8728B874a6a5c7A8d4d387C9aae9172D621";

//     await helpers.impersonateAccount(TOKEN_HOLDER);
//     const impersonatedSigner = await ethers.getSigner(TOKEN_HOLDER);

//     //Amount of USDC and Dai we want to add to the pool
//     const UsdcDesired = ethers.parseUnits("2",6);
//     const DaiDesired = ethers.parseUnits("2",18);

//     //address 
//     const USDC_Contract = await ethers.getContractAt("IERC20", USDC, impersonatedSigner);
//     const DAI_Contract = await ethers.getContractAt("IERC20", DAI, impersonatedSigner);
//     // const Add_Liquidity = await ethers.getContractAt("addLiquidity", AddLiquidityAddress, impersonatedSigner);
//     const ROUTER = await ethers.getContractAt("IUniswapV2Router", ROUTER_ADDRESS, impersonatedSigner);

//     //approve USDC and DAI to be transferred by the router
//     await USDC_Contract.approve(ROUTER, UsdcDesired);
//     await DAI_Contract.approve(ROUTER, DaiDesired);

//     //balance before snding liquidity
//     const usdcBal = await USDC_Contract.balanceOf(impersonatedSigner.address);
//     const daiBal = await DAI_Contract.balanceOf(impersonatedSigner.address);
//     const deadline = Math.floor(Date.now() / 1000) + (60 * 10);

//     console.log("usdc balance before adding liquidity", Number(usdcBal));
//     console.log("dai balance before adding liquidity", Number(daiBal));

//     // add liquidity to the pool

//     // const tx = await Add_Liquidity.add_liquidity(USDC, DAI, UsdcDesired, DaiDesired, 0, 0, impersonatedSigner.address, deadline);
//     // await tx.wait();

//      await ROUTER.addLiquidity(
//         USDC,
//         DAI,
//         UsdcDesired,
//         DaiDesired,
//         0,
//         0,
//         TOKEN_HOLDER,
//         deadline
//     );

//     console.log("Liquidity added successfully");

//     const usdcBalAfter = await USDC_Contract.balanceOf(impersonatedSigner.address);
//     const daiBalAfter = await DAI_Contract.balanceOf(impersonatedSigner.address);

//     console.log("=========================================================");

//     console.log("usdc balance after adding liquidity", Number(usdcBalAfter));
//     console.log("dai balance after adding liquidity", Number(daiBalAfter));

// }

// main().catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
// });
