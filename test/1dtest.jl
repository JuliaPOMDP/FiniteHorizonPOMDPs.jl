
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
solver = ValueIterationSolver(max_iterations=20, belres=1e-3);

# Solve Value Iteration
VIPolicy = solve(solver, mdp);
    
# Solve Finite Horizon by Value Iteration
FHPolicy = FiniteHorizonPOMDP.mysolve(ValueIterationSolver, fhmdp);

# Compare resulting policies
@test VIPolicy.policy == vec(FHPolicy.policy')
# println(vec(policy.policy'))