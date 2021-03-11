function set!(widget::GtkWidget, name::Symbol, sprops::Dict{Symbol, T}) where {T}
    for (key, value) in sprops
        set!(widget, "$name-$key", value)
    end
end
"""
        margin(top, right, bottom, left)

Returns a [`Dict`](@ref) that can be used to set margins of a widget.

# Example

```julia-repl
julia> m = margin(1, 2, 3, 4)
Dict{Symbol, Real}...

julia> btn = Button("Some button", margin = m)
GtkButtonLeaf...


```
"""
function margin(top, right, bottom, left)
    return Dict{Symbol, Real}([
        :top => top,
        :left => left,
        :right => right,
        :bottom => bottom
    ])
end

margin(top, horizontal, bottom) = margin(top, horizontal, bottom, horizontal)
margin(vertical, horizontal) = margin(vertical, horizontal, vertical)
margin(size) = margin(size, size)

"""
        @margin [values...]

Useful macro for define the margins of a widget.

# Example

```julia-repl
julia> btn = Button("Hello"; @margin(4, 2))
GtkButtonLeaf...

julia> lb = Label(:foo; @margin(15, 10, 25))
GtkLabelLeaf...


```
"""
macro margin(values...)
    esc(Expr(:kw, :margin, :( margin($(values...)) )))
end

"""
        align(value)

Returns a `GtkAlign` constant.

# Example

```julia-repl
julia> box = Box(:v, valign = align(:fill))
GtkBoxLeaf...
```
"""
function align(value::Symbol)
    galign = Symbol(uppercase(string(value)))
    @assert isdefined(GtkAlign, galign) "Alignment type $value unknow."
    return getfield(GtkAlign, galign)
end

"""
        @valign value

Used to define the vertical alignment of a widget.

# Example

```julia-repl
julia> sl = Slider(1:100, @valign(:fill))
GtkScaleLeaf...

```
"""
macro valign(value)
    esc(Expr(:kw, :valign, :( align($value) )))
end
"""
        @halign value

Used to define the horizontal alignment of a widget.

# Example

```julia-repl
julia> sl = Slider(-10:10, @halign(:start))
GtkScaleLeaf...

```
"""
macro halign(value)
    esc(Expr(:kw, :halign, :( align($value) )))
end

"""
        @hexpand

The widget should expand horizontally.

# Example

```julia-repl
julia> bx = Box(:v, @hexpand)


```
"""
macro hexpand()
    Expr(:kw, :hexpand, true)
end

"""
        @vexpand

The widget should expand vertically.

# Example

```julia-repl
julia> bx = Box(:v, @vexpand)


```
"""
macro vexpand()
    Expr(:kw, :vexpand, true)
end
"""
        @columnhg

The grid widget should have homogeneous columns.

# Example
```julia-repl
julia> grid = Grid(@columnhg) do
            [foo bar qux]
       end
GtkGridLeaf...

```
"""
macro columnhg()
    Expr(:kw, :column_homogeneous, true)
end
"""
        @rowhg

The grid widget should have homogeneous rows.

# Example
```julia-repl
julia> grid = Grid(@rowhg) do
            [foo bar qux]
       end
GtkGridLeaf...

```
"""
macro rowhg()
    Expr(:kw, :row_homogeneous, true)
end

struct GridSpacing
    r::Int
    c::Int
end

GridSpacing(v) = GridSpacing(v, v)

set!(widget::GtkGrid, key::Symbol, spacing::GridSpacing) = set!(
    widget,
    row_spacing = spacing.r,
    column_spacing = spacing.c
)

macro spacing(args...)
    args = esc.([args...])
    Expr(:kw, :spacing, :( GridSpacing($(args...)) ))
end