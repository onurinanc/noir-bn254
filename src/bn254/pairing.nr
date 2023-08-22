use dep::std::println;

use dep::bigint::prime_field::PrimeField as Fp;
use dep::bigint::prime_field_fq::PrimeField as Fq;

use crate::bn254::swcurve::Point;
use crate::bn254::fp12::Fp12;
use crate::bn254::fp6::Fp6;
use crate::bn254::fp2::Fp2;
use crate::bn254::g2::G2Point;
use crate::bn254::constants::NAF_DIGIT;

struct LineEval {
    l: Fp12,
    T: G2Point,
}

// Algorithm 26 from: https://eprint.iacr.org/2010/354.pdf
fn line_function_double_point(q: G2Point, p: Point) -> LineEval {
    let tmp0 = q.x.square();
    let tmp1 = q.y.square();
    let tmp2 = tmp1.square();
    let x = tmp1.add(q.x);
    let x = x.square();
    let x = x.sub(tmp0);
    let tmp3 = x.sub(tmp2);
    let tmp3 = tmp3.double();
    let tmp4 = tmp0.add(tmp0.double());
    let tmp6 = q.x.add(tmp4);
    let tmp5 = tmp4.square();
    let X_T = tmp5.sub(tmp3.double());
    let Z_T = q.y.add(q.z);
    let Z_T = Z_T.square();
    let Z_T = Z_T.sub(tmp1);
    let Z_T = Z_T.sub(q.z.square());
    let Y_T = tmp3.sub(X_T);
    let Y_T = Y_T.mul(tmp4);
    let tmp2_8 = tmp2.double();
    let tmp2_8 = tmp2_8.double();
    let tmp2_8 = tmp2_8.double();
    let Y_T = Y_T.sub(tmp2_8);
    let tmp3 = tmp4.mul(q.z.double());
    let tmp3 = tmp3.double();
    let tmp3 = tmp3.neg();
    let tmp3 = tmp3.mul_by_b0(p.x); 
    let tmp6 = tmp6.square();
    let tmp6 = tmp6.sub(tmp0);
    let tmp6 = tmp6.sub(tmp5);
    let tmp1_4 = tmp1.double();
    let tmp1_4 = tmp1_4.double();
    let tmp6 = tmp6.sub(tmp1_4);
    let tmp0 = Z_T.mul(q.z.square());
    let tmp0 = tmp0.double();
    let tmp0 = tmp0.mul_by_b0(p.y);
    let a0 = Fp6::new(
        tmp0,
        Fp2::zero(),
        Fp2::zero(),
    );

    let a1 = Fp6::new(
        tmp3,
        tmp6,
        Fp2::zero(),
    );

    let l = Fp12::new(
        a0,
        a1,
    );

    let T = G2Point{
        x: X_T,
        y: Y_T,
        z: Z_T,
    };

    LineEval{
        l,
        T,
    }
}

// Algorithm 27 from: https://eprint.iacr.org/2010/354.pdf
fn line_function_add_point(q: G2Point, r: G2Point, p: Point) -> LineEval {
    let t0 = q.x.mul(r.z.square());
    let t1 = q.y.add(r.z);
    let t1 = t1.square();
    let t1 = t1.sub(q.y.square());
    let t1 = t1.sub(r.z.square());
    let t1 = t1.mul(r.z.square());
    let t2 = t0.sub(r.x);
    let t3 = t2.square();
    let t4 = t3.double();
    let t4 = t4.double();
    let t5 = t4.mul(t2);
    let t6 = t1.sub(r.y.double());
    let t9 = t6.mul(q.x);
    let t7 = r.x.mul(t4);
    let X_T = t6.square();
    let X_T = X_T.sub(t5);
    let X_T = X_T.sub(t7.double());
    let Z_T = r.z.add(t2);
    let Z_T = Z_T.square();
    let Z_T = Z_T.sub(r.z.square());
    let Z_T = Z_T.sub(t3);
    let t10 = q.y.add(Z_T);
    let t8 = t7.sub(X_T);
    let t8 = t8.mul(t6);
    let t0 = r.y.mul(t5);
    let t0 = t0.double();
    let Y_T = t8.sub(t0);
    let t10 = t10.square();
    let t10 = t10.sub(q.y.square());
    let t10 = t10.sub(Z_T.square());
    let t9 = t9.double();
    let t9 = t9.sub(t10);
    let t10 = Z_T.mul_by_b0(p.y);
    let t10 = t10.double();
    let t6 = t6.neg();
    let t1 = t6.mul_by_b0(p.x);
    let t1 = t1.double();

    let l0 = Fp6::new(
        t10,
        Fp2::zero(),
        Fp2::zero(),
    );

    let l1 = Fp6::new(
        t1,
        t9,
        Fp2::zero(),
    );

    let l = Fp12::new(
        l0,
        l1,
    );

    let T = G2Point{
        x: X_T,
        y: Y_T,
        z: Z_T,
    };

    LineEval{
        l,
        T,
    }
}

fn final_exponentiation(z: Fp12) -> Fp12 {
    // Easy part

    let result = z;
    let t0 = z.conjugate();
    let result = result.invert();
    let t0 = t0.mul(result);
    let result = t0.frobenius_square();
    let result = result.mul(t0);

    // Hard part
    // https://eprint.iacr.org/2015/192.pdf

    let t0 = result.exponentiation();
    let t0 = t0.conjugate();
    let t0 = t0.cyclotomic_square();
    let t2 = t0.exponentiation();
    let t2 = t2.conjugate();
    let t1 = t2.cyclotomic_square();
    let t2 = t2.mul(t1);
    let t2 = t2.mul(result);
    let t1 = t2.exponentiation();
    let t1 = t1.cyclotomic_square();
    let t1 = t1.mul(t2);
    let t1 = t1.conjugate();
    let t3 = t1.conjugate();
    let t1 = t0.cyclotomic_square();
    let t1 = t1.mul(result);
    let t1 = t1.conjugate();
    let t1 = t1.mul(t3);
    let t0 = t0.mul(t1);
    let t2 = t2.mul(t1);
    let t3 = t1.frobenius_square();
    let t2 = t2.mul(t3);
    let t3 = result.conjugate();
    let t3 = t3.mul(t0);
    let t1 = t3.frobenius_cube();
    let t2 = t2.mul(t1);
    let t1 = t0.frobenius();
    let t1 = t1.mul(t2);
    t1
}

fn miller_loop(Q: G2Point, P: Point) -> Fp12 {
    let mut T = Q;
    let mut f = Fp12::one();

    for i in 0..64 {
        let line_evaluated = line_function_double_point(T, P);
        f = f.square();
        f = f.mul(line_evaluated.l);
        T = line_evaluated.T;

        if NAF_DIGIT[i] == 2 {
            let Q_NEG = Q.negate();
            let line_evaluated = line_function_add_point(T, Q_NEG, P);
            f = f.mul(line_evaluated.l);
            T = line_evaluated.T;
        } else if NAF_DIGIT[i] == 1 {
            let line_evaluated = line_function_add_point(T, Q, P);
            f = f.mul(line_evaluated.l);
            T = line_evaluated.T;
        }
    }

    // Q1 <- pi_p(Q)
    let q1x = Q.x.conjugate();
    let q1y = Q.y.conjugate();
    let q1x = q1x.mul_by_non_residue_1_power_2();
    let q1y = q1y.mul_by_non_residue_1_power_3();
    let Q1 = G2Point::from_affine(q1x, q1y);

    // Q2 <- pi_p_square(Q);
    let q2x = Q.x.mul_by_non_residue_2_power_2();
    let q2y = Q.y.mul_by_non_residue_2_power_3();
    let q2y = q2y.neg();
    // Q2 is negated above to use directly in the line_function
    let Q2 = G2Point::from_affine(q2x, q2y);

    // Line eval with Q1
    let line_evaluated = line_function_add_point(T, Q1, P);
    f = f.mul(line_evaluated.l);
    T = line_evaluated.T;

    // Line eval with Q2
    let line_evaluated = line_function_add_point(T, Q2, P);
    let f = f.mul(line_evaluated.l);
    f
}

fn pair(Q: G2Point, P: Point) -> Fp12 {
    let res = miller_loop(Q, P);
    let res = final_exponentiation(res);
    res
}

