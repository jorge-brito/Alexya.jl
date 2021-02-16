@testset "Utils" begin
    v = [3, 4]
    @test point(v) == Point(3, 4)
    @test abs(v) == 5.0
    
    @test mapr(0:10, 0:1) isa Function
    @test mapr(1, 0:10, 0:1) == 0.1
    @test (1 ↦ (0:10, 0:1)) == 0.1
end