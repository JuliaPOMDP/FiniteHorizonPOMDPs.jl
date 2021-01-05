# FiniteHorizonPOMDP

 Finite Horizon algorithm evaluating given problem with the use of other POMDP algorithms.  
 Currently supports ValueIterationSolver. So far tested only with 1D GridWorld(`tst/instances/...`).  

 Currently supporting: ValueIterationSolver

 User has to define the Problem using POMDPs requirement functions - `POMDPs.isterminal`, `POMDPs.reward`, `POMDPs.actionindex`, `POMDPs.discount` and `POMDPs.transition` (notice that `POMDPs.stage_states`, `POMDPs.stage_actions` and `POMDPs.stage_stateindex` are missing), as well as to implement FiniteHorizonPOMDP functions `FiniteHorizonPOMDP.stage_states`, `FiniteHorizonPOMDP.stage_actions` and `FiniteHorizonPOMDP.stage_stateindex`.
 
 Method currently passes the current epoch(that is to be evaluated) as well as the following epoch(the one that is already evaluated) as placeholder for precalculated Util matrix to work.

 Possible future improvements: Change arrays from row oriented to column oriented
                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility