macro protected(f, e)
    quote
        function callback(args...)
            try
                $(esc(f))(args...)
            catch e
                @error "Error in $($e) event callback!" exception=e
                Base.show_backtrace(stderr, catch_backtrace())
            end
        end
    end
end

"""
        onclick!(callback, [ mousebutton], app)

Adds a mouse event of type `press`.
"""
function onclick!(callback::Function, mousebutton::Int, app::DrawingApp)
    setfield!(
        app.canvas.mouse, 
        Symbol("button$(mousebutton)press"), 
        @protected(callback, :onclick!)
    )
end

function onclick!(callback::Function, mousebutton::Int = 1)
    onclick!(callback, mousebutton, get_current_app())
end

"""
        onclicked!(callback, [ mousebutton], app)

Adds a mouse event of type `press`.
"""
function onclicked!(callback::Function, mousebutton::Int, app::DrawingApp)
    setfield!(
        app.canvas.mouse, 
        Symbol("button$(mousebutton)release"), 
        @protected(callback, :onclicked!)
    )
end

function onclicked!(callback::Function, mousebutton::Int = 1)
    onclicked!(callback, mousebutton, get_current_app())
end

"""
        onmousemotion!(callback, [ mousebutton], app)

Adds a mouse event of type `motion`.
"""
function onmousemotion!(callback::Function, mousebutton::Int, app::DrawingApp)
    if mousebutton == 0
        app.canvas.mouse.motion = @protected(callback, :onmousemotion!)
    else
        setfield!(
            app.canvas.mouse, 
            Symbol("button$(mousebutton)motion"), 
            @protected(callback, :onmousemotion!)
        )
    end
end

function onmousemotion!(callback::Function, mousebutton::Int = 0)
    onmousemotion!(callback, mousebutton, get_current_app())
end
"""
        onkeypress!(callback, window)

Sets the `onkeypress` event callback.
"""
function onkeypress!(callback::Function, window::GtkWindow)
    on!(@protected(callback, :onkeypress!), "key-press-event", window)
end

function onkeypress!(callback::Function)
    onkeypress!(callback, get_current_window())
end

"""
        onkeyrelease!(callback, window)

Sets the `onkeyrelease` event callback.
"""
function onkeyrelease!(callback::Function, window::GtkWindow)
    on!(@protected(callback, :onkeyrelease!), "key-release-event", window)
end

function onkeyrelease!(callback::Function)
    onkeyrelease!(callback, get_current_window())
end
"""
        key(keyname)

Returns the `Gtk` constant key of name `keyname`.
"""
function key(keyname::Union{AbstractString, Symbol})
    try
        getfield(GConstants, Symbol("GDK_KEY_$keyname"))
    catch
        @error "Key $keyname not found."
        Base.show_backtrace(stderr, catch_backtrace())
    end
end