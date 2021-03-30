module FiniteHorizonPOMDPs

using POMDPs
using POMDPModelTools
using Random: Random, AbstractRNG
using ProgressMeter: @showprogress
using BeliefUpdaters


export
    stage_states,
    stage_stateindex,
    HorizonLength,
    FiniteHorizon,
    InfiniteHorizon,
    horizon,
    stage_observations,
    stage_obsindex,
    ordered_stage_states,
    ordered_stage_observations

include("interface.jl")

export
    fixhorizon

include("fixhorizon.jl")

end
