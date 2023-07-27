## How to Deploy
The following values need to be set in the constructor to deploy:

- _royaltyReceiver The account that will receive royalties.
- _royaltyFeeNumerator The royalty fee in basis points.
- _stablecoinAddress The address of stablecoin that will be used for paying fees.
- _mintFee The stablecoin quantity fee charged per minting 1 NFT, 18 zeros.
- _maxSupply The capped supply of the mintable NFTs.
- _devWallet The dev wallet address which is allow to mint for free up to a limit.
- _devMaxMint The limit for how many free mints the dev wallet can perform.

## How to Activate

- Verify the contract on a bnb scan.
- Call the `activateMint` function as admin.