module ConferenceCall

using MacroTools: splitdef, combinedef, @capture

export @confcalled, @confcalled_fast

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

call_all_methods_tuple(fn, args...) =
    tuple([fn(v(), args...)
           for v in sorted_available_vals(fn)
           if applicable(fn, v(), args...)]...)

impl_name(fname::Symbol) = Symbol(fname, "_impl")

""" `@confcalled_fast function foo end` """
macro confcalled_fast(fn_def)
    @assert(@capture(fn_def, function fname_ end),
            "Use `@confcalled` for function definitions")
    esc(:($fname(args...) =
          $ConferenceCall.call_all_methods_tuple_fast($(impl_name(fname)), args...)))
end

macro confcalled(fn_def)
    if @capture(fn_def, function fname_ end)
        esc(:($fname(args...) =
              $ConferenceCall.call_all_methods_tuple($(impl_name(fname)), args...)))
    else
        di = splitdef(fn_def)
        esc(:($ConferenceCall.@confcalled $(hash(di[:body])) $fn_def))
    end
end

macro confcalled(key, fn_def)
    di = splitdef(fn_def)
    di2 = copy(di)
    di2[:args] = tuple(:(::Val{$key}), di[:args]...)
    di2[:name] = impl_name(di[:name])
    return esc(combinedef(di2))
end

end # module
