theory sort_MSortTDSorts
imports Main
begin
  datatype 'a list = nil | cons "'a" "'a list"
  fun ztake :: "int => 'a list => 'a list" where
  "ztake x y =
     (if x = 0 then nil else
        case y of
          | nil => y
          | cons z xs => cons z (ztake (x - 1) xs)
        end)"
  fun zlength :: "'a list => int" where
  "zlength (nil) = 0"
  | "zlength (cons y xs) = 1 + (zlength xs)"
  fun zdrop :: "int => 'a list => 'a list" where
  "zdrop x y =
     (if x = 0 then y else
        case y of
          | nil => y
          | cons z xs => zdrop (x - 1) xs
        end)"
  fun lmerge :: "int list => int list => int list" where
  "lmerge (nil) y = y"
  | "lmerge (cons z x2) (nil) = cons z x2"
  | "lmerge (cons z x2) (cons x3 x4) =
       (if z <= x3 then cons z (lmerge x2 (cons x3 x4)) else
          cons x3 (lmerge (cons z x2) x4))"
  fun msorttd :: "int list => int list" where
  "msorttd (nil) = nil"
  | "msorttd (cons y (nil)) = cons y (nil)"
  | "msorttd (cons y (cons x2 x3)) =
       lmerge
         (msorttd
            (ztake
               (div (zlength (cons y (cons x2 x3))) 2) (cons y (cons x2 x3))))
         (msorttd
            (zdrop
               (div (zlength (cons y (cons x2 x3))) 2) (cons y (cons x2 x3))))"
  fun and2 :: "bool => bool => bool" where
  "and2 True y = y"
  | "and2 False y = False"
  fun ordered :: "int list => bool" where
  "ordered (nil) = True"
  | "ordered (cons y (nil)) = True"
  | "ordered (cons y (cons y2 xs)) =
       and2 (y <= y2) (ordered (cons y2 xs))"
  theorem x0 :
    "!! (x :: int list) . ordered (msorttd x)"
    oops
end
