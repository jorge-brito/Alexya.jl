using Alexya
using Test

@testset "Layout overlay" begin
    
createCanvas(800, 600, Layout{:overlay})

draw!() do w, h
    @test w == 800
    @test h == 600
    noloop!()
end

loop!()

end

# TODO: Write more tests