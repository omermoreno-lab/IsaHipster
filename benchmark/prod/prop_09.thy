theory prop_09
imports Main
        "../../IsaHipster"
begin
  datatype 'a list = Nil2 | Cons2 "'a" "'a list"
  datatype Nat = Z | S "Nat"
  fun drop :: "Nat => 'a list => 'a list" where
  "drop (Z) y = y"
  | "drop (S z) (Nil2) = Nil2"
  | "drop (S z) (Cons2 x2 x3) = drop z x3"
  hipster drop
  theorem x0 :
    "!! (x :: Nat) (y :: Nat) (z :: 'a list) (w :: Nat) .
       (drop w (drop x (drop y z))) = (drop y (drop x (drop w z)))"
    oops
end
