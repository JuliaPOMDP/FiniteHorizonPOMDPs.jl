"""
    stage(ss::MDPState)::Int

Return number of state's stage
"""
function stage end

"""
    stage_states(m::Union{MDP,POMDP}, stage::Int)

Create Infinite Horizon MDP's states for given stage.
"""
function stage_states end

"""
    stage_stateindex(m::Union{MDP,POMDP}, ss::MDPState}::Int
    
Compute the index of the given state in Infinite Horizon for given stage state space.
"""
function stage_stateindex end

"""
    HorizonLength(::Type{<:Union{POMDP,MDP})
    HorizonLength(::Union{POMDP,MDP})

Check whether MDP is Finite or Infinite Horizon and return corresponding struct (FiniteHorizon or InfiniteHorizon).
"""
abstract type HorizonLength end

"If HorizonLength(m::Union{MDP,POMDP}) == FiniteHorizon(), horizon(m) should be implemented and return an integer"
struct FiniteHorizon <: HorizonLength end
"HorizonLength(m::Union{MDP,POMDP}) == InfiniteHorizon() indicates that horizon(m) should not be called."
struct InfiniteHorizon <: HorizonLength end

HorizonLength(m::Union{MDP,POMDP}) = HorizonLength(typeof(m))
HorizonLength(::Type{<:Union{MDP,POMDP}}) = InfiniteHorizon()

"""
Return the number of *steps* that will be taken in the (PO)MDP, given it is Finite Horizon.

A simulation of a (PO)MDP with `horizon(m) == d` should contain *d+1* states and *d* actions and rewards.
"""
function horizon end
