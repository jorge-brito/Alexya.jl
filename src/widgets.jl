const AbstractStringLike = Union{AbstractString, Symbol}

const Children = Union{Gtk.GtkWidget, AbstractStringLike, AbstractArray, Tuple, Function}

function on(handler::Function, type::AbstractStringLike, w::Gtk.GtkWidget)
    Gtk.signal_connect(handler, w, type)
end

function off(w::Gtk.GtkWidget, id::UInt64)
    Gtk.signal_handler_disconnect(w, id)
end

function set!(w::Gtk.GtkWidget, name::AbstractStringLike, value::T) where {T}
    Gtk.set_gtk_property!(w, dashcase(name), value)
end

function set!(w::Gtk.GtkWidget, name::AbstractStringLike, value::Dict)
    for (key, val) in value
        set!(w, "$name-$key", val)
    end
end

function set!(w::Gtk.GtkWidget, name::AbstractStringLike, value::NamedTuple)
    set!(w, name, Dict(pairs(value)))
end

function set!(w::Gtk.GtkWidget, name::AbstractStringLike, value::Function)
    if startswith(string(name), "on")
        type = dashcase(string(name)[3:end])
        on(value, type, w)
    else
        set!(w, name, value)
    end
end

function set!(w::Gtk.GtkWidget; props...)
    for (name, prop) in props
        set!(w, name, prop)
    end
end

function getprop(w::Gtk.GtkWidget, prop::AbstractStringLike)
    Gtk.get_gtk_property(w, prop)
end

function getprop(w::Gtk.GtkWidget, prop::AbstractStringLike, ::Type{T}) where {T}
    Gtk.get_gtk_property(w, prop, T)
end

function widget(w::Gtk.GtkWidget; props...)
    if length(props) > 0
        set!(w; props...)
    end
    return w
end

function widget(w::Gtk.GtkWidget, children::Tuple; props...)
    w = widget(w; props...)

    if !ismissing(children)
        for child in filter(!ismissing, collect(children))
            Gtk.push!(w, child)
        end
    end

    return w
end

function widget(w::Gtk.GtkWidget, children::Function; props...)
    widget(w, children(); props...)
end

function widget(w::Gtk.GtkWidget, children::AbstractArray; props...)
    widget(w, tuple(children...); props...)
end

function widget(w::Gtk.GtkWidget, children::AbstractStringLike; props...)
    widget(w, [string(children)]; props...)
end

function widget(w::Gtk.GtkWidget, children::Gtk.GtkWidget; props...)
    widget(w, [children]; props...)
end

macro widget(expr)
    if @capture(expr, name_ <: w_[]) # @widget MyWidget <: GtkWidget[] == container widget.
        quote
            function $name(children::Children, args...; props...)
                w = $w(args...)
                return widget(w, children; props...)
            end
        end |> esc
    elseif @capture(expr, name_ <: w_) # @widget MyWidget <: GtkWidget == non-container widget.
        quote
            function $name(args...; props...)
                w = $w(args...)
                return widget(w; props...)
            end
        end |> esc
    else
        error("Wrong use of @widget macro.")
    end
end

@widget Canvas             <: Gtk.GtkCanvas
@widget ComboBoxText       <: Gtk.GtkComboBoxText
@widget Alignment          <: Gtk.GtkAlignment[]
@widget AspectFrame        <: Gtk.GtkAspectFrame[]
@widget Button             <: Gtk.GtkButton[]
@widget CheckButton        <: Gtk.GtkCheckButton[]
@widget Expander           <: Gtk.GtkExpander[]
@widget EventBox           <: Gtk.GtkEventBox[]
@widget Frame              <: Gtk.GtkFrame[]
@widget LinkButton         <: Gtk.GtkLinkButton[]
@widget RadioButton        <: Gtk.GtkRadioButton[]
@widget ToggleButton       <: Gtk.GtkToggleButton[]
@widget VolumeButton       <: Gtk.GtkVolumeButton[]
@widget Window             <: Gtk.GtkWindow[]
@widget Dialog             <: Gtk.GtkDialog[]
@widget FileChooserDialog  <: Gtk.GtkFileChooserDialog[]
@widget Box                <: Gtk.GtkBox[]
@widget ButtonBox          <: Gtk.GtkButtonBox[]
@widget Statusbar          <: Gtk.GtkStatusbar[]
@widget Grid               <: Gtk.GtkGrid[]
@widget Layoutc            <: Gtk.GtkLayout[]
@widget Notebook           <: Gtk.GtkNotebook[]
@widget NullContainer      <: Gtk.GtkNullContainer
@widget Overlay            <: Gtk.GtkOverlay[]
@widget Paned              <: Gtk.GtkPaned[]
@widget RadioButtonGroup   <: Gtk.GtkRadioButtonGroup[]
@widget TableWidget        <: Gtk.GtkTable[]
@widget Entry              <: Gtk.GtkEntry
@widget Image              <: Gtk.GtkImage
@widget Label              <: Gtk.GtkLabel
@widget ProgressBar        <: Gtk.GtkProgressBar
@widget Scale              <: Gtk.GtkScale
@widget SpinButton         <: Gtk.GtkSpinButton
@widget Spinner            <: Gtk.GtkSpinner
@widget Switch             <: Gtk.Gtk.GtkSwitch
@widget TextView           <: Gtk.GtkTextView
@widget FileChooserNative  <: Gtk.GtkFileChooserNative

function value(s::Gtk.GtkScale)
    Gtk.GAccessor.value(Gtk.GAccessor.adjustment(s))
end

function value!(s::Gtk.GtkScale, v::Real)
    Gtk.set_gtk_property!(Gtk.GAccessor.adjustment(s), :value, v)
end

function value(s::Gtk.GtkEntry)
    Gtk.bytestring(Gtk.GAccessor.text(s))
end

function value(s::Union{Gtk.GtkSwitch, Gtk.GtkCheckButton, Gtk.GtkRadioButton})
    Gtk.GAccessor.active(s)
end

function value(s::Gtk.GtkComboBoxText)
    Gtk.Gtk.bytestring(Gtk.GAccessor.active(s))
end

function Slider(r::AbstractRange; start = missing, props...)
    s = Scale(false, r; props...)
    start isa Real && value!(s, start)
    return s
end