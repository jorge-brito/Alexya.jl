mutable struct DrawingApp
    window::GtkWindow
    canvas::GtkCanvas
    framerate::Real
    looping::Bool
    DrawingApp(window, canvas; framerate = 60) = new(window, canvas, framerate, true)
end

"""
        framerate!(app, fr)

Change the current framerate to `fr`.
"""
function framerate!(app::DrawingApp, fr::Real)
    app.framerate = fr
end
"""
        noloop!(app)

Prevent the canvas from looping.
"""
function noloop!(app::DrawingApp)
    app.looping = false
end

function startloop(app::DrawingApp)
    while app.looping
        draw(app.canvas)
        sleep(inv(app.framerate))
    end
end

"""
    loop!(app, setup, update; [ async = false])

Start the application with the respectives `setup` and `update` functions.

If `async` parameter is true, the loop will be asynchronous.
"""
function loop!(app::DrawingApp, setup::Maybe{Function}, update::Function; async = false)
    showall(app.window)

    w, h = width(app.window), height(app.window)

    if setup isa Function
        setup(w, h)
    end

    @guarded draw(app.canvas) do c
        w, h = width(c), height(c)
        d = Drawing(w, h, :image)
        d.cr = getgc(c)
        try
            update(w, h)
        catch e
            @error "Error in update function" exception=e
            Base.show_backtrace(stderr, catch_backtrace())
            app.looping = false
        end
        finish()
    end

    on!(:destroy, app.window) do w
        app.looping = false
    end

    if async
        @async startloop(app)
    else
        startloop(app)
    end
end

function loop!(app::DrawingApp, update::Function; async = false)
    loop!(app, missing, update; async)
end

const CURRENT_APP = Array{DrawingApp, 1}()
const CURRENT_LAYOUT = Array{Layout, 1}()

function get_current_app()
    try
        first(CURRENT_APP)
    catch
        error("There is no current drawing app.")
    end
end

function get_current_layout()
    try
        first(CURRENT_LAYOUT)
    catch
        error("There is no current drawing app.")
    end
end

get_current_window() = getfield(get_current_app(), :window)
get_current_canvas() = getfield(get_current_app(), :canvas)

const DEFAULT_LAYOUT = [VPanels{80}]

function uselayout(::Type{T}) where T <: Layout
    DEFAULT_LAYOUT[1] = T
end

"""
        createCanvas(width, height, layout; [ title, framerate])

Create a new canvas application.
"""
function createCanvas(width::Int, height::Int, ::Type{T};
    title::String = "Canvas", framerate::Real = 60) where T <: Layout
    
    win = Window(width, height; title)
    canvas = Canvas()
    app = DrawingApp(win, canvas; framerate)

    if isempty(CURRENT_APP)
        push!(CURRENT_APP, app)
    else
        CURRENT_APP[1] = app
    end

    lyt = createLayout(T, canvas, win)

    if isempty(CURRENT_LAYOUT)
        push!(CURRENT_LAYOUT, lyt)
    else
        CURRENT_LAYOUT[1] = lyt
    end
end

createCanvas(width, height; kwargs...) = createCanvas(width, height, DEFAULT_LAYOUT[1]; kwargs...)

function loop!(setup::Maybe{Function}, update::Function; async = false)
    loop!(get_current_app(), setup, update; async)
end

function loop!(update::Function; async = false)
    loop!(nothing, update; async)
end

framerate!(fr::Real) = framerate!(get_current_app(), fr)
noloop!() = noloop!(get_current_app())

"""
        @add widget

Adds a widget to the current app.

# Examples

```julia-repl
julia> sw = @add Switch(false)
GtkSwitchLeaf...

julia> @add slider = Slider(1:120)
GtkScaleLeaf...

julia> @add box = Box(Label("Some message"), :v)
GtkBoxLeaf...

```
"""
macro add(ex)
    if Meta.isexpr(ex, Symbol("="))
        n, e = ex.args
        :( $(esc(n)) = add!($(esc(e)), get_current_layout(), get_current_window()) )
    else
        :( add!($(esc(ex)), get_current_layout(), get_current_window()) )
    end
end
"""
        @width

Returns the current canvas `width`.
"""
macro width()
    :( width(get_current_canvas()) )
end
"""
        @height

Returns the current canvas `height`.
"""
macro height()
    :( height(get_current_canvas()) )
end

"""
        @framerate

Returns the current canvas `framerate`.
"""
macro framerate()
    :( getfield(get_current_app(), :framerate) )
end
"""
        @canvas

Returns the current `canvas`.
"""
macro canvas()
    :( get_current_canvas() )
end
"""
        @window

Returns the current `window`.
"""
macro window()
    :( get_current_window() )
end
"""
        @app

Returns the current `app`.
"""
macro app()
    :( get_current_app() )
end