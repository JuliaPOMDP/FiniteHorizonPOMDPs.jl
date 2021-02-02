using FiniteHorizonPOMDPs
using Test
using POMDPLinter
using POMDPModelTools
using DiscreteValueIteration
using POMDPModels: SimpleGridWorld, BabyPOMDP

@testset "interface" begin
    @test HorizonLength(SimpleGridWorld()) == InfiniteHorizon()
    @test HorizonLength(BabyPOMDP()) == InfiniteHorizon()
end

# include("instances/1DGridWorld.jl")
include("instances/1DFiniteHorizonGridWorld.jl")

@testset "1DGridWorld" begin
    include("1dtest.jl")
end
