# FiniteHorizonPOMDPs.jl
A Julia interface built on top of [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl) as extension for finite horizon POMDPs.


## Package Features
The goals of this package is to:
1. offer value-iteration-based algorithms to start at the final-stage and work backwards,
2. preserve compatibility with other interface extensions like constrained POMDPs and mixed observability problems,
3. offer ways to create finite horizon POMDPs.

Package supports two ways to do that.
1. Custom finite horizon POMDPs implemented using package's interface methods.
2. Utility which wraps infinite horizon POMDP into finite horizon one.

This is achieved without defining any abstract class.

## Interface
Finite horizon POMDPs are to be defined using [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl) interface extended with new functions from this package

FiniteHorizonPOMDPs' interface is documented in [Interface Documentation](@ref) section.


## Solvers
Finite horizon MDP problems can be solved using following solver:
- `FiniteHorizonValueIteration.jl`- Finite horizon value iteration solver.

This list is going to be extended with POMDPs solvers in future.
