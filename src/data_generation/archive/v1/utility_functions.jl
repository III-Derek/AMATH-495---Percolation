# none of these functions are used in the final script

function run_parallel(func, args, iterations)
    x = Vector{Any}(undef, iterations)
    @sync begin
        for i = 1:iterations
            Threads.@spawn begin
                x[i] = func(args...)
            end
        end
    end
    return x
end

function compute_average(data; columns)
    mat = mapreduce(permutedims, vcat, data)
    aggregate_values = [mean(mat[:, col]) for col in columns]
    return_row = data[1]
    return_row[columns] = aggregate_values
    return [return_row]
end