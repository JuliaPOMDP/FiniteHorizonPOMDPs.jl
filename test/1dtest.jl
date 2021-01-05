# using POMDPs:transition
# using FiniteHorizonPOMDP
# include("instances/1DGridWorld.jl")
println("greet!")

# First set parameters of Example Mdp
# no_states = 5
# horizon = 3     # finite horizon mdp
# actions = [:l, :r]
# actionCost = -1.
# actionsImpact = Base.ImmutableDict(:l => -1, :r => 1)
# reward_states = [1, 5]
# reward = 10.
# discount_factor = 1.
# noise = 1.

# define POMDPS.transition method


# initialize the problem 
mdp = Example(no_states, horizon, actions, actionCost, actionsImpact, reward_states, reward, discount_factor, noise)

# initialize the solver
# max_iterations: maximum number of iterations value iteration runs for (default is 100)
# belres: the value of Bellman residual used in the solver (defualt is 1e-3)
# solver = ValueIterationSolver(max_iterations=3, belres=1e-3, verbose=true)

# @POMDPLinter.show_requirements DiscreteValueIteration.solve(solver, mdp)

# solve for an optimal policy
# if verbose=false, the text output will be supressed (false by default)
# policy = solve(solver, mdp);


function stage_states(mdp::Example, stage::Int64)    
    s = ExampleState[]    

    for i=0:1
        for j=1:mdp.no_states
            push!(s, ExampleState(j, stage + i, i == 1 || isreward(mdp, j) ? true : false))
        end
    end

    s
end

FiniteHorizonPOMDP.mysolve(ValueIterationSolver, mdp, verbose=true)