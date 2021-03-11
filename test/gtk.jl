@testset "Window" begin
    app = Window(1366, 768; title = "Window test")
    show(app)
    Alexya.destroy(app)
end

@testset "Widgets" begin

    widgets = [
        Button(:foo)  => :GtkButton,
        Button("foo") => :GtkButton,
        Label(:foo)   => :GtkLabel,
        Label("foo")  => :GtkLabel,
        label"foo"    => :GtkLabel,
        Box(:h)       => :GtkBox,
        Paned(:v)     => :GtkPaned,
        Grid()        => :GtkGrid,
        Entry("foo")  => :GtkEntry,
        Slider(1:10)  => :GtkScale,
        Canvas()      => :GtkCanvas,
        ColorButton() => :GtkColorButton,
        Switch(true)  => :GtkSwitch,
        Window(1366, 768; title = "Widgets test") => :GtkWindow
    ]

    for (widget, type) in widgets
        @test widget isa getfield(Alexya, type)
    end

    Alexya.destroy.(first.(widgets))
end

@testset "Grid test" begin
    win = Window(1366, 768; title = "Widgets test")

    grid = Grid([
        Button(".") Button(".") Button(".")
        Button(".") → 2 ""      Button(".") ↓ 2
        ""              ""      ""
    ], @columnhg, @rowhg, @spacing(5))

    @test grid isa Alexya.GtkGrid
    @test getprop(grid, :row_spacing, Int) == 5
    @test getprop(grid, :column_spacing, Int) == 5

    add!(win, grid)
    showall(win)
    Alexya.destroy(win)
end