function loop!(update::Function, window::GtkWindow, canvas::GtkCanvas; framerate::Real = 64)
    isRunning = Ref{Bool}(true)

     @guarded draw(canvas) do c
        w, h = width(c), height(c)
        d = Drawing(w, h, :image)
        d.cr = getgc(c)        
        try
            if applicable(update, w, h)
                update(w, h)
            else
                update()
            end
        catch e
            @error "Error in update callback." exception=e
            Base.show_backtrace(stderr, catch_backtrace())
            isRunning[] = false
        end
        finish()
    end

    @on :destroy window (w) -> begin
        isRunning[] = false
    end

    showall(window)

    while isRunning[] == true
        draw(canvas)
        sleep(inv(framerate))
    end
end

mutable struct DrawingApp
    window::Maybe{GtkWindow}
    canvas::Maybe{GtkCanvas}
    framerate::Real
    add::Function
end

const CURRENT_DRAWINGAPP = Array{DrawingApp, 1}()

function get_current_app()
    try
        first(CURRENT_DRAWINGAPP)
    catch
        error("No current DrawingApp has been created with the `createCanvas` function.")
    end
end

get_current_window() = getfield(get_current_app(), :window)
get_current_canvas() = getfield(get_current_app(), :canvas)

function createCanvas(width::Int, height::Int; framerate::Real = 60, title::String = "Canvas")
    window = Window(width, height; title)
    canvas = Canvas()
    layout = first(CURRENT_LAYOUT)
    add = layout(window, canvas)
    app = DrawingApp(window, canvas, framerate, add)

    empty!(CURRENT_DRAWINGAPP)
    push!(CURRENT_DRAWINGAPP, app)

    return app
end

function loop!(setup::Maybe{Function}, update::Function)
    app = get_current_app()
    window = app.window
    canvas = app.canvas

    showall(window)
    wwidth, wheight = sizeof(window)

    if setup isa Function
        if applicable(setup, wwidth, wheight)
            setup(wwidth, wheight)
        else
            setup()
        end
    end

    loop!(update, window, canvas; framerate = app.framerate)
end

loop!(update::Function) = loop!(missing, update)

macro size()
    :( sizeof( get_current_window() ) )
end

macro width()
    :( first( sizeof( get_current_window() ) ) )
end

macro height()
    :( last( sizeof( get_current_window() ) ) )
end

macro window()
    :( get_current_window() )
end

macro canvas()
    :( get_current_canvas() )
end