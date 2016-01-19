theory SmallListDemo
imports "$HIPSTER_HOME/IsaHipster"
begin

(* Currently works poorly: Don't seem to get Sledgehammer to pick up theorems that's been 
   discovered during the same theory exploration round.
 *) 

datatype 'a Lst = 
  Emp
  | Cons "'a" "'a Lst"

fun app :: "'a Lst \<Rightarrow> 'a Lst \<Rightarrow> 'a Lst" 
where 
  "app Emp xs = xs"
| "app (Cons x xs) ys = Cons x (app xs ys)"

fun rev :: "'a Lst \<Rightarrow> 'a Lst"
where 
  "rev Emp = Emp"
| "rev (Cons x xs) = app (rev xs) (Cons x Emp)"

(* hipster app rev FIXME: Outrageously slow with Sledgehammer. *)

lemma lemma_a [thy_expl]: "app x Emp = x"
apply (induction x)
apply simp
by simp

lemma lemma_aa [thy_expl]: "app (app x y) z = app x (app y z)"
apply (induction x)
apply simp
by simp


lemma lemma_ab [thy_expl]: "app (SmallListDemo.rev x) (SmallListDemo.rev y) =
SmallListDemo.rev (app y x)"
apply (hipster_induct)
apply (induction y)
apply simp
apply simp
apply (metis lemma_aa)
by (metis lemma_a)
(*apply (induction y)
apply simp
apply (metis lemma_a)
apply simp
apply (metis lemma_aa)
done*)


lemma unknown [thy_expl]: "SmallListDemo.rev (SmallListDemo.rev x) = x"
apply (induction x)
apply simp
apply simp
sledgehammer

lemma unknown [thy_expl]: "SmallListDemo.rev (SmallListDemo.rev x) = x"
oops

lemma unknown [thy_expl]: "app (SmallListDemo.rev x) (SmallListDemo.rev y) =
SmallListDemo.rev (app y x)"
oops

lemma unknown [thy_expl]: "app (SmallListDemo.rev x) (SmallListDemo.rev x) =
SmallListDemo.rev (app x x)"
oops



end
