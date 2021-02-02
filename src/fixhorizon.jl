# TODO: Docstring
fixhorizon(m::MDP, horizon::Int) = FixedHorizonMDPWrapper(m, horizon)
fixhorizon(m::POMDP, horizon::Int) = FixedHorizonPOMDPWrapper(m, horizon)

##################
# Wrapper types
#################
struct FixedHorizonMDPWrapper{S,A,M<:MDP} <: MDP{Tuple{S, Int}, A}
    m::M
    horizon::Int
end

FixedHorizonMDPWrapper(m::MDP, d::Int) = FixedHorizonMDPWrapper{statetype(m), actiontype(m), typeof(m)}(m, d)

# TODO: Make it optional to include the stage in the observation
struct FixedHorizonPOMDPWrapper{S,A,O,M<:POMDP} <: POMDP{Tuple{S, Int}, A, Tuple{O,Int}}
    m::M
    horizon::Int
end

FixedHorizonPOMDPWrapper(m::POMDP, d::Int) = FixedHorizonPOMDPWrapper{statetype(m), actiontype(m), obstype(m), typeof(m)}(m, d)

const FHWrapper = Union{FixedHorizonMDPWrapper,FixedHorizonPOMDPWrapper}

###################################
# changed elements of POMDPs interface
###################################
POMDPs.states(w::FHWrapper) = Iterators.product(states(w.m), 1:w.horizon+1)
function POMDPs.stateindex(w::FHWrapper, ss::Tuple{<:Any, Int})
    s, k = ss
    return (k-1)*(w.horizon) + stateindex(w.m, s)
end

POMDPs.isterminal(w::FHWrapper, ss::Tuple{<:Any,Int}) = last(ss) > w.horizon || isterminal(w.m, first(ss))

function POMDPs.gen(w::FHWrapper, ss::Tuple{<:Any,Int}, a, rng::AbstractRNG)
    out = gen(w.m, first(ss), a, rng)
    if haskey(out, :sp)
        return merge(out, (sp=(out.sp, last(ss)+1),))
    else
        return out
    end
end

POMDPs.transition(w::FHWrapper, ss::Tuple{<:Any,Int}, a) = InStageDistribution(transition(w.m, first(ss), a), last(ss)+1)
# TODO: convert_s

POMDPs.actions(w::FHWrapper, ss::Tuple{<:Any,Int}) = actions(w.m, first(ss))

POMDPs.initialstate(w::FHWrapper) = InStageDistribution(initialstate(w.m), 1)

POMDPs.observations(w::FixedHorizonPOMDPWrapper) = Iterators.product(observations(w.m), 1:w.horizon)
POMDPs.obsindex
POMDPs.observation(w::FixedHorizonPOMDPWrapper, ss::Tuple{<:Any,Int}, a, ssp::Tuple{<:Any, Int}) = InStageDistribution(observation(w.m, first(ss), a, first(ssp)), last(ss))
POMDPs.observation(w::FixedHorizonPOMDPWrapper, a, ssp::Tuple{<:Any, Int}) = InStageDistribution(observation(w.m, a, first(ssp)), last(ssp)-1)
POMDPs.initialobs(w::FixedHorizonPOMDPWrapper, ss::Tuple{<:Any,Int}) = initialobs(w.m, first(ss))
# TODO: convert_o

###############################
# FiniteHorizonPOMDPs interface
###############################
stage_states(w::FHWrapper, stage::Int) = Iterators.product(states(w.m), stage)
stage_stateindex(w::FHWrapper, ss::Tuple{<:Any,Int}, stage::Int) = stateindex(w.m, first(ss))
HorizonLength(::Type{<:FHWrapper}) = FiniteHorizon()
horizon(w::FHWrapper) = w.horizon

###############################
# Forwarded parts of POMDPs interface
###############################
POMDPs.reward(w::FHWrapper, ss, a, ssp) = reward(w.m, first(ss), a, first(ssp))
POMDPs.reward(w::FixedHorizonPOMDPWrapper, ss, a, ssp, so) = reward(w.m, first(ss), a, first(ssp), first(so))
POMDPs.reward(w::FHWrapper, ss, a) = reward(w.m, first(ss), a)
POMDPs.actions(w::FHWrapper) = actions(w.m)
POMDPs.actionindex(w::FHWrapper, a) = actionindex(w.m, a)
POMDPs.discount(w::FHWrapper) = discount(w.m)
# TODO: convert_a

#################################
# distribution with a fixed stage
#################################
struct InStageDistribution{D}
    d::D
    stage::Int
end

Base.rand(rng::AbstractRNG, s::Random.SamplerTrivial{<:InStageDistribution}) = (rand(rng, s[].d), s[].stage)

function POMDPs.pdf(d::InStageDistribution, ss::Tuple{<:Any, Int})
    s, k = ss
    if k == d.stage
        return pdf(d.d, s)
    else
        return 0.0
    end
end

POMDPs.mean(d::InStageDistribution) = (mean(d.d), d.stage)
POMDPs.mode(d::InStageDistribution) = (mode(d.d), d.stage)
POMDPs.support(d::InStageDistribution) = Iterators.product(support(d.d), d.stage)
