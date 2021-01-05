

mutable struct FiniteHorizonPolicy{Q<:AbstractArray, U<:AbstractMatrix, P<:AbstractMatrix, A, M<:MDP} <: Policy
    qmat::Q
    util::U 
    policy::P 
    action_map::Vector{A}
    include_Q::Bool 
    mdp::M
end

function FiniteHorizonPolicy(mdp::MDP)
    return FiniteHorizonPolicy(zeros(mdp.horizon, mdp.no_states, length(mdp.actions)), zeros(mdp.horizon, mdp.no_states), zeros(mdp.horizon, mdp.no_states), ordered_actions(mdp), true, mdp)
end

function addepochrecord(fhpolicy::FiniteHorizonPolicy, policy::Policy, mdp::MDP)    
    global fhepoch
    fhpolicy.qmat[fhepoch + 1, :, :] = policy.qmat[1:mdp.no_states, :]
    fhpolicy.util[fhepoch + 1, :] = policy.util[1:mdp.no_states]
    fhpolicy.policy[fhepoch + 1, :] = policy.policy[1:mdp.no_states]
    return fhpolicy
end

POMDPs.states(mdp::MDP) = stage_states(mdp, fhepoch)
POMDPs.actions(mdp::MDP) = stage_actions(mdp, fhepoch)
POMDPs.stateindex(mdp::MDP, state) = stage_stateindex(mdp, state.epoch, state)

fhepoch = -1

function mysolve(solverType::Type{<:Solver}, mdp::MDP; verbose::Bool=false)
    one_epoch_states_no = mdp.no_states    
    # mdp.no_states *= 2

    fhpolicy = FiniteHorizonPolicy(mdp)
    solver = solverType(max_iterations=1, verbose=verbose)

    println(states(mdp))
    for epoch=mdp.horizon:-1:1
        global fhepoch = epoch - 1

        if verbose
            println("EPOCH: $epoch")
        end

        # mdp.epoch = epoch - 1
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

        policy.util[mdp.no_states + 1:mdp.no_states * 2] = policy.util[1:mdp.no_states]
        policy.util[1:mdp.no_states] = zeros(mdp.no_states)

        solver = solverType(max_iterations=1, verbose=verbose, init_util=policy.util)
    end

    return fhpolicy
end