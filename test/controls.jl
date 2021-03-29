# using Alexya

@testset "Controls" begin

widgets = (
    inspect = Button("Inspect", @hexpand),
    close = Button("Close", @hexpand)
)

inputs = (
    text_field = "Lorem ipsum dolor",
    number = 10,
    δ = (10, -50:50)
)

numbers = (
    complex = 3 + 4im,
    point = Point(-5, 5)
)

others = (
    slider = -20:20,
    φ = (-100:100, 50),
    color = colorant"#000",
    switch = true
)

options = Controls(
    widgets = widgets,
    inputs = inputs,
    numbers = numbers,
    others = others
)

onevent(:clicked, options.widgets.inspect) do 
    @show options
end

app = Window("Controsl test", 400, 800) do 
    ScrolledWindow() do 
        options
    end
end

showall(app)

@test options.widgets.inspect[]     == widgets.inspect
@test options.widgets.close[]       == widgets.close
@test options.inputs.text_field[]   == inputs.text_field
@test options.inputs.number[]       == inputs.number
@test options.inputs.δ[]            == 10.0
@test options.numbers.complex[]     == numbers.complex
@test options.numbers.point[]       == numbers.point
@test options.others.slider[]       == 0.0
@test options.others.φ[]            == 50.0
@test options.others.color[]        == convert(RGBA, others.color)
@test options.others.switch[]       == others.switch

options.inputs.text_field[] = "Okay"
options.inputs.number[] = 5
options.inputs.δ[] = 10
options.numbers.complex[] = 3.14 + 1im
options.numbers.point[] = Point(10, 10)
options.others.slider[] = -9/2
options.others.φ[] = -1/12
options.others.color[] = colorant"#fff" 
options.others.switch[] = false

@test options.inputs.text_field[]   == "Okay"
@test options.inputs.number[]       == 5
@test options.inputs.δ[]            == 10
@test options.numbers.complex[]     == 3.14 + 1im
@test options.numbers.point[]       == Point(10, 10)
@test options.others.slider[]       == -9/2
@test options.others.φ[]            == -1/12
@test options.others.color[]        == RGBA(colorant"#fff") 
@test options.others.switch[]       == false

destroy(app)

end # testset

@testset "Options Macro" begin

@init "Options test" 400 800

@layout aside(:v, 250)

options = @create @options begin
    widgets = (
        inspect = Button("Inspect", @hexpand),
        close = Button("Close", @hexpand)
    )

    inputs = (
        text_field = "Lorem ipsum dolor",
        number = 10,
        δ = (10, -50:50)
    )

    numbers = (
        complex = 3 + 4im,
        point = Point(-5, 5)
    )

    others = (
        slider = -20:20,
        φ = (-100:100, 50),
        color = colorant"#000",
        switch = true
    )
end

@use function setup()
    #@show options
    noLoop()
end

@test inputs.text_field[]   == "Lorem ipsum dolor"
@test inputs.number[]       == 10.0
@test inputs.δ[]            == 10.0
@test numbers.complex[]     == 3 + 4im
@test numbers.point[]       == Point(-5, 5)
@test others.slider[]       == 0.0
@test others.φ[]            == 50.0
@test others.color[]        == RGBA(0, 0, 0, 1)
@test others.switch[]       == true

start()

end # testset