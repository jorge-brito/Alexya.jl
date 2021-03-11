@testset "Vector basics" begin
    v = Vec(3, 4)
    @test v isa Vec
    @test v.x == 3 && v.y == 4
    @test v == Vec(3, 4)
    @test v != Vec(1, 2)
    @test v >  Vec(2, 2)
    @test v <  Vec(6, 8)
    @test v >= Vec(3, -4)
    @test v <= Vec(-3, 4)

    @test abs(v) == 5.0
    @test length(v) == 2
    @test v[1] == 3 && v[2] == 4
    @test convert(Vec, [3, 4]) == v
    @test convert(Vector{<:Real}, v) == [3.0, 4.0]
    @test convert(Vec, Point(3, 4)) == v
    @test convert(Point, v) == Point(3, 4)
    @test point(v) == Point(3, 4)
end

@testset "Vector operations" begin
    v = 3î + 4ĵ
    w = -î + 2ĵ
    @test v == Vec(3, 4)
    @test w == Vec(-1, 2)

    @test v + w == Vec(2, 6)
    @test v - w == Vec(4, 2)
    @test v * w == 5
    @test 2v == Vec(6, 8)
    @test v/2 == Vec(1.5, 2)
end

@testset "Vector functions" begin
    @test rotm2d(π/2) * î == Vec(cos(π/2), 1)
    v = withangle(π)
    @test v == Vec(-1, sin(π))
    @test rot(v, -π/2) == Vec(cos(π/2), 1)
    @test normalize(î + ĵ) == (î + ĵ) / abs(î + ĵ)
    @test withmag(î, 2) == Vec(2, 0)
end