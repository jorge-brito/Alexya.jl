@testset "Utils" begin
    v = [3, 4]
    @test point(v) == Point(3, 4)
    @test abs(v) == 5.0
    
    @test mapr(0:10, 0:1) isa Function
    @test mapr(1, 0:10, 0:1) == 0.1
    @test (1 ↦ (0:10, 0:1)) == 0.1

    c = Gtk.GdkRGBA(1, 0, 1, 1)
    @test convert(ColorAlpha, c) isa RGBA
    @test convert(Color, c) isa RGB
    @test convert(Gtk.GdkRGBA, colorant"rgba(1, 1, 1, 0.5)") isa Gtk.GdkRGBA
end