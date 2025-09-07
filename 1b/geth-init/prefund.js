const from = eth.accounts[0];
const contractDeployer = "0x556CA0FD74b31B9a2B38aB3f93a07341282e7b0f";
eth.sendTransaction({
  from: from,
  to: contractDeployer,
  value: web3.toWei(100, "ether"),
});
