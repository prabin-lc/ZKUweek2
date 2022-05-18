//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves

        // initialization
        hashes = new uint256[](15);

        for (uint256 i = 0; i < 15; i++) {
            hashes[i] = 0;
        }

        // hash calculation for upper levels
        for (uint256 level = 2; level > 0; level--) {
            for (uint256 j = 0; j < 2**level; j++) {
                // 2**(level+1) is index to be shifted depending on level
                hashes[j + 2**(level + 1)] = PoseidonT3.poseidon(
                    [hashes[2 * j], hashes[2 * j + 1]]
                );
            }
        }

        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint256 currentIndex = index;

        uint256 leftChild;
        uint256 rightChild;

        // insert leaf node
        hashes[index] = hashedLeaf;

        // parent hashes calculation
        for (uint256 level = 2; level > 0; level--) {
            if (currentIndex % 2 == 0) {
                leftChild = hashes[currentIndex];
                rightChild = hashes[currentIndex + 1];
            } else {
                leftChild = hashes[currentIndex - 1];
                rightChild = hashes[currentIndex];
            }
            currentIndex = currentIndex / 2 + 2**(level + 1);
            hashes[currentIndex] = PoseidonT3.poseidon([leftChild, rightChild]);
        }

        index++;
        root = hashes[14];
        return root;
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return Verifier.verifyProof(a, b, c, input);
    }
}
