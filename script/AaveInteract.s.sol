// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console, console2} from "forge-std/Script.sol";
import {AaveInteraction} from "../src/aave/AaveInteraction.sol";
import "../src/interface/IERC20.sol";


interface IAaveInteraction {
    function supply(address asset, uint256 amount) external;
    function getVariableDebtTokenAddress(address asset) external view returns (address);
    function borrow(address asset, uint256 amount, uint256 interestRateMode) external;
    function repay(address tokenAddress, uint256 amount, uint256 interestRateMode) external;
    function withdraw(address tokenAddress, uint256 amount) external;
    function getAToken(address asset) external view returns (address);
    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}

interface IVariableDebtToken {
    function approveDelegation(address delegatee, uint256 amount) external;
}

interface IAtoken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract AaveScript is Script {
    IERC20 dai = IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357);
    IERC20 link = IERC20(0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5);
    IERC20 usdc = IERC20(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8);

    function run() public {
        vm.startBroadcast();

        // AaveInteraction hack = new AaveInteraction(0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A); // deploying adding the poolprovider address
        IAaveInteraction hack = IAaveInteraction(0x560B163A0FBcC293E082Df70Cc6b26B655C99d36);


        // dai.approve(address(hack), 100 ether);
        // hack.supply(address(dai), 100 ether);

        // address debbb = hack.getVariableDebtTokenAddress(address(link));

        // console2.log("Address:", debbb);

        // /// just like allowance
        // IVariableDebtToken(debbb).approveDelegation(address(hack), type(uint256).max);

        // hack.borrow(address(link), 1 ether, 2);

        (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) = hack.getUserAccountData(msg.sender);

        console2.log("Total Collateral Base:", totalCollateralBase);
        console2.log("Total Debt Base:", totalDebtBase);
        console2.log("Available Borrows Base:", availableBorrowsBase);
        console2.log("Current Liquidation Threshold:", currentLiquidationThreshold);
        console2.log("LTV:", ltv);
        console2.log("Health Factor:", healthFactor);

        hack.repay(address(link), 1 ether, 2);

        address deb = hack.getAToken(address(dai));

        IAtoken(deb).approve(address(hack), type(uint256).max);

        hack.withdraw(address(dai), 100 ether);

        vm.stopBroadcast();
    }
}
