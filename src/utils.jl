const Maybe{T} = Union{Missing, T}

"""
        point(v)

Converts a [`Vector`](@ref) to a [`Point`](@ref) object.
"""
point(v::Vector{<:Real}) = Point(first(v), last(v))

"""
        mapr(a, b)

Returns a function that linearly map values from the `a` interval to the `b` interval.

# Examples

```julia
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

function mapr(a::Tuple{Real, Real}, b::Tuple{Real, Real})
    a₁, a₂ = first(a), last(a)
    b₁, b₂ = first(b), last(b)
    return (s) -> b₁ + (s - a₁) * (b₂ - b₁) / (a₂ - a₁)
end
"""
        mapr(s, (a, b))

Returns the value `s` from the `a` interval linearly mapped on the `b` interval.

# Examples

```julia
julia> mapr(1, 0:1, 0:10)
10.0

julia> mapr(0.5, 0:1, 0:10)
5.0

```
"""
function mapr(s::Real, a::UnitRange, b::UnitRange)
    return mapr(a, b)(s)
end

function mapr(s::Real, a::Tuple{Real, Real}, b::Tuple{Real, Real})
    return mapr(a, b)(s)
end
"""
        ↦(s, (a, b))

Returns the value `s` from the `a` interval linearly mapped on the `b` interval.

# Examples

```julia
julia> 2 ↦ (0:1, 0:10)
20.0

julia> -5 ↦ (-10:10, 0:1)
0.25

```
"""
↦(s::Real, (a, b)::Tuple{AbstractRange, AbstractRange}) = mapr(s, a, b)

"""
        abs(v::Vector)

Returns the absolute value of a julia vector.

# Examples

```julia
julia> abs([3, 4])
5.0

julia> abs([1, 2, 3])
3.7416573867739413

```
"""
function abs(v::Vector{T}) where T <: Real
    √(reduce(+, v .^ 2))
end

function getFPS!(lf::Ref{DateTime})
    then = Dates.now()
    Δt = Millisecond(then - lf[]).value
    lf[] = then
    return 1000 / Δt
end

function sizeof(win::GtkWindow)
    return width(win), height(win)
end

function resizeWidth!(win::GtkWindow, w::Int)
    h = height(win)
    resize!(win, w, h)
end

function resizeHeight!(win::GtkWindow, h::Int)
    w = width(win)
    resize!(win, w, h)
end

macro protected(f, msg)
    quote
        try
            $(esc(f))
        catch e
            @error $(esc(msg)) exception=e
            Base.show_backtrace(stderr, catch_backtrace())
        end
    end
end

macro on(event, widget, callback)
    args = esc.([callback, event, widget])
    quote
        on!($(args...))
    end
end

function convert(::Type{GdkRGBA}, c::T) where T <: ColorAlpha
    c__ = convert(RGBA, c)
    return GdkRGBA(c__.r, c__.g, c__.b, c__.alpha)
end

convert(::Type{GdkRGBA}, c::T) where T <: Colorant = convert(GdkRGBA, convert(RGBA, c))
convert(::Type{T}, c::GdkRGBA) where T <: ColorAlpha = convert(T, RGBA(c.r, c.g, c.b, c.a))
convert(::Type{T}, c::GdkRGBA) where T <: Color = convert(T, RGB(c.r, c.g, c.b))