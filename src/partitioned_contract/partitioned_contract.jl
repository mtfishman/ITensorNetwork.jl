function partitioned_contract(contraction_sequence::Vector; kwargs...)
  leaves = filter(
    v -> v isa Vector && v[1] isa ITensor, collect(PreOrderDFS(contraction_sequence))
  )
  tn = ITensorNetwork()
  subgraph_vs = []
  i = 1
  for ts in leaves
    vs = []
    for t in ts
      add_vertex!(tn, i)
      tn[i] = t
      push!(vs, i)
      i += 1
    end
    push!(subgraph_vs, vs)
  end
  par = partition(tn, subgraph_vs)
  vs_contraction_sequence = _map_nested_vector(
    Dict(leaves .=> collect(1:length(leaves))), contraction_sequence
  )
  contraction_tree = contraction_sequence_to_digraph(vs_contraction_sequence)
  return partitioned_contract(par, contraction_tree; kwargs...)
end

function partitioned_contract(
  par::DataGraph,
  contraction_tree::NamedDiGraph;
  ansatz="mps",
  approx_itensornetwork_alg="density_matrix",
  cutoff=1e-15,
  maxdim=10000,
  swap_size=1,
  contraction_sequence_alg,
  contraction_sequence_kwargs,
  linear_ordering_alg,
)
  @info "ansatz: $(ansatz)"
  @info "approx_itensornetwork_alg: $(approx_itensornetwork_alg)"
  @info "cutoff: $(cutoff)"
  @info "maxdim: $(maxdim)"
  @info "swap_size: $(swap_size)"
  @info "contraction_sequence_alg: $(contraction_sequence_alg)"
  @info "contraction_sequence_kwargs: $(contraction_sequence_kwargs)"
  @info "linear_ordering_alg: $(linear_ordering_alg)"
  input_tn = ITensorNetwork(mapreduce(l -> Vector{ITensor}(par[l]), vcat, vertices(par)))
  # TODO: currently we assume that the tn represented by 'par' is closed.
  @assert noncommoninds(Vector{ITensor}(input_tn)...) == []

  @timeit_debug ITensors.timer "partitioned_contract" begin
    leaves = leaf_vertices(contraction_tree)
    traversal = post_order_dfs_vertices(contraction_tree, _root(contraction_tree))
    contractions = setdiff(traversal, leaves)
    p_edge_to_ordered_inds = _ind_orderings(par, contraction_tree; linear_ordering_alg)
    for (p_edge, ordered_inds) in p_edge_to_ordered_inds
      @info "edge", p_edge
      @info "ordered_inds", ordered_inds
    end
    # Build the orderings used for the ansatz tree.
    # For each tuple in `v_to_ordered_p_edges`, the first item is the
    # reference ordering of uncontracted edges for the contraction `v`,
    # the second item is the target ordering, and the third item is the
    # ordering of part of the uncontracted edges that are to be contracted
    # in the next contraction (first contraction in the path of `v`).
    v_to_ordered_p_edges = Dict{Tuple,Tuple}()
    for (ii, v) in enumerate(traversal)
      @info "$(ii)/$(length(traversal)) th ansatz tree construction"
      p_leaves = vcat(v[1:(end - 1)]...)
      tn = ITensorNetwork(mapreduce(l -> Vector{ITensor}(par[l]), vcat, p_leaves))
      path = filter(u -> issubset(p_leaves, u[1]) || issubset(p_leaves, u[2]), contractions)
      p_edges = _neighbor_edges(par, p_leaves)
      if p_edges == []
        v_to_ordered_p_edges[v] = ([], [], [])
        continue
      end
      # Get the reference ordering and target ordering of `v`
      v_inds = map(e -> Set(p_edge_to_ordered_inds[e]), p_edges)
      constraint_tree = _adjacency_tree(v, path, par, p_edge_to_ordered_inds)
      if v in leaves
        # TODO: the "bottom_up" algorithm currently doesn't support `v_inds`
        # being a vector of set of indices.
        ref_inds_ordering = _mps_partition_inds_order(tn, v_inds; alg="top_down")
        inds_ordering = _constrained_minswap_inds_ordering(
          constraint_tree, ref_inds_ordering, tn
        )
      else
        c1, c2 = child_vertices(contraction_tree, v)
        c1_inds_ordering = map(
          e -> Set(p_edge_to_ordered_inds[e]), v_to_ordered_p_edges[c1][2]
        )
        c2_inds_ordering = map(
          e -> Set(p_edge_to_ordered_inds[e]), v_to_ordered_p_edges[c2][2]
        )
        # TODO: consider removing `c1 in leaves` and `c2 in leaves` below.
        ref_inds_ordering, inds_ordering = _constrained_minswap_inds_ordering(
          constraint_tree,
          c1_inds_ordering,
          c2_inds_ordering,
          tn,
          c1 in leaves,
          c2 in leaves,
        )
      end
      ref_p_edges = p_edges[_findperm(v_inds, ref_inds_ordering)]
      p_edges = p_edges[_findperm(v_inds, inds_ordering)]
      # Update the contracted ordering and `v_to_ordered_p_edges[v]`.
      # `sibling` is the vertex to be contracted with `v` next.
      # Note: the contracted ordering in `ref_p_edges` is not changed,
      # since `ref_p_edges` focuses on minimizing the number of swaps
      # rather than making later contractions efficient.
      sibling = setdiff(child_vertices(contraction_tree, path[1]), [v])[1]
      if haskey(v_to_ordered_p_edges, sibling)
        contract_edges = v_to_ordered_p_edges[sibling][3]
        @assert(_is_neighbored_subset(p_edges, Set(contract_edges)))
        p_edges = _replace_subarray(p_edges, contract_edges)
      else
        p_leaves_2 = vcat(sibling[1:(end - 1)]...)
        p_edges_2 = _neighbor_edges(par, p_leaves_2)
        contract_edges = intersect(p_edges, p_edges_2)
      end
      v_to_ordered_p_edges[v] = (ref_p_edges, p_edges, contract_edges)
      @info "ref_p_edges is", ref_p_edges
      @info "p_edges is", p_edges
    end
    # start approximate contraction
    v_to_tn = Dict{Tuple,ITensorNetwork}()
    for v in leaves
      @assert length(v[1]) == 1
      v_to_tn[v] = par[v[1][1]]
    end
    log_acc_norm = 0.0
    for (ii, v) in enumerate(contractions)
      @info "$(ii)/$(length(contractions)) th tree approximation"
      c1, c2 = child_vertices(contraction_tree, v)
      tn = ITensorNetwork()
      ts = vcat(Vector{ITensor}(v_to_tn[c1]), Vector{ITensor}(v_to_tn[c2]))
      for (i, t) in enumerate(ts)
        add_vertex!(tn, i)
        tn[i] = t
      end
      ref_p_edges, p_edges, contract_edges = v_to_ordered_p_edges[v]
      if p_edges == []
        @assert v == contractions[end]
        out = _optcontract(
          Vector{ITensor}(tn);
          contraction_sequence_alg=contraction_sequence_alg,
          contraction_sequence_kwargs=contraction_sequence_kwargs,
        )
        out_nrm = norm(out)
        out /= out_nrm
        return ITensorNetwork(out), log_acc_norm + log(out_nrm)
      end
      intervals = _intervals(ref_p_edges, p_edges; size=swap_size)
      @info "number of approx_itensornetwork calls: $(length(intervals))"
      for edge_order in intervals
        inds_ordering = map(e -> p_edge_to_ordered_inds[e], edge_order)
        # `ortho_center` denotes the number of edges arranged at
        # the left of the center vertex.
        ortho_center = if edge_order == p_edges
          _ortho_center(p_edges, contract_edges)
        else
          div(length(edge_order), 2, RoundDown)
        end
        tn, log_norm = approx_itensornetwork(
          tn,
          _ansatz_tree(inds_ordering, ansatz, ortho_center);
          alg=approx_itensornetwork_alg,
          cutoff=cutoff,
          maxdim=maxdim,
          contraction_sequence_alg=contraction_sequence_alg,
          contraction_sequence_kwargs=contraction_sequence_kwargs,
        )
        log_acc_norm += log_norm
      end
      v_to_tn[v] = tn
    end
    return v_to_tn[contractions[end]], log_acc_norm
  end
end

# Note: currently this function assumes that the input tn represented by 'par' is closed
# TODO: test needed:
function _ind_orderings(par::DataGraph, contraction_tree::NamedDiGraph; linear_ordering_alg)
  leaves = leaf_vertices(contraction_tree)
  traversal = post_order_dfs_vertices(contraction_tree, _root(contraction_tree))
  contractions = setdiff(traversal, leaves)
  @info "number of contractions", length(contractions)
  p_edge_to_ordered_inds = Dict{Any,Vector}()
  # mapping each vector of par vertices to a given tensor network.
  # This dict is used so that the construnctor `ITensorNetwork`
  # does not need to be called too many times.
  p_vs_to_tn = Dict{Any,ITensorNetwork}()
  # This dict is used so that `noncommoninds` does not need to be
  # called too many times.
  p_vs_to_noncommon_inds = Dict{Any,Vector}()
  for v in leaves
    @assert length(v[1]) == 1
    p_vs_to_tn[v[1]] = par[v[1][1]]
    p_vs_to_noncommon_inds[v[1]] = noncommoninds(Vector{ITensor}(par[v[1][1]])...)
  end
  for v in contractions
    contract_edges = intersect(_neighbor_edges(par, v[1]), _neighbor_edges(par, v[2]))
    tn1, tn2 = p_vs_to_tn[v[1]], p_vs_to_tn[v[2]]
    inds1, inds2 = p_vs_to_noncommon_inds[v[1]], p_vs_to_noncommon_inds[v[2]]
    p_vs_to_tn[union(v[1], v[2])] = union(tn1, tn2)
    p_vs_to_noncommon_inds[union(v[1], v[2])] = union(
      setdiff(inds1, inds2), setdiff(inds2, inds1)
    )
    # The inds ordering for each edge is selected based on a
    # larger partition of the tn.
    tn, tn_inds = length(vertices(tn1)) >= length(vertices(tn2)) ? (tn1, inds1) : (tn2, inds2)
    for e in contract_edges
      source_inds = intersect(
        p_vs_to_noncommon_inds[[e.src]], p_vs_to_noncommon_inds[[e.dst]]
      )
      @assert issubset(source_inds, tn_inds)
      # Note: another more efficient implementation is below, where we first get
      # `sub_tn` of `tn` that is closely connected to `source_inds`, and then compute
      # the ordering only on top of `sub_tn`. The problem is that for multiple graphs
      # `sub_tn` will be empty. We keep the implementation below for reference.
      #=
      terminal_inds = setdiff(tn_inds, source_inds)
      p, _ = _mincut_partitions(tn, source_inds, terminal_inds)
      sub_tn = subgraph(u -> u in p, tn)
      p_edge_to_ordered_inds[e] = _mps_partition_inds_order(sub_tn, source_inds)
      =#
      p_edge_to_ordered_inds[e] = _mps_partition_inds_order(
        tn, source_inds; alg=linear_ordering_alg
      )
      # @info "tn has size", length(vertices(tn))
      # @info "out ordering is", p_edge_to_ordered_inds[e]
    end
  end
  return p_edge_to_ordered_inds
end

function _ansatz_tree(inds_orderings::Vector, ansatz::String, ortho_center::Integer)
  @assert ansatz in ["comb", "mps"]
  nested_vec_left, nested_vec_right = _nested_vector_pair(
    Algorithm(ansatz), inds_orderings, ortho_center
  )
  if nested_vec_left == [] || nested_vec_right == []
    nested_vec = nested_vec_left == [] ? nested_vec_right : nested_vec_left
  else
    nested_vec_left = length(nested_vec_left) == 1 ? nested_vec_left[1] : nested_vec_left
    nested_vec_right =
      length(nested_vec_right) == 1 ? nested_vec_right[1] : nested_vec_right
    nested_vec = [nested_vec_left, nested_vec_right]
  end
  return _nested_vector_to_digraph(nested_vec)
end

function _nested_vector_pair(
  ::Algorithm"mps", inds_orderings::Vector, ortho_center::Integer
)
  nested_vec_left = line_to_tree(vcat(inds_orderings[1:ortho_center]...))
  nested_vec_right = line_to_tree(reverse(vcat(inds_orderings[(ortho_center + 1):end]...)))
  return nested_vec_left, nested_vec_right
end

function _nested_vector_pair(
  ::Algorithm"comb", inds_orderings::Vector, ortho_center::Integer
)
  nested_vec_left = line_to_tree(
    map(ig -> line_to_tree(ig), inds_orderings[1:ortho_center])
  )
  nested_vec_right = line_to_tree(
    map(ig -> line_to_tree(ig), inds_orderings[end:-1:(ortho_center + 1)])
  )
  return nested_vec_left, nested_vec_right
end

function _ortho_center(edges::Vector, contract_edges::Vector)
  left_edges, right_edges = _split_array(edges, contract_edges)
  if length(left_edges) < length(right_edges)
    return length(left_edges) + length(contract_edges)
  end
  return length(left_edges)
end

function _permute(v::Vector, perms)
  v = copy(v)
  for p in perms
    temp = v[p]
    v[p] = v[p + 1]
    v[p + 1] = temp
  end
  return v
end

function _intervals(v1::Vector, v2::Vector; size)
  if v1 == v2
    return [v2]
  end
  perms_list = collect(Iterators.partition(_bubble_sort(v1, v2), size))
  out = [v1]
  current = v1
  for perms in perms_list
    v = _permute(current, perms)
    push!(out, v)
    current = v
  end
  return out
end
