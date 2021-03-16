struct SVGCmd{T}
    args::Vector{<:Float64}
    SVGCmd{T}(args::Vararg{<:Float64}) where T = new{T}(Float64[args...])
end

mutable struct SVGPath
    path::String
    commands::Vector{SVGCmd}
end

function SVGPath(path::String)
    svg_path = SVGPath(path, SVGCmd[])
    δ = ""
    Δ = Float64[]
    m = missing
    chars = Char[]

    foreach(path) do char
        if isletter(char)
            push!(chars, ' ')
            push!(chars, char)
            push!(chars, ' ')
        elseif char == '-'
            push!(chars, ' ')
            push!(chars, char)
        else
            push!(chars, char)
        end
    end

    push!(chars, ' ')
    push!(chars, 'E')

    for char in chars
        if isletter(char)
            # println("char is a letter '$char'")
            if ismissing(m)
                # println("Previous letter is missing.")
                m = Symbol(uppercase(char))
                # println("Setting char to ':$m'")
            else
                # println("Previous letter is not missing")
                # @show m Δ
                push!(svg_path.commands, SVGCmd{m}(Δ...))
                empty!(Δ)
                m = Symbol(uppercase(char))
            end
        elseif isdigit(char) || char in ".-"
            # println("Char is part of a number")
            δ *= char
            # @show δ
        elseif (isspace(char) || char == ',') && δ != ""
            # println("char is a space")
            push!(Δ, parse(Float64, δ))
            # @show δ Δ
            δ = ""
        else
            # println("Skipping $char")
            continue
        end
        #println("-" ^ 32)
    end

    return svg_path
end

# Quadratic bezier curve
qB(t, P...) = @. P[2] + (1 - t)^2 * (P[1] - P[2]) + t^2 * (P[3] - P[2])
# Cubic bezier curve
cB(t, P...) = @. (1 - t) * qB(t, P[1], P[2], P[3]) + t * qB(t, P[2], P[3], P[4])

bezier_points(curve::Function, P, Δt = 1/20) = [curve(t, P...) for t in 0:Δt:1]

Base.parse(cmd::SVGCmd{:M}, points) = push!(points, cmd.args)

Base.parse(cmd::SVGCmd{:L}, points) = push!(points, cmd.args)

Base.parse(cmd::SVGCmd{:V}, points) = begin
    x = cmd.args[1]
    y = points[end][2]
    push!(points, Float64[x, y])
end

Base.parse(cmd::SVGCmd{:H}, points) = begin
    x = points[end][1]
    y = cmd.args[1]
    push!(points, Float64[x, y])
end

Base.parse(::SVGCmd{:Z}, points) = push!(points, points[1])

Base.parse(cmd::SVGCmd{:C}, points) = begin
    P = [last(points), [cmd.args[i:i+1] for i in 1:2:6]...]
    for point in bezier_points(cB, P)
        push!(points, point)
    end
end

Base.parse(cmd::SVGCmd{:S}, points) = begin
    args = cmd.args
    P = [points[end-1:end]..., args[1:2], args[3:4]]
    for point in bezier_points(cB, P)
        push!(points, point)
    end
end

Base.parse(cmd::SVGCmd{:Q}, points) = begin
    args = cmd.args
    P = [points[end], args[1:2], args[3:4]]
    for point in bezier_points(cB, P)
        push!(points, point)
    end
end

Base.parse(cmd::SVGCmd{:T}, points) = begin
    args = cmd.args
    P = [points[end-1:end]..., args[1:2], args[3:4]]
    for point in bezier_points(qB, P)
        push!(points, point)
    end
end

Base.parse(::SVGCmd{T}, points) where T = throw(error("SVG Path command of type '$T' not yet supported."))

function getpoints(path::SVGPath)::Vector{Point}
    points = Vector{<:Float64}[]
    for cmd in path.commands
        parse(cmd, points)
    end
    return point.(points)
end

getpoints(path::String) = getpoints(SVGPath(path))

# TODO: implement svg 'arc' command, but i'm kinda lazy
# TODO: implement a way of getting the path from a svg file, without the need of get it manually 