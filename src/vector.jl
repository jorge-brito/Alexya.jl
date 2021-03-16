const Vec = Vector{<:Real}

const VECT_LETTER_INDICIES = Dict{Symbol, Int}(
    :x => 1, 
    :y => 2, 
    :z => 3, 
    :w => 4
)

function set_vector_lindex!(index::Pair{Symbol, Int})
    VECT_LETTER_INDICIES[first(index)] = last(index)
end

function Base.getproperty(v::Vec, key::Symbol)
    i = get(VECT_LETTER_INDICIES, key, missing)
    @assert !ismissing(i) "Vector letter index '$key' not found.
    You may want to define others letter indicies for higher dimension vectors.\n"
    try
        return v[i]
    catch e
        throw(error("attempt to access the $(i)th dimension of $(length(v))D Vector."))
    end
end

function Base.setproperty!(v::Vec, key::Symbol, value::Real)
    i = get(VECT_LETTER_INDICIES, key, missing)

    @assert !ismissing(i) "Vector letter index '$key' not found.
    You may want to define other letter indicies for vectors with dimension higher than 4.\n"

    try
        v[i] = value
    catch e
        throw(error("attempt to set component '$key' of $(length(v))D Vector."))
    end
end

extend!(v::Vec, d = 1) = push!(v, [0 for i in 0:d]...)

"""
        mag(v::Vector{<:Real})

Returns the `magnitude` of `v`.
"""
mag(v::Vec) = norm(v)
"""
        mag2(v::Vector{<:Real})

Returns the `magnitude` squared of `v`.
"""
mag2(v::Vec) = norm(v, 1)
"""
        mag²(v::Vector{<:Real})

Returns the `magnitude` squared of `v`.
"""
mag²(v::Vec) = mag2(v)

Base.abs(v::Vec) = mag(v)
"""
        angle(v::Vector{<:Real})

Returns the `angle` (in radians) that a 2D vector `v` makes
with the positive x-axis.
"""
Base.angle(v::Vec) = atan(v[2], v[1])

"""
        rot(v::Vector{<:Real}, φ)

Returns a new vector where its `magnitude` is the same as `v`,
but its angle is the sum of `φ` and the angle of `v`.
"""
rot(v::Vec, φ::Real) = Float64[cos(angle(v) + φ), sin(angle(v) + φ)] * mag(v)

Vect(coords::Real...) = [coords...]
Vect(; angle::Real, abs::Real = 1) = abs * [cos(angle), sin(angle)]

function limit(v::Vec, max::Real)
    m = mag2(v)
    nv = copy(v)
    if m > max ^ 2
        nv = (nv / sqrt(m)) * max
    end
    return nv
end

"""
        randv()

Returns a vector of magnitude `1` pointing in a random direction.
"""
randv() = withangle(rand(Float64) * 2π)
"""
        withangle(angle [, abs = 1])

Returns a vector of magnitude `abs` and angle `angle`.
"""
withangle(angle::Real, m::Real = 1) = Vect(; angle, abs = m)
"""
        withmag(v, m)

Returns a vector with the same direction as `v`, but with magnitude `m`.
"""
withmag(v::Vec, m::Real) = m * normalize(v)