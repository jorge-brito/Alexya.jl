function canvasonly(canvas::GtkCanvas, widgets::GtkWidget...)

    for widget in widgets
        @warn """
        Attempt to add widget of type '$(typeof(widget))', but the current layout 
        is 'canvasonly'. If you want to add other widgets aside from just the 
        canvas, call the `uselayout` function or the `@layout` macro.
        """
    end

    return canvas
end

function aside(::Val{:h}, slength::Int)
    return function(canvas::GtkCanvas, widgets::GtkWidget...)
        window = @window()
        w, h = Gtk.size(window)

        container = Paned(:v, position = h) do 
            canvas,
            Box(() -> widgets, :h)
        end
        # Here we resize the window, so the Canvas can have
        # the same dimensions as specified by the user, because
        # otherwise, Gtk will resize the Canvas to fit inside the window
        Gtk.resize!(window, w, h + slength)
        return container
    end
end

function aside(::Val{:v}, slength::Int)
    return function(canvas::GtkCanvas, widgets::GtkWidget...)
        window = @window()
        w, h = Gtk.size(window)

        container = Paned(:h, position = w) do 
            canvas,
            Box(() -> widgets, :v)
        end
        # Here we resize the window, so the Canvas can have
        # the same dimensions as specified by the user, because
        # otherwise, Gtk will resize the Canvas to fit inside the window
        Gtk.resize!(window, w + slength, h)
        return container
    end
end

aside(type::Symbol, slength::Int) = aside(Val(type), slength)

function uselayout(layout::Function)
    app = current_app()
    app.layout = layout
    nothing
end

macro layout(ex)
    :( uselayout($(esc(ex))) )
end