module FiniteHorizonPOMDPs

using POMDPs
using POMDPModelTools
import POMDPs: Policy, action

export
    stage_states,
    stage_stateindex,
    HorizonLength,
    FiniteHorizon,
    InfiniteHorizon,
    horizon

include("interface.jl")

export 
    FiniteHorizonPolicy,
    solve,
    action

include("valueiteration.jl")
include("solver.jl")

end
