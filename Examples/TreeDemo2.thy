theory TreeDemo
imports "$HIPSTER_HOME/IsaHipster"

begin

(* setup Tactic_Data.set_induct_simp *)

datatype 'a Tree = 
  Leaf 'a 
  | Node "'a Tree""'a Tree"

fun mirror :: "'a Tree => 'a Tree"
where
  "mirror (Leaf x) = Leaf x"
| "mirror (Node l r) = Node (mirror r) (mirror l)"

fun tmap :: "('a => 'b) => 'a Tree => 'b Tree"
where
  "tmap f (Leaf x) = Leaf (f x)"
| "tmap f (Node l r) = Node (tmap f l) (tmap f r)" 


(* First call to Hipster: Explore tmap and mirror *)
hipster tmap mirror




fun flat_tree :: "'a Tree => 'a list"
where
  "flat_tree (Leaf x) = [x]"
| "flat_tree (Node l r) = (flat_tree l) @ (flat_tree r)"

(* Second call to Hipster: Explore relation to lists: flat_tree tmap mirror rev map *)





fun rightmost :: "'a Tree \<Rightarrow> 'a"
where 
  "rightmost (Leaf x) = x"
| "rightmost (Node l r) = rightmost r"

fun leftmost :: "'a Tree \<Rightarrow> 'a"
where 
  "leftmost (Leaf x) = x"
| "leftmost (Node l r) = leftmost l"

(* Explore leftmost rightmost mirror tmap *)










(*
(* Third call to Hipster: hd mirror flat_tree  rightmost leftmost*)
hipster hd mirror flat_tree rightmost leftmost

(* Bug, produces the wrong proof as sledgehammer gives back a simp-proof it 
   seems to loose the last line! *)
lemma lemma_ad [thy_expl]: "hd (flat_tree z @ y) = hd (flat_tree z)"
apply (induction z)
apply simp
apply simp
by (simp add: hd_append) (* Misses this!*)

lemma lemma_ae [thy_expl]: "hd (flat_tree y) = leftmost y"
apply (induction y)
apply simp
apply simp
by (metis TreeDemo.lemma_ad)

lemma lemma_af [thy_expl]: "leftmost (mirror y) = rightmost y"
apply (induction y)
apply simp
by simp
*)

(* lemma lemma_ad [thy_expl]: "leftmost (mirror x) = rightmost x"
apply (induction x)
apply simp
by simp

lemma lemma_ae [thy_expl]: "rightmost (mirror x) = leftmost x"
apply (induction x)
apply simp
by simp

lemma lemma_af [thy_expl]: "hd (xs @ xs) = hd xs"
apply (induction xs)
apply simp
by simp

lemma unknown [thy_expl]: "hd (flat_tree x) = leftmost x"
oops

*)






























(* FIXME: Bug in translation? *)
(*
fun size :: "'a Tree \<Rightarrow> nat"
where
  "size (Leaf x) = 0"
  | "size (Node l r) = (size l + size r + 1)"
fun size1 :: "'a Tree \<Rightarrow> nat"
where
  "size1 (Leaf x) = 1"
  | "size1 (Node l r) = (size1 l + size1 r)"
*)
(*  hipster  size *) (* TO DO! Make sure + and 0,1 gets transalated back to the right constants*)
(* Issue! These constants are polymorphic! fix fix fix... *)
(*ML{* @{term "nonEmpty ys \<and> true ==> flat_tree x = []"} *} *)

(*

hipster last rev mirror flat_tree rigthmost leftmost
lemma lemma_af [thy_expl]: "last (xs2 @ xs2) = last xs2"
by (tactic {* Hipster_Tacs.induct_simp_metis @{context} @{thms List.last.simps List.rev.simps TreeDemo.mirror.simps TreeDemo.flat_tree.simps TreeDemo.rigthmost.simps TreeDemo.leftmost.simps thy_expl} *})

lemma unknown [thy_expl]: "last (flat_tree x) = rigthmost x"
oops

(* setup{* 
Tactic_Data.set_induct_simp;
*}
*)

*)
end

