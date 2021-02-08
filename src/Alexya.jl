module Alexya

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
    @eval Base.Experimental.@optlevel 1
end

using Reexport, MacroTools
import Gtk

@reexport using Colors, Luxor

include("exports.jl")
include("utils.jl")
include("widgets.jl")
include("layout.jl")
include("canvas.jl")
include("events.jl")

if Base.VERSION >= v"1.4.2"
    include("precompile.jl")
    _precompile_()
end

end # module
