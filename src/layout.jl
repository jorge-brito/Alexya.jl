function nolayout(width::Int, height::Int, title::String, canvas::GtkCanvas)
    return Window(width, height; title) do 
        canvas
    end,
    function(child::T) where T <: GtkWidget
        @warn """
        
        Attempt to add widget of type $T but no layout is being used.
        If you want to use other widgets with the canvas call the `uselayout!` 
        function (or the @layout macro) and pass a layout. Example:

                `@layout aside(type = :horizontal)`
            
        You can also implement your own layouts.

        """
    end
end

function aside(::Val{:vertical}, size::Int, reverse::Bool)
    return function(width::Int, height::Int, title::String, canvas::GtkCanvas)
        box = Box(:v; @margin(20, 10))
        Window(width + size, height; title) do 
            Paned(:h; position = width) do 
                if reverse
                    return box, canvas
                else
                    return canvas, box
                end
            end # Paned
        end, # Window
        (child) -> add!(box, child)
    end
end

aside(::Val{:v}, args...) = aside(Val(:vertical), args...)

function aside(::Val{:horizontal}, size::Int, reverse::Bool)
    return function(width::Int, height::Int, title::String, canvas::GtkCanvas)
        box = Box(:h; @margin(20, 10))
        Window(width, height + size; title) do 
            Paned(:v; position = height) do 
                if reverse
                    return box, canvas
                else
                    return canvas, box
                end
            end # Paned
        end, # Window
        (child) -> add!(box, child)
    end
end

aside(::Val{:h}, args...) = aside(Val(:horizontal), args...)

function aside(size::Int = 130, type::Symbol = :vertical, reverse::Bool = false)
    aside(Val(type), size, reverse)
end

const CURRENT_LAYOUT = Function[nolayout]

function uselayout!(layout::Function)
    CURRENT_LAYOUT[1] = layout
end

function create(w::T) where T <: GtkWidget
    app = get_current_app()
    app.add(w)
    return w
end

macro create(ex)
    :( create($(esc(ex))) )
end

macro layout(layout)
    :( uselayout!($(esc(layout))) )
end