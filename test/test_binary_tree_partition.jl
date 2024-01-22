using ITensors, OMEinsumContractionOrders
using Graphs, NamedGraphs
using KaHyPar, Metis
using ITensors: contract
using ITensorNetworks:
  _root,
  _mps_partition_inds_order,
  _mincut_partitions,
  _is_rooted_directed_binary_tree,
  _contract_deltas_ignore_leaf_partitions,
  _rem_vertex!,
  _DensityMartrixAlgGraph

@testset "test mincut and partition functions on top of MPS" begin
  function _build_tn_inds(num)
    is = [Index(2, string(i)) for i in 1:num]
    T = randomITensor(is...)
    M = MPS(T, Tuple(is); cutoff=1e-5, maxdim=500)
    tn = ITensorNetwork(M[:])
    return tn, is
  end
  for num in [6, 8]
    tn, is = _build_tn_inds(num)
    for alg in ["top_down", "bottom_up"]
      for out in [binary_tree_structure(tn; alg=alg), path_graph_structure(tn; alg=alg)]
        @test out isa DataGraph
        @test _is_rooted_directed_binary_tree(out)
        @test length(vertex_data(out).values) == num
      end
      out = _mps_partition_inds_order(tn, is; alg=alg)
      @test out in [is, reverse(is)]
    end
  end
end

@testset "test _mincut_partitions" begin
  is = [Index(2, string(i)) for i in 1:8]
  T = randomITensor(is...)

  M = MPS(T, Tuple(is); cutoff=1e-5, maxdim=500)
  tn = ITensorNetwork(M[:])
  p1, p2 = _mincut_partitions(tn, [is[3], is[4]], [is[5], is[6]])
  # When MPS bond dimensions are large, the partition will not across internal inds
  @test (length(p1) == 0) || (length(p2) == 0)

  M = MPS(T, Tuple(is); cutoff=1e-5, maxdim=2)
  tn = ITensorNetwork(M[:])
  p1, p2 = _mincut_partitions(tn, [is[3], is[4]], [is[5], is[6]])
  # When MPS bond dimensions are small, the partition will across internal inds
  @test sort(p1) == [1, 2, 3, 4]
  @test sort(p2) == [5, 6, 7, 8]
end

@testset "test _mps_partition_inds_order of a sub 2D grid" begin
  N = (8, 8)
  linkdim = 2
  network = randomITensorNetwork(IndsNetwork(named_grid(N)); link_space=linkdim)
  tn = Array{ITensor,length(N)}(undef, N...)
  for v in vertices(network)
    tn[v...] = network[v...]
  end
  tensors = vec(tn)[1:20]
  tn = ITensorNetwork(tensors)
  # @info _mps_partition_inds_order(tn, noncommoninds(tensors...); alg="top_down")
  # TODO: this case is not supported for now, since two indices are adjacent to
  # one tensor.
end

@testset "test _binary_tree_partition_inds of a 2D network" begin
  N = (3, 3, 3)
  linkdim = 2
  network = randomITensorNetwork(IndsNetwork(named_grid(N)); link_space=linkdim)
  tn = Array{ITensor,length(N)}(undef, N...)
  for v in vertices(network)
    tn[v...] = network[v...]
  end
  tn = ITensorNetwork(vec(tn[:, :, 1]))
  for alg in ["top_down", "bottom_up"]
    for out in [binary_tree_structure(tn; alg=alg), path_graph_structure(tn; alg=alg)]
      @test out isa DataGraph
      @test _is_rooted_directed_binary_tree(out)
      @test length(vertex_data(out).values) == 9
    end
  end
end

@testset "test partition with mincut_recursive_bisection alg of disconnected tn" begin
  inds = [Index(2, "$i") for i in 1:5]
  tn = ITensorNetwork([randomITensor(i) for i in inds])
  for alg in ["top_down", "bottom_up"]
    par = partition(
      tn, binary_tree_structure(tn; alg=alg); alg="mincut_recursive_bisection"
    )
    networks = [Vector{ITensor}(par[v]) for v in vertices(par)]
    network = vcat(networks...)
    @test isapprox(contract(Vector{ITensor}(tn)), contract(network...))
  end
end

@testset "test partition with mincut_recursive_bisection alg and approx_itensornetwork" begin
  i = Index(2, "i")
  j = Index(2, "j")
  k = Index(2, "k")
  l = Index(2, "l")
  m = Index(2, "m")
  for dtype in [Float64, ComplexF64]
    T = randomITensor(dtype, i, j, k, l, m)
    M = MPS(T, (i, j, k, l, m); cutoff=1e-5, maxdim=5)
    network = M[:]
    out1 = contract(network...)
    tn = ITensorNetwork(network)
    inds_btree = binary_tree_structure(tn)
    par = partition(tn, inds_btree; alg="mincut_recursive_bisection")
    par = _contract_deltas_ignore_leaf_partitions(par; root=_root(inds_btree))
    networks = [Vector{ITensor}(par[v]) for v in vertices(par)]
    network2 = vcat(networks...)
    out2 = contract(network2...)
    @test isapprox(out1, out2)
    # test approx_itensornetwork (here we call `contract` to test the interface)
    for structure in [path_graph_structure, binary_tree_structure]
      for alg in ["density_matrix", "ttn_svd"]
        approx_tn, lognorm = contract(
          tn; alg=alg, output_structure=structure, contraction_sequence_alg="sa_bipartite"
        )
        network3 = Vector{ITensor}(approx_tn)
        out3 = contract(network3...) * exp(lognorm)
        i1 = noncommoninds(network...)
        i3 = noncommoninds(network3...)
        @test (length(i1) == length(i3))
        @test isapprox(out1, out3)
      end
    end
  end
end

@testset "test caching in approx_itensornetwork" begin
  i = Index(2, "i")
  j = Index(2, "j")
  k = Index(2, "k")
  l = Index(2, "l")
  m = Index(2, "m")
  T = randomITensor(i, j, k, l, m)
  M = MPS(T, (i, j, k, l, m); cutoff=1e-5, maxdim=5)
  tn = ITensorNetwork(M[:])
  out_tree = path_graph_structure(tn)
  input_partition = partition(tn, out_tree; alg="mincut_recursive_bisection")
  underlying_tree = underlying_graph(input_partition)
  # Change type of each partition[v] since they will be updated
  # with potential data type chage.
  p = DataGraph()
  for v in vertices(input_partition)
    add_vertex!(p, v)
    p[v] = ITensorNetwork{Any}(input_partition[v])
  end
  alg_graph = _DensityMartrixAlgGraph(p, underlying_tree, _root(out_tree))
  path = post_order_dfs_vertices(underlying_tree, _root(out_tree))
  for v in path[1:2]
    _rem_vertex!(
      alg_graph,
      v;
      cutoff=1e-15,
      maxdim=10000,
      contraction_sequence_alg="optimal",
      contraction_sequence_kwargs=(;),
    )
  end
  # Check that a specific density matrix info has been cached
  @test haskey(alg_graph.caches.es_to_pdm, Set([NamedEdge(nothing, path[3])]))
end
