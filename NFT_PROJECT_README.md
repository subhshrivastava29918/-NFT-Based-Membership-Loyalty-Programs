# Full-Stack NFT Marketplace Project

A complete, production-ready NFT marketplace with React frontend, Node.js backend, and Solidity smart contracts.

## Project Structure

```
nft-marketplace/
├── frontend/                 # React + Web3.js UI
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── contracts/
│   │   └── App.jsx
│   └── package.json
├── backend/                  # Node.js + Express API
│   ├── src/
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── middleware/
│   │   └── server.js
│   └── package.json
├── contracts/                # Solidity Smart Contracts
│   ├── NFTMarketplace.sol
│   ├── NFTToken.sol
│   └── hardhat.config.js
└── README.md
```

## Tech Stack

### Frontend
- **React 18** - UI Framework
- **Web3.js** - Blockchain interaction
- **Axios** - HTTP client
- **TailwindCSS** - Styling
- **Vite** - Build tool

### Backend
- **Node.js + Express** - Server framework
- **MongoDB** - Database
- **JWT** - Authentication
- **Ethers.js** - Smart contract interaction
- **IPFS** - Decentralized storage

### Smart Contracts
- **Solidity 0.8.x** - Contract language
- **Hardhat** - Development environment
- **OpenZeppelin** - Standard libraries

## Features

- ✅ User authentication with Web3 wallets
- ✅ Create and mint NFTs
- ✅ Buy/Sell NFTs on marketplace
- ✅ View NFT collections
- ✅ Real-time price updates
- ✅ User profiles and portfolios
- ✅ IPFS metadata storage
- ✅ Transaction history
- ✅ Admin dashboard
- ✅ Search and filter NFTs

## Setup Instructions

### Prerequisites
- Node.js 16+
- npm or yarn
- MetaMask or compatible Web3 wallet
- MongoDB instance
- IPFS node (or Pinata account)

### 1. Frontend Setup

```bash
cd frontend
npm install
cp .env.example .env.local
# Edit .env.local with your configuration
npm run dev
```

### 2. Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration
npm start
```

### 3. Smart Contracts Setup

```bash
cd contracts
npm install
npx hardhat compile
npx hardhat deploy --network goerli
# Copy contract addresses to frontend .env
```

## Environment Variables

### Frontend (.env.local)
```
VITE_API_URL=http://localhost:5000
VITE_CONTRACT_ADDRESS=0x...
VITE_NETWORK_ID=5
VITE_INFURA_KEY=your_infura_key
VITE_IPFS_GATEWAY=https://gateway.pinata.cloud
```

### Backend (.env)
```
PORT=5000
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your_secret_key
ETHERSCAN_API_KEY=your_key
CONTRACT_ADDRESS=0x...
PRIVATE_KEY=your_private_key
PINATA_API_KEY=your_key
PINATA_SECRET=your_secret
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - Web3 wallet authentication
- `POST /api/auth/logout` - Logout
- `GET /api/auth/verify` - Verify token

### NFTs
- `GET /api/nfts` - Get all NFTs
- `GET /api/nfts/:id` - Get single NFT
- `POST /api/nfts/create` - Create NFT (auth required)
- `PUT /api/nfts/:id` - Update NFT
- `DELETE /api/nfts/:id` - Delete NFT

### Marketplace
- `GET /api/marketplace/listings` - Active listings
- `POST /api/marketplace/buy` - Purchase NFT
- `POST /api/marketplace/sell` - List NFT for sale
- `GET /api/marketplace/offers/:id` - View offers

### Users
- `GET /api/users/:address` - User profile
- `GET /api/users/:address/nfts` - User's NFTs
- `GET /api/users/:address/portfolio` - Portfolio stats

## Smart Contract Functions

### NFTToken (ERC721)
```solidity
- mint(address to, string uri) - Create new NFT
- burn(uint256 tokenId) - Destroy NFT
- transferFrom(address from, address to, uint256 tokenId)
- approve(address to, uint256 tokenId)
```

### NFTMarketplace
```solidity
- listNFT(address nftAddress, uint256 tokenId, uint256 price)
- buyNFT(address nftAddress, uint256 tokenId)
- cancelListing(address nftAddress, uint256 tokenId)
- makeOffer(address nftAddress, uint256 tokenId, uint256 amount)
- acceptOffer(address nftAddress, uint256 tokenId, address bidder)
```

## Testing

```bash
# Frontend tests
cd frontend
npm run test

# Backend tests
cd backend
npm run test

# Contract tests
cd contracts
npx hardhat test
```

## Deployment

### Frontend (Vercel)
```bash
cd frontend
npm install -g vercel
vercel
```

### Backend (Heroku)
```bash
cd backend
heroku create your-app-name
git push heroku main
```

### Contracts (Ethereum Mainnet)
```bash
cd contracts
npx hardhat run scripts/deploy.js --network mainnet
```

## Security Considerations

- 🔒 Private keys stored in .env (never commit)
- 🔒 JWT tokens for API authentication
- 🔒 Rate limiting on sensitive endpoints
- 🔒 Input validation and sanitization
- 🔒 HTTPS enforced in production
- 🔒 Contract audited (recommended)
- 🔒 OpenZeppelin standard implementations

## Performance Optimizations

- Caching with Redis
- Lazy loading images
- Code splitting in React
- Database indexing
- CDN for static assets
- Pagination on list endpoints
- Web3 provider pooling

## Troubleshooting

### MetaMask Connection Issues
- Ensure network matches contract deployment
- Clear MetaMask cache
- Verify contract address in .env

### IPFS Upload Failures
- Check Pinata API keys
- Ensure file size < 100MB
- Verify network connectivity

### Contract Deployment Errors
- Check sufficient gas funds
- Verify network configuration
- Review contract compilation

## Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open pull request

## License

MIT License - see LICENSE.md

## Support

- Documentation: https://docs.example.com
- Community: https://discord.gg/example
- Issues: https://github.com/example/issues

## Roadmap

- [ ] Multi-chain support (Polygon, Arbitrum)
- [ ] DAO governance
- [ ] Fractional NFTs
- [ ] Advanced analytics
- [ ] Mobile app
- [ ] OpenSea integration
