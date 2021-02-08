module Widgets
include("utils.jl")

using Gtk, MacroTools

const AbstractStringLike = Union{AbstractString, Symbol}

const Children = Union{Gtk.GtkWidget, AbstractStringLike, AbstractArray, Tuple, Function}

function on(handler::Function, type::AbstractStringLike, w::Gtk.GtkWidget)
    signal_connect(handler, w, type)
end

function off(w::Gtk.GtkWidget, id::UInt64)
    signal_handler_disconnect(w, id)
end

function set!(w::Gtk.GtkWidget, name::AbstractStringLike, value::T) where {T}
    set_gtk_property!(w, dashcase(name), value)
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
    get_gtk_property(w, prop)
end

function getprop(w::Gtk.GtkWidget, prop::AbstractStringLike, ::Type{T}) where {T}
    get_gtk_property(w, prop, T)
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
            push!(w, child)
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

@widget Canvas             <: GtkCanvas
@widget ComboBoxText       <: GtkComboBoxText
@widget Alignment          <: GtkAlignment[]
@widget AspectFrame        <: GtkAspectFrame[]
@widget Button             <: GtkButton[]
@widget CheckButton        <: GtkCheckButton[]
@widget Expander           <: GtkExpander[]
@widget EventBox           <: GtkEventBox[]
@widget Frame              <: GtkFrame[]
@widget LinkButton         <: GtkLinkButton[]
@widget RadioButton        <: GtkRadioButton[]
@widget ToggleButton       <: GtkToggleButton[]
@widget VolumeButton       <: GtkVolumeButton[]
@widget Window             <: GtkWindow[]
@widget Dialog             <: GtkDialog[]
@widget FileChooserDialog  <: GtkFileChooserDialog[]
@widget Box                <: GtkBox[]
@widget ButtonBox          <: GtkButtonBox[]
@widget Statusbar          <: GtkStatusbar[]
@widget Grid               <: GtkGrid[]
@widget Layoutc           <: GtkLayout[]
@widget Notebook           <: GtkNotebook[]
@widget NullContainer      <: GtkNullContainer
@widget Overlay            <: GtkOverlay[]
@widget Paned              <: GtkPaned[]
@widget RadioButtonGroup   <: GtkRadioButtonGroup[]
@widget TableWidget        <: GtkTable[]
@widget Entry              <: GtkEntry
@widget Image              <: GtkImage
@widget Label              <: GtkLabel
@widget ProgressBar        <: GtkProgressBar
@widget Scale              <: GtkScale
@widget SpinButton         <: GtkSpinButton
@widget Spinner            <: GtkSpinner
@widget Switch             <: Gtk.GtkSwitch
@widget TextView           <: GtkTextView
@widget FileChooserNative  <: GtkFileChooserNative

function value(s::GtkScale)
    GAccessor.value(GAccessor.adjustment(s))
end

function value!(s::GtkScale, v::Real)
    set_gtk_property!(GAccessor.adjustment(s), :value, v)
end

function value(s::GtkEntry)
    Gtk.bytestring(GAccessor.text(s))
end

function value(s::Union{Gtk.GtkSwitch, GtkCheckButton, GtkRadioButton})
    GAccessor.active(s)
end

function value(s::GtkComboBoxText)
    Gtk.bytestring(GAccessor.active(s))
end

function Slider(r::AbstractRange; start = missing, props...)
    s = Scale(false, r; props...)
    start isa Real && value!(s, start)
    return s
end

export AbstractStringLike ,
       Children           ,
       set!               ,
       getprop            ,
       on                 ,
       off                ,
       @widget            ,
       showall            ,
       show               ,
       value

export Canvas             ,
       ComboBoxText       ,
       Alignment          ,
       AspectFrame        ,
       Button             ,
       CheckButton        ,
       EventBox           ,
       Expander           ,
       Frame              ,
       LinkButton         ,
       RadioButton        ,
       ToggleButton       ,
       VolumeButton       ,
       Window             ,
       Dialog             ,
       FileChooserDialog  ,
       Box                ,
       ButtonBox          ,
       Statusbar          ,
       Grid               ,
       Layoutc            ,
       Notebook           ,
       NullContainer      ,
       Overlay            ,
       Paned              ,
       RadioButtonGroup   ,
       TableWidget        ,
       Entry              ,
       Image              ,
       Label              ,
       ProgressBar        ,
       Scale              ,
       SpinButton         ,
       Spinner            ,
       Switch             ,
       TextView           ,
       FileChooserNative  ,
       Slider

end # module