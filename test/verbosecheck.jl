include("instances/1DCustomFHGW.jl")

# MDP parameters, ValueIteration minimizes the cost => cost is positive, reward is negative
no_states = 10
_horizon = 5
actions = [:l, :r]
actionCost = 1.
actionsImpact = Base.ImmutableDict(:l => -1, :r => 1)
reward_states = [1, no_states]
reward = -10.
discount_factor = 1.
noise = .6

mdp = CustomFHExample(no_states, _horizon, actions, actionCost, actionsImpact, reward_states, reward, discount_factor, noise)

println("Verbose Check")
fhsolver = FiniteHorizonSolver(verbose=true)
FHPolicy = FiniteHorizonPOMDPs.solve(fhsolver, mdp);