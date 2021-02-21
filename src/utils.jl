const Maybe{T} = Union{Nothing, T}

"""
        point(v)

Converts a [`Vector`](@ref) to a [`Point`](@ref) object.
"""
point(v::Vector{<:Real}) = Point(first(v), last(v))

"""
        mapr(a, b)

Returns a function that linearly map values from the `a` interval to the `b` interval.

# Examples

```julia-repl
julia> f = mapr(0:1, 0:10)
# (generic function with 1 method)

julia> f(1)
10.0

julia> f(0.5)
5.0

```
"""
function mapr(a::UnitRange, b::UnitRange)
    a₁, a₂ = first(a), last(a)
    b₁, b₂ = first(b), last(b)
    return (s) -> b₁ + (s - a₁) * (b₂ - b₁) / (a₂ - a₁)
end
"""
        mapr(s, (a, b))

Returns the value `s` from the `a` interval linearly mapped on the `b` interval.

# Examples

```julia-repl
julia> mapr(1, 0:1, 0:10)
10.0

julia> mapr(0.5, 0:1, 0:10)
5.0

```
"""
function mapr(s::Real, a::UnitRange, b::UnitRange)
    return mapr(a, b)(s)
end
"""
        ↦(s, (a, b))

Returns the value `s` from the `a` interval linearly mapped on the `b` interval.

# Examples

```julia-repl
julia> 2 ↦ (0:1, 0:10)
20.0

julia> -5 ↦ (-10:10, 0:1)
0.25

```
"""
↦(s::Real, (a, b)::Tuple{UnitRange, UnitRange}) = mapr(s, a, b)

function abs(v::Vector{T}) where T <: Real
    √(reduce(+, v .^ 2))
end

function getFPS!(lf::Ref{DateTime})
    then = Dates.now()
    Δt = Millisecond(then - lf).value
    lf[] = then
    return 1000 / Δt
end

function sizeof(win::GtkWindow)
    return width(win), height(win)
end