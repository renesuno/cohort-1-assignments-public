// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {MiniAMMFactory} from "../src/MiniAMMFactory.sol";
import {MiniAMM} from "../src/MiniAMM.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract FactoryScript is Script {
    MiniAMMFactory public miniAMMFactory;
    MockERC20 public token0;
    MockERC20 public token1;
    address public pair;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast();

        // Step 1: Deploy MiniAMMFactory
        MiniAMMFactory factory = new MiniAMMFactory();
        console.log("MiniAMMFactory deployed at:", address(factory));

        // Step 2: Deploy two MockERC20 tokens
        MockERC20 tokenA = new MockERC20("Token A", "TKA");
        MockERC20 tokenB = new MockERC20("Token B", "TKB");
        console.log("TokenA deployed at:", address(tokenA));
        console.log("TokenB deployed at:", address(tokenB));

        // Step 3: Create a MiniAMM pair using the factory
        address pair = factory.createPair(address(tokenA), address(tokenB));
        console.log("MiniAMM pair deployed at:", pair);

        vm.stopBroadcast();
    }
}

// ==========================

// == Logs ==
//   MiniAMMFactory deployed at: 0x49c5998a3d99B9d755906196219530D21C21fD6D
//   TokenA deployed at: 0x3c723fa37a98CBE904EDC9B8C65b7D6CCD6b215F
//   TokenB deployed at: 0xA909D7290bfFb010FFB81061094Cf7cF4Ca1BD57
//   MiniAMM pair deployed at: 0x74ADde0f6Bc75199ccEA77B1A4c8389eb40aB868

// ## Setting up 1 EVM.
// ==========================

// ==========================

// ##### flare-coston2
// ✅  [Success] Hash: 0x237de628497d0eed384d949b482b00c155da8df123f8df5bb7dbc29fc437bbe9
// Contract Address: 0x3c723fa37a98CBE904EDC9B8C65b7D6CCD6b215F
// Block: 22437640
// Paid: 0.0615736875 C2FLR (985179 gas * 62.5 gwei)

// ##### flare-coston2
// ✅  [Success] Hash: 0xc2bab0553e4e6e8aeb33a0ee0b6a1b0a7da7e315d38e1b1087319d61019d3403
// Contract Address: 0x49c5998a3d99B9d755906196219530D21C21fD6D
// Block: 22437640
// Paid: 0.20060825 C2FLR (3209732 gas * 62.5 gwei)

// ##### flare-coston2
// ✅  [Success] Hash: 0xe8f670ba8ff298d1c91225d278cf79bc2fafba8bed8c2b580f79503e36871a0b
// Contract Address: 0xA909D7290bfFb010FFB81061094Cf7cF4Ca1BD57
// Block: 22437640
// Paid: 0.0615736875 C2FLR (985179 gas * 62.5 gwei)

// ##### flare-coston2
// ✅  [Success] Hash: 0x4a7edd10a0bdfb1a33f0d95aa871f61dcb28bf467450a5c9b02379375e40d159
// Block: 22437640
// Paid: 0.1421888125 C2FLR (2275021 gas * 62.5 gwei)

// ✅ Sequence #1 on flare-coston2 | Total Paid: 0.4659444375 C2FLR (7455111 gas * avg 62.5 gwei)

// ==========================

// ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
