// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {BaseStrategy} from "@badger-finance/BaseStrategy.sol";

contract MyStrategy is BaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;
    

    event MyLog(string, uint);

// address public want; // Inherited from BaseStrategy
    // address public lpComponent; // Token that represents ownership in a pool, not always used
    // address public reward; // Token we farm

    // $WBTC 
    address public constant want = 0x321162Cd933E2Be498Cd2267a90534A804051b11;
    // $scWBTC Token;
    CTokenInterface scToken = 0x4565DC3Ef685E4775cdF920129111DdF43B9d882;
    // $SCREAM Token
    address public reward = 0xe0654C8e6fd4D733349ac7E09f6f23DA256bF475;

    address constant BADGER = 0x753fbc5800a8C8e3Fb6DC6415810d627A387Dfc9;

    /// @dev Initialize the Strategy with security settings as well as tokens
    /// @notice Proxies will set any non constant variable you declare as default value
    /// @dev add any extra changeable variable at end of initializer as shown
    function initialize(address _vault, address[1] memory _wantConfig) public initializer {
        __BaseStrategy_init(_vault);
        /// @dev Add config here
        want = _wantConfig[0]; 
        reward = _wantConfig[1];

        scToken = CTokenInterface(scToken); //scToken object for $scWBTC
        
        // If you need to set new values that are not constants, set them like so
        // stakingContract = 0x79ba8b76F61Db3e7D994f7E384ba8f7870A043b7;

        // If you need to do one-off approvals do them here like so
        // IERC20Upgradeable(reward).safeApprove(
        //     address(DX_SWAP_ROUTER),
        //     type(uint256).max
        // );
    

        address; UNITROLLER_ADDRESSS = 0x260E596DAbE3AFc463e75B6CC05d8c46aCAcFB09;
        address; ROUTER = 0xf491e7b69e4244ad4002bc14e878a34207e38c29; 
        IERC20Upgradeable(want); //Erc20 object for $WBTC

        /// @dev do one off approvals here
        // IERC20Upgradeable(want).safeApprove(gauge, type(uint256).max);
        IERC20Upgradeable(want).safeApprove(scToken, type(uint256).max); //approving $WBTC for $scWBTC contract

        IERC20Upgradeable(scToken).safeApprove(scToken, type(uint256).max); //approving $scWBTC for $scWBTC contract

        //CErc20(lpComponent).safeApprove(COMPTROLLER_ADDRESSS, type(uint256).max); //approving CWBTC for COMP

        /// @dev Allowance for SpookySwap
        IERC20Upgradeable(reward).safeApprove(ROUTER, type(uint256).max); //approving Scream to SpookySwap
        IERC20Upgradeable(want).safeApprove(ROUTER, type(uint256).max); //approving $WBTC to SpookySwap

        //IERC20Upgradeable(COMP_TOKEN).safeApprove(ROUTER, type(uint256).max);



    }
    
    /// @dev Return the name of the strategy
    function getName() external pure override returns (string memory) {
        return "ScreamYieldFarmingWBTC";
    }

    /// @dev Return a list of protected tokens
    /// @notice It's very important all tokens that are meant to be in the strategy to be marked as protected
    /// @notice this provides security guarantees to the depositors they can't be sweeped away
    function getProtectedTokens() public view virtual override returns (address[] memory) {
        address[] memory protectedTokens = new address[](3);
        protectedTokens[0] = 0x321162Cd933E2Be498Cd2267a90534A804051b11;
        protectedTokens[1] = BADGER;
        protectedTokens[2] = 0x4565DC3Ef685E4775cdF920129111DdF43B9d882;
        return protectedTokens;
    }

    /// @dev Deposit `_amount` of want, investing it to earn yield
        // Add code here to invest `_amount` of want to earn yield 
    function mint(uint256 mintAmount) internal override { 

    }


    /// @dev Withdraw all funds, this is used for migrations, most of the time for emergency reasons
    function _redeemUnderlying(uint256 redeemAmount) internal override {
        // Add code here to unlock all available funds
    }

    /// @dev Withdraw `_amount` of want, so that it can be sent to the vault / depositor
    /// @notice just unlock the funds and return the amount you could unlock
    function repayBorrow(uint256 repayAmount) internal override returns (uint256) {
        // Add code here to unlock / withdraw `_amount` of tokens to the withdrawer
        // If there's a loss, make sure to have the withdrawer pay the loss to avoid exploits
        // Socializing loss is always a bad idea
        return _amount;
    }


    /// @dev Does this function require `tend` to be called?
    function _isTendable() internal override pure returns (bool) {
        return false; // Change to true if the strategy should be tended
    }

    function _claimComp() internal override returns (TokenAmount[] memory harvested) {
        // No-op as we don't do anything with funds
        // use autoCompoundRatio here to convert rewards to want ...

        // Nothing harvested, we have 2 tokens, return both 0s
        harvested = new TokenAmount[](2);
        harvested[0] = TokenAmount(want, 0);
        harvested[1] = TokenAmount(BADGER, 0);

        // keep this to get paid!
        _reportToVault(0);

        return harvested;
    }


    // Example tend is a no-op which returns the values, could also just revert
    function _tend() internal override returns (TokenAmount[] memory tended){
        // Nothing tended
        tended = new TokenAmount[](2);
        tended[0] = TokenAmount(want, 0);
        tended[1] = TokenAmount(BADGER, 0); 
        return tended;
    }

    /// @dev Return the balance (in want) that the strategy has invested somewhere
    function balanceOfUnderlying(address owner) public view override returns (uint256) {
        // Change this to return the amount of want invested in another protocol
        return 0;
    }

    /// @dev Return the balance of rewards that the strategy has accrued
    /// @notice Used for offChain APY and Harvest Health monitoring
    function balanceOfRewards() external view override returns (TokenAmount[] memory rewards) {
        // Rewards are 0
        rewards = new TokenAmount[](2);
        rewards[0] = TokenAmount(want, 0);
        rewards[1] = TokenAmount(BADGER, 0); 
        return rewards;
    }
}
