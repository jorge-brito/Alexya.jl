"""
Represents a 2D Vector
"""
mutable struct Vec
    x::Float64
    y::Float64
    Vec(x::Real, y::Real) = new(x, y)
end
""" 
        abs(v::Vec)

Returns the absolute value of a vector.
"""
abs(v::Vec) = sqrt(v.x^2 + v.y^2)
length(v::Vec) = 2

convert(::Type{Vec}, a::Vector{<:Real}) = Vec(a[begin], a[end])
convert(::Type{Vector{<:Real}}, v::Vec) = Float64[v.x, v.y]
convert(::Type{Point}, v::Vec) = Point(v.x, v.y)
convert(::Type{Vec}, p::Point) = Vec(p.x, p.y)

point(v::Vec) = convert(Point, v)
getindex(v::Vec, i::Int) = convert(Vector{<:Real}, v)[i]

==(a::Vec, b::Vec) = a.x == b.x && a.y == b.y

for op in [:>, :<, :>=, :<=]
    @eval $(op)(a::Vec, b::Vec) = $(op)(abs(a), abs(b))
end

+(v::Vec) = v
-(v::Vec) = Vec(-v.x, -v.y)
+(a::Vec, b::Vec) = Vec(a.x + b.x, a.y + b.y)
-(a::Vec, b::Vec) = Vec(a.x - b.x, a.y - b.y)
# Dot product
*(a::Vec, b::Vec) = a.x * b.x + a.y * b.y
*(k::Real, v::Vec) = Vec(k * v.x, k * v.y)
*(v::Vec, k::Real) = k * v
/(v::Vec, k::Real) = Vec(v.x / k, v.y / k)

"""
        transform(v::Vec, m::Matrix)

Returns a new vector by applying a transformation of the matrix `m` on `v`.
"""
transform(v::Vec, m::Matrix{<:Real}) = convert(Vec, m * convert(Vector{<:Real}, v))

"""
        rotm2d(θ)

Returns a Rotation Matrix that rotates `θ` radians in 2D space.
"""
rotm2d(θ) = [
    cos(θ) -sin(θ)
    sin(θ)  cos(θ)
]
"""
        rot(v::Vec, φ::Real)

Returns new vector by applying a rotation transformation of `φ` radians on `v`.
"""
rot(v::Vec, φ::Real) = Vec(
    v.x * cos(φ) - v.y * sin(φ), 
    v.x * sin(φ) + v.y * cos(φ)
)

*(m::Matrix{<:Real}, v::Vec) = transform(v, m)
*(v::Vec, m::Matrix{<:Real}) = transform(v, m)

""" 
The unitary horizontal vector.
"""
const î = Vec(1, 0)
""" 
The unitary vertical vector.
"""
const ĵ = Vec(0, 1)

"""
        angle(v::Vec)

Returns the angle `θ`, in radians, that `v` makes with the
positive x-axis.
"""
angle(v::Vec) = atan(v.y, v.x)
"""
        withangle(φ::Real)

Returns a new vector with angle `φ`.
"""
withangle(φ::Real) = Vec(cos(φ), sin(φ))
"""
        normalize(v::Vec)

Normalizes a vector `v`.

A normalized vector, or the "unit" vector of a vector `v`
is the result of the quotient between `v` and its magnitude.

The normalized vector has a magnitude of 1 and points in the direction of `v`.
"""
normalize(v::Vec) = v / abs(v)
"""
        setmag!(v::Vec, m::Real)

Creates a vector with the direction of `v`
and magnitude of `m`.
"""
withmag(v::Vec, m::Real) = m * normalize(v)

"""
        randv([θ = 0:π/32:2π, m = 1)

Creates a vector that points in a random direction.

Pass a range for `θ` to constraint the possible 
angles and a value for `m` to define its magnitude.
"""
randv(θ::AbstractRange = 0:π/32:2π, m::Real = 1) = m * withangle(rand(θ))