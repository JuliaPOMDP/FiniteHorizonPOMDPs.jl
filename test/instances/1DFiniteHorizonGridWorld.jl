using POMDPs
using FiniteHorizonPOMDPs


struct FHExampleState 
    position::Int64
    epoch::Int64
    done::Bool # are we in a terminal state?
end

# initial state constructor
FHExampleState(position::Int64, epoch::Int64)::FHExampleState = FHExampleState(position, epoch, false)
FHExampleState(position::Int64)::FHExampleState = FHExampleState(position, 0, false)
FHExampleState(position::Int64, done::Bool)::FHExampleState = FHExampleState(position, 0, done)

struct FHExample <: MDP{FHExampleState, Symbol} # Note that our MDP is parametarized by the state and the action
    no_states::Int64 # number od states
    horizon::Int64
    actions::Vector{Symbol}
    actionCost::Float64
    actionsImpact::Base.ImmutableDict{Symbol, Int64}
    reward_states::Vector{Int64}
    reward::Float64
    discount_factor::Float64 # discount factor
    noise::Float64
end

function POMDPs.isterminal(mdp::FHExample, state::FHExampleState)::Bool
    return state.done
end

function isreward(mdp::FHExample, position::Int64)::Bool
    return position in mdp.reward_states
end

function POMDPs.reward(mdp::FHExample, s::FHExampleState, a::Symbol, sp::FHExampleState)::Float64
    isreward(mdp, sp.position) ? mdp.reward : mdp.actionCost
end

# returns current stage's states whose util value is to be updated
# is terminal if the stage is terminal or the state is goal
function FiniteHorizonPOMDPs.stage_states(mdp::FHExample, epoch::Int64)::Array{FHExampleState}
    mdp_states = FHExampleState[]
    for i=1:mdp.no_states
        push!(mdp_states, FHExampleState(i, epoch, isreward(mdp, i) || epoch==mdp.horizon + 1))
    end
   
    return mdp_states
end

# Implementation of function that are replacing POMDPs.states, POMDPs.actions and POMDPs.state_index in FiniteHorizonPOMDPs Solver
function FiniteHorizonPOMDPs.stage_stateindex(mdp::FHExample, s::FHExampleState, epoch::Int64)::Int64
    return s.position + (epoch - 1) * mdp.no_states
end

function FiniteHorizonPOMDPs.stage_stateindex(mdp::FHExample, s::FHExampleState)::Int64
    return s.position
end

function POMDPs.actions(mdp::FHExample, s::FHExampleState)
    mdp.actions
end

function POMDPs.actions(mdp::FHExample)
    mdp.actions
end

# Creates (mdp.horizon - 1) * mdp.no_states states to be evaluated and mdp.no_states sink states
function POMDPs.states(mdp::FHExample)::Array{FHExampleState}
    mdp_states = FHExampleState[]
    for e=1:mdp.horizon + 1
        for i=1:mdp.no_states
            push!(mdp_states, FHExampleState(i, e, isreward(mdp, i) || e == mdp.horizon + 1))
        end
    end
   
    return mdp_states
end

POMDPs.stateindex(mdp::FHExample, s::FHExampleState)::Int64 = s.position + (s.epoch - 1) * mdp.no_states

POMDPs.actions(mdp::FHExample)::Vector{Symbol} = mdp.actions

POMDPs.actionindex(mdp::FHExample, a::Symbol)::Int64 = findall(x->x==a, POMDPs.actions(mdp))[1]

POMDPs.discount(mdp::FHExample)::Number = mdp.discount_factor

# returns transition distributions - works only for 1D Gridworld with possible moves to left and to right
function POMDPs.transition(mdp::FHExample, s::FHExampleState, a::Symbol)::SparseCat{Vector{FHExampleState},Vector{Float64}}    
    sp = FHExampleState[]
    prob = Float64[]

    # add original transition target and probability
    position = s.position + mdp.actionsImpact[a]
    push!(sp, FHExampleState(position, s.epoch + 1, isreward(mdp, position)))
    push!(prob, 1. - mdp.noise)

    # add noise transition target and probability
    noise_action = a == :l ? :r : :l
    position = s.position + mdp.actionsImpact[noise_action]
    push!(sp, FHExampleState(position, s.epoch + 1, isreward(mdp, position)))
    push!(prob, mdp.noise)

    return SparseCat(sp, prob)
end
