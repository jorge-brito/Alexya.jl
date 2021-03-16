module Alexya

using Reexport


@reexport using Colors, Luxor, LinearAlgebra

import Base: convert, length, getindex, get
import LinearAlgebra: rotate!
import Gtk, Luxor.Cairo

import Gtk: GtkScale,
    GtkButton,
    GtkLabel,
    GtkEntry,
    GtkSpinButton,
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
    GtkFrame,
    GtkPaned,
    GtkWindow,
    GtkMenuBar,
    GtkToolbar,
    GtkTreeView,
    GtkNotebook,
    GtkScrolledWindow,
    GtkWidget,
    GdkRGBA,
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

function runexamples()
    include(joinpath(@__DIR__, "..", "examples", "runexamples.jl"))
end

export runexamples

end