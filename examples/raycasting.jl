# Example adapted from The Coding Train
# https://youtu.be/TOEi6T2mtHo?list=PLRqwX-V7Uu6ZiZxtDDRCi6uhfTH4FilpH

using Alexya

mutable struct Wall
    a::Vector{<:Real}
    b::Vector{<:Real}
    color::Union{Colorant, AbstractString}
    Wall(a, b; color = "white") = new(a, b, color)
end

mutable struct Ray
    pos::Vector{<:Real}
    dir::Vector{<:Real}
    color::Union{Colorant, AbstractString}
    Ray(pos::Vector{<:Real}, θ::Real; color = "white") = begin
        dir = [cos(θ), sin(θ)]
        new(pos, dir, color)
    end
end

mutable struct Particle
    pos::Vector{<:Real}
    rays::Vector{Ray}
    Particle(pos) = begin
        new(pos, Vector{Ray}())
    end
end

function update!(p::Particle)
    empty!(p.rays)
    for θ in 0:π/n:2π
        i = floor(rad2deg(θ)) |> Int
        color = "hsl($i, 85%, 70%)"
        ray = Ray(p.pos, θ; color)
        push!(p.rays, ray)
    end
    p.pos = [noise(xoff)*width(), noise(yoff)*height()]
end

function draw(wall::Wall)
    sethue(wall.color)
    line(point(wall.a), point(wall.b), :stroke)
end

function draw(p::Particle)
    sethue("white")
    circle(point(p.pos), 1, :fill)
end

function ⟶(ray::Ray, wall::Wall)
    x₁, y₁ = wall.a
    x₂, y₂ = wall.b
    x₃, y₃ = ray.pos
    x₄, y₄ = ray.pos + ray.dir

    den = (x₁ - x₂) * (y₃ - y₄) - (y₁ - y₂) * (x₃ - x₄)

    den == 0 && return

    t =  ((x₁ - x₃) * (y₃ - y₄) - (y₁ - y₃) * (x₃ - x₄)) / den
    u = -((x₁ - x₂) * (y₁ - y₃) - (y₁ - y₂) * (x₁ - x₃)) / den

    if 1 > t > 0 && u > 0
        x = x₁ + t * (x₂ - x₁)
        y = y₁ + t * (y₂ - y₁)

        return Point(x, y)
    end
end

function ⟶(p::Particle, walls::Vector{Wall})
    pos = point(p.pos)
    for ray in p.rays
        closest = nothing
        record = Inf
        for wall in walls
            pt = ray ⟶ wall
            if pt isa Point
                d = distance(pos, pt)
                if d < record
                    record = d
                    closest = pt
                end
            end
        end
        if closest isa Point
            sethue(ray.color)
            line(pos, closest, :stroke)
        end
    end
end

function resetWalls()
    w, h = width(), height()
    empty!(walls)
    push!(walls, Wall([0, 0], [w, 0]; color="black"))
    push!(walls, Wall([w, 0], [w, h]; color="black"))
    push!(walls, Wall([w, h], [0, h]; color="black"))
    push!(walls, Wall([0, h], [0, 0]; color="black"))
end

createCanvas(800, 600, Layout{:splitv, 540}) # create a Canvas

walls = Wall[]
xoff = 0
yoff = 10000
n = 128

slider = Slider(1:256; start=n, hexpand = true)
button = Button("Reset walls", onclicked = (w) -> resetWalls())

@add Box([button, slider], :h; @margin(10), spacing = 10)


setup!() do w, h
    global particle = Particle([0, 0])
    resetWalls()
end

startpoint = Real[]
drawing = false
mouse = Real[]

draw!() do w, h
    global n = value(slider)
    
    background("black")
    update!(particle)
    draw.(walls)
    draw(particle)
    particle ⟶ walls

    if drawing
        line(point(startpoint), point(mouse), :stroke)
    end

    global xoff += 0.01
    global yoff += 0.01
end

onmousepress!(Mouse{1}) do w, event
    global startpoint = [event.x, event.y]
    global drawing = true
end

onmousemotion!() do w, event
    global mouse = [event.x, event.y]
end

onmouserelease!(Mouse{1}) do w, event
    global drawing = false
    endpoint = Real[event.x, event.y]
    push!(walls, Wall(startpoint, endpoint))
end

loop!()