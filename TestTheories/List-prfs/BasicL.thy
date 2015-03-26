theory BasicL
imports Main
        "../Listing"
        "../../IsaHipster"
        "../Naturals"

begin

(* FIXME: more than reversing lists, etc. deciding which scheme to start with might reside solely
    on how different some are from others: shall we start with those "different" from the structural
    one? How can we determine this? *)

(*print_rules
print_induct_rules*)
ML {* Outer_Syntax.improper_command *}
ML {* Datatype.get_info *}

(*hipster_cond notNil maps tail init len*)
lemma lemma_a [thy_expl]: "tail (maps x2 y2) = maps x2 (tail y2)"
by hipster_induct_simp_metis
(*apply(induction y2)
apply(simp_all)
done*)

lemma lemma_aa [thy_expl]: "len (maps x2 y2) = len y2"
by hipster_induct_simp_metis
(*apply(induction y2)
apply(simp_all)
done*)

lemma lemma_ac [thy_expl]: "(Nil \<noteq> (maps x2 y2)) = (Nil \<noteq> y2)"
by hipster_induct_simp_metis (* just metis *)
(*apply(induction y2)
apply(simp_all)
done*)


(* internally goes into conditional which Hipster cannot solve right now *)
(* FIXME: we rev the list so that it doesn't get stuck in maps.induct BUT we should control this
  behaviour! \<Rightarrow> limit simp_or_metis... *)
lemma unknown01 [thy_expl]: "init (maps x y) = maps x (init y)"
by (hipster_induct_schemes)(*
apply(induction y rule: init.induct)
apply(simp_all)
done*)

lemma auxNilIn : "init Nil = tail Nil"
by (metis init.simps tail.simps)

lemma unknown02 [thy_expl]: "init (tail x) = tail (init x)"
by hipster_induct_schemes (*
apply(induction x)
apply(simp_all)
apply(case_tac x)
apply(simp_all)
done*)

lemma unknown03 [thy_expl]: "len (init x) = len (tail x)"
by hipster_induct_schemes (*
apply(induction x)
apply(simp_all)
apply(case_tac x)
apply(simp_all)
done*)

lemma unknown04 [thy_expl]: "notNil (init x) = notNil (tail x)" (* required schemes: init.induct *)
by hipster_induct_schemes (*
apply(case_tac x)
apply(simp_all)
apply(case_tac List)
apply(simp_all)
done *)

lemma unknown04': " (Nil \<noteq> init x) = (Nil \<noteq> tail x)" (* required schemes: init.induct *)
by hipster_induct_schemes

(*
fun noNat :: "Nat List \<Rightarrow> bool" where
  "noNat l = notNil l"
fun appnat :: "Nat List \<Rightarrow> Nat List \<Rightarrow> Nat List " where
  "appnat x y = app x y"

hipster noNat appnat*)


lemma initDef: "init (app ts (Cons t Nil)) = ts"
by hipster_induct_schemes (*
apply(induction ts rule: init.induct)
apply(simp_all)
done*)

lemma lastDef: "\<not> notNil ts \<Longrightarrow> last (Cons t ts) = t"
by (hipster_induct_simp_metis Listing.notNil.simps Listing.last.simps)

lemma lastDef' : "last (Cons t Nil) = t"
by(tactic {* Tactic_Data.routine_tac @{context} *})

(* auxiliary *)
lemma noElems: "count t Nil = Z"
by simp

lemma appNil: "app ts Nil = ts"
by (hipster_induct_simp_metis Listing.app.simps )
(*
hipster_cond notNil app init*)

(* XXX: shall we try and have some reasonable decision as to which argument + function to start inducting upon?
  eg: inner-most-left-most *)
lemma initLast: "ts \<noteq> Nil \<Longrightarrow> app (init ts) (Cons (last ts) Nil) = ts"
by (hipster_induct_schemes)
(*by (hipster_induct_schemes Listing.notNil.simps Listing.init.simps Listing.app.simps Listing.last.simps)*)
(* by hipster_induct_schemes : succeeds but takes long because it tries first notNil.induct, app.induct
    and then init.induct *)(*
apply(induction ts rule: init.induct)
apply(simp_all)
done*)


lemma initCons: "notNil ts \<Longrightarrow> init (Cons t ts) = Cons t (init ts)"
by (hipster_induct_simp_metis)

lemma initApp: "notNil ts \<Longrightarrow> init (app rs ts) = app rs (init ts)"
by (hipster_induct_schemes initCons)
(* by (hipster_induct_schemes initCons : needs initCons! succeeds but takes long - tries notNil.induct
  and app.induct before last.induct... *)(*
apply(induction rs rule: init.induct)
apply(simp_all)
apply(case_tac ts)
apply(simp_all)
done*)

lemma initAppNil: "\<not> notNil ts \<Longrightarrow> init (app rs ts) = init rs"
by (hipster_induct_schemes Listing.notNil.simps Listing.app.simps Listing.init.simps appNil)
(* before: apply(induction ts rule: init.induct) apply(simp_all add: appNil) *)

lemma lastCons: "notNil ts \<Longrightarrow> last (Cons t ts) = last ts"
by (hipster_induct_simp_metis)

lemma lastApp: "notNil ts \<Longrightarrow> last (app rs ts) = last ts"
by (hipster_induct_schemes lastCons)
(* by (hipster_induct_schemes lastCons) : needs lastCons! succeeds but takes long - tries notNil.induct
  and app.induct before last.induct... XXX: check order in general! *)
(* XXX2: seems like case distinctions (maybe double inductions too) could benefit from auxiliary
    lemmas, in general *)(*
apply(induction rs rule: last.induct)
apply(simp_all)
apply(case_tac ts)
apply(simp_all)
done*)

lemma lastAppNil: "\<not> notNil ts \<Longrightarrow> last (app rs ts) = last rs"
by (hipster_induct_schemes appNil) (* needs it! *)
(*
lemma countDiff: "\<not> eqN r t \<Longrightarrow> count r (app (Cons t Nil) ts) = count r ts"
by (hipster_induct_simp_metis)*)

lemma countInc: "eqN r t \<Longrightarrow> count r (Cons t ts) = S (count r ts)"
by (hipster_induct_simp_metis)

ML {*
   fun infer_term x ctxt =
     let val (T, ctxt') = Proof_Context.inferred_param x ctxt
     in (Free (x, T), ctxt') end;
   fun bis x = Attrib.thms x ;
   fun induct_for_me ctxt xss rule i =
     let
       val (tss, ctxt') = (fold_map o fold_map) infer_term xss ctxt
       val instss = map (map (fn inst => SOME (NONE, (inst, false)))) tss;
     in Seq.map snd o Induct.induct_tac ctxt' false instss [] [] NONE (*SOME rule*) [] i end;
*}
fun drop' :: "nat \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "drop' _ [] = []"
| "drop' 0 xs = xs"
| "drop' (Suc n) (x#xs) = drop' n xs"
(* XXX: mailing list!  But hipster_induct_simp_metis (or schemes) never work with this, regular
  List.drop which is implemented like ours or ours *)
lemma drop'Nil: "drop' n [] = []"
apply(raw_tactic {* ALLGOALS(induct_for_me @{context} [["n"]] []) *})
apply(simp_all)
done
(*by(tactic {* Tactic_Data.routine_tac @{context} *}) works too *)

(*XXX: maybe schemes will solve it when we pick the appropriate variable (type-wise) on which to
    induct?
       or does it have something to do with how the goal of a proof is set? 
  XXX: look up for a type T what T.exhaust is *)

  declare [[show_types]]
  declare [[show_sorts]]
  declare [[show_consts]]
lemma dropNil: "drop n Nil = Nil" (* XXX: check why this solves our problem... why no "unification" *)
(*by (metis drop.simps Nat.exhaust)*)
by hipster_induct_simp_metis


lemma dropMapComm: "drop n (maps f ts) = maps f (drop n ts)"
by hipster_induct_schemes (*
apply(induction ts rule: drop.induct)
apply(simp_all)
done*)

lemma takeMapCom: "take n (maps f ts) = maps f (take n ts)" (* needs schemes! *)
by hipster_induct_schemes (*
apply(induction ts rule: drop.induct) (* XXX: either works! drop.induct OR take.induct *)
apply(simp_all)
done*)

(* XXX: for now changed order \<Longrightarrow> do something about those HO objects, such as f *)
lemma mapIntersperse: "intersperse (f a) (maps f xs) = maps f (intersperse a xs)"
by hipster_induct_schemes

fun ith :: "'a List \<Rightarrow> nat \<Rightarrow> 'a" where
  "ith (Cons t ts) 0 = t"
| "ith (Cons t ts) (Suc n) = ith ts n"

fun len' :: "'a List \<Rightarrow> nat" where
  "len' Nil = 0"
| "len' (Cons t ts) = Suc (len' ts)"

lemma extens: "\<lbrakk> len' xs = len' ys ; ALL i < len' xs. ith xs i = ith ys i \<rbrakk> \<Longrightarrow> xs = ys"
oops

fun map' :: "('a \<Rightarrow> 'b) \<Rightarrow> 'a list \<Rightarrow> 'b List" where
  "map' f [] = Nil"
| "map' f (t # ts) = Cons (f t) (map' f ts)"

lemma mapIth:  "map' (\<lambda>i. ith xs i) [0..<len' xs] = xs"
oops


end



