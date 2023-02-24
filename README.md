# FiniteHorizonPOMDPs.jl
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Omastto1.github.io/FiniteHorizonPOMDPs.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://Omastto1.github.io/FiniteHorizonPOMDPs.jl/latest)
[![codecov](https://codecov.io/gh/JuliaPOMDP/FiniteHorizonPOMDPs.jl/branch/master/graph/badge.svg?token=09h0DS1ubi)](https://codecov.io/gh/JuliaPOMDP/FiniteHorizonPOMDPs.jl)

[POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl)-compatible interface for defining MDPs and POMDPs with finite horizons

This package aims to provide a standard interface for defining problems with finite horizons.

The goals are to
1. Provide a way for value-iteration-based algorithms to start at the final-stage and work backwards
2. Be compatible with generic POMDPs.jl solvers and simulators (i.e. solvers should not have to check anything more than `isterminal`)
3. Provide a wrapper so that an infinite horizon POMDP can be easily made into a finite horizon one
4. Be compatible with other interface extensions like constrained POMDPs and mixed observability problems

Notably, in accordance with goal (4), this package does **not** define something like `AbstractFiniteHorizonPOMDP`.

## Usage
Package offers interface for finite horizon POMDPs.
Solver currently supports only MDPs.
User can either implement:
 - finite horizon MDP using both POMDPs.jl and FiniteHorizonPOMDPs.jl interface functions or
 - infinite horizon MDP and transform it to finite horizon one using `fixhorizon` utility

 ```julia
 using FiniteHorizonPOMDPs
 using POMDPModels

 gw = SimpleGridWorld()    # initialize Infinite Horizon model
 fhgw = fixhorizon(gw, 2)  # use fixhorizon utility to transform it to Finite Horizon
 ```

## Interface

 - `HorizonLength(::Type{<:Union{MDP,POMDP})`
    - Checks whether MDP is Finite or Infinite Horizon and return corresponding struct (FiniteHorizon or InfiniteHorizon).    

 - `horizon(m::Union{MDP,POMDP})::Int`  
    - Returns the number of *steps* that will be taken in the (PO)MDP, given it is Finite Horizon.
 - `stage(m::Union{MDP,POMDP}, ss)::Int`
    - Returns the number of input variable's stage.
 - `stage_states(m::Union{MDP,POMDP}, stage::Int)`   
    - Creates (PO)MDP's states for given stage.
 - `stage_stateindex(m::Union{MDP,POMDP}, state)`  
    - Computes the index of the given state in the corresponding stage.
 - `ordered_stage_states(w::FHWrapper, stage::Int)`
    - Returns an `AbstractVector` of states from given stage ordered according to `stage_stateindex(mdp, s)`.
 - `stage_observations(m::Union{MDP,POMDP}, stage::Int)`
    - Creates (PO)MDP's observations for given stage.
 - `stage_obsindex(m::Union{MDP,POMDP}, o::stage::Int)`
    - Computes the index of the given observation in the corresponding stage.
 - `ordered_stage_observations(w::FHWrapper, stage::Int)`
    - Returns an `AbstractVector` of observations from given stage ordered according to `stage_obsindex(w,o)`.
