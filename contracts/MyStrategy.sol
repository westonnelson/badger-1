    // SPDX-License-Identifier: MIT

    pragma solidity 0.6.12;
    pragma experimental ABIEncoderV2;

    import "@openzeppelin-contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
    import "@openzeppelin-contracts-upgradeable/math/SafeMathUpgradeable.sol";
    import "@openzeppelin-contracts-upgradeable/math/MathUpgradeable.sol";
    import "@openzeppelin-contracts-upgradeable/utils/AddressUpgradeable.sol";
    import "@openzeppelin-contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";


    import {BaseStrategy} from "@badger-finance/BaseStrategy.sol";
    import {ILendingPool} from "../interfaces/scream/ILendingPool.sol";
    import {IComptrollerLensInterface} from "../interfaces/scream/IComptrollerLensInterface.sol";
    import {IRouter} from "../interfaces/spookyswap/IRouter.sol";


    contract MyStrategy is BaseStrategy {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    event Debug(string name, uint256 value);
    
    // $scWBTC Token;
    address public constant SCTOKEN = 0x4565DC3Ef685E4775cdF920129111DdF43B9d882;
    // $SCREAM Token
    address public constant REWARD = 0xe0654C8e6fd4D733349ac7E09f6f23DA256bF475;
    
    // $BADGER Token
    address constant BADGER = 0x753fbc5800a8C8e3Fb6DC6415810d627A387Dfc9;

    // SpookySwap Router
    IRouter constant public ROUTER = IRouter(0xf491e7b69e4244ad4002bc14e878a34207e38c29);

    ILendingPool constant public LENDING_POOL = ILendingPool(0x4565DC3Ef685E4775cdF920129111DdF43B9d882);

    IComptrollerLensInterface constant public COMPTROLLER_LENS_INTERFACE = IComptollerLensInterface(0x59B46Fbb487aa974DE815F31601cbE6ba7368A01);


    function initialize(address _vault, address[1] memory _wantConfig) public initializer {
        __BaseStrategy_init(_vault);
    
        want = _wantConfig[0]; 

         // Approve want for earning interest
        IERC20Upgradeable(want).safeApprove(
            address(LENDING_POOL),
            type(uint256).max
        );
        
        // Aprove Reward so we can sell it
        IERC20Upgradeable(REWARD).safeApprove(
            address(ROUTER),
            type(uint256).max
        );
    }
    

    /// @dev Return the name of the strategy
    function getName() external pure override returns (string memory) {
        return "WBTC_YieldFarming_Scream";
    }

    /// @dev Return a list of protected tokens
    /// @notice It's very important all tokens that are meant to be in the strategy to be marked as protected
    /// @notice this provides security guarantees to the depositors they can't be sweeped away
    function getProtectedTokens() public view virtual override returns (address[] memory) {
        address[] memory protectedTokens = new address[](3);
        protectedTokens[0] = want;
        protectedTokens[0] = scToken;
        protectedTokens[1] = reward;
        return protectedTokens;
    }



    /// @dev Deposit `_amount` of want, investing it to earn yield
        // Add code here to invest `_amount` of want to earn yield 
    function mint(uint256 mintAmount) internal override { 
        emit Debug("_amount", _amount);
        LENDING_POOL.deposit(want, _amount, address(this), 0);
    }

    }


    //
    function redeem() internal override {}
    uint256 redeemTokens = IERC20Upgradeable(scToken).balanceOf(address(this)); // Cache to save gas on worst case
        
        if(toWithdraw == 0){

            // Scream reverts if trying to withdraw 0

            return;
        }
       
    }

    // Max Withdrawal 
    LENDING_POOL.redeemUnderlying(want, type(uint256).max, address(this));

}
    uint256 balBefore = balanceOfWant();
        LENDING_POOL.withdraw(want, _amount, address(this));
        uint256 balAfter = balanceOfWant();

        // Handle case of slippage
        return balAfter.sub(balBefore);
    }

    /// @dev Does this function require `tend` to be called?
    function _isTendable() internal override pure returns (bool) {
        return false; // Change to true if the strategy should be tended
    }

    function _claimComp() internal override returns (TokenAmount[] memory harvested) {
        address[] memory tokens = new address[](1);
        tokens[0] = scToken;
        // No-op as we don't do anything with funds
        // use autoCompoundRatio here to convert rewards to want ...


        // Claim all rewards
        REWARDS_CONTRACT.claimRewards(tokens, type(uint256).max, address(this));

        uint256 allRewards = IERC20Upgradeable(REWARD).balanceOf(address(this));

         // Sell 50%
        uint256 toSell = allRewards.mul(5000).div(MAX_BPS);

         // Sell for more want
        address[] memory path = new address[](2);
        path[0] = REWARD;
        path[1] = want;

        uint256 beforeWant = IERC20Upgradeable(want).balanceOf(address(this));
        ROUTER.swapExactTokensForTokens(toSell, 0, path, address(this), block.timestamp);
        uint256 afterWant = IERC20Upgradeable(want).balanceOf(address(this));

          // Report profit for the want increase (NOTE: We are not getting perf fee on AAVE APY with this code)
        uint256 wantHarvested = afterWant.sub(beforeWant);
        _reportToVault(wantHarvested);

         // Remaining balance to emit to tree
        uint256 rewardEmitted = IERC20Upgradeable(REWARD).balanceOf(address(this)); 
        _processExtraToken(REWARD, rewardEmitted);

        // Return the same value for APY and offChain automation
        harvested = new TokenAmount[](2);
        harvested[0] = TokenAmount(want, wantHarvested);
        harvested[1] = TokenAmount(REWARD, rewardEmitted);
        return harvested;
    }

      // Example tend is a no-op which returns the values, could also just revert
    function _tend() internal override returns (TokenAmount[] memory tended){
        uint256 balanceToTend = balanceOfWant();
        _deposit(balanceToTend);

        // Return all tokens involved for offChain tracking and automation
        tended = new TokenAmount[](3);
        tended[0] = TokenAmount(want, balanceToTend);
        tended[1] = TokenAmount(scToken, 0);
        tended[2] = TokenAmount(REWARD, 0); 
        return tended;
    }

      /// @dev Return the balance (in want) that the strategy has invested somewhere
    function balanceOfUnderlying() public view override returns (uint256) {
        return IERC20Upgradeable(scToken).balanceOf(address(this));
    }


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
    function compAccrued() external view override returns (TokenAmount[] memory rewards) {
        address[] memorty tokens = new address[](1);
        tokens[0] = scToken;

        uint256 accruedRewards = REWARDS_CONTRACT.compAccrued(tokens, address(this));
        rewards = new TokenAmount[](1);
        rewards[0] = TokenAmount(REWARD, accruedRewards); 
        return rewards;
    }
}
