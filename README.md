# FiniteHorizonPOMDP

 Finite Horizon algorithm evaluating given problem with the use of other POMDP algorithms.  
 Currently supports ValueIterationSolver. So far tested only with 1D GridWorld(`tst/instances/...`).  

 ## Solution approach

 Current solution consists of simple solver `mysolve(solver_type, mdp)` iterating and evaluating epochs and `FiniteHorizonPolicy` struct storing its results. This approach has been tested by comparisson of its results on GridWorld to results of value iteration on all epochs simultaneously. Finite horizon instance of GridWorld problem is defined in `tst/instances/1DFiniteHorizonGridWorld.jl` and infinite horizon instance is defined in `tst/instances/1DGridWorld.jl`.

## How to use it

 User has to define the Problem using `POMDPs.jl` requirement functions - `POMDPs.isterminal`, `POMDPs.reward`, `POMDPs.actionindex`, `POMDPs.discount` and `POMDPs.transition` (notice that `POMDPs.stage_states`, `POMDPs.stage_actions` and `POMDPs.stage_stateindex` are missing), as well as to implement FiniteHorizonPOMDP functions `FiniteHorizonPOMDP.stage_states`, `FiniteHorizonPOMDP.stage_actions` and `FiniteHorizonPOMDP.stage_stateindex`.
 
 Method currently passes the current epoch(that is to be evaluated) as well as the following epoch(the one that is already evaluated) as placeholder for precalculated Util matrix to work.

 ## Future plan

 Possible future improvements: Change arrays from row oriented to column oriented
                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility