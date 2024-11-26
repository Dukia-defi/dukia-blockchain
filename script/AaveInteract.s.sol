// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console, console2} from "forge-std/Script.sol";
import {AaveInteractionDelegate} from "../src/aave/AaveInteraction.sol";
import "../src/interface/IERC20.sol";

interface IPoolAddressesProvider {
    function getPool() external view returns (address);
}

interface IPool {
    function getReservesList() external view returns (address[] memory);
}

contract AaveScript is Script {
    function run() public {
        vm.startBroadcast();
        
        // Addresses
        address poolAddressProviderAddr = 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A;
        address usdcAddr = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
        
        // Get Pool Address Provider and Pool
        IPoolAddressesProvider poolAddressProvider = IPoolAddressesProvider(poolAddressProviderAddr);
        address poolAddress = poolAddressProvider.getPool();
        IPool pool = IPool(poolAddress);
        
        // Diagnostic Logs
        console.log("Pool Address Provider:", poolAddressProviderAddr);
        console.log("Pool Address:", poolAddress);
        console.log("USDC Address:", usdcAddr);
        
        // Check token details
        IERC20 usdc = IERC20(usdcAddr);
        
        // Delegate Deployment
        AaveInteractionDelegate hack = new AaveInteractionDelegate(poolAddressProviderAddr);
        
     
        
        // Token balance
        try usdc.balanceOf(msg.sender) returns (uint256 balance) {
            console.log("USDC Balance:", balance);
        } catch {
            console.log("Unable to get USDC balance");
        }
        
        // List Reserves
        try pool.getReservesList() returns (address[] memory reserves) {
            console.log("Total Reserves:", reserves.length);
            for(uint i = 0; i < reserves.length; i++) {
                console.log("Reserve", i, ":", reserves[i]);
            }
        } catch {
            console.log("Unable to get reserves list");
        }
        
        // Approve and attempt supply
        usdc.approve(address(hack), 5 * 10 ** 6);
        
        try hack.supply(usdcAddr, 5 * 10 ** 6) {
            console.log("Supply Attempt Successful");
        } catch Error(string memory reason) {
            console.log("Supply Error:", reason);
        } catch (bytes memory /*lowLevelData*/) {
            console.log("Unknown Supply Error");
        }
        
        vm.stopBroadcast();
    }
}



// // import {Script, console, console2} from "forge-std/Script.sol";
// import {AaveInteractionDelegate} from "../src/aave/AaveInteraction.sol";
// import "../src/interface/IERC20.sol";

// contract AaveScript is Script {
//     function run() public {
//         vm.startBroadcast();
        
//         // Addresses
//         address poolAddressProviderAddr = 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A;
//         address daiAddr = 0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357;
//         address linkAddr = 0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5;
        
//         // Create interaction delegate
//         AaveInteractionDelegate hack = new AaveInteractionDelegate(poolAddressProviderAddr);
        
//         // Token interfaces
//         IERC20 dai = IERC20(daiAddr);
//         IERC20 link = IERC20(linkAddr);
        
//         // Diagnostic logs
//         console.log("DAI Balance:", dai.balanceOf(msg.sender));
        
//         // Approve DAI
//         dai.approve(address(hack), 5 ether);
        
//         // Supply DAI
//         try hack.supply(daiAddr, 5 ether) {
//             console.log("DAI Supply Successful");
//         } catch Error(string memory reason) {
//             console.log("Supply Error:", reason);
//         } catch (bytes memory /*lowLevelData*/) {
//             console.log("Unknown Supply Error");
//         }
        
//         // Borrow LINK
//         try hack.borrow(linkAddr, 1 ether, 2) {
//             console.log("LINK Borrow Successful");
//         } catch Error(string memory reason) {
//             console.log("Borrow Error:", reason);
//         } catch (bytes memory /*lowLevelData*/) {
//             console.log("Unknown Borrow Error");
//         }
        
//         vm.stopBroadcast();
//     }
// }
