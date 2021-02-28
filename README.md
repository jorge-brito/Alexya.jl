# Alexya.jl

**Alexya** merges [Luxor.jl](https://github.com/JuliaGraphics/Luxor.jl) with [Gtk.jl](https://github.com/JuliaGraphics/Gtk.jl). Use this package to create interactive visualizations with luxor in a Gtk window.

## Getting Started

### Instalation

Install with the Julia package manager.

```julia
import Pkg; Pkg.add("Alexya")
```

Or

```julia
julia> add Alexya
```
### How to use

First, load the package:

```julia
using Alexya
```

Then, create a canvas with the `width` and `height` of your choose:

```julia
createCanvas(800, 600)
```

You can also pass a keyword argument `title` for the title of the window.

```julia
createCanvas(800, 600; title = "My canvas")
```

Then, define your `setup` and `draw` (or `update`) functions:

```julia
function setup(width, height)
    # This function is called when the window
    # is created
    println("Starting...")
end

function draw(width, height)
    # this function is called every frame
    # draw something here using Luxor's functions
end
```

Then, start the loop using those functions:

```julia
loop!(setup, draw)
```
If you want to know how to draw things on the screen, check out
the **Luxor.jl** documentation [here](https://juliahub.com/docs/Luxor/HA9ps/2.7.0/tutorial/).

## More complete example

```julia
# Example adapted from Luxor.jl documentation
# https://juliagraphics.github.io/Luxor.jl/stable/polygons/#Offsetting-polygons

using Alexya

createCanvas(800, 600) # create a Canvas

t = 0

# @add macro adds the widget to the window
@add velocity = Slider(1/10:1/100:1; @hexpand)

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
```

Outputs:

![Basic Example](example.gif)

See the [examples](./examples) folder for more examples.

## About this package

> English is not my native language, so if you see any errors, i'm sorry.

### For what i can use this package?

Use this package for creating interactive visualizations using a window and widgets from the [Gtk.jl](https://github.com/JuliaGraphics/Gtk.jl) package and the drawing tools from the awsome [Luxor.jl](https://github.com/JuliaGraphics/Luxor.jl) package.

### Why do you have created this package?

I'm think **julia** is a perfect language for creating visualizations because of its performance and syntax, and i was trying to created a drawing package for that, but a find Luxor.jl and Gtk.jl so i decided to bring then together.

### What performance benefits i'll have?

I guess you'll have good performance if you don't try to draw something real crazy, like more than 1 thousand little things that constantly updates on the screen, for that, i'll recommend to you learning other packages that use OpenGL or learn how to draw with OpenGL from scratch, but this package is good if you want to relax and create simple visualizations that the user can interact with, you can even create the Snake game.

### 3D Support?

Well... I think there is a package that allows you to create 3D things with Luxor, but, if you really want to draw 3D things, i don't think this is the better package for you to use. Like i said above, try messing with OpenGL. **But**, in the future i'll try to implement 3D with OpenGL in this package, but not for now.

### How can i contribute?

I'm not a professional developer, programming is my hobby, and most of my projects came from that (even what i study on college doesn't have anything to do with programming), but i love to code, and if you see some bugs or things that you can optimize, feel free to creating a issue or pull request.

### Why the name?

Well, **Alexya** is a friend of mine, and just think her name is so beautiful, and also i'm terrible at choosing names, so i just picked her name.

## License

MIT License

Copyright (c) 2021 jorge-brito.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.