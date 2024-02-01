function contract(
  ::Algorithm"fit",
  tns::Vector{<:Tuple{<:AbstractTTN,<:AbstractTTN}};
  init,
  #init=random_ttn(
  #  flatten_external_indsnetwork(first(tn1s), first(tn2s));
  #  link_space=trivial_space(first(tn1s)),
  #),
  nsweeps=1,
  nsites=2, # used to be default of call to default_sweep_regions
  updater_kwargs=(;),
  kwargs...,
)
  tn1s = first.(tns)
  tn2s = last.(tns)
  ns = nv.(tn1s)
  n = first(ns)
  any(ns .!= nv.(tn2s)) && throw(
    DimensionMismatch("Number of sites operator ($n) and state ($(nv(tn2))) do not match")
  )
  any(ns .!= n) &&
    throw(DimensionMismatch("Number of sites in different operators ($n) do not match"))
  # ToDo: Write test for single-vertex TTN, this implementation has not been tested.
  if n == 1
    res = 0
    for (tn1, tn2) in zip(tn1s, tn2s)
      v = only(vertices(tn2))
      res += tn1[v] * tn2[v]
    end
    typeof([res])
    return nothing
  end

  # check_hascommoninds(siteinds, tn1, tn2)

  # In case `tn1` and `tn2` have the same internal indices
  PHs = ProjTTNApply{vertextype(first(tn1s))}[]
  for (tn1, tn2) in zip(tn1s, tn2s)
    tn1 = sim(linkinds, tn1)

    # In case `init` and `tn2` have the same internal indices
    init = sim(linkinds, init)
    push!(PHs, ProjTTNApply(tn2, tn1))
  end
  PH = isone(length(PHs) == 1) ? only(PHs) : ProjTTNSum(PHs)
  # Fix site and link inds of init
  ## init = deepcopy(init)
  ## init = sim(linkinds, init)
  ## for v in vertices(tn2)
  ##   replaceinds!(
  ##     init[v], siteinds(init, v), uniqueinds(siteinds(tn1, v), siteinds(tn2, v))
  ##   )
  ## end
  sweep_plan = default_sweep_regions(nsites, init; kwargs...)
  psi = alternating_update(
    contract_updater, PH, init; nsweeps, sweep_plan, updater_kwargs, kwargs...
  )

  return psi
end

function contract(a::Algorithm"fit", tn1::AbstractTTN, tn2::AbstractTTN; kwargs...)
  return contract(a, [(tn1, tn2)]; kwargs...)
end

"""
Overload of `ITensors.contract`.
"""
function contract(tn1::AbstractTTN, tn2::AbstractTTN; alg="fit", kwargs...)
  return contract(Algorithm(alg), tn1, tn2; kwargs...)
end

"""
Overload of `ITensors.apply`.
"""
function apply(tn1::AbstractTTN, tn2::AbstractTTN; init, kwargs...)
  #plin=plev(first(externalinds(init)))
  #outputindsnet=
  #plout=plev(outputindsnet[first(vertices(outputindsnet))])
  plev_inc = plev_diff(flatten_external_indsnetwork(tn1, tn2), external_indsnetwork(init))
  init = prime(init, plev_inc)
  tn12 = contract(tn1, tn2; init, kwargs...)
  return replaceprime(tn12, 1 => 0)
end

function sum_apply(
  tns::Vector{<:Tuple{<:AbstractTTN,<:AbstractTTN}}; alg="fit", init, kwargs...
)
  #plin=plev(first(externalinds(init)))
  #outputindsnet = flatten_external_indsnetwork(first(tns), first(tn2s))
  #plout=plev(outputindsnet[first(vertices(outputindsnet))])
  plev_inc = plev_diff(
    flatten_external_indsnetwork(first(first(tns)), last(first(tns))),
    external_indsnetwork(init),
  )
  init = prime(init, plev_inc)
  alg != "fit" && error("sum_apply not implemented for other algorithms than fit.")
  tn12 = contract(Algorithm(alg), tns; init, kwargs...)
  return replaceprime(tn12, 1 => 0)
end

function plev_diff(a::IndsNetwork, b::IndsNetwork)
  pla = plev(only(a[first(vertices(a))]))
  plb = plev(only(b[first(vertices(b))]))
  return pla - plb
end
