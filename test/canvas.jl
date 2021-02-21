@testset "Canvas Test" begin
    canvas = Canvas()
    win = Window(canvas, 800, 600; title = "Canvas test")
    lf = Ref{DateTime}(now())

    @test canvas isa Alexya.GtkCanvas

    function draw(w, h)
        fps = getFPS!(lf) |> round
        background("black")
        sethue("white")
        x, y = rand(0:w), rand(0:h)
        circle(x, y, 10, :fill)
        fontsize(24)
        text("Current FPS is $fps frames/s", w/2, 40, halign=:center)
    end

    loop!(draw, win, canvas)
end

@testset "Create canvas" begin
    createCanvas(800, 600; title = "Create canvas")
    lf = Ref{DateTime}(now())

    radius = @create Slider(1:200; startat = 20)

    function setup(w, h)
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
    end

    onmousemotion!() do w, event
        global mousepos = Point(event.x, event.y)
    end

    loop!(setup, draw)
end