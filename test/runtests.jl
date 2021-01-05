using FiniteHorizonPOMDP
using Test
using POMDPLinter
using POMDPModelTools

using DiscreteValueIteration

include("instances/1DGridWorld.jl")

@testset "FiniteHorizonPOMDP.jl" begin
    no_states = 5
    horizon = 3     # finite horizon mdp
    actions = [:l, :r]
    actionCost = -1.
    actionsImpact = Base.ImmutableDict(:l => -1, :r => 1)
    reward_states = [1, 5]
    reward = 10.
    discount_factor = 1.
    noise = 1.
    include("1dtest.jl")  
end
