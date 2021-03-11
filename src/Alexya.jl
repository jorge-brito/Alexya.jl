module Alexya

using Reexport

import Gtk

import Gtk: 
    GtkWidget,
    GtkContainer,
    GtkWindow, 
    resize!,
    GdkRGBA,
    GtkBox,
    GtkPaned,
    GtkCanvas,
    @guarded,
    draw,
    width,
    height,
    size,
    waitforsignal,
    getgc,
    destroy,
    GtkFrame,
    GtkGrid,
    GtkButton,
    GtkColorButton,
    GtkSwitch,
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

@reexport using Colors, Luxor, Dates

import Base: abs, +, -, *, /, ==, >, <, <=, >=, convert, length, getindex

include("utils.jl")
include("vector.jl")
include("gtk.jl")
include("helpers.jl")
include("layout.jl")
include("canvas.jl")
include("events.jl")
include("exports.jl")

export runexamples, waitforsignal

function runexamples()
    include(joinpath(@__DIR__, "..", "examples", "runexamples.jl"))
end

end