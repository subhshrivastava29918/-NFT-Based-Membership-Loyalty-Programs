import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Web3 from 'web3';
import Navbar from './components/Navbar';
import Marketplace from './pages/Marketplace';
import CreateNFT from './pages/CreateNFT';
import Profile from './pages/Profile';
import NFTDetail from './pages/NFTDetail';
import './App.css';

function App() {
  const [account, setAccount] = useState(null);
  const [web3, setWeb3] = useState(null);
  const [isConnected, setIsConnected] = useState(false);
  const [loading, setLoading] = useState(false);

  // Initialize Web3 connection
  useEffect(() => {
    const initWeb3 = async () => {
      if (window.ethereum) {
        try {
          const web3Instance = new Web3(window.ethereum);
          setWeb3(web3Instance);
          
          // Listen for account changes
          window.ethereum.on('accountsChanged', (accounts) => {
            setAccount(accounts[0] || null);
            setIsConnected(accounts.length > 0);
          });

          // Listen for chain changes
          window.ethereum.on('chainChanged', () => {
            window.location.reload();
          });

          // Check if already connected
          const accounts = await window.ethereum.request({ 
            method: 'eth_accounts' 
          });
          if (accounts.length > 0) {
            setAccount(accounts[0]);
            setIsConnected(true);
          }
        } catch (error) {
          console.error('Web3 initialization failed:', error);
        }
      } else {
        console.error('MetaMask not found');
      }
    };

    initWeb3();
  }, []);

  // Connect wallet
  const connectWallet = async () => {
    if (!window.ethereum) {
      alert('Please install MetaMask');
      return;
    }

    try {
      setLoading(true);
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });
      setAccount(accounts[0]);
      setIsConnected(true);
    } catch (error) {
      console.error('Connection failed:', error);
      alert('Failed to connect wallet');
    } finally {
      setLoading(false);
    }
  };

  // Disconnect wallet
  const disconnectWallet = () => {
    setAccount(null);
    setIsConnected(false);
  };

  return (
    <Router>
      <div className="App">
        <Navbar 
          account={account} 
          isConnected={isConnected}
          onConnect={connectWallet}
          onDisconnect={disconnectWallet}
          loading={loading}
        />
        
        <main className="main-content">
          <Routes>
            <Route 
              path="/" 
              element={<Marketplace web3={web3} account={account} />} 
            />
            <Route 
              path="/create" 
              element={
                isConnected ? (
                  <CreateNFT web3={web3} account={account} />
                ) : (
                  <div className="auth-required">
                    <h2>Connect Your Wallet</h2>
                    <p>Please connect your wallet to create NFTs</p>
                    <button onClick={connectWallet}>Connect Wallet</button>
                  </div>
                )
              } 
            />
            <Route 
              path="/profile/:address" 
              element={<Profile web3={web3} account={account} />} 
            />
            <Route 
              path="/nft/:tokenId" 
              element={<NFTDetail web3={web3} account={account} />} 
            />
          </Routes>
        </main>

        <footer className="footer">
          <div className="footer-content">
            <p>&copy; 2024 NFT Marketplace. All rights reserved.</p>
            <div className="footer-links">
              <a href="#terms">Terms</a>
              <a href="#privacy">Privacy</a>
              <a href="#contact">Contact</a>
            </div>
          </div>
        </footer>
      </div>
    </Router>
  );
}

export default App;
