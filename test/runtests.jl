using Test
using FiniteHorizonPOMDPs
using POMDPs
using POMDPTools
using POMDPModels

@testset "interface" begin
    @test HorizonLength(SimpleGridWorld()) == InfiniteHorizon()
    @test HorizonLength(BabyPOMDP()) == InfiniteHorizon()
end

@testset "fixhorizon" verbose=true begin
    include("fixhorizon.jl")
end
