@testset "Canvas" begin
    canvas = Canvas()
    win = Window(canvas, 800, 600; title = "Canvas test")
    app = DrawingApp(win, canvas; framerate = 60)

    @test canvas isa Alexya.GtkCanvas

    function setup(w, h)
        @test w == 800
        @test h == 600
        println("Starting...")
    end

    function draw(w, h)
        background("black")
        sethue("white")
        x, y = rand(0:w), rand(0:h)
        circle(x, y, 10, :fill)
    end

    loop!(app, setup, draw)
end

@testset "Global canvas" begin
    createCanvas(800, 600; title = "Canvas Test")

    @add slider = Slider(1:100; vexpand = false, @hexpand, @margin(5, 10))
    @add Label("Hello")
    @add Button("Ok")

    function setup(w, h)
        @test slider isa Alexya.GtkScale
        @test w == 800
        @test h == 600
        println("Starting...")
    end

    function draw(w, h)
        background("black")
        sethue("white")
        x, y = rand(0:w), rand(0:h)
        circle(x, y, value(slider), :fill)
    end

    loop!(setup, draw)
end

@testset "Canvas layout" begin
    uselayout(HPanels{120})
    createCanvas(800, 600; title = "Canvas Test")

    @add slider = Slider(1:100; @hexpand)
    @add Label("Hello")
    @add Button("Ok")

    function setup(w, h)
        @test slider isa Alexya.GtkScale
        @test w == 800
        @test h == 600
        println("Starting...")
    end

    function draw(w, h)
        background("black")
        sethue("white")
        x, y = rand(0:w), rand(0:h)
        circle(x, y, value(slider), :fill)
    end

    loop!(setup, draw)
end

global mousepos = [0, 0]
global lastmousepos = mousepos
global radius = 5

@testset "Events" begin
    createCanvas(800, 600)

    function update(args...)
        background("black")
        sethue("white")
        circle(point(mousepos), radius, :fill)
    end

    onmousemotion!(0) do w, event
        global mousepos = [event.x, event.y]
    end

    onmousemotion!(1) do w, event
        global radius = abs([event.x, event.y] - lastmousepos)
    end

    for n in 1:3
        onclick!(n) do w, event
            println("Mouse $n pressed!")
            if n == 1
                global lastmousepos = [event.x, event.y]
            end
        end
    
        onclicked!(n) do w, event
            println("Mouse $n released!")
        end
    end

    onkeypress!() do w, event
        println("Key $(event.keyval) pressed!")
    end

    onkeyrelease!() do w, event
        @show event.keyval == key("w")
        println("Key $(event.keyval) released!")
    end

    loop!(update)
end