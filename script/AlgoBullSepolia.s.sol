// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/AlgoBull.sol";

contract DeployAlgoBull is Script {
    function setUp() public {}

    function run() public {
        address _royaltyReceiver = 0x1A22f8e327adD0320d7ea341dFE892e43bC60322;
        uint96 _royaltyFeeNumerator = 1000;
        // BUSD on BNB testnet
        // address _stablecoinAddress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

        // LINK on sepolia, for ease of faucet
        address _stablecoinAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
        uint256 _mintFee = 1e18; // 1 dollar
        uint256 _maxSupply = 1000;
        address _devWallet = 0x5c57Afeb070B0F089E4DeDE58deF524143D1b54d;
        uint256 _devMaxMint = 3;


        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        AlgoBull algobull = new AlgoBull(
          _royaltyReceiver,
          _royaltyFeeNumerator,
          _stablecoinAddress,
          _mintFee,
          _maxSupply,
          _devWallet,
          _devMaxMint
        );

        vm.stopBroadcast();
    }
}
