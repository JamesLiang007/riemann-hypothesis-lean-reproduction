import Lean
import Lean.Replay
import Lean.Util.ForEachExpr

open Lean

def expressionDependencies (e : Expr) : StateRefT NameSet IO Unit :=
  e.forEach fun e => do
    match e with
    | .const name _ | .proj name _ _ => modify fun names => names.insert name
    | .lit (.natVal _) => modify fun names => names.insert `Nat
    | .lit (.strVal _) => modify fun names => names.insert `String
    | _ => pure ()

def declarationDependencies (ci : ConstantInfo) : StateRefT NameSet IO Unit := do
  expressionDependencies ci.type
  if let some value := ci.value? (allowOpaque := true) then
    expressionDependencies value
  match ci with
  | .inductInfo info =>
    modify fun names => names ++ NameSet.ofList (info.all ++ info.ctors)
  | .ctorInfo info =>
    modify fun names => names.insert info.induct
  | .recInfo info =>
    modify fun names => names ++ NameSet.ofList info.all
    for rule in info.rules do
      modify fun names => names.insert rule.ctor
      expressionDependencies rule.rhs
  | .quotInfo _ =>
    modify fun names => names.insert `Eq
  | _ => pure ()

def collectClosure (env : Environment) (target : Name)
    : IO (Std.HashMap Name ConstantInfo) := do
  let mut pending := #[(target, target)]
  let mut result : Std.HashMap Name ConstantInfo := {}
  while !pending.isEmpty do
    let (name, parent) := pending.back!
    pending := pending.pop
    if result.contains name then continue
    let some info := env.find? name
      | throw <| IO.userError s!"Missing declaration {name} referenced by {parent}"
    if info.isUnsafe || info.isPartial then
      throw <| IO.userError s!"Cannot safely replay {name} referenced by {parent}"
    result := result.insert name info
    let (_, deps) ← (declarationDependencies info).run {}
    for dep in deps do
      if !result.contains dep then
        pending := pending.push (dep, name)
    if result.size % 10000 == 0 then
      IO.println s!"Collected {result.size} declarations"
      (← IO.getStdout).flush
  return result

def main : IO Unit := do
  let target := `riemannHypothesis
  initSearchPath (← findSysroot)
  IO.println "Loading declaration bodies from Main"
  (← IO.getStdout).flush
  let env ← importModules #[{ module := `Main }] {} (level := .private)
  let some (.thmInfo _) := env.find? target
    | throw <| IO.userError s!"Could not find theorem {target}"
  IO.println "Tracing declarations from the theorem type and proof"
  (← IO.getStdout).flush
  let closure ← collectClosure env target
  let allowed : List Name := [`propext, `Classical.choice, `Quot.sound]
  let mut axioms : Array Name := #[]
  let mut modules : NameSet := {}
  for (name, info) in closure.toList do
    if let some idx := env.getModuleIdxFor? name then
      if let some mod := env.allImportedModuleNames[idx.toNat]? then
        modules := modules.insert mod
    if let .axiomInfo _ := info then
      axioms := axioms.push name
      unless allowed.contains name do
        throw <| IO.userError s!"Unexpected axiom in declaration closure: {name}"
  IO.println s!"CLOSURE {closure.size} declarations across {modules.toList.length} modules"
  IO.println s!"ACTUAL AXIOMS {(axioms.qsort Name.lt).toList}"
  IO.println "Starting kernel replay in an empty environment"
  (← IO.getStdout).flush
  let checked ← (← mkEmptyEnvironment).replay closure
  for (name, _) in closure.toList do
    unless (checked.find? name).isSome do
      throw <| IO.userError s!"Declaration absent after replay: {name}"
  IO.println s!"PASS {target}: kernel accepted its transitive declaration closure"
