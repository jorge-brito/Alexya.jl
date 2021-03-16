@testset "Widgets" begin
    entry = Entry(text = "Foo")
    @test entry isa GtkEntry

    set!(entry, text = "Hello")
    @test getprop(entry, :text, String) == "Hello"
    
    set!(entry, text = "Ok")
    @test getprop(entry, :text, String) == "Ok"
    
    @test Label("Foo")              isa GtkLabel
    @test ProgressBar()             isa GtkProgressBar
    @test Scale(true, 0:10)         isa GtkScale
    @test Slider(0:10, init = 5)    isa GtkScale
    @test SpinButton(0:10)          isa GtkSpinButton
    @test Spinner()                 isa GtkSpinner
    @test Switch(true)              isa Gtk.GtkSwitch
    
    color_btn =  ColorButton()
    @test color_btn isa GtkColorButton

    set!(color_btn, rgba = colorant"#f1a")
    @test value(color_btn) == RGBA(colorant"#f1a")
end

@testset "Containers" begin
    win = Window("Window", 800, 600) do 
        Box(:v) do 
            Frame("Hello") do 
                Paned(:h) do 
                    # Expander(())
                    Box(:v) do
                        button"Hello",
                        SpinButton(1:100),
                        colorbtn"#1af"
                    end, # Box
                    Box(:v) do 
                        entry"World!",
                        Slider(-10:10, @hexpand),
                        label"Ok"
                    end # Box
                end # Paned
            end # Frame
        end # Box
    end # Window

    showall(win)
    destroy(win)
end

@testset "Events" begin
    i = Ref{Int}(0)
    slider = Slider(1:50,       @on value changed () -> i[] += 1)
    spin = SpinButton(0:1000,   @on value changed () -> i[] += 1)
    entry = Entry(text = "Ok",  @on changed () -> i[] += 1)
    btn = Button("Click-me!",   @on clicked () -> println("Button was clicked!"))
    checkbox = CheckBox(        @on clicked () -> println("CheckBox was clicked!"))
    switch = Switch(true)
    cbtn = ColorButton()

    @test i[] == 3

    onevent(:state_set, switch) do 
        # error test
        @test_throws UndefVarError println(ok)
    end

    set!(switch, active = false)

    onevent(:clicked, cbtn) do 
        println("Color Button value changed!")
    end

    win = Window("Event test", 800, 600) do 
        Box(:v, @margin(20), spacing = 10) do 
            slider,
            spin,
            btn,
            entry,
            checkbox,
            switch,
            cbtn
        end
    end

    showall(win)
    destroy(win)
end

@testset "Prop Helpers" begin
    value = 10
    box = Box((), :h, @margin(value), @hexpand, @vexpand(false), @align(:center, :fill))

    for m in [:top, :right, :bottom, :left]
        @test getprop(box, "margin-$m", Int) == value
    end

    set!(box, @margin(value, 2value))

    @test getprop(box, "margin-top", Int) == value
    @test getprop(box, "margin-bottom", Int) == value

    @test getprop(box, "margin-left", Int) == 2value
    @test getprop(box, "margin-right", Int) == 2value

    @test getprop(box, :valign, UInt32) == GtkAlign.CENTER
    @test getprop(box, :halign, UInt32) == GtkAlign.FILL

    @test getprop(box, :hexpand, Bool) == true
    @test getprop(box, :vexpand, Bool) == false
end
