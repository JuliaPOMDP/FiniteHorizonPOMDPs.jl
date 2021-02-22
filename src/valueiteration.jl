"""
    valueiterationsolver(w::FHWrapper, stage::Int64, util)
    
Perform one iteration of Value Iteration
"""
function valueiterationsolver(m::MDP, stage::Int64, util)
    next_stage_value = util               # maximum value in each row
    stage_q = fill(0., (length(actions(m)), length(stage_states(m, stage))))
    
    for s in stage_states(m, stage)
        isterminal(m, s) && continue

        for a in actions(m)
            si = stage_stateindex(m, s)
            ai = actionindex(m, a)
            for (sp, p) in weighted_iterator(transition(m, s, a))
                spi = stage_stateindex(m, sp)
                stage_q[ai, si] += p * (reward(m, s, a, sp) + discount(m) * next_stage_value[spi])
            end
        end
    end

    util = maximum(stage_q; dims=1)
    pol = [i[1] for i in findmax(stage_q; dims=1)[2]][:]

    return stage_q, util, pol
end