"""
    stage_states(w::FHWrapper, stage::Int)

Wrap Infinite Horizon MDP's states with given stage.
"""
function stage_states end

"""
    stage_stateindex(w::FHWrapper, ss::Tuple{<:Any,Int}, stage::Int)::Int

Compute the index of the given state in Infinite Horizon state space (only in given stage).
"""
function stage_stateindex end

"""
    HorizonLength(::Type{<:FHWrapper})

Check whether MDP is Finite or Infinite Horizon and return corresponding struct (FiniteHorizon or InfiniteHorizon).
"""
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

Return the number of *steps* that will be taken in the (PO)MDP, given it is Finite Horizon.

A simulation of a (PO)MDP with `horizon(m) == d` should contain *d+1* states and *d* actions and rewards.
"""
function horizon end
