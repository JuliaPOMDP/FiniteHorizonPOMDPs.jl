using Test
using FiniteHorizonPOMDPs
using POMDPs
using POMDPTools
import POMDPModels: SimpleGridWorld, BabyPOMDP

@testset "interface" begin
    @test HorizonLength(SimpleGridWorld()) == InfiniteHorizon()
    @test HorizonLength(BabyPOMDP()) == InfiniteHorizon()
end

@testset "fixhorizon" begin
    include("fixhorizon.jl")
end
