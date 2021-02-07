# Finite Horizon algorithm evaluating problem with use of other POMDP algorithms
# User has to define (PO)MDP instance with use of POMDPs interface methods isterminal, reward, actions, states, stateindex, actions, actionindex, discount, transition

# For example see problems defined in POMDPModels package or FiniteHorizonPOMDP/test/instances/1DFiniteHorizonGridWorld.jl
#
# Currently supporting: ValueIterationSolver
#
# Possible future improvements: Change arrays from row oriented to column oriented
#                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility


# Policy struct created according to one used in DiscreteValueIteration

#TODO: Dosctring
struct FiniteHorizonSolver <: Solver
    verbose::Bool
end

#TODO: Dosctring
mutable struct FiniteHorizonValuePolicy{Q<:AbstractArray, U<:AbstractMatrix, P<:AbstractMatrix, A, M<:MDP} <: Policy
    qmat::Q
    util::U 
    policy::P 
    action_map::Vector{A}
    include_Q::Bool 
    m::M
end

# Policy constructor
function FiniteHorizonValuePolicy(m::MDP)
    return FiniteHorizonValuePolicy(zeros(m.horizon + 1, length(stage_states(m, 1)), length(actions(m))), zeros(m.horizon + 1, length(stage_states(m, 1))), ones(Int64, m.horizon + 1, length(stage_states(m, 1))), ordered_actions(m), true, m)
end

function action(policy::FiniteHorizonValuePolicy, s::S) where S
    sidx = stateindex(policy.m, s)
    aidx = policy.policy'[sidx]
    return policy.action_map[aidx]
end

"""
    addstagerecord(fhpolicy::FiniteHorizonValuePolicy, qmat, util, policy, stage)

Store record for given stage results to `FiniteHorizonPolicy` and return updated version.
"""
function addstagerecord(fhpolicy::FiniteHorizonValuePolicy, qmat, util, policy, stage)    
    fhpolicy.qmat[stage, :, :] = qmat
    fhpolicy.util[stage, :] = util
    fhpolicy.policy[stage, :] = policy
    return fhpolicy
end

# MDP given horizon 5 assumes that agent can move 5 times
function POMDPs.solve(solver::FiniteHorizonSolver, m::MDP)
    if typeof(HorizonLength(m)) == InfiniteHorizon
        throw(ArgumentError("m should be valid Finite Horizon MDP with methods from FiniteHorizonPOMDPs.jl/src/interface.jl implemented"))
    end

    fhpolicy = FiniteHorizonValuePolicy(m)
    util = fill(0., length(stage_states(m, 1)))

    for stage=m.horizon:-1:1
        if solver.verbose
            println("Stage: $stage")
        end

        stage_q, util, pol = valueiterationsolver(m, stage, util)

        fhpolicy = addstagerecord(fhpolicy, stage_q, util, pol, stage)

        if solver.verbose
            println("POLICY\n")
            println("QMAT")
            println(stage_q)
            println("util")
            println(util)
            println("policy")
            println(policy)
            println("\n\n\n")
        end
    end

    return fhpolicy
end