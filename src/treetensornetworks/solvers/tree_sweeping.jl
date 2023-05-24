direction(step_number) = isodd(step_number) ? Base.Forward : Base.Reverse

function make_region(edge; last_edge=false, nsite=1, region_args=(;), reverse_args=region_args, reverse_step=false)
  if nsite == 1
    site = ([src(edge)], region_args)
    bond = (edge, reverse_args)
    region = reverse_step ? (site, bond) : (site,)
    if last_edge
      return (region..., ([dst(edge)], region_args))
    else
      return region
    end
  elseif nsite == 2
    sites_two = ([src(edge),dst(edge)],region_args)
    sites_one = ([dst(edge)],reverse_args)
    region = reverse_step ? (sites_two, sites_one) : (sites_two,)
    if last_edge
      return (sites_two,)
    else
      return region
    end
  else
    error("nsite=$nsite not supported in alternating_update / update_step")
  end
end

#
# Helper functions to take a tuple like ([1],[2])
# and append an empty named tuple to it, giving ([1],[2],(;))
#
prepend_missing_namedtuple(t::Tuple) = ((;), t...)
prepend_missing_namedtuple(t::Tuple{<:NamedTuple,Vararg}) = t

function append_missing_namedtuple(t::Tuple)
  return reverse(prepend_missing_namedtuple(reverse(t)))
end

to_tuple(x) = (x,)
to_tuple(x::Tuple) = x

function half_sweep(
  dir::Base.ForwardOrdering,
  graph::AbstractGraph,
  region_function;
  root_vertex=default_root_vertex(graph),
  kwargs...,
)
  edges = post_order_dfs_edges(graph, root_vertex)
  V = vertextype(graph)
  E = edgetype(graph)
  steps = []
  for e in edges[1:(end - 1)]
    push!(steps, region_function(e; last_edge=false, kwargs...)...)
  end
  push!(steps, region_function(edges[end]; last_edge=true, kwargs...)...)

  steps = append_missing_namedtuple.(to_tuple.(steps))

  return steps
end

function half_sweep(dir::Base.ReverseOrdering, args...; kwargs...)
  rev_sweep = []
  for region in reverse(half_sweep(Base.Forward, args...; kwargs...))
    push!(rev_sweep, (reverse(region[1]), region[2:end]...))
  end
  return rev_sweep
end
