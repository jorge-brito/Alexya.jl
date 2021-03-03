# ----------------- ------------------------------------- -----------------
# ----------------- Helper functions for working with Gtk -----------------
# ----------------- ------------------------------------- -----------------

const SString = Union{AbstractString, Symbol}

"""
        getprop(widget, prop, T)

Get the Gtk property `prop` with type `T`.
"""
function getprop(widget::GtkWidget, prop::SString, ::Type{T}) where {T}
    return get_gtk_property(widget, prop, T)
end
"""
        set!(wiget, prop, value)

Sets the Gtk property `prop` to `value`.
"""
function set!(widget::GtkWidget, prop::SString, value::T) where {T}
    set_gtk_property!(widget, prop, value)
end
"""
        set!(widget, props::Dict{SString, T}) where {T}

Sets the Gtk property for each `(key, value)` pair in `props`.
"""
function set!(widget::GtkWidget, props::Dict{K, T}) where {K <: SString, T}
    for (key, value) in props
        set!(widget, key, value)
    end
end
"""
        set!(widget, props::NamedTuple)

Sets the Gtk property for each `(key, value)` pair in `props`.
"""
function set!(widget::GtkWidget, props::NamedTuple)
    set!(widget, Dict(pairs(props)))
end
"""
        set!(widget, props::NamedTuple)

Sets the Gtk property for each `(key, value)` pair in `props`.
"""
function set!(widget::GtkWidget; props...)
    if length(props) > 0
        set!(widget, Dict(pairs(props)))
    end
end
"""
        on(callback, event, target)

Connects a event listener of type `event` for `target`.

This function returns an `id` that can be use
with the `off` function.
"""
function on!(callback::Function, event::SString, target::GtkWidget)
    signal_connect(callback, target, event)
end
"""
        off(target, id)

Disconnect the callback associated with `id`.
"""
function off!(target::GtkWidget, id::UInt64)
    signal_handler_disconnect(target, id)
end

"""
        value(scale)

Returns the value of a `GtkScale` (e.g. slider).
"""
function value(scale::GtkScale)
    return GAccessor.value(GAccessor.adjustment(scale))
end
"""
        value!(scale, v::Real)

Sets the value of a `GtkScale` (a.k.a. slider) to `v`.
"""
function value!(scale::GtkScale, v::Real)
    return set_gtk_property!(GAccessor.adjustment(scale), :value, v)
end

function value(entry::GtkEntry)
    return bytestring(GAccessor.text(entry))
end

function value(cbtn::GtkColorButton)
    return convert(RGBA, getprop(cbtn, "rgba", Gtk.GdkRGBA))
end

function value(switch::GtkSwitch)
    return getprop(switch, :active, Bool)
end

function add!(parent::GtkWidget, child::GtkWidget)
    push!(parent, child)
end

function add!(parent::GtkWidget, children::GtkWidget...)
    for child in children
        add!(parent, child)
    end
end

function add!(parent::GtkWidget, children::Tuple{Vararg{GtkWidget}})
    add!(parent, children...)
end

function add!(parent::GtkWidget, children::AbstractArray{GtkWidget, 1})
    add!(parent, children...)
end

function add!(parent::GtkWidget, children::Function)
    add!(parent, children())
end


# ----------------- ----------------- ----------- ----------------- -----------------
# ----------------- ----------------- Gtk Widgets ----------------- -----------------
# ----------------- ----------------- ----------- ----------------- -----------------

const Children{T} = Union{T, Tuple{Vararg{T}}, AbstractArray{T, 1}, Function}

function (container::GtkContainer)(children::Vararg{Children{GtkWidget}}; props...)
    length(props) > 0 && set!(container; props...)
    for child in children
        add!(container, child)
    end
    return container;
end

function Window(children::Children{GtkWidget}, width::Int, height::Int; title::SString = "A Window Title", props...)
    win = GtkWindow(title, width, height)
    # if properties are passed, set them.
    length(props) > 0 && set!(win; props...)
    add!(win, children)
    return win
end

function Window(width::Int, height::Int; title::SString = "A Window Title", props...)
    return Window((), width, height; title, props...)
end

"""
        Box(children, [ layout = :v]; props...)

Creates a new `GtkBox` Widget that can be used to group other widgets.

The `children` parameter can be either a single widget, a collection
of widgets or a function that returns a widget or a collection of widgets.

The `layout` parameter is a symbol that defines the way that the widgets are
grouped, either in the `vertical` or `horizontal` direction.

```julia-repl
    layout = :v # vertical direction
    layout = :h # horizontal direction
```

# Examples

```julia-repl
julia> Box(:h) # empty box (with no children widgets)
GtkBoxLeaf...

julia> Box((button, slider, label)) # box with three children widgets.
GtkBoxLeaf...

julia> Box([button, slider, label]) # the same thing as above.
GtkBoxLeaf...

julia> Box(:h; spacing = 45) do # using 'do' syntax.
        button,                 # Also the same thing as above.
        slider,                 # The function passed is called and
        label                   # its return value is the children.
    end
GtkBoxLeaf(spacing=45...)

```
"""
function Box(children::Children{GtkWidget}, layout::Symbol = :v; props...)
    box = GtkBox(layout)
    length(props) > 0 && set!(box; props...)
    add!(box, children)
    return box
end

function Paned(children::Children{GtkWidget}, layout::Symbol = :v; props...)
    pn = GtkPaned(layout)
    length(props) > 0 && set!(pn; props...)
    add!(pn, children)
    return pn
end
"""
        Box([, layout = :v]; props...)

Creates a empty box (with no children widgets).
"""
function Box(layout::Symbol = :v; props...)
    return Box((), layout; props...)
end

"""
        Paned([, layout = :v]; props...)

Creates a empty paned (with no children widgets).
"""
function Paned(layout::Symbol = :v; props...)
    return Paned((), layout; props...)
end

"""
        Span{T, N}

Represents a grid cell that spans multiple rows **or** collumns.

The `T` type parameter indicates whether the widget will span rows or columns.

The `N` type parameter is how much the widget will span.

| Example          | Result           |
|:-----------------|-----------------:|
| `Span{:r, N}`    | span `N` rows    |
| `Span{:c, N}`    | span `N` columns |
| `Span{:rows, N}` | span `N` rows    |
| `Span{:cols, N}` | span `N` columns |

!!! warning "Beware!"
    Span objects can only be use
    in a grid context.
"""
mutable struct Span{T, N}
    widget::GtkWidget
end
"""
        rspan(widget, N::Int)

Creates a grid cell that spans `N` rows.

# Examples

```julia-repl
julia> label = rspan(Label(:foo), 2) # The label will span 2 rows.
Span{:rows, 2}(GtkBoxLeaf...)

julia> label = rspan(Label(:bar), 3) # span 3 rows
Span{:rows, 3}(GtkBoxLeaf...)


```
"""
function rspan(widget::GtkWidget, N::Int)
    return Span{:rows, N}(widget)
end
"""
        cspan(widget, N::Int)

Like [`rspan`](@ref), but the widget will span `N` columns instead of `N` rows.
"""
function cspan(widget::GtkWidget, N::Int)
    return Span{:cols, N}(widget)
end

function span(sp::Span{T, N}) where {T, N}
    return sp.widget, T, N
end

"""
        →(w, N)

Useful binary operator to create a cell that spans `N` columns.

# Examples

```julia-repl
julia> Label(:foo) → 2 # The label will span 2 columns.
Span{:cols, 2}(GtkLabelLeaf...)


```
"""
→(w::GtkWidget, N::Int) = rspan(w, N)
"""
        ↓(w, N)

Useful binary operator to create a cell that spans `N` rows.

# Examples

```julia-repl
julia> Label(:foo) ↓ 3 # The label will span 3 rows.
Span{:rows, 3}(GtkLabelLeaf...)


```
"""
↓(w::GtkWidget, N::Int) = cspan(w, N)

"""
        Grid(cells; props...)
Creates a grid widget that groups its children in a grid layout.

The `cells` parameter is a [`Matrix`](@ref) where each element is a
widget and its position on the matrix corresponds to its position
on the grid.

# Examples

```julia-repl
julia> Grid([
        button  label
        box     slider
    ])
GtkGridLeaf...

julia> Grid() do # using do-syntax.
        GridCell[ 
              Button(".") → 2 ""              Button(".")    
              Button(".")     Button(".") ↓ 3 Button(".") ↓ 2
              Button(".")     ""              ""             
              Button(".")     ""              Button(".")    
        ]
      end
GtkGridLeaf...


```
"""
function Grid(cells::AbstractArray{Any, 2}; props...)
    grid = GtkGrid()
    length(props) > 0 && set!(grid; props...)
    if length(cells) > 0
        for (index, child) in pairs(cells)
            i, j = Tuple(index)
            if child == ""
                continue
            elseif child == '.'
                grid[j, i] = Label(".")
            elseif child isa Span
                w, T, N = span(child)
                if T == :r || T == :rows
                    grid[j:(j + N - 1), i] = w
                elseif T == :c || T == :cols
                    grid[j, i:(i + N - 1)] = w
                else
                    throw(error("Span of type $T is not a valid Span type."))
                end
            else
                grid[j, i] = child
            end
        end
    end
    return grid
end

function Grid(cells::Function; props...)
    return Grid(cells()::GridCells; props...)
end

"""
        @grid [cells] [props...]

Useful macro for creating a grid widget.

# Examples

```julia-repl
julia> mygrid = @grid [ # the "" indicates a empty grid cell.
           rspan(label, 3)      "" ""
           button cspan(slider, 2) ""
           switch               "" ""
      ] spacing = 45
GtkGridLeaf...


```
"""
macro grid(cells, props...)
    kws = map(props) do p
        @assert Meta.isexpr(p, Symbol("="))
        return Expr(:kw, p.args...)
    end

    if Meta.isexpr(cells, :typed_vcat)
        _cells = cells
    else
        _cells = Expr(:typed_vcat, :GridCell, cells.args...)
    end

    quote
        Grid($_cells; $(kws...))
    end |> esc
end

"""
Creates a `GtkButton` widget.
"""
function Button(children::Union{SString, Children{GtkWidget}}; props...)
    if children isa SString
        btn = GtkButton(string(children))
    else
        btn = GtkButton()
        add!(btn, children)
    end
    length(props) > 0 && set!(btn; props...)
    return btn
end

"""
Creates a `GtkLabel` widget.
"""
function Label(text::SString; props...)
    lb = GtkLabel(string(text))
    length(props) > 0 && set!(lb; props...)
    return lb
end

macro label_str(str)
    :( Label($str) )
end

"""
Creates a `GtkEntry` widget.
"""
function Entry(text::SString = ""; props...)
    entry = GtkEntry()
    text != "" && set!(entry; text)
    length(props) > 0 && set!(entry; props...)
    return entry
end

"""
Creates a `GtkScale` (a.k.a. slider) widget.
"""
function Slider(range::AbstractRange; startat = missing, props...)
    sc = GtkScale(false, range)

    if startat isa Real
        value!(sc, startat)
    end

    length(props) > 0 && set!(sc; props...)

    return sc
end

"""
Creates a `GtkCanvas` widget.
"""
function Canvas(width::Int = -1, height::Int = -1; props...)
    c = GtkCanvas(width, height)
    length(props) > 0 && set!(c; props...)
    return c
end

function ColorButton(c::Colorant = colorant"#fff"; props...)
    cbtn = GtkColorButton(convert(Gtk.GdkRGBA, c))
    length(props) > 0 && set!(cbtn; props...)
    return cbtn
end

ColorButton(c::String; props...) = ColorButton(parse(Colorant, c); props...)

function Switch(on::Bool = false; props...)
    w = GtkSwitch(on)
    length(props) > 0 && set!(w; props...)
    return w
end