# TODO: These tests should be expanded to cover everything

@testset "fixhorizon Grid World" begin
    gw = SimpleGridWorld()
    fhgw = fixhorizon(gw, 2)

    @test length(states(fhgw)) == 3*length(states(gw))
    @test collect(first(state) for state in stage_states(fhgw, 1)) == collect(states(gw))
    @test HorizonLength(fhgw) == FiniteHorizon()
    @test horizon(fhgw) == 2
    @test has_consistent_distributions(fhgw)
    is = (convert(statetype(gw), [1,1]), 1)::statetype(fhgw)
    @show actiontype(fhgw)
    @test length(collect(stepthrough(fhgw, FunctionPolicy(s->:left), is, "s,a,r,sp"))) == 2
end

@testset "fixhorizon Baby" begin
    m = BabyPOMDP()
    fhb = fixhorizon(m, 2)

    @test length(states(fhb)) == 3*length(states(m))
    @test collect(first(state) for state in stage_states(fhb, 1)) == collect(states(m))
    @test HorizonLength(fhb) == FiniteHorizon()
    @test horizon(fhb) == 2
    @test has_consistent_distributions(fhb)
    @test length(collect(stepthrough(fhb, FunctionPolicy(s->true)))) == 2
end

@testset "fixhorizon General" begin
    m = BabyPOMDP()
    fhb = fixhorizon(m, 3)
    state = (false, 2)
    action = true

    states = [(false, 2), (true, 2)]
    @test stateindex(fhb, ordered_states(fhb)[3]) == 3
    @test stage_stateindex(fhb, ordered_states(fhb)[3]) == 1
    @test ordered_states(fhb)[3] == state
    @test ordered_stage_states(fhb, 2) == [(false, 2), (true, 2)]

    obs = [(false, 2), (true, 2)]
    @test collect(first(obs) for obs in stage_observations(fhb, 1)) == collect(observations(m))
    @test obsindex(fhb, obs[2]) == 4
    @test stage_obsindex(fhb, obs[2]) == 2
    @test ordered_stage_observations(fhb, 2) == [(false, 2), (true, 2)]
end

@testset "solver" begin
    fhgw = fixhorizon(SimpleGridWorld(), 3)
    # TODO: Change test to pass without boolean value
    # Dependencies are destroying testing with this (probably until the repos are registered ?)
    # @test test_solver(FiniteHorizonSolver(), fhgw) == 9.025
end
