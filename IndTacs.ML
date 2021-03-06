(*  Author:     Moa Johansson, Chalmers University of Technology
    Author:     Irene Lobo Valbuena, Chalmers University of Technology

Hipster induction tactics.
*)

(* Various tactics for Hipster. Induction, simplification and metis. *)

(* TODO: checkout Type.could_unify
          --> and: purely structural matching (raw_match, etc)
         else Term.could_unify (for terms...) *)

signature IND_TACS =
sig
  type inductionStrategy
  val simp_all : Proof.context -> thm list -> tactic
  val sledgehammer_goals : Proof.context -> tactic
  val prove_by_simp : Proof.context -> thm list -> tactic
  val timed_metis_tac : Proof.context -> bool -> Thm.thm list -> int -> tactic
  val simp_or_metis : Proof.context -> (thm list * thm list) -> tactic
  val simp_or_sledgehammer_tac : Proof.context -> tactic
  val induct_and_simp : thm list -> inductionStrategy
  val induct_simp_or_metis : thm list * thm list -> inductionStrategy
  val induct_and_sledgehammer : inductionStrategy

  val try_inductable_vars : Proof.context -> inductionStrategy -> int -> tactic

  (* Utility function: figure out induction vars and arbitrary vars for induction tactic. *)
  val mk_induct_insts : (string * typ) list -> string list ->
                        (string * typ) list * (string * typ) option list

  (* Does induction on specified var.  *)
  val induct_on_var_tac : Proof.context -> (string * thm list) option -> string list option -> int -> tactic

  (* Get variable names to try structural induction on *)
  val inductable_things_in_sg : Proof.context -> int -> thm -> (string * typ) list

  (* Context -> tactic, to be pasted into proof script. *)
  val induct_simp_tac : Proof.context -> tactic

  (* Context -> list of simp rules (defs) -> tactic, to be pasted into proof script. *)
  val induct_simp_metis : Proof.context -> thm list -> tactic
  (* Context -> tactic, to be pasted into proof script. *)
  val induct_sledgehammer_tac :  Proof.context -> tactic
(*
  (* Context -> list of induct rules (schemes) -> tactic *)
  val induct_with_schemes : Proof.context -> thm list -> tactic
  val try_induct_schemes : Proof.context -> inductionStrategy -> int -> tactic
*)
  val SOLVE_TIMEOUT : int -> tactic -> tactic
end

structure Ind_Tacs  : IND_TACS  =
struct

type inductionStrategy = Proof.context -> (string * thm list) option -> string list option (*-> int*) -> tactic

fun SOLVE_TIMEOUT mseconds tac t =
  let val res = Timeout.apply (Time.fromMilliseconds mseconds)
                  (fn () => SINGLE ( tac) t) ()
                handle Timeout.TIMEOUT _ => NONE
                     | ERROR message => (warning ("Error: " ^ message ^ "\n"); NONE)
  in
    case res of
      NONE => Seq.empty  (* Hipster_Utils.maybe_output ctxt 50 ("Timeout :(") *)
    | SOME t' => Seq.single t'
  end;


(*-----------------------------------------------------------------------------------------*)
(* Simp tactics *)
(*-----------------------------------------------------------------------------------------*)
(*fun pretty_thm ctxt thm = Syntax.pretty_term ctxt (prop_of thm);*)
fun SOLVE_OR_FAIL tac st =
  let fun solved st = has_fewer_prems 1 st;
  in Seq.filter solved (tac st) end;

(* Apply simp to all subgoals *)
fun simp_all ctxt lemmas thm =
    let
       (*val _ = Pretty.writeln (Pretty.block [Pretty.str "simp_all: ", pretty_thm ctxt thm])*)
       (*val ss = map @{print} lemmas*)
       val ctxt' = Library.foldl (fn (ctxt,thm) => Simplifier.add_simp thm ctxt)
                                 (ctxt, lemmas)
    in
      (PARALLEL_GOALS o ALLGOALS) (fn i => SOLVE_TIMEOUT 500 (Simplifier.asm_full_simp_tac ctxt' i)) thm
    end;

(* Fails if all there are some subgoals left after application of simp *)
 fun prove_by_simp ctxt lemmas = SOLVE_OR_FAIL (SOLVE_TIMEOUT 500 (simp_all ctxt lemmas));


(*-----------------------------------------------------------------------------------------*)
(* Metis tactics *)
(*-----------------------------------------------------------------------------------------*)


(* Apply simp, if that doesn't work try metis.  *)
  (*  val _ = Pretty.writeln (Pretty.block [Pretty.str ("timed_metis: "^ @{make_string} i),pretty_thm ctxt thm]) in*)
fun timed_metis_tac ctxt full facts i thm =
  let val timeout = Hip_Tac_Ops.metis_to ctxt
      val args_metis = (if full then [ATP_Proof_Reconstruct.full_type_enc] else [])
  in (SOLVE_TIMEOUT timeout
       (Metis_Tactic.metis_tac args_metis
        ATP_Proof_Reconstruct.default_metis_lam_trans ctxt facts i)) thm
 end;

val has_tvar = exists_type (exists_subtype (fn TVar _ => true | _ => false)) o Thm.prop_of

fun metis_method ((override_type_encs, lam_trans), ths) ctxt facts =
  let val (schem_facts, nonschem_facts) = List.partition has_tvar facts
      val timeout = Hip_Tac_Ops.metis_to ctxt
  in
     (Method.insert_tac ctxt nonschem_facts THEN'
      CHANGED_PROP o (SOLVE_TIMEOUT timeout) o Metis_Tactic.metis_tac (these override_type_encs)
        (the_default ATP_Proof_Reconstruct.default_metis_lam_trans lam_trans) ctxt (schem_facts @ ths)) end


(* First simp, and if nessecary, let Metis deal with the rest *)
fun simp_or_metis ctxt (facts, lemmas) thm = (*let val _ = Pretty.writeln (pretty_thm ctxt thm) in*)
  let
    val type_enc = if Hip_Tac_Ops.use_full_types ctxt then (SOME [ATP_Proof_Reconstruct.full_type_enc]) else NONE
    val simp_adds = filter (fn lem => hd (Hip_Tac_Ops.simp_cond ctxt) (thm,lem)) lemmas
    val metis_adds = filter (fn lem => hd (Hip_Tac_Ops.metis_cond ctxt) (thm,lem)) (lemmas)
  in
    ((simp_all ctxt simp_adds) (* FIXME: both facts and lemmas? *)     (*SOLVE_TIMEOUT 2000*)
     THEN
     IF_UNSOLVED
     ((PARALLEL_GOALS o ALLGOALS) (metis_method ((type_enc,NONE), metis_adds) ctxt facts))) thm
  end;
(*REPEAT o FIRSTGOAL*) (*REPEAT_FIRST*)
(*((REPEAT_ALL_NEW (metis_method ((NONE,NONE), lemmas) ctxt facts))))*)


(* TODO: Maybe hack around with sledgehammer_with_metis to print string with actual facts as proof,
 also maybe see if we can pass in stuff proved during theory exploration but not yet in proof script.*)
(* Sledgehammer tactic *)
fun sledgehammer_goals ctxt =
  let
    val proved = ThyExpl_Data.proved_of_ctxt ctxt
    (* val _ = @{print} proved *)
  in
    ALLGOALS (Sledgehammer_Tactics.sledgehammer_with_metis_tac ctxt []
              Sledgehammer_Fact.no_fact_override proved)
  end;


(*** FIXME: Think this is slightly wrong, should simp before passing to sledgehammer. ***)
(* Must fail if there are any open subgoals left *)
fun simp_or_sledgehammer_tac ctxt = (*let val _ = @{print} "simp or" in *)
  (simp_all ctxt []) THEN (sledgehammer_goals ctxt)
 (*  SOLVE_OR_FAIL ((simp_all ctxt []) THEN IF_UNSOLVED (sledgehammer_goals ctxt))
      handle Fail msg => (warning ("Failure in: *" ^ msg ^"\n"); fn _ =>  Seq.empty) *)
(*end*)

(*
fun sledgehammer_goals_explore ctxt =
  let
    val proved = ThyExpl_Data.proved_of_ctxt ctxt
  in
    (Hipster_Sledgehammer_Tactics.sledgehammer_with_metis_tac ctxt []
             Sledgehammer_Fact.no_fact_override proved)
  end
*)
(*-----------------------------------------------------------------------------------------*)
(* Figure out what we can do induction on, and tries each variable until success.*)
(* Stolen from IsaPlanner...                                                               *)
(*-----------------------------------------------------------------------------------------*)

(* find an element, but keep the rest also *)
fun pull_elem f l =
  let fun recf [] _ = NONE
        | recf (h :: t) L =
            if f h
              then SOME (h, (rev L) @ t)
              else recf t (h :: L)
  in recf l [] end;

(* re-arranges things to induct on (indnames) into the correct format
for Isabelles induction tactic, also removed them from ithings, so
that we know what other frees to turn into sinks (univ quantifies in
the IH) *)
(* assumes: indnames <= ithings *)
fun mk_induct_insts ithings indnames =
  let fun faux ithings [] L = (ithings, rev L)
        | faux ithings (h :: t) L =
            if h = "_"
              then faux ithings t (NONE :: L)
              else (case pull_elem (fn (n,_) => n = h) ithings of
                      NONE => raise ERROR ("No such variable to do induction on: " ^ h)
                    | SOME (v, ithings') => (faux ithings' t ((SOME v) :: L)));
    in faux ithings indnames [] end;

fun inductable_things_in_term ctxt t =
  let
      fun ind_check (Type(ty,_)) = is_some (Induct.lookup_inductT ctxt ty)
         | ind_check _ = false;
      fun coind_check (Type(ty,_)) = is_some (Induct.lookup_coinductT ctxt ty)
         | coind_check _ = false; 
    val frees = Hipster_Utils.frees_of t;
    
  in
    filter ((fn x => (ind_check x) orelse (coind_check x)) o snd) frees
  end;

fun inductable_things_in_sg ctxt i thm =
  inductable_things_in_term ctxt (Library.nth (Thm.prems_of thm) (i - 1))  (* XXX: check how this might affect us *)


(* Term: has_abs, dest_abs??
         typ_subst_atomic? *)
(*fun isHO *)


(* Rule can be NONE if we just want plain structural induction. *)
(* var is the variable(s) we want to do induction on *)
fun induct_on_var_tac ctxt rule vars i goalthm =
  let val ithings = inductable_things_in_sg ctxt i goalthm;
      val (otherfrees, inductfrees) = (case vars of
                                        NONE => mk_induct_insts ithings []
                                      | SOME vs => mk_induct_insts ithings vs)
    
      val insts = map (fn NONE => NONE
                        | SOME v => SOME (NONE : Binding.binding option, (Free v,false)))
            (* Each variable paired with false: matters not in our case since we are wrapping them with 'Free' *)
                  inductfrees

     (*Rule is paired with its name, drop here. *)
     val rule' = case rule of NONE => NONE | SOME (_,thms) => SOME thms
  in
    Induction.induction_tac ctxt false
                      [insts] [otherfrees] [] rule' [] i goalthm
                    handle ERROR msg => (warning ("Error in: " ^ msg ^ "\n"); Seq.empty)
                    handle Fail  msg => (warning ("Failure in: *" ^ msg ^"\n"); Seq.empty)
  end;


(*-----------------------------------------------------------------------------------------*)
(* Induction tactics.                                                                      *)
(*-----------------------------------------------------------------------------------------*)

(* Apply induction on var and try to prove all cases by simp *)
fun induct_and_simp lemmas ctxt rule var (*i*) =
  DEPTH_SOLVE (
    (Seq.DETERM (HEADGOAL ((induct_on_var_tac ctxt rule var )))) THEN (prove_by_simp ctxt lemmas) )

(* Induction on var, then try to prove resulting subgoals by simp or metis *)
fun induct_simp_or_metis (facts, lemmas) ctxt rule var(* i*) =
  DEPTH_SOLVE (
    (Seq.DETERM (HEADGOAL ((induct_on_var_tac ctxt rule var (*i*) )))) THEN (simp_or_metis ctxt (facts,lemmas)) )

(* Induction on a var, then try to prove by sledgehammer *)
fun induct_and_sledgehammer ctxt rule var = (*let val _ = @{print} "induct_and_sl" in*)
  DEPTH_SOLVE (
    (Seq.DETERM (HEADGOAL ((induct_on_var_tac ctxt rule var)))) THEN (simp_or_sledgehammer_tac ctxt))


(* Try induction on each variable in vars until we find one that allows a proof. *)
(* Note: vars :: string list list so could be schemes with many vars*)
fun try_induct_on ctxt rule strat vars i =
  case vars of
    []        => no_tac
  | (v :: vs) =>  (*let val _ = Pretty.writeln (Pretty.str (" - vars: "^ @{make_string} v)) in*)
      strat ctxt rule (SOME v) (*i*) (*THEN simp_all ctxt []*)
      ORELSE
      (try_induct_on ctxt rule strat vs i)

(* Find the variables we can induct on *)
fun try_inductable_vars ctxt strat i thm =
  let val vars = map (fn (v,_) => [v]) (inductable_things_in_sg ctxt i thm)
  in (try_induct_on ctxt NONE strat vars i) thm
  end


(* QUESTION: Should these tactics really add the lemma-list to the simplifier?
The tactics used by Hipster don't, they only pass them to Metis, looking them up from the ctxt.
However, if these tactics are used outside of theory exploration, they might not have all the
stuff in the ctxt, i.e. simprules and discovered theorems?

Maybe need all separate tactics for outside Theory Exploration? Or data for induction?
Or add to TacticData?
*)


(* An induction tactic to paste into the proof-script afterwards *)
fun induct_simp_metis ctxt facts thm =
  let val lemmas = (ThyExpl_Data.proved_of_ctxt ctxt) @ (Hipster_Rules.get ctxt)
  in
    (* XXX: removed as simplifier rules - in this case, so far, no changes *)
    ALLGOALS(try_inductable_vars ctxt (induct_simp_or_metis (facts,lemmas))) thm
  end;


(* An induction tactic to paste into the proof-script afterwards *)
fun induct_simp_tac ctxt thm =
  let val lemmas = (ThyExpl_Data.proved_of_ctxt ctxt) @ (Hipster_Rules.get ctxt)
      val ctxt' = Library.foldl (fn (ctxt,thm) => Simplifier.add_simp thm ctxt)
                                (ctxt, lemmas)
  in ALLGOALS(try_inductable_vars ctxt' (induct_and_simp lemmas)) thm
  end;

fun induct_sledgehammer_tac ctxt = (*let val _ = @{print} "ind-sl-tac" in*)
  ALLGOALS(try_inductable_vars ctxt (induct_and_sledgehammer))

end


