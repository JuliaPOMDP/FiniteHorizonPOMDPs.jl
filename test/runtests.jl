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

include("instances/1DInfiniteHorizonGridWorld.jl")

@testset "1DFixHorizonGridWorld" begin
    include("fixhorizon1dtest.jl")
end

include("instances/1DCustomFHGW.jl")

@testset "Custom Finite Horizon MDP" begin
    include("custom1dtest.jl")
end
