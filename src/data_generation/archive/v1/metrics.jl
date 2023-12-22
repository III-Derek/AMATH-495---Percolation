# these metrics are not used in the final script
"""
Computes fraction of blocks filled to the amount of blocks that can be filled
(ignoring the whether the directions are possible)
"""
function fill_fraction(blocked, filled)
    number_blocked = sum(blocked)
    number_filled = sum(filled)
    return number_filled, number_blocked, number_filled + number_blocked
end



function compute_metrics(blocked, filled, starting_points, directions)
    return (filled[size(blocked)...], fill_fraction(blocked, filled)...)
end