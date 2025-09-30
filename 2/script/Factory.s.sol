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
//   MiniAMMFactory deployed at: 0x87D927A7c8dD7C99df8d5DB758512Dc7a7E667cD
//   TokenA deployed at: 0x2203a23279483aA116C4b46Cd924171A1BC028f3
//   TokenB deployed at: 0x3d2e6Bf44c8ba2DB5cC29A1536752d6F03E5e32F
//   MiniAMM pair deployed at: 0xFf31A5e09143e9A8079214D1072f5F3a552f5540

// ==========================

// ##### flare-coston2
// ✅  [Success] Hash: 0x8b0b703a50aca94cba32e1972fd4e0e51619d302b23978fffa4125012f7926f1
// Contract Address: 0x87D927A7c8dD7C99df8d5DB758512Dc7a7E667cD
// Block: 22439515
// Paid: 0.20060825 C2FLR (3209732 gas * 62.5 gwei)

// ##### flare-coston2
// ✅  [Success] Hash: 0xcfcb9d2b1a2280027b642edc7174d163909ae8fe1a4591e0512c0a36061303d0
// Block: 22439516
// Paid: 0.1421888125 C2FLR (2275021 gas * 62.5 gwei)

// ##### flare-coston2
// ✅  [Success] Hash: 0xb779eaf197fcb4b63cdb38b3fe389d98b895fa8851827c5d48150caaf71bf27b
// Contract Address: 0x2203a23279483aA116C4b46Cd924171A1BC028f3
// Block: 22439516
// Paid: 0.0615736875 C2FLR (985179 gas * 62.5 gwei)

// ##### flare-coston2
// ✅  [Success] Hash: 0x8ea22323c76366c60c68e7fb3b1c17445b5c5c55040f46f697f1c79986647ff7
// Contract Address: 0x3d2e6Bf44c8ba2DB5cC29A1536752d6F03E5e32F
// Block: 22439516
// Paid: 0.0615736875 C2FLR (985179 gas * 62.5 gwei)

// ✅ Sequence #1 on flare-coston2 | Total Paid: 0.4659444375 C2FLR (7455111 gas * avg 62.5 gwei)

// ==========================

// ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
