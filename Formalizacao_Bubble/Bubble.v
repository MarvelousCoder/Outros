Require Import List.
Require Import Arith.
Require Import Sorted.
Require Import Recdef.

Function bubble (l : list nat) {measure length} : list nat :=
  match l with
  | nil => nil
  | n :: nil => n :: nil
  | n1 :: n2 :: l' => if leb n1 n2
                      then n1 :: (bubble (n2 :: l'))
                      else n2 :: (bubble (n1 :: l'))
  end.
Proof.
  auto. auto.
Defined.

Fixpoint bubbleSort (l : list nat) : list nat :=
  match l with
  | nil => nil
  | n :: l' => bubble (n :: (bubbleSort l'))
  end.

Notation "[ ]" := nil.
Notation "[ x ; .. ; y ]" := (cons x .. (cons y nil) ..).

Eval compute in bubble (1 :: 2 :: 0 :: 3 :: 1 :: nil).
Eval compute in bubbleSort (1 :: 2 :: 0 :: 3 :: 1 :: nil).
Eval compute in bubbleSort (1 :: 2 :: 0 :: 3 :: 1 :: nil).
Eval compute in bubbleSort (1 :: 2 :: 10 :: 3 :: 6 :: nil).

Lemma bubbleSort_nil: bubble nil = nil.
Proof.
  reflexivity.
Qed.

Lemma bubbleSort_unique: forall  n: nat,
    bubble (n :: nil) = n :: nil.
Proof.
  reflexivity.
Qed.

(* Lemma bubble_leq : forall a b l, *)
(*     a <= b -> bubble (a :: (b :: l)) = a :: (bubble (b :: l)). *)
(* Proof. *)
(*   intros a b l Hle. *)
(*   functional induction (bubble (b :: l)%list).  *)
(* Abort. *)

Theorem restricted_excluded_middle : forall P b,
  (P <-> b = true) -> P \/ ~P.
Proof.
  intros P [] H.
  - left. apply H. reflexivity.
  - right. unfold not. 
    intros. inversion H.
    apply H1 in H0.
    inversion H0.
Qed.

Theorem beq_nat_true : forall n m,
    beq_nat n m = true -> n = m.
Proof.
    intros n. induction n as [| n' IHn'].
    - intros m H. destruct m.
      + reflexivity.
      + inversion H.
    - intros m H. destruct m.
      + inversion H.
      + apply IHn' in H.
        rewrite -> H.
        reflexivity.
Qed.

Theorem beq_nat_refl : forall n : nat,
  true = beq_nat n n.
Proof.
  intros n. induction n as [| n' IHn'].
  - simpl. reflexivity.
  - simpl. apply IHn'.
Qed.

Lemma eq_dec: forall (n m: nat), (n=m) \/ (n<>m).
Proof.
  intros n m.
  apply (restricted_excluded_middle (n = m) (beq_nat n m)).
  split.
  - intros.
    symmetry.
    rewrite -> H.
    apply beq_nat_refl.
  - apply beq_nat_true.
Defined.

Fixpoint num_oc (n : nat) (l:list nat) : nat :=
  match l with 
    | [] => 0
    | h :: tl =>
      match eq_nat_dec n h with
        | left _  => S (num_oc n tl)
        | right _ => num_oc n tl 
      end
  end.


Definition equiv l l' := forall n, num_oc n l = num_oc n l'.

Inductive ordenada : list nat -> Prop :=
  | nil_ord : ordenada nil
  | one_ord : forall n:nat, ordenada [n]
  | mult_ord : forall (x y : nat) (l : list nat), ordenada (y :: l) -> le x y -> ordenada (x :: (y :: l)).

Theorem ex_falso_quodlibet : forall (P:Prop),
  False -> P.
Proof.
  intros P contra.
  destruct contra.  
Qed.

Fact num_oc_fact: forall l n,
    num_oc n (n :: l) = S (num_oc n l).
Proof.
  induction l.
  - simpl.
    intros n.
    destruct (eq_nat_dec n n).
    + reflexivity.
    + unfold not in n0.
      apply ex_falso_quodlibet.
      apply n0; reflexivity.
  - simpl num_oc.
    intros n.
    destruct (eq_nat_dec n n).
    + reflexivity.
    + apply ex_falso_quodlibet.
      apply n0; reflexivity.
Qed.

Lemma num_oc_bubble: forall l n,
    num_oc n (bubble l) =  num_oc n l.
Proof.
  induction l.
  - intros.
    reflexivity.
  - intros.
    generalize dependent l; destruct l.
    + intros.
      simpl.
      destruct eq_nat_dec.
      * reflexivity.
      * reflexivity.
    + intros.
      simpl num_oc.
      * destruct (eq_nat_dec n a).
        ** destruct (eq_nat_dec n n0).
           *** rewrite <- e.
               rewrite <- num_oc_fact.
               rewrite <- e0.
               replace (num_oc n (n :: l)) with (num_oc n (n0 :: l)).
               rewrite <- IHl.
               rewrite <- e0.
Admitted.
               
Lemma bubble_preserva_ordem : forall l, 
    ordenada l -> ordenada (bubble l).
Proof.
Admitted.

Theorem correcao: forall l,  (equiv l (bubbleSort l)) /\ ordenada (bubbleSort l).
Proof.
  induction l.
  - simpl.
    split.
    + unfold equiv.
      reflexivity.
    + apply nil_ord.
  - split.
    + destruct IHl.
      unfold equiv in *.
      simpl bubbleSort.
      symmetry.
      rewrite -> num_oc_bubble.
      simpl num_oc.
      * destruct eq_nat_dec.
        ** rewrite -> H.
           reflexivity.
        ** symmetry.
           apply H.
    + destruct IHl.
      simpl.
      apply bubble_preserva_ordem.
      
 Admitted.
      
Theorem correcao_comp: forall (l:list nat), {l' | equiv l l' /\ ordenada l'}.
Proof.
  intro l.
  exists (bubbleSort l).
  apply correcao.
Qed.
  
Recursive Extraction correcao_comp.
Extraction "insercao.ml" correcao_comp.
  
