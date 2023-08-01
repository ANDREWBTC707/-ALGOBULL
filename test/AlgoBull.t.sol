pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/AlgoBull.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract AlgoBullTest is Test {
    AlgoBull algoBull;
    address deployer = address(1);
    address _royaltyReceiver = address(2);
    uint96 _royaltyFeeNumerator = 1000;
    uint256 _mintFee = 500;
    uint256 _maxSupply = 1000;
    address _devWallet = address(3);
    uint256 _devMaxMint = 25;
    address _minter = address(4);
    ERC20 _stablecoin;

    function setUp() public {
        _stablecoin = new ERC20("test", "TEST");
        address _stablecoinAddress = address(_stablecoin);

        vm.prank(deployer);
        algoBull = new AlgoBull(
            _royaltyReceiver = _royaltyReceiver,
            _royaltyFeeNumerator = _royaltyFeeNumerator,
            _stablecoinAddress = _stablecoinAddress,
            _mintFee = _mintFee,
            _maxSupply = _maxSupply,
            _devWallet = _devWallet,
            _devMaxMint = _devMaxMint
        );
    }

    function test_OwnerIsSet() public {
        assertEq(deployer, algoBull.owner());
    }

    function test_RoyaltyFeeAndReceiverAreSet() public {
        deal(address(_stablecoin), _minter, _mintFee);

        vm.prank(_minter);
        _stablecoin.approve(address(algoBull), _mintFee);

        vm.prank(_minter);
        algoBull.mintMultiple(_minter, 1);

        uint256 salePrice = 100;

        vm.prank(_minter);
        (address royaltyReceiver, uint256 royaltyAmount) = algoBull.royaltyInfo(0, 100);

        assertEq(royaltyAmount, salePrice * 100 / _royaltyFeeNumerator);
        assertEq(royaltyReceiver, _royaltyReceiver);
    }

    function test_SenderCannotMintBeyondRemainingSupply() public {
        uint256 supplyOverflow = _maxSupply + 1;
        uint256 totalFees = supplyOverflow * _mintFee;

        deal(address(_stablecoin), _minter, totalFees);

        vm.prank(_minter);
        _stablecoin.approve(address(algoBull), totalFees);

        vm.prank(_minter);
        vm.expectRevert("Cannot mint beyond remaining supply");
        algoBull.mintMultiple(_minter, supplyOverflow);
    }

    function test_SenderCannotMintWithoutFee() public {
        vm.prank(_minter);
        vm.expectRevert("Sender needs to approve contract to spend total fee amount");
        algoBull.mintMultiple(_minter, 1);
    }

    function test_SenderPaysFeeAmountOnMint() public {
        deal(address(_stablecoin), _minter, _mintFee);

        vm.prank(_minter);
        _stablecoin.approve(address(algoBull), _mintFee);

        vm.prank(_minter);
        algoBull.mintMultiple(_minter, 1);

        assertEq(_stablecoin.balanceOf(_minter), 0);
    }

    function test_NFTUriIsSetOnMint() public {
        deal(address(_stablecoin), _minter, _mintFee);

        vm.prank(_minter);
        _stablecoin.approve(address(algoBull), _mintFee);

        vm.prank(_minter);
        algoBull.mintMultiple(_minter, 1);

        assertEq(algoBull.tokenURI(0), "ipfs://bafkreiau7zsjgl3ieud3rswejmpdga2tido5qyicnvedpgezcq5hmh4zhq");
    }

    function test_FeeAmountIsSentToAdminOnMint() public {
        deal(address(_stablecoin), _minter, _mintFee);

        vm.prank(_minter);
        _stablecoin.approve(address(algoBull), _mintFee);

        vm.prank(_minter);
        algoBull.mintMultiple(_minter, 1);

        assertEq(_stablecoin.balanceOf(deployer), _mintFee);
    }

    function test_SenderReceivesRequestedQuantityOnMint() public {
        deal(address(_stablecoin), _minter, _mintFee);

        vm.prank(_minter);
        _stablecoin.approve(address(algoBull), _mintFee);

        vm.prank(_minter);
        algoBull.mintMultiple(_minter, 1);

        assertEq(algoBull.balanceOf(_minter), 1);
    }

    function test_SendersCanMintMaxSupply() public {
        uint256 totalFees = _maxSupply * _mintFee;

        deal(address(_stablecoin), _minter, totalFees);

        vm.prank(_minter);
        _stablecoin.approve(address(algoBull), totalFees);

        vm.prank(_minter);
        algoBull.mintMultiple(_minter, _maxSupply);

        assertEq(algoBull.balanceOf(_minter), _maxSupply);
    }

    function test_OwnerCanSetDevWallet() public {
        address newDevWallet = address(5);
        vm.prank(deployer);
        algoBull.setDevWallet(newDevWallet);
        assertEq(algoBull.devWallet(), newDevWallet);
    }

    function test_NonOwnerCannotSetDevWallet() public {
        vm.prank(_minter);
        vm.expectRevert("Ownable: caller is not the owner");
        algoBull.setDevWallet(_minter);
    }

    function test_DevWalletMustPayFeesPastDevMintMax() public {
        vm.prank(_devWallet);
        vm.expectRevert("Sender needs to approve contract to spend total fee amount");
        algoBull.mintMultiple(_devWallet, _devMaxMint + 1);
    }

    function test_CannotMintZeroToken() public {
        vm.prank(_devWallet);
        vm.expectRevert("Cannot mint 0 tokens");
        algoBull.mintMultiple(_devWallet, 0);
    }

    function test_DevWalletCanMintWithoutFeesUpToLimit() public {
        vm.prank(_devWallet);
        algoBull.mintMultiple(_devWallet, _devMaxMint);

        assertEq(algoBull.balanceOf(_devWallet), _devMaxMint);
    }

    function test_UnclaimedAmountReflectsRemainingMintable() public {
        deal(address(_stablecoin), _minter, _mintFee);

        vm.prank(_minter);
        _stablecoin.approve(address(algoBull), _mintFee);

        vm.prank(_minter);
        algoBull.mintMultiple(_minter, 1);

        assertEq(algoBull.unclaimed(), _maxSupply - 1);
    }
}
