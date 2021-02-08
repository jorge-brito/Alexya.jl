abstract type Mouse{T} end

macro protected(callback)
    quote
        function handler(args...)
            try
                $(esc(callback))(args...)
            catch e
                @error "Error in event callback" exception=e 
                Base.show_backtrace(stderr, catch_backtrace())
            end
        end
    end
end

for N in 1:3
    @eval function onmousepress!(callback::Function, ::Type{Mouse{$N}}, canvas::AlCanvas)
        setfield!(canvas.widget.mouse, Symbol("button$($N)press"), @protected(callback))
    end

    @eval function onmousepress!(callback::Function, ::Type{Mouse{$N}})
        onmousepress!(callback, Mouse{$N}, get_current_canvas())
    end

    @eval function onmouserelease!(callback::Function, ::Type{Mouse{$N}}, canvas::AlCanvas)
        setfield!(canvas.widget.mouse, Symbol("button$($N)release"), @protected(callback))
    end

    @eval function onmouserelease!(callback::Function, ::Type{Mouse{$N}})
        onmouserelease!(callback, Mouse{$N}, get_current_canvas())
    end
end

function onmousemotion!(callback::Function, canvas::AlCanvas)
    canvas.widget.mouse.motion = @protected(callback)
end

function onmousemotion!(callback::Function)
    onmousemotion!(callback, get_current_canvas())
end

function onkeypress!(callback::Function, win::Gtk.GtkWindow)
    on(@protected(callback), "key-press-event", win)
end

function onkeypress!(callback::Function)
    onkeypress!(callback, get_current_window())
end

function onkeyrelease!(callback::Function, win::Gtk.GtkWindow)
    on(@protected(callback), "key-release-event", win)
end

function onkeyrelease!(callback::Function)
    onkeyrelease!(callback, get_current_window())
end

function key(keyname::Union{AbstractString, Symbol})
    try
        getfield(Gtk.GConstants, Symbol("GDK_KEY_$keyname"))
    catch
        @error "Key $keyname not found."
        Base.show_backtrace(stderr, catch_backtrace())
    end
end

export Mouse, onmousepress!, onmouserelease!, onkeypress!, onkeyrelease!, key, onmousemotion!