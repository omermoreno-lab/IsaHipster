theory sort_NMSortTDPermutes'
imports Main
begin
  datatype 'a list = nil | cons "'a" "'a list"
  datatype Nat = Z | S "Nat"
  fun take :: "Nat => 'a list => 'a list" where
  "take (Z) y = nil"
  | "take (S z) (nil) = nil"
  | "take (S z) (cons x2 x3) = cons x2 (take z x3)"
  fun or2 :: "bool => bool => bool" where
  "or2 True y = True"
  | "or2 False y = y"
  fun null :: "'t list => bool" where
  "null (nil) = True"
  | "null (cons y z) = False"
  fun lmerge :: "int list => int list => int list" where
  "lmerge (nil) y = y"
  | "lmerge (cons z x2) (nil) = cons z x2"
  | "lmerge (cons z x2) (cons x3 x4) =
       (if z <= x3 then cons z (lmerge x2 (cons x3 x4)) else
          cons x3 (lmerge (cons z x2) x4))"
  fun length :: "'t list => Nat" where
  "length (nil) = Z"
  | "length (cons y xs) = S (length xs)"
  fun half :: "Nat => Nat" where
  "half (Z) = Z"
  | "half (S (Z)) = Z"
  | "half (S (S n)) = S (half n)"
  fun elem :: "int => int list => bool" where
  "elem x (nil) = False"
  | "elem x (cons z ys) = or2 (x = z) (elem x ys)"
  fun drop :: "Nat => 'a list => 'a list" where
  "drop (Z) y = y"
  | "drop (S z) (nil) = nil"
  | "drop (S z) (cons x2 x3) = drop z x3"
  fun nmsorttd :: "int list => int list" where
  "nmsorttd (nil) = nil"
  | "nmsorttd (cons y (nil)) = cons y (nil)"
  | "nmsorttd (cons y (cons x2 x3)) =
       lmerge
         (nmsorttd
            (take (half (length (cons y (cons x2 x3)))) (cons y (cons x2 x3))))
         (nmsorttd
            (drop
               (half (length (cons y (cons x2 x3)))) (cons y (cons x2 x3))))"
  fun delete :: "int => int list => int list" where
  "delete x (nil) = nil"
  | "delete x (cons z ys) =
       (if x = z then ys else cons z (delete x ys))"
  fun and2 :: "bool => bool => bool" where
  "and2 True y = y"
  | "and2 False y = False"
  fun isPermutation :: "int list => int list => bool" where
  "isPermutation (nil) y = null y"
  | "isPermutation (cons z xs) y =
       and2 (elem z y) (isPermutation xs (delete z y))"
  theorem x0 :
    "!! (x :: int list) . isPermutation (nmsorttd x) x"
    oops
end
