"""
The struct is used to store cached density matrices in `approx_binary_tree_itensornetwork`.
  tensor: the cached symmetric density matric tensor
  root: the root vertex of which the density matrix tensor is computed
  children: the children vertices of the root where the density matrix tensor is computed

Example:
  Consider a tensor network below,
    1
    /\
   9  2
  /   /\
     3  6
    /|  /\
   4 5 7  8
  /  | |   \

  The density matrix for the root 3, children [4, 5] squares the subgraph
    with vertices 3, 4, 5
     |
     3
    /|
   4 5
   | |
   4 5
   |/
   3
   |

  The density matrix for the root 3, children [2, 4] squares the subgraph
    with vertices 1, 2, 3, 4, 6, 7, 8, 9
      1
      /\
     /  2
    /   /\
   /   3  6
  9   /|  /\
  |  4   7  8
  |  |   |  |
  |  4   7  8
  |  |/  | /
  |  3   6
  |  |  /
  |  | /
  |  2
  9 /
  |/
  1

  The density matrix for the root 3, children [2, 5] squares the subgraph
    with vertices 1, 2, 3, 5, 6, 7, 8, 9
      1
      /\
     /  2
    /   /\
   /   3  6
  9   /|  /\
  |    5 7  8
  |    | |  |
  |    5 7  8
  |  |/  | /
  |  3   6
  |  |  /
  |  | /
  |  2
  9 /
  |/
  1
"""
struct _DensityMatrix
  tensor::ITensor
  root::Any
  children::Vector
end

"""
The struct is used to store cached partial density matrices in `approx_binary_tree_itensornetwork`.
  tensor: the cached partial density matric tensor
  root: the root vertex of which the partial density matrix tensor is computed
  child: the child vertex of the root where the density matrix tensor is computed

Example:
  Consider a tensor network below,
    1
    /\
   9  2
  /   /\
     3  6
    /|  /\
   4 5 7  8
  /  | |   \

  The partial density matrix for the root 3, child 4 squares the subgraph
    with vertices 4, and contract with the tensor 3
    |
    3
   /
  4 - 4 -

  The partial density matrix for the root 3, child 2 squares the subgraph
    with vertices 1, 2, 6, 7, 8, 9, and contract with the tensor 3
      1
      /\
     /  2
    /   /\
   /   3  6
  9   /|  /\
  |      7  8
  |      |  |
  |      7  8
  |      | /
  |      6
  |     /
  |  | /
  |  2
  9 /
  |/
  1

  The density matrix for the root 3, children 5 squares the subgraph
    with vertices 5. and contract with the tensor 3
    |
    3
   /
  5 - 5 -
"""
struct _PartialDensityMatrix
  tensor::ITensor
  root::Any
  child::Any
end

"""
The struct contains cached density matrices and cached partial density matrices
for each vertex in the tensor network.
"""
struct _DensityMatrixAlgCaches
  v_to_cdm::Dict{Any,_DensityMatrix}
  v_to_cpdms::Dict{Any,Vector{_PartialDensityMatrix}}
end

function _DensityMatrixAlgCaches()
  v_to_cdm = Dict{Any,_DensityMatrix}()
  v_to_cpdms = Dict{Any,Vector{_PartialDensityMatrix}}()
  return _DensityMatrixAlgCaches(v_to_cdm, v_to_cpdms)
end

"""
Remove cached partial density matrices from `cpdms` whose child is in `children`
"""
function _remove_cpdms(cpdms::Vector, children)
  return filter(pdm -> !(pdm.child in children), cpdms)
end

"""
The struct stores data used in the density matrix algorithm.
  partition: The given tn partition
  out_tree: the binary tree structure of the output ITensorNetwork
  root: root vertex of the bfs_tree for truncation
  innerinds_to_sim: mapping each inner index of the tn represented by `partition` to a sim index
  caches: all the cached density matrices
"""
struct _DensityMartrixAlgGraph
  partition::DataGraph
  out_tree::NamedGraph
  root::Any
  innerinds_to_sim::Dict{<:Index,<:Index}
  caches::_DensityMatrixAlgCaches
end

function _DensityMartrixAlgGraph(partition::DataGraph, out_tree::NamedGraph, root::Any)
  innerinds = _commoninds(partition)
  sim_innerinds = [sim(ind) for ind in innerinds]
  return _DensityMartrixAlgGraph(
    partition,
    out_tree,
    root,
    Dict(zip(innerinds, sim_innerinds)),
    _DensityMatrixAlgCaches(),
  )
end

"""
Contract of a vector of tensors, `network`, with a contraction sequence generated via sa_bipartite
"""
function _optcontract(
  network::Vector; contraction_sequence_alg="optimal", contraction_sequence_kwargs=(;)
)
  @timeit_debug ITensors.timer "[approx_binary_tree_itensornetwork]: _optcontract" begin
    if length(network) == 0
      return ITensor(1.0)
    end
    @assert network isa Vector{ITensor}
    @timeit_debug ITensors.timer "[approx_binary_tree_itensornetwork]: contraction_sequence" begin
      seq = contraction_sequence(
        network; alg=contraction_sequence_alg, contraction_sequence_kwargs...
      )
    end
    output = contract(network; sequence=seq)
    return output
  end
end

function _get_low_rank_projector(tensor, inds1, inds2; cutoff, maxdim)
  @assert length(inds(tensor)) <= 4
  @timeit_debug ITensors.timer "[approx_binary_tree_itensornetwork]: eigen" begin
    diag, U = eigen(tensor, inds1, inds2; cutoff=cutoff, maxdim=maxdim, ishermitian=true)
  end
  return U
end

"""
Returns a dict that maps the partition's outinds that are adjacent to `partition[root]` to siminds
"""
function _densitymatrix_outinds_to_sim(partition, root)
  outinds = _noncommoninds(partition)
  outinds_root = intersect(outinds, noncommoninds(Vector{ITensor}(partition[root])...))
  outinds_root_to_sim = Dict(zip(outinds_root, [sim(ind) for ind in outinds_root]))
  return outinds_root_to_sim
end

"""
Replace the inds of partial_dm_tensor that are in keys of `inds_to_siminds` to the
corresponding value, and replace the inds that are in values of `inds_to_siminds`
to the corresponding key.
"""
function _sim(partial_dm_tensor::ITensor, inds_to_siminds)
  siminds_to_inds = Dict(zip(values(inds_to_siminds), keys(inds_to_siminds)))
  indices = keys(inds_to_siminds)
  indices = intersect(indices, inds(partial_dm_tensor))
  simindices = setdiff(inds(partial_dm_tensor), indices)
  reorder_inds = [indices..., simindices...]
  reorder_siminds = vcat(
    [inds_to_siminds[i] for i in indices], [siminds_to_inds[i] for i in simindices]
  )
  return replaceinds(partial_dm_tensor, reorder_inds => reorder_siminds)
end

"""
Return the partial density matrix whose root is `v` and root child is `child_v`.
If the tensor is in `partial_dms`, just return the tensor without contraction.
"""
function _get_pdm(
  partial_dms::Vector{_PartialDensityMatrix},
  v,
  child_v,
  child_dm_tensor,
  network;
  contraction_sequence_alg,
  contraction_sequence_kwargs,
)
  for partial_dm in partial_dms
    if partial_dm.child == child_v
      return partial_dm
    end
  end
  tensor = _optcontract(
    [child_dm_tensor, network...]; contraction_sequence_alg, contraction_sequence_kwargs
  )
  return _PartialDensityMatrix(tensor, v, child_v)
end

"""
Update `caches.v_to_cdm[v]` and `caches.v_to_cpdms[v]`.
  caches: the caches of the density matrix algorithm.
  v: the density matrix root
  children: the children vertices of `v` in the dfs_tree
  root: the root vertex of the truncation algorithm
  network: the tensor network at vertex `v`
  inds_to_sim: a dict mapping inds to sim inds
"""
function _update!(
  caches::_DensityMatrixAlgCaches,
  v::Any,
  children::Vector,
  root::Any,
  network::Vector{ITensor},
  inds_to_sim;
  contraction_sequence_alg,
  contraction_sequence_kwargs,
)
  if haskey(caches.v_to_cdm, v) && caches.v_to_cdm[v].children == children && v != root
    @assert haskey(caches.v_to_cdm, v)
    return nothing
  end
  child_to_dm = [c => caches.v_to_cdm[c].tensor for c in children]
  if !haskey(caches.v_to_cpdms, v)
    caches.v_to_cpdms[v] = []
  end
  cpdms = [
    _get_pdm(
      caches.v_to_cpdms[v],
      v,
      child_v,
      dm_tensor,
      network;
      contraction_sequence_alg,
      contraction_sequence_kwargs,
    ) for (child_v, dm_tensor) in child_to_dm
  ]
  if length(cpdms) == 0
    sim_network = map(x -> replaceinds(x, inds_to_sim), network)
    density_matrix = _optcontract(
      [network..., sim_network...]; contraction_sequence_alg, contraction_sequence_kwargs
    )
  elseif length(cpdms) == 1
    sim_network = map(x -> replaceinds(x, inds_to_sim), network)
    density_matrix = _optcontract(
      [cpdms[1].tensor, sim_network...];
      contraction_sequence_alg,
      contraction_sequence_kwargs,
    )
  else
    simtensor = _sim(cpdms[2].tensor, inds_to_sim)
    density_matrix = _optcontract(
      [cpdms[1].tensor, simtensor]; contraction_sequence_alg, contraction_sequence_kwargs
    )
  end
  caches.v_to_cdm[v] = _DensityMatrix(density_matrix, v, children)
  caches.v_to_cpdms[v] = cpdms
  return nothing
end

"""
Perform truncation and remove `root` vertex in the `partition` and `out_tree`
of `alg_graph`.

Example:
  Consider an `alg_graph`` whose `out_tree` is shown below,
    1
    /\
   9  2
  /   /\
     3  6
    /|  /\
   4 5 7  8
  /  | |   \
  when `root = 4`, the output `out_tree` will be
    1
    /\
   9  2
  /   /\
     3  6
    /|  /\
     5 7  8
     | |   \
  and the returned tensor `U` will be the projector at vertex 4 in the output tn.
"""
function _rem_vertex!(
  alg_graph::_DensityMartrixAlgGraph,
  root;
  cutoff,
  maxdim,
  contraction_sequence_alg,
  contraction_sequence_kwargs,
)
  caches = alg_graph.caches
  outinds_root_to_sim = _densitymatrix_outinds_to_sim(alg_graph.partition, root)
  inds_to_sim = merge(alg_graph.innerinds_to_sim, outinds_root_to_sim)
  dm_dfs_tree = dfs_tree(alg_graph.out_tree, root)
  @assert length(child_vertices(dm_dfs_tree, root)) == 1
  for v in post_order_dfs_vertices(dm_dfs_tree, root)
    children = sort(child_vertices(dm_dfs_tree, v))
    @assert length(children) <= 2
    network = Vector{ITensor}(alg_graph.partition[v])
    _update!(
      caches,
      v,
      children,
      root,
      Vector{ITensor}(network),
      inds_to_sim;
      contraction_sequence_alg,
      contraction_sequence_kwargs,
    )
  end
  U = _get_low_rank_projector(
    caches.v_to_cdm[root].tensor,
    collect(values(outinds_root_to_sim)),
    collect(keys(outinds_root_to_sim));
    cutoff,
    maxdim,
  )
  # update partition and out_tree
  root_tensor = _optcontract(
    [Vector{ITensor}(alg_graph.partition[root])..., U];
    contraction_sequence_alg,
    contraction_sequence_kwargs,
  )
  new_root = child_vertices(dm_dfs_tree, root)[1]
  alg_graph.partition[new_root] = disjoint_union(
    alg_graph.partition[new_root], ITensorNetwork([root_tensor])
  )
  rem_vertex!(alg_graph.partition, root)
  rem_vertex!(alg_graph.out_tree, root)
  # update v_to_cpdms[new_root]
  delete!(caches.v_to_cpdms, root)
  truncate_dfs_tree = dfs_tree(alg_graph.out_tree, alg_graph.root)
  caches.v_to_cpdms[new_root] = _remove_cpdms(
    caches.v_to_cpdms[new_root], child_vertices(truncate_dfs_tree, new_root)
  )
  @assert length(caches.v_to_cpdms[new_root]) <= 1
  caches.v_to_cpdms[new_root] = [
    _PartialDensityMatrix(
      _optcontract(
        [cpdm.tensor, root_tensor]; contraction_sequence_alg, contraction_sequence_kwargs
      ),
      new_root,
      cpdm.child,
    ) for cpdm in caches.v_to_cpdms[new_root]
  ]
  return U
end

"""
For a given ITensorNetwork `tn` and a `root` vertex, remove leaf vertices in the directed tree
with root `root` without changing the tensor represented by tn.
In particular, the tensor of each leaf vertex is contracted with the tensor of its parent vertex
to keep the tensor unchanged.
"""
function _rem_leaf_vertices!(
  tn::ITensorNetwork;
  root=first(vertices(tn)),
  contraction_sequence_alg,
  contraction_sequence_kwargs,
)
  dfs_t = dfs_tree(tn, root)
  leaves = leaf_vertices(dfs_t)
  parents = [parent_vertex(dfs_t, leaf) for leaf in leaves]
  for (l, p) in zip(leaves, parents)
    tn[p] = _optcontract(
      [tn[p], tn[l]]; contraction_sequence_alg, contraction_sequence_kwargs
    )
    rem_vertex!(tn, l)
  end
end

"""
Approximate a `partition` into an output ITensorNetwork
with the binary tree structure defined by `out_tree`.
"""
function _approx_binary_tree_itensornetwork!(
  input_partition::DataGraph,
  out_tree::NamedGraph;
  root=first(vertices(partition)),
  cutoff=1e-15,
  maxdim=10000,
  contraction_sequence_alg,
  contraction_sequence_kwargs,
)
  # Change type of each partition[v] since they will be updated
  # with potential data type chage.
  partition = DataGraph()
  for v in vertices(input_partition)
    add_vertex!(partition, v)
    partition[v] = ITensorNetwork{Any}(input_partition[v])
  end
  @assert sort(vertices(partition)) == sort(vertices(out_tree))
  alg_graph = _DensityMartrixAlgGraph(partition, out_tree, root)
  output_tn = ITensorNetwork()
  for v in post_order_dfs_vertices(out_tree, root)[1:(end - 1)]
    U = _rem_vertex!(
      alg_graph, v; cutoff, maxdim, contraction_sequence_alg, contraction_sequence_kwargs
    )
    add_vertex!(output_tn, v)
    output_tn[v] = U
  end
  @assert length(vertices(partition)) == 1
  add_vertex!(output_tn, root)
  root_tensor = _optcontract(
    Vector{ITensor}(partition[root]); contraction_sequence_alg, contraction_sequence_kwargs
  )
  root_norm = norm(root_tensor)
  root_tensor /= root_norm
  output_tn[root] = root_tensor
  return output_tn, log(root_norm)
end

"""
Approximate a `binary_tree_partition` into an output ITensorNetwork
with the same binary tree structure. `root` is the root vertex of the
pre-order depth-first-search traversal used to perform the truncations.
"""
function approx_itensornetwork(
  ::Algorithm"density_matrix",
  binary_tree_partition::DataGraph;
  root,
  cutoff=1e-15,
  maxdim=10000,
  contraction_sequence_alg,
  contraction_sequence_kwargs,
)
  @assert is_tree(binary_tree_partition)
  @assert root in vertices(binary_tree_partition)
  @assert _is_rooted_directed_binary_tree(dfs_tree(binary_tree_partition, root))
  # The `binary_tree_partition` may contain multiple delta tensors to make sure
  # the partition has a binary tree structure. These delta tensors could hurt the
  # performance when computing density matrices so we remove them first.
  partition_wo_deltas = _contract_deltas_ignore_leaf_partitions(
    binary_tree_partition; root=root
  )
  return _approx_binary_tree_itensornetwork!(
    partition_wo_deltas,
    underlying_graph(binary_tree_partition);
    root,
    cutoff,
    maxdim,
    contraction_sequence_alg,
    contraction_sequence_kwargs,
  )
end

"""
Approximate a given ITensorNetwork `tn` into an output ITensorNetwork with `output_structure`.
`output_structure` outputs a directed binary tree DataGraph defining the desired graph structure.
"""
function approx_itensornetwork(
  ::Algorithm"density_matrix",
  tn::ITensorNetwork,
  output_structure::Function=path_graph_structure;
  cutoff,
  maxdim,
  contraction_sequence_alg,
  contraction_sequence_kwargs,
)
  inds_btree = output_structure(tn)
  return approx_itensornetwork(
    tn,
    inds_btree;
    alg="density_matrix",
    cutoff=cutoff,
    maxdim=maxdim,
    contraction_sequence_alg=contraction_sequence_alg,
    contraction_sequence_kwargs=contraction_sequence_kwargs,
  )
end

"""
Approximate a given ITensorNetwork `tn` into an output ITensorNetwork
with a binary tree structure. The binary tree structure is defined based
on `inds_btree`, which is a directed binary tree DataGraph of indices.
"""
function approx_itensornetwork(
  ::Algorithm"density_matrix",
  tn::ITensorNetwork,
  inds_btree::DataGraph;
  cutoff=1e-15,
  maxdim=10000,
  contraction_sequence_alg="optimal",
  contraction_sequence_kwargs=(;),
)
  par = partition(tn, inds_btree; alg="mincut_recursive_bisection")
  output_tn, log_root_norm = approx_itensornetwork(
    par;
    alg="density_matrix",
    root=_root(inds_btree),
    cutoff=cutoff,
    maxdim=maxdim,
    contraction_sequence_alg=contraction_sequence_alg,
    contraction_sequence_kwargs=contraction_sequence_kwargs,
  )
  # Each leaf vertex in `output_tn` is adjacent to one output index.
  # We remove these leaf vertices so that each non-root vertex in `output_tn`
  # is an order 3 tensor.
  _rem_leaf_vertices!(
    output_tn;
    root=_root(inds_btree),
    contraction_sequence_alg=contraction_sequence_alg,
    contraction_sequence_kwargs=contraction_sequence_kwargs,
  )
  return output_tn, log_root_norm
end

function approx_itensornetwork(
  partitioned_tn::DataGraph;
  alg::String,
  root,
  cutoff=1e-15,
  maxdim=10000,
  contraction_sequence_alg="optimal",
  contraction_sequence_kwargs=(;),
)
  return approx_itensornetwork(
    Algorithm(alg),
    partitioned_tn;
    root,
    cutoff,
    maxdim,
    contraction_sequence_alg,
    contraction_sequence_kwargs,
  )
end

function approx_itensornetwork(
  tn::ITensorNetwork,
  inds_btree::DataGraph;
  alg::String,
  cutoff=1e-15,
  maxdim=10000,
  contraction_sequence_alg="optimal",
  contraction_sequence_kwargs=(;),
)
  return approx_itensornetwork(
    Algorithm(alg),
    tn,
    inds_btree;
    cutoff,
    maxdim,
    contraction_sequence_alg,
    contraction_sequence_kwargs,
  )
end

function approx_itensornetwork(
  tn::ITensorNetwork,
  output_structure::Function;
  alg::String,
  cutoff=1e-15,
  maxdim=10000,
  contraction_sequence_alg="optimal",
  contraction_sequence_kwargs=(;),
)
  return approx_itensornetwork(
    Algorithm(alg),
    tn,
    output_structure;
    cutoff,
    maxdim,
    contraction_sequence_alg,
    contraction_sequence_kwargs,
  )
end
