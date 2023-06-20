// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {  
  function run() external returns (FundMe) {

    // anything before a startBroadcast is not a real transaction, it's just going to be simualted in its simulated environment
    HelperConfig helperConfig = new HelperConfig();

    address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
    vm.startBroadcast();
    
    FundMe fundMe = new FundMe(ethUsdPriceFeed);
    vm.stopBroadcast();
    return fundMe;
  }
}