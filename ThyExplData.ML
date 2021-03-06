(*  Author:     Moa Johansson, Chalmers University of Technology
    Author:     Irene Lobo Valbuena, Chalmers University of Technology

Hipster theory exploration discovered properties data.
*)

(*-----------------------------------------------------------------------------------------*)
(* Data to be stored during theory exploration *)
(*-----------------------------------------------------------------------------------------*)

(*structure ThyExpl_Opts =
struct

datatype T = Data of
    { val cond_count : int,
      val ind_count : int,
    }
end;*)


structure ThyExpl_Data =
struct

datatype T = Data of
  { open_conjs : Thm.thm list,  (* left to prove *)
    failed : Thm.thm list,      (* Have tried once but failed *)
    proved : Thm.thm list,      (* proved *)
    facts :  Thm.thm list,      (* Background facts, e.g. fun defs *)
    fact_names : string list,   (* Names of rules for fun defs. *)
    proof_scripts : string Symtab.table, (* A string representation of a proof as Isar. *)
    used_thm_names : Name.context,  (* keeping track of names of theorems we generate. *)
    priority_goal : Thm.thm option, (* Do we have any priority user goal to prove? *)
    progress : bool }           (* have we proved at least something this iteration *)

fun get_open_conjs (Data d) = (#open_conjs d)
fun get_failed (Data d) = (#failed d)
fun get_proved (Data d) = (#proved d)
fun get_facts (Data d) = (#facts d)
fun get_fact_names (Data d) = (#fact_names d)
fun get_proof_scripts (Data d) = (#proof_scripts d)
fun get_used_thm_names (Data d) = (#used_thm_names d)
fun get_priority_goal (Data d) = (#priority_goal d)
fun get_progress (Data d) = (#progress d)

fun update_open_conjs f (Data d) =
  Data{open_conjs = f (#open_conjs d), failed = #failed d, proved = #proved d,
       facts = #facts d, fact_names = #fact_names d, proof_scripts= #proof_scripts d,
       used_thm_names = #used_thm_names d, priority_goal = #priority_goal d,
       progress = #progress d}
fun update_failed f (Data d) =
  Data{open_conjs = #open_conjs d, failed = f (#failed d), proved = #proved d,
       facts = #facts d, fact_names = #fact_names d, proof_scripts= #proof_scripts d,
       used_thm_names = #used_thm_names d, priority_goal = #priority_goal d,
       progress = #progress d}
fun update_proved f (Data d) =
  Data{open_conjs = #open_conjs d, failed = #failed d, proved = f (#proved d),
       facts = #facts d, fact_names = #fact_names d, proof_scripts= #proof_scripts d,
       used_thm_names = #used_thm_names d, priority_goal = #priority_goal d,
       progress = #progress d}
fun update_facts f (Data d) =
  Data{open_conjs = #open_conjs d, failed = #failed d, proved = #proved d,
       facts = f (#facts d), fact_names = #fact_names d, proof_scripts= #proof_scripts d,
       used_thm_names = #used_thm_names d, priority_goal = #priority_goal d,
       progress = #progress d}
fun update_fact_names f (Data d) =
  Data{open_conjs = #open_conjs d, failed = #failed d, proved = #proved d,
       facts =  #facts d, fact_names = f (#fact_names d), proof_scripts= #proof_scripts d,
       used_thm_names = #used_thm_names d, priority_goal = #priority_goal d,
       progress = #progress d}
fun update_proof_scripts f (Data d) =
  Data{open_conjs = #open_conjs d, failed = #failed d, proved = #proved d,
       facts =  #facts d, fact_names = #fact_names d, proof_scripts= f (#proof_scripts d),
       used_thm_names = #used_thm_names d, priority_goal = #priority_goal d,
       progress = #progress d}
fun update_used_thm_names f (Data d) =
  Data{open_conjs = #open_conjs d, failed = #failed d, proved = #proved d,
       facts = #facts d, fact_names = #fact_names d, proof_scripts= #proof_scripts d,
       used_thm_names = f (#used_thm_names d), priority_goal = #priority_goal d,
       progress = #progress d}
fun update_priority_goal f (Data d) =
  Data{open_conjs = #open_conjs d, failed = #failed d, proved = #proved d,
       facts = #facts d, fact_names = #fact_names d, proof_scripts= #proof_scripts d,
       used_thm_names = #used_thm_names d, priority_goal = f (#priority_goal d),
       progress = #progress d}
fun update_progress f (Data d) =
  Data{open_conjs = #open_conjs d, failed = #failed d, proved = #proved d,
       facts = #facts d, fact_names = #fact_names d, proof_scripts= #proof_scripts d,
       used_thm_names = #used_thm_names d, priority_goal = #priority_goal d,
       progress = f (#progress d)}


fun set_open_conjs conjs = update_open_conjs (K conjs)
fun set_failed failed = update_failed (K failed)
fun set_proved proved = update_proved (K proved)
fun set_facts facts = update_facts (K facts)
fun set_fact_names fact_nms = update_fact_names (K fact_nms)
fun set_proof_scripts proof_scripts = update_proof_scripts (K proof_scripts)
fun set_used_thm_names names = update_used_thm_names (K names)
fun set_priority_goal goals = update_priority_goal (K goals)
fun set_progress prog = update_progress (K prog)

fun add_failed c = update_failed (fn cs => cs@[c])
fun add_proved thm = update_proved (fn thms => thms@[thm])
fun add_proof_script (thm_nm, proof) =
  update_proof_scripts (fn proofs => Symtab.update (thm_nm,proof) proofs)

val empty = Data{open_conjs = [], failed = [], proved = [], facts = [], fact_names = [],
                 proof_scripts = Symtab.empty,
                 used_thm_names = Name.context, priority_goal = NONE, progress = false}

(* Data stored in an Isabelle context *)
structure ExplData = Proof_Data (type T = T
                                 fun init _ = empty)

(* Get information from a proof context type *)
val open_conjs_of_ctxt = get_open_conjs o ExplData.get
val failed_of_ctxt = get_failed o ExplData.get
val proved_of_ctxt = get_proved o ExplData.get
val facts_of_ctxt  = get_facts o ExplData.get
val fact_names_of_ctxt  = get_fact_names o ExplData.get
val used_thm_names_of_ctxt = get_used_thm_names o ExplData.get
val proof_scripts_of_ctxt = get_proof_scripts o ExplData.get
val priority_goal_of_ctxt = get_priority_goal o ExplData.get
val progress_of_ctxt = get_progress o ExplData.get

fun proof_script_of_thm thm_nm ctxt =
  Symtab.lookup (proof_scripts_of_ctxt ctxt) thm_nm


fun set_open_conjs_ctxt conjs ctxt =
  ExplData.put (set_open_conjs conjs (ExplData.get ctxt)) ctxt
fun set_failed_ctxt failed ctxt =
  ExplData.put (set_failed failed (ExplData.get ctxt)) ctxt
fun set_proved_ctxt proved ctxt =
  ExplData.put (set_proved proved (ExplData.get ctxt)) ctxt
fun set_facts_ctxt facts ctxt =
  ExplData.put (set_facts facts (ExplData.get ctxt)) ctxt
fun set_fact_nms_ctxt fact_nms ctxt =
  ExplData.put (set_facts fact_nms (ExplData.get ctxt)) ctxt
fun set_proof_scripts_ctxt proof_scripts ctxt =
  ExplData.put (set_proof_scripts proof_scripts (ExplData.get ctxt)) ctxt
fun set_used_thm_names_ctxt names ctxt =
  ExplData.put (set_used_thm_names names (ExplData.get ctxt)) ctxt
fun set_priority_goal_ctxt goal ctxt =
  ExplData.put (set_priority_goal goal (ExplData.get ctxt)) ctxt
fun set_progress_ctxt prog ctxt =
  ExplData.put (set_progress prog (ExplData.get ctxt)) ctxt

fun add_failed_ctxt failed ctxt =
  ExplData.put (add_failed failed (ExplData.get ctxt)) ctxt
fun add_proved_ctxt proved ctxt =
  ExplData.put (add_proved proved (ExplData.get ctxt)) ctxt
fun add_proof_script_ctxt (thm_nm,proof) ctxt =
  ExplData.put (add_proof_script (thm_nm,proof) (ExplData.get ctxt)) ctxt

(* Check if this thm is already present. Also do symetric thm. *)
fun is_present ctxt thm =
  let val crits = [(true, Find_Theorems.Solves)];
  in
    null (snd (Find_Theorems.find_theorems ctxt (SOME thm) (SOME 1) false crits))
    andalso 
    (null (snd (Find_Theorems.find_theorems ctxt (SOME (sym RS thm)) (SOME 1) false crits))
      handle THM _ => true) (*FIX: If not an equation a THM exception is thrown if we try to get 
                                      the symmetric theorem. *)
  end

(* from the CookBook *)
fun goal_prop str ctxt =
  let val prop = Syntax.read_prop ctxt str
  in Proof.theorem NONE (K I) [[(prop, [])]] ctxt
  end

(* Assume get list of strings from HipSpec, which can be directly parsed as Isabelle terms *)
fun init_expl ctxt facts fact_names prio_goal_opt lemma_strs =
  let
      val conjs = lemma_strs
                    |> map (Syntax.read_prop ctxt)
                    |> map (Goal.init o (Thm.cterm_of ctxt))
                    |> filter (is_present ctxt);
  in
    ExplData.put
      (Data{open_conjs = conjs, failed = [], proved = [], facts = facts, fact_names = fact_names,
            proof_scripts = Symtab.empty, 
            used_thm_names = Name.make_context
                                (map (fn thm => Long_Name.base_name(Thm.get_name_hint thm))
                                     (Hipster_Rules.get ctxt)),
            priority_goal = prio_goal_opt, progress = false})
      ctxt
  end

(* Generate a fresh name for a lemma *)
fun fresh_name ctxt =
  let val (nm, nm_ctxt) = Name.variant "lemma_a" (used_thm_names_of_ctxt ctxt)
  in (nm, set_used_thm_names_ctxt nm_ctxt ctxt) end

end
