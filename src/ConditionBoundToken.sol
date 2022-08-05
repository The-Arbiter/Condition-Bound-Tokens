// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/// @author 0xArbiter

contract ConditionBoundToken is ERC721, Ownable{

    // Set up 721
    constructor(string memory name_, string memory symbol_) ERC721("ConditionBoundToken", "CBT") {}
    
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  CONDITION BOUND TOKENS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Custom CBT error for if users try to transfer
    error TokenIsBound();

    // Struct for binding aux info
    /// @dev You can make the bool a bit if you want
    struct bindingMetadata {
        bool isConditionBound;
        bytes31 aux;
    }

    // Mapping of token IDs to whether they are ConditionBound or not
    mapping (uint256 => bindingMetadata) Bindings;

    // Get aux bytes
    function getTokenAux(uint256 tokenId_) view public returns(bytes31 tokenAux){
        tokenAux = Bindings[tokenId_].aux;
    }

    // Set aux bytes
    function getTokenAux(uint256 tokenId_, bytes31 tokenAux_) public returns(bool status){
        Bindings[tokenId_].aux = tokenAux_;
        status = true;
    }

    /// @notice Prevent ConditionBound transfers
    function checkConditionBound(uint256 tokenId_) internal view {
        
        /** 
            @dev Here is where you can add gamification conditions 
            For example you can check the aux and that might store
            time information which you compare against block timestamp.

            Or you could use difficulty or something and have tokens that
            become ConditionBound if the merge happens.
         */

         // Revert if token is ConditionBound
        if (Bindings[tokenId_].isConditionBound){
            revert TokenIsBound();
        }
    }

    /// @notice Override OZ's _beforeTokenTransfer to prevent sending tokens if conditions aren't right
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        checkConditionBound(tokenId);
    }

    /// @notice Bind a token (only owner in this base)
    function bindToken(uint256 tokenId_) external onlyOwner returns(bool status){
        Bindings[tokenId_].isConditionBound = true;
        status = true;
    }

    /// @notice Release binding of a token (only owner in this base)
    function releaseToken(uint256 tokenId_) external onlyOwner returns(bool status){
        Bindings[tokenId_].isConditionBound = false;
        status = true;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    NORMAL TOKEN STUFF                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    
    error MintIsOver();
    error InsufficientEther();

    uint256 public totalSupply = 0;
    uint256 constant MAX_SUPPLY = 10_000;
    uint256 constant MINT_PRICE = 0.0 ether;

    string baseURI = "www.miladymaker.net/";

    /// @notice Mint a token to the given address
    function safeMint(address to) public payable {
        // Check they paid enough
        if(msg.value!=MINT_PRICE){
            revert InsufficientEther();
        }
        // Check mint is not over
        if(totalSupply+1>MAX_SUPPLY){
            revert MintIsOver();
        }
        // Mint token
        _safeMint(to, totalSupply);
        ++totalSupply;
    }

    /// @notice Burn the given token
    function burn(uint256 id) public payable {
        _burn(id);
        //--totalSupply; Don't do this in this case or it'll let you mint again
    }

    /// @notice Get baseURI
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /// @notice Changes baseURI
    function changeBaseURI(string calldata baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }




   


}
