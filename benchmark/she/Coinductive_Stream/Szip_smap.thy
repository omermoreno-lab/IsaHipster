theory Szip_smap
  imports Main "$HIPSTER_HOME/IsaHipster"
begin
  
setup Tactic_Data.set_coinduct_sledgehammer  
codatatype (sset: 'a) Stream =
  SCons (shd: 'a) (stl: "'a Stream")
datatype ('a, 'b) Pair2 = Pair2 'a 'b
primcorec szip :: "'a Stream \<Rightarrow> 'b Stream \<Rightarrow> (('a, 'b) Pair2) Stream" where
  "shd (szip s1 s2) = Pair2 (shd s1) (shd s2)"
| "stl (szip s1 s2) = szip (stl s1) (stl s2)"

primcorec smap :: "('a \<Rightarrow> 'b) \<Rightarrow> 'a Stream \<Rightarrow> 'b Stream" where
  "smap f xs = SCons (f (shd xs)) (smap f (stl xs))"

fun map_prod2 :: "('a \<Rightarrow> 'c) \<Rightarrow> ('b \<Rightarrow> 'd) \<Rightarrow> ('a,'b) Pair2 \<Rightarrow> ('c,'d) Pair2" where
"map_prod2 f g (Pair2 a b) = Pair2 (f a) (g b)"

datatype 'a Lst = 
  Emp
  | Cons "'a" "'a Lst"
    
fun obsStream :: "int \<Rightarrow> 'a Stream \<Rightarrow> 'a Lst" where
"obsStream n s = (if (n \<le> 0) then Emp else Cons (shd s) (obsStream (n - 1) (stl s)))"

(* hipster_obs Stream Lst obsStream szip smap map_prod2
Proving: map_prod2 z z (Pair22 y x2) = Pair22 (z y) (z x2) 
Undefined fact: "Szip_smap.Pair2.coinduct_strong" *)
theorem szip_smap: 
 "szip (smap f xs) (smap g ys) = smap (map_prod2 f g) (szip xs ys)"
by hipster_coinduct_sledgehammer
end   