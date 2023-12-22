include("Percolation.jl")
using .Percolation
using DataFrames
using CSV
using Images

function main(input)
    # iterate over many p values. Don't include 0 and 1 since they can mess up calculations with divide by zero
    for p = 0.01:0.001:0.99
        # compute percolation for the p value
        input["porosity"] = p
        blocked, percolation_probability = compute_percolation_probability(input)

        # save image to a file with the corresponding percolation probability
        path = "C:\\Users\\jonat\\OneDrive\\Documents\\programming\\AnacondaProjects\\PHYS495\\final\\data\\perco_prob\\"
        image = colorview(Gray, blocked)
        save(string(path,round(1-p;digits=3),"_", percolation_probability,".png"), image)
    end
end

# input configuration. Here the direction goes in all directions as supposed to in two 
input = Dict()
input["widths"] = (250,250)
input["directions"] = [[0,1],[1,0],[0,-1],[-1,0]]

main(input)
