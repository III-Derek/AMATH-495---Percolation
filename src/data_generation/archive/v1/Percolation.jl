module Percolation
using Distributions
using Statistics

export run_percolation, run_parallel, compute_metrics, compute_average, compute_percolation_probability

include("percolation_functions.jl")
include("metrics.jl")
include("utility_functions.jl")

end