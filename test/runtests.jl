using ConferenceCall
using Test

@testset "ConferenceCall.jl" begin
    @confcall function foo end
    @confcall 1 foo() = :a
    @confcall 2 foo() = :b
    @test foo() == [:a, :b]

    @confcall function describe_object end
    @confcall 1 describe_object(x) = "Something"
    @confcall 2 describe_object(x::Number) = "Some number"
    @confcall 3 describe_object(x::Int) = "An Int"
    @test describe_object(3.0) == ["Something", "Some number"]

    @confcall_fast function describe_object2 end
    @confcall 1 describe_object2(x) = "Something"
    @confcall 2 describe_object2(x::Number) = "Some number"
    @confcall 3 describe_object2(x::Int) = "An Int"
    @test describe_object2(3.0) == ("Something", "Some number")
end
