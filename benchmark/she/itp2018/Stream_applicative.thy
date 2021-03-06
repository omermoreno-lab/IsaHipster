theory Stream_applicative
  imports Main "$HIPSTER_HOME/IsaHipster"
    "types/Stream"
    Smap
begin
setup Tactic_Data.set_coinduct_sledgehammer 
setup Misc_Data.set_noisy
  
(* Lifting *)
primcorec spure :: "'a \<Rightarrow> 'a Stream" where  
  "shd (spure x) = x"
| "stl (spure x) = spure x"
  
(* Sequential application *)
primcorec sapp :: " ('a \<Rightarrow> 'b) Stream \<Rightarrow> 'a Stream \<Rightarrow> 'b Stream" where
  "shd (sapp fs xs) = (shd fs) (shd xs)"
| "stl (sapp fs xs) = sapp (stl fs) (stl xs)"

(*cohipster smap spure sapp*)
(* Discovered in ca 40 seconds *)
lemma lemma_ac [thy_expl]: "sapp (spure z) x2 = smap z x2"
  by (coinduction arbitrary: x2 z rule: Stream.Stream.coinduct_strong)
  auto
  
lemma lemma_ad [thy_expl]: "smap y (spure z) = spure (y z)"
  by (coinduction arbitrary: y z rule: Stream.Stream.coinduct_strong)
    auto
    
lemma lemma_ae [thy_expl]: "smap z (SCons y (spure x2)) = SCons (z y) (spure (z x2))"
  by (coinduction arbitrary: x2 y z rule: Stream.Stream.coinduct_strong)
    (simp add: lemma_ad)
    
lemma lemma_af [thy_expl]: "sapp (SCons y (spure z)) (spure x2) = SCons (y x2) (spure (z x2))"
  by (coinduction arbitrary: x2 y z rule: Stream.Stream.coinduct_strong)
    (simp add: Stream_applicative.lemma_ac lemma_ad)

(*cohipster sapp spure Fun.comp
== Laws ==
  1. shd (spure x) = x
  2. stl (spure y) = spure y
Warning: generated term of untestable type Stream (X1 -> X2)
  3. sapp (spure f) z = sapp (spure f) z
  4. sapp (spure f) (spure y) = spure (f y)
  5. shd (sapp (spure f) y) = f (shd y)
  6. stl (sapp (spure f) x2) = sapp (spure f) (stl x2)
tip-spec: src/QuickSpec/Eval.hs, line 361: Untestable instance spure (X1 . X2) of testable schema spure (X1 . X1)
CallStack (from HasCallStack):
  error, called at src/QuickSpec/Eval.hs:361:12 in quickspec-2-AOUQDFNL2O4D7eGTuZ37W9:QuickSpec.Eval*)
end
