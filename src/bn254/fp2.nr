use dep::std::println;
use dep::bigint::prime_field::PrimeField as Fp;

struct Fp2 {
    c0: Fp,
    c1: Fp,
}

impl Fp2 {
    fn new(c0: Fp, c1: Fp) -> Self {
        Fp2{
            c0,
            c1,
        }
    }

    fn zero() -> Fp2 {
        Fp2{
            c0: Fp::zero(),
            c1: Fp::zero(),
        }
    }

    fn one() -> Fp2 {
        Fp2{
            c0: Fp::one(),
            c1: Fp::zero(),
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
        let t1 = self.c0.mul(other.c0);
        let t0 = self.c0.add(self.c1);
        let t2 = self.c1.mul(other.c1);
        let c1 = other.c0.add(other.c1);
        let c0 = t1.sub(t2);
        let t1 = t1.add(t2);
        let t0 = t0.mul(c1);
        let c1 = t0.sub(t1);

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
        let c0 = self.c1.neg();
        let c0 = c0.add(self.c0);
        let c0 = c0.mul(c0c1);
        let c0 = c0.sub(ab);

        Self {
            c0: c0.add(ab),
            c1: ab.double(),
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

    fn invert(self: Self) -> Self {
        let t0 = self.c0.mul(self.c0);
        let t1 = self.c1.mul(self.c1);
        let t0 = t0.add(t1);
        let t1 = t0.invert();
        let c0 = t1.mul(self.c0);
        let c1 = self.c1.mul(t1);
        let c1 = c1.neg();

        Self {
            c0,
            c1,
        }
    }




}