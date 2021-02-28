"""
        onclick!(callback, [ mousebutton], app)

Adds a mouse event of type `press`.
"""
function onclick!(callback::Function, mousebutton::Int, canvas::GtkCanvas)
    setfield!(
        canvas.mouse, 
        Symbol("button$(mousebutton)press"), 
        (args...) -> @protected(callback(args...), "Error in onclick event callback.")
    )
end

function onclick!(callback::Function, mousebutton::Int = 1)
    onclick!(callback, mousebutton, get_current_canvas())
end

"""
        onclicked!(callback, [ mousebutton], app)

Adds a mouse event of type `press`.
"""
function onclicked!(callback::Function, mousebutton::Int, canvas::GtkCanvas)
    setfield!(
        canvas.mouse, 
        Symbol("button$(mousebutton)release"), 
        (args...) -> @protected(callback(args...), "Error in onclicked event callback.")
    )
end

function onclicked!(callback::Function, mousebutton::Int = 1)
    onclicked!(callback, mousebutton, get_current_canvas())
end

"""
        onmousemotion!(callback, [ mousebutton], app)

Adds a mouse event of type `motion`.
"""
function onmousemotion!(callback::Function, mousebutton::Int, canvas::GtkCanvas)
    if mousebutton == 0
        canvas.mouse.motion = (args...) -> @protected(callback(args...), :onmousemotion!)
    else
        setfield!(
            canvas.mouse, 
            Symbol("button$(mousebutton)motion"), 
            (args...) -> @protected(callback(args...), "Error in onmousemotion event callback.")
        )
    end
end

function onmousemotion!(callback::Function, mousebutton::Int = 0)
    onmousemotion!(callback, mousebutton, get_current_canvas())
end
"""
        onkeypress!(callback, window)

Sets the `onkeypress` event callback.
"""
function onkeypress!(callback::Function, window::GtkWindow)
    on!(
        (args...) -> @protected(callback(args...), "Error in onkeypress event callback"), 
        "key-press-event", 
        window
    )
end

function onkeypress!(callback::Function)
    onkeypress!(callback, get_current_window())
end

"""
        onkeyrelease!(callback, window)

Sets the `onkeyrelease` event callback.
"""
function onkeyrelease!(callback::Function, window::GtkWindow)
    on!(
        (args...) -> @protected(callback(args...), "Error in onkeyrelease event callback"), 
        "key-release-event", 
        window
    )
end

function onkeyrelease!(callback::Function)
    onkeyrelease!(callback, get_current_window())
end
"""
        key(keyname)

Returns the `Gtk` constant key of name `keyname`.
"""
function key(keyname::Union{AbstractString, Symbol})
    @protected begin
        gdk_key = Symbol("GDK_KEY_$keyname")
        getfield(GConstants, gdk_key)
    end "Key $keyname not found."
end