function loop!(
    update::Function, 
    window::GtkWindow, 
    canvas::GtkCanvas; 
    framerate::Real = 64, 
    isRunning::Ref{Bool} = Ref{Bool}(true)
)
     @guarded draw(canvas) do c
        w, h = width(c), height(c)
        d = Drawing(w, h, :image)
        d.cr = getgc(c)        
        gsave()
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
        grestore()
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
    size::Vector{<:Int}
    window::Maybe{GtkWindow}
    canvas::Maybe{GtkCanvas}
    framerate::Real
    running::Ref{Bool}
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
    canvas = Canvas()
    layout = first(CURRENT_LAYOUT)
    window, add = layout(width, height, title, canvas)
    app = DrawingApp(Int[width, height], window, canvas, framerate, Ref{Bool}(true), add)

    empty!(CURRENT_DRAWINGAPP)
    push!(CURRENT_DRAWINGAPP, app)

    return app
end

function loop!(setup::Maybe{Function}, update::Function)
    app = get_current_app()
    window = app.window
    canvas = app.canvas
    isRunning = app.running
    framerate = app.framerate

    showall(window)
    w, h = app.size

    if setup isa Function
        if applicable(setup, w, h)
            setup(w, h)
        else
            setup()
        end
    end

    loop!(update, window, canvas; framerate, isRunning)
end

loop!(update::Function) = loop!(missing, update)

function dontloop!()
    app = get_current_app()
    app.running[] = false
end

framerate!(fps::Real) = setfield!(get_current_app(), :framerate, fps)

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