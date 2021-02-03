"""
    valueiterationsolver(w::FHWrapper, stage::Int64, util)
    
Perform one iteration of Value Iteration
"""
function valueiterationsolver(w::FHWrapper, stage::Int64, util)
    next_stage_value = util               # maximum value in each row
    stage_q = fill(0., (length(stage_states(w, 1)), length(actions(w))))
    
    for s in stage_states(w, stage)
        isterminal(w, s) && continue

        for a in actions(w)
            si = stage_stateindex(w, s, stage)
            ai = actionindex(w, a)
            for (sp, p) in weighted_iterator(transition(w, s, a))
                spi = stage_stateindex(w, sp, stage + 1)
                stage_q[si, ai] += p * (reward(w, s, a, sp) + discount(w) * next_stage_value[spi])
            end
        end
    end

    util = maximum(stage_q; dims=2)
    pol = [i[2] for i in findmax(stage_q; dims=2)[2]][:]

    return stage_q, util, pol
end
