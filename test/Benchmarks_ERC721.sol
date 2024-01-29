// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Benchmarks.base.sol";
import {IAirdropERC721} from "src/thirdweb/deps/IAirdropERC721.sol";

// See Benchmarks.base.sol for more info and to modify the amount of recipients to test with

// 1. MAPPING APPROACH (claim)
// 2. MERKLE TREE APPROACH (claim)
// 3. SIGNATURE APPROACH (claim)
// 4. GASLITE DROP (airdrop)
// 5. THIRDWEB AIRDROP (airdrop)
// 6. THIRDWEB AIRDROP (claim)

contract Benchmarks_ERC721 is Benchmarks_Base {
    /* -------------------------------------------------------------------------- */
    /*                                    SETUP                                   */
    /* -------------------------------------------------------------------------- */

    function _setType() internal override {
        testType = TEST_TYPE.ERC721;
    }

    /* -------------------------------------------------------------------------- */
    /*                             1. MAPPING APPROACH                            */
    /* -------------------------------------------------------------------------- */

    function test_ERC721_AirdropClaimMapping(uint256) public {
        setup();

        // Airdrop
        erc721.setApprovalForAll(address(airdropClaimMapping), true);
        airdropClaimMapping.airdropERC721(RECIPIENTS, TOKEN_IDS);

        // Claim
        for (uint256 i = 0; i < RECIPIENTS.length; i++) {
            vm.prank(RECIPIENTS[i]);
            airdropClaimMapping.claimERC721();
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                           2. MERKLE TREE APPROACH                          */
    /* -------------------------------------------------------------------------- */

    function test_ERC721_AirdropClaimMerkle(uint256) public {
        setup();

        // Deposit
        for (uint256 i = 0; i < TOKEN_IDS.length; i++) {
            erc721.transferFrom(address(this), address(airdropClaimMerkle), TOKEN_IDS[i]);
        }

        // Claim
        for (uint256 i = 0; i < RECIPIENTS.length; i++) {
            bytes32[] memory proof = m.getProof(DATA_ERC721, i);
            // prank doesn't really matter as anyone can claim with a valid proof, since tokens are sent to the recipient
            vm.prank(RECIPIENTS[i]);
            airdropClaimMerkle.claimERC721(RECIPIENTS[i], TOKEN_IDS[i], proof);
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                            3. SIGNATURE APPROACH                           */
    /* -------------------------------------------------------------------------- */

    function test_ERC721_AirdropClaimSignature(uint256) public {
        setup();

        // Deposit
        for (uint256 i = 0; i < TOKEN_IDS.length; i++) {
            erc721.transferFrom(address(this), address(airdropClaimSignature), TOKEN_IDS[i]);
        }

        // Claim
        for (uint256 i = 0; i < RECIPIENTS.length; i++) {
            bytes32 messageHash = keccak256(abi.encodePacked(RECIPIENTS[i], TOKEN_IDS[i]));
            bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(SIGNER_KEY, prefixedHash);
            bytes memory signature = abi.encodePacked(r, s, v);

            // Same here with prank, some can claim on behalf of the recipient (but tokens are sent to the recipient)
            vm.prank(RECIPIENTS[i]);
            airdropClaimSignature.claimERC721(RECIPIENTS[i], TOKEN_IDS[i], signature);
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                               4. GASLITE DROP                              */
    /* -------------------------------------------------------------------------- */

    function test_ERC721_GasliteDrop(uint256) public {
        setup();

        // Airdrop
        erc721.setApprovalForAll(address(gasliteDrop), true);
        gasliteDrop.airdropERC721(address(erc721), RECIPIENTS, TOKEN_IDS);
    }

    /* -------------------------------------------------------------------------- */
    /*                             5. THIRDWEB AIRDROP                            */
    /* -------------------------------------------------------------------------- */

    function test_ERC721_ThirdwebAirdrop(uint256) public {
        setup();

        // Airdrop
        erc721.setApprovalForAll(address(thirdweb_airdropERC721), true);
        thirdweb_airdropERC721.airdropERC721(address(erc721), address(this), _toAirdropContent(RECIPIENTS, TOKEN_IDS));
    }

    function _toAirdropContent(address[] memory _recipients, uint256[] memory _tokenIds)
        internal
        pure
        returns (IAirdropERC721.AirdropContent[] memory contents)
    {
        contents = new IAirdropERC721.AirdropContent[](_recipients.length);
        for (uint256 i = 0; i < _recipients.length; i++) {
            contents[i] = IAirdropERC721.AirdropContent({recipient: _recipients[i], tokenId: _tokenIds[i]});
        }
    }
}
