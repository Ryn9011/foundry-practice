// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); //computes address for given private key
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); //gives USER 10 ether
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log(version);
        // uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //next line should revert
        fundMe.fund();
    }

    function testFundUpdatesDataStrucure() public funded {
        uint256 amoundFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amoundFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funderAddress = fundMe.getFunder(0);
        assertEq(funderAddress, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); //expects the next line to revert but will ignore vm stuff and so looks at withdraw line
        fundMe.withdraw();
    }

    function testWithdraWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();
        // Act
        uint256 gasStart = gasleft(); //gas left is built in solidity function. tells you have much gas is left in the transaction call.
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //default solidty function
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = fundMe.getBalance();

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawalFromMultipleFunders() public funded {
        // Arrange    
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(user);
            // vm.deal(user, STARTING_BALANCE);
            // hoax is a standard cheat code that combines prank and deal
            // address(number) generates an address from a number.
            // starts at 1 because good idea not to use 0 as can cause issues
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // Assert        
        // assertEq(startingFundMeBalance, 0);
        console.log(startingOwnerBalance);
        console.log(startingFundMeBalance);
        console.log(fundMe.getOwner().balance);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawalFromMultipleFundersCheaper() public funded {
        // Arrange    
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(user);
            // vm.deal(user, STARTING_BALANCE);
            // hoax is a standard cheat code that combines prank and deal
            // address(number) generates an address from a number.
            // starts at 1 because good idea not to use 0 as can cause issues
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        // Assert        
        // assertEq(startingFundMeBalance, 0);
        console.log(startingOwnerBalance);
        console.log(startingFundMeBalance);
        console.log(fundMe.getOwner().balance);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
