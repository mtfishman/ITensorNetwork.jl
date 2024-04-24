using Dictionaries: Dictionary, set!
using ITensors: Op, op, contract, siteinds, which_op
using ITensors.ITensorMPS: ITensorMPS, expect

default_expect_alg() = "bp"

function ITensorMPS.expect(
  ψ::AbstractITensorNetwork, args...; alg=default_expect_alg(), kwargs...
)
  return expect(Algorithm(alg), ψ, args...; kwargs...)
end

function expect_internal(ψIψ::AbstractFormNetwork, op::Op; contract_kwargs=(;), kwargs...)
  v = only(op.sites)
  ψIψ_v = ψIψ[operator_vertex(ψIψ, v)]
  s = commonind(ψIψ[ket_vertex(ψIψ, v)], ψIψ_v)
  operator = ITensors.op(op.which_op, s)
  ∂ψIψ_∂v = environment(ψIψ, [v]; vertex_mapping_function=operator_vertices, kwargs...)
  numerator = contract(vcat(∂ψIψ_∂v, operator); contract_kwargs...)[]
  denominator = contract(vcat(∂ψIψ_∂v, ψIψ_v); contract_kwargs...)[]

  return numerator / denominator
end

function ITensorMPS.expect(
  alg::Algorithm,
  ψ::AbstractITensorNetwork,
  ops;
  (cache!)=nothing,
  update_cache=isnothing(cache!),
  cache_update_kwargs=default_cache_update_kwargs(cache!),
  cache_construction_function=tn ->
    cache(alg, tn; default_cache_construction_kwargs(alg, tn)...),
  kwargs...,
)
  ψIψ = inner_network(ψ, ψ)
  if isnothing(cache!)
    cache! = Ref(cache_construction_function(ψIψ))
  end

  if update_cache
    cache![] = update(cache![]; cache_update_kwargs...)
  end

  return map(
    op -> expect_internal(ψIψ, op; alg, cache!, update_cache=false, kwargs...), ops
  )
end

function ITensorMPS.expect(alg::Algorithm"exact", ψ::AbstractITensorNetwork, ops; kwargs...)
  ψIψ = inner_network(ψ, ψ)
  return map(op -> expect_internal(ψIψ, op; alg, kwargs...), ops)
end

function ITensorMPS.expect(alg::Algorithm, ψ::AbstractITensorNetwork, op::Op; kwargs...)
  return expect(alg, ψ, [op]; kwargs...)
end

function ITensorMPS.expect(
  alg::Algorithm, ψ::AbstractITensorNetwork, op::String, vertices; kwargs...
)
  return expect(alg, ψ, [Op(op, vertex) for vertex in vertices]; kwargs...)
end

function ITensorMPS.expect(alg::Algorithm, ψ::AbstractITensorNetwork, op::String; kwargs...)
  return expect(alg, ψ, op, vertices(ψ); kwargs...)
end
