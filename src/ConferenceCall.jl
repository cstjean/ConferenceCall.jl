module ConferenceCall

using MacroTools: splitdef, combinedef, @capture

export @confcalled

val_value(::Type{Val{T}}) where T = T

available_vals(fn) = (m.sig.types[2] for m in methods(fn).ms)
sorted_available_vals(fn) = sort(collect(available_vals(fn)), by=val_value)

@generated function call_all_methods_tuple(fn, args...)
    quote
        tuple($([:(fn($v(), args...)) 
                 for v in sorted_available_vals(fn.instance)]...))
    end
end

impl_name(fname::Symbol) = Symbol(fname, "_impl")

macro confcalled(fn_def)
    if @capture(fn_def, function fname_ end)
        esc(:($fname(args...) =
              $ConferenceCall.call_all_methods_tuple($(impl_name(fname)), args...)))
    else
        todo()
    end
end

macro confcalled(key, fn_def)
    di = copy(splitdef(fn_def))
    di[:args] = tuple(:(::Val{$key}), di[:args]...)
    di[:name] = impl_name(di[:name])
    return esc(combinedef(di))
end

end # module
