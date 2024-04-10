@eval module $(gensym())
using ITensorNetworks: ITensorNetworks, OpSum, apply, dmrg, inner, mpo, random_mps, siteinds
using KrylovKit: linsolve
using Random: Random
using Test: @test, @test_broken, @testset

@testset "Linsolve" begin
  @testset "Linsolve Basics" begin
    cutoff = 1E-11
    maxdim = 8
    nsweeps = 2

    N = 8
    # s = siteinds("S=1/2", N; conserve_qns=true)
    s = siteinds("S=1/2", N; conserve_qns=false)

    os = OpSum()
    for j in 1:(N - 1)
      os += 0.5, "S+", j, "S-", j + 1
      os += 0.5, "S-", j, "S+", j + 1
      os += "Sz", j, "Sz", j + 1
    end
    H = mpo(os, s)

    states = [isodd(n) ? "Up" : "Dn" for n in 1:N]

    #
    # Test complex case
    #
    Random.seed!(1234)
    x_c = random_mps(states, s; link_space=4) + 0.1im * random_mps(states, s; link_space=2)
    b = apply(H, x_c; alg="fit", nsweeps=3, init=x_c) #cutoff is unsupported kwarg for apply/contract

    x0 = random_mps(states, s; link_space=10)
    x = @test_broken linsolve(
      H, b, x0; cutoff, maxdim, nsweeps, updater_kwargs=(; tol=1E-6, ishermitian=true)
    )

    # @test norm(x - x_c) < 1E-3
  end
end
end
