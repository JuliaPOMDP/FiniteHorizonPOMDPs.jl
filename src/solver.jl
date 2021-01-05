# Finite Horizon algorithm evaluating problem with use of other POMDP algorithms
# User has to implement FiniteHorizon function (stage_states, stage_actions and stage_stateindex) in such a way that the function returns current epoch and the following one (the one that has already been evaluated)
# For example see FiniteHorizonPOMDP/test/instances/1DFiniteHorizonGridWorld.jl
#
# Currently supporting: ValueIterationSolver
#
# Possible future improvements: Change arrays from row oriented to column oriented
#                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility


# Policy struct created according to one used in DiscreteValueIteration
mutable struct FiniteHorizonPolicy{Q<:AbstractArray, U<:AbstractMatrix, P<:AbstractMatrix, A, M<:MDP} <: Policy
    qmat::Q
    util::U 
    policy::P 
    action_map::Vector{A}
    include_Q::Bool 
    mdp::M
end

# Policy constructor
function FiniteHorizonPolicy(mdp::MDP)
    return FiniteHorizonPolicy(zeros(mdp.horizon, mdp.no_states, length(mdp.actions)), zeros(mdp.horizon, mdp.no_states), zeros(Int64, mdp.horizon, mdp.no_states), ordered_actions(mdp), true, mdp)
end

# Method stores record for each evaluated epoch to FiniteHorizonPolicy and returns it
function addepochrecord(fhpolicy::FiniteHorizonPolicy, policy::Policy, mdp::MDP)    
    global fhepoch
    fhpolicy.qmat[fhepoch, :, :] = policy.qmat[1:mdp.no_states, :]
    fhpolicy.util[fhepoch, :] = policy.util[1:mdp.no_states]
    if fhepoch == mdp.horizon - 1
        fhpolicy.policy[mdp.horizon, :] = ones(Int64, mdp.no_states)
    end
    fhpolicy.policy[fhepoch, :] = policy.policy[1:mdp.no_states]
    return fhpolicy
end

# In order to run Infinite Horizon MDPs one has to implement these functions
# User has to implement these fuctions in such a way that the function returns current epoch and the following one (the one that has already been evaluated)
function stage_states(mdp::MDP, epoch::Int64) end
POMDPs.states(mdp::MDP) = stage_states(mdp, fhepoch)

function stage_actions(mdp::MDP, fhepoch::Int64) end
POMDPs.actions(mdp::MDP) = stage_actions(mdp, fhepoch)

function stage_stateindex(mdp::MDP, s, epoch::Int64) end
POMDPs.stateindex(mdp::MDP, s) = stage_stateindex(mdp, s, fhepoch)

# Global variable for storing number of epoch in order to pass it to functions from outer solvers
# Is there a better way to achieve this?
fhepoch = -1


# Is it possible to change name of this function to solve?
# The problem is that I am not able to use for example DiscreteValueIteration.solve() as I do not know the Solver in advance

# MDP given horizon 5 assumes that agent can move 4 times
# 
function mysolve(solverType::Type{<:Solver}, mdp::MDP; verbose::Bool=false)
    fhpolicy = FiniteHorizonPolicy(mdp)
    solver = solverType(max_iterations=1, verbose=verbose)

    for epoch=mdp.horizon-1:-1:1
        # Store number of epoch to global variable in order to work properly
        # Is there a better way to achieve this?
        global fhepoch = epoch

        if verbose
            println("EPOCH: $epoch")
        end

        policy = solve(solver, mdp)

        fhpolicy = addepochrecord(fhpolicy, policy, mdp)

        if verbose
            println("POLICY\n")
            println("QMAT")
            println(policy.qmat)
            println("util")
            println(policy.util)
            println("policy")
            println(policy.policy)
            println("action_map")
            println(policy.action_map)
            println("include_Q")
            println(policy.include_Q)
            println("mdp")
            println(policy.mdp)
            println("\n\n\n")
            # print(policy)
            # println(Dict(map((x, y) -> Pair(x.name + (x.epoch - mdp.epoch) * (one_epoch_states_no / 2), y), ordered_states(mdp)[1:one_epoch_states_no], policy.action_map[policy.policy][1:one_epoch_states_no])))
            # println(Dict(map((x, y) -> Pair(x.name + (x.epoch - mdp.epoch) * (one_epoch_states_no / 2), y), ordered_states(mdp)[1:one_epoch_states_no], policy.util[1:one_epoch_states_no])))
        end

        # Util matrix has to be changed in such a way that the values are moved from current epoch (1:mdp.no_states) to following epoch(mdp.no_states + 1:mdp.no_states * 2)
        policy.util[mdp.no_states + 1:mdp.no_states * 2] = policy.util[1:mdp.no_states]
        policy.util[1:mdp.no_states] = zeros(mdp.no_states)

        solver = solverType(max_iterations=1, verbose=verbose, init_util=policy.util)
    end

    return fhpolicy
end