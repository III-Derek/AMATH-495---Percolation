include("Percolation.jl")
using .Percolation
using DataFrames
using CSV
using Images

function main(input)
    for p = 0.01:0.001:0.99
        input["porosity"] = p
        blocked, percolation_probability = compute_percolation_probability(input)
        path = "C:\\Users\\jonat\\OneDrive\\Documents\\programming\\AnacondaProjects\\PHYS495\\final\\data\\perco_prob\\"
        data = permutedims(repeat(blocked*1.0, inner=[1,1,3]),[3,1,2])
        image = colorview(RGB, data)
        save(string(path,round(1-p;digits=3),"_", percolation_probability,".png"), image)
    end
end

input = Dict()
input["widths"] = (250,250)
input["initial conditions"] = Set([[1,1]])
input["directions"] = [[0,1],[1,0],[0,-1],[-1,0]]
input["aggregate"] = "mean" # or none

input["filename"] = "data4.csv"
input["display"] = true

main(input)
