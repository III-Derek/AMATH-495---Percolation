function target_filled(point, blocked, filled)
    return blocked[point...] || filled[point...]
end

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

function run_percolation(inputs::Dict)
    # metrix to track
    max_distance2 = 0
    max_projected_distance = zeros(length(inputs["directions"]))

    blocked, filled = generate_geometry(inputs["widths"], inputs["porosity"])
    points = inputs["initial conditions"]
    fill_new_points!(points, filled)
    while true
        points = propagate(points, blocked, filled, inputs["directions"])
        if isempty(points)
            break
        end
        # compute metrics
        for p in points
            for init_p in inputs["initial conditions"]
                for (i, direction) in enumerate(inputs["directions"])
                    dist = ((p - init_p)'direction)/sqrt(sum(direction.^2))
                    if dist > max_projected_distance[i] 
                        max_projected_distance[i] = dist
                    end
                end
                dist = sum((p - init_p).^2)
                if dist > max_distance2
                    max_distance2 = dist
                end
            end
        end
        fill_new_points!(points, filled)
    end
    return blocked, filled, sqrt(max_distance2), max_projected_distance
end

function generate_geometry(widths, porosity)
    blocked = rand(Uniform(0,1), widths) .< porosity
    filled = BitArray(zeros(widths))
    return blocked, filled
end
