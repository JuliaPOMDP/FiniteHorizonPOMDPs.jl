using POMDPs
using FiniteHorizonPOMDPs


struct FHExampleState 
    position::Int64
    done::Bool # are we in a terminal state?
end

# initial state constructor
FHExampleState(position::Int64)::FHExampleState = FHExampleState(position, false)

struct FHExample <: MDP{FHExampleState, Symbol} # Note that our MDP is parametarized by the state and the action
    no_states::Int64 # number od states
    actions::Vector{Symbol}
    actionCost::Float64
    actionsImpact::Base.ImmutableDict{Symbol, Int64}
    reward_states::Vector{Int64}
    reward::Float64
    discount_factor::Float64 # discount factor
    noise::Float64
end

POMDPs.isterminal(mdp::FHExample, s::FHExampleState)::Bool = s.position in mdp.reward_states
POMDPs.isterminal(mdp::FHExample, position::Int64)::Bool = position in mdp.reward_states

function POMDPs.reward(mdp::FHExample, s::FHExampleState, a::Symbol, sp::FHExampleState)::Float64
    isterminal(mdp, sp.position) ? mdp.reward : mdp.actionCost
end

function POMDPs.actions(mdp::FHExample, s::FHExampleState)
    mdp.actions
end

function POMDPs.actions(mdp::FHExample)
    mdp.actions
end

# Creates mdp.no_states states
function POMDPs.states(mdp::FHExample)::Array{FHExampleState}
    mdp_states = FHExampleState[]
    for i=1:mdp.no_states
        push!(mdp_states, FHExampleState(i, isterminal(mdp, i)))
    end
   
    return mdp_states
end

POMDPs.stateindex(mdp::FHExample, s::FHExampleState)::Int64 = s.position
POMDPs.actions(mdp::FHExample)::Vector{Symbol} = mdp.actions
POMDPs.actionindex(mdp::FHExample, a::Symbol)::Int64 = findfirst(x->x==a, POMDPs.actions(mdp))
POMDPs.discount(mdp::FHExample)::Number = mdp.discount_factor

# returns transition distributions - works only for 1D Gridworld with possible moves to left and to right
function POMDPs.transition(mdp::FHExample, s::FHExampleState, a::Symbol)::SparseCat{Vector{FHExampleState},Vector{Float64}}    
    sp = FHExampleState[]
    prob = Float64[]

    # add original transition target and probability
    position = s.position + mdp.actionsImpact[a]
    push!(sp, FHExampleState(position, isterminal(mdp, position)))
    push!(prob, 1. - mdp.noise)

    # add noise transition target and probability
    noise_action = a == :l ? :r : :l
    position = s.position + mdp.actionsImpact[noise_action]
    push!(sp, FHExampleState(position, isterminal(mdp, position)))
    push!(prob, mdp.noise)

    return SparseCat(sp, prob)
end
