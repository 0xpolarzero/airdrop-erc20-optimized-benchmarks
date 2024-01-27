// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Benchmarks.base.sol";

// See Benchmarks.base.sol for more info and to modify the amount of recipients to test with

// 4. DISPERSE APP
// 5. WENTOKENS
// 6. GASLITE DROP

contract Benchmarks_ETH is Benchmarks_Base {
    /* -------------------------------------------------------------------------- */
    /*                               1. DISPERSE APP                              */
    /* -------------------------------------------------------------------------- */

    function test_gasBenchmarks_Disperse(uint256) public {
        setup();
        // Deploy Disperse with cheatcode because of the pragma solidity ^0.4.25
        address deployed = deployCode("Disperse.sol");

        // Airdrop ("disperse")
        (bool success,) = deployed.call{value: TOTAL_AMOUNT}(
            abi.encodeWithSignature("disperseEther(address[],uint256[])", RECIPIENTS, AMOUNTS)
        );
        if (!success) revert("test_gasBenchmarks_Disperse_FAILED");
    }

    /* -------------------------------------------------------------------------- */
    /*                                2. WENTOKENS                                */
    /* -------------------------------------------------------------------------- */

    function test_gasBenchmarks_AirdropWentokens(uint256) public {
        setup();

        // Airdrop
        airdropWentokens.airdropETH{value: TOTAL_AMOUNT}(RECIPIENTS, AMOUNTS);
    }

    /* -------------------------------------------------------------------------- */
    /*                               3. GASLITE DROP                              */
    /* -------------------------------------------------------------------------- */

    function test_gasBenchmarks_GasliteDrop(uint256) public {
        setup();

        // Airdrop
        gasliteDrop.airdropETH{value: TOTAL_AMOUNT}(RECIPIENTS, AMOUNTS);
    }
}
