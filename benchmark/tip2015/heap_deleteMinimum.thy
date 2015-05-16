theory heap_deleteMinimum
imports Main
        "../../IsaHipster"
begin
  datatype 'a list = Nil2 | Cons2 "'a" "'a list"
  datatype Nat = Z | S "Nat"
  datatype 'a Maybe = Nothing | Just "'a"
  datatype Heap = Node "Heap" "Nat" "Heap" | Nil2
  fun plus :: "Nat => Nat => Nat" where
  "plus (Z) y = y"
  | "plus (S n) y = S (plus n y)"
  fun listDeleteMinimum :: "Nat list => (Nat list) Maybe" where
  "listDeleteMinimum (Nil2) = Nothing"
  | "listDeleteMinimum (Cons2 y xs) = Just xs"
  fun le :: "Nat => Nat => bool" where
  "le (Z) y = True"
  | "le (S z) (Z) = False"
  | "le (S z) (S x2) = le z x2"
  fun merge :: "Heap => Heap => Heap" where
  "merge (Node z x2 x3) (Node x4 x5 x6) =
     (if le x2 x5 then Node (merge x3 (Node x4 x5 x6)) x2 z else
        Node (merge (Node z x2 x3) x6) x5 x4)"
  | "merge (Node z x2 x3) (Nil2) = Node z x2 x3"
  | "merge (Nil2) y = y"
  fun toList :: "Nat => Heap => Nat list" where
  "toList (Z) y = Nil2"
  | "toList (S z) (Node x2 x3 x4) =
       Cons2 x3 (toList z (merge x2 x4))"
  | "toList (S z) (Nil2) = Nil2"
  fun heapSize :: "Heap => Nat" where
  "heapSize (Node l y r) = S (plus (heapSize l) (heapSize r))"
  | "heapSize (Nil2) = Z"
  fun toList2 :: "Heap => Nat list" where
  "toList2 x = toList (heapSize x) x"
  fun maybeToList :: "Heap Maybe => (Nat list) Maybe" where
  "maybeToList (Nothing) = Nothing"
  | "maybeToList (Just y) = Just (toList2 y)"
  fun deleteMinimum :: "Heap => Heap Maybe" where
  "deleteMinimum (Node l y r) = Just (merge l r)"
  | "deleteMinimum (Nil2) = Nothing"
  (*hipster plus
            listDeleteMinimum
            le
            merge
            toList
            heapSize
            toList2
            maybeToList
            deleteMinimum *)
  theorem x0 :
    "(listDeleteMinimum (toList2 h)) = (maybeToList (deleteMinimum h))"
    by (tactic {* Subgoal.FOCUS_PARAMS (K (Tactic_Data.hard_tac @{context})) @{context} 1 *})
end
