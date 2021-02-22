using POMDPs
using FiniteHorizonPOMDPs


#####################
# MDP and State types
#####################
struct PyramidState 
    position::Int64
    epoch::Int64
end

# initial state constructor
PyramidState(position::Int64)::PyramidState = PyramidState(position, 0)

struct PyramidMDP <: MDP{PyramidState, Symbol} # Note that our MDP is parametarized by the state and the action
    horizon::Int64
    actions::Vector{Symbol}
    actionCost::Float64
    actionsImpact::Base.ImmutableDict{Symbol, Int64}
    reward_states::Vector{Vector{Int64}}
    reward::Float64
    discount_factor::Float64 # discount factor
    noise::Float64
end

FiniteHorizonPOMDPs.HorizonLength(::Type{<:PyramidMDP}) = FiniteHorizon()
FiniteHorizonPOMDPs.horizon(mdp::PyramidMDP) = mdp.horizon

###################################
# changed elements of POMDPs interface
###################################

# Creates (horizon(mdp) - 1) * mdp.no_states states to be evaluated and mdp.no_states sink states
function POMDPs.states(mdp::PyramidMDP)::Array{PyramidState}
    mdp_states = PyramidState[]
    for e=1:horizon(mdp) + 1
        for i=1:e
            push!(mdp_states, PyramidState(i, e))
        end
    end

    return mdp_states
end

POMDPs.stateindex(mdp::PyramidMDP, ss::PyramidState)::Int64 = sum(1:ss.epoch - 1) + ss.position
POMDPs.isterminal(mdp::PyramidMDP, ss::PyramidState) = FiniteHorizonPOMDPs.stage(mdp, ss) > horizon(mdp) || [ss.epoch, ss.position] in mdp.reward_states

# returns transition distributions - works only for 1D Gridworld with possible moves to left and to right
function POMDPs.transition(mdp::PyramidMDP, ss::PyramidState, a::Symbol)::SparseCat{Vector{PyramidState},Vector{Float64}}    
    sp = PyramidState[]
    prob = Float64[]

    # add original transition target and probability
    position = ss.position + mdp.actionsImpact[a]
    push!(sp, PyramidState(position, ss.epoch + 1))
    push!(prob, 1. - mdp.noise)

    # add noise transition target and probability
    noise_action = a == :l ? :r : :l
    position = ss.position + mdp.actionsImpact[noise_action]
    push!(sp, PyramidState(position, ss.epoch + 1))
    push!(prob, mdp.noise)

    return SparseCat(sp, prob)
end


POMDPs.actions(mdp::PyramidMDP)::Vector{Symbol} = mdp.actions
POMDPs.actions(mdp::PyramidMDP, ss::PyramidState) = mdp.actions
POMDPs.actionindex(mdp::PyramidMDP, a::Symbol)::Int64 = findall(x->x==a, POMDPs.actions(mdp))[1]

###############################
# FiniteHorizonPOMDPs interface
###############################
FiniteHorizonPOMDPs.stage(mdp::PyramidMDP, ss::PyramidState) = ss.epoch

function FiniteHorizonPOMDPs.stage_states(mdp::PyramidMDP, stage::Int)
    mdp_states = PyramidState[]
    for i=1:stage
        push!(mdp_states, PyramidState(i, stage))
    end

    return mdp_states
end

FiniteHorizonPOMDPs.stage_stateindex(mdp::PyramidMDP, ss::PyramidState) = ss.position

###############################
# Forwarded parts of POMDPs interface
###############################
function isreward(mdp::PyramidMDP, ss::PyramidState)::Bool
    return [ss.epoch, ss.position] in mdp.reward_states
end

function POMDPs.reward(mdp::PyramidMDP, ss::PyramidState, a::Symbol, sp::PyramidState)::Float64
    isreward(mdp, sp) ? mdp.reward : mdp.actionCost
end

POMDPs.discount(mdp::PyramidMDP)::Number = mdp.discount_factor
