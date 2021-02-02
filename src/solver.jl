# Finite Horizon algorithm evaluating problem with use of other POMDP algorithms
# User has to implement FiniteHorizon function (stage_states, stage_actions and stage_stateindex) in such a way that the function returns current epoch and the following one (the one that has already been evaluated)
# For example see FiniteHorizonPOMDP/test/instances/1DFiniteHorizonGridWorld.jl
#
# Currently supporting: ValueIterationSolver
#
# Possible future improvements: Change arrays from row oriented to column oriented
#                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility


# Policy struct created according to one used in DiscreteValueIteration
mutable struct FiniteHorizonValuePolicy{Q<:AbstractArray, U<:AbstractMatrix, P<:AbstractMatrix, A, M<:MDP} <: Policy
    qmat::Q
    util::U 
    policy::P 
    action_map::Vector{A}
    include_Q::Bool 
    mdp::M
end

# Policy constructor
function FiniteHorizonValuePolicy(mdp::MDP)
    return FiniteHorizonValuePolicy(zeros(mdp.horizon, mdp.no_states, length(mdp.actions)), zeros(mdp.horizon, mdp.no_states), ones(Int64, mdp.horizon, mdp.no_states), ordered_actions(mdp), true, mdp)
end

function action(policy::FiniteHorizonValuePolicy, s::S) where S
    sidx = stage_stateindex(policy.mdp, s, s.epoch)
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
function solve(mdp::MDP; verbose::Bool=false, new_VI::Bool=true)
    fhpolicy = FiniteHorizonValuePolicy(mdp)
    util = fill(0., mdp.no_states) # XXX not all MDPs have a no_states field. Suggest using length(states(mdp))

    for stage=mdp.horizon-1:-1:1

        if verbose
            println("EPOCH: $stage")
        end

        stage_q, util, pol = valueiterationsolver(mdp, stage, util)

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
