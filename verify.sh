forge verify-contract \
    --chain-id 56 \
    --constructor-args $(cast abi-encode "constructor(address,uint96,address,uint256,uint256,address,uint256)" 0xE2274b261696B570C5646330b20551B7407F0562 1000 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 500000000000000000000 1000 0xE2274b261696B570C5646330b20551B7407F0562 25) \
    --etherscan-api-key $BNB_SCAN_API_KEY \
    --compiler-version "v0.8.18+commit.87f61d96" \
    0x344b011c68237D2db56734ef0B79BFBa6D842BF9 \
    src/AlgoBull.sol:AlgoBull \
    --watch