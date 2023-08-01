pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

/**
 * @dev AlgoBull NFT Minting Contract that implements the following properties:
 * - Fixed Stablecoin fee per 1 mint.
 * - Fixed Supply.
 * - Mint multiple NFTs.
 * - Apply royalties via ERC2981.
 * - Support a dev wallet's ability to waive minting fees up to a set amount.
 */
contract AlgoBull is ERC721Royalty, ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    string public tokenIPFSUri = "ipfs://bafkreiau7zsjgl3ieud3rswejmpdga2tido5qyicnvedpgezcq5hmh4zhq";

    uint256 public mintFee;
    ERC20 private stablecoin;
    uint256 public maxSupply;
    address public devWallet;
    uint256 public devMaxMint;

    Counters.Counter private _tokenIds;

    /**
     * @dev Initializes the AlgoBull NFT minting contract.
     * @param _royaltyReceiver The account that will receive royalties.
     * @param _royaltyFeeNumerator The royalty fee in basis points.
     * @param _stablecoinAddress The address of stablecoin that will be used for paying fees.
     * @param _mintFee The stablecoin quantity fee charged per minting 1 NFT.
     * @param _maxSupply The capped supply of the mintable NFTs.
     * @param _devWallet The dev wallet address which is allow to mint for free up to a limit.
     * @param _devMaxMint The limit for how many free mints the dev wallet can perform.
     */
    constructor(
        address _royaltyReceiver,
        uint96 _royaltyFeeNumerator,
        address _stablecoinAddress,
        uint256 _mintFee,
        uint256 _maxSupply,
        address _devWallet,
        uint256 _devMaxMint
    ) ERC721("AlgoBull", "ALGOBULL") Ownable() {
        _setDefaultRoyalty(_royaltyReceiver, _royaltyFeeNumerator);
        stablecoin = ERC20(_stablecoinAddress);
        mintFee = _mintFee;
        maxSupply = _maxSupply;
        devWallet = _devWallet;
        devMaxMint = _devMaxMint;
    }

    /**
     * @dev Allows owner to set a dev wallet.
     * @param _devWallet the wallet that will be able to mint without fees up to the devMaxMint.
     */
    function setDevWallet(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }

    /**
     * @dev Mints a token.
     * This function is designed to only be used by contract level functions.
     * @param _recipient The address of the account that will receives the minted NFT and pay the fee.
     */
    function mint(address _recipient) private nonReentrant returns (uint256) {
        uint256 newID = _tokenIds.current();
        _mint(_recipient, newID);
        _setTokenURI(newID, tokenIPFSUri);
        _tokenIds.increment();

        return newID;
    }

    /**
     * @dev Mints multiple tokens and sends fee amount to owner.
     * The sender must have an adequate balance of stablecoin to pay the fee. minting
     * should not push the total tokens minted above the max token supply.
     * @param _recipient The address of the account that will receive the minted NFT.
     */
    function mintMultiple(address _recipient, uint256 quantity) external returns (uint256) {
        require(quantity > 0, "Cannot mint 0 tokens");
        require((_tokenIds.current() + quantity) <= unclaimed(), "Cannot mint beyond remaining supply");

        bool isDev = msg.sender == devWallet;
        bool devCanMintFree = (balanceOf(msg.sender) + quantity) <= devMaxMint;

        if (isDev && devCanMintFree) {
            for (uint256 i = 0; i < quantity; i++) {
                mint(_recipient);
            }
        } else {
            uint256 totalFee = mintFee * quantity;
            require(
                stablecoin.allowance(msg.sender, address(this)) >= totalFee,
                "Sender needs to approve contract to spend total fee amount"
            );
            require(
                stablecoin.balanceOf(msg.sender) >= (mintFee * quantity),
                "Sender does not have enough stablecoin for minting fee"
            );
            for (uint256 i = 0; i < quantity; i++) {
                mint(_recipient);
            }
            stablecoin.transferFrom(msg.sender, owner(), totalFee);
        }

        return quantity;
    }

    /**
     * @dev Get remaining unclaimed NFTs left to mint.
     */
    function unclaimed() public view returns (uint256) {
        return maxSupply - _tokenIds.current();
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev See {ERC721-_burn}.
     */
    function _burn(uint256 tokenId) internal override(ERC721Royalty, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Royalty, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
