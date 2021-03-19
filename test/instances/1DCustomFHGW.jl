using POMDPs
using FiniteHorizonPOMDPs


#####################
# MDP and State types
#####################
struct CustomFHExampleState 
    position::Int64
    epoch::Int64
end

# initial state constructor
CustomFHExampleState(position::Int64)::CustomFHExampleState = CustomFHExampleState(position, 0)

struct CustomFHExample <: MDP{CustomFHExampleState, Symbol} # Note that our MDP is parametarized by the state and the action
    no_states::Int64 # number od statesL
    horizon::Int64
    actions::Vector{Symbol}
    actionCost::Float64
    actionsImpact::Base.ImmutableDict{Symbol, Int64}
    reward_states::Vector{Int64}
    reward::Float64
    discount_factor::Float64 # discount factor
    noise::Float64
end

FiniteHorizonPOMDPs.HorizonLength(::Type{<:CustomFHExample}) = FiniteHorizon()
FiniteHorizonPOMDPs.horizon(mdp::CustomFHExample) = mdp.horizon

###################################
# changed elements of POMDPs interface
###################################

# Creates (horizon(mdp) - 1) * mdp.no_states states to be evaluated and mdp.no_states sink states
function POMDPs.states(mdp::CustomFHExample)::Array{CustomFHExampleState}
    mdp_states = CustomFHExampleState[]
    for e=1:horizon(mdp) + 1
        for i=1:mdp.no_states
            push!(mdp_states, CustomFHExampleState(i, e))
        end
    end

    return mdp_states
end

POMDPs.stateindex(mdp::CustomFHExample, ss::CustomFHExampleState)::Int64 = (ss.epoch - 1) * mdp.no_states + ss.position 

POMDPs.isterminal(mdp::CustomFHExample, ss::CustomFHExampleState) = FiniteHorizonPOMDPs.stage(mdp, ss) > horizon(mdp) || POMDPs.isterminal(mdp, ss.position)
POMDPs.isterminal(mdp::CustomFHExample, position::Int64)::Bool = position in mdp.reward_states

# returns transition distributions - works only for 1D Gridworld with possible moves to left and to right
function POMDPs.transition(mdp::CustomFHExample, ss::CustomFHExampleState, a::Symbol)::SparseCat{Vector{CustomFHExampleState},Vector{Float64}}    
    sp = CustomFHExampleState[]
    prob = Float64[]

    # add original transition target and probability
    position = ss.position + mdp.actionsImpact[a]
    push!(sp, CustomFHExampleState(position, ss.epoch + 1))
    push!(prob, 1. - mdp.noise)

    # add noise transition target and probability
    noise_action = a == :l ? :r : :l
    position = ss.position + mdp.actionsImpact[noise_action]
    push!(sp, CustomFHExampleState(position, ss.epoch + 1))
    push!(prob, mdp.noise)

    return SparseCat(sp, prob)
end


POMDPs.actions(mdp::CustomFHExample)::Vector{Symbol} = mdp.actions
POMDPs.actions(mdp::CustomFHExample, ss::CustomFHExampleState) = mdp.actions
POMDPs.actionindex(mdp::CustomFHExample, a::Symbol)::Int64 = findfirst(x->x==a, POMDPs.actions(mdp))

###############################
# FiniteHorizonPOMDPs interface
###############################
FiniteHorizonPOMDPs.stage(mdp::CustomFHExample, ss::CustomFHExampleState) = ss.epoch

function FiniteHorizonPOMDPs.stage_states(mdp::CustomFHExample, stage::Int)
    mdp_states = CustomFHExampleState[]
    for i=1:mdp.no_states
        push!(mdp_states, CustomFHExampleState(i, stage))
    end

    return mdp_states
end

FiniteHorizonPOMDPs.stage_stateindex(mdp::CustomFHExample, ss::CustomFHExampleState) = ss.position

###############################
# Forwarded parts of POMDPs interface
###############################
function isreward(mdp::CustomFHExample, position::Int64)::Bool
    return position in mdp.reward_states
end

function POMDPs.reward(mdp::CustomFHExample, ss::CustomFHExampleState, a::Symbol, sp::CustomFHExampleState)::Float64
    isreward(mdp, sp.position) ? mdp.reward : mdp.actionCost
end

POMDPs.discount(mdp::CustomFHExample)::Number = mdp.discount_factor
