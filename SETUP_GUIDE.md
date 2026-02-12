# Complete NFT Marketplace Setup Guide

## Prerequisites

Before starting, ensure you have:

- **Node.js** (v16+): https://nodejs.org/
- **npm** (v8+): Comes with Node.js
- **Git**: https://git-scm.com/
- **MetaMask**: https://metamask.io/
- **MongoDB**: https://www.mongodb.com/
- **Hardhat**: Smart contract development
- **Pinata Account**: https://www.pinata.cloud/ (for IPFS)

## Step-by-Step Installation

### 1. Clone and Setup Project Structure

```bash
# Create project directory
mkdir nft-marketplace
cd nft-marketplace

# Create subdirectories
mkdir frontend backend contracts
```

### 2. Frontend Setup

```bash
cd frontend

# Initialize React project with Vite
npm create vite@latest . -- --template react

# Install dependencies
npm install

# Copy environment file
cp .env.example .env.local

# Update .env.local with your configuration
# - VITE_API_URL=http://localhost:5000
# - VITE_CONTRACT_ADDRESS=your_contract_address
# - VITE_INFURA_KEY=your_infura_key
```

**Frontend Dependencies:**
```bash
npm install web3 ethers axios react-router-dom
npm install -D tailwindcss postcss autoprefixer
npm install ipfs-http-client

# Initialize Tailwind
npx tailwindcss init -p
```

**Run Frontend:**
```bash
npm run dev
# Opens at http://localhost:5173
```

### 3. Backend Setup

```bash
cd ../backend

# Initialize Node project
npm init -y

# Install dependencies
npm install express cors dotenv mongoose jsonwebtoken bcryptjs ethers axios multer helmet express-validator
npm install -D nodemon jest eslint

# Create directory structure
mkdir -p src/{routes,controllers,models,middleware}
mkdir logs

# Copy environment file
cp .env.example .env

# Update .env with your configuration
# - MONGODB_URI=mongodb+srv://...
# - JWT_SECRET=your_secret_key
# - CONTRACT_ADDRESS=your_contract_address
```

**Run Backend:**
```bash
npm start
# Server runs on http://localhost:5000
```

### 4. Smart Contracts Setup

```bash
cd ../contracts

# Initialize Hardhat project
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat init

# Install OpenZeppelin contracts
npm install @openzeppelin/contracts

# Copy configuration
cp hardhat.config.example.js hardhat.config.js
```

**Compile Contracts:**
```bash
npx hardhat compile
```

**Deploy Contracts:**
```bash
# Deploy to Goerli testnet (requires GOERLI_RPC_URL and PRIVATE_KEY in .env)
npx hardhat run scripts/deploy.js --network goerli

# Save the returned contract addresses!
```

### 5. Database Setup (MongoDB)

#### Option A: Local MongoDB

```bash
# Install MongoDB Community
# Mac:
brew tap mongodb/brew
brew install mongodb-community

# Linux:
sudo apt-get install -y mongodb

# Start MongoDB
brew services start mongodb-community
# or
sudo systemctl start mongod
```

#### Option B: MongoDB Atlas (Recommended)

1. Go to https://www.mongodb.com/cloud/atlas
2. Create free account
3. Create a cluster
4. Create database user
5. Get connection string
6. Update `MONGODB_URI` in backend `.env`

```
mongodb+srv://username:password@cluster.mongodb.net/nft-marketplace?retryWrites=true&w=majority
```

### 6. Configuration Files

#### Frontend .env.local

```env
VITE_API_URL=http://localhost:5000
VITE_CONTRACT_ADDRESS=0x...
VITE_MARKETPLACE_ADDRESS=0x...
VITE_NETWORK_ID=5
VITE_INFURA_KEY=your_key
VITE_PINATA_API_KEY=your_key
```

#### Backend .env

```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your_secret_key
CONTRACT_ADDRESS=0x...
MARKETPLACE_ADDRESS=0x...
PINATA_API_KEY=your_key
PRIVATE_KEY=your_private_key
```

### 7. Testnet Setup

#### Using Goerli Testnet

1. **Get Test ETH:**
   - Visit https://goerlifaucet.com
   - Enter your MetaMask address
   - Receive 1 test ETH

2. **Get Infura Key:**
   - Sign up at https://infura.io
   - Create project
   - Copy Goerli endpoint: `https://goerli.infura.io/v3/YOUR_PROJECT_ID`

3. **Configure MetaMask:**
   - Open MetaMask
   - Add network:
     - Name: Goerli
     - RPC: `https://goerli.infura.io/v3/YOUR_PROJECT_ID`
     - Chain ID: `5`
     - Currency: ETH

### 8. Deploy Smart Contracts

```bash
cd contracts

# Set environment variables
export PRIVATE_KEY=your_wallet_private_key
export GOERLI_RPC_URL=https://goerli.infura.io/v3/your_key

# Deploy
npx hardhat run scripts/deploy.js --network goerli

# Save contract addresses - you'll need these!
```

### 9. IPFS Setup (Pinata)

1. Visit https://www.pinata.cloud
2. Sign up for free account
3. Go to API Keys section
4. Create new API key
5. Copy key and secret to `.env` files

### 10. Start the Application

```bash
# Terminal 1 - Backend
cd backend
npm start

# Terminal 2 - Frontend
cd frontend
npm run dev

# Terminal 3 - IPFS (Optional)
cd contracts
npx hardhat node  # For local testing

# Open browser
# http://localhost:5173
```

## Verification Checklist

- [ ] MetaMask installed and connected to Goerli
- [ ] Test ETH in wallet (0.5+ ETH recommended)
- [ ] MongoDB running and connection working
- [ ] Smart contracts deployed (saved addresses)
- [ ] Environment variables configured in both frontend and backend
- [ ] Pinata API keys added
- [ ] Backend running on port 5000
- [ ] Frontend running on port 5173
- [ ] Able to connect wallet from UI

## Common Issues and Solutions

### MetaMask Connection Fails

```
Solution:
1. Clear MetaMask cache: Settings > Advanced > Clear cache
2. Make sure you're on Goerli testnet
3. Reload the page
4. Check browser console for errors
```

### Contract Deployment Fails

```
Solution:
1. Check you have sufficient test ETH
2. Verify RPC URL is correct
3. Check contract syntax: npx hardhat compile
4. Verify network configuration in hardhat.config.js
```

### MongoDB Connection Error

```
Solution:
1. Verify MongoDB is running: mongosh
2. Check connection string in .env
3. Verify database user credentials
4. Check network access in MongoDB Atlas (if using cloud)
```

### IPFS Upload Fails

```
Solution:
1. Verify Pinata API keys
2. Check file size < 100MB
3. Verify network connectivity
4. Check Pinata service status
```

## Testing the Application

### Manual Testing Flow

1. **Connect Wallet**
   - Click "Connect Wallet"
   - Approve in MetaMask
   - Verify address shown

2. **Create NFT**
   - Go to Create page
   - Upload image
   - Fill metadata
   - Mint NFT
   - Confirm transaction in MetaMask

3. **List NFT**
   - Go to Profile
   - Select NFT
   - Click "List for Sale"
   - Set price
   - Approve marketplace

4. **Buy NFT**
   - Go to Explore
   - Find NFT
   - Click "Buy Now"
   - Confirm transaction

## Performance Optimization

### Frontend
- Enable lazy loading: `React.lazy()`
- Code splitting with routes
- Image optimization with IPFS
- Caching with service workers

### Backend
- Database indexing on frequently queried fields
- Redis caching for popular NFTs
- Pagination on all list endpoints
- Rate limiting on sensitive endpoints

### Smart Contracts
- Optimize gas usage
- Use proper data types (uint256 vs uint8)
- Batch operations where possible

## Security Best Practices

1. **Private Keys**
   - Never commit `.env` files
   - Use environment variables
   - Rotate keys regularly
   - Use hardware wallet for mainnet

2. **Smart Contracts**
   - Use OpenZeppelin audited contracts
   - Implement reentrancy guards
   - Pause mechanism for emergency
   - Rate limiting

3. **Backend**
   - Input validation
   - HTTPS in production
   - CORS properly configured
   - JWT token expiration
   - SQL injection prevention

4. **Frontend**
   - Validate user input
   - CSRF protection
   - XSS prevention
   - Content Security Policy

## Production Deployment

### Frontend (Vercel)

```bash
cd frontend
npm install -g vercel
vercel
# Follow prompts
```

### Backend (Heroku)

```bash
cd backend
npm install -g heroku
heroku login
heroku create your-app-name
git push heroku main
```

### Smart Contracts (Mainnet)

```bash
export MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
npx hardhat run scripts/deploy.js --network mainnet
```

## Monitoring and Maintenance

1. **Logging**: Check logs in `backend/logs/`
2. **Database**: Monitor MongoDB performance
3. **Blockchain**: Track gas prices and network congestion
4. **Errors**: Use Sentry for error tracking
5. **Analytics**: Implement user tracking

## Getting Help

- **Hardhat Docs**: https://hardhat.org/
- **OpenZeppelin**: https://docs.openzeppelin.com/
- **Ethers.js**: https://docs.ethers.org/
- **MongoDB**: https://docs.mongodb.com/
- **Express.js**: https://expressjs.com/

## Next Steps

1. Customize branding and UI
2. Add more features (collections, bundles, etc.)
3. Implement advanced search and filtering
4. Add social features (following, reviews)
5. Deploy to mainnet
6. Marketing and promotion

Good luck with your NFT marketplace! 🚀
