const Maybe{T} = Union{Missing, T}

import Luxor: Point

macro void(f)
    @assert Meta.isexpr(f, :function)
    append!(last(f.args).args, :( return nothing ))
    esc(f)
end

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

function margin(t, r, b, l; top = missing, left = missing, right = missing, bottom = missing)
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

function Base.map(s::T, a::AbstractRange, b::AbstractRange) where T <: Real
    a₁, a₂ = first(a), last(a)
    b₁, b₂ = first(b), last(b)
    b₁ + (s - a₁) * (b₂ - b₁) / (a₂ - a₁)
end

Point(v::T) where T <: Vector{<:Real} = Point(first(v), last(v))
