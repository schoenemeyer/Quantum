﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;


    // tpye of test, number of qubits, abs(amplitude), phase
    newtype StatePreparationTestCases = (Int, Int, Double[], Double[]);

    function StatePreparationTestNormalizeInput(coefficients: Double[]) : Double[]{
        let nCoefficients = Length(coefficients);
        mutable norm = 0.0;
        mutable output = new Double[nCoefficients];
        for(idx in 0..nCoefficients-1){
            set norm = norm + coefficients[idx]*coefficients[idx];
        }
        for(idx in 0..nCoefficients-1){
            set output[idx] = coefficients[idx] / Sqrt(norm);
        }
        return output;
    }

    operation StatePreparationPositiveCoefficientsTest () : () {
        body{
            let tolerance = 10e-5;

            mutable testCases = new StatePreparationTestCases[100];
            mutable nTests = 0;

            // Test positive coefficients.
            set testCases[nTests] = StatePreparationTestCases(0, 1, [0.773761; 0.633478], [0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 2, [0.183017; 0.406973; 0.604925; 0.659502], [0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 3, [0.0986553; 0.359005; 0.465689; 0.467395; 0.419893; 0.118445; 0.461883; 0.149609], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 4, [0.271471; 0.0583654; 0.11639; 0.36112; 0.307383; 0.193371; 0.274151; 0.332542; 0.130172; 0.222546; 0.314879; 0.210704; 0.212429; 0.245518; 0.30666; 0.22773], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            // Test negative coefficients. Should give same probabilities as positive coefficients.
            set testCases[nTests] = StatePreparationTestCases(0, 1, [-0.773761; 0.633478], [0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 2, [0.183017; -0.406973; 0.604925; 0.659502], [0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 3, [0.0986553; -0.359005; 0.465689; -0.467395; 0.419893; 0.118445; -0.461883; 0.149609], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 4, [-0.271471; 0.0583654; 0.11639; 0.36112; -0.307383; 0.193371; -0.274151; 0.332542; 0.130172; 0.222546; 0.314879; -0.210704; 0.212429; 0.245518; -0.30666; -0.22773], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;

            // Test unnormalized coefficients
            set testCases[nTests] = StatePreparationTestCases(0, 3, [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445; 0.461883; 0.149609], new Double[0]);
            set nTests = nTests + 1;

            // Test missing coefficicients
            set testCases[nTests] = StatePreparationTestCases(0, 3, [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445], new Double[0]);
            set nTests = nTests + 1;

            // Loop over multiple qubit tests
            for(idxTest in 0..nTests-1){
                let (testType, nQubits, coefficientsAmplitude, coefficientsPhase) = testCases[idxTest];
                let nCoefficients = Length(coefficientsAmplitude);


                // Test negative coefficicients. Should give same results as positive coefficients.
                using(qubits = Qubit[nQubits]){
                    let qubitsBE = BigEndian(qubits);

                    if(testType == 0){
                        let op = StatePreparationPositiveCoefficients(coefficientsAmplitude);
                        op(qubitsBE);
                        let normalizedCoefficients = StatePreparationTestNormalizeInput(coefficientsAmplitude);
                        for(idxCoeff in 0..(nCoefficients-1)){
                            let amp = normalizedCoefficients[idxCoeff];
                            let prob = amp * amp;
                            AssertProbIntBE(idxCoeff, prob, qubitsBE, tolerance);
                        }
                    }
                    ResetAll(qubits);
                }
            }
        }
    }

    operation StatePreparationComplexCoefficientsTest () : () {
        body{
            let tolerance = 10e-8;

            mutable testCases = new StatePreparationTestCases[100];
            mutable nTests = 0;

            // Test phase factor on uniform superposition
            set testCases[nTests] = StatePreparationTestCases(0, 1, [1.0; 1.0], [0.01; -0.01]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 1, [1.0; 1.0], [0.01; -0.05]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(1, 1, [1.0; 1.0], [0.01; -0.01]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(1, 3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(1, 3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [PI(); PI(); PI(); PI(); PI(); PI(); PI(); PI()]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(1, 3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.01]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(1, 3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445; 0.461883; 0.149609]);
            set nTests = nTests + 1;

            // Loop over multiple qubit tests
            for(idxTest in 0..nTests-1){
                Message($"Test case {idxTest}");
                let (testType, nQubits, coefficientsAmplitude, coefficientsPhase) = testCases[idxTest];
                let nCoefficients = Length(coefficientsAmplitude);


                // Test negative coefficicients. Should give same results as positive coefficients.
                using(qubits = Qubit[nQubits]){
                    let qubitsBE = BigEndian(qubits);
                    mutable coefficients = new ComplexPolar[nCoefficients];
                    for(idxCoeff in 0..nCoefficients-1){
                        set coefficients[idxCoeff] = ComplexPolar(coefficientsAmplitude[idxCoeff], coefficientsPhase[idxCoeff]);
                    }
                    let normalizedCoefficients = StatePreparationTestNormalizeInput(coefficientsAmplitude);

                    if(testType == 0){
                        let phase = 0.5 * (coefficientsPhase[0]-coefficientsPhase[1]);
                        let amp = normalizedCoefficients[0];
                        let prob = amp * amp;
                        StatePreparationSBM(coefficients, qubitsBE);
                        //Exp([PauliZ], 0.123, qubitsBE);
                        //let control = new Qubit[0];
                        //StatePreparationSBM_ (coefficients, BigEndian(control), qubitsBE[0]); 

                        AssertProbIntBE(0, prob, qubitsBE, tolerance);
                        AssertProbIntBE(1, prob, qubitsBE, tolerance);
                        AssertPhase(phase, qubitsBE[0], tolerance);
                        ResetAll(qubits);
                    }


                    // Test phases on uniform superposition
                    if(testType == 1){
                        using(control = Qubit[1]){
                            for(repeats in 0..nCoefficients/2){
                                H(control[0]);
                                (Controlled StatePreparationSBM(coefficients, _))(control, qubitsBE);
                                X(control[0]);
                                (Controlled ApplyToEachCA(H, _))(control, qubitsBE);
                                X(control[0]);

                                for(idxCoeff in 0..(nCoefficients-1)){
                                    let amp = normalizedCoefficients[idxCoeff];
                                    let prob = amp * amp;
                                    AssertProbIntBE(idxCoeff, prob, qubitsBE, tolerance);
                                }

                                let indexMeasuredInteger = MeasureIntegerBE(qubitsBE);

                                let phase = coefficientsPhase[indexMeasuredInteger];
                                Message($"StatePreparationComplexCoefficientsTest: expected phase = {phase}.");
                                AssertPhase(-0.5 * phase, control[0], tolerance);

                                ResetAll(control);
                                ResetAll(qubits);
                            }
                        }
                    }

                    

                }


                    //mutable coefficients = new ComplexPolar[nCoefficients];
                 //   for(idxCoeff in 0..nCoefficients-1){
                 //       set coefficients[idxCoeff] = ComplexPolar(coefficientsAmplitude[idxCoeff], coefficientsPhase[idxCoeff]);
                 //   }

            }
        }
    }
}
