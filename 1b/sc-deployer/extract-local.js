#!/usr/bin/env node

const fs = require('fs');

// Path to the broadcast artifact
const broadcastPath = '../1a/broadcast/MiniAMM.s.sol/1337/run-latest.json';

try {
  const broadcastData = JSON.parse(fs.readFileSync(broadcastPath, 'utf8'));
  
  const deployment = {
    mock_erc_0: null,
    mock_erc_1: null,
    mini_amm: null
  };
  
  broadcastData.transactions.forEach(tx => {
    if (tx.contractName === 'MockERC20' && !deployment.mock_erc_0) {
      deployment.mock_erc_0 = tx.contractAddress;
    } else if (tx.contractName === 'MockERC20' && !deployment.mock_erc_1) {
      deployment.mock_erc_1 = tx.contractAddress;
    } else if (tx.contractName === 'MiniAMM') {
      deployment.mini_amm = tx.contractAddress;
    }
  });
  
  fs.writeFileSync('sc-deployer/deployment.json', JSON.stringify(deployment, null, 4));
  console.log('✅ Deployment addresses extracted successfully!');
  console.log(JSON.stringify(deployment, null, 2));
} catch (error) {
  console.error('❌ Error:', error.message);
  process.exit(1);
}
