// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.GroversAlgorithm {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    
    
    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // The "Solving SAT problem with Grover's algorithm" quantum kata is a series of exercises designed
    // to get you comfortable with using Grover's algorithm to solve realistic problems
    // using boolean satisfiability problem (SAT) as an example.
    // It covers the following topics:
    //  - writing oracles implementing boolean expressions and SAT instances,
    //  - using Grover's algorithm to solve problems with unknown number of solutions.
    
    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.
    
    // Within each section, tasks are given in approximate order of increasing difficulty;
    // harder ones are marked with asterisks.
    
    
    //////////////////////////////////////////////////////////////////
    // Part I. Oracles for SAT problems
    //////////////////////////////////////////////////////////////////
    
    // The most interesting part of learning Grover's algorithm is solving realistic problems.
    // This means using oracles which express an actual problem and not simply hard-code a known solution.
    // In this section we'll learn how to express boolean satisfiability problems as quantum oracles.

    // Task 1.1. The AND oracle: f(x) = x₀ ∧ x₁
    // Inputs:
    //      1) 2 qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if both qubits of the query register are in the |1⟩ state,
    //       and leave it unchanged otherwise.
    //       Leave the query register in the same state it started in.
    // Stretch goal: Can you implement the oracle so that it would work
    //               for queryRegister containing an arbitrary number of qubits?
    operation Oracle_And (queryRegister : Qubit[], target : Qubit) : Unit
    is Adj {
        CCNOT(queryRegister[0], queryRegister[1], target);
    }


    // Task 1.2. The OR oracle: f(x) = x₀ ∨ x₁
    // Inputs:
    //      1) 2 qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if at least one qubit of the query register is in the |1⟩ state,
    //       and leave it unchanged otherwise.
    //       Leave the query register in the same state it started in.
    // Stretch goal: Can you implement the oracle so that it would work
    //               for queryRegister containing an arbitrary number of qubits?
    operation Oracle_Or (queryRegister : Qubit[], target : Qubit) : Unit
    is Adj {
        CNOT(queryRegister[0], target);
        CNOT(queryRegister[1], target);
        CCNOT(queryRegister[0], queryRegister[1], target);
    }


    // Task 1.3. The XOR oracle: f(x) = x₀ ⊕ x₁
    // Inputs:
    //      1) 2 qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if the qubits of the query register are in different states,
    //       and leave it unchanged otherwise.
    //       Leave the query register in the same state it started in.
    // Stretch goal: Can you implement the oracle so that it would work
    //               for queryRegister containing an arbitrary number of qubits?
    operation Oracle_Xor (queryRegister : Qubit[], target : Qubit) : Unit
    is Adj {
        CNOT(queryRegister[0], target);
        CNOT(queryRegister[1], target);
    }


    // Task 1.4. Alternating bits oracle: f(x) = (x₀ ⊕ x₁) ∧ (x₁ ⊕ x₂) ∧ ... ∧ (xₙ₋₂ ⊕ xₙ₋₁)
    // Inputs:
    //      1) N qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    //       Leave the query register in the same state it started in.
    // 
    // Note that this oracle marks two states similar to the state explored in task 1.2 of GroversAlgorithm kata: 
    // |10101...⟩ and |01010...⟩
    // It is possible (and quite straightforward) to implement this oracle based on this observation; 
    // however, for the purposes of learning to write oracles to solve SAT problems we recommend using the representation above.
    operation Oracle_AlternatingBits (queryRegister : Qubit[], target : Qubit) : Unit
    is Adj {
        let N = Length(queryRegister);
        using (anc = Qubit[N-1]) {
            // XOR each set
            for (i in 0..N-2) {
                Oracle_Xor([queryRegister[i], queryRegister[i + 1]], anc[i]);
                X(anc[i]);
            }
            // Invert the target only when anc is |1...1>
            (ControlledOnInt(0, X))(anc, target);
            // Reversing the action we took on ancillas
            for (i in 0..N-2) {
                X(anc[i]);
                Oracle_Xor([queryRegister[i], queryRegister[i + 1]], anc[i]);
            }
        }
    }


    // Task 1.5. 2-SAT problem oracle
    //
    // For 2-SAT problems, f(x) is represented as a conjunction (an AND operation) of M clauses on N variables, 
    // and each clause is a disjunction (an OR operation) of two variables or negated variables:
    //      f(x) = ∧ᵢ (yᵢ₀ ∨ yᵢ₁), yᵢₖ = either xⱼ or ¬xⱼ for some j in {0, ..., N-1}
    //
    // For example, XOR function f(x) = x₀ ⊕ x₁ can be represented as a 2-SAT problem 
    // using N = 2 variables and M = 2 clauses as follows:
    //      f(x) = x₀ ⊕ x₁ = (x₀ ∨ x₁) ∧ (¬x₀ ∨ ¬x₁)
    //
    // Inputs:
    //      1) N qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    //      3) a 2-dimensional array of tuples "problem" which describes the 2-SAT problem instance f(x).
    //
    // i-th element of "problem" describes the i-th clause of f(x);
    // it is an array of 2 tuples, each of them describing one component of the clause.
    // Each tuple is an (Int, Bool) pair:
    //  - the first element is the index of the variable xⱼ,
    //  - the second element is true if the variable is included as itself (xⱼ) and false if it is included as a negation (¬xⱼ)
    // 
    // Example 1:
    // The oracle from the task 4.2 (OR oracle x₀ ∨ x₁) can be represented as [[(0, true), (1, true)]].
    //
    // Example 2:
    // The oracle from the task 4.3 (XOR oracle x₀ ⊕ x₁) can be represented as [[(0, true), (1, true)], [(0, false), (1, false)]]
    //
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    //       Leave the query register in the same state it started in.
    operation Oracle_2SAT (queryRegister : Qubit[], 
                           target : Qubit, 
                           problem : (Int, Bool)[][]) : Unit
        is Adj {
            let N = Length(problem);
            using (anc = Qubit[N]) {
                // Or each set and save the result in ancilla sets
                for (i in 0..N-1) {
                    let (index1, isInvert1) = problem[i][0];
                    let (index2, isInvert2) = problem[i][1];
                    if (isInvert1 == false) {
                        X(queryRegister[index1]);
                    }
                    if (isInvert2 == false) {
                        X(queryRegister[index2]);
                    }
                    Oracle_Or([queryRegister[index1], queryRegister[index2]], anc[i]);
                    if (isInvert1 == false) {
                        X(queryRegister[index1]);
                    }
                    if (isInvert2 == false) {
                        X(queryRegister[index2]);
                    }
                }
                // Invert the target only when anc is |1...1>
                Controlled X(anc, target);
                // Reversing the action we took on ancillas
                for (i in 0..N-1) {
                    let (index1, isInvert1) = problem[i][0];
                    let (index2, isInvert2) = problem[i][1];
                    if (isInvert1 == false) {
                        X(queryRegister[index1]);
                    }
                    if (isInvert2 == false) {
                        X(queryRegister[index2]);
                    }
                    Oracle_Or([queryRegister[index1], queryRegister[index2]], anc[i]);
                    if (isInvert1 == false) {
                        X(queryRegister[index1]);
                    }
                    if (isInvert2 == false) {
                        X(queryRegister[index2]);
                    }
                }
            }
    }


    // Task 1.6. k-SAT problem oracle
    //
    // For k-SAT problems, f(x) is represented as a conjunction (an AND operation) of M clauses on N variables, 
    // and each clause is a disjunction (an OR operation) of one or several variables or negated variables:
    //      f(x) = ∧ᵢ (∨ₖ yᵢₖ), yᵢₖ = either xⱼ or ¬xⱼ for some j in {0, ..., N-1}
    //
    // Inputs:
    //      1) N qubits in an arbitrary state |x⟩ (input/query register)
    //      2) a qubit in an arbitrary state |y⟩ (target qubit)
    //      3) a 2-dimensional array of tuples "problem" which describes the SAT problem instance f(x).
    //
    // i-th element of "problem" describes the i-th clause of f(x);
    // it is an array of 2 tuples, each of them describing one component of the clause.
    // Each tuple is an (Int, Bool) pair:
    //  - the first element is the index of the variable xⱼ,
    //  - the second element is true if the variable is included as itself (xⱼ) and false if it is included as a negation (¬xⱼ)
    // 
    // Example:
    // A more general case on the OR oracle for 3 variables f(x) = (x₀ ∨ x₁ ∨ x₂) can be represented as [[(0, true), (1, true), (2, true)]].
    // 
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    //       Leave the query register in the same state it started in.
    operation Oracle_SAT (queryRegister : Qubit[], 
                          target : Qubit, 
                          problem : (Int, Bool)[][]) : Unit
        is Adj {        
            let N = Length(problem);
            using (anc = Qubit[N]) {
                // Or each set and save the result in ancilla sets
                for (i in 0..N-1) {
                    let L = Length(problem[i]);
                    using (anc1 = Qubit[L]) {
                        for (j in 0..L-1) {
                            let (index, isInvert) = problem[i][j];
                            if (isInvert == false) {
                                X(queryRegister[index]);
                            }
                            CNOT(queryRegister[index], anc1[j]);
                            if (isInvert == false) {
                                X(queryRegister[index]);
                            }
                        }
                        // Set anc[i] to 1 when any of the bit in anc1 is 1
                        (ControlledOnInt(0, X))(anc1, anc[i]);
                        X(anc[i]);
                        // Reverse actions we took on anc1
                        for (j in 0..L-1) {
                            let (index, isInvert) = problem[i][j];
                            if (isInvert == false) {
                                X(queryRegister[index]);
                            }
                            CNOT(queryRegister[index], anc1[j]);
                            if (isInvert == false) {
                                X(queryRegister[index]);
                            }
                        }
                    }
                }
                // Invert the target only when anc is |1...1>
                Controlled X(anc, target);
                // Reversing the action we took on ancillas
                for (i in 0..N-1) {
                    let L = Length(problem[i]);
                    using (anc1 = Qubit[L]) {
                        for (j in 0..L-1) {
                            let (index, isInvert) = problem[i][j];
                            if (isInvert == false) {
                                X(queryRegister[index]);
                            }
                            CNOT(queryRegister[index], anc1[j]);
                            if (isInvert == false) {
                                X(queryRegister[index]);
                            }
                        }
                        X(anc[i]);
                        (ControlledOnInt(0, X))(anc1, anc[i]);
                        // Reverse actions we took on anc1
                        for (j in 0..L-1) {
                            let (index, isInvert) = problem[i][j];
                            if (isInvert == false) {
                                X(queryRegister[index]);
                            }
                            CNOT(queryRegister[index], anc1[j]);
                            if (isInvert == false) {
                                X(queryRegister[index]);
                            }
                        }
                    }
                }
            }
    }


    //////////////////////////////////////////////////////////////////
    // Part II. Using Grover's algorithm for problems with multiple solutions
    //////////////////////////////////////////////////////////////////
    
    // Task 2.1. Using Grover's algorithm
    // Goal: Implement Grover's algorithm and use it to find solutions to SAT instances from part 1.
    // This task is not covered by a test and allows you to experiment with running the algorithm.
    //
    // If you want to learn the Grover's algorithm itself, try doing GroversAlgorithm kata first.
    operation E2E_GroversAlgorithm_Test () : Unit {

        // Hint: Experiment with SAT instances with different number of solutions and the number of algorithm iterations 
        // to see how the probability of the algorithm finding the correct answer changes depending on these two factors.
        // For example, 
        // - the AND oracle from task 1.1 has exactly one solution,
        // - the alternating bits oracle from task 1.4 has exactly two solutions,
        // - the OR oracle from task 1.2 for 2 qubits has exactly 3 solutions, and so on.

        // ...
    }
    

    // Task 2.2. Universal implementation of Grover's algorithm
    // Inputs: 
    //      1) the number of qubits N,
    //      2) a marking oracle which implements a boolean expression, similar to the oracles from section 1.
    // Output:
    //      An array of N boolean values which satisfy the expression implemented by the oracle
    //      (i.e., any basis state marked by the oracle).
    // 
    // Note that the similar task in the GroversAlgorithm kata required you to implement Grover's algorithm
    // in a way that would be robust to accidental failures, but you knew the optimal number of iterations
    // (the number that minimizes the probability of such failure). 
    // In this task you also need to make your implementation robust to not knowing the optimal number of iterations.
    operation GroversAlgorithm (N : Int, oracle : ((Qubit[], Qubit) => Unit is Adj)) : Bool[] {
        mutable result = new Bool[N];
        // using ((target, anc) = (Qubit[N], Qubit())) {
        //     ApplyToEach(H, target);
        //     for (i in 0..64) {
        //         // Phase shift for target x
        //         X(anc);
        //         H(anc);
        //         oracle(target, anc);
        //         H(anc);
        //         X(anc);
        //         ApplyToEach(H, target);
        //         ApplyToEach(X, target);
        //         Controlled Z(Most(target), Tail(target));
        //         ApplyToEach(X, target);
        //         ApplyToEach(H, target);
        //     }
        //     let res = MultiM(target);
        //     set result = BoolArrFromResultArr(res);
        //     ResetAll(target);
        // }
        return result;
    }
}
