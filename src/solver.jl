# Finite Horizon algorithm evaluating problem with use of other POMDP algorithms
# User has to define (PO)MDP instance with use of POMDPs interface methods isterminal, reward, actions, states, stateindex, actions, actionindex, discount, transition

# For example see problems defined in POMDPModels package or FiniteHorizonPOMDP/test/instances/1DFiniteHorizonGridWorld.jl
#
# Currently supporting: ValueIterationSolver
#
# Possible future improvements: Change arrays from row oriented to column oriented
#                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility


# Policy struct created according to one used in DiscreteValueIteration
mutable struct FiniteHorizonValuePolicy{Q<:AbstractArray, U<:AbstractMatrix, P<:AbstractMatrix, A, W<:FHWrapper} <: Policy
    qmat::Q
    util::U 
    policy::P 
    action_map::Vector{A}
    include_Q::Bool 
    w::W
end

# Policy constructor
function FiniteHorizonValuePolicy(w::FHWrapper)
    return FiniteHorizonValuePolicy(zeros(w.horizon + 1, length(states(w.m)), length(actions(w.m))), zeros(w.horizon + 1, length(states(w.m))), ones(Int64, w.horizon + 1, length(states(w.m))), ordered_actions(w.m), true, w)
end

function action(policy::FiniteHorizonValuePolicy, s::S) where S
    sidx = stateindex(policy.w, s)
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

# MDP given horizon 5 assumes that agent can move 4 times
function solve(w::FHWrapper; verbose::Bool=false, new_VI::Bool=true)
    fhpolicy = FiniteHorizonValuePolicy(w)
    util = fill(0., length(states(w.m)))

    for stage=w.horizon:-1:1
        if verbose
            println("Stage: $stage")
        end

        stage_q, util, pol = valueiterationsolver(w, stage, util)

        fhpolicy = addstagerecord(fhpolicy, stage_q, util, pol, stage)

        if verbose
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
