module GraphingCalculator

using Alexya, Luxor

@init "Graphing Calculator" 800 600

@layout aside(:v, 250)

curves = Vector{Point}()

@create @options begin
    variables = (
        a = (-10:.1:10, 1),
        b = (-10:.1:10, 1),
        c = (-10:.1:10, 1)
    )

    input = @nolabel "f(x) = a*cos(x) + b*sin(c*x)"

    settings = (
        zoom = (1:300, 100),
        x_min = (-50, -100:-1),
        x_max = (50, 1:100),
        points = (10:300, 300)
    )

    style = (
        color = colorant"yellowgreen",
        line_width = (1, 1:10)
    )

    actions = @nolabel (
        plot = Button("Plot", @hexpand),
        delete = Button("Delete", @hexpand, onclicked = () -> empty!(curves))
    )
end

function eventplot()
    ex = Meta.parse(input[])
    block = last(ex.args)

    @eval begin
        $ex
        plot() do x
            a, b, c = getindex.($variables)
            return $block
        end
    end
end

onevent(eventplot, :clicked, actions.plot)

function plot(f::Function)
    global curves = [Point[]]
    i = 1
    xmin = settings.x_min[]
    xmax = settings.x_max[]
    N = settings.points[]
    Δx = (xmax - xmin)/N
    for x in xmin:Δx:xmax
        local segment = curves[i]
        try
            y = -f(x)
            isinf(y) && throw(DivideError())
            push!(segment, Point(x, f(x)))
        catch e
            if !isempty(segment)
                i += 1
                push!(curves, Point[])
            end
        end
    end
end

@use function setup()
    for (key, option) in pairs(settings)
        key ≠ :zoom && onevent(:value_changed, option) do 
            eventplot()
        end
    end

    for option in variables
        onevent(eventplot, :value_changed, option)
    end

    eventplot()
end

@use function update(Δt)
    background("black")
    origin()
    scale(settings.zoom[]/10)
    drawaxis()
    sethue(style.color[])
    setline(style.line_width[])
    setopacity(1)
    for curve in filter(c -> length(c) > 0, curves)
        poly(simplify(curve), :stroke)
    end
end

function drawaxis()
    w, h = @width, @height
    sethue("white")
    setline(1)
    setopacity(1)
    fontsize(0.85)

    line(Point(0, -h/2), Point(0, h/2), :stroke)
    line(Point(-w/2, 0), Point(w/2, 0), :stroke)

    xmin = settings.x_min[]
    xmax = settings.x_max[]
    
    for y in -h÷2:5:h÷2
        y == 0 && continue
        line( Point(-0.5, y), Point(0.5, y), :stroke )
        label(string(-y), :W, Point(0, y); offset = 1)
        setopacity(.1)
        line( Point(xmin, y), Point(xmax, y), :stroke) 
    end

    for x in floor.(Int, [xmin:5:xmax...])
        align = x == 0 ? :SW : :S
        line( Point(x, -0.5), Point(x, 0.5), :stroke )
        label(string(x), align, Point(x, 0); offset = 1)
        setopacity(.1)
        line( Point(x, -h/2), Point(x, h/2), :stroke) 
    end
end

start()

end