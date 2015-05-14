theory mccarthy91_M1
imports Main
begin
  fun m :: "int => int" where
  "m x = (if x > 100 then x - 10 else m (m (x + 11)))"
  theorem x0 :
    "!! (n :: int) . (n <= 100) ==> ((m n) = 91)"
    oops
end
