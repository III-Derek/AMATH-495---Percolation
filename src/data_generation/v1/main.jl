include("Percolation.jl")
using .Percolation
using DataFrames
using CSV

function run_computations(input)
    blocked, filled, max_distance2, max_projected_distance = run_percolation(input)
    metrics = compute_metrics(blocked, filled, input["initial conditions"], input["directions"])
    return [input["porosity"], input["widths"], collect(input["initial conditions"]), input["directions"], max_distance2, max_projected_distance, metrics...]
end

function main(input)
    all_data = []
    for p = 0:0.01:1
        t = @elapsed begin
            input["porosity"] = p
            data = run_parallel(run_computations, (input,), input["iterations"])
            if input["aggregate"] == "mean"
                data = compute_average(data; columns=(5:5+5))
            end
            append!(all_data, data)
        end
        if input["display"]
            println("Completed p=",p," - time elapsed: ",t)
        end

    end
    header = ["porosity", "widths", "initial conditions", "directions", "max distance", "projected distances","filled bottom","number filled", "number blocked","total filled"]
    df = DataFrame([getindex.(all_data, i) for i in 1:length(all_data[1])], header, copycols=false)
    if input["display"]
        println(df)
    end
    if filesize(input["filename"]) == 0
        CSV.write(input["filename"], df,header=header, append=false)
    else
        CSV.write(input["filename"], df, append=true)
    end
end

input = Dict()
input["widths"] = (100,100)
input["initial conditions"] = Set([[1,1]])
input["directions"] = [[0,1],[1,0],[1,1]]
input["iterations"] = 1000
input["aggregate"] = "mean" # or none

input["filename"] = "data4.csv"
input["display"] = true

main(input)
