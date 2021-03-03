using Alexya

@layout aside(220)

createCanvas(1200, 800; title = "Drawing")

mutable struct Sketch
    points::Vector{Point}
    color::Color
    stroke::Real
    fill::Bool
end

trash = Sketch[]
sketchs = Sketch[]

clear() = empty!(sketchs)

# ------------- ------------- Controls ------------- ------------- 

# Background color
bg = ColorButton("#e1e1e1")
# Line color
color = ColorButton("#f1a")
# Line width
linewidth = Slider(1:100)
# Should fill
sketchfill = Switch(false, hexpand = false, @halign(:center))

undo = Button("Undo")
on!(:clicked, undo) do w
    if length(sketchs) > 0
        push!(trash, pop!(sketchs))
    
        if length(trash) > 10
            pop!(trash)
        end
    end
end

redo = Button("Redo")
on!(:clicked, redo) do w
    if length(trash) > 0
        push!(sketchs, pop!(trash))
    end
end

clearbtn = Button("Clear")
on!(:clicked, clearbtn) do w
    clear()
end

create_sketch() = push!(sketchs, Sketch(
    Point[], 
    value(color), 
    value(linewidth),
    value(sketchfill)
))

@create Grid([
    label"Background: "     bg
    label"Color"            color
    label"Line width: "     linewidth
    label"Fill: "           sketchfill
    undo                    redo
    clearbtn → 2            ""               
    ],  @margin(10), @halign(:center),
    row_spacing = 10, column_spacing = 5
)

global drawing = false
global firstframe = true

function update(w, h)
    if firstframe
        spiralcurve = spiral(20, 0.3, log=true, period=3π)
        f(x, θ) = 1 + 15sin(x * π)
        # translate the spiral to the origin
        pgon = map(p -> Point(w/2, h/2) + p, offsetpoly(spiralcurve, f))
        push!(sketchs, Sketch(pgon, colorant"black", 1, true))
        global firstframe = false
    end

    background(value(bg))

    for sketch in sketchs
        sethue(sketch.color)
        setline(sketch.stroke)
        action = sketch.fill ? :fill : :stroke
        poly(simplify(sketch.points), action)
    end
end

onmousemotion!(1) do w, event
    !drawing && create_sketch()
    
    sketch = last(sketchs)
    push!(sketch.points, Point(event.x, event.y))

    global drawing = true
end

onclicked!(1) do w, event
    global drawing = false
end

loop!(update)