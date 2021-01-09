# FiniteHorizonPOMDPs.jl
[POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl)-compatible interface for defining MDPs and POMDPs with finite horizons

**Warning: This package is preliminary and may change at any time.**

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

`stage_actions(m::Union{MDP,POMDP}, t::Int, [s])`

## Utilities

`fixhorizon(m::Union{MDP,POMDP}, T::Int)` creates one of
  - `FiniteHorizonMDP{S, A} <: MDP{Tuple{S,Int}, A}`
  - `FiniteHorizonPOMDP{S, A, O} <: POMDP{Tuple{S,Int}, A, O}`