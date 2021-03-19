module FiniteHorizonPOMDPs

using POMDPs
using POMDPModelTools
using Random: Random, AbstractRNG
using NamedTupleTools: merge
using ProgressMeter: @showprogress
using POMDPModelTools: SparseTabularMDP
using BeliefUpdaters
import BeliefUpdaters: DiscreteBelief

import POMDPLinter: @POMDP_require, @req, @subreq
import POMDPs: Policy, action
import Base.Iterators

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

export
    FiniteHorizonSolver,
    FiniteHorizonPolicy,
    solve,
    action

include("valueiteration.jl")
include("solver.jl")
end
