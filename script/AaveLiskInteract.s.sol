// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console, console2} from "forge-std/Script.sol";
import {AaveLisk} from "../src/AaveLisk.sol";
import "../src/interface/IERC20.sol";

contract AaveLiskInteract is Script {
    IERC20 dai = IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357);
    IERC20 link = IERC20(0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5);
    address userAddr = msg.sender;
    uint32 chainId = 11155111;

    function run() public {
        vm.startBroadcast();
        AaveLisk aavelisk = new AaveLisk();

        aavelisk.approveAndSupply(userAddr, chainId, address(dai), 1 ether);

        aavelisk.approveAndBorrow(userAddr, chainId, address(link), 1 ether, 2);

        aavelisk.repay(address(link), 1 ether, 2, userAddr);

        aavelisk.approveAndWithdraw(userAddr, chainId, address(this), address(dai), 1 ether);
        vm.stopBroadcast();
    }
}
