using Revise
using FiniteHorizonPOMDP
using Test
using POMDPLinter
using POMDPModelTools

using DiscreteValueIteration

# include("instances/1DGridWorld.jl")
include("instances/1DFiniteHorizonGridWorld.jl")

@testset "1DGridWorld" begin
    include("1dtest.jl")
end
