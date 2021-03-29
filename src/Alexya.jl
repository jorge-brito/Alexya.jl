module Alexya

using Reexport

@reexport using Colors, Luxor

import Base: convert, length, getindex, get
import Gtk, Luxor.Cairo

import Gtk: GtkScale,
    GtkButton,
    GtkLabel,
    GtkEntry,
    GtkSpinButton,
    GtkExpander,
    GtkSpinner,
    GtkTextView,
    GtkStatusbar,
    GtkSwitch,
    GtkLinkButton,
    GtkFontButton,
    GtkAppChooser,
    GtkColorButton,
    GtkProgressBar,
    GtkFileChooser,
    GtkCheckButton,
    GtkToggleButton,
    GtkComboBoxText,
    GtkVolumeButton,
    GtkCanvas,
    GtkBox,
    GtkGrid,
    GtkFrame,
    GtkPaned,
    GtkWindow,
    GtkMenuBar,
    GtkToolbar,
    GtkTreeView,
    GtkNotebook,
    GtkScrolledWindow,
    CssProvider,
    GtkWidget,
    GdkRGBA,
    GConstants,
    GtkAlign,
    set_gtk_property!,
    get_gtk_property,
    signal_connect,
    signal_handler_disconnect,
    bytestring,
    show, showall,
    destroy,
    GAccessor,
    width, height

include("exports.jl")
include("utils.jl")
include("vector.jl")
include("math.jl")
include("gtk.jl")
include("widgets.jl")
include("grid.jl")
include("events.jl")
include("app.jl")
include("layout.jl")
include("svg.jl")
include("sprites.jl")
include("controls.jl")

function runexamples()
    include(joinpath(@__DIR__, "..", "examples", "runexamples.jl"))
end

export runexamples, GtkAlign

if VERSION >= v"1.1"   # work around https://github.com/JuliaLang/julia/issues/34121
    include("precompile.jl")
    _precompile_()
end

end