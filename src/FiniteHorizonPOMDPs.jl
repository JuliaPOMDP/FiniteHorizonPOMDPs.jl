module FiniteHorizonPOMDPs

using POMDPs
using POMDPTools
using Random: Random, AbstractRNG


export
    HorizonLength,
    FiniteHorizon,
    InfiniteHorizon,
    horizon,
    stage,
    stage_states,
    stage_stateindex,
    ordered_stage_states,
    stage_observations,
    stage_obsindex,
    ordered_stage_observations

include("interface.jl")

export
    fixhorizon

include("fixhorizon.jl")

end
