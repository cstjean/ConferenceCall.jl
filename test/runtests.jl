using ConferenceCall
using Test

@testset "ConferenceCall.jl" begin
    # Write your own tests here.
    @confcalled function foo end

    @confcalled 1 foo() = :a
    @confcalled 2 foo() = :b

    @test foo() == (:a, :b)
end
