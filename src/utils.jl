""" Sometimes useful given `@confcall`'s tendency to grow methods endlessly. 
Useful special case: `delete_all_methods(fn, types=Tuple{Val{whatev},Vararg{Any}})` """
delete_all_methods(fn, types=Tuple{Vararg{Any}}) =
    foreach(Base.delete_method, methods(fn, types).ms)

    
