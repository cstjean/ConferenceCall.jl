module ConferenceCall

using MacroTools: splitdef, combinedef, @capture

export @confcall, @confcall_fast

include("utils.jl")

val_value(::Type{Val{T}}) where T = T

available_vals(fn) = (m.sig.types[2] for m in methods(fn).ms)
sorted_available_vals(fn) = sort(collect(available_vals(fn)), by=val_value)

""" See Cassette#6 for why this is not Revise-able. """
@generated function call_all_methods_tuple_fast(fn, args...)
    quote
        tuple($([:(fn($v(), args...)) 
                 for v in sorted_available_vals(fn.instance)
                 if hasmethod(fn.instance, Tuple{v, args...})]...))
    end
end

call_all_methods_vector(fn, args...) =
    [fn(v(), args...) for v in sorted_available_vals(fn)
     if applicable(fn, v(), args...)]

impl_name(fname::Symbol) = Symbol(fname, "_impl")
function impl_name(fname::Expr)
    @assert @capture(fname, mod_.fname2_)
    return :($mod.$(impl_name(fname2)))
end

""" `@confcall_fast function foo end` """
macro confcall_fast(fn_def)
    @assert(@capture(fn_def, function fname_ end),
            "Use `@confcall` for function definitions")
    impl = impl_name(fname)
    esc(quote
        function $impl end
        $fname(args...) = $ConferenceCall.call_all_methods_tuple_fast($impl, args...)
        end)
end

macro confcall(fn_def)
    if @capture(fn_def, function fname_ end)
        impl = impl_name(fname)
        esc(quote
            function $impl end
            $fname(args...) = $ConferenceCall.call_all_methods_vector($impl, args...)
        end)
    else
        di = splitdef(fn_def)
        esc(:($ConferenceCall.@confcall $(hash(fn_def)) $fn_def))
    end
end

macro confcall(key, fn_def)
    di = splitdef(fn_def)
    di2 = copy(di)
    di2[:args] = tuple(:(::Val{$key}), di[:args]...)
    di2[:name] = impl_name(di[:name])
    return esc(combinedef(di2))
end

end # module
