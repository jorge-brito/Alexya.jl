using Alexya

@init "Drawing" 1200 800
@layout aside(:v, 220)
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
bg = colorbtn"#e1e1e1"
# Line color
linecolor = colorbtn"#f1a"
# Line width
linewidth = SpinButton(1:100)
# Should fill
sketchfill = Switch(false, hexpand = false, halign = align(:center))

undo = Button("Undo")
onevent(:clicked, undo) do
    if length(sketchs) > 0
        push!(trash, pop!(sketchs))
    
        if length(trash) > 10
            pop!(trash)
        end
    end
end

redo = Button("Redo")
onevent(:clicked, redo) do
    if length(trash) > 0
        push!(sketchs, pop!(trash))
    end
end

clearbtn = Button("Clear")
onevent(:clicked, clearbtn) do
    clear()
end

create_sketch() = push!(sketchs, Sketch(
    Point[], 
    value(linecolor), 
    value(linewidth),
    value(sketchfill)
))

@create Grid([
    label"Background: "     bg
    label"Color"            linecolor
    label"Line width: "     linewidth
    label"Fill: "           sketchfill
    undo                    redo
    clearbtn → 2                           
    ],  
    @margin(10), @align(:center), @spacing(5)
)

global drawing = false

@use function setup()
    w, h = @width, @height
    spiralcurve = spiral(20, 0.3, log=true, period=3π)
    f(x, θ) = 1 + 15sin(x * π)
    # translate the spiral to the origin
    pgon = map(p -> Point(w/2, h/2) + p, offsetpoly(spiralcurve, f))
    push!(sketchs, Sketch(pgon, colorant"black", 1, true))
end

@use function update()
    background(value(bg))

    for sketch in sketchs
        sethue(sketch.color)
        setline(sketch.stroke)
        action = sketch.fill ? :fill : :stroke
        poly(simplify(sketch.points), action)
    end
end

@use function mouse1motion(event)
    !drawing && create_sketch()
    
    sketch = last(sketchs)
    push!(sketch.points, event.pos)

    global drawing = true
end

@use function mousepress(event)
    global drawing = false
end

start()