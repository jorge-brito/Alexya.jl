mutable struct AlexyaApp
    title::String # The window title
    width::Int # Canvas width
    height::Int # Canvas height
    framerate::Real # FPS
    layout::Function # Layout manager
    window::GtkWindow # The GtkWindow widget
    canvas::GtkCanvas # The GtkCanvas widget
    events::Dict{Symbol, Function}
    loop::Bool
    framecount::Int 
    fps::Real # Current FPS
    widgets::Vector{<:GtkWidget}
    drawing::Drawing # Luxor Drawing object

    AlexyaApp() = new()
end

function destroy(app::AlexyaApp)
    Gtk.destroy.([app.widgets..., app.canvas, app.window])
end

const CURRENT_ALEXYA_APP = Array{AlexyaApp, 1}()

function current_app()
    try
        return CURRENT_ALEXYA_APP[1]
    catch
        throw(error("There is no current Alexya Application."))
    end
end

current_app(field::Symbol) = getfield(current_app(), field)

"""
        addwidget(widget::GtkWidget)

Adds the widget `widget` in the current window.

# Examples

```julia
julia> slider = Slider(1:100)
GtkSlider...

julia> addwidget(slider)
GtkSlider...
```
"""
function addwidget(widget::GtkWidget)
    widgets = current_app(:widgets)
    push!(widgets, widget)
    return widget
end


"""
        init(title [, width = 400, height = 400])

Initialize `Alexya` by creating a new `AlexyaApp` global object.

The `title` parameter is the title of the `window`, the `width` 
and `height` parameters are not necessarily the same as the 
window, but they determine the size of the canvas. The size
of the window and canvas can be controlled by the current
`layout`, and the behavior of the `addwidget` function or 
`@create` macro are also controlled by the `layout`.

The default `layout` is `canvasonly`, wich means that
the canvas will be the only widget on the window and
uses of the `addwidget` function or `@create` macro
will not work.

You can set the current `layout` by calling the `uselayout` function
or the `@layout` macro. The `layout` is a just a function that
determines how the widgets (including the canvas) are added to the
window. You can also create your own layouts.

# Examples

```julia
julia> init("My beautiful animation", 800, 600)
AlexyaApp...

julia> @layout aside(:h, 200)

julia> @layout aside(:v, 300)

julia> @layout MyLayout

julia> uselayout() do canvas, widgets
            Box(:v) do
                canvas,
                widgets...
            end # Box 
        end

```
"""
function init(title::String, width::Int = 400, height::Int = 400)
    @debug "Application initialized."
    app = AlexyaApp()
    app.title = title
    app.width = width
    app.height = height
    app.framerate = 65.0
    app.layout = canvasonly
    app.widgets = GtkWidget[]
    app.events = Dict{Symbol, Function}(:appclosed => appclosed)
    app.loop = true

    app.canvas = GtkCanvas()
    app.window = Window((), title, width, height)
    app.drawing = Drawing(width, height, :image)

    empty!(CURRENT_ALEXYA_APP)
    push!(CURRENT_ALEXYA_APP, app)

    return app
end

"""
        start(; [ async = false])

Starts the current `AlexyaApp`.

This function will setup all the events, apply the current `layout` and start the canvas drawing loop.
The `async` parameter determines if the loop should be asynchronous.
"""
function start(; async::Bool = false)
    app = current_app()
    layout = app.layout
    widgets = app.widgets
    window = app.window
    canvas = app.canvas

    add!(window, layout(canvas, widgets...))
    showall(window)
    setevent.([Event(T, callback) for (T, callback) in app.events])

    if async
        @async while app.loop == true
            Gtk.draw(canvas)
            sleep(1/app.framerate)
        end
    else
        while app.loop == true
            Gtk.draw(canvas)
            sleep(1/app.framerate)
        end
    end
end
"""
        framerate(fps::Real)

Sets the current `framerate`.

The default `framerate` is approximaly `60` frames/second.

!!! note

    The framerate is dynamic, wich means that you can
    set the framerate inside the `update` function or anywhere else.

"""
function framerate(fps::Real)
    app = current_app()
    app.framerate = fps
end

"""
        noLoop()

This function will prevent the drawing loop from start, wich will call the `update`
function just one time (or zero if you call on the `setup` function).
"""
function noLoop()
    app = current_app()
    app.loop = false
end

"""
        use(type::Symbol, func::Function)

`Alexya` works with events, and event listeners can be attached to the current
`application` with the `use` function or the `@use` macro.

Each event has a unique type (a `symbol`) that determines how it is fired.

!!! note

    The `@use` macro automatically determines the type of event
    by the name of the function that is passed as argument.

| Event        | Is fired when        | Usage                                                   |
|:-------------|:---------------------|:--------------------------------------------------------|
|`setup`       | The `app` starts     | Do something when the app is starting                   |
|`update`      | Every frame          | Draw every frame on the canvas using Luxor              |
|`appclosed`   | Window closed        | Do something when the window is closed                  |
|`keypress`    | Keyboard key pressed | Do something when a key is pressed                      |
|`mousepress`  | Canvas is clicked    | Do something when the canvas is clicked                 |
|`mouserelease`| Canvas is clicked    | Do something after the canvas is clicked                |
|`mousemotion` | Mouse is moving      | Do something when the mouse is moving inside the canvas |

# Examples

```julia
@use function setup()
    println("My application has started!")
end

@use function update()
    background("black")
    # Luxor drawing here
end

@use function keypress(event)
    @info "Key press event" key=event.keyval
end

@use function mousepress(event)
    @info "Mouse clicked" pos=event.pos
end

@use function mouserelease(event)
    @info "Mouse button release" pos=event.pos
end

@use function mousemotion(event)
    @info "Cursor moving" pos=event.pos
end

@use function appclosed()
    @info "Window closed"
end
```
"""
function use(type::Symbol, func::Function)
    app = current_app()
    app.events[type] = func
end

"""
        @use event

Adds a `event` listener on the current `application`.

The `@use` macro should be use in a function declaration expression.

The event `type` is automatically determined by the name of the function.
"""
macro use(ex)
    if ex isa Symbol
        name = QuoteNode(ex)
        :( use($name, $(esc(ex))) )
    elseif Meta.isexpr(ex, :function)
        name = ex.args[1].args[1]
        quote
            $(esc(ex))
            use($(QuoteNode(name)), $(esc(name)))
        end
    end
end

"""
        @window

Returns the current `window`.
"""
macro window()
    :( current_app(:window) )
end

"""
        @canvas

Returns the current canvas.
"""
macro canvas()
    :( current_app(:canvas) )
end

"""
        @width

Returns the current canvas `width`.
"""
macro width()
    :( current_app(:width) )
end

"""
        @height

Returns the current canvas `height`.
"""
macro height()
    :( current_app(:height) )
end

"""
        @framecount

Returns the current `frame count`.
"""
macro framecount()
    :( current_app(:framecount) )
end

"""
        @framerate

Returns the current `framerate`.
"""
macro framerate()
    :( current_app(:fps) )
end

"""
        @create widget

Adds a `widget` in the current `application`.
"""
macro create(ex)
    :( addwidget($(esc(ex))) )
end

"""
        @init title [width = 400, height = 400]

Shorthand macro for the `init` function.
"""
macro init(title)
    :( init($(esc(title)), 400, 400) )
end
"""
        @init title width height

Shorthand macro for the `init` function.
"""
macro init(title, width, height)
    :( init($(esc(title)), $(esc(width)), $(esc(height))) )
end