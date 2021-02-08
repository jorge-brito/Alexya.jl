mutable struct AlCanvas
    widget::Gtk.GtkCanvas
    framerate::Real
    loop::Bool
    draw::Function
    setup::Function

    function AlCanvas(width::Int = -1, height::Int = -1; framerate = 60)
        w = Canvas(width, height)
        return new(w, framerate, true)
    end
end

Base.show(io::IO, alc::AlCanvas) = write(io, "AlCanvas(loop = $(alc.loop), draw = $(isdefined(alc, :draw)))\n")

function loop!(alc::AlCanvas)
    @assert isdefined(alc, :draw) "Canvas must have a draw function."

    function draw(wg)
        w, h = Gtk.width(wg), Gtk.height(wg)
        d = Drawing(w, h, :image)
        d.cr = Gtk.getgc(wg)
        alc.draw(w, h)
        finish()
    end
    
    Gtk.@guarded Gtk.draw(alc.widget) do wg
        w, h = Gtk.width(wg), Gtk.height(wg)
        if !isdefined(alc, :setup)
            @info "Starting without setup function."
        else
            if hasmethod(alc.setup, Tuple{Int, Int})
                alc.setup(w, h)
            else
                alc.setup()
            end
        end
        Gtk.draw(draw, alc.widget)
    end
    while alc.loop
        try
            Gtk.draw(alc.widget)
            sleep(inv(alc.framerate))
        catch e
            alc.loop = false
            @error "Error in drawing loop!" exception=e
            Base.show_backtrace(stderr, catch_backtrace())
            break
        end
    end
end

function noloop!(alc::AlCanvas)
    alc.loop = false
end

function width(alc::AlCanvas)
    Gtk.width(alc.widget)
end

function height(alc::AlCanvas)
    Gtk.height(alc.widget)
end

function framerate!(alc::AlCanvas, fr::Real)
    alc.framerate = fr
end

function setup!(callback::Function, alc::AlCanvas)
    alc.setup = callback
end

function draw!(callback::Function, alc::AlCanvas)
    if hasmethod(callback, Tuple{Real, Real})
        alc.draw = callback
    else
        alc.draw = (w, h) -> callback()
    end
end

const CURRENT_APP = Array{Dict, 1}()

function get_current_app()
    try
        CURRENT_APP[1]
    catch
        error("There is no current app!")
    end
end

get_current_canvas()    = get(get_current_app(), :canvas    , missing)
get_current_window()    = get(get_current_app(), :window    , missing)
get_current_container() = get(get_current_app(), :container , missing)

function createCanvas(width::Int = 400, height::Int = 400, layout = Layout{:overlay}; title = "My Canvas")
    canvas = AlCanvas()       
    body, container = layout_rule(layout, canvas.widget)
    window = Window([body], title, width, height)
    app = dict(; canvas, window, container)

    if isempty(CURRENT_APP)
        push!(CURRENT_APP, app)
    else
        CURRENT_APP[1] = app
    end
end

draw!(callback::Function)  = draw!(callback, get_current_canvas())
setup!(callback::Function) = setup!(callback, get_current_canvas())
noloop!()                  = noloop!(get_current_canvas())
framerate!(fr::Real)       = framerate!(get_current_canvas(), fr)
width()                    = width(get_current_canvas())
height()                   = height(get_current_canvas())

function loop!(; async::Bool = false)
    canvas = get_current_canvas()
    win = get_current_window()

    Gtk.showall(win)

    on(:destroy, win) do args...
        noloop!(canvas)
    end

    if async
        @async loop!(canvas)
    else
        loop!(canvas)
    end
end

function add(w::Gtk.GtkWidget)
    container = get_current_container()
    push!(container, w)
    return w
end

macro add(expr)
    if @capture(expr, name_ = w__)
        esc(:( $name = add($(first(w))) ))
    else
        :( add($(esc(expr))) )
    end
end

macro width()
    esc(:( width() ))
end

macro height()
    esc(:( height() ))
end