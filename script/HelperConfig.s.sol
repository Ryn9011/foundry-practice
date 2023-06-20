//SPDX-License-Identifier: MIT

// 1. deploy mocks when we are on a local anvil chain
// 2. keep track of contract address accross different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
  // if we are on local anvil, we deploy mocks
  // otherwise, grab the existing address from the live network

  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e8; //2000 USD

  NetworkConfig public activeNetworkConfig;

  struct NetworkConfig {
    address priceFeed; //ETH/USD price feed address
  }

  constructor() {
    if (block.chainid == 11155111) {
      activeNetworkConfig = getSepoliaEthConfig();
    } else if (block.chainid == 1) {
      activeNetworkConfig = getMainnetEthConfig();
    } else {
      activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
  }

  function getSepoliaEthConfig() public pure returns (NetworkConfig memory sepoliaNetworkConfig) {
    sepoliaNetworkConfig = NetworkConfig({
      priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });   
  }

  function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
    NetworkConfig memory ethConfig = NetworkConfig({
      priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    }); 
    return ethConfig;
  }

  function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {     
    // we don't want to recreate if priceFeed is already set
    if (activeNetworkConfig.priceFeed != address(0)) {
      return activeNetworkConfig;
    }
    // 1. Deploy the mocks
    // 2. Return their addresses    

    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); //eth usd has 8 decimals and here is given initiap price of 2000
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
      priceFeed: address(mockPriceFeed)
    });
    return anvilConfig;
  }
}