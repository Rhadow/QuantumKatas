// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.Superposition {
    
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // "Superposition" quantum kata is a series of exercises designed
    // to get you familiar with programming in Q#.
    // It covers the following topics:
    //  - basic single-qubit and multi-qubit gates,
    //  - superposition,
    //  - flow control and recursion in Q#.
    
    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.
    
    // The tasks are given in approximate order of increasing difficulty; harder ones are marked with asterisks.
    
    // Task 1. Plus state
    // Input: a qubit in |0⟩ state (stored in an array of length 1).
    // Goal: create a |+⟩ state on this qubit (|+⟩ = (|0⟩ + |1⟩) / sqrt(2)).
    operation PlusState (qs : Qubit[]) : Unit {
        // Hadamard gate H will convert |0⟩ state to |+⟩ state.
        // The first qubit of the array can be accessed as qs[0].
        // Type the following: H(qs[0]);
        // Then rebuild the project and rerun the tests - T01_PlusState_Test should now pass!

        // ...
        H(qs[0]);
    }
    
    
    // Task 2. Minus state
    // Input: a qubit in |0⟩ state (stored in an array of length 1).
    // Goal: create a |-⟩ state on this qubit (|-⟩ = (|0⟩ - |1⟩) / sqrt(2)).
    operation MinusState (qs : Qubit[]) : Unit {
        // In this task, as well as in all subsequent ones, you have to come up with the solution yourself.
            
        // ...
        X(qs[0]);
        H(qs[0]);
    }
    
    
    // Task 3*. Unequal superposition
    // Inputs:
    //      1) a qubit in |0⟩ state (stored in an array of length 1).
    //      2) angle alpha, in radians, represented as Double
    // Goal: create a cos(alpha) * |0⟩ + sin(alpha) * |1⟩ state on this qubit.
    operation UnequalSuperposition (qs : Qubit[], alpha : Double) : Unit {
        // Hint: Experiment with rotation gates from the Microsoft.Quantum.Intrinsic namespace.
        // Note that all rotation operators rotate the state by _half_ of its angle argument.

        // ...
        Ry(2.0 * alpha, qs[0]);
    }
    
    
    // Task 4. Superposition of all basis vectors on two qubits
    // Input: two qubits in |00⟩ state (stored in an array of length 2).
    // Goal:  create the following state on these qubits: (|00⟩ + |01⟩ + |10⟩ + |11⟩) / 2.
    operation AllBasisVectors_TwoQubits (qs : Qubit[]) : Unit {
        // The following lines enforce the constraints on the input that you are given.
        // You don't need to modify them. Feel free to remove them, this won't cause your code to fail.
        EqualityFactI(Length(qs), 2, "The array should have exactly 2 qubits.");

        // ...
        H(qs[0]);
        H(qs[1]);
    }
    
    
    // Task 5. Superposition of basis vectors with phases
    // Input: two qubits in |00⟩ state (stored in an array of length 2).
    // Goal:  create the following state on these qubits: (|00⟩ + i*|01⟩ - |10⟩ - i*|11⟩) / 2.
    operation AllBasisVectorsWithPhases_TwoQubits (qs : Qubit[]) : Unit {
        // The following lines enforce the constraints on the input that you are given.
        // You don't need to modify them. Feel free to remove them, this won't cause your code to fail.
        EqualityFactI(Length(qs), 2, "The array should have exactly 2 qubits.");

        // Hint: Is this state separable?
        // ...
        H(qs[0]);
        H(qs[1]);
        Z(qs[0]);
        S(qs[1]);
    }
    
    
    // Task 6. Bell state
    // Input: two qubits in |00⟩ state (stored in an array of length 2).
    // Goal: create a Bell state |Φ⁺⟩ = (|00⟩ + |11⟩) / sqrt(2) on these qubits.
    operation BellState (qs : Qubit[]) : Unit {
        // ...
        H(qs[0]);
        CNOT(qs[0], qs[1]);
    }
    
    
    // Task 7. All Bell states
    // Inputs:
    //      1) two qubits in |00⟩ state (stored in an array of length 2)
    //      2) an integer index
    // Goal: create one of the Bell states based on the value of index:
    //       0: |Φ⁺⟩ = (|00⟩ + |11⟩) / sqrt(2)
    //       1: |Φ⁻⟩ = (|00⟩ - |11⟩) / sqrt(2)
    //       2: |Ψ⁺⟩ = (|01⟩ + |10⟩) / sqrt(2)
    //       3: |Ψ⁻⟩ = (|01⟩ - |10⟩) / sqrt(2)
    operation AllBellStates (qs : Qubit[], index : Int) : Unit {
        // ...
        H(qs[0]);
        CNOT(qs[0], qs[1]);
        if (index == 1) {
            Z(qs[0]);
        } elif (index == 2) {
            X(qs[0]);
        } elif (index == 3) {
            X(qs[0]);
            Z(qs[0]);
        }

        // if (index == 1) {
        //     X(qs[0]);
        // } elif (index == 2) {
        //     X(qs[1]);
        // } elif (index == 3) {
        //     X(qs[0]);
        //     X(qs[1]);
        // }
        // H(qs[0]);
        // CNOT(qs[0], qs[1]);

    }
    
    
    // Task 8. Greenberger–Horne–Zeilinger state
    // Input: N qubits in |0...0⟩ state.
    // Goal: create a GHZ state (|0...0⟩ + |1...1⟩) / sqrt(2) on these qubits.
    operation GHZ_State (qs : Qubit[]) : Unit {
        // Hint: N can be found as Length(qs).

        // ...
        let N = Length(qs);
        H(qs[0]);
        for (i in 1..N-1) {
            CNOT(qs[0], qs[i]);
        }
    }
    
    
    // Task 9. Superposition of all basis vectors
    // Input: N qubits in |0...0⟩ state.
    // Goal: create an equal superposition of all basis vectors from |0...0⟩ to |1...1⟩
    // (i.e. state (|0...0⟩ + ... + |1...1⟩) / sqrt(2^N) ).
    operation AllBasisVectorsSuperposition (qs : Qubit[]) : Unit {
        // ...
        let N = Length(qs);
        for (i in 0..N-1) {
            H(qs[i]);
        }
    }
    
    
    // Task 10. |00⟩ + |01⟩ + |10⟩ state
    // Input: 2 qubits in |00⟩ state.
    // Goal: create the state (|00⟩ + |01⟩ + |10⟩) / sqrt(3) on these qubits.
    operation ThreeStates_TwoQubits (qs : Qubit[]) : Unit {
        // ...
        // https://quantumcomputing.stackexchange.com/questions/2310/how-can-i-build-a-circuit-to-generate-an-equal-superposition-of-3-outcomes-for-2/2313#2313

        // rotate
        let angle = ArcCos(Sqrt(2.0) / Sqrt(3.0)) * 2.0;
        Ry(angle, qs[0]);
        // apply conditional hadamard
        X(qs[0]);
        Controlled H([qs[0]], qs[1]);
        X(qs[0]);
    }
    
    
    // Task 11. Superposition of |0...0⟩ and given bit string
    // Inputs:
    //      1) N qubits in |0...0⟩ state
    //      2) bit string represented as Bool[]
    // Goal: create an equal superposition of |0...0⟩ and basis state given by the bit string.
    // Bit values false and true correspond to |0⟩ and |1⟩ states.
    // You are guaranteed that the qubit array and the bit string have the same length.
    // You are guaranteed that the first bit of the bit string is true.
    // Example: for bit string = [true, false] the qubit state required is (|00⟩ + |10⟩) / sqrt(2).
    operation ZeroAndBitstringSuperposition (qs : Qubit[], bits : Bool[]) : Unit {
        // The following lines enforce the constraints on the input that you are given.
        // You don't need to modify them. Feel free to remove them, this won't cause your code to fail.
        EqualityFactI(Length(bits), Length(qs), "Arrays should have the same length");
        EqualityFactB(bits[0], true, "First bit of the input bit string should be set to true");

        // ...
        let N = Length(bits);
        H(qs[0]);
        for (i in 1..N-1) {
            if (bits[i]) {
                CNOT(qs[0], qs[i]);
            }
        }
    }
    
    
    // Task 12. Superposition of two bit strings
    // Inputs:
    //      1) N qubits in |0...0⟩ state
    //      2) two bit string represented as Bool[]s
    // Goal: create an equal superposition of two basis states given by the bit strings.
    //
    // Bit values false and true correspond to |0⟩ and |1⟩ states.
    // Example: for bit strings [false, true, false] and [false, false, true]
    // the qubit state required is (|010⟩ + |001⟩) / sqrt(2).
    // You are guaranteed that the both bit strings have the same length as the qubit array,
    // and that the bit strings will differ in at least one bit.
    operation TwoBitstringSuperposition (qs : Qubit[], bits1 : Bool[], bits2 : Bool[]) : Unit {
        // ...
        let N = Length(qs);
        mutable diff = -1;
        H(qs[0]);

        for (i in 1..N-1) {
            if (diff == -1 and bits2[i] != bits1[i]) {
                set diff = i;
            }
            if (bits2[i]) {
                CNOT(qs[0], qs[i]);
            }
            if (bits1[i]) {
                X(qs[0]);
                CNOT(qs[0], qs[i]);
                X(qs[0]);
            }
        }

        if (diff == -1) {
            if (bits1[0] and not bits2[0]) {
                X(qs[0]);
            }
        } else {
            if (bits1[diff]) {
                if (bits1[0]) {
                    CNOT(qs[diff], qs[0]);
                }
                if (not bits2[0]) {
                    X(qs[diff]);
                    CNOT(qs[diff], qs[0]);
                    X(qs[diff]);
                }
            } else {
                if (not bits2[0]) {
                    CNOT(qs[diff], qs[0]);
                }
                if (bits1[0]) {
                    X(qs[diff]);
                    CNOT(qs[diff], qs[0]);
                    X(qs[diff]);
                }
            }
            // Derived from above, shorter but harder to under stand
            // if (bits1[0]) {
            //     (ControlledOnInt(bits1[diff] ? 1 | 0, X))([qs[diff]], qs[0]);
            // }
            // if (not bits2[0]) {
            //     (ControlledOnInt(bits1[diff] ? 0 | 1, X))([qs[diff]], qs[0]);
            // }
        }
    }
    
    
    // Task 13*. Superposition of four bit strings
    // Inputs:
    //      1) N qubits in |0...0⟩ state
    //      2) four bit string represented as Bool[][] bits
    //         bits is an array of size 4 x N which describes the bit strings as follows:
    //         bits[i] describes the i-th bit string and has N elements.
    //         All four bit strings will be distinct.
    //
    // Goal: create an equal superposition of the four basis states given by the bit strings.
    //
    // Example: for N = 3 and bits = [[false, true, false], [true, false, false], [false, false, true], [true, true, false]]
    //          the state you need to prepare is (|010⟩ + |100⟩ + |001⟩ + |110⟩) / 2.
    operation FourBitstringSuperposition (qs : Qubit[], bits : Bool[][]) : Unit {
        // Hint: remember that you can allocate extra qubits.
        let N = Length(qs);
        using (anc = Qubit[2]) {
            H(anc[0]);
            H(anc[1]);
            for (j in 0..N-1) {
                for (i in 0..3) {
                    if (bits[i][j]) {
                        (ControlledOnInt(i, X))(anc, qs[j]);
                    }
                }
            }
            for (i in 0..3) {
                if (i % 2 == 1) {
                    (ControlledOnBitString(bits[i], X))(qs, anc[0]);
                }
                if (i / 2 >= 1) {
                    (ControlledOnBitString(bits[i], X))(qs, anc[1]);
                }
            }
        }
    }
    
    
    // Task 14**. W state on 2ᵏ qubits
    // Input: N = 2ᵏ qubits in |0...0⟩ state.
    // Goal: create a W state (https://en.wikipedia.org/wiki/W_state) on these qubits.
    // W state is an equal superposition of all basis states on N qubits of Hamming weight 1.
    // Example: for N = 4, W state is (|1000⟩ + |0100⟩ + |0010⟩ + |0001⟩) / 2.
    operation WState_PowerOfTwo (qs : Qubit[]) : Unit {
        // Hint: you can use Controlled modifier to perform arbitrary controlled gates.

        // Transform steps:

        // 00000000

        // 10000000
        // 00000000

        // 10000000
        // 00000001

        // 10000000
        // 11000000
        // 00000001
        // 00000011


        // 10000000
        // 01000000
        // 00000001
        // 00000010


        // 10000000
        // 10100000
        // 01000000
        // 01010000
        // 00000001
        // 00000101
        // 00000010
        // 00001010


        // 10000000
        // 00100000
        // 01000000
        // 00010000
        // 00000001
        // 00000100
        // 00000010
        // 00001000

        let N = Length(qs);

        if (N == 1) {
            X(qs[0]);
            return ();
        }

        mutable push = 1;
        mutable i = 1;
        repeat {
            if (i == 1) {
                H(qs[0]);
                (ControlledOnInt(0, X))([qs[0]], qs[N - 1]);
            } else {
                for (j in 0..push-1) {
                    Controlled H([qs[j]], qs[j+push]);
                    Controlled X([qs[j+push]], qs[j]);
                    Controlled H([qs[N-1-j]], qs[N-1-j-push]);
                    Controlled X([qs[N-1-j-push]], qs[N-1-j]);
                }
                set push = push * 2;
            }
            set i = i * 2;
        } until (i == N);
    }
    
    
    // Task 15**. W state on arbitrary number of qubits
    // Input: N qubits in |0...0⟩ state (N is not necessarily a power of 2).
    // Goal: create a W state (https://en.wikipedia.org/wiki/W_state) on these qubits.
    // W state is an equal superposition of all basis states on N qubits of Hamming weight 1.
    // Example: for N = 3, W state is (|100⟩ + |010⟩ + |001⟩) / sqrt(3).
    operation WState_Arbitrary (qs : Qubit[]) : Unit {
        // ...
        // Similar to ThreeStates_TwoQubits question, start by thinking on how to get the correct amplitude.
        // The answer is to rotate each qubit with angle coreesponding to its index

        let N = Length(qs);
        mutable index = N - 1;
        repeat {
            mutable angle = ArcSin(1.0 / Sqrt(IntAsDouble(index + 1))) * 2.0;
            if (index == N - 1) {
                Ry(angle, qs[index]);
            } else {
                (ControlledOnInt(0, Ry))(qs[index+1..N-1], (angle, qs[index]));
            }
            set index -= 1;
        } until (index < 0);
    }
}
