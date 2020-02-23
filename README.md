# ConferenceCall

ConferenceCall.jl allows one function call to call multiple methods.

```julia
@confcall function ask_for_advice end
@confcall ask_for_advice() = "Buy!"
@confcall ask_for_advice() = "Sell!"

julia> ask_for_advice()
2-element Array{String,1}:
 "Sell!"
 "Buy!" 
```

All applicable methods will be called.

```julia
@confcall function describe_object end
@confcall 1 describe_object(x) = "Something"
@confcall 2 describe_object(x::Number) = "Some number"
@confcall 3 describe_object(x::Int) = "An Int"

julia> describe_object(3.0)
2-element Array{String,1}:
 "Something"  
 "Some number"
```

Here I gave an (optional) `key` after `@confcall` so that the methods are called in
a desired order. Numbers and symbols can be used (it's put in a `Val{}`). 

`@confcall` is precompilation-friendly and
[Reviseable](https://github.com/timholy/Revise.jl). However, calling these methods
is moderately slow, as it involves some reflection.

```julia
julia> @btime describe_object(3.0)
  32.748 μs (38 allocations: 1.69 KiB)
2-element Array{String,1}:
 "Something"  
 "Some number"
```

The reflection can be done at compile-time using `@confcall_fast`:

```julia
julia> @confcall_fast function describe_object end
describe_object (generic function with 1 method)

julia> @btime describe_object(3.0)
  7.377 ns (1 allocation: 32 bytes)
("Something", "Some number")
````

but it involves generated functions, so it [revises poorly](https://github.com/jrevels/Cassette.jl/issues/6) (as of Julia 1.4). Adding/removing methods will not work after the
first call.