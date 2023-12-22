function target_filled(point, blocked, filled)
    return blocked[point...] || filled[point...]
end

"""
Checks whether new point is in a grid
"""
function within_grid(point, grid)
    grid_size = size(grid)
    for dim in eachindex(point)
        within = (point[dim] >= 1) && (point[dim] <= grid_size[dim])
        if !within
            return false
        end
    end
    return true
end

"""
Gets list of new points around given point.
"""
function get_new_points(point, directions)
    new_points = Set()
    for direction in directions
        push!(new_points, [p+d for (p,d) in zip(point, direction)])
    end
    return new_points
end

"""
Given recent_points, propogates water into the given directions. 

Returns new points

"""
function propagate(recent_points::Set, blocked::BitMatrix, filled::BitMatrix, directions::Vector)
    new_points = Set()
    for point in recent_points
        union!(new_points, get_new_points(point, directions))
    end
    selected_new_points = Set()
    for point in new_points
        if within_grid(point, blocked) && !target_filled(point, blocked, filled)
            push!(selected_new_points, point)
        end
    end
    return selected_new_points
end

function fill_new_points!(new_points::Set, filled::BitMatrix)
    for points in new_points
        filled[points...] = 1
    end
end

# function run_percolation(inputs::Dict)
#     # metrix to track
#     max_distance2 = 0
#     max_projected_distance = zeros(length(inputs["directions"]))

#     blocked, filled = generate_geometry(inputs["widths"], inputs["porosity"])
#     points = inputs["initial conditions"]
#     fill_new_points!(points, filled)
#     while true
#         points = propagate(points, blocked, filled, inputs["directions"])
#         if isempty(points)
#             break
#         end
#         # compute metrics
#         for p in points
#             for init_p in inputs["initial conditions"]
#                 for (i, direction) in enumerate(inputs["directions"])
#                     dist = ((p - init_p)'direction)/sqrt(sum(direction.^2))
#                     if dist > max_projected_distance[i] 
#                         max_projected_distance[i] = dist
#                     end
#                 end
#                 dist = sum((p - init_p).^2)
#                 if dist > max_distance2
#                     max_distance2 = dist
#                 end
#             end
#         end
#         fill_new_points!(points, filled)
#     end
#     return blocked, filled, sqrt(max_distance2), max_projected_distance
# end
"""
Generates a random array of 0s and 1s and runs percolation on it to see what elements are filled, propogating from initial conditions
of all empty cells on the left side. Then we measure which of these reach the right side. Then we start with the points reached on the
right side and run percolation on that. This gives a large cluster. Dividing the size of this cluster by the number of non-blocked elements
gives the percolation probability

"""
function compute_percolation_probability(inputs::Dict)
    # generate random arary
    blocked, _ = generate_geometry(inputs["widths"], inputs["porosity"])
    # get initial conditions on all empty cells on the left side
    initial_conditions = Set()
    for i = 1:size(blocked, 1)
        if blocked[i,1] == 0
            push!(initial_conditions, [i,1])
        end
    end
    # run percolation for these initial conditions
    filled = run_percolation(inputs["directions"], initial_conditions, blocked)

    # get initial conditions from all cells on the right side that were filled from the percolation
    new_initial_conditions = Set()
    for i = 1:size(filled, 1)
        if filled[i, end] == 1
            push!(new_initial_conditions, [i,size(filled, 2)])
        end
    end
    # run percolation on the right side initial conditions
    filled = run_percolation(inputs["directions"], new_initial_conditions, blocked)
    # compute percolation probability
    return blocked, sum(filled)/sum(1 .- blocked)
end

"""
The percolation simulation. Given some initial conditions, fill out the neighbours until you can't
"""
function run_percolation(directions, initial_conditions, blocked)
    # initialize array of zeros to keep track of filled elements
    filled = BitArray(zeros(Int, size(blocked)))
    points = initial_conditions
    fill_new_points!(points, filled) # put intial conditions on filled array
    while true
        # propogate to empty cells until you can't
        points = propagate(points, blocked, filled, directions)
        if isempty(points)
            break
        end
        # put new points in the filled matrix
        fill_new_points!(points, filled)
    end
    return filled
end

"""
Creates empty arrays
"""
function generate_geometry(widths, porosity)
    blocked = rand(Uniform(0,1), widths) .< porosity
    filled = BitArray(zeros(widths))
    return blocked, filled
end
