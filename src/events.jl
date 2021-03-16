function onevent(callback::Function, type::SString, canvas::GtkCanvas)
    mouse = canvas.mouse
    setfield!(mouse, Symbol(type), (args...) -> begin
        try
            if applicable(callback, args...)
                callback(args...)
            else
                callback()
            end
        catch e
            @error "Error in '$type' canvas event callback." exception=e
            Base.show_backtrace(stderr, catch_backtrace())
        end
    end)
end

function appclosed()
    app = current_app()
    destroy(app)
    destroy.(app.widgets)
    empty!(app.widgets)
    empty!(app.events)
    app.loop = false
end

function canvasfocus()
    app = current_app()
    GAccessor.focus(app.window, C_NULL)
end

struct Event{T}
    callback::Function
    Event(T, callback) = new{T}(callback)
end

function setevent(event::Event{T}) where {T}
    @warn "Event of type '$T' not recognized."
end

function setevent(event::Event{:appclosed})
    app = current_app()
    onevent(:destroy, app.window) do 
        appclosed()
        event.callback()
    end
end

function setevent(event::Event{:keypress})
    app = current_app()
    onevent("key-press-event", app.window) do w, e
        try
            # If there is other element focused
            # this will throw an error
            GAccessor.focus(app.window)
        catch error
            # if not, the canvas is the current focused widget
            # and we can fire the keypress event
            event.callback(e)
        end
    end
end

for i in 1:3
    for event in [:press, :release, :motion]
        e = QuoteNode(Symbol("mouse$(i)$event"))
        ce = "button$(i)$event"
        @eval function setevent(event::Event{$e})
            onevent($ce, current_app(:canvas)) do w, e
                canvasfocus()
                event.callback((
                    pos = Point(e.x, e.y),
                    x = e.x,
                    y = e.y
                ))
            end
        end
    end
end

for (a, b) in [:mousepress => :mouse1press, :mousemotion => :mouse1motion, :mouserelease => :mouse1release]
    @eval function setevent(event::Event{$(QuoteNode(a))})
        setevent(Event($(QuoteNode(b)), event.callback))
    end
end

function setevent(event::Event{:mousemove})
    onevent(:motion, current_app(:canvas)) do w, e
        event.callback((
            pos = Point(e.x, e.y),
            x = e.x,
            y = e.y
        ))
    end
end

function setevent(event::Event{:setup})
    event.callback()
end

function setevent(event::Event{:update})
    app = current_app()
    canvas = app.canvas
    fps_interval = 1 / app.framerate
    then = time()
    app.framecount = 0
    
    Gtk.@guarded Gtk.draw(canvas) do c
        w, h = width(c), height(c)
        app.width = w
        app.height = h

        fps_interval = 1 / app.framerate
        now = time()
        Δt = now - then
        # @show Δt

        if Δt > fps_interval
            then = now# - (Δt % fps_interval)
            app.fps = floor(1 / Δt)

            app.drawing = Drawing(w, h, :image)
            app.drawing.cr = Gtk.getgc(c)
            app.framecount += 1
            try
                gsave()
                event.callback()
                grestore()
                finish()
            catch e
                @error "Error in update function." exception=e
                Base.show_backtrace(stderr, catch_backtrace())
                app.loop = false
            end
        end
    end
end