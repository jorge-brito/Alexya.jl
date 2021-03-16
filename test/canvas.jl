xoff = 0
yoff = 1000

@testset "Simple Canvas" begin
    init("Simple Canvas Test", 800, 600)

    @use function setup()
        @test 800 == @width()
        @test 600 == @height()

        @test (@window) isa GtkWindow
        @test (@canvas) isa GtkCanvas
    end
    
    @use function update()
        w, h = @width, @height

        background("black")
        sethue("white")
        x = noise(xoff) * w
        y = noise(yoff) * h
        circle(x, y, 16, :fill)

        fontsize(18)
        text("Framerate: $(@framerate) frames/s", Point(w/2, 20), halign = :center)
        text("Framecount: $(@framecount)", Point(w/2, 40), halign = :center)

        global xoff += 0.03
        global yoff += 0.03
    end

    start(async = true)
    destroy(@window)
end

@testset "Layout & Events" begin
    init("Layout Test", 800, 600)
    @layout aside(:v, 200)

    slider = @create Slider(1:100, @margin(10), @align(:center, :fill))
    entry = @create Entry(text = "Hello world", @margin(10))
    mousepos = Ref{Point}(O)

    onevent(() -> framerate(value(slider)), :value_changed, slider)

    @use function setup()
        @test 800 == @width()
        @test 600 == @height()

        @test (@window) isa GtkWindow
        @test (@canvas) isa GtkCanvas
    end

    @use function appclosed()
        # @test true == !false
        @info "App closed"
    end

    @use function mousemove(event)
        @info "Mouse move event" pos=event.pos
        mousepos[] = event.pos
    end

    @use function mousepress(event)
        @info "Mouse press event" pos=event.pos
    end

    @use function mouserelease(event)
        @info "Mouse release event" pos=event.pos
    end

    @use function mousemotion(event)
        @info "Mouse motion event" pos=event.pos
    end

    @use function keypress(event)
        @info "Key press event" key=event.keyval
    end
    
    @use function update()
        w, h = @width, @height
        background("black")
        sethue("white")
        x = noise(xoff) * w
        y = noise(yoff) * h
        circle(x, y, 16, :fill)
        
        sethue("#f1a")
        circle(mousepos[], 16, :fill)

        global xoff += 1 / value(slider)
        global yoff += 1 / value(slider)
        noLoop()
    end

    start()
    destroy(@window)
end

@testset "Sprites" begin
    @init "Sprite test" 800 600

    sprite = loadsprite(joinpath(@__DIR__, "sprite.png"))
    
    @use function setup()
        @info "Sprite loaded" sprite=sprite
        @test sprite isa SpriteImage
    end

    @use function update()
        background("black")
        w, h = @width, @height
        drawsprite(sprite, Point(w/2, h/2), 400:400, centered = true)
        noLoop()
    end

    start()
    destroy(@window)
end