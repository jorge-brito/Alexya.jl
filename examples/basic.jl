# Example adapted from Luxor.jl documentation
# https://juliagraphics.github.io/Luxor.jl/stable/polygons/#Offsetting-polygons

using Alexya

@layout aside()
createCanvas(800, 600) # create a Canvas

t = 0

# @create macro creates and adds the widget to the window
velocity = @create Slider(1/10:1/100:1; @hexpand)

# draw callback is called every frame
function draw(w, h)
    background("#e1e1e1")
    origin()

    spine = [Point(20x, 15sin(x + t)) for x in -4π:pi/24:4pi]

    f(t, b, c, d) = 2sin(t * π)

    pg = offsetpoly(spine, startoffset=1, endoffset=10, easingfunction=f)
    sethue("black")
    poly(pg, :fill)

    sethue("#e1e1e1")
    poly(spine, :stroke)

    global t += value(velocity)

    if t >= 6π
        global t = 0
    end
end

loop!(draw) # Start the loop