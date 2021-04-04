# FiniteHorizonPOMDPs.jl
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Omastto1.github.io/FiniteHorizonPOMDPs.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://Omastto1.github.io/FiniteHorizonPOMDPs.jl/latest)
[![Coverage Status](https://coveralls.io/repos/github/Omastto1/FiniteHorizonPOMDPs.jl/badge.svg?branch=master)](https://coveralls.io/github/Omastto1/FiniteHorizonPOMDPs.jl?branch=master)

[POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl)-compatible interface for defining MDPs and POMDPs with finite horizons

This package aims to provide a standard interface for defining problems with finite horizons.

The goals are to
1. Provide a way for value-iteration-based algorithms to start at the final-stage and work backwards
2. Be compatible with generic POMDPs.jl solvers and simulators (i.e. solvers should not have to check anything more than `isterminal`)
3. Provide a wrapper so that an infinite horizon POMDP can be easily made into a finite horizon one
4. Be compatible with other interface extensions like constrained POMDPs and mixed observability problems

Notably, in accordance with goal (4), this package does **not** define something like `AbstractFiniteHorizonPOMDP`.

## Use
Package offers interface for finite horizon POMDPs.
Solver currently supports only MDPs.
User can either implement:
 - finite horizon MDP using both POMDPs.jl and FiniteHorizonPOMDPs.jl interface functions or
 - infinite horizon MDP and transform it to finite horizon one using `fixhorizon` utility

## Interface

- `HorizonLength(::Type{<:Union{MDP,POMDP}) = InfiniteHorizon()`
  - `FiniteHorizon`
  - `InfiniteHorizon`

 - `horizon(m::Union{MDP,POMDP})::Int`  
 - `stage_states(m::Union{MDP,POMDP}, stage::Int)`   
 - `stage_stateindex(m::Union{MDP,POMDP}, state)`  
 - `stage(m::Union{MDP,POMDP}, state)`  
