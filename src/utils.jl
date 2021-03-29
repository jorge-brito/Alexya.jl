const SString = Union{AbstractString, Symbol}
const Maybe{T} = Union{Missing, Nothing, T}

function middle(range::AbstractRange)
    array = collect(range)
    N = length(array)
    return array[ceil(Int, N / 2)]
end

function convert(::Type{GdkRGBA}, c::T) where T <: ColorAlpha
    color = convert(RGBA, c)
    return GdkRGBA(color.r, color.g, color.b, color.alpha)
end

convert(::Type{GdkRGBA}, color::T) where T <: Colorant   = convert(GdkRGBA, convert(RGBA, color))
convert(::Type{T}, color::GdkRGBA) where T <: ColorAlpha = convert(T, RGBA(color.r, color.g, color.b, color.a))
convert(::Type{T}, color::GdkRGBA) where T <: Color      = convert(T, RGB(color.r, color.g, color.b))

set!(w::GtkColorButton, k::SString, color::Colorant) = set!(w, k, convert(Gtk.GdkRGBA, color))

function set!(w::GtkWidget, k::SString, props::Vector{Pair})
    for (key, value) in props
        set!(w, key, value)
    end
end
"""
        @margin values...

Useful macro for setting the `margins` of a widget.

| Example             | Behavior                                                      |
|:--------------------|:--------------------------------------------------------------|
|`@margin(s)`         | Sets all margins to `s`                                       |
|`@margin(v, h)`      | Sets `top-bottom` and `left-right` margins respectively       |
|`@margin(t, b, h)`   | Sets `top`, `bottom` and `left-right` margins respectively    |
|`@margin(t, r, b, l)`| Sets `top`, `right`, `bottom` and `left` margins respectively |

# Examples

```julia
julia> Button(:Foo, @margin(10)) # Sets all margins to 10
GtkButton...

julia> Button(:Foo, @margin(10, 20)) # Sets top-bottom margins to 10 and left-right margins to 20
GtkButton...
```
"""
macro margin(t, r, b, l)
    return esc(Expr(:kw, :margin, :((
        top = $t,
        left = $l,
        right = $r,
        bottom = $b,
    ))))
end

macro margin(t, b, lr)
    esc(:( @margin($t, $lr, $b, $lr) ))
end

macro margin(tb, lr)
    esc(:( @margin($tb, $lr, $tb, $lr) ))
end

macro margin(s)
    esc(:( @margin($s, $s, $s, $s) ))
end

function align(value::Symbol)
    galign = Symbol(uppercase(string(value)))
    @assert isdefined(GtkAlign, galign) "Alignment type $value unknow."
    return getfield(GtkAlign, galign)
end

macro valign(ex)
    Expr(:kw, :valign, :( align($(esc(ex))) ))
end

macro halign(ex)
    Expr(:kw, :halign, :( align($(esc(ex))) ))
end

"""
        @align v h

Sets the vertical and horizontal alignment of Gtk widget.

# Examples

```julia
julia> Button("Foo", @align(:center)) # Sets both alignments to center
GtkButton...

julia> Button("Foo", @align(:center, :end))
GtkButton...
```
"""
macro align(v, h)
    esc(Expr(:kw, :align, :(Pair[
        :valign => align($v),
        :halign => align($h)
    ])))
end

macro align(value)
    esc(:(@align($value, $value)))
end

"""
        @spacing r c

Sets the `row` and `column` spacing of a `GtkGrid` widget.

# Examples

```julia
julia> Grid(@spacing(10)) # sets both row and column spacing.
GtkGrid...

julia> Grid(@spacing(10, 20))
GtkGrid...
```
"""
macro spacing(r, c)
    esc(Expr(:kw, :____, :(Pair[
        :row_spacing => $r,
        :column_spacing => $c
    ])))
end

macro spacing(value)
    esc(:(@spacing($value, $value)))
end

macro expand()
    Expr(:kw, :expand, true)
end

macro expand(ex)
    esc(Expr(:kw, :expand, ex))
end

macro hexpand()
    Expr(:kw, :hexpand, true)
end

macro hexpand(ex)
    esc(Expr(:kw, :hexpand, ex))
end

macro vexpand()
    Expr(:kw, :vexpand, true)
end

macro vexpand(ex)
    esc(Expr(:kw, :vexpand, ex))
end

macro homogeneous(r, c)
    esc(Expr(:kw, :homogeneous, :(Pair[
        :column_homogeneous => $(r),
        :row_homogeneous => $(c),
    ])))
end

macro homogeneous(v)
    esc(:(@homogeneous($v, $v)))
end

macro homogeneous()
   :(@homogeneous(true, true))
end

macro on(ex...)
    if length(ex) == 1
        throw(error("The @on macro must have at least 2 arguments (event name and callback function)"))
    end
    eventname = ("on" * join(map(string, ex[1:end-1]), "_")) |> Symbol
    esc(Expr(:kw, eventname, last(ex)))
end

"""
        keyboard(key)

Returns a number that represents a `key` of the keyboard.
"""
function keyboard(key::Union{AbstractString, Symbol})
    try 
        gdk_key = Symbol("GDK_KEY_$key")
        getfield(Gtk.GConstants, gdk_key)
    catch e
        throw(error("Keyboard '$key' key not found."))
    end 
end
