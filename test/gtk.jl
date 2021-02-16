@testset "Window" begin
    win = Window(800, 600; title = "Window Test")

    @test win isa Alexya.GtkWindow
    @test getprop(win, :title, String) == "Window Test"

    show(win)

    Alexya.destroy(win)
end

@testset "Props" begin
    box = Box(:h; spacing = 10)
    @test getprop(box, :spacing, Int) == 10

    set!(box, :spacing, 5)
    @test getprop(box, :spacing, Int) == 5

    set!(box, (spacing = 8))
    @test getprop(box, :spacing, Int) == 8

    set!(box, @margin(10), @hexpand, @vexpand)
    
    for m in ["top", "bottom", "right", "left"]
        @eval @test getprop($box, "margin-$($m)", Int) == 10
    end

    @test getprop(box, :hexpand, Bool) == true
    @test getprop(box, :vexpand, Bool) == true

    Alexya.destroy(box)
end

@testset "Grid" begin
    win = Window(800, 600; title = "Grid Test")
    grid = Grid([ Button("row $i, column $j") for i=1:2, j=1:2 ], @columnhg, @rowhg)

    @test getprop(grid, "column-homogeneous", Bool) == true
    @test getprop(grid, "row-homogeneous", Bool) == true

    add!(win, grid)
    showall(win)

    c = Condition()
    on!(:destroy, win) do w
        notify(c)
    end
    wait(c)
end

@testset "Grid with Span cells" begin
    win = Window(800, 600; title = "Grid with Span cells Test")
    grid = Grid(@columnhg, @rowhg) do
    GridCell[ 
        Button(".") → 2 ""              Button(".")    
        Button(".")     Button(".") ↓ 3 Button(".") ↓ 2
        Button(".")     ""              ""             
        Button(".")     ""              Button(".")    
    ]
    end

    @test getprop(grid, "column-homogeneous", Bool) == true
    @test getprop(grid, "row-homogeneous", Bool) == true

    add!(win, grid)
    showall(win)

    c = Condition()
    on!(:destroy, win) do w
        notify(c)
    end
    wait(c)
end

@testset "Grid Macro" begin
    win = Window(800, 600; title = "Grid Macro Test")
    grid = @grid [ 
        Button(".") → 2 ""              Button(".")    
        Button(".")     Button(".") ↓ 3 Button(".") ↓ 2
        Button(".")     ""              ""             
        Button(".")     ""              Button(".")    
    ] row_homogeneous = true column_homogeneous = true

    @test getprop(grid, "column-homogeneous", Bool) == true
    @test getprop(grid, "row-homogeneous", Bool) == true

    add!(win, grid)
    showall(win)

    c = Condition()
    on!(:destroy, win) do w
        notify(c)
    end
    wait(c)
end

@testset "Events" begin
    btn = Button("Hello")
    @test btn isa Alexya.GtkButton

    id = on!(:clicked, btn) do w
        println("clicked!")
    end

    @test id isa UInt64
    @test Alexya.signal_handler_is_connected(btn, id) == true

    off!(btn, id)
    @test Alexya.signal_handler_is_connected(btn, id) == false
    Alexya.destroy(btn)
end

@testset "Widgets" begin
    @test Label(:Hello) isa Alexya.GtkLabel
    @test label"Ok then" isa Alexya.GtkLabel
    @test Slider(1:50) isa Alexya.GtkScale
    @test Entry("I'm just a regular every day normal **") isa Alexya.GtkEntry
    @test Paned(:v) isa Alexya.GtkPaned
end
