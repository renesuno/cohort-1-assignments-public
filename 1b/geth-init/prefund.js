// Prefund accounts with known private keys
const from = eth.accounts[0];

// List of accounts to prefund
const accountsToPrefund = [
  "0x556CA0FD74b31B9a2B38aB3f93a07341282e7b0f", // contract deployer
];

// Prefund each account with 100 ETH
accountsToPrefund.forEach(function(account) {
  console.log("Prefunding account: " + account);
  eth.sendTransaction({
    from: from,
    to: account,
    value: web3.toWei(100, "ether"),
  });
});

console.log("Prefunding complete!");
