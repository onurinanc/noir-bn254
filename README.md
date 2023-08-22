# noir-bn254

BN254 Elliptic Curve Pairing Library

## Information

(This library has a dependency of https://github.com/shuklaayush/noir-bigint However, due to a current issue, we need to add past version of noir-bigint library)

## How to use it
Use following commands to use two libraries in your local

`git clone https://github.com/onurinanc/noir-bn254`

To add the noir-bigint dependency, use a forked version of https://github.com/shuklaayush/noir-bigint,

`git clone https://github.com/onurinanc/noir-bigint`

Test the files using the following commands.
`nargo test`

## Methods
- fn pair(Q: G2Point, P: Point) -> Fp12

It's the pairing function.
Q is an element of G2
P is an element of G1
`pair` calculates the pairing in Fp12