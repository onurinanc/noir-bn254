use dep::std::println;
use dep::bigint::prime_field::PrimeField as Fp;
use dep::bigint::prime_field_fq::PrimeField as Fq;

mod swcurve;
mod fp2;

use swcurve::Point;
use swcurve::Curve;
use fp2::Fp2;

struct BN254 {
    curve: Curve,
}

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

#[test]
fn test_bn254_add1() {
    let BN254 { curve } = bn254();

    let p = curve.add(Point::zero(), Point::zero());
    assert(p.is_zero()); 
}

#[test]
fn test_bn254_add2() {
    let BN254 { curve } = bn254();

    let p = curve.add(curve.gen, Point::zero());
    assert(p.eq(curve.gen));
}

#[test]
fn test_bn254_add3() {
    let BN254 { curve } = bn254();

    let p = curve.add(curve.double(curve.gen), curve.gen);
    let q = curve.add(curve.double(curve.gen), curve.double(curve.gen));
    let p_1 = curve.add(p, curve.gen);
    assert(p_1.eq(q));
}

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

#[test]
fn test_bn254_mul1() {
    let BN254 { curve } = bn254();

    let p1 = curve.mul(Fq::from_u56(3), curve.gen);

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

#[test]
fn test_fp2_double() {
    let a: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    let b = a.add(a);
    let c = a.double();

    assert(b.c0.eq(c.c0));
    assert(b.c1.eq(c.c1));
}

#[test]
fn test_fp2_square() {
    let a: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    let b = a.mul(a);
    let c = a.square();

    assert(b.c0.eq(c.c0));
    assert(b.c1.eq(c.c1));
}

#[test]
fn test_fp2_invert() {
    let a: Fp2 = Fp2::new(Fp::from_u56(1), Fp::from_u56(2));
    let b = a.invert();
    let c = a.mul(b);
    assert(c.c0.eq(Fp::one()));
}

#[test]
fn test_fp2_invert2() {
    let a: Fp2 = Fp2::new(Fp::from_u56(8), Fp::from_u56(11));
    let b = a.invert();
    let c = a.mul(b);
    assert(c.c0.eq(Fp::one()));
    assert(c.c1.eq(Fp::zero()));
    assert(c.eq(Fp2::one()));
}

#[test]
fn test_mul_bench() {
    // Works in ~5-10 minutes
    let BN254 { curve } = bn254();
    let mut out = curve.gen;
    let mut count = true;

    for i in 0..250 {
        let out = curve.double(out);
        let out = curve.add(out, curve.gen);
    }
}


#[test]
fn test_inversion() {
    let a = Fp::from_u56(8);
    let b = a.invert();
    let c = a.mul(b);
    assert(c.eq(Fp::one()));
}

// Try field methods
#[test]
fn test_field_methods() {
    let p_min_1: Field = 1;
    println(p_min_1);
    let x = p_min_1.to_le_bits(254);
    let a0 = x[0];
    let a1 = x[1];
    let a2 = x[2];
    println(a0);
    println(a1);
    println(a2);
}