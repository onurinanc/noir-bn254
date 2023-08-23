# noir-bn254

BN254 Elliptic Curve Pairing Library

- **This implementation has not been reviewed or audited. Use at your own risk.**
- This implementation targets Noir version 0.9.0 or higher
- This implementation currently requires **a specific fork https://github.com/onurinanc/noir-bigint` of noir-bigint library https://github.com/shuklaayush/noir-bigint**, workspace dependency will be added in the future for a better use

## How to test the library
1. Use following commands to use two libraries in your local

`git clone https://github.com/onurinanc/noir-bn254`

2. To add the noir-bigint dependency, use a forked version of https://github.com/shuklaayush/noir-bigint,

`git clone https://github.com/onurinanc/noir-bigint`

3. Test the files using the following commands inside the noir-bn254.
`nargo test`

## Documentation

### Curve Description and Usage
BN254 is a pairing-friendly elliptic curve construction. This includes two elliptic curve constructions which are G1: E(Fp) and G2: E(Fp^2).

G1 curve is `y^2 = x^3 + 3`
Field modulus is `21888242871839275222246405745257275088696311157297823662689037894645226208583`
The order of the elliptic curves is `21888242871839275222246405745257275088548364400416034343698204186575808495617`
The generator of the G1 is the (1, 2)

The method and parameters for constructing the G1 curve is in the src/bn254.nr

```
// Construct G1 curve for BN254
fn bn254() -> BN254 {
    BN254 {
        curve: Curve::new(
            Fp::zero(),
            Fp::from_u56(3),
            Point::from_affine( 
                Fp::from_u56(1),
                Fp::from_u56(2),
            ),
        ),
    }
}
```

G2 is constructed using the Fp^2 extension field. The method and the parameters for constructing the G2 curve is in the src/bn254.nr

```
// Construct G2 curve for BN254
fn bn254_g2() -> BN254G2 {
    // Construct a, b, and gen for G2 Curve
    // G2_A, G2_B_ G2_GENERATOR_X, and G2_GENERATOR_Y

    let G2_A = Fp2::zero();
    let G2_B: Fp2 = Fp2::new(
        Fp::from_bytes(
                    [
                        0xe5, 0x38, 0xa1, 0x24, 0xdc, 0xe6, 0x67, 0x32, 
                        0xa3, 0xef, 0xdb, 0x59, 0xe5, 0xc5, 0xb4, 0xb5, 
                        0xc3, 0x6a, 0xe0, 0x1b, 0x99, 0x18, 0xbe, 0x81, 
                        0xae, 0xaa, 0xb8, 0xce, 0x40, 0x9d, 0x14, 0x2b
                    ]
                ),
        Fp::from_bytes(
                    [
                        0xd2, 0x15, 0xc3, 0x85, 0x06, 0xbd, 0xa2, 0xe4, 
                        0x52, 0x18, 0x2d, 0xe5, 0x84, 0xa0, 0x4f, 0xa7, 
                        0xf4, 0xfd, 0xd8, 0xee, 0xad, 0xaf, 0x2c, 0xcd, 
                        0xd4, 0xfe, 0xf0, 0x3a, 0xb0, 0x13, 0x97, 0x00
                    ]
                )
    );
    let G2_GENERATOR_X: Fp2 = Fp2::new(
        Fp::from_bytes(
                    [
                        0xed, 0xf6, 0x92, 0xd9, 0x5c, 0xbd, 0xde, 0x46, 
                        0xdd, 0xda, 0x5e, 0xf7, 0xd4, 0x22, 0x43, 0x67, 
                        0x79, 0x44, 0x5c, 0x5e, 0x66, 0x00, 0x6a, 0x42, 
                        0x76, 0x1e, 0x1f, 0x12, 0xef, 0xde, 0x00, 0x18
                    ]
                ),
        Fp::from_bytes(
                    [
                        0xc2, 0x12, 0xf3, 0xae, 0xb7, 0x85, 0xe4, 0x97, 
                        0x12, 0xe7, 0xa9, 0x35, 0x33, 0x49, 0xaa, 0xf1, 
                        0x25, 0x5d, 0xfb, 0x31, 0xb7, 0xbf, 0x60, 0x72, 
                        0x3a, 0x48, 0x0d, 0x92, 0x93, 0x93, 0x8e, 0x19
                    ]
                )
    );

    let G2_GENERATOR_Y: Fp2 = Fp2::new(
        Fp::from_bytes(
                    [
                        0xaa, 0x7d, 0xfa, 0x66, 0x01, 0xcc, 0xe6, 0x4c, 
                        0x7b, 0xd3, 0x43, 0x0c, 0x69, 0xe7, 0xd1, 0xe3, 
                        0x8f, 0x40, 0xcb, 0x8d, 0x80, 0x71, 0xab, 0x4a, 
                        0xeb, 0x6d, 0x8c, 0xdb, 0xa5, 0x5e, 0xc8, 0x12
                    ]
                ),
        Fp::from_bytes(
                    [
                        0x5b, 0x97, 0x22, 0xd1, 0xdc, 0xda, 0xac, 0x55, 
                        0xf3, 0x8e, 0xb3, 0x70, 0x33, 0x31, 0x4b, 0xbc, 
                        0x95, 0x33, 0x0c, 0x69, 0xad, 0x99, 0x9e, 0xec, 
                        0x75, 0xf0, 0x5f, 0x58, 0xd0, 0x89, 0x06, 0x09
                    ]
                )
    );

    BN254G2 {
        curve: G2Curve::new(
            Fp2::zero(),
            G2_B,
            G2Point::from_affine(
                G2_GENERATOR_X,
                G2_GENERATOR_Y,
            )
        )
    }
}
```


You can create instances of the elliptic curves using

```
let g2: BN254G2 = bn254_g2();
let g1: BN254 = bn254();
```

You can test additions for G1 and G2 seperately using the following command in Noir

```
nargo test test_bn254_add1
nargo test test_bn254g2_add1
```

### Features
- fn pair(Q: G2Point, P: Point) -> Fp12

It's the pairing function. Q is an element of G2, and 
P is an element of G1.

- The `pair` calculates the pairing in Fp12

- `Point` is a point on the G1 curve
- `G2Point` is a point on the G2 curve

You can create Point and G2Point as the following function signatures

- `Point::from_affine(x: Fp, y: Fp)`
- `G2Point::from_affine(x: Fp2, y:Fp2)`

You can create Fp, Fp2, Fp6, Fp12 elements using the following examples

```
let fp_1 = Fp::from_bytes([
            0x61, 0x22, 0xfe, 0xd9,
            0x3d, 0xff,	0xf1, 0xcd,
            0x57, 0x5b,	0x9c, 0x0b,
            0xb4, 0x63,	0x9e, 0x31,
            0x75, 0x64,	0x08, 0x8d,
            0x7c, 0xdb,	0x4f, 0x55,
            0x29, 0x94,	0x48, 0xe0,
            0xbe, 0x99,	0xb7, 0x2a,
        ]);

let fp_2 = Fp::from_u56(8);

let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));

let a1: Fp6 = Fp6::new(a, b, c);
let a2: Fp6 = Fp6::new(a, a, b);
let a3: Fp6 = Fp6::new(b, c, c);
let a4: Fp6 = Fp6::new(c, b, a);

let x1: Fp12 = Fp12::new(a1, a4);
let x2: Fp12 = Fp12::new(a3, a2);
let x3: Fp12 = Fp12::new(a4, a2);
```

## Contributing

Contributions are welcome! Please adhere to the following guidelines:

- Open a pull request with a clear description of your changes.
- Changes should aim to improve code efficiency or readability.
- Add appropriate tests, ensuring all pass before submission.

## Disclaimer
This is an **experimental software** and is provided on an "as is" and "as available" basis. We **do not give any warranties** and **will not be liable for any losses** incurred through any use of this code base.