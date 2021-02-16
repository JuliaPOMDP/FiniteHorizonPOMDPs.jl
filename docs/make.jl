push!(LOAD_PATH,"../src/")

using Documenter, FiniteHorizonPOMDPs

makedocs(
    
    modules = [FiniteHorizonPOMDPs],
    format = Documenter.HTML(),
    sitename = "FiniteHorizonPOMDPs.jl",   
    pages = [
        ##############################################
        ## MAKE SURE TO SYNC WITH docs/src/index.md ##
        ##############################################
        "Basics" => [
            "index.md",
            "interface.md"
           ]
    ]
)

deploydocs(
    repo = "github.com/Omastto1/FiniteHorizonPOMDPs.jl.git",
)
