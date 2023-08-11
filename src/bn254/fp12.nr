use dep::std::println;
use dep::bigint::prime_field::PrimeField as Fp;
use crate::bn254::fp6::Fp6;

struct Fp12 {
    c0: Fp6,
    c1: Fp6,
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
    fn invert_x(self: Self) -> Self {
        let t0 = self.c0.square();
        let t1 = self.c1.square();
        let t1 = t1.mul_by_nonresidue();
        let t0 = t0.sub(t1);
        let t1 = t0.invert();
        let c0 = self.c0.mul(t1);
        let c1 = self.c1.mul(t1);
        let c1 = c1.neg();

        Self {
            c0,
            c1,
        }
    }

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

   

}