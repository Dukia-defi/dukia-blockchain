// SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "../lib/forge-std/src/Test.sol";
// //import {Counter} from "../src/Counter.sol";
// import {ReadWalletData} from "../src/ReadWalletData.sol";

// contract CounterTest is Test {
//     Counter public counter;

//     function setUp() public {
//         counter = new Counter();
//         counter.setNumber(0);
//     }

//     function test_Increment() public {
//         counter.increment();
//         assertEq(counter.number(), 1);
//     }

//     function testFuzz_SetNumber(uint256 x) public {
//         counter.setNumber(x);
//         assertEq(counter.number(), x);
//     }
// }

// contract ReadWalletDataTest is Test{
//     ReadWalletData public readwalletdata;

//     function setUp() public{
//         readwalletdata = new ReadWalletData();
//     }

//     function testGetAaveAccountData() public {
//     uint256 totalCollateral = 1e18; // Mock data
//     uint256 totalDebt = 0.5e18;
//     uint256 availableBorrow = 0.5e18;
//     uint256 liquidationThreshold = 0.8e18;
//     uint256 ltv = 0.5e18;
//     uint256 healthFactor = 1.5e18;

//     vm.mockCall(poolAddress, abi.encodeWithSelector(IPool.getUserAccountData.selector),
//         abi.encode(totalCollateral, totalDebt, availableBorrow, liquidationThreshold, ltv, healthFactor)
//     );

//     (uint256 collateral, uint256 debt, uint256 borrow, uint256 threshold, uint256 loanToValue, uint256 health) = contractInstance.getAaveAccountData(userAddress);
//     assertEq(collateral, totalCollateral);
//     assertEq(debt, totalDebt);
//     assertEq(borrow, availableBorrow);
//     assertEq(threshold, liquidationThreshold);
//     assertEq(loanToValue, ltv);
//     assertEq(health, healthFactor);
// }
// }
