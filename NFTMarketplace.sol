// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC2981 {
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

/**
 * @title NFTMarketplace
 * @dev Marketplace for buying and selling ERC721 NFTs
 */
contract NFTMarketplace is ReentrancyGuard, Pausable, Ownable {
    
    // Marketplace fee in basis points (e.g., 250 = 2.5%)
    uint256 public marketplaceFee = 250;
    
    // Listing structure
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool isActive;
        uint256 createdAt;
        uint256 expiresAt;
    }
    
    // Offer structure
    struct Offer {
        address bidder;
        uint256 amount;
        bool isActive;
        uint256 createdAt;
        uint256 expiresAt;
    }
    
    // Listing counter
    uint256 public listingCounter;
    
    // Mappings
    mapping(uint256 => Listing) public listings;
    mapping(address => mapping(uint256 => mapping(uint256 => Offer))) public offers;
    mapping(address => mapping(uint256 => uint256[])) public offerIds;
    mapping(address => uint256) public escrowBalance;
    
    // Events
    event ListingCreated(
        uint256 indexed listingId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 timestamp
    );
    
    event ListingCanceled(uint256 indexed listingId);
    
    event ListingUpdated(
        uint256 indexed listingId,
        uint256 newPrice,
        uint256 timestamp
    );
    
    event NFTPurchased(
        uint256 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 price,
        uint256 timestamp
    );
    
    event OfferMade(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 amount,
        uint256 timestamp
    );
    
    event OfferAccepted(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 amount,
        uint256 timestamp
    );
    
    event OfferCanceled(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed bidder
    );
    
    event MarketplaceFeeUpdated(uint256 newFee);
    
    event FundsWithdrawn(address indexed user, uint256 amount);
    
    /**
     * @dev List an NFT for sale
     */
    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 expirationTime
    ) external nonReentrant returns (uint256) {
        require(price > 0, "Price must be greater than 0");
        require(expirationTime > block.timestamp, "Expiration must be in future");
        
        // Verify NFT ownership and approval
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Must own the NFT");
        require(
            nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );
        
        uint256 listingId = listingCounter++;
        
        listings[listingId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            isActive: true,
            createdAt: block.timestamp,
            expiresAt: expirationTime
        });
        
        emit ListingCreated(
            listingId,
            msg.sender,
            nftContract,
            tokenId,
            price,
            block.timestamp
        );
        
        return listingId;
    }
    
    /**
     * @dev Cancel an active listing
     */
    function cancelListing(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is not active");
        require(listing.seller == msg.sender, "Only seller can cancel");
        
        listing.isActive = false;
        emit ListingCanceled(listingId);
    }
    
    /**
     * @dev Update listing price
     */
    function updateListing(uint256 listingId, uint256 newPrice)
        external
        nonReentrant
    {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is not active");
        require(listing.seller == msg.sender, "Only seller can update");
        require(newPrice > 0, "Price must be greater than 0");
        
        listing.price = newPrice;
        emit ListingUpdated(listingId, newPrice, block.timestamp);
    }
    
    /**
     * @dev Purchase an NFT from a listing
     */
    function buyNFT(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is not active");
        require(block.timestamp <= listing.expiresAt, "Listing expired");
        require(msg.value == listing.price, "Incorrect payment amount");
        
        // Calculate fees
        uint256 feeAmount = (listing.price * marketplaceFee) / 10000;
        uint256 sellerAmount = listing.price - feeAmount;
        
        // Handle royalties
        (uint256 royaltyAmount, address royaltyReceiver) = 
            _getRoyaltyInfo(listing.nftContract, listing.tokenId, listing.price);
        
        if (royaltyAmount > 0) {
            sellerAmount -= royaltyAmount;
        }
        
        // Mark listing as inactive
        listing.isActive = false;
        
        // Transfer NFT to buyer
        IERC721(listing.nftContract).safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );
        
        // Transfer payments
        escrowBalance[listing.seller] += sellerAmount;
        escrowBalance[owner()] += feeAmount;
        
        if (royaltyAmount > 0 && royaltyReceiver != address(0)) {
            escrowBalance[royaltyReceiver] += royaltyAmount;
        }
        
        emit NFTPurchased(
            listingId,
            msg.sender,
            listing.seller,
            listing.price,
            block.timestamp
        );
    }
    
    /**
     * @dev Make an offer on an NFT
     */
    function makeOffer(
        address nftContract,
        uint256 tokenId,
        uint256 expirationTime
    ) external payable nonReentrant {
        require(msg.value > 0, "Offer amount must be greater than 0");
        require(expirationTime > block.timestamp, "Expiration must be in future");
        
        uint256 offerId = offerIds[nftContract][tokenId].length;
        
        offers[nftContract][tokenId][offerId] = Offer({
            bidder: msg.sender,
            amount: msg.value,
            isActive: true,
            createdAt: block.timestamp,
            expiresAt: expirationTime
        });
        
        offerIds[nftContract][tokenId].push(offerId);
        escrowBalance[msg.sender] -= msg.value;
        
        emit OfferMade(nftContract, tokenId, msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @dev Accept an offer
     */
    function acceptOffer(
        address nftContract,
        uint256 tokenId,
        uint256 offerId
    ) external nonReentrant {
        require(
            IERC721(nftContract).ownerOf(tokenId) == msg.sender,
            "Must own the NFT"
        );
        
        Offer storage offer = offers[nftContract][tokenId][offerId];
        require(offer.isActive, "Offer is not active");
        require(block.timestamp <= offer.expiresAt, "Offer expired");
        
        offer.isActive = false;
        
        uint256 feeAmount = (offer.amount * marketplaceFee) / 10000;
        uint256 sellerAmount = offer.amount - feeAmount;
        
        // Handle royalties
        (uint256 royaltyAmount, address royaltyReceiver) = 
            _getRoyaltyInfo(nftContract, tokenId, offer.amount);
        
        if (royaltyAmount > 0) {
            sellerAmount -= royaltyAmount;
        }
        
        // Transfer NFT
        IERC721(nftContract).safeTransferFrom(
            msg.sender,
            offer.bidder,
            tokenId
        );
        
        // Transfer payments
        escrowBalance[msg.sender] += sellerAmount;
        escrowBalance[owner()] += feeAmount;
        
        if (royaltyAmount > 0 && royaltyReceiver != address(0)) {
            escrowBalance[royaltyReceiver] += royaltyAmount;
        }
        
        emit OfferAccepted(nftContract, tokenId, offer.bidder, offer.amount, block.timestamp);
    }
    
    /**
     * @dev Cancel an offer
     */
    function cancelOffer(
        address nftContract,
        uint256 tokenId,
        uint256 offerId
    ) external nonReentrant {
        Offer storage offer = offers[nftContract][tokenId][offerId];
        require(offer.bidder == msg.sender, "Only bidder can cancel");
        require(offer.isActive, "Offer is not active");
        
        offer.isActive = false;
        escrowBalance[msg.sender] += offer.amount;
        
        emit OfferCanceled(nftContract, tokenId, msg.sender);
    }
    
    /**
     * @dev Withdraw funds from escrow
     */
    function withdrawFunds() external nonReentrant {
        uint256 amount = escrowBalance[msg.sender];
        require(amount > 0, "No funds to withdraw");
        
        escrowBalance[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit FundsWithdrawn(msg.sender, amount);
    }
    
    /**
     * @dev Get listing details
     */
    function getListing(uint256 listingId)
        external
        view
        returns (Listing memory)
    {
        return listings[listingId];
    }
    
    /**
     * @dev Get offer details
     */
    function getOffer(
        address nftContract,
        uint256 tokenId,
        uint256 offerId
    ) external view returns (Offer memory) {
        return offers[nftContract][tokenId][offerId];
    }
    
    /**
     * @dev Internal function to get royalty info
     */
    function _getRoyaltyInfo(
        address nftContract,
        uint256 tokenId,
        uint256 salePrice
    ) internal view returns (uint256, address) {
        try IERC2981(nftContract).royaltyInfo(tokenId, salePrice) returns (
            address receiver,
            uint256 royaltyAmount
        ) {
            return (royaltyAmount, receiver);
        } catch {
            return (0, address(0));
        }
    }
    
    /**
     * @dev Set marketplace fee
     */
    function setMarketplaceFee(uint256 newFee) external onlyOwner {
        require(newFee <= 5000, "Fee cannot exceed 50%");
        marketplaceFee = newFee;
        emit MarketplaceFeeUpdated(newFee);
    }
    
    /**
     * @dev Pause/unpause marketplace
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Emergency withdrawal by owner
     */
    function emergencyWithdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
    
    // Allow contract to receive ETH
    receive() external payable {}
}
