# Benchmark of argmax implementations

using Revise
using FiniteHorizonPOMDP
using Test
using POMDPLinter
using POMDPModelTools

using DiscreteValueIteration

using FStrings

using BenchmarkTools

include("instances/1DFiniteHorizonGridWorld.jl")

# MDP parameters, ValueIteration minimizes the cost => cost is positive, reward is negative
no_states = 10
horizon = 4
actions = [:l, :r]
actionCost = 1.
actionsImpact = Base.ImmutableDict(:l => -1, :r => 1)
reward_states = [1, 10]
reward = -10.
discount_factor = 1.
noise = .6

# MDPs initialization
fhmdp = FHExample(no_states, horizon, actions, actionCost, actionsImpact, reward_states, reward, discount_factor, noise)

stage_q = fill(0, (fhmdp.no_states, length(POMDPs.actions(fhmdp))))
stage_q, util = FiniteHorizonPOMDP.valueiterationsolver(fhmdp, 1, stage_q)
println(stage_q)

println("mapslices benchmark")
@btime mapslices(argmax,stage_q,dims=2)[:]
println(f"result: {mapslices(argmax,stage_q,dims=2)[:]}")

println("findmax benchmark without extracting indices")
@btime findmax(stage_q; dims=2)
println(f"result: {findmax(stage_q; dims=2)}")

println("findmax benchmark with extracted indices")
@btime [i[2] for i in findmax(stage_q; dims=2)[2]][:]
println(f"result: {[i[2] for i in findmax(stage_q; dims=2)[2]][:]}")

nothing