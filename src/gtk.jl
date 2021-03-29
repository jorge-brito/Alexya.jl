"""
        set!(widget, prop, value)

Sets the `value` of the Gtk property `prop` of `widget`.

# Examples

```julia
julia> set!(window, :title, "My window")

julia> set!(entry, :text, "Foo bar")
```
"""
function set!(widget::GtkWidget, prop::SString, value::T) where {T}
    set_gtk_property!(widget, prop, value)
end

"""
        set!(widget, prop, values::NamedTuple)

Sets a Gtk property of `widget` for each key-value pair in `values`.

The name of the final property will be `prop-key` where key is a key of `values`.

For example, instead of setting the margins of a `widget` each time, like this:

```julia
set!(mywidget, :margin_top, 10)
set!(mywidget, :margin_bottom, 20)
set!(mywidget, :margin_left, 15)
set!(mywidget, :margin_right, 10)
```

We can simple do:

```julia
set!(mywidget, :margin, (
    top = 10,
    bottom = 20,
    left = 15,
    right = 10
))
```
"""
function set!(widget::GtkWidget, prop::SString, values::NamedTuple)
    for (sprop, value) in pairs(values)
        set!(widget, "$prop-$sprop", value)
    end
end

"""
        set!(widget, props::NamedTuple)

Sets a Gtk property of `widget` for each key-value pair in `props`.

# Examples

```julia
julia> set!(button, (label = "Click-me"))

julia> set!(color_btn, (color = colorant"#f1a"))
```
"""
function set!(widget::GtkWidget, props::NamedTuple)
    for (prop, value) in props
        set!(widget, prop, value)
    end
end

"""
        set!(widget, props::Dict)

Sets a Gtk property of `widget` for each key-value pair in `props`.
"""
function set!(widget::GtkWidget, props::Dict)
    for (prop, value) in props
        set!(widget, prop, value)
    end
end

"""
        set!(widget; props...)

Sets a Gtk property of `widget` for each key-value pair in `props`.
"""
function set!(widget::GtkWidget; props...)
    if length(props) > 0
        set!(widget, Dict(pairs(props)))
    end
end


"""
        getprop(widget, key)

Returns the Gtk property `key` from `widget`.

# Examples

```julia
julia> getprop(window, :title)
"My window"
```
"""
function getprop(widget::GtkWidget, key::SString)
    return get_gtk_property(widget, key)
end
"""
        getprop(widget, key, T)

Returns the Gtk property `key` with type `T` from `widget`.

# Examples

```julia
julia> getprop(window, :title, String)
"My window"
```
"""
function getprop(widget::GtkWidget, key::SString, ::Type{T}) where T
    return get_gtk_property(widget, key, T)
end

"""
        onevent(callback, event, widget)

Adds a event listener for `widget`. The `callback` is called when the `event` is fired.

# Examples

```julia
julia> onevent(:destroy, window) do
            println("The window has been closed")
       end

```
"""
function onevent(callback::Function, event::SString, widget::GtkWidget)
    return signal_connect(widget, event) do args...
        try
            if applicable(callback, args...)
                callback(args...)
            else
                callback()
            end
        catch e
            @error "Error in event '$event' callback." exception=e
            Base.show_backtrace(stderr, catch_backtrace())
        end
    end
end

function onevent(callback::Function, event::SString, widgets::Vector{<:GtkWidget})
    return [onevent(callback, event, widget) for widget in widgets] 
end

function set!(widget::GtkWidget, event::SString, callback::Function)
    if startswith(string(event), "on")
        onevent(callback, String(string(event)[3:end]), widget)
    else
        set_gtk_property!(widget, event, callback)
    end
end

"""
        offevent(widget, eventid)

Disconnect the event of id `eventid` from `widget`.

# Examples

```julia
julia> id = onevent(:destroy, window) do
            println("The window has been closed")
       end

julia> destroy(window)
The window has been closed

julia> offevent(window, id)

julia> show(window)
GtkWindow...

julia> destroy(window)

```
"""
function offevent(widget, id)
    signal_handler_disconnect(widget, id)
end

macro onevent(event, widget, callback)
    args = esc.([callback, event, widget])
    :( onevent($(args...)) )
end

function add!(parent::GtkWidget, child::GtkWidget)
    push!(parent, child)
end

function add!(parent::GtkWidget, children::GtkWidget...)
    for child in children
        add!(parent, child)
    end
end

function add!(parent::GtkWidget, children::Union{Tuple, Vector})
    add!(parent, children...)
end

function add!(parent::GtkWidget, children::Function)
    add!(parent, children())
end

function value(slider::Union{GtkScale, GtkSpinButton})
    return GAccessor.value(GAccessor.adjustment(slider))
end

function setvalue!(slider::Union{GtkScale, GtkSpinButton}, value::Real)
    adj = GAccessor.adjustment(slider)
    set_gtk_property!(adj, :value, value)
end

function value(w::Union{Gtk.GtkSwitch, GtkToggleButton, GtkCheckButton})
    return getprop(w, :active, Bool)
end

function setvalue!(w::Union{Gtk.GtkSwitch, GtkToggleButton, GtkCheckButton}, value::Bool)
    set!(w, :active, value)
end

function value(entry::GtkEntry)
    return bytestring(GAccessor.text(entry))
end

function value(cbtn::GtkColorButton)
    return convert(RGBA, getprop(cbtn, :rgba, Gtk.GdkRGBA))
end

function setvalue!(cbtn::GtkColorButton, color::Colorant)
    set!(cbtn, rgba = convert(GdkRGBA, color))
end