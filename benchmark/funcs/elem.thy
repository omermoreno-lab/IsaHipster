theory elem
imports Main
        "../data/Natu"
        "../data/list"
        "../funcs/equal"
        "../funcs/append"

        "../../IsaHipster"

begin

fun elem :: "Nat => Nat list => bool" where
  "elem x (Nil2) = False"
| "elem x (Cons2 z xs) = (if equal2 x z then True else elem x xs)"

hipster elem append

hipster_cond elem append elem
end

