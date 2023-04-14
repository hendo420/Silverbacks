// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Inherit from ERC721URIStorage and IERC721Metadata for metadata and tokenURI handling
// Inherit from Ownable to restrict certain functions to the contract owner
contract USDNFT is ERC721URIStorage, IERC721Metadata, Ownable {
    // Import the Counter library from OpenZeppelin for managing token IDs
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Mapping to store NFT denominations, where key is the token ID and value is the denomination
    mapping(uint256 => uint256) private _denominations;

    constructor() ERC721("USDNFT", "USD") {
        // Explicitly initialize the _tokenIdCounter to 0
        _tokenIdCounter = Counters.Counter(0);
    }

    // Function to mint new NFTs, only callable by the contract owner
    function mint(address to, uint256 denomination, string memory tokenURI) public onlyOwner {
        // Increment the token ID counter
        _tokenIdCounter.increment();

        // Get the current token ID value
        uint256 tokenId = _tokenIdCounter.current();

        // Call the internal _safeMint function to mint the NFT to the recipient's address
        _safeMint(to, tokenId);

        // Set the tokenURI for the newly minted NFT
        _setTokenURI(tokenId, tokenURI);

        // Store the denomination value for the newly minted NFT
        _denominations[tokenId] = denomination;
    }

    // Function to get the denomination of a specific NFT using its token ID
    function getDenomination(uint256 tokenId) public view returns (uint256) {
        return _denominations[tokenId];
    }
}
