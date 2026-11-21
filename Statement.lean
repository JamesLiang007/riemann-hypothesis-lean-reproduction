import Main
import Lean

def rhReferenceStatement : Prop :=
  ∀ z : ℂ, riemannZeta z = 0 →
    (¬ ∃ n : ℕ, z = -2 * ((n : ℂ) + 1)) →
    z ≠ 1 → z.re = 1 / 2

#check riemannHypothesis
#print RiemannHypothesis
example : rhReferenceStatement = RiemannHypothesis := rfl
example : rhReferenceStatement := riemannHypothesis
#print axioms riemannHypothesis

open Lean Elab Command in
run_cmd do
  let allowed : List Name := [`propext, `Classical.choice, `Quot.sound]
  let axioms ← Lean.collectAxioms `riemannHypothesis
  unless axioms.all allowed.contains do
    throwError m!"Unexpected axiom dependencies: {axioms.toList}"
  logInfo "PASS statement comparison and stored axiom audit for riemannHypothesis"
