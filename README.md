# AlgoBull Contract

The House of the AlgoBull.

## Testing

Enter the dev shell via
```
nix develop
```
And run the tests:
```
forge test
```

## Project Plan

- [x] Contract is ownable.
- [x] Expose mint function that charges 500 BUSD for minting an NFT and sends it to the admin wallet.
- [x] Expose mint multiple function that mints n number of NFTs and charges 500 x n BUSD.
- [x] Expose function for admin to set dev wallet.
- [x] NFT minting fee does not apply to dev wallet if the dev wallet has minted 25 NFTs or less.
- [x] Limit maximum mint of NFTs to 1000.
- [x] Expose function to give users number of NFTs left to mint (`unclaimed()`).
- [x] NFT minting sets a 10% (1000 bip) royalty for all minted NFTs (Set `_setDefaultRoyalty(_receiver, feeNumerator)` in `ERC721Royalty` constructor).

## Notes

- The `approve` function will need to be called in a separate transaction before the minting function is called to allow the contract to spend the fee amount of stablecoin to pay for minting. This is because the `msg.sender` when called from the AlgoBull to the ERC20 contract is the AlgoBull address and not the originating sender, the minting user. 
