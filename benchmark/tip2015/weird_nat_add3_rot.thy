theory weird_nat_add3_rot
imports Main
begin
  datatype Nat = Z | S "Nat"
  fun add3 :: "Nat => Nat => Nat => Nat" where
  "add3 (Z) (Z) z = z"
  | "add3 (Z) (S y2) z = S (add3 Z y2 z)"
  | "add3 (S x2) y z = S (add3 x2 y z)"
  theorem x0 :
    "!! (x :: Nat) (y :: Nat) (z :: Nat) . (add3 x y z) = (add3 y x z)"
    oops
end
