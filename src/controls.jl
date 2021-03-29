function format_option_name(name::String)
    return replace(name, "_" => " ") |> titlecase
end

format_option_name(name::Symbol) = format_option_name(string(name))

valuetype(::T) where {T <: GtkWidget} = Nothing
valuetype(::Union{GtkScale, GtkSpinButton}) = Real
valuetype(::GtkEntry) = String
valuetype(::GtkColorButton) = RGBA
valuetype(::Union{GtkSwitch, GtkCheckButton}) = Bool

abstract type AbstractOption{T} end

"""
        mutable struct Option{W, T} <: AbstractOption{W, T}

Represents an `option` object.

An option is a value of type `T` associated with a `GtkWidget`.

The option's value can be accessed with the empty bracket notation: `option[]`

The `option.set` function sets a new value for the option. The option's value can also be setted
with the empty bracket notation: `option[] = newvalue`

Each option type defines the `get` and `set` functions.
"""
mutable struct Option{T} <: AbstractOption{T}
    widget::GtkWidget
    type::Symbol
    value::T
    set::Function
    label::Maybe{Union{GtkLabel, Symbol}}
    function Option{T}(init::Function) where {T}
        self = new{T}()
        init(self)
        return self;
    end
end

function Base.show(io::IO, ::Option{T}) where {T}
    println(io, "Option($T)")
end

Base.getindex(self::Option) = self.value
Base.setindex!(self::Option, x::T) where {T} = self.set(x)

function onevent(callback::Function, event::SString, self::Option)
    onevent(callback, event, self.widget)
end

function onevent(callback::Function, event::SString, options::Vector{<:Option})
    [onevent(callback, event, opt.widget) for opt in options]
end

value(self::Option) = value(self.widget)
setvalue!(self::Option) = setvalue!(self.widget)

"""
A `controls` object contains a list of options `object` and
a `GtkGrid` containing each option's widget.
"""
mutable struct Controls
    _options::NamedTuple
    _grid::GtkGrid
end

add!(parent::GtkWidget, self::Controls) = add!(parent, self._grid)

function Base.getproperty(self::Controls, key::Symbol)
    if startswith(string(key), "_")
        return getfield(self, key)
    else
        return getfield(getfield(self, :_options), key)
    end
end

function Base.getindex(self::Controls, index::Union{Symbol, Int})
    return getindex(self._options, index).value
end

function Base.setindex!(self::Controls, index::Union{Symbol, Int}, x::T) where {T}
    getindex(self._options, index).set(x)
end

function Controls(options::NamedTuple)
    controls = map(collect(pairs(options))) do pair
        name, value = pair
        return name => create_option(value, name)
    end

    rows = Matrix{GridCell}(undef, length(options), 2)

    for (i, control) in pairs(last.(controls))
        label = getfield(control, :label)
        widget = getfield(control, :widget)
        if ismissing(label)
            rows[i, 1] = GridCell(widget, 1, 2)
            rows[i, 2] = ()
        elseif isnothing(label) || typeof(label) == Symbol
            label = string(isnothing(label) ? first(controls[i]) : label) * ":"
            rows[i, 1] = Label(length(label) == 2 ? label : format_option_name(label), @halign(:START))
            rows[i, 2] = widget
        else
            rows[i, 1] = label
            rows[i, 2] = widget
        end
    end

    grid = Grid(rows; 
        @hexpand,
        @margin(10), 
        @spacing(20)
    )

    return Controls(NamedTuple(controls), grid);
end

function Controls(; options...)
    return Controls(NamedTuple(collect(pairs(options))))
end

function Base.string(controls::Controls)
    io = IOBuffer()
    traverse = (options, level) -> begin
        i = repeat("  ", level)
        for (name, option) in pairs(options)
            if option isa SectionOption
                println(io, string(name))
                traverse(getfield(option, :value)._options, level+1)
            else
                value = option[]
                value = value isa GtkWidget ? typeof(value) : value
                println(io, "$(i)$name: $value")
            end
        end
    end

    options = getfield(controls, :_options)
    traverse(options, 0)

    return String(take!(io))
end

function Base.show(io::IO, controls::Controls)
    println(io, "Controls")
    println(io, "  " * string(controls))
end

##############################################################################
################################## OPTIONS ###################################
##############################################################################

function create_option(self::Option, ::Symbol)
    return self;
end

function create_option(widget::W, name::Maybe{Symbol}) where {W <: GtkWidget}
    T = valuetype(widget)
    return Option{T}() do self
        self.widget = widget
        self.type = Symbol(string(W))
        self.label = name
        self.value = self.widget
        self.set = () -> nothing
    end
end

function create_option(button::GtkButton, ::Symbol)
    return Option{GtkButton}() do self
        self.widget = button
        self.label = missing
        self.type = :button
        self.value = button
        self.set = () -> nothing
    end
end

SectionOption = Option{Controls}

function create_option(options::NamedTuple, name::Maybe{Symbol})
    controls = Controls(options)
    grid = controls._grid
    return SectionOption() do self
        self.type = :section
        self.label = missing
        if name isa Symbol
            label = format_option_name(name)
            self.widget = Expander(() -> Frame(grid, margin_top=5), label, expanded=true)
        else
            self.widget = Frame(grid, margin_top=5)
        end
        self.value = controls
        self.set = () -> nothing
    end
end

function Base.getproperty(self::SectionOption, key::Symbol)
    key = string(key)
    if startswith(key, "_")
        return getfield(self, Symbol(key[2:end]))
    else
        return getproperty(getfield(self, :value), Symbol(key))
    end
end

function Base.iterate(self::SectionOption, i::Int = 1)
    options = getfield(self, :value)._options
    length(self) < i && return nothing
    return options[i], i + 1
end

Base.eltype(::SectionOption) = Option
Base.length(self::SectionOption) = length(getfield(self, :value)._options)
Base.size(self::SectionOption) = length(self)
Base.pairs(self::SectionOption) = pairs(getfield(self, :value)._options)

const InputOption = Option{AbstractString}

function create_option(v::AbstractString, name::Maybe{Symbol})::InputOption
    return InputOption() do self::InputOption
        self.type = :string
        self.widget = Entry(text = v, @hexpand)
        self.label = name
        self.value = v

        onevent(:changed, self.widget) do
            self.value = value(self.widget)
        end

        self.set = (text) -> begin 
            self.value = text 
            set!(self.widget, text = text)
        end
    end
end

const NumberOption = Option{Real}

function create_option(v::Real, name::Maybe{Symbol})::NumberOption
    range = -10 ≤ v ≤ 10 ? (-10:10) : (-2v:3v)
    return NumberOption() do self
        self.type = :number
        self.widget = SpinButton(range; init=v, @halign(:start))
        self.label = name
        self.value = value(self.widget)
        onevent(:value_changed, self.widget) do 
            self.value = value(self.widget)
        end
        self.set = (v) -> (self.value = v; setvalue!(self.widget, v))
    end
end

function create_option((init, range)::Tuple{<:Real, AbstractRange}, name::Maybe{Symbol})::NumberOption
    return NumberOption() do self::NumberOption
        self.type = :number
        self.widget = SpinButton(range; init = init, @halign(:start))
        self.label = name
        self.value = value(self.widget)
        onevent(:value_changed, self.widget) do 
            self.value = value(self.widget)
        end
        self.set = (v) -> (self.value = v; setvalue!(self.widget, v))
    end
end

const ColorOption = Option{RGBA}

function create_option(color::Colorant, name::Maybe{Symbol})
    return ColorOption() do self::ColorOption
        self.type = :color
        self.widget = ColorButton(color)
        self.label = name
        self.value = value(self.widget)
        onevent(:color_set, self.widget) do 
            self.value = value(self.widget)
        end
        self.set = (v) -> (self.value = v; setvalue!(self.widget, v))
    end
end

function create_option(range::AbstractRange, name::Maybe{Symbol})
    return NumberOption() do self
        self.type = :range
        self.widget = Slider(range; margin_bottom = 16, @hexpand)
        self.label = name
        self.value = value(self.widget)
        onevent(:value_changed, self.widget) do 
            self.value = value(self.widget)
        end
        self.set = (v) -> (self.value = v; setvalue!(self.widget, v))
    end
end

function create_option((range, init)::Tuple{AbstractRange, <:Real}, name::Maybe{Symbol})
    return NumberOption() do self
        self.type = :range
        self.widget = Slider(range; init=init, margin_bottom = 16, @hexpand)
        self.label = name
        self.value = value(self.widget)
        onevent(:value_changed, self.widget) do 
            self.value = value(self.widget)
        end
        self.set = (v) -> (self.value = v; setvalue!(self.widget, v))
    end
end

const SwitchOption = Option{Bool}

function create_option(option::Bool, name::Maybe{Symbol})
    return SwitchOption() do self
        self.type = :switch
        self.widget = Switch(option, @halign(:start))
        self.label = name
        self.value = value(self.widget)
        onevent(:state_set, self.widget) do 
            self.value = value(self.widget)
        end
        self.set = (v) -> (self.value = v; setvalue!(self.widget, v))
    end
end

const ComplexNOption = Option{Complex{<:Real}}

function create_option(x::Complex, name::Symbol)
    r, i = real(x), imag(x)
    return ComplexNOption() do self
        real_p = create_option(r, :real)
        imag_p = create_option(i, :imag)

        onevent(:value_changed, [real_p, imag_p]) do
            self.value = Complex(real_p.value, imag_p.value)
        end

        self.type = :complex_number

        self.label = missing
        label = Label(format_option_name(name), @halign(:START))

        self.widget = Grid(@spacing(10)) do 
            [ 
                label → 3
                () Label("Real:", margin_left=10, @halign(:START)) real_p.widget
                () Label("Imag:", margin_left=10, @halign(:START)) imag_p.widget
            ]
        end

        self.value = x
        self.set = (y::Complex) -> begin
            real_p.set(real(y))
            imag_p.set(imag(y))
            self.value = y
        end
    end
end

const PointOption = Option{Point}

function create_option(point::Point, name::Symbol)
    return PointOption() do self
        x_p = create_option(point.x, :x)
        y_p = create_option(point.y, :y)

        onevent(:value_changed, [x_p, y_p]) do 
            self.value = Point(value(x_p), value(y_p))
        end
        
        self.type = :point
        self.label = missing
        label = Label(format_option_name(name), @halign(:START))

        self.widget = Grid(@spacing(10)) do 
            [ 
                label → 3
                () Label("x:", margin_left=10, @halign(:START)) x_p.widget
                () Label("y:", margin_left=10, @halign(:START)) y_p.widget
            ]
        end

        self.value = point
        self.set = (p::Point) -> begin
            x_p.set(p.x)
            y_p.set(p.y)
            self.value = p
        end
    end
end

macro options(ex)
    @assert Meta.isexpr(ex, :block)

    exprs = filter(ex.args) do x
        Meta.isexpr(x, :(=))
    end

    sections = map(first, getfield.(exprs, :args))

    quote
        begin
            global __OPTIONS__ = Controls($( Expr(:tuple, exprs...) ))
            $(Expr(:block, 
                [
                    :( global $name = getproperty(__OPTIONS__, $(QuoteNode(name))) ) 
                    for name in sections
                ]...
            ))
            __OPTIONS__
        end
    end |> esc
end

addwidget(self::Controls) = (addwidget(self._grid); self)

struct NoLabel{T}
    value::T
    NoLabel(value::T) where{T} = new{T}(value)
end

macro nolabel(ex)
    return :( NoLabel($(esc(ex))) )
end

function create_option(x::NoLabel{T}, ::Symbol) where {T}
    return create_option(x.value, missing)
end