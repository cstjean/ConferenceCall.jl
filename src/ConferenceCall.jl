module ConferenceCall

using MacroTools: splitdef, combinedef, @capture

available_vals(fn) = (m.sig.types[2] for m in methods(fn).ms)

@generated function call_all_methods_tuple(fn, args...)
    quote
        tuple($([:(fn($v(), args...)) 
                 for v in available_vals(fn.instance)]...))
    end
end

macro confcalled(key, fn_def)
    impl_name(fname::Symbol) = 
    if @capture(fn_def, function fname_ end)
        esc(:($fname(args...) =
              $ConferenceCall.call_all_methods_tuple($(impl_name(fname)), args...)))
    elseif 
        di = copy(splitdef(fn_def))
        di[:args] = tuple(:(::Val{$key}), $(di[:args]...))
        di[:name] = impl_name(di[:name])
    end
end

end # module
