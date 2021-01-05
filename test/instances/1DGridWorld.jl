using POMDPs


struct ExampleState 
    position::Int64
    epoch::Int64
    done::Bool # are we in a terminal state?
end

# initial state constructor
ExampleState(name::Int64, epoch::Int64)::ExampleState = ExampleState(name, epoch, false)
ExampleState(name::Int64)::ExampleState = ExampleState(name, 0, false)
ExampleState(name::Int64, done::Bool)::ExampleState = ExampleState(name, 0, done)

struct Example <: MDP{ExampleState, Symbol} # Note that our MDP is parametarized by the state and the action
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

function POMDPs.isterminal(mdp::Example, state::ExampleState)::Bool
    return state.done
end

function isreward(mdp::Example, position::Int64)::Bool
    return position % mdp.no_states == 1 || position % mdp.no_states == 0
end

# Checks whether state is goal state and return cost/reward correspondingly
function POMDPs.reward(mdp::Example, s::ExampleState, a::Symbol, sp::ExampleState)::Float64
    isreward(mdp, sp.position) ? mdp.reward : mdp.actionCost
end

# Creates (mdp.horizon - 1) * mdp.no_states states to be evaluated and mdp.no_states sink states
function POMDPs.states(mdp::Example)::Array{ExampleState}
    mdp_states = ExampleState[]
    for i=1:mdp.no_states * (mdp.horizon - 1)
        push!(mdp_states, ExampleState(i, isreward(mdp, i)))
    end

    for i=mdp.no_states * (mdp.horizon - 1) + 1:mdp.no_states * mdp.horizon
        push!(mdp_states, ExampleState(i, true))
    end
   
    return mdp_states
end

POMDPs.stateindex(mdp::Example, s::ExampleState)::Int64 = s.position

POMDPs.actions(mdp::Example)::Vector{Symbol} = mdp.actions

POMDPs.actionindex(mdp::Example, a::Symbol)::Int64 = findall(x->x==a, POMDPs.actions(mdp))[1]

POMDPs.discount(mdp::Example)::Number = mdp.discount_factor

# returns transition distributions - works only for 1D Gridworld with possible moves to left and to right
function POMDPs.transition(mdp::Example, s::ExampleState, a::Symbol)::SparseCat{Vector{ExampleState},Vector{Float64}}    
    sp = ExampleState[]
    prob = Float64[]

    # add original transition target and probability
    position = s.position + mdp.no_states + mdp.actionsImpact[a]
    push!(sp, ExampleState(position, isreward(mdp, position)))
    push!(prob, 1. - mdp.noise)

    # add noise transition target and probability
    noise_action = a == :l ? :r : :l
    position = s.position + mdp.no_states + mdp.actionsImpact[noise_action]
    push!(sp, ExampleState(position, isreward(mdp, position)))
    push!(prob, mdp.noise)

    return SparseCat(sp, prob)
end
