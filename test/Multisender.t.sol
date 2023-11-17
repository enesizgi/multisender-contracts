// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {Multisender} from "../src/Multisender.sol";
import {Standard_Token} from "../src/Standard_Token.sol";

contract MultisenderTest is Test {
    Multisender public multisender;
    Standard_Token public token;

    fallback() external payable {}
    receive() external payable {}

    function setUp() public {
        multisender = new Multisender();
        token = new Standard_Token(0, "Test Token", 18, "TTT");
    }

    function testSendERC20() public {
        token.mint(address(this), 1000);
        token.approve(address(multisender), 500);

        address[] memory recipients = new address[](2);
        recipients[0] = address(0x123);
        recipients[1] = address(0x456);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 200;
        amounts[1] = 300;

        // // Execute the sendERC20 function
        multisender.sendERC20(address(token), recipients, amounts);

        // // Assert the balances of recipients after the transaction
        assertEq(token.balanceOf(address(0x123)), 200, "Incorrect balance for recipient 0x123");
        assertEq(token.balanceOf(address(0x456)), 300, "Incorrect balance for recipient 0x456");
    }
    
    function testFail_sendERC20withoutApprove() public {
        address[] memory recipients = new address[](2);
        recipients[0] = address(0x123);
        recipients[1] = address(0x456);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 200;
        amounts[1] = 300;

        // // Execute the sendERC20 function
        multisender.sendERC20(address(token), recipients, amounts);
    }

    function testFail_sendERC20withInsufficientBalance() public {
        token.mint(address(this), 499);
        token.approve(address(multisender), 500);

        address[] memory recipients = new address[](2);
        recipients[0] = address(0x123);
        recipients[1] = address(0x456);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 200;
        amounts[1] = 300;

        // // Execute the sendERC20 function
        multisender.sendERC20(address(token), recipients, amounts);
    }

    function testSendEther() public {
        address payable[] memory recipients = new address payable[](2);
        recipients[0] = payable(address(0x123));
        recipients[1] = payable(address(0x456));

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 200;
        amounts[1] = 300;

        // // Execute the sendEther function
        multisender.sendEther{value: 500}(recipients, amounts);

        // // Assert the balances of recipients after the transaction
        assertEq(recipients[0].balance, 200, "Incorrect balance for recipient 0x123");
        assertEq(recipients[1].balance, 300, "Incorrect balance for recipient 0x456");
    }

    function testSendEtherExcessiveValue() public {
        address payable[] memory recipients = new address payable[](2);
        recipients[0] = payable(address(0x123));
        recipients[1] = payable(address(0x456));

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 200;
        amounts[1] = 300;

        // // Execute the sendEther function
        multisender.sendEther{value: 600}(recipients, amounts);

        // // Assert the balances of recipients after the transaction
        assertEq(recipients[0].balance, 200, "Incorrect balance for recipient 0x123");
        assertEq(recipients[1].balance, 300, "Incorrect balance for recipient 0x456");
    }

    function testFail_sendEtherInsufficientValue() public {
        address payable[] memory recipients = new address payable[](2);
        recipients[0] = payable(address(0x123));
        recipients[1] = payable(address(0x456));

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 200;
        amounts[1] = 300;

        // // Execute the sendEther function
        multisender.sendEther{value: 400}(recipients, amounts);
    }
}