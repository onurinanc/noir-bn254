use dep::std::println;
use dep::bigint::prime_field::PrimeField as Fp;

mod fp2;
mod fp6;
mod fp12;
mod g2;
mod pairing;
mod swcurve;
mod constants;


use fp2::Fp2;
use fp6::Fp6;
use fp12::Fp12;
use g2::G2Point;
use g2::G2Curve;
use swcurve::Point;
use swcurve::Curve;

// G2 curve for BN254
struct BN254G2 {
    curve: G2Curve,
}

// G1 curve for BN254
struct BN254 {
    curve: Curve,
}

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

// O + O = O
#[test]
fn test_bn254_add1() {
    let BN254 { curve } = bn254();

    let p = curve.add(Point::zero(), Point::zero());
    assert(p.is_zero()); 
}

// O + G = G
#[test]
fn test_bn254_add2() {
    let BN254 { curve } = bn254();

    let p = curve.add(curve.gen, Point::zero());
    assert(p.eq(curve.gen));
}

// (2*G + G) + G = 4*G
#[test]
fn test_bn254_add3() {
    let BN254 { curve } = bn254();

    let p = curve.add(curve.double(curve.gen), curve.gen);
    let q = curve.add(curve.double(curve.gen), curve.double(curve.gen));
    let p_1 = curve.add(p, curve.gen);
    assert(p_1.eq(q));
}

// 2*G + G = 3*G
#[test]
fn test_bn254_add4() {
    let BN254 { curve } = bn254();

    let p1 = curve.add(curve.double(curve.gen), curve.gen);
    // p2 is the little endian representation of G * 3
    let p2 = Point::from_affine(
        Fp::from_bytes([
            0xf0, 0xab, 0x15, 0x19,
            0x96, 0x55,	0xd3, 0xf2,
            0x79, 0xe6, 0xb8, 0x15,
            0x47, 0xd8, 0x15, 0x93,
            0x15, 0xbd, 0xb6, 0xb1,
            0xbc, 0x32, 0x02, 0xf4,
            0x3f, 0xea, 0x6b, 0xc5,
            0x9a, 0xbf, 0x69, 0x07
        ]),
        Fp::from_bytes([
            0x61, 0x22, 0xfe, 0xd9,
            0x3d, 0xff,	0xf1, 0xcd,
            0x57, 0x5b,	0x9c, 0x0b,
            0xb4, 0x63,	0x9e, 0x31,
            0x75, 0x64,	0x08, 0x8d,
            0x7c, 0xdb,	0x4f, 0x55,
            0x29, 0x94,	0x48, 0xe0,
            0xbe, 0x99,	0xb7, 0x2a,
        ]),
    );
    
    assert(p1.eq(p2));
}

// 3*G = 3*G
#[test]
fn test_bn254_mul1() {
    let BN254 { curve } = bn254();

    let p1 = curve.mul_Field(3, curve.gen);

    // p2 is the little endian representation of G * 3
    let p2 = Point::from_affine(
        Fp::from_bytes([
            0xf0, 0xab, 0x15, 0x19,
            0x96, 0x55,	0xd3, 0xf2,
            0x79, 0xe6, 0xb8, 0x15,
            0x47, 0xd8, 0x15, 0x93,
            0x15, 0xbd, 0xb6, 0xb1,
            0xbc, 0x32, 0x02, 0xf4,
            0x3f, 0xea, 0x6b, 0xc5,
            0x9a, 0xbf, 0x69, 0x07
        ]),
        Fp::from_bytes([
            0x61, 0x22, 0xfe, 0xd9,
            0x3d, 0xff,	0xf1, 0xcd,
            0x57, 0x5b,	0x9c, 0x0b,
            0xb4, 0x63,	0x9e, 0x31,
            0x75, 0x64,	0x08, 0x8d,
            0x7c, 0xdb,	0x4f, 0x55,
            0x29, 0x94,	0x48, 0xe0,
            0xbe, 0x99,	0xb7, 0x2a,
        ]),
    );
    
    assert(p1.eq(p2));
}

// 3*G
#[test]
fn test_bn254_mul_Field1() {
    let BN254 { curve } = bn254();

    let x: Field = 3;
    let p1 = curve.mul_Field(x, curve.gen);

    // p2 is the little endian representation of G * 3
    let p2 = Point::from_affine(
        Fp::from_bytes([
            0xf0, 0xab, 0x15, 0x19,
            0x96, 0x55,	0xd3, 0xf2,
            0x79, 0xe6, 0xb8, 0x15,
            0x47, 0xd8, 0x15, 0x93,
            0x15, 0xbd, 0xb6, 0xb1,
            0xbc, 0x32, 0x02, 0xf4,
            0x3f, 0xea, 0x6b, 0xc5,
            0x9a, 0xbf, 0x69, 0x07
        ]),
        Fp::from_bytes([
            0x61, 0x22, 0xfe, 0xd9,
            0x3d, 0xff,	0xf1, 0xcd,
            0x57, 0x5b,	0x9c, 0x0b,
            0xb4, 0x63,	0x9e, 0x31,
            0x75, 0x64,	0x08, 0x8d,
            0x7c, 0xdb,	0x4f, 0x55,
            0x29, 0x94,	0x48, 0xe0,
            0xbe, 0x99,	0xb7, 0x2a,
        ]),
    );
    
    assert(p1.eq(p2));
}

// a + (b + c) == a + (c + b) == b + (c + a)
#[test]
fn test_fp2_add() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    
    let t0 = a.add(b.add(c));
    let t1 = a.add(c.add(b));
    let t2 = b.add(c.add(a));

    assert(t0.c0.eq(t1.c0));
    assert(t0.c0.eq(t2.c0));
    assert(t1.c0.eq(t2.c0));
    assert(t0.c1.eq(t1.c1));
    assert(t0.c1.eq(t2.c1));
    assert(t1.c1.eq(t2.c1));
}

// a * (b * c) == a * (c * b) = b * (c * a)
#[test]
fn test_fp2_mul() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));

    let t0 = a.mul(b.mul(c));
    let t1 = a.mul(c.mul(b));
    let t2 = b.mul(c.mul(a));

    assert(t0.c0.eq(t1.c0));
    assert(t0.c0.eq(t2.c0));
    assert(t1.c0.eq(t2.c0));
    assert(t0.c1.eq(t1.c1));
    assert(t0.c1.eq(t2.c1));
    assert(t1.c1.eq(t2.c1));
}

// a + a == 2*a
#[test]
fn test_fp2_double() {
    let a: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    let b = a.add(a);
    let c = a.double();

    assert(b.c0.eq(c.c0));
    assert(b.c1.eq(c.c1));
}

// a * a == a^2
#[test]
fn test_fp2_square() {
    let a: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    let b = a.mul(a);
    let c = a.square();

    assert(b.c0.eq(c.c0));
    assert(b.c1.eq(c.c1));
}

// (2+2u) * (9+u) = (16+20u)
#[test]
fn test_fp2_mul_by_nonresidue(){
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(1));
    let a = a.mul_by_nonresidue();
    Fp::println(a.c0);
    Fp::println(a.c1);
}

// a*a^-1 == O
#[test]
fn test_fp2_invert() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b = a.invert();
    let c = a.mul(b);
    assert(c.c0.eq(Fp::one()));
    Fp::println(c.c0);
    Fp::println(c.c1);
}

// a*a^-1 == O
#[test]
fn test_fp2_invert2() {
    let a: Fp2 = Fp2::new(Fp::from_u56(2347), Fp::from_u56(9812));
    let b = a.invert();
    let c = a.mul(b);
    //assert(c.c0.eq(Fp::one()));
    //assert(c.c1.eq(Fp::zero()));
    assert(c.eq(Fp2::one()));
    Fp::println(c.c0);
    Fp::println(c.c1);
}

// a + (b + c) == a + (c + b) == b + (c + a)
#[test]
fn test_fp6_add() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    
    let x1: Fp6 = Fp6::new(a, b, c);
    let x2: Fp6 = Fp6::new(a, a, b);
    let x3: Fp6 = Fp6::new(b, c, c);

    let t0 = x1.add(x2.add(x3));
    let t1 = x1.add(x3.add(x2));
    let t2 = x2.add(x3.add(x1));

    assert(t0.c0.eq(t1.c0));
    assert(t0.c0.eq(t2.c0));
    assert(t1.c0.eq(t2.c0));
    assert(t0.c1.eq(t1.c1));
    assert(t0.c1.eq(t2.c1));
    assert(t1.c1.eq(t2.c1));
    assert(t0.c2.eq(t1.c2));
    assert(t0.c2.eq(t2.c2));
    assert(t1.c2.eq(t2.c2));
}

// a * (b * c) == a * (c * b) = b * (c * a)
#[test]
fn test_fp6_mul() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    
    let x1: Fp6 = Fp6::new(a, b, c);
    let x2: Fp6 = Fp6::new(c, b, b);
    let x3: Fp6 = Fp6::new(b, c, c);

    let t0 = x1.mul(x2.mul(x3));
    let t1 = x1.mul(x3.mul(x2));
    let t2 = x2.mul(x3.mul(x1));

    assert(t0.c0.eq(t1.c0));
    assert(t0.c0.eq(t2.c0));
    assert(t1.c0.eq(t2.c0));
    assert(t0.c1.eq(t1.c1));
    assert(t0.c1.eq(t2.c1));
    assert(t1.c1.eq(t2.c1));
    assert(t0.c2.eq(t1.c2));
    assert(t0.c2.eq(t2.c2));
    assert(t1.c2.eq(t2.c2));
}

// a * O = O
#[test]
fn test_fp6_mul2() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    
    let x1: Fp6 = Fp6::new(a, b, c);
    let x2: Fp6 = Fp6::new(c, b, b);
    let x3: Fp6 = Fp6::new(b, c, c);

    let x = x1.mul(Fp6::one());
    assert(x.eq(x1));
}

// a + a == 2*a
#[test]
fn test_fp6_double() {
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    let d: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));

    let a: Fp6 = Fp6::new(b, c, d);
    let b = a.add(a);
    let c = a.double();

    assert(b.c0.eq(c.c0));
    assert(b.c1.eq(c.c1));
    assert(b.c2.eq(c.c2));
}

// a * a == a^2
#[test]
fn test_fp6_square() {
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    let d: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));

    let a: Fp6 = Fp6::new(b, c, d);
    let x = a.mul(a);
    let y = a.square();

    assert(x.c0.eq(y.c0));
    assert(x.c1.eq(y.c1));
    assert(x.c2.eq(y.c2));
}

// a*a^-1 == O
#[test]
fn test_fp6_invert() {
    let x: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let y: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    let z: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));

    let a = Fp6::new(x, y, z);
    let b = a.invert_x();
    let c = a.mul(b);

    // assert(c.eq(Fp6::one()));
    Fp::println(c.c0.c0);
    Fp::println(c.c0.c1);
    Fp::println(c.c1.c0);
    Fp::println(c.c1.c1);
    Fp::println(c.c2.c0);
    Fp::println(c.c2.c1);
}

// a + (b + c) == a + (c + b) == b + (c + a)
#[test]
fn test_fp12_add() {
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

    let t0 = x1.add(x2.add(x3));
    let t1 = x1.add(x3.add(x2));
    let t2 = x2.add(x3.add(x1));

    assert(t0.c0.eq(t1.c0));
    assert(t0.c0.eq(t2.c0));
    assert(t1.c0.eq(t2.c0));
    assert(t0.c1.eq(t1.c1));
    assert(t0.c1.eq(t2.c1));
    assert(t1.c1.eq(t2.c1));
}

// a * (b * c) == a * (c * b) = b * (c * a)
#[test]
fn test_fp12_mul() {
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

    let t0 = x1.mul(x2.mul(x3));
    let t1 = x1.mul(x3.mul(x2));
    let t2 = x2.mul(x3.mul(x1));

    assert(t0.c0.eq(t1.c0));
    assert(t0.c0.eq(t2.c0));
    assert(t1.c0.eq(t2.c0));
    assert(t0.c1.eq(t1.c1));
    assert(t0.c1.eq(t2.c1));
    assert(t1.c1.eq(t2.c1));
}

// a + a == 2*a
#[test]
fn test_fp12_double() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    
    let a1: Fp6 = Fp6::new(a, b, c);
    let a2: Fp6 = Fp6::new(a, a, b);
    let a3: Fp6 = Fp6::new(b, c, c);
    let a4: Fp6 = Fp6::new(c, b, a);

    let a: Fp12 = Fp12::new(a1, a4);

    let b = a.add(a);
    let c = a.double();

    assert(b.c0.eq(c.c0));
    assert(b.c1.eq(c.c1));
}

// a * a == a^2
#[test]
fn test_fp12_square() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    
    let a1: Fp6 = Fp6::new(a, b, c);
    let a2: Fp6 = Fp6::new(a, a, b);
    let a3: Fp6 = Fp6::new(b, c, c);
    let a4: Fp6 = Fp6::new(c, b, a);

    let a: Fp12 = Fp12::new(a1, a4);

    let b = a.mul(a);
    let c = a.square();

    assert(b.c0.eq(c.c0));
    assert(b.c1.eq(c.c1));
}

// a*a^-1 == O
#[test]
fn test_fp12_invert() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b: Fp2 = Fp2::new(Fp::from_u56(3), Fp::from_u56(5));
    let c: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    
    let a1: Fp6 = Fp6::new(a, b, c);
    let a2: Fp6 = Fp6::new(a, a, b);
    let a3: Fp6 = Fp6::new(b, c, a);
    let a4: Fp6 = Fp6::new(c, b, a);

    let a: Fp12 = Fp12::new(a1, a3);
    let d: Fp12 = Fp12::new(a2, a4);

    let b = a.invert();
    let c = a.mul(b);

    assert(c.eq(Fp12::one()));
}

// O + O = O
#[test]
fn test_bn254g2_add1() {
    let BN254G2 { curve } = bn254_g2();

    let p = curve.add(G2Point::zero(), G2Point::zero());
    assert(p.is_zero()); 
}

// O + G = G
#[test]
fn test_bn254g2_add2() {
    let BN254G2 { curve } = bn254_g2();

    let p = curve.add(curve.gen, G2Point::zero());
    assert(p.eq(curve.gen));
}

// (2*G + G) + G = (2*G + 2*G)
#[test]
fn test_bn254g2_add3() {
    let BN254G2 { curve } = bn254_g2();

    let p = curve.add(curve.double(curve.gen), curve.gen);
    let q = curve.add(curve.double(curve.gen), curve.double(curve.gen));
    let p_1 = curve.add(p, curve.gen);
    assert(p_1.eq(q));
}

// Basic invert function for Fp
#[test]
fn test_inversion() {
    let a = Fp::from_u56(8);
    let b = a.invert();
    let c = a.mul(b);
    assert(c.eq(Fp::one()));
}

// for i in 0..8 -> 2 minutes
// for i in 0..10 -> 3 minutes
// for i in 0..12 -> 4 minutes
// for i in 0..64 -> ~30 minutes
// 16 GB RAM, Intel Core i5-12450H
//#[test]
//fn test_miller_loop() {
//    let g2: BN254G2 = bn254_g2();
//    let g1: BN254 = bn254();
//
//    let res = pairing::miller_loop(g2.curve.gen, g1.curve.gen); 
//}


#[test]
fn test_fp12_final_exp() {
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
    
    let res = pairing::final_exponentiation(x1);
}

// ~33 minutes
// 16 GB RAM, Intel Core i5-12450H
//#[test]
//fn test_pairing_rough() {
//    let g2: BN254G2 = bn254_g2();
//    let g1: BN254 = bn254();
//
//    let res = pairing::pair(g2.curve.gen, g1.curve.gen);  
//}