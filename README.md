# FiniteHorizonPOMDPs.jl


# FiniteHorizonPOMDPs.jl
[POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl)-compatible interface for defining MDPs and POMDPs with finite horizons

This package aims to provide a standard interface for defining problems with finite horizons.

The goals are to
1. Provide a way for value-iteration-based algorithms to start at the final-stage and work backwards
2. Be compatible with generic POMDPs.jl solvers and simulators (i.e. solvers should not have to check anything more than `isterminal`)
3. Provide a wrapper so that can an infinite horizon POMDP can be easily made into a finite horizon one
4. Be compatible with other interface extensions like constrained POMDPs and mixed observability problems

Notably, in accordance with goal (4), this package does **not** define something like `AbstractFiniteHorizonPOMDP`.

## Interface

- `HorizonLength(::Type{<:Union{MDP,POMDP}) = InfiniteHorizon()`
  - `FiniteHorizon`
  - `InfiniteHorizon`

`horizon(m::Union{MDP,POMDP})::Int`

`stage_states(m::Union{MDP,POMDP}, t::Int)`
`stage_stateindex(m::Union{MDP,POMDP}, t::Int, s)`

## Value Iteration for discrete problems

The package also contains a solver for discrete problems that uses Value Iteration.  
So far tested only with 1D GridWorld(`test/instances/...`).  

### Solution approach

 Current solution consists of simple solver `mysolve(mdp)` iterating and evaluating epochs and `FiniteHorizonPolicy` struct storing its results. This approach has been tested by comparisson of its results on GridWorld to results of value iteration on all epochs simultaneously. Instance of GridWorld problem is defined in `test/instances/1DFiniteHorizonGridWorld.jl`.

### How to use it

 User has to define the Problem using `POMDPs.jl` requirement functions - `POMDPs.isterminal`, `POMDPs.reward`, `POMDPs.actionindex`, `POMDPs.discount` and `POMDPs.transition` (notice that `POMDPs.states`, `POMDPs.actions` and `POMDPs.stateindex` are missing), as well as to implement FiniteHorizonPOMDP functions `FiniteHorizonPOMDPs.stage_states`, `FiniteHorizonPOMDPs.stage_actions` and `FiniteHorizonPOMDPs.stage_stateindex`.
