# Interface Documentation
This page describes the finite horizon interface.
In order to fully define one the user has to also use methods from [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl) interface defined [here](https://juliapomdp.github.io/POMDPs.jl/stable/api/).

Docstrings for FiniteHorizonPOMDPs.jl interface members can be [accessed through Julia's built-in documentation system](https://docs.julialang.org/en/v1/manual/documentation/index.html#Accessing-Documentation-1) or in the list below.

```@meta
CurrentModule = FiniteHorizonPOMDPs
```
 
## Contents

```@contents
Pages = ["interface.md"]
```

## Index

```@index
Pages = ["interface.md"]
```

## Types

```@docs
FiniteHorizonPOMDPs.FiniteHorizon
FiniteHorizonPOMDPs.HorizonLength
FiniteHorizonPOMDPs.InfiniteHorizon
```

## Model Functions

```@docs
FiniteHorizonPOMDPs.horizon
FiniteHorizonPOMDPs.fixhorizon
FiniteHorizonPOMDPs.stage
FiniteHorizonPOMDPs.stage_stateindex
FiniteHorizonPOMDPs.stage_states
```