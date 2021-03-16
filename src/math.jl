"""
random(a, b [, T = Float64])

Returns a random number between `a` and `b`. The result is converted to the type `T`.
"""
random(a::Real, b::Real, ::Type{T} = Float64) where {T <: Real} = convert(T, (b - a) * rand(Float64) + a)

"""
random(len [, T = Float64])

Returns a random number between `0` and `len`. The result is converted to the type `T`.
"""
random(len::Real, ::Type{T} = Float64) where {T} = random(0, len, T)

"""
        point(v::Vector)

Converts a [`Vector`](@ref) to a [`Point`](@ref) object.
"""
point(v::Vector{<:Real}) = Luxor.Point(v.x, v.y)

"""
        mapr(s::Real, intervals::Matrix)

Return the value `s` linearly mapped from the intervals in `intervals`.

# Examples

```julia
julia> mapr(1, [0 1; 0 10])
10.0

julia> mapr(0.5, [0 1; 0 10])
5.0

julia> mapr(-2, [-5 5; 0 5])
1.5
```
"""
function mapr(s::Real, intervals::Matrix{<:Real})
    a₁, a₂ = intervals[1, :]
    b₁, b₂ = intervals[2, :]
    return b₁ + (s - a₁) * (b₂ - b₁) / (a₂ - a₁)
end

"""
        s ⟶ [a₁ a₂; b₁ b₂]

Return the value `s` linearly mapped from the `a` interval to the `b` interval.

# Examples

```julia
julia> 1 ⟶ [0 1; 0 10]
10.0

julia> 0.5 ⟶ [0 1; 0 10]
5.0

julia> -2 ⟶ [-5 5; 0 5]
1.5
```
"""
⟶(s::Real, intervals::Matrix{<:Real}) = mapr(s, intervals)