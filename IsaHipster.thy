theory IsaHipster
imports Main "$ISABELLE_HOME/src/HOL/TPTP/ATP_Problem_Import"
keywords "hipster" "hipster_cond" :: thy_decl

begin

 
ML{*

structure Hipster_Setup =
struct

(* Set these to your path to the Hipster directory *)
val basepath =
  case getenv "HIPSTER_HOME" of
    "" => let val _ = Output.warning ("Hipster: Environment variable $HIPSTER_HOME not set."^
                         "\n  Using current directory.")
          in "./" end
  | hip_home => hip_home^"/"
val filepath = basepath^"GenCode/"

end

structure Hipster_Rules = Named_Thms
  ( val name = @{binding "thy_expl"} 
    val description = "Theorems discovered by theory exploration" )

(* A flag which tells Hipster that it should disregard equations
   which *only* feature functions defined in another theory, i.e. a library. *)
val thy_interesting = Attrib.setup_config_bool @{binding thy_interesting} (K true)

*}


setup {* Hipster_Rules.setup;*}

ML_file "HipsterUtils.ML"
ML_file "SchemeInstances.ML"
ML_file "ThyExplData.ML"
ML_file "ProofData.ML"
ML_file "CTacs/CTac.ML"

ML_file "SledgehammerTacs.ML"
ML_file "HipTacOps.ML"
ML_file "IndTacs.ML"
ML_file "CTacs/InductCTac.ML"

ML_file "TacticData.ML"
ML_file "HipsterExplore.ML"
ML_file "HipsterIsar.ML"


method_setup hipster_induct_simp = {*
  Scan.lift (Scan.succeed 
    (fn ctxt => SIMPLE_METHOD 
      (Ind_Tacs.induct_simp_tac ctxt)))
   *}

method_setup hipster_induct_simp_metis = {*
  Attrib.thms >> (fn thms => fn ctxt =>
    SIMPLE_METHOD 
      (Ind_Tacs.induct_simp_metis ctxt thms))
 *}

method_setup hipster_induct_sledgehammer = {*
  Scan.lift (Scan.succeed 
    (fn ctxt => SIMPLE_METHOD 
      (Ind_Tacs.induct_sledgehammer_tac ctxt)))
   *}

method_setup hipster_induct_schemes = {*
  Attrib.thms >> (fn thms => fn ctxt =>
    SIMPLE_METHOD 
      (Ind_Tacs.induct_with_schemes ctxt thms))
 *}

(*
ML{*
Method.setup;
*}

method_setup hipster_goal = {*
*}*)

(* 
(* Default value for tactics is induct_simp_metis.
   Use setup command to change to other hard/routine tactics.
*)
setup{* 
Tactic_Data.set_induct_simp_metis;
*}

*)


end

