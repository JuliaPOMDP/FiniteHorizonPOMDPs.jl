using FiniteHorizonPOMDPs
using Test
using POMDPLinter
using POMDPModelTools
using DiscreteValueIteration
using POMDPs
using POMDPModels: SimpleGridWorld, BabyPOMDP
using POMDPTesting
using POMDPPolicies: FunctionPolicy
using POMDPSimulators: stepthrough

@testset "interface" begin
    @test HorizonLength(SimpleGridWorld()) == InfiniteHorizon()
    @test HorizonLength(BabyPOMDP()) == InfiniteHorizon()
end

@testset "fixhorizon" begin
    include("fixhorizon.jl")
end

# include("instances/1DGridWorld.jl")
include("instances/1DFiniteHorizonGridWorld.jl")

@testset "1DGridWorld" begin
    include("1dtest.jl")
end
