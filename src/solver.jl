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
    return FiniteHorizonValuePolicy(zeros(horizon(mdp), no_states(mdp), length(actions(mdp))), zeros(horizon(mdp), no_states(mdp)), ones(Int64, horizon(mdp), no_states(mdp)), ordered_actions(mdp), true, mdp)
end

function no_states(mdp::MDP)
    length(stage_states(mdp,1))
end

function action(policy::FiniteHorizonValuePolicy, s::S) where S
    sidx = stage_stateindex(policy.mdp, s, epoch(s))
    aidx = policy.policy'[sidx]
    return policy.action_map[aidx]
end

# Method stores record for each evaluated epoch to FiniteHorizonPolicy and returns it
function addepochrecord(fhpolicy::FiniteHorizonValuePolicy, qmat, util, policy)    
    global fhepoch
    fhpolicy.qmat[fhepoch, :, :] = qmat
    fhpolicy.util[fhepoch, :] = util
    fhpolicy.policy[fhepoch, :] = policy
    return fhpolicy
end


# Global variable for storing number of epoch in order to pass it to functions from outer solvers
# Is there a better way to achieve this?
fhepoch = -1


# Is it possible to change name of this function to solve?
# The problem is that I am not able to use for example DiscreteValueIteration.solve() as I do not know the Solver in advance

# MDP given horizon 5 assumes that agent can move 4 times
function solve(mdp::MDP; verbose::Bool=false, new_VI::Bool=true)
    fhpolicy = FiniteHorizonValuePolicy(mdp)
    util = fill(0., no_states(mdp)) # XXX not all MDPs have a no_states field. Suggest using length(states(mdp))

    for epoch=horizon(mdp)-1:-1:1
        # Store number of epoch to global variable in order to work properly
        # Is there a better way to achieve this?
        global fhepoch = epoch

        if verbose
            println("EPOCH: $epoch")
        end

        stage_q, util, pol = valueiterationsolver(mdp, epoch, util)

        fhpolicy = addepochrecord(fhpolicy, stage_q, util, pol)

        if verbose
            println("POLICY\n")
            println("QMAT")
            println(stage_q)
            println("util")
            println(util)
            println("policy")
            println(policy)
            # println("action_map")
            # println(policy.action_map)
            # println("include_Q")
            # println(policy.include_Q)
            # println("mdp")
            # println(policy.mdp)
            println("\n\n\n")
        end
    end

    return fhpolicy
end
