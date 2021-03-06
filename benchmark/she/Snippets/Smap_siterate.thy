theory Smap_siterate
  imports Main "$HIPSTER_HOME/IsaHipster"
begin
  
setup Tactic_Data.set_coinduct_sledgehammer  
  
text_raw \<open>\DefineSnippet{streamdefs}{\<close>
codatatype (sset: 'a) Stream =
  SCons (shd: 'a) (stl: "'a Stream")

primcorec smap :: "('a \<Rightarrow> 'b) \<Rightarrow> 'a Stream \<Rightarrow> 'b Stream" where
  "smap f xs = SCons (f (shd xs)) (smap f (stl xs))"

primcorec siterate :: "('a \<Rightarrow> 'a) \<Rightarrow> 'a \<Rightarrow> 'a Stream" where
  "siterate f a = SCons a (siterate f (f a))"

cohipster smap siterate \<comment> "tell Hipster to explore these functions"

text_raw \<open>}%EndSnippet\<close>  

text_raw \<open>\DefineSnippet{streamoutput}{\<close>  
lemma lemma_a [thy_expl]: "SCons (y z) (smap y x2) = smap y (SCons z x2)"
  by(coinduction arbitrary: x2 y z rule: Stream.coinduct_strong)
simp

lemma lemma_aa [thy_expl]: "smap y (siterate y z) = siterate y (y z)"
  by(coinduction arbitrary: y z rule: Stream.coinduct_strong)
auto

lemma lemma_ab [thy_expl]: "smap z (SCons y (siterate z x2)) = SCons (z y) (siterate z (z x2))"
  by(coinduction arbitrary: x2 y z rule: Stream.coinduct_strong)
    (simp add: Smap_siterate.lemma_aa)
text_raw \<open>}%EndSnippet\<close>    

end