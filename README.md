# FiniteHorizonPOMDPs.jl
[POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl)-compatible interface for defining MDPs and POMDPs with finite horizons

**Warning: This package is preliminary and may change at any time.**

This package aims to provide a standard interface for defining problems with finite horizons.

The goals are to
1. Provide a way for value-iteration-based algorithms to start at the final-stage and work backwards
2. Be compatible with generic POMDPs.jl solvers and simulators (i.e. define isterminal correctly)
3. Provide a wrapper so that can an infinite horizon POMDP can be easily made into a finite horizon one
4. Be compatible with other interface extensions like constrained POMDPs

Notably, to help with (4), this package does **not** define `AbstractFiniteHorizonPOMDP`.
