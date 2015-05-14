theory nat_acc_alt_mul_assoc
imports Main
begin
  datatype Nat = Z | S "Nat"
  fun accplus :: "Nat => Nat => Nat" where
  "accplus (Z) y = y"
  | "accplus (S z) y = accplus z (S y)"
  fun accaltmul :: "Nat => Nat => Nat" where
  "accaltmul (Z) y = Z"
  | "accaltmul (S z) (Z) = Z"
  | "accaltmul (S z) (S x2) =
       S (accplus z (accplus x2 (accaltmul z x2)))"
  theorem x0 :
    "!! (x :: Nat) (y :: Nat) (z :: Nat) .
       (accaltmul x (accaltmul y z)) = (accaltmul (accaltmul x y) z)"
    oops
end
