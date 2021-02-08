module Alexya

using Reexport, MacroTools
import Gtk

@reexport using Colors, Luxor

include("widgets.jl")

using .Widgets

include("utils.jl")
include("layout.jl")
include("canvas.jl")
include("events.jl")


export margin, @margin, map, Point

end # module
