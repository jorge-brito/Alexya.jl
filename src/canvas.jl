function set_update_function(update::Function, canvas::GtkCanvas)
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
        end
        grestore()
        finish()
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

function loop!(setup::Function, update::Function)
    app = get_current_app()
    window = app.window
    canvas = app.canvas
    running = app.running

    changed = Ref{Bool}(false)

    on!(:size_allocate, window) do args...
        if !changed[]
            changed[] = true
            w, h = width(canvas), height(canvas)
            try
                if applicable(setup, w, h)
                    setup(w, h)
                else
                    setup()
                end
            catch e
                @error "Error in setup callback" exception=e
                Base.show_backtrace(stderr, catch_backtrace())
            end
            set_update_function(update, canvas)
        end
    end
    
    on!(:destroy, window) do w
        @layout nolayout
        running[] = false
        Gtk.gtk_quit()
    end

    showall(window)

    @async Gtk.gtk_main()

    while running[]
        draw(canvas)
        sleep(inv(app.framerate))
    end
end

loop!(update::Function) = loop!((args...) -> nothing, update)

function dontloop!()
    app = get_current_app()
    app.running[] = false
end

framerate!(fps::Real) = setfield!(get_current_app(), :framerate, fps)

macro size()
    :( sizeof( get_current_window() ) )
end

macro window()
    :( get_current_window() )
end

macro canvas()
    :( get_current_canvas() )
end

macro width()
    :( first( size( get_current_canvas() ) ) )
end

macro height()
    :( last( size( get_current_window() ) ) )
end