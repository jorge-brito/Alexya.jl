mutable struct AlCanvas
    widget::Gtk.GtkCanvas
    framerate::Real
    loop::Bool
    draw::Function
    setup::Function

    function AlCanvas(width::Int = -1, height::Int = -1; framerate = 60)
        w = Canvas(width, height)
        return new(w, framerate, true)
    end
end

Base.show(io::IO, alc::AlCanvas) = write(io, "AlCanvas(loop = $(alc.loop), draw = $(isdefined(alc, :draw)))\n")

"""
        loop!(alc::AlCanvas)

Starts the drawing loop of the `alc` canvas.
"""
function loop!(alc::AlCanvas)
    @assert isdefined(alc, :draw) "Canvas must have a draw function."

    function draw(wg)
        w, h = Gtk.width(wg), Gtk.height(wg)
        d = Drawing(w, h, :image)
        d.cr = Gtk.getgc(wg)
        alc.draw(w, h)
        finish()
    end
    
    Gtk.@guarded Gtk.draw(alc.widget) do wg
        w, h = Gtk.width(wg), Gtk.height(wg)
        if !isdefined(alc, :setup)
            @info "Starting without setup function."
        else
            if hasmethod(alc.setup, Tuple{Int, Int})
                alc.setup(w, h)
            else
                alc.setup()
            end
        end
        Gtk.draw(draw, alc.widget)
    end
    while alc.loop
        try
            Gtk.draw(alc.widget)
            sleep(inv(alc.framerate))
        catch e
            alc.loop = false
            @error "Error in drawing loop!" exception=e
            Base.show_backtrace(stderr, catch_backtrace())
            break
        end
    end
end

"""
        noloop!(alc::AlCanvas)

Stop the drawing loop of the `alc` canvas.
"""
function noloop!(alc::AlCanvas)
    alc.loop = false
end
"""
        width(alc::AlCanvas)

Gets the current `width` of the canvas `alc`.
"""
function width(alc::AlCanvas)
    Gtk.width(alc.widget)
end
"""
        height(alc::AlCanvas)

Gets the current `height` of the canvas `alc`.
"""
function height(alc::AlCanvas)
    Gtk.height(alc.widget)
end

"""
        framerate!(alc::AlCanvas, fr::Real)

Sets the framerate of the `alc` canvas to `fr`.
"""
function framerate!(alc::AlCanvas, fr::Real)
    alc.framerate = fr
end
"""
        setup!(callback::Function, alc::AlCanvas)

Sets the `setup` function of the `alc` canvas.

The setup function runs before the loop starts.

The `callback` function can accept 2 parameters `width` and `height`
that correspond to the width and height of the canvas.

# Example

```julia
canvas = AlCanvas(800, 600; title = "My Canvas")

setup!(canvas) do width, height
    println("Starting...")
    @show width height
end
```
"""
function setup!(callback::Function, alc::AlCanvas)
    alc.setup = callback
end
"""
        draw!(callback::Function, alc::AlCanvas)

Sets the `draw` function of the `alc` canvas.

The draw function runs every frame.

The `callback` function can accept 2 parameters `width` and `height`
that correspond to the width and height of the canvas.

# Example

```julia
canvas = AlCanvas(800, 600; title = "My Canvas")

draw!(canvas) do width, height
    background("black")
    origin()
    radius = rand(0:200)
    sethue("white")
    circle(Point(0, 0), radius, :fill)
end
```
"""
function draw!(callback::Function, alc::AlCanvas)
    if hasmethod(callback, Tuple{Real, Real})
        alc.draw = callback
    else
        alc.draw = (w, h) -> callback()
    end
end

const CURRENT_APP = Array{Dict, 1}()

function get_current_app()
    try
        CURRENT_APP[1]
    catch
        error("There is no current app!")
    end
end

get_current_canvas()    = get(get_current_app(), :canvas    , missing)
get_current_window()    = get(get_current_app(), :window    , missing)
get_current_container() = get(get_current_app(), :container , missing)

"""
        createCanvas(width::Int, height::Int [layout=Layout{:overlay},]; kwargs...)

Create a new canvas.
"""
function createCanvas(width::Int, height::Int, layout = Layout{:overlay}; title = "My Canvas")
    canvas = AlCanvas()       
    body, container = layout_rule(layout, canvas.widget)
    window = Window([body], title, width, height)
    app = dict(; canvas, window, container)

    if isempty(CURRENT_APP)
        push!(CURRENT_APP, app)
    else
        CURRENT_APP[1] = app
    end
end

draw!(callback::Function)  = draw!(callback, get_current_canvas())
setup!(callback::Function) = setup!(callback, get_current_canvas())
noloop!()                  = noloop!(get_current_canvas())
framerate!(fr::Real)       = framerate!(get_current_canvas(), fr)
width()                    = width(get_current_canvas())
height()                   = height(get_current_canvas())

function loop!(; async::Bool = false)
    canvas = get_current_canvas()
    win = get_current_window()

    Gtk.showall(win)

    on(:destroy, win) do args...
        noloop!(canvas)
    end

    if async
        @async loop!(canvas)
    else
        loop!(canvas)
    end
end

function add(w::Gtk.GtkWidget)
    container = get_current_container()
    push!(container, w)
    return w
end

"""
Adds a widget to the current container.
"""
macro add(expr)
    if @capture(expr, name_ = w__)
        esc(:( $name = add($(first(w))) ))
    else
        :( add($(esc(expr))) )
    end
end

"""
Returns the current canvas `width`.
"""
macro width()
    esc(:( width() ))
end

"""
Returns the current canvas `height`.
"""
macro height()
    esc(:( height() ))
end