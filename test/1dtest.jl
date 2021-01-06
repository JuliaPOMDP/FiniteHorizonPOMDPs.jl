
# MDP parameters, ValueIteration minimizes the cost => cost is positive, reward is negative
no_states = 10
horizon = 4
actions = [:l, :r]
actionCost = 1.
actionsImpact = Base.ImmutableDict(:l => -1, :r => 1)
reward_states = [1, 10]
reward = -10.
discount_factor = 1.
noise = .6

# MDPs initialization
mdp = Example(no_states, horizon, actions, actionCost, actionsImpact, reward_states, reward, discount_factor, noise)
fhmdp = FHExample(no_states, horizon, actions, actionCost, actionsImpact, reward_states, reward, discount_factor, noise)

# initialize the solver
# max_iterations: maximum number of iterations value iteration runs for (default is 100)
# belres: the value of Bellman residual used in the solver
solver = ValueIterationSolver(max_iterations=10, belres=1e-3, include_Q=true);

# Solve Value Iteration
# VIPolicy = solve(solver, mdp);
    
# Solve Finite Horizon by Value Iteration
# FHPolicy = FiniteHorizonPOMDP.mysolve(ValueIterationSolver, fhmdp);

# Compare resulting policies
#@test VIPolicy.policy == vec(FHPolicy.policy')
# println(vec(policy.policy'))

stages(mdp::MDP) = mdp.horizon

Base.length(f::Iterators.Flatten) = sum(length, f.it)
POMDPs.states(mdp::FHExample) = Iterators.flatten(FiniteHorizonPOMDP.stage_states(mdp, i)[1:mdp.no_states] for i=1:stages(mdp))

println(collect(states(fhmdp)))
println(states(mdp))

# Evaluates to false because of different elements Types (ExampleState vs FHExampleState)
@test collect(states(fhmdp)) == states(mdp)

# FHPolicy = FiniteHorizonPOMDP.mysolve(fhmdp);

# # println("A")
# # println(VIPolicy.qmat)
# # println("A")
# # println(FHPolicy.qmat)
# # println("A")
# # println(VIPolicy.util)
# # println("A")
# # println(FHPolicy.util)
# # println("A")
# # println(VIPolicy.policy)
# # println("A")
# # println(FHPolicy.policy)
# # println("A")

# # Compare resulting policies
# @test VIPolicy.policy == vec(FHPolicy.policy')
