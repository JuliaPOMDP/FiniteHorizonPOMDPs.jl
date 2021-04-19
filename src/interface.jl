"""
    HorizonLength(::Type{<:Union{MDP,POMDP})
    HorizonLength(::Union{MDP,POMDP})

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

"""
    stage(m::Union{MDP,POMDP}, ss)::Int
    stage(m::Union{MDP,POMDP}, o)::Int
    stage(d)::Int

Considering a variable or distribution containing its stage assignment, return the number of its stage.
"""
function stage end

"""
    stage_states(m::Union{MDP,POMDP}, stage::Int)

Create (PO)MDP's states for given stage.
"""
function stage_states end

"""
    stage_stateindex(m::Union{MDP,POMDP}, ss}::Int

Compute the index of the given state in the corresponding stage.
"""
function stage_stateindex end

"""
    ordered_stage_states(w::FHWrapper, stage::Int)

Return an AbstractVector of states from given stage ordered according to stage_stateindex(mdp, s).
"""
function ordered_stage_states end

"""
    stage_observations(m::Union{MDP,POMDP}, stage::Int)

Create (PO)MDP's observations for given stage.
"""
function stage_observations end

"""
    stage_obsindex(m::Union{MDP,POMDP}, o::stage::Int)

Compute the index of the given observation in the corresponding stage.
"""
function stage_obsindex end

"""
    ordered_stage_observations(w::FHWrapper, stage::Int)

Return an AbstractVector of observations from given stage ordered according to stage_obsindex(w,o).
"""
function ordered_stage_observations end
