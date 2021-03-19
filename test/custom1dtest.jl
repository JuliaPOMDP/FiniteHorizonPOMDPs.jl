
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

fhsolver = FiniteHorizonSolver()

# MDPs initialization
mdp = CustomFHExample(no_states, _horizon, actions, actionCost, actionsImpact, reward_states, reward, discount_factor, noise)

# check implementation of required methods
# @POMDPLinter.show_requirements FiniteHorizonPOMDPs.solve(fhsolver, mdp)

# initialize the solver
# max_iterations: maximum number of iterations value iteration runs for (default is 100)
# belres: the value of Bellman residual used in the solver
solver = ValueIterationSolver(max_iterations=10, belres=1e-3, include_Q=true);

# Solve Value Iteration
VIPolicy = DiscreteValueIteration.solve(solver, mdp);

# Solve Finite Horizon by Value Iteration
FHPolicy = FiniteHorizonPOMDPs.solve(fhsolver, mdp);

@test typeof(HorizonLength(mdp)) != InfiniteHorizon

# Compare resulting policies
@test all((FiniteHorizonPOMDPs.action(FHPolicy, s) == action(VIPolicy, s) for s in states(mdp)))

# Compare FHMDP and IHMDP states
fh_states = Iterators.flatten([FiniteHorizonPOMDPs.stage_states(mdp, i) for i=1:FiniteHorizonPOMDPs.horizon(mdp) + 1])
ih_states = states(mdp)

z = zip(fh_states, ih_states)

@test all((fh == ih for (fh, ih) in z))
