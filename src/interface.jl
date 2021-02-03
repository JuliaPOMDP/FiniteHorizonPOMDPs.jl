# TODO: Improve docstring https://docs.julialang.org/en/v1/manual/documentation/
"stage_states(mdp::MDP, stage::Int64)"
function stage_states end

# TODO: Improve docstring
"stage_stateindex(mdp::MDP, s, stage::Int64)::Integer"
function stage_stateindex end

# TODO: Docstring
abstract type HorizonLength end

"If HorizonLength(m::Union{MDP,POMDP}) == FiniteHorizon(), horizon(m) should be implemented and return an integer"
struct FiniteHorizon <: HorizonLength end
"HorizonLength(m::Union{MDP,POMDP}) == InfiniteHorizon() indicates that horizon(m) should not be called."
struct InfiniteHorizon <: HorizonLength end

HorizonLength(m::Union{MDP,POMDP}) = HorizonLength(typeof(m))
HorizonLength(::Type{<:Union{MDP,POMDP}}) = InfiniteHorizon()

# TODO Improve docstring
"""
    horizon(m::Union{MDP,POMDP})::Integer

Return the number of *steps* that will be taken in the (PO)MDP.

A simulation of a (PO)MDP with `horizon(m) == d` should contain *d+1* states and *d* actions and rewards.
"""
function horizon end
