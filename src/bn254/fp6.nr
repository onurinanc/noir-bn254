use dep::std::println;
use dep::bigint::prime_field::PrimeField as Fp;
use crate::bn254::fp2::Fp2;

// c0 + c1 * v + c2 * v^2
struct Fp6 {
    c0: Fp2,
    c1: Fp2,
    c2: Fp2,
}

impl Fp6 {
    fn new(c0: Fp2, c1: Fp2, c2: Fp2) -> Self {
        Fp6{
            c0,
            c1,
            c2,
        }
    }

    fn zero() -> Fp6 {
        Fp6{
            c0: Fp2::zero(),
            c1: Fp2::zero(),
            c2: Fp2::zero(),
        }
    }

    fn one() -> Fp6 {
        Fp6{
            c0: Fp2::one(),
            c1: Fp2::zero(),
            c2: Fp2::zero(),
        }
    }

    fn add(self: Self, other: Self) -> Self {
        Self{
            c0: self.c0.add(other.c0),
            c1: self.c1.add(other.c1),
            c2: self.c2.add(other.c2),
        }
    }

    fn sub(self: Self, other: Self) -> Self {
        Self{
            c0: self.c0.sub(other.c0),
            c1: self.c1.sub(other.c1),
            c2: self.c2.sub(other.c2),
        }
    }

    fn mul(self: Self, other: Self) -> Self {
        let a_a = self.c0.mul(other.c0);
        let b_b = self.c1.mul(other.c1);
        let c_c = self.c2.mul(other.c2);

        // Construct t1
        let t1 = other.c1;
        let t1 = t1.add(other.c2);

        let tmp = self.c1.add(self.c2);
        let t1 = t1.mul(tmp);
        let t1 = t1.sub(b_b);
        let t1 = t1.sub(c_c);
        let t1 = t1.mul_by_nonresidue();
        let t1 = t1.add(a_a);

        // Construct t3
        let t3 = other.c0;
        let t3 = t3.add(other.c2);

        let tmp = self.c0.add(self.c2);
        let t3 = t3.mul(tmp);
        let t3 = t3.sub(a_a);
        let t3 = t3.add(b_b);
        let t3 = t3.sub(c_c);

        // Construct t2
        let t2 = other.c0;
        let t2 = t2.add(other.c1);

        let tmp = self.c0.add(self.c1);
        let t2 = t2.mul(tmp);
        let t2 = t2.sub(a_a);
        let t2 = t2.sub(b_b);
        let c_c_mul_by_nonres = c_c.mul_by_nonresidue();
        let t2 = t2.add(c_c_mul_by_nonres);

        Self{
            c0: t1,
            c1: t2,
            c2: t3,
        }
    }

    fn double(self: Self) -> Self {
        Self {
            c0: self.c0.double(),
            c1: self.c1.double(),
            c2: self.c2.double(),
        }
    }

    // Algorithm 16 from: https://eprint.iacr.org/2010/354.pdf
    fn square(self: Self) -> Self {
        let c4 = self.c0.mul(self.c1);
        let c4 = c4.double();
        let c5 = self.c2.square();
        let tmp = c5.mul_by_nonresidue();
        let c1 = tmp.add(c4);
        let c2 = c4.sub(c5);
        let c3 = self.c0.square();
        let c4 = self.c0.sub(self.c1);
        let c4 = c4.add(self.c2);
        let c5 = self.c1.mul(self.c2);
        let c5 = c5.double();
        let c4 = c4.square();
        let tmp = c5.mul_by_nonresidue();
        let c0 = tmp.add(c3);
        let c2 = c2.add(c4);
        let c2 = c2.add(c5);
        let c2 = c2.sub(c3);

        Self{
            c0,
            c1,
            c2,
        }
    }

    fn neg(self: Self) -> Self {
        Self {
            c0: self.c0.neg(),
            c1: self.c1.neg(),
            c2: self.c2.neg(),
        }
    }

    fn eq(self: Self, other: Self) -> bool {
        self.c0.eq(other.c0) & self.c1.eq(other.c1) & self.c2.eq(other.c2)
    }
    
    fn is_zero(self: Self) -> bool {
        self.c0.is_zero() & self.c1.is_zero() & self.c2.is_zero()
    }

    fn is_one(self: Self) -> bool {
        self.c0.is_one() & self.c1.is_zero() & self.c2.is_zero()
    }

    fn invert(self: Self) -> Self {
        let c0 = self.c2;
        let c0 = c0.mul_by_nonresidue();
        let c0 = c0.mul(self.c1);
        let c0 = c0.neg();

        let c0s = self.c0;
        let c0s = c0s.square();
        let c0 = c0.add(c0s);

        let c1 = self.c2;
        let c1 = c1.square();
        let c1 = c1.mul_by_nonresidue();

        let c01 = self.c0;
        let c01 = c01.mul(self.c1);
        let c1 = c1.sub(c01);

        let c2 = self.c1;
        let c2 = c2.square();
        let c02 = self.c0;
        let c02 = c02.mul(self.c2);
        let c2 = c2.sub(c02);

        let tmp1 = self.c2;
        let tmp1 = tmp1.mul(c1);
        let tmp2 = self.c1;
        let tmp2 = tmp2.mul(c2);
        let tmp1 = tmp1.add(tmp2);
        let tmp1 = tmp1.mul_by_nonresidue();
        let tmp2 = self.c0;
        let tmp2 = tmp2.mul(c0);
        let tmp1 = tmp1.add(tmp2);

        let tmp = tmp1.invert();
        let c0 = tmp.mul(c0);
        let c1 = tmp.mul(c1);
        let c2 = tmp.mul(c2);

        Self {
            c0,
            c1,
            c2,
        }
    }

    // Algorithm 17 from: https://eprint.iacr.org/2010/354.pdf
    // Something works wrong here
    fn invert_x(self: Self) -> Self {
        let t0 = self.c0.square();
        let t1 = self.c1.square();
        let t2 = self.c2.square();

        let t3 = self.c0.mul(self.c1);
        let t4 = self.c0.mul(self.c2);
        let t5 = self.c2.mul(self.c1);

        let tmp = t5.mul_by_nonresidue();
        let c0 = t0.sub(tmp);
        
        let tmp = t2.mul_by_nonresidue();
        let c1 = tmp.sub(t3);

        let c2 = t1.mul(t4);

        let t6 = self.c0.mul(c0);

        let tmp = self.c2.mul(c1);
        let tmp = tmp.mul_by_nonresidue();
        let t6 = t6.add(tmp);

        let tmp = self.c1.mul(c2);
        let tmp = tmp.mul_by_nonresidue();
        let t6 = t6.add(tmp);

        let t6 = t6.invert();

        let c0 = c0.mul(t6);
        let c1 = c1.mul(t6);
        let c2 = c2.mul(t6);

        Self {
            c0,
            c1,
            c2,
        }
    }

    // Multiply by cubic nonresidue v
    // c0, c1, c2 -> c2, c0, c1
    fn mul_by_nonresidue(self: Self) -> Self {
        let c0 = self.c2.mul_by_nonresidue();
        let c1 = self.c0;
        let c2 = self.c1;

        Self{
            c0,
            c1,
            c2,
        }
    }
}