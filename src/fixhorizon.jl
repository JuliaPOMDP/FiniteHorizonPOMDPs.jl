"""
    fixhorizon(m::Union{MDP,POMDP}, horizon::Int)

Wrap infinite horizon (PO)MDP `m` and `horizon` to the new structure creating Finite Horizon (PO)MDP.
"""
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

###############################
# FiniteHorizonPOMDPs interface
###############################
HorizonLength(::Type{<:FHWrapper}) = FiniteHorizon()
horizon(w::FHWrapper) = w.horizon

###################################
# changed elements of POMDPs interface
###################################
"""
   POMDPs.states(w::HFWrapper)

Create a product of Infinite Horizon MDP's states with all stages (`1:horizon(w) + 1`).
"""
POMDPs.states(w::FHWrapper) = Iterators.product(states(w.m), 1:horizon(w)+1)

"""
    POMDPS.stateindex(w::FHWrapper, ss::Tuple{<:Any, Int})

Compute the index of the given state in Finite Horizon state space (meaning in state space of all stages).
"""
function POMDPs.stateindex(w::FHWrapper, ss::Tuple{<:Any, Int})
    s, k = ss
    return (k-1)*length(stage_states(w, 1)) + stateindex(w.m, s)
end

"""
    POMDPs.isterminal(w::FHWrapper, ss::Tuple{<:Any,Int})

Mark the state as terminal if its stage number if greater than horizon, else let the Infinite Horizon MDP's `isterminal` method decide.
"""
POMDPs.isterminal(w::FHWrapper, ss::Tuple{<:Any,Int}) = stage(w, ss) > horizon(w) || isterminal(w.m, first(ss))

"""
    POMDPs.gen(w::FHWrapper, ss::Tuple{<:Any,Int}, a, rng::AbstractRNG)

Implement the entire MDP/POMDP generative model by returning a NamedTuple.
"""
function POMDPs.gen(w::FHWrapper, ss::Tuple{<:Any,Int}, a, rng::AbstractRNG)
    out = gen(w.m, first(ss), a, rng)
    if haskey(out, :sp)
        return merge(out, (sp=(out.sp, stage(w, ss)+1),))
    else
        return out
    end
end

"""
    POMDPs.transition(w::FHWrapper, ss::Tuple{<:Any,Int}, a)

Wrap the transition result of Infinite Horizon MDP with stage number.
"""
POMDPs.transition(w::FHWrapper, ss::Tuple{<:Any,Int}, a) = InStageDistribution(transition(w.m, first(ss), a), stage(w, ss)+1)
# TODO: convert_s

"""
    POMDPs.actions(w::FHWrapper, ss::Tuple{<:Any,Int})

Return the actions of Infinite Horizon (PO)MDP.
This method assumes similar actions for all stages.
"""
POMDPs.actions(w::FHWrapper, ss::Tuple{<:Any,Int}) = actions(w.m, first(ss))

"""
    POMDPs.initialstate(w::FHWrapper)

Wrap Infinite Horizon MDP's `initialstate(mdp)` with stage 1.
"""
POMDPs.initialstate(w::FHWrapper) = InStageDistribution(initialstate(w.m), 1)

"""
    POMDPs.observations(w::FixedHorizonPOMDPWrapper)

Create a product of Infinite Horizon MDP's observations with all not-terminal stages (`1:horizon(w)`).
"""
POMDPs.observations(w::FixedHorizonPOMDPWrapper) = Iterators.product(observations(w.m), 1:horizon(w)+1)

"""
    POMDPs.obsindex(w::FixedHorizonPOMDPWrapper, o::Tuple{<:Any, Int})::Int

Compute the index of the given observation in the Finite Horizon observation space (meaning in observation space of all stages).
"""
function POMDPs.obsindex(w::FixedHorizonPOMDPWrapper, o::Tuple{<:Any, Int})::Int
    s, k = o
    return (k-1)*length(stage_observations(w, 1)) + obsindex(w.m, s)
end

"""
    POMDPs.observation(w::FixedHorizonPOMDPWrapper[, ss::Tuple{<:Any,Int}], a, ssp::Tuple{<:Any, Int})

Create a product of Infinite Horizon MDP's observations given destination state and action (and original state) with original state's stage.
"""
function POMDPs.observation(w::FixedHorizonPOMDPWrapper{S}, ss::Tuple{S,Int}, a, ssp::Tuple{S, Int}) where S
    InStageDistribution(observation(w.m, first(ss), a, first(ssp)), stage(w, ssp))
end

function POMDPs.observation(w::FixedHorizonPOMDPWrapper{S}, a, ssp::Tuple{S, Int}) where S
    InStageDistribution(observation(w.m, a, first(ssp)), stage(w, ssp))
end

"""
    POMDPs.initialstate(w::FHWrapper)

Return Infinite Horizon MDP's initial observations.
"""
POMDPs.initialobs(w::FixedHorizonPOMDPWrapper, ss::Tuple{<:Any,Int}) = initialobs(w.m, first(ss))
# TODO: convert_o

###############################
# FiniteHorizonPOMDPs interface
###############################
stage(w::FHWrapper, ss::Tuple{<:Any,Int}) = last(ss)
stage_states(w::FHWrapper, stage::Int) = Iterators.product(states(w.m), stage)
stage_stateindex(w::FHWrapper, ss::Tuple{<:Any,Int}) = stateindex(w.m, first(ss))
stage_observations(w::FixedHorizonPOMDPWrapper, stage::Int) = Iterators.product(observations(w.m), stage)
stage_obsindex(w::FixedHorizonPOMDPWrapper, o::Tuple{<:Any,Int}) = obsindex(w.m, first(o))
function ordered_stage_states(w::FHWrapper, stage::Int)
    return POMDPTools.ModelTools.ordered_vector(
        statetype(typeof(w)),
        s -> stage_stateindex(w,s),
        stage_states(w, stage),
        "stage_state"
    )
end
function ordered_stage_observations(w::FHWrapper, stage::Int)
    return POMDPTools.ModelTools.ordered_vector(
        obstype(typeof(w)),
        o -> stage_obsindex(w,o),
        stage_observations(w, stage),
        "stage_observation"
    )
end

###############################
# Forwarded parts of POMDPs interface
###############################
POMDPs.reward(w::FHWrapper, ss::Tuple{<:Any,Int}, a, ssp::Tuple{<:Any,Int}) = reward(w.m, first(ss), a, first(ssp))
POMDPs.reward(w::FixedHorizonPOMDPWrapper, ss, a, ssp, so) = reward(w.m, first(ss), a, first(ssp), first(so))
POMDPs.reward(w::FHWrapper, ss::Tuple{<:Any,Int}, a) = reward(w.m, first(ss), a)
POMDPs.actions(w::FHWrapper) = actions(w.m)
POMDPs.actionindex(w::FHWrapper, a) = actionindex(w.m, a)
POMDPs.discount(w::FHWrapper) = discount(w.m)
# TODO: convert_a

#################################
# distribution with a fixed stage
#################################
"""
    InStageDistribution{D}

Wrap given distribution with a given stage
"""
struct InStageDistribution{D}
    d::D
    stage::Int
end

"""
    distribution(d::InStageDistribution{D})::D

Return distrubution wrapped in InStageDistribution without stage
"""
function distribution(d::InStageDistribution)
    return d.d
end

"""
    stage(d::InStageDistribution)

Return stage of InStageDistribution
"""
stage(d::InStageDistribution) = d.stage

Base.rand(rng::AbstractRNG, s::Random.SamplerTrivial{<:InStageDistribution}) = (rand(rng, s[].d), s[].stage)

function POMDPs.pdf(d::InStageDistribution, ss::Tuple{<:Any, Int})
    s, k = ss
    if k == stage(d)
        return pdf(distribution(d), s)
    else
        return 0.0
    end
end

POMDPs.mean(d::InStageDistribution) = (mean(distribution(d)), stage(d))
POMDPs.mode(d::InStageDistribution) = (mode(distribution(d)), stage(d))
POMDPs.support(d::InStageDistribution) = Iterators.product(support(distribution(d)), stage(d))
POMDPs.rand(r::AbstractRNG, d::FiniteHorizonPOMDPs.InStageDistribution) = (rand(r, distribution(d)), stage(d))

#################################
# POMDPModelTools ordered actions
#################################
POMDPTools.ordered_actions(w::FHWrapper) = ordered_actions(w.m)
