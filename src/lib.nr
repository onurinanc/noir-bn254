use dep::std;
use dep::bigint::prime_field::PrimeField as Fp;
use dep::bigint::prime_field_fq::PrimeField as Fq;

mod bn254;

struct BN254G1 {
    curve: CurveG1,
}

struct PointG1{
    x: Fp,
    y: Fp,
}

impl PointG1 {
    fn new(x: Fp, y: Fp) -> PointG1 {
        PointG1{
            x: x,
            y: y,
        }
    }

    fn negate(self :Self) -> Self {
        Self{
            x: self.x,
            y: self.y.neg(),
        }
    }
}

struct CurveG1{
    a: Fp,
    b: Fp,
    gen: PointG1,
}

impl CurveG1 {
    fn new(a: Fp, b: Fp, gen: PointG1) -> CurveG1 {
        // Check curve coefficients
        assert(!(Fp::from_u56(4).mul(a.square().mul(a)).add(Fp::from_u56(27).mul(b.square()))).is_zero());

        let curve = CurveG1{ a, b, gen };
        // gen should be on the curve
        //assert(curve.contains(gen)); // We can write the contains function later
        curve
    }

    fn add(self, p: PointG1, q: PointG1) -> PointG1 {
        let x1 = p.x;
        let y1 = p.y;
        let x2 = q.x;
        let y2 = q.y;

        if ((x1.eq(x2)) & (y1.eq(y2))) == true {
            self.double(p)
        } else if (x1.eq(x2)) == true {
            assert(1 == 0);
            PointG1{
                x: Fp::from_limbs([0, 0, 0, 0, 0]),
                y: Fp::from_limbs([0, 0, 0, 0, 0]),
            }
        } else {
            let y_sub = y2.sub(y1);
            let x_sub = x2.sub(x1);
            let x_sub_inv = x_sub.invert(); // No more fails due to inversion
            let l = y_sub.mul(x_sub_inv);
            let l_square = l.mul(l);
            let l_square_sub_x1 = l_square.sub(x1);
            let new_x = l_square_sub_x1.sub(x2);

            let neg_l = l.neg();
            let neg_l_mul_x = neg_l.mul(new_x);
            let l_mul_x1 = l.mul(x1);
            let l_mul_x1_sub_y1 = l_mul_x1.sub(y1);
            let new_y = neg_l_mul_x.add(l_mul_x1_sub_y1);

            PointG1{
                x: new_x,
                y: new_y,
            }
        }

        
    }

    fn double(self, p: PointG1) -> PointG1 {
        let x = p.x;
        let y = p.y;
        let x_square = x.mul(x);
        let x_square_times_3 = x_square.mul(Fp::from_limbs([3, 0, 0, 0, 0]));
        let y_times_2 = x.mul(Fp::from_limbs([2, 0, 0, 0, 0]));
        let y_times_2_inverse = y_times_2.invert();
        let l = x_square_times_3.mul(y_times_2_inverse);
        let l_square = l.mul(l);
        let two_x = x.mul(Fp::from_limbs([2, 0, 0, 0, 0]));
        let new_x = l_square.sub(two_x);
        let neg_l = l.neg();
        let neg_l_mul_x = neg_l.mul(new_x);
        let l_mul_x = l.mul(x);
        let l_mul_x_sub_y = l_mul_x.sub(y);
        let new_y = neg_l_mul_x.add(l_mul_x_sub_y);
        PointG1{
            x: new_x,
            y: new_y,
        }
    }

    fn sub(self, p: PointG1, q: PointG1) -> PointG1 {
        self.add(p, q.negate())
    }

    
}

#[test]
fn test_prime_field() {
    let modulus = Fp::modulus();
    let value = modulus.val;
    let limb0 = value.limbs[0];
    std::println(limb0);
}

#[test]
fn test_curve_g1(){
    let bn254_g1 = BN254G1{curve: CurveG1::new(
        Fp::from_limbs([1, 0, 0, 0, 0]),
        Fp::from_limbs([3, 0, 0, 0, 0]),
        PointG1{x: Fp::from_limbs([1, 0, 0, 0, 0]), y:Fp::from_limbs([2, 0, 0, 0, 0])},
    )};

    let a = bn254_g1.curve.a;
    let val = a.val;
    let limb = val.limbs[0];
    std::println(limb);
}

#[test]
fn test_add() {
    let bn254_g1 = BN254G1{curve: CurveG1::new(
        Fp::from_limbs([0, 0, 0, 0, 0]),
        Fp::from_limbs([3, 0, 0, 0, 0]),
        PointG1{x: Fp::from_limbs([1, 0, 0, 0, 0]), y:Fp::from_limbs([2, 0, 0, 0, 0])},
    )};
    let p1: PointG1 = bn254_g1.curve.gen;
    let p2: PointG1 = bn254_g1.curve.gen;
    let p1_double = bn254_g1.curve.double(p1);
    let res = bn254_g1.curve.add(p1, p2);
    // It works.

    assert(res.x.eq(p1_double.x));
    assert(res.y.eq(p1_double.y));

    // It works.
    //let a0 = res.x.val.limbs[0];
    //let a1 = res.y.val.limbs[0];
    //let b0 = p1_double.x.val.limbs[0];
    //let b1 = p1_double.y.val.limbs[0];
    //std::println(a0);
    //std::println(a1);
    //std::println(b0);
    //std::println(b1);
}

#[test]
fn test_add_2() {
    let bn254_g1 = BN254G1{curve: CurveG1::new(
        Fp::from_limbs([0, 0, 0, 0, 0]),
        Fp::from_limbs([3, 0, 0, 0, 0]),
        PointG1{x: Fp::from_limbs([1, 0, 0, 0, 0]), y:Fp::from_limbs([2, 0, 0, 0, 0])},
    )};

    let p1: PointG1 = bn254_g1.curve.gen;
    let p1_double = bn254_g1.curve.double(p1);
    let p1_double_4 = bn254_g1.curve.double(p1_double); // 4G
    let p1_3 = bn254_g1.curve.add(p1, p1_double); // 3G
    let p1_4 = bn254_g1.curve.add(p1_3, p1); //
    // Toplama fonksiyonu yanlış çalışıyor.
    
    //assert(p1_4.x.eq(p1_double_4.x));
    //assert(p1_4.y.eq(p1_double_4.y));

    let a0 = p1_4.x.val.limbs[0];
    let a1 = p1_4.y.val.limbs[0];
    let b0 = p1_double_4.x.val.limbs[0];
    let b1 = p1_double_4.y.val.limbs[0];
    std::println(a0);
    std::println(a1);
    std::println(b0);
    std::println(b1);
}

#[test]
fn test_add_3() {
    let bn254_g1 = BN254G1{curve: CurveG1::new(
        Fp::from_limbs([0, 0, 0, 0, 0]),
        Fp::from_limbs([3, 0, 0, 0, 0]),
        PointG1{x: Fp::from_limbs([1, 0, 0, 0, 0]), y:Fp::from_limbs([2, 0, 0, 0, 0])},
    )};

    let p1 = bn254_g1.curve.gen;
    let p1_2 = bn254_g1.curve.double(p1);
    let p1_4 = bn254_g1.curve.double(p1_2); // Bu 4G olması gerekiyor.

    let p1_3 = bn254_g1.curve.add(p1, p1_2); // Bu 3G olması gerekiyor.
    let p1_4_second = bn254_g1.curve.add(p1_3, p1); // BU 4G olması gerekiyor.

    assert(p1_4.x.eq(p1_4_second.x));
    assert(p1_4.y.eq(p1_4_second.y));
}

#[test]
fn test_double() {
    let bn254_g1 = BN254G1{curve: CurveG1::new(
        Fp::from_limbs([0, 0, 0, 0, 0]),
        Fp::from_limbs([3, 0, 0, 0, 0]),
        PointG1{x: Fp::from_limbs([1, 0, 0, 0, 0]), y:Fp::from_limbs([2, 0, 0, 0, 0])},
    )};

    let p1: PointG1 = bn254_g1.curve.gen;

    let p1_double = bn254_g1.curve.double(p1);
    let p1_4 = bn254_g1.curve.double(p1_double);
}

#[test]
fn test_sub() {

    let bn254_g1 = BN254G1{curve: CurveG1::new(
        Fp::from_limbs([0, 0, 0, 0, 0]),
        Fp::from_limbs([3, 0, 0, 0, 0]),
        PointG1{x: Fp::from_limbs([1, 0, 0, 0, 0]), y:Fp::from_limbs([2, 0, 0, 0, 0])},
    )};

    let p1: PointG1 = bn254_g1.curve.gen;
    let p1_double = bn254_g1.curve.double(p1);
    let res = bn254_g1.curve.sub(p1_double, p1);
    
    //assert(res.x.eq(p1.x));
    //assert(res.y.eq(p1.y));

    let a0 = res.x.val.limbs[0];
    let a1 = res.y.val.limbs[0];
    let b0 = p1.x.val.limbs[0];
    let b1 = p1.y.val.limbs[0];
    std::println(a0);
    std::println(a1);
    std::println(b0);
    std::println(b1); 
}

#[test]
fn test_prime_invert() {
    let bn254_g1 = BN254G1{curve: CurveG1::new(
        Fp::from_limbs([0, 0, 0, 0, 0]),
        Fp::from_limbs([3, 0, 0, 0, 0]),
        PointG1{x: Fp::from_limbs([1, 0, 0, 0, 0]), y:Fp::from_limbs([2, 0, 0, 0, 0])},
    )};

    let p1: PointG1 = bn254_g1.curve.gen;
    let p1_y_invert = p1.y.invert();
    let identity = p1_y_invert.mul(p1.y);
    let a = identity.val.limbs[0];

    std::println(a);

}