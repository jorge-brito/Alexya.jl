module Alexya

using Reexport

import Gtk

import Gtk: 
    GtkWidget,
    GtkContainer,
    GtkWindow, 
    resize!,
    GtkBox,
    GtkPaned,
    GtkCanvas,
    @guarded,
    draw,
    width,
    height,
    getgc,
    destroy,
    GtkFrame,
    GtkGrid,
    GtkButton,
    GtkColorButton,
    GtkScale,
    GtkEntry,
    GtkComboBoxText,
    GtkLabel,
    set_gtk_property!,
    push!,
    get_gtk_property,
    signal_connect,
    signal_handler_disconnect,
    signal_handler_is_connected,
    GAccessor,
    show,
    showall,
    GtkAlign,
    bytestring,
    GConstants

@reexport using Colors, Luxor

import Base: abs

include("utils.jl")
include("gtk.jl")
include("helpers.jl")
include("layout.jl")
include("canvas.jl")
include("events.jl")
include("exports.jl")

if VERSION >= v"1.1"   # work around https://github.com/JuliaLang/julia/issues/34121
    include("precompile.jl")
    _precompile_()
end

end