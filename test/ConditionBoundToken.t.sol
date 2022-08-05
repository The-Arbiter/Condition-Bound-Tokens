// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ConditionBoundToken} from "src/ConditionBoundToken.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

import "forge-std/Test.sol";

contract ConditionBoundTokenTest is Test, IERC721Receiver{
    
    ConditionBoundToken conditionBound;

    function setUp() public {
        conditionBound = new ConditionBoundToken("ConditionBoundToken", "CBT");
    }

    // Allow the contract to receive ERC721 for testing
    function onERC721Received(address, address, uint256, bytes calldata) public pure override returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    function fuzzingRestrictions(address someAddress) internal{
        vm.assume(someAddress != address(0));
        vm.assume(someAddress != address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
        vm.assume(someAddress != address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        vm.assume(someAddress != address(0x4e59b44847b379578588920cA78FbF26c0B4956C));
    }

    // Test CBT can mint
    function testMintTokens(address tokenOwner_ ) public{
        fuzzingRestrictions(tokenOwner_);

        // Check old balance
        uint256 existingBalance = conditionBound.balanceOf(tokenOwner_);
        conditionBound.safeMint{value:0}(tokenOwner_);
        uint256 newBalance = conditionBound.balanceOf(tokenOwner_);

        // Check that our token balance increased by 1
        if(newBalance - existingBalance != 1){
            revert("No tokens were sent to the test contract.");
        }
    }

    // Test CBT can set
    function testConditionBoundFunctionality(address tokenOwner_ , address tokenRecipient_) public{

        fuzzingRestrictions(tokenRecipient_);
        vm.assume(tokenOwner_!=tokenRecipient_);

        // Mint tokens using the above test
        this.testMintTokens(tokenOwner_);
        
        uint256 new_id = conditionBound.totalSupply() - 1;

        // Prank as owner
        vm.prank(conditionBound.owner());
        // CB the 0th token
        conditionBound.bindToken(new_id);

        
        // Expect revert and try and send it
        vm.prank(tokenOwner_);
        conditionBound.approve(address(tokenRecipient_), new_id);

        // Expect revert with `TokenIsSoulbound()` error type
        vm.expectRevert(abi.encodeWithSignature("TokenIsBound()"));
        vm.prank(tokenOwner_);
        conditionBound.transferFrom(tokenOwner_, tokenRecipient_, new_id);

        vm.prank(conditionBound.owner());
        conditionBound.releaseToken(new_id);

        vm.prank(tokenOwner_);
        conditionBound.transferFrom(tokenOwner_, tokenRecipient_, new_id);
        if(conditionBound.ownerOf(new_id)!=tokenRecipient_){
            revert("Ownership didnt change");
        }

    }

}