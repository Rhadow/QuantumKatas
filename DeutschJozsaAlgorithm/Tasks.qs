// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.DeutschJozsaAlgorithm {
    
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    
    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // The "Deutsch-Jozsa algorithm" quantum kata is a series of exercises designed
    // to get you familiar with programming in Q#.
    // It covers the following topics:
    //  - writing oracles (quantum operations which implement certain classical functions),
    //  - Bernstein-Vazirani algorithm for recovering the parameters of a scalar product function,
    //  - Deutsch-Jozsa algorithm for recognizing a function as constant or balanced, and
    //  - writing tests in Q#.
    
    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.
    
    //////////////////////////////////////////////////////////////////
    // Part I. Oracles
    //////////////////////////////////////////////////////////////////
    
    // In this section you will implement oracles defined by classical functions using the following rules:
    //  - a function f(x₀, ..., xₙ₋₁) with N bits of input x = (x₀, ..., xₙ₋₁) and 1 bit of output y
    //    defines an oracle which acts on N input qubits and 1 output qubit.
    //  - the oracle effect on qubits in computational basis states is defined as follows:
    //    |x⟩ |y⟩ -> |x⟩ |y ⊕ f(x)⟩   (⊕ is addition modulo 2)
    //  - the oracle effect on qubits in superposition is defined following the linearity of quantum operations.
    //  - the oracle must act properly on qubits in all possible input states.
    
    // Task 1.1. f(x) = 0
    // Inputs:
    //      1) N qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    // Goal: transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    operation Oracle_Zero (x : Qubit[], y : Qubit) : Unit {
        // Since f(x) = 0 for all values of x, |y ⊕ f(x)⟩ = |y⟩.
        // This means that the operation doesn't need to do any transformation to the inputs.
        // Build the project and run the tests to see that T01_Oracle_Zero_Test test passes.
    }
    
    
    // Task 1.2. f(x) = 1
    // Inputs:
    //      1) N qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    // Goal: transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    operation Oracle_One (x : Qubit[], y : Qubit) : Unit {
        // Since f(x) = 1 for all values of x, |y ⊕ f(x)⟩ = |y ⊕ 1⟩ = |NOT y⟩.
        // This means that the operation needs to flip qubit y (i.e. transform |0⟩ to |1⟩ and vice versa).

        X(y);
    }
    
    
    // Task 1.3. f(x) = xₖ (the value of k-th qubit)
    // Inputs:
    //      1) N qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    //      3) 0-based index of the qubit from input register (0 <= k < N)
    // Goal: transform state |x, y⟩ into state |x, y ⊕ xₖ⟩ (⊕ is addition modulo 2).
    operation Oracle_Kth_Qubit (x : Qubit[], y : Qubit, k : Int) : Unit {
        // The following line enforces the constraints on the value of k that you are given.
        // You don't need to modify it. Feel free to remove it, this won't cause your code to fail.
        EqualityFactB(0 <= k and k < Length(x), true, "k should be between 0 and N-1, inclusive");

        CNOT(x[k], y);
    }
    
    
    // Task 1.4. f(x) = 1 if x has odd number of 1s, and 0 otherwise
    // Inputs:
    //      1) N qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    // Goal: transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    operation Oracle_OddNumberOfOnes (x : Qubit[], y : Qubit) : Unit {
        // Hint: f(x) can be represented as x_0 ⊕ x_1 ⊕ ... ⊕ x_(N-1)
        let N = Length(x);
        for (i in 0..N-1) {
            CNOT(x[i], y);
        }
    }
    
    
    // Task 1.5. f(x) = Σᵢ rᵢ xᵢ modulo 2 for a given bit vector r (scalar product function)
    // Inputs:
    //      1) N qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    //      3) a bit vector of length N represented as Int[]
    // You are guaranteed that the qubit array and the bit vector have the same length.
    // Goal: transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    //
    // Note: the functions featured in tasks 1.1, 1.3 and 1.4 are special cases of this function.
    operation Oracle_ProductFunction (x : Qubit[], y : Qubit, r : Int[]) : Unit {
        // The following line enforces the constraint on the input arrays.
        // You don't need to modify it. Feel free to remove it, this won't cause your code to fail.
        EqualityFactI(Length(x), Length(r), "Arrays should have the same length");

        let N = Length(x);
        for (i in 0..N-1) {
            if (r[i] % 2 == 1) {
                CNOT(x[i], y);
            }
        }
    }
    
    
    // Task 1.6. f(x) = Σᵢ (rᵢ xᵢ + (1 - rᵢ)(1 - xᵢ)) modulo 2 for a given bit vector r
    // Inputs:
    //      1) N qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    //      3) a bit vector of length N represented as Int[]
    // You are guaranteed that the qubit array and the bit vector have the same length.
    // Goal: transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    operation Oracle_ProductWithNegationFunction (x : Qubit[], y : Qubit, r : Int[]) : Unit {
        // The following line enforces the constraint on the input arrays.
        // You don't need to modify it. Feel free to remove it, this won't cause your code to fail.
        EqualityFactI(Length(x), Length(r), "Arrays should have the same length");

        // Replace xᵢ with 1 or zero and the result will be:
        // xᵢ = 0 => 1 - rᵢ
        // xᵢ = 1 => rᵢ
        // In other word, when rᵢ is odd, it will only affect our output when xᵢ is 1 since 1 - rᵢ is gonna be even and even number does nothing to ⊕.
        // On the other side, when rᵢ is even, since 1 - rᵢ is odd, it might affect output when xᵢ is 0.

        let N = Length(x);
        mutable num = 0;
        for (i in 0..N-1) {
            if (r[i] % 2 == 0) {
                X(x[i]);
                CNOT(x[i], y);
                X(x[i]);
            } else {
                CNOT(x[i], y);
            }
        }
    }
    
    
    // Task 1.7. f(x) = Σᵢ xᵢ + (1 if prefix of x is equal to the given bit vector, and 0 otherwise) modulo 2
    // Inputs:
    //      1) N qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    //      3) a bit vector of length P represented as Int[] (1 <= P <= N)
    // Goal: transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    //
    // A prefix of length k of a state |x⟩ = |x₁, ..., xₙ⟩ is the state of its first k qubits |x₁, ..., xₖ⟩.
    // For example, a prefix of length 2 of a state |0110⟩ is 01.
    operation Oracle_HammingWithPrefix (x : Qubit[], y : Qubit, prefix : Int[]) : Unit {
        // The following line enforces the constraint on the input arrays.
        // You don't need to modify it. Feel free to remove it, this won't cause your code to fail.
        let P = Length(prefix);
        EqualityFactB(1 <= P and P <= Length(x), true, "P should be between 1 and N, inclusive");

        // Hint: the first part of the function is the same as in task 1.4
        let N = Length(x);
        let prefixLength = Length(prefix);
        using (anc = Qubit[prefixLength]) {
            for (i in 0..N-1) {
                // This CNOT ensure the result is the same as 1.4
                CNOT(x[i], y);
                // Since we need to compare the bits without measuring them, applying CNOT using x and prefix as controlled bit is a perfect solution.
                // if these two values are the same, the result ancilla bit should always be zero because we are applying NOT twice or not applying at all.
                if (i < prefixLength) {
                    CNOT(x[i], anc[i]);
                    if (prefix[i] == 1) {
                        X(anc[i]);
                    }
                }
            }
            // Here, we add one (apply X) only when ancilla bits are zero only. Any differences in prefix and x will result ancilla bits to be non-zero.
            (ControlledOnInt(0, X))(anc, y);
            // Clear ancilla bits, ResetAll does not work, still need to figure out why
            for (i in 0..prefixLength-1) {
                CNOT(x[i], anc[i]);
                if (prefix[i] == 1) {
                    X(anc[i]);
                }
            }
        }
    }
    
    
    // Task 1.8*. f(x) = 1 if x has two or three bits (out of three) set to 1, and 0 otherwise  (majority function)
    // Inputs:
    //      1) 3 qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    // Goal: transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    operation Oracle_MajorityFunction (x : Qubit[], y : Qubit) : Unit {
        // The following line enforces the constraint on the input array.
        // You don't need to modify it. Feel free to remove it, this won't cause your code to fail.
        EqualityFactB(3 == Length(x), true, "x should have exactly 3 qubits");

        // Hint: represent f(x) in terms of AND and ⊕ operations

        // There are only 4 cases where f(x) is returning 1 which are 011, 101, 110, 111. We can separate them into two cases:
        // 1. 111 - When 3 bits AND together, we want a one. We can achieve this using two CCNOT (Tofolli gate).
        // 2. 011, 101, 110 - When 3 bits XOR together, it will return 0 if there are two ones in there. One thing to notice, we need to get
        // rid of the 000 case since 000 XOR together is also returning zero. We can then invert the result and use it on y.


        // Covers the first (AND together) case, notice that these two cases does not affect each other, we can do them sequentially without conditions.
        using (anc = Qubit()) {
            CCNOT(x[0], x[1], anc);
            CCNOT(anc, x[2], y);
            CCNOT(x[0], x[1], anc);
        }

        // Covers the second case
        using (anc = Qubit[3]) {
            // anc[1] and anc[2] are used to check the 000 case, I invert the x and AND them together. anc[2] will be one only when x is 000.
            X(x[0]);
            X(x[1]);
            X(x[2]);
            CCNOT(x[0], x[1], anc[1]);
            CCNOT(anc[1], x[2], anc[2]);
            // Since I want to CNOT y when anc[2] is zero (not 000), I invert it again for later use
            X(anc[2]);
            // Revert the change on x since we shouldn't change them
            X(x[0]);
            X(x[1]);
            X(x[2]);

            // XOR three bits together
            CNOT(x[0], anc[0]);
            CNOT(x[1], anc[0]);
            CNOT(x[2], anc[0]);
            // Invert it, since we want to use it as a conditional bit later
            X(anc[0]);
            // We only invert y when anc[0] (3 bit of x XOR together is 0) and anc[2] (x is not equal to 000) are both true
            CCNOT(anc[0], anc[2], y);

            // Clear ancillabit
            X(anc[0]);
            CNOT(x[2], anc[0]);
            CNOT(x[1], anc[0]);
            CNOT(x[0], anc[0]);
            X(x[0]);
            X(x[1]);
            X(x[2]);
            X(anc[2]);
            CCNOT(anc[1], x[2], anc[2]);
            CCNOT(x[0], x[1], anc[1]);
            X(x[2]);
            X(x[1]);
            X(x[0]);
        }
    }
    
    
    //////////////////////////////////////////////////////////////////
    // Part II. Bernstein-Vazirani Algorithm
    //////////////////////////////////////////////////////////////////
    
    // Task 2.1. State preparation for Bernstein-Vazirani algorithm
    // Inputs:
    //      1) N qubits in |0⟩ state (query register)
    //      2) a qubit in |0⟩ state (answer register)
    // Goal:
    //      1) create an equal superposition of all basis vectors from |0...0⟩ to |1...1⟩ on query register
    //         (i.e. state (|0...0⟩ + ... + |1...1⟩) / sqrt(2^N) )
    //      2) create |-⟩ state (|-⟩ = (|0⟩ - |1⟩) / sqrt(2)) on answer register
    operation BV_StatePrep (query : Qubit[], answer : Qubit) : Unit
    is Adj {
        let N = Length(query);
        for (i in 0..N-1) {
            H(query[i]);
        }
        X(answer);
        H(answer);
    }
    
    
    // Task 2.2. Bernstein-Vazirani algorithm implementation
    // Inputs:
    //      1) the number of qubits in the input register N for the function f
    //      2) a quantum operation which implements the oracle |x⟩|y⟩ -> |x⟩|y ⊕ f(x)⟩, where
    //         x is an N-qubit input register, y is a 1-qubit answer register, and f is a Boolean function
    // You are guaranteed that the function f implemented by the oracle is a scalar product function
    // (can be represented as f(x₀, ..., xₙ₋₁) = Σᵢ rᵢ xᵢ modulo 2 for some bit vector r = (r₀, ..., rₙ₋₁)).
    // You have implemented the oracle implementing the scalar product function in task 1.5.
    // Output:
    //      A bit vector r reconstructed from the function
    //
    // Note: a trivial approach is to call the oracle N times:
    //       |10...0⟩|0⟩ = |10...0⟩|r₀⟩, |010...0⟩|0⟩ = |010...0⟩|r₁⟩ and so on.
    // Quantum computing allows to perform this task in just one call to the oracle; try to implement this algorithm.
    operation BV_Algorithm (N : Int, Uf : ((Qubit[], Qubit) => Unit)) : Int[] {
        
        // Declare an Int array in which the result will be stored;
        // the variable has to be mutable to allow updating it.
        mutable r = new Int[N];
        
        using (query = Qubit[N]) {
            using (answer = Qubit()) {
                BV_StatePrep(query, answer);
                Uf(query, answer);
                BV_StatePrep(query, answer);
                for (i in 0..N-1) {
                    set r w/= i <- M(query[i]) == One ? 1 | 0;
                }
                Reset(answer);
            }
            ResetAll(query);
        }

        return r;
    }
    
    
    // Task 2.3. Testing Bernstein-Vazirani algorithm
    // Goal: use your implementation of Bernstein-Vazirani algorithm from task 2.2 to figure out
    // what bit vector the scalar product function oracle from task 1.5 was using.
    // As a reminder, this oracle creates an operation f(x) = Σᵢ 𝑟ᵢ 𝑥ᵢ modulo 2 for a given bit vector r,
    // and Bernstein-Vazirani algorithm recovers that bit vector given the operation.
    operation BV_Test () : Unit {
        // Hint: use Oracle_ProductFunction to implement the scalar product function oracle passed to BV_Algorithm.
        // Since Oracle_ProductFunction takes three arguments (Qubit[], Qubit and Int[]), 
        // and the operation passed to BV_Algorithm must take two arguments (Qubit[] and Qubit), 
        // you need to use partial application to fix the third argument (a specific value of a bit vector). 
        // 
        // You might want to use something like the following:
        // let oracle = Oracle_ProductFunction(_, _, [...your bit vector here...]);

        // Hint: use AllEqualityFactI function to assert that the return value of BV_Algorithm operation 
        // matches the expected value (i.e. the bit vector passed to Oracle_ProductFunction).

        // BV_Test appears in the list of unit tests for the solution; run it to verify your code.

        // ...
    }
    
    
    //////////////////////////////////////////////////////////////////
    // Part III. Deutsch-Jozsa Algorithm
    //////////////////////////////////////////////////////////////////
    
    // Task 3.1. Deutsch-Jozsa algorithm implementation
    // Inputs:
    //      1) the number of qubits in the input register N for the function f
    //      2) a quantum operation which implements the oracle |x⟩|y⟩ -> |x⟩|y ⊕ f(x)⟩, where
    //         x is an N-qubit input register, y is a 1-qubit answer register, and f is a Boolean function
    // You are guaranteed that the function f implemented by the oracle is either
    // constant (returns 0 on all inputs or 1 on all inputs) or
    // balanced (returns 0 on exactly one half of the input domain and 1 on the other half).
    // Output:
    //      true if the function f is constant
    //      false if the function f is balanced
    //
    // Note: a trivial approach is to call the oracle multiple times:
    //       if the values for more than half of the possible inputs are the same, the function is constant.
    // Quantum computing allows to perform this task in just one call to the oracle; try to implement this algorithm.
    operation DJ_Algorithm (N : Int, Uf : ((Qubit[], Qubit) => Unit)) : Bool {
        
        // Declare Bool variable in which the result will be accumulated;
        // this variable has to be mutable to allow updating it.
        mutable isConstantFunction = true;
        
        // Hint: Even though Deutsch-Jozsa algorithm operates on a wider class of functions
        // than Bernstein-Vazirani (i.e. functions which can not be represented as a scalar product, such as f(x) = 1),
        // it can be expressed as running Bernstein-Vazirani algorithm
        // and then post-processing the return value classically.
        
        let amps = BV_Algorithm(N, Uf);

        for (i in 0..Length(amps)-1) {
            if (amps[i] == 1) {
                set isConstantFunction = false;
            }
        }

        return isConstantFunction;
    }
    
    
    // Task 3.2. Testing Deutsch-Jozsa algorithm
    // Goal: use your implementation of Deutsch-Jozsa algorithm from task 3.1 to test
    // each of the oracles you've implemented in part I for being constant or balanced.
    operation DJ_Test () : Unit {
        // Hint: you will need to use partial application to test ones such as Oracle_Kth_Qubit and Oracle_ProductFunction;
        // see task 2.3 for a description of how to do that.

        // Hint: use EqualityFactB function to assert that the return value of DJ_Algorithm operation matches the expected value

        // DJ_Test appears in the list of unit tests for the solution; run it to verify your code.

        // ...
    }
    
    
    //////////////////////////////////////////////////////////////////
    // Part IV. Come up with your own algorithm!
    //////////////////////////////////////////////////////////////////
    
    // Task 4.1. Reconstruct the oracle from task 1.6
    // Inputs:
    //      1) the number of qubits in the input register N for the function f
    //      2) a quantum operation which implements the oracle |x⟩|y⟩ -> |x⟩|y ⊕ f(x)⟩, where
    //         x is an N-qubit input register, y is a 1-qubit answer register, and f is a Boolean function
    // You are guaranteed that the function f implemented by the oracle can be represented as
    // f(x₀, ..., xₙ₋₁) = Σᵢ (rᵢ xᵢ + (1 - rᵢ)(1 - xᵢ)) modulo 2 for some bit vector r = (r₀, ..., rₙ₋₁).
    // You have implemented the oracle implementing this function in task 1.6.
    // Output:
    //      A bit vector r which generates the same oracle as the one you are given
    operation Noname_Algorithm (N : Int, Uf : ((Qubit[], Qubit) => Unit)) : Int[] {

        // Hint: The bit vector r does not need to be the same as the one used by the oracle,
        // it just needs to produce equivalent results.

        // Declare an Int array in which the result will be stored;
        // the variable has to be mutable to allow updating it.

        using ((x, y) = (Qubit[N], Qubit())) {
            Uf(x, y);
            if (N % 2 == 1) {
                X(y);
            }
            mutable r = new Int[N];
            if (M(y) == One) {
                set r w/= 0 <- 1;
            }
            ResetAll(x);
            Reset(y);
            return r;
        }
    }

}
