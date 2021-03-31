using Test
using POMDPTesting
using FiniteHorizonPOMDPs
using POMDPs
using POMDPModelTools
import POMDPModels: SimpleGridWorld, BabyPOMDP
import POMDPPolicies: FunctionPolicy
import POMDPSimulators: stepthrough

@testset "interface" begin
    @test HorizonLength(SimpleGridWorld()) == InfiniteHorizon()
    @test HorizonLength(BabyPOMDP()) == InfiniteHorizon()
end

@testset "fixhorizon" begin
    include("fixhorizon.jl")
end
