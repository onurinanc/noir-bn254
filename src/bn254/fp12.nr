use dep::std::println;
use dep::bigint::prime_field::PrimeField as Fp;
use crate::bn254::fp6::Fp6;

struct Fp12 {
    c0: Fp6,
    c1: Fp6
}

impl Fp12 {
    fn new(c0: Fp6, c1: Fp6) -> Self {
        Fp12{
            c0,
            c1,
        }
    }

    fn zero() -> Fp12 {
        Fp12{
            c0: Fp6::zero(),
            c1: Fp6::zero(),
        }
    }

    fn one() -> Fp12 {
        Fp12{
            c0: Fp6::one(),
            c1: Fp6::zero(),
        }
    }

    fn add(self: Self, other: Self) -> Self {
        Self{
            c0: self.c0.add(other.c0),
            c1: self.c1.add(other.c1),
        }
    }

    fn sub(self: Self, other: Self) -> Self {
        Self{
            c0: self.c0.sub(other.c0),
            c1: self.c1.sub(other.c1),
        }
    }

    fn mul(self: Self, other: Self) -> Self {
        let t0 = self.c0.mul(other.c0);
        let t1 = self.c1.mul(other.c1);
        let t2 = other.c0.add(other.c1);

        let c1 = self.c1.add(self.c0);
        let c1 = c1.mul(t2);
        let c1 = c1.sub(t0);
        let c1 = c1.sub(t1);

        let t1 = t1.mul_by_nonresidue();
        let c0 = t0.add(t1);

        Self{
            c0,
            c1,
        }
    }

    fn double(self: Self) -> Self {
        Self {
            c0: self.c0.double(),
            c1: self.c1.double(),
        }
    }

    fn square(self: Self) -> Self {
        let ab = self.c0.mul(self.c1);
        let c0c1 = self.c0.add(self.c1);
        let c0 = self.c1.mul_by_nonresidue();
        let c0 = c0.add(self.c0);
        let c0 = c0.mul(c0c1);
        let c0 = c0.sub(ab);

        let c1 = ab.add(ab);
        let tmp = ab.mul_by_nonresidue();
        let c0 = c0.sub(tmp);

        Self {
            c0,
            c1,
        }
    }

    fn neg(self: Self) -> Self {
        Self {
            c0: self.c0.neg(),
            c1: self.c1.neg(),
        }
    }

    fn conjugate(self: Self) -> Self {
        Self {
            c0: self.c0,
            c1: self.c1.neg(),
        }
    }

    fn eq(self: Self, other: Self) -> bool {
        self.c0.eq(other.c0) & self.c1.eq(other.c1)
    }
    
    fn is_zero(self: Self) -> bool {
        self.c0.is_zero() & self.c1.is_zero()
    }

    fn is_one(self: Self) -> bool {
        self.c0.is_one() & self.c1.is_zero()
    }

    // Algorithm 23 from: https://eprint.iacr.org/2010/354.pdf
    //fn invert_x(self: Self) -> Self {
    //    let t0 = self.c0.square();
    //    let t1 = self.c1.square();
    //    let t1 = t1.mul_by_nonresidue();
    //    let t0 = t0.sub(t1);
    //    let t1 = t0.invert();
    //    let c0 = self.c0.mul(t1);
    //    let c1 = self.c1.mul(t1);
    //    let c1 = c1.neg();
//
    //    Self {
    //        c0,
    //        c1,
    //    }
    //}

    fn invert(self: Self) -> Self {
        let c0s = self.c0.mul(self.c0);
        let c1s = self.c1.mul(self.c1);
        let c1s = c1s.mul_by_nonresidue();
        let c0s = c0s.sub(c1s);
        let c0 = c0s.invert();
        let c1 = c0s.invert();
        let c0 = c0.mul(self.c0);
        let c1 = c1.mul(self.c1);
        let c1 = c1.neg();

        Self{
            c0,
            c1,
        }
    }

    // Algorithm 28 from: https://eprint.iacr.org/2010/354.pdf
    fn frobenius(self: Self) -> Self {
        let t1 = self.c0.c0.conjugate();
        let t2 = self.c1.c0.conjugate();
        let t3 = self.c0.c1.conjugate();
        let t4 = self.c1.c1.conjugate();
        let t5 = self.c0.c2.conjugate();
        let t6 = self.c1.c2.conjugate();

        let t2 = t2.mul_by_non_residue_1_power_1();
        let t3 = t3.mul_by_non_residue_1_power_2();
        let t4 = t4.mul_by_non_residue_1_power_3();
        let t5 = t5.mul_by_non_residue_1_power_4();
        let t6 = t6.mul_by_non_residue_1_power_5();

        let c0 = Fp6::new(
            t1,
            t3,
            t5
        );

        let c1 = Fp6::new(
            t2,
            t4,
            t6
        );

        Self {
            c0,
            c1
        }
    }

    // Algorithm 29 from: https://eprint.iacr.org/2010/354.pdf
    fn frobenius_square(self: Self) -> Self {
        let t1 = self.c0.c0;
        let t2 = self.c1.c0.mul_by_non_residue_2_power_1();
        let t3 = self.c0.c1.mul_by_non_residue_2_power_2();
        let t4 = self.c1.c1.mul_by_non_residue_2_power_3();
        let t5 = self.c0.c2.mul_by_non_residue_2_power_4();
        let t6 = self.c1.c2.mul_by_non_residue_2_power_5();

        let c0 = Fp6::new(
            t1,
            t3,
            t5
        );

        let c1 = Fp6::new(
            t2,
            t4,
            t6
        );

        Self {
            c0,
            c1
        }
    }

    // Algorithm 30 from: https://eprint.iacr.org/2010/354.pdf
    fn frobenius_cube(self: Self) -> Self {
        let t1 = self.c0.c0.conjugate();
        let t2 = self.c1.c0.conjugate();
        let t3 = self.c0.c1.conjugate();
        let t4 = self.c1.c1.conjugate();
        let t5 = self.c0.c2.conjugate();
        let t6 = self.c1.c2.conjugate();

        let t2 = t2.mul_by_non_residue_3_power_1();
        let t3 = t3.mul_by_non_residue_3_power_2();
        let t4 = t4.mul_by_non_residue_3_power_3();
        let t5 = t5.mul_by_non_residue_3_power_4();
        let t6 = t6.mul_by_non_residue_3_power_5();

        let c0 = Fp6::new(
            t1,
            t3,
            t5
        );

        let c1 = Fp6::new(
            t2,
            t4,
            t6
        );

        Self {
            c0,
            c1
        }
    }

    fn cyclotomic_square(self: Self) -> Self {
        let t0 = self.c1.c1.square();
        let t1 = self.c0.c0.square();
        let t6 = self.c1.c1.add(self.c0.c0);
        let t6 = t6.square();
        let t6 = t6.sub(t0);
        let t6 = t6.sub(t1);
        let t2 = self.c0.c2.square();
        let t3 = self.c1.c0.square();
        let t7 = self.c0.c2.add(self.c1.c0);
        let t7 = t7.square();
        let t7 = t7.sub(t2);
        let t7 = t7.sub(t3);
        let t4 = self.c1.c2.square();
        let t5 = self.c0.c1.square();
        let t8 = self.c1.c2.add(self.c0.c1);
        let t8 = t8.square();
        let t8 = t8.sub(t4);
        let t8 = t8.sub(t5);
        let t8 = t8.mul_by_nonresidue();

        let t0 = t0.mul_by_nonresidue();
        let t0 = t0.add(t1);
        let t2 = t2.mul_by_nonresidue();
        let t2 = t2.add(t3);
        let t4 = t4.mul_by_nonresidue();
        let t4 = t4.add(t5);

        let c0c0 = t0.sub(self.c0.c0);
        let c0c0 = c0c0.double();
        let c0c0 = c0c0.add(t0);

        let c0c1 = t2.sub(self.c0.c1);
        let c0c1 = c0c1.double();
        let c0c1 = c0c1.add(t2);

        let c0c2 = t4.sub(self.c0.c2);
        let c0c2 = c0c2.double();
        let c0c2 = c0c2.add(t4);

        let c1c0 = t8.add(self.c1.c0);
        let c1c0 = c1c0.double();
        let c1c0 = c1c0.add(t8);

        let c1c1 = t6.add(self.c1.c1);
        let c1c1 = c1c1.double();
        let c1c1 = c1c1.add(t6);

        let c1c2 = t7.add(self.c1.c2);
        let c1c2 = c1c2.double();
        let c1c1 = c1c2.add(t7);

        let c0 = Fp6::new(
            c0c0,
            c0c1,
            c0c2
        );

        let c1 = Fp6::new(
            c1c0,
            c1c1,
            c1c2
        );

        Self {
            c0,
            c1
        }
    }

    fn n_square(self: Self, N: comptime Field) -> Self {
        let mut out = self;

        for i in 0..2 {
            out = out.cyclotomic_square();
        }

        out
    }



    fn exponentiation(self: Self) -> Self {
        let six: comptime Field = 6;
        let seven: comptime Field = 7;
        let eight: comptime Field = 8;
        let ten: comptime Field = 10;

        let t3 = self.cyclotomic_square();
        let t5 = t3.cyclotomic_square();
        let result = t5.cyclotomic_square();
        let t0 = result.cyclotomic_square();
        let t2 = self.mul(t0);
        let t0 = t2.mul(t3);
        let t1 = self.mul(t0);
        let t4 = result.mul(t2);
        let t6 = t2.cyclotomic_square();
        let t1 = t1.mul(t0);
        let t0 = t1.mul(t3);
        let t6 = t6.n_square(six);
        let t5 = t5.mul(t6);
        let t5 = t4.mul(t5);
        let t5 = t5.n_square(seven);
        let t4 = t4.mul(t5);
        let t4 = t4.n_square(eight);
        let t4 = t4.mul(t0);
        let t3 = t3.mul(t4);
        let t3 = t3.n_square(six);
        let t2 = t2.mul(t3);
        let t2 = t2.n_square(eight);
        let t2 = t0.mul(t2);
        let t2 = t2.n_square(six);
        let t2 = t0.mul(t2);
        let t2 = t2.n_square(ten);
        let t1 = t1.mul(t2);
        let t1 = t1.n_square(six);
        let t0 = t0.mul(t1);
        let result = result.mul(t0);
        result
    }
}