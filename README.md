# FiniteHorizonPOMDP

 Finite Horizon algorithm evaluating given problem using Value Iteration.  
So far tested only with 1D GridWorld(`test/instances/...`).  

 ## Solution approach

 Current solution consists of simple solver `mysolve(mdp)` iterating and evaluating epochs and `FiniteHorizonPolicy` struct storing its results. This approach has been tested by comparisson of its results on GridWorld to results of value iteration on all epochs simultaneously. Instance of GridWorld problem is defined in `test/instances/1DFiniteHorizonGridWorld.jl`.

## How to use it

 User has to define the Problem using `POMDPs.jl` requirement functions - `POMDPs.isterminal`, `POMDPs.reward`, `POMDPs.actionindex`, `POMDPs.discount` and `POMDPs.transition` (notice that `POMDPs.states`, `POMDPs.actions` and `POMDPs.stateindex` are missing), as well as to implement FiniteHorizonPOMDP functions `FiniteHorizonPOMDPs.stage_states`, `FiniteHorizonPOMDPs.stage_actions` and `FiniteHorizonPOMDPs.stage_stateindex`.

 ## Future plan

 Possible future improvements: Change arrays from row oriented to column oriented
                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility
