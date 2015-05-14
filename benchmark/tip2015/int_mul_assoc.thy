theory int_mul_assoc
imports Main
begin
  datatype Sign = Pos | Neg
  datatype Nat = Zero | Succ "Nat"
  datatype Z = P "Nat" | N "Nat"
  fun toInteger :: "Sign => Nat => Z" where
  "toInteger (Pos) y = P y"
  | "toInteger (Neg) (Zero) = P Zero"
  | "toInteger (Neg) (Succ m) = N m"
  fun sign2 :: "Z => Sign" where
  "sign2 (P y) = Pos"
  | "sign2 (N z) = Neg"
  fun plus :: "Nat => Nat => Nat" where
  "plus (Zero) y = y"
  | "plus (Succ n) y = Succ (plus n y)"
  fun opposite :: "Sign => Sign" where
  "opposite (Pos) = Neg"
  | "opposite (Neg) = Pos"
  fun timesSign :: "Sign => Sign => Sign" where
  "timesSign (Pos) y = y"
  | "timesSign (Neg) y = opposite y"
  fun mult :: "Nat => Nat => Nat" where
  "mult (Zero) y = Zero"
  | "mult (Succ n) y = plus y (mult n y)"
  fun absVal :: "Z => Nat" where
  "absVal (P n) = n"
  | "absVal (N m) = Succ m"
  fun times :: "Z => Z => Z" where
  "times x y =
     toInteger
       (timesSign (sign2 x) (sign2 y)) (mult (absVal x) (absVal y))"
  theorem x0 :
    "!! (x :: Z) (y :: Z) (z :: Z) .
       (times x (times y z)) = (times (times x y) z)"
    oops
end
