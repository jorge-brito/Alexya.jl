abstract type Layout{T, N} end

function layout_rule(::Type{Layout{:overlay}}, canvas::Gtk.GtkCanvas)
    container = Box((), :v)
    body = EventBox() do 
        Overlay([canvas, container])
    end
    # Propagate the event to the canvas
    on("button-press-event", body) do w, event
        Gtk.signal_emit(canvas, "button-press-event", Bool, event)
    end
    # Propagate the event to the canvas
    on("button-release-event", body) do w, event
        Gtk.signal_emit(canvas, "button-release-event", Bool, event)
    end
    # Propagate the event to the canvas
    on("motion-notify-event", body) do w, event
        Gtk.signal_emit(canvas, "motion-notify-event", Bool, event)
    end

    return body, container 
end

function layout_rule(::Type{Layout{:split, N}}, canvas::Gtk.GtkCanvas) where {N}
    container = Box((), :v)
    body = Paned([canvas, container], :h; position = N)
    return body, container 
end

function layout_rule(::Type{Layout{:splitv, N}}, canvas::Gtk.GtkCanvas) where {N}
    container = Box((), :v)
    body = Paned([canvas, container], :v; position = N)
    return body, container 
end

export layout_rule,
       Layout     