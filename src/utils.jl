const Maybe{T} = Union{Missing, T}

"""
        dashcase(s::AbstractString)

Convert a camel or snake case string `s` to dashcase.

# Examples

```julia-repl
julia> dashcase("snake_case_string")
"snake-case-string"

julia> dashcase("someCamelCaseString")
"some-camel-case-string"
```
"""
function dashcase(s::AbstractString)
    res = Base.map(collect(s[2:end])) do char
        if char == '-'
            return "-"
        elseif char == '_'
            return "-"
        elseif char == uppercase(char)
            return "-" * lowercase(char)
        else 
            return string(char)
        end
    end
    pushfirst!(res, lowercase(s[1]) |> string) 
    return join(res)
end

function dashcase(s::Symbol)
    dashcase(string(s))
end

function dict(; kwargs...)
    return Dict(pairs(kwargs))
end

"""
        margin(t::Real, r::Real, b::Real, l::Real; kwargs...)

Return a `margin` dict that can be used to set margins of a widget.

|Parameter|Description     |
|---------|---------------:|
|`t`      | top margin     |
|`r`      | right margin   |
|`b`      | bottom margin  |
|`l`      | left margin    |

# Example

```julia
slider = Slider(0:255; start = 125)
set!(slider; margin = margin(20, 30, 20, 30))
```
"""
function margin(t::Real, r::Real, b::Real, l::Real; top = missing, left = missing, right = missing, bottom = missing)
    return Dict([
        :top    => ismissing(top)    ? t : top,
        :right  => ismissing(right)  ? r : right,
        :bottom => ismissing(bottom) ? b : bottom,
        :left   => ismissing(left)   ? l : left
    ])
end

function margin(t, b, lr)
    margin(t, lr, b, lr)
end

function margin(tb, lr)
    margin(tb, tb, lr)
end

function margin(size)
    margin(size, size)
end

macro margin(t, r, b, l)
    Expr(:kw, :margin, :( margin($t, $r, $b, $l) )) |> esc
end

macro margin(t, b, lr)
    Expr(:kw, :margin, :( margin($t, $lr, $b, $lr) )) |> esc
end

macro margin(tb, lr)
    Expr(:kw, :margin, :( margin($tb, $tb, $lr) )) |> esc
end

macro margin(size)
    Expr(:kw, :margin, :( margin($size, $size) )) |> esc
end

"""
        ⟶(s::Real, (a, b))

Maps the value `s` of the range `a` in the range `b`

# Examples

```julia
julia> 1 ⟶ (0:1, 0:10)
10.0

julia> 0.5 ⟶ (0:1, 0:10)
5.0

julia> -5 ⟶ (-10:10, 0:1)
0.25
```
"""
function ⟶(s::Real, (a, b))
    a₁, a₂ = first(a), last(a)
    b₁, b₂ = first(b), last(b)
    b₁ + (s - a₁) * (b₂ - b₁) / (a₂ - a₁)
end

"""
        point(v::Vector{<:Real})

Converts a `Vector` to a `Point`.

# Examples

```julia
julia> point([1, 2])
Point(1.0, 2.0)

julia> point([-5, 5])
Point(-5.0, 5.0)
```
"""
function point(v::Vector{<:Real})
    Point(v[1], v[2])
end