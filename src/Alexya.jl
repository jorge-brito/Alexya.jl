module Alexya

using Reexport, MacroTools
import Gtk

@reexport using Colors, Luxor

include("exports.jl")
include("utils.jl")
include("widgets.jl")
include("layout.jl")
include("canvas.jl")
include("events.jl")

end # module
