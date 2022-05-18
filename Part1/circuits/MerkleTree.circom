pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    // mutable container for hash values
    var nodes[2**n];

    // poseidon components
    component hashes[2**n - 1];

    // initializing each component
    for(var i=0; i<2**n - 1; i++) {
        hashes[i] = Poseidon(2);
    }

    // copying values from signal to mutable variable
    for(var i=0; i< 2**n; i++){
        nodes[i]<==leaves[i];
    }

    // calculating the root
    var count = 0; // counter for poseidon components used

    for (var i = n; i > 0; i--) { // for each level
        for( var j = 0; j< 2**n; j=j+2**(n-i+1) ){ // for each node in the level

            // the calculated hash of a parent is stored in the place of its left child
            // 2**(n-i+1) is the number of nodes to be skipped to get next node in the same level

            hashes[count].inputs[0] <== nodes[j];
            
            // j+2**(n-i) is the number of nodes to be skipped to get sibbling node in the same level
            hashes[count].inputs[1] <== nodes[j+2**(n-i)];

            // replacing leftmost child node in the hashes variable
            nodes[j] = hashes[count].out;
            
            // poseidon component counter
            count++;
        }
    }

    root <== nodes[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

    // poseidon components
    component hashes[n];
    
    component switchers[n];
    
    // mutable variable for calculated hash value of current node
    var parentHash = leaf;

    for (var i = 0; i < n; i++) {
        // initializing each component
        hashes[i] = Poseidon(2);
        switchers[i] = Switcher();

        switchers[i].sel <== path_index[i];
        switchers[i].L <== parentHash;
        switchers[i].R <== path_elements[i];

        hashes[i].inputs[0] <== switchers[i].outL;
        hashes[i].inputs[1] <== switchers[i].outR;
        
        parentHash = hashes[i].out;

    }

    root <== parentHash;

}