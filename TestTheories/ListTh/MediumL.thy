theory MediumL
imports "../Listing"
        "../Naturals"
        BasicL
begin

(** manual **)
lemma count01: "r \<noteq> t \<Longrightarrow> count r (app ts (Cons t Nil)) = count r ts"
apply(induction ts)
apply(simp_all)
apply(induction rule: eqN.induct)
apply(simp_all)
done

(*
lemma identityNat: "eqN x x"
apply(induction x)
apply(simp_all)
done *)

lemma count02: "count t ts = n \<Longrightarrow> count t (Cons t ts) = S n"
(* apply(case_tac ts)     (* OR: induciton ts on its own *)
by (simp_all add: identityNat) (*XXX: how come the simplifier cannot get itself to the conclusion eqN v v? *)
*)
by (hipster_induct_simp_metis)

lemma count03: "count t ts = n \<Longrightarrow> count t (app rs ts) = add (count t rs) n"
by (hipster_induct_simp_metis)

lemma elem01: "elem t ts \<Longrightarrow> elem t (Cons r ts)"
(* apply(induction ts) by (simp_all) *)
by (hipster_induct_simp_metis)

lemma elem02: "elem t ts \<Longrightarrow> elem t (app ts rs)"
(* apply(induction ts) by (simp_all) *)
by (hipster_induct_simp_metis)

lemma elem03: "elem t ts \<Longrightarrow> elem t (app rs ts)"
(* apply(induction rs)  apply(simp_all) *)
by (hipster_induct_simp_metis)

lemma inRev: "elem t ts \<Longrightarrow> elem t (rev ts)"
(* apply(induction ts)  apply(simp_all)  by (metis elem.simps(2) elem02 elem03) *)
by (hipster_induct_simp_metis elem02 elem03 elem.simps(2))

lemma lastAfterCons: "ts \<noteq> Nil \<Longrightarrow> last ts = last (Cons t ts)"
by (hipster_induct_simp_metis)

lemma lastElemIsLast: "last (app ts (Cons t Nil)) = t"
by (hipster_induct_schemes) (*
apply(induction ts rule: last.induct)
by (simp_all)*)

lemma firstLast: "ts \<noteq> Nil \<Longrightarrow> head ts = last (rev ts)"
(* apply(induction ts)  by (simp_all add: lastElemIsLast) *)
by (hipster_induct_simp_metis lastElemIsLast)

lemma setCountRev: "count t ts = count t (rev ts)"
(* TODO: Ill-typed instantiation::: check types before inducting with a rule that does not correspond
   HOWEVER: we cannot know in some cases immediately... XXX: how to extract which var's a rule inducts over? *)
apply(induction ts)  (* XXX: no need for  rule: rev.induct ! *)
by (simp_all add: count03 addId addS2) (* for some reason still won't do with hipster and these lemmas *)

lemma lenTake: "leq n (len ts) \<Longrightarrow> len (take n ts) = n" (* XXX: same as previous *)
apply(induction ts rule: take.induct)
apply(simp_all)
done

lemma lastStays: "ts \<noteq> Nil \<Longrightarrow> last ts = last (Cons t ts)"
(* apply(induction ts)  apply(simp_all) *)
by (hipster_induct_simp_metis)

lemma len0: "Z = len ts \<Longrightarrow> ts = Nil"
by (hipster_induct_simp_metis)

  declare [[show_types]]
  declare [[show_sorts]]
  declare [[show_consts]]

lemma notLen0: "leq (S n) (len ts) \<Longrightarrow> ts \<noteq> Nil" (* FIXME: loops in Hipster \<Longrightarrow> timeout on simp too? *)
apply(induction ts)
by (simp_all)

(* XXX: maybe start with innermost? *)
lemma notEmptyDrop: "leq (S n) (len ts) \<Longrightarrow> (drop n ts) \<noteq> Nil"
apply(induction ts rule: drop.induct) (* XXX: same as previous; NOTE: loops in struct-ind attempt *)
by (simp_all add: notLen0)  (* notLen0 necessary! *)

lemma emptyDrop: "leq (len ts) n \<Longrightarrow> drop n ts = Nil"
apply(induction ts rule: drop.induct)
apply(simp_all)
apply(frule noLowerZ) (* XXX: why frule's is not done also by the simplifier? *)
by (simp_all add: len0)

lemma lastDrop : "leq (S n) (len ts) \<Longrightarrow> last (drop n ts) = last ts"
apply(induction ts rule: drop.induct)
apply(simp_all)
oops

(* TODO: strategy: start with tailing call? nah, didn't matter: both take.induct and drop.induct get us there *)
lemma dropTake : "ts = app (take n ts) (drop n ts)" (* XXX: ill-instantiation again... *)
apply(induction ts rule: take.induct)
apply(case_tac n)
apply(simp_all)
(** conditional **)
done

lemma takeMore: "leq (len ts) n \<Longrightarrow> take n ts = ts"
apply(induction ts rule: take.induct)
apply(simp_all)
apply(drule emptyDrop)
by (simp_all)

(* XXX: make sure we include helping lemmas \<Longrightarrow> they avoid errors + infinite running! (ill-instantiations... none) *)
lemma initAsTake: "init ts = take (sub (len ts) (S Z)) ts"
(* by (hipster_induct_schemes subId ) when with the right one... *)
apply(induction ts rule: init.induct)
by (simp_all add: subId)


lemma zipNil: "rs = Nil \<Longrightarrow> zip rs ts = Nil" (* "\<not> notNil rs *)  (* does not require condition "format" *)
by (tactic {* Simp_Tacs.routine_tac @{context} *})
(*by (hipster_induct_simp_metis)*)

(* XXX: we should do something about our conclusions in the induction? type of the Nil has a 
    _SCHEMATIC TYPE_ variable... *)
lemma zip2nil: "rs = Nil \<Longrightarrow> zip ts rs = Nil"
by (hipster_induct_simp_metis)
(* by (metis Listing.zip.simps Listing.List.exhaust)*) (*
apply(induction ts)
by (simp_all)*)
(* FIXME: hipster_induct_simp_metis solves all goals if the condition is not specified but we get
    when trying to close the proof:
      Proved a different theorem:
      Listing.zip ts Listing.List.Nil = Listing.List.Nil *)

lemma zipNilBis: "\<not> notNil ts \<Longrightarrow> zip rs ts = Nil"
by (hipster_induct_simp_metis zip2nil) (* here: usage of notNil requires the induction? *)

lemma zipNotNil: "notNil rs \<Longrightarrow> zip (Cons t ts) rs = Cons (t, head rs) (zip ts (tail rs))"
apply(case_tac rs)
apply(simp_all)
done
(*by (hipster_induct_simp_metis)*)

lemma zipSingleton: "zip (Cons t Nil) (Cons r Nil) = Cons (t,r) Nil"
by simp

(* XXX: if the condition is dropped, simplification alone (our Simp_Tacs.routine_tac) suffices, of course
    But if induction is taken, the method cannot be applied and it fails... 
    Notably, if we have a condition and still use Nil instead of ts, we don't get "type unification"
      for both Nil's despite the type of rev, apparently - or so it seems - *)
lemma revNil: "ts = Nil \<Longrightarrow> rev ts = Nil"
by hipster_induct_simp_metis

lemma rotSelf : "rotate n (app xs xs) = app (rotate n xs) (rotate n xs)"
apply(induction xs rule: rotate.induct)
apply(simp_all)
apply(case_tac n)
apply auto
oops

end


