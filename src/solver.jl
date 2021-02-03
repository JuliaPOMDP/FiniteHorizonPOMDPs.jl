# Finite Horizon algorithm evaluating problem with use of other POMDP algorithms
# User has to implement FiniteHorizon function (stage_states and stage_stateindex) in such a way that the function returns current epoch and the following one (the one that has already been evaluated)
# For example see FiniteHorizonPOMDP/test/instances/1DFiniteHorizonGridWorld.jl
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
    sidx = stage_stateindex(policy.w.m, s, s.epoch)
    aidx = policy.policy'[sidx]
    return policy.action_map[aidx]
end

# Method stores record for each evaluated epoch to FiniteHorizonPolicy and returns it
function addepochrecord(fhpolicy::FiniteHorizonValuePolicy, qmat, util, policy, stage)    
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
            println("EPOCH: $stage")
        end

        stage_q, util, pol = valueiterationsolver(w, stage, util)

        fhpolicy = addepochrecord(fhpolicy, stage_q, util, pol, stage)

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
