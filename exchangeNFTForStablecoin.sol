pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract NFTExchange is Ownable, Pausable {
    using SafeERC20 for IERC20; // import SafeERC20 library for safe ERC20 transfers

    // Define private variables for the NFT and USDT contracts
    IERC721 private immutable _nftContract;
    IERC20 private immutable _usdtContract;

    constructor(address nftContractAddress, address usdtContractAddress) {
        _nftContract = IERC721(nftContractAddress);
        _usdtContract = IERC20(usdtContractAddress);
    }

    // Exchange an NFT for USDT
    function exchangeNFTForUSDT(uint256 tokenId) public whenNotPaused {
        // Get the denomination of the NFT from the NFT contract
        uint256 denomination = USDNFT(address(_nftContract)).getDenomination(tokenId);

        // Transfer the NFT from the user to the contract
        _nftContract.safeTransferFrom(msg.sender, address(this), tokenId);

        // Burn the NFT
        _nftContract.burn(tokenId);

        // Transfer USDT to the user
        _usdtContract.safeTransfer(msg.sender, denomination);
    }

    // Deposit USDT into the contract
    function depositUSDT(uint256 amount) public onlyOwner {
        // Transfer USDT from the owner to the contract
        _usdtContract.safeTransferFrom(msg.sender, address(this), amount);
    }

    // Withdraw USDT from the contract
    function withdrawUSDT(uint256 amount) public onlyOwner {
        // Transfer USDT from the contract to the owner
        _usdtContract.safeTransfer(msg.sender, amount);
    }

    // Upgrade the NFT and/or USDT contract
    function upgradeContract(address newNftContractAddress, address newUsdtContractAddress) public onlyOwner {
        // If a new NFT contract address is provided, update the NFT contract
        if (newNftContractAddress != address(0)) {
            _nftContract = IERC721(newNftContractAddress);
        }

        // If a new USDT contract address is provided, update the USDT contract
        if (newUsdtContractAddress != address(0)) {
            _usdtContract = IERC20(newUsdtContractAddress);
        }
    }

    // Pause the contract
    function pause() public onlyOwner {
        _pause();
    }

    // Unpause the contract
    function unpause() public onlyOwner {
        _unpause();
    }
} 
