module FiniteHorizonPOMDP

using POMDPs
using POMDPModelTools

import POMDPs: Policy, action

export 
    FiniteHorizonPolicy,
    solve,
    action

include("valueiteration.jl")
include("solver.jl")

end
