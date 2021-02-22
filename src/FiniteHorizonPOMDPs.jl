module FiniteHorizonPOMDPs

using POMDPs
using POMDPModelTools
using Random: Random, AbstractRNG
using NamedTupleTools: merge
using ProgressMeter: @showprogress
using POMDPModelTools: SparseTabularMDP

import POMDPLinter: @POMDP_require, @req, @subreq
import POMDPs: Policy, action
import Base.Iterators

export
    stage_states,
    stage_stateindex,
    HorizonLength,
    FiniteHorizon,
    InfiniteHorizon,
    horizon

include("interface.jl")

export
    fixhorizon

include("fixhorizon.jl")

export 
    FiniteHorizonSolver,
    FiniteHorizonPolicy,
    solve,
    action

include("valueiteration.jl")
include("solver.jl")
end
