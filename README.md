# Alexya.jl

> Note: this package is current in development.

**Alexya** merges [Luxor.jl](https://github.com/JuliaGraphics/Luxor.jl) with [Gtk.jl](https://github.com/JuliaGraphics/Gtk.jl). Use this package to create interactive visualizations with luxor in a Gtk window.

## Basic example

```julia
# Example adapted from Luxor.jl documentation
# https://juliagraphics.github.io/Luxor.jl/stable/polygons/#Offsetting-polygons

using Alexya

createCanvas(800, 600) # create a Canvas

t = 0

# @add macro adds the widget to the window
@add velocity = Slider(1/10:1/100:1; @margin(20))

# draw callback is called every frame
draw!() do w, h
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

loop!() # Start the loop
```

Outputs:

![Basic Example](example.gif)

See the [examples](./examples) folder for more examples.