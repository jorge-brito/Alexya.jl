@testset "Canvas test" begin
    createCanvas(800, 600, title = "Canvas Test")

    function update(w, h)
        background("black")
        origin()
        sethue(RGB(rand(Float64, 3)...))
        circle(O, 100, :fill)
        dontloop!()
    end

    loop!(update)
end

@testset "Create canvas" begin
    createCanvas(800, 600; title = "Create canvas")
    lf = Ref{DateTime}(now())

    radius = @create Slider(1:200; startat = 20)

    function setup(w, h)
        @test w == 800
        @test h == 600
        println("Creating canvas with width of $w and height of $h")
    end

    function draw(w, h)
        fps = getFPS!(lf) |> round
        background("black")
        sethue("white")
        x, y = rand(0:w), rand(0:h)
        circle(x, y, 10, :fill)
        fontsize(24)
        text("Current FPS is $fps frames/s", w/2, 40, halign=:center)
        dontloop!()
    end

    loop!(setup, draw)
end

mousepos = Point(0, 0)

@testset "Canvas with controls & events" begin
    @layout aside()
    createCanvas(800, 600; title = "Canvas with controls & events")

    lf = Ref{DateTime}(now())
    radius = @create Slider(1:200; startat = 20)

    function setup(w, h)
        println("Creating canvas with width of $w and height of $h")
        global mousepos = Point(w/2, h/2)
    end

    function draw(w, h)
        fps = getFPS!(lf) |> round
        background("black")
        sethue("white")
        circle(mousepos, value(radius), :fill)
        fontsize(24)
        text("Current FPS is $fps frames/s", w/2, 40, halign=:center)
        dontloop!()
    end

    onmousemotion!() do w, event
        global mousepos = Point(event.x, event.y)
    end

    loop!(setup, draw)
end
