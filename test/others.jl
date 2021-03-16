@testset "Vector" begin
    i = [1, 0, 0]
    j = [0, 1, 0]
    k = [0, 0, 1]

    @test i.x == 1
    @test i.y == 0
    @test i.z == 0
    @test_throws ErrorException i.w == 0

    @test j.x == 0
    @test j.y == 1
    @test j.z == 0
    @test_throws ErrorException j.w == 0

    @test k.x == 0
    @test k.y == 0
    @test k.z == 1
    @test_throws ErrorException k.w == 0
    
    v = 2i + 3j - 4k
    @test v.x == 2
    @test v.y == 3
    @test v.z == -4
    @test_throws ErrorException v.w == 0

    @test_throws AssertionError v.u == 0

    extend!(v)
    @test v.w == 0
    @test mag(v) == √(2^2 + 3^2 + (-4)^2)

    u = withangle(π, 2)
    @test u == 2 * [cos(π), sin(π)]
    @test angle(u) ≈ π

    u = withangle(π/2, abs(u))
    @test u == 2 * [cos(π/2), sin(π/2)]
    @test angle(u) == π/2

    l = [1, 1]
    @test limit(l, 1) == l / √2
end


@testset "Math" begin
    @test point([1, 2]) == Point(1, 2)

    for N in 0:10
        @test 0 <= random(N) <= N
    end

    for n in 0:10
        @test mapr(n, [0 10; 0 1]) == n / 10
        @test (n ⟶ [0 10; 0 5]) == mapr(n, [0 10; 0 5])
    end
end

@testset "SVG Path" begin
    path = "M 10 10 H 20 V 30 L 50 50 Z"

    points = getpoints(path)

    @test points == [
        Point(10, 10),
        Point(10, 20),
        Point(30, 20),
        Point(50, 50),
        Point(10, 10)
    ]
end
