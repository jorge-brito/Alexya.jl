using Test, Alexya

@testset "Examples" begin
    include("../examples/basic.jl")
    include("../examples/wave.jl")
    include("../examples/fractal-tree.jl")
    include("../examples/raycasting.jl")
end


# TODO: Write more tests