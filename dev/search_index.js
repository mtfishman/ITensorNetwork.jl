var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ITensorNetworks","category":"page"},{"location":"#ITensorNetworks","page":"Home","title":"ITensorNetworks","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ITensorNetworks.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ITensorNetworks]","category":"page"},{"location":"#ITensorNetworks.CURRENT_PARTITIONING_BACKEND","page":"Home","title":"ITensorNetworks.CURRENT_PARTITIONING_BACKEND","text":"Current default graph partitioning backend\n\n\n\n\n\n","category":"constant"},{"location":"#ITensorNetworks.Backend","page":"Home","title":"ITensorNetworks.Backend","text":"Graph partitioning backend\n\n\n\n\n\n","category":"type"},{"location":"#ITensorNetworks.ITensorNetwork","page":"Home","title":"ITensorNetworks.ITensorNetwork","text":"ITensorNetwork\n\n\n\n\n\n","category":"type"},{"location":"#ITensorNetworks.ProjTTN","page":"Home","title":"ITensorNetworks.ProjTTN","text":"ProjTTN\n\n\n\n\n\n","category":"type"},{"location":"#ITensorNetworks.ProjTTNSum","page":"Home","title":"ITensorNetworks.ProjTTNSum","text":"ProjTTNSum\n\n\n\n\n\n","category":"type"},{"location":"#ITensorNetworks.SweepStep","page":"Home","title":"ITensorNetworks.SweepStep","text":"struct SweepStep{V}\n\nAuxiliary object specifying a single local update step in a tree sweeping algorithm.\n\n\n\n\n\n","category":"type"},{"location":"#ITensorNetworks.TDVPInfo","page":"Home","title":"ITensorNetworks.TDVPInfo","text":"#fields\n\nmaxtruncerr::Float64: the maximum tuncation error\n\n\n\n\n\n","category":"type"},{"location":"#ITensorNetworks.TTN-Union{Tuple{V}, Tuple{ITensors.LazyApply.Applied{typeof(sum), Tuple{Array{ITensors.LazyApply.Applied{typeof(*), Tuple{C, ITensors.LazyApply.Prod{ITensors.Ops.Op}}, NamedTuple{(), Tuple{}}}, 1}}, NamedTuple{(), Tuple{}}} where C, IndsNetwork{V, <:ITensors.Index}}} where V","page":"Home","title":"ITensorNetworks.TTN","text":"TTN(os::OpSum, sites::IndsNetwork{<:Index}; kwargs...)\nTTN(eltype::Type{<:Number}, os::OpSum, sites::IndsNetwork{<:Index}; kwargs...)\n\nConvert an OpSum object os to a TreeTensorNetwork, with indices given by sites.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.TreeTensorNetwork","page":"Home","title":"ITensorNetworks.TreeTensorNetwork","text":"TreeTensorNetwork{V} <: AbstractTreeTensorNetwork{V}\n\nFields\n\nitensor_network::ITensorNetwork{V}\northo_lims::Vector{V}: A vector of vertices defining the orthogonality limits.\n\n\n\n\n\n","category":"type"},{"location":"#ITensorNetworks._binary_partition-Tuple{ITensorNetwork, Vector{ITensors.ITensor}, Vector{<:ITensors.Index}}","page":"Home","title":"ITensorNetworks._binary_partition","text":"Partition the input network containing both tn and deltas (a vector of delta tensors) into two partitions, one adjacent to source_inds and the other adjacent to other external inds of the network.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._binary_tree_structure-Tuple{ITensorNetwork, Vector{<:ITensors.Index}}","page":"Home","title":"ITensorNetworks._binary_tree_structure","text":"Given a tn and outinds (a subset of noncommoninds of tn), get a DataGraph with binary tree structure of outinds that will be used in the binary tree partition. If maximally_unbalanced=true, the binary tree will have a line/mps structure. The binary tree is recursively constructed from leaves to the root.\n\nExample:\n\nTODO\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._distance-Tuple{ITensorNetwork, Vector{<:ITensors.Index}}","page":"Home","title":"ITensorNetworks._distance","text":"Sum of shortest path distances among all outinds.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._introot_union!-Tuple{DataStructures.IntDisjointSets, Any, Any}","page":"Home","title":"ITensorNetworks._introot_union!","text":"Rewrite of the function   DataStructures.root_union!(s::IntDisjointSet{T}, x::T, y::T) where {T<:Integer}.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._is_directed_binary_tree-Union{Tuple{var\"##331\"}, Tuple{Type{Graphs.IsDirected{var\"##331\"}}, var\"##331\"}} where var\"##331\"<:DataGraphs.AbstractDataGraph","page":"Home","title":"ITensorNetworks._is_directed_binary_tree","text":"Check if a data graph is a directed binary tree\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._maxweightoutinds_tn-Tuple{ITensorNetwork, Union{Nothing, Vector{<:ITensors.Index}}}","page":"Home","title":"ITensorNetworks._maxweightoutinds_tn","text":"create a tn with empty ITensors whose outinds weights are MAXWEIGHT The maxweighttn is constructed so that only commoninds of the tn will be considered in mincut.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._mincut-Tuple{ITensorNetwork, Vector{<:ITensors.Index}, Vector{<:ITensors.Index}}","page":"Home","title":"ITensorNetworks._mincut","text":"Calculate the mincut between two subsets of the uncontracted inds (sourceinds and terminalinds) of the input tn. Mincut of two inds list is defined as the mincut of two newly added vertices, each one neighboring to one inds subset.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._mincut_inds-Tuple{Pair{<:ITensorNetwork, <:ITensorNetwork}, Dict{ITensors.Index, ITensors.Index}, Vector{<:Vector{<:ITensors.Index}}}","page":"Home","title":"ITensorNetworks._mincut_inds","text":"Find a vector of indices within sourceindslist yielding the mincut of given tnpair. Args:   tnpair: a pair of tns (tn1 => tn2), where tn2 is generated via _maxweightoutindstn(tn1)   outtomaxweightind: a dict mapping each out ind in tn1 to out ind in tn2   sourceindslist: a list of vector of indices to be considered Note:   For each sourceinds in sourceindslist, we consider its mincut within both tns (tn1, tn2) given in tnpair.   The mincut in tn1 represents the rank upper bound when splitting sourceinds with other inds in outinds.   The mincut in tn2 represents the rank upper bound when the weights of outinds are very large.   The first mincut upper_bounds the number of non-zero singular values, while the second empirically reveals the   singular value decay.   We output the sourceinds where the first mincut value is the minimum, the secound mincut value is also   the minimum under the condition that the first mincut is optimal, and the sourceinds have the lowest all-pair shortest path.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._mincut_partitions-Tuple{ITensorNetwork, Vector{<:ITensors.Index}, Vector{<:ITensors.Index}}","page":"Home","title":"ITensorNetworks._mincut_partitions","text":"Calculate the mincutpartitions between two subsets of the uncontracted inds (sourceinds and terminal_inds) of the input tn.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._mps_partition_inds_order-Tuple{ITensorNetwork, Union{Nothing, Vector{<:ITensors.Index}}}","page":"Home","title":"ITensorNetworks._mps_partition_inds_order","text":"Given a tn and outinds, returns a vector of indices representing MPS inds ordering.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._remove_deltas-Tuple{ITensorNetwork, Vector{ITensors.ITensor}}","page":"Home","title":"ITensorNetworks._remove_deltas","text":"Given an input tensor network containing tensors in the input tnand tensors indeltas`, remove redundent delta tensors indeltasand change inds accordingly to make the outputtnandoutdeltasrepresent the same tensor network but with less delta tensors. Note: inds of tensors intnanddeltasmay be changed, andoutdeltas`   may still contain necessary delta tensors.\n\n======== Example:   julia> is = [Index(2, \"i\") for i in 1:6]   julia> a = ITensor(is[1], is[2])   julia> b = ITensor(is[2], is[3])   julia> delta1 = delta(is[3], is[4])   julia> delta2 = delta(is[5], is[6])   julia> tn = ITensorNetwork([a,b])   julia> tn, outdeltas = ITensorNetworks.removedeltas(tn, [delta1, delta2])   julia> noncommoninds(Vector{ITensor}(tn)...)   2-element Vector{Index{Int64}}:    (dim=2|id=339|\"1\")    (dim=2|id=489|\"4\")   julia> length(outdeltas)   1\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._root-Union{Tuple{var\"##330\"}, Tuple{Type{Graphs.IsDirected{var\"##330\"}}, var\"##330\"}} where var\"##330\"<:DataGraphs.AbstractDataGraph","page":"Home","title":"ITensorNetworks._root","text":"Return the root vertex of a directed tree data graph\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks._root_union!-Tuple{DataStructures.DisjointSets, Any, Any}","page":"Home","title":"ITensorNetworks._root_union!","text":"Rewrite of the function DataStructures.root_union!(s::DisjointSet{T}, x::T, y::T). The difference is that in the output of _root_union!, x is guaranteed to be the root of y when setting left_root=true, and y will be the root of x when setting left_root=false. In DataStructures.root_union!, the root value cannot be specified. A specified root is useful in functions such as _remove_deltas, where when we union two indices into one disjointset, we want the index that is the outinds if the given tensor network to always be the root in the DisjointSets.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.alternating_update-Tuple{Any, Vector{<:ITensorNetworks.AbstractTreeTensorNetwork}, Number, ITensorNetworks.AbstractTreeTensorNetwork}","page":"Home","title":"ITensorNetworks.alternating_update","text":"tdvp(Hs::Vector{MPO},psi0::MPS,t::Number; kwargs...)\ntdvp(Hs::Vector{MPO},psi0::MPS,t::Number, sweeps::Sweeps; kwargs...)\n\nUse the time dependent variational principle (TDVP) algorithm to compute exp(t*H)*psi0 using an efficient algorithm based on alternating optimization of the MPS tensors and local Krylov exponentiation of H.\n\nThis version of tdvp accepts a representation of H as a Vector of MPOs, Hs = [H1,H2,H3,...] such that H is defined as H = H1+H2+H3+... Note that this sum of MPOs is not actually computed; rather the set of MPOs [H1,H2,H3,..] is efficiently looped over at  each step of the algorithm when optimizing the MPS.\n\nReturns:\n\npsi::MPS - time-evolved MPS\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.binary_tree_structure-Tuple{ITensorNetwork, Vector{<:ITensors.Index}}","page":"Home","title":"ITensorNetworks.binary_tree_structure","text":"Given a tn and outinds (a subset of noncommoninds of tn), outputs a directed binary tree DataGraph of outinds defining the desired graph structure\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.binary_tree_structure-Tuple{ITensorNetwork}","page":"Home","title":"ITensorNetworks.binary_tree_structure","text":"Outputs a directed binary tree DataGraph defining the desired graph structure\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.calculate_contraction-Tuple{ITensorNetwork, DataGraph, Vector}","page":"Home","title":"ITensorNetworks.calculate_contraction","text":"Calculate the contraction of a tensor network centred on the vertices verts. Using message tensors. Defaults to using tn[verts] as the local network but can be overriden\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.compute_message_tensors-Tuple{ITensorNetwork}","page":"Home","title":"ITensorNetworks.compute_message_tensors","text":"Simulaneously initialise and update message tensors of a tensornetwork\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.contraction_sequence-Tuple{NDTensors.Algorithm{:greedy}, Vector{ITensors.ITensor}}","page":"Home","title":"ITensorNetworks.contraction_sequence","text":"GreedyMethod(; method=MinSpaceOut(), nrepeat=10)\n\nThe fast but poor greedy optimizer. Input arguments are:\n\nmethod is MinSpaceDiff() or MinSpaceOut.\nMinSpaceOut choose one of the contraction that produces a minimum output tensor size,\nMinSpaceDiff choose one of the contraction that decrease the space most.\nnrepeat is the number of repeatition, returns the best contraction order.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.contraction_sequence-Tuple{NDTensors.Algorithm{:kahypar_bipartite}, Any}","page":"Home","title":"ITensorNetworks.contraction_sequence","text":"KaHyParBipartite(; sc_target, imbalances=collect(0.0:0.005:0.8),\n                   max_group_size=40, greedy_config=GreedyMethod())\n\nOptimize the einsum code contraction order using the KaHyPar + Greedy approach. This program first recursively cuts the tensors into several groups using KaHyPar, with maximum group size specifed by max_group_size and maximum space complexity specified by sc_target, Then finds the contraction order inside each group with the greedy search algorithm. Other arguments are:\n\nsc_target is the target space complexity, defined as log2(number of elements in the largest tensor),\nimbalances is a KaHyPar parameter that controls the group sizes in hierarchical bipartition,\nmax_group_size is the maximum size that allowed to used greedy search,\ngreedy_config is a greedy optimizer.\n\nReferences\n\nHyper-optimized tensor network contraction\nSimulating the Sycamore quantum supremacy circuits\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.contraction_sequence-Tuple{NDTensors.Algorithm{:sa_bipartite}, Any}","page":"Home","title":"ITensorNetworks.contraction_sequence","text":"SABipartite(; sc_target=25, ntrials=50, βs=0.1:0.2:15.0, niters=1000\n              max_group_size=40, greedy_config=GreedyMethod(), initializer=:random)\n\nOptimize the einsum code contraction order using the Simulated Annealing bipartition + Greedy approach. This program first recursively cuts the tensors into several groups using simulated annealing, with maximum group size specifed by max_group_size and maximum space complexity specified by sc_target, Then finds the contraction order inside each group with the greedy search algorithm. Other arguments are:\n\nsize_dict, a dictionary that specifies leg dimensions,\nsc_target is the target space complexity, defined as log2(number of elements in the largest tensor),\nmax_group_size is the maximum size that allowed to used greedy search,\nβs is a list of inverse temperature 1/T,\nniters is the number of iteration in each temperature,\nntrials is the number of repetition (with different random seeds),\ngreedy_config configures the greedy method,\ninitializer, the partition configuration initializer, one can choose :random or :greedy (slow but better).\n\nReferences\n\nHyper-optimized tensor network contraction\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.contraction_sequence-Tuple{NDTensors.Algorithm{:tree_sa}, Any}","page":"Home","title":"ITensorNetworks.contraction_sequence","text":"TreeSA(; sc_target=20, βs=collect(0.01:0.05:15), ntrials=10, niters=50,\n         sc_weight=1.0, rw_weight=0.2, initializer=:greedy, greedy_config=GreedyMethod(; nrepeat=1))\n\nOptimize the einsum contraction pattern using the simulated annealing on tensor expression tree.\n\nsc_target is the target space complexity,\nntrials, βs and niters are annealing parameters, doing ntrials indepedent annealings, each has inverse tempteratures specified by βs, in each temperature, do niters updates of the tree.\nsc_weight is the relative importance factor of space complexity in the loss compared with the time complexity.\nrw_weight is the relative importance factor of memory read and write in the loss compared with the time complexity.\ninitializer specifies how to determine the initial configuration, it can be :greedy or :random. If it is using :greedy method to generate the initial configuration, it also uses two extra arguments greedy_method and greedy_nrepeat.\nnslices is the number of sliced legs, default is 0.\nfixed_slices is a vector of sliced legs, default is [].\n\nReferences\n\nRecursive Multi-Tensor Contraction for XEB Verification of Quantum Circuits\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.contraction_sequence_to_graph-Tuple{Any}","page":"Home","title":"ITensorNetworks.contraction_sequence_to_graph","text":"Take a contractionsequence and return a graphical representation of it. The leaves of the graph represent the leaves of the sequence whilst the internalnodes of the graph define a tripartition of the graph and thus are named as an n = 3 element tuples, which each element specifying the keys involved. Edges connect parents/children within the contraction sequence.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.contraction_tree_leaf_bipartition-Tuple{Graphs.AbstractGraph, Any}","page":"Home","title":"ITensorNetworks.contraction_tree_leaf_bipartition","text":"Get the vertex bi-partition that a given edge represents\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.current_partitioning_backend-Tuple{}","page":"Home","title":"ITensorNetworks.current_partitioning_backend","text":"Get the graph partitioning backend\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.delta_network-Tuple{Type, IndsNetwork}","page":"Home","title":"ITensorNetworks.delta_network","text":"RETURN A TENSOR NETWORK WITH COPY TENSORS ON EACH VERTEX.  Note that passing a link_space will mean the indices of the resulting network don't match those of the input indsnetwork\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.distance_from_roots-Tuple{Graphs.AbstractGraph, Int64}","page":"Home","title":"ITensorNetworks.distance_from_roots","text":"Return all vertices which are within a certain pathlength dist of the leaves of the  graph\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.distance_to_leaf-Tuple{Graphs.AbstractGraph, Any}","page":"Home","title":"ITensorNetworks.distance_to_leaf","text":"Get distance of a vertex from a leaf\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.fidelity-Tuple{Vector{ITensors.ITensor}, ITensors.ITensor, ITensors.ITensor, ITensors.ITensor, ITensors.ITensor, ITensors.ITensor}","page":"Home","title":"ITensorNetworks.fidelity","text":"Calculate the overlap of the gate acting on the previous p and q versus the new p and q in the presence of environments. This is the cost function that optimisepq will minimise\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.fill_contraction_sequence_graph_vertices!-Tuple{Any, Any, Any}","page":"Home","title":"ITensorNetworks.fill_contraction_sequence_graph_vertices!","text":"Given a contraction sequence which is a subsequence of some larger sequence (with leaves leaves) which is being built on g Spawn contract sequence' as a vertex oncurrent_g' and continue on with its children \n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.find_subgraph-Tuple{Any, DataGraph}","page":"Home","title":"ITensorNetworks.find_subgraph","text":"Find the subgraph which contains the specified vertex.\n\nTODO: Rename something more general, like:\n\nfindfirstinvertex_data(item, graph::AbstractDataGraph)\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.findall_on_edges-Tuple{Function, DataGraphs.AbstractDataGraph}","page":"Home","title":"ITensorNetworks.findall_on_edges","text":"Find all edges e such that f(graph[e]) == true\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.findall_on_vertices-Tuple{Function, DataGraphs.AbstractDataGraph}","page":"Home","title":"ITensorNetworks.findall_on_vertices","text":"Find all vertices v such that f(graph[v]) == true\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.findfirst_on_edges-Tuple{Function, DataGraphs.AbstractDataGraph}","page":"Home","title":"ITensorNetworks.findfirst_on_edges","text":"Find the edge e such that f(graph[e]) == true\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.findfirst_on_vertices-Tuple{Function, DataGraphs.AbstractDataGraph}","page":"Home","title":"ITensorNetworks.findfirst_on_vertices","text":"Find the vertex v such that f(graph[v]) == true\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.finite_state_machine-Union{Tuple{V}, Tuple{C}, Tuple{ITensors.LazyApply.Applied{typeof(sum), Tuple{Array{ITensors.LazyApply.Applied{typeof(*), Tuple{C, ITensors.LazyApply.Prod{ITensors.Ops.Op}}, NamedTuple{(), Tuple{}}}, 1}}, NamedTuple{(), Tuple{}}}, IndsNetwork{V, <:ITensors.Index}, V}} where {C, V}","page":"Home","title":"ITensorNetworks.finite_state_machine","text":"finite_state_machine(os::OpSum{C}, sites::IndsNetwork{V,<:Index}, root_vertex::V) where {C,V}\n\nFinite state machine generator for ITensors.OpSum Hamiltonian defined on a tree graph. The site Index graph must be a tree graph, and the chosen root  must be a leaf vertex of this tree. Returns a DataGraph of SparseArrayKit.SparseArrays\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.fsmTTN-Union{Tuple{V}, Tuple{C}, Tuple{ITensors.LazyApply.Applied{typeof(sum), Tuple{Array{ITensors.LazyApply.Applied{typeof(*), Tuple{C, ITensors.LazyApply.Prod{ITensors.Ops.Op}}, NamedTuple{(), Tuple{}}}, 1}}, NamedTuple{(), Tuple{}}}, IndsNetwork{V, <:ITensors.Index}, V}} where {C, V}","page":"Home","title":"ITensorNetworks.fsmTTN","text":"fsmTTN(os::OpSum{C}, sites::IndsNetwork{V,<:Index}, root_vertex::V, kwargs...) where {C,V}\n\nConstruct a dense TreeTensorNetwork from sparse finite state machine represenatation, without compression.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.get_environment-Tuple{ITensorNetwork, DataGraph, Vector}","page":"Home","title":"ITensorNetworks.get_environment","text":"Given a subet of vertices of a given Tensor Network and the Message Tensors for that network, return a Dictionary with the involved subgraphs as keys and the vector of tensors associated with that subgraph as values Specifically, the contraction of the environment tensors and tn[vertices] will be a scalar.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.has_leaf_neighbor-Tuple{Graphs.AbstractGraph, Any}","page":"Home","title":"ITensorNetworks.has_leaf_neighbor","text":"Determine if a node has any neighbors which are leaves\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.heisenberg-Tuple{Graphs.AbstractGraph}","page":"Home","title":"ITensorNetworks.heisenberg","text":"Random field J1-J2 Heisenberg model on a general graph\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.heisenberg-Tuple{Integer}","page":"Home","title":"ITensorNetworks.heisenberg","text":"Random field J1-J2 Heisenberg model on a chain of length N\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.internal_edges-Tuple{Graphs.AbstractGraph}","page":"Home","title":"ITensorNetworks.internal_edges","text":"Get all edges which do not involve a leaf\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.is_leaf_edge-Tuple{Graphs.AbstractGraph, Any}","page":"Home","title":"ITensorNetworks.is_leaf_edge","text":"Determine if an edge involves a leaf (at src or dst)\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.ising-Tuple{Graphs.AbstractGraph}","page":"Home","title":"ITensorNetworks.ising","text":"Next-to-nearest-neighbor Ising model (ZZX) on a general graph\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.ising-Tuple{Integer}","page":"Home","title":"ITensorNetworks.ising","text":"Next-to-nearest-neighbor Ising model (ZZX) on a chain of length N\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.ising_network-Tuple{Type, IndsNetwork, Number}","page":"Home","title":"ITensorNetworks.ising_network","text":"BUILD Z OF CLASSICAL ISING MODEL ON A GIVEN GRAPH AT INVERSE TEMP BETA H = -\\sum{(v,v') \\in edges}\\sigma^{z}{v}\\sigma^{z}_{v'} OPTIONAL ARGUMENT:   h: EXTERNAL MAGNETIC FIELD   szverts: A LIST OF VERTICES OVER WHICH TO APPLY A SZ.     THE RESULTANT NETWORK CAN THEN BE CONTRACTED AND DIVIDED BY THE ACTUAL PARTITION FUNCTION TO GET THAT OBSERVABLE     INDSNETWORK IS ASSUMED TO BE BUILT FROM A GRAPH (NO SITE INDS) AND OF LINK SPACE 2\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.ising_network-Tuple{Type, NamedGraphs.NamedGraph, Number}","page":"Home","title":"ITensorNetworks.ising_network","text":"BUILD Z OF CLASSICAL ISING MODEL ON A GIVEN GRAPH AT INVERSE TEMP BETA H = -\\sum{(v,v') \\in edges}\\sigma^{z}{v}\\sigma^{z}_{v'} TAKE AS AN OPTIONAL ARGUMENT A LIST OF VERTICES OVER WHICH TO APPLY A SZ. THE RESULTANT NETWORK CAN THEN BE CONTRACTED AND DIVIDED BY THE ACTUAL PARTITION FUNCTION TO GET THAT OBSERVABLE\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.leaf_vertices-Tuple{Graphs.AbstractGraph}","page":"Home","title":"ITensorNetworks.leaf_vertices","text":"Get all vertices which are leaves of a graph\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.nested_graph_leaf_vertices-Tuple{Any}","page":"Home","title":"ITensorNetworks.nested_graph_leaf_vertices","text":"Given a nested graph fetch all the vertices down to the lowest levels and return the grouping at the highest level. Keyword argument is used to state whether we are at the top\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.optimise_p_q-Tuple{ITensors.ITensor, ITensors.ITensor, Vector{ITensors.ITensor}, ITensors.ITensor}","page":"Home","title":"ITensorNetworks.optimise_p_q","text":"Do Full Update Sweeping, Optimising the tensors p and q in the presence of the environments envs, Specifically this functions find the pcur and qcur which optimise envsgatepqdag(prime(pcur))*dag(prime(qcur))\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.partition-Tuple{Graphs.AbstractGraph}","page":"Home","title":"ITensorNetworks.partition","text":"partition(g::AbstractGraph; npartitions::Integer, kwargs...)\npartition(g::AbstractGraph, subgraph_vertices)\n\nGiven a graph g, partition g into npartitions partitions or into partitions with nvertices_per_partition vertices per partition. The partitioning tries to keep all subgraphs the same size and minimize edges cut between them.\n\nAlternatively, specify a desired partitioning with a collection of sugraph vertices.\n\nReturns a data graph where each vertex contains the corresponding subgraph as vertex data. The edges indicates which subgraphs are connected, and the edge data stores a dictionary with two fields. The field :edges stores a list of the edges of the original graph that were connecting the two subgraphs, and :edge_data stores a dictionary mapping edges of the original graph to the data living on the edges of the original graph, if it existed.\n\nTherefore, one should be able to extract that data and recreate the original graph from the results of partition.\n\nA graph partitioning backend such as Metis or KaHyPar needs to be installed for this function to work if the subgraph vertices aren't specified explicitly.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.partition-Tuple{NDTensors.Algorithm{:mincut_recursive_bisection}, ITensorNetwork, DataGraph}","page":"Home","title":"ITensorNetworks.partition","text":"Given an input tn and a rooted binary tree of indices, return a partition of tn with the same binary tree structure as indsbtree. Note: in the output partition, we add multiple delta tensors to the network so that   the output graph is guaranteed to be the same binary tree as indsbtree. Note: in the output partition, tensor vertex names will be changed. For a given input   tensor with vertex name v, its name in the output partition will be(v, 1), and any   delta tensor will have name(v, 2). Note: for a given binary tree with n indices, the output partition will contain 2n-1 vertices,   with each leaf vertex corresponding to a sub tn adjacent to one output index. Keeping these   leaf vertices in the partition makes laterapproxitensornetworkalgorithms more efficient. Note: name of vertices in the output partition can be different from the name of vertices   inindsbtree`.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.partition_vertices-Tuple{Graphs.AbstractGraph, Any}","page":"Home","title":"ITensorNetworks.partition_vertices","text":"partition_vertices(g::AbstractGraph, subgraph_vertices::Vector)\n\nGiven a graph (g) and groups of vertices defining subgraphs of that graph (subgraph_vertices), return a DataGraph storing the subgraph vertices on the vertices of the graph and with edges denoting which subgraphs of the original graph have edges connecting them, along with edge data storing the original edges that were connecting the subgraphs.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.partition_vertices-Tuple{Graphs.AbstractGraph}","page":"Home","title":"ITensorNetworks.partition_vertices","text":"partition_vertices(g::AbstractGraph; npartitions, nvertices_per_partition, kwargs...)\n\nGiven a graph g, partition the vertices of g into 'npartitions' partitions or into partitions with nvertices_per_partition vertices per partition. Try to keep all subgraphs the same size and minimise edges cut between them Returns a datagraph where each vertex contains the list of vertices involved in that subgraph. The edges state which subgraphs are connected. A graph partitioning backend such as Metis or KaHyPar needs to be installed for this function to work.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.path_graph_structure-Tuple{ITensorNetwork, Vector{<:ITensors.Index}}","page":"Home","title":"ITensorNetworks.path_graph_structure","text":"Given a tn and outinds (a subset of noncommoninds of tn), outputs a maximimally unbalanced directed binary tree DataGraph of outinds defining the desired graph structure\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.path_graph_structure-Tuple{ITensorNetwork}","page":"Home","title":"ITensorNetworks.path_graph_structure","text":"Outputs a maximimally unbalanced directed binary tree DataGraph defining the desired graph structure\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.randomITensorNetwork-Tuple{Distributions.Distribution, IndsNetwork}","page":"Home","title":"ITensorNetworks.randomITensorNetwork","text":"Build an ITensor network on a graph specified by the inds network s. Bonddim is given by linkspace and entries are randomized. The random distribution is based on the input argument distribution.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.randomITensorNetwork-Tuple{Type, IndsNetwork}","page":"Home","title":"ITensorNetworks.randomITensorNetwork","text":"Build an ITensor network on a graph specified by the inds network s. Bonddim is given by linkspace and entries are randomised (normal distribution, mean 0 std 1)\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.relabel_sites-Tuple{ITensors.LazyApply.Applied{typeof(sum), Tuple{Array{ITensors.LazyApply.Applied{typeof(*), Tuple{C, ITensors.LazyApply.Prod{ITensors.Ops.Op}}, NamedTuple{(), Tuple{}}}, 1}}, NamedTuple{(), Tuple{}}} where C, Dictionaries.AbstractDictionary}","page":"Home","title":"ITensorNetworks.relabel_sites","text":"Relabel sites in OpSum according to given site map\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.set_partitioning_backend!-Tuple{Union{Missing, String, ITensorNetworks.Backend}}","page":"Home","title":"ITensorNetworks.set_partitioning_backend!","text":"Set the graph partitioning backend\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.subgraphs-Tuple{Graphs.AbstractGraph, Any}","page":"Home","title":"ITensorNetworks.subgraphs","text":"subgraphs(g::AbstractGraph, subgraph_vertices)\n\nReturn a collection of subgraphs of g defined by the subgraph vertices subgraph_vertices.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.subgraphs-Tuple{Graphs.AbstractGraph}","page":"Home","title":"ITensorNetworks.subgraphs","text":"subgraphs(g::AbstractGraph; npartitions::Integer, kwargs...)\n\nGiven a graph g, partition g into npartitions partitions or into partitions with nvertices_per_partition vertices per partition, returning a list of subgraphs. Try to keep all subgraphs the same size and minimise edges cut between them. A graph partitioning backend such as Metis or KaHyPar needs to be installed for this function to work.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.svdTTN-Union{Tuple{VT}, Tuple{C}, Tuple{ITensors.LazyApply.Applied{typeof(sum), Tuple{Array{ITensors.LazyApply.Applied{typeof(*), Tuple{C, ITensors.LazyApply.Prod{ITensors.Ops.Op}}, NamedTuple{(), Tuple{}}}, 1}}, NamedTuple{(), Tuple{}}}, IndsNetwork{VT, <:ITensors.Index}, VT}} where {C, VT}","page":"Home","title":"ITensorNetworks.svdTTN","text":"svdTTN(os::OpSum{C}, sites::IndsNetwork{V<:Index}, root_vertex::V, kwargs...) where {C,V}\n\nConstruct a dense TreeTensorNetwork from a symbolic OpSum representation of a Hamiltonian, compressing shared interaction channels.\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.symmetric_gauge-Tuple{ITensorNetwork}","page":"Home","title":"ITensorNetworks.symmetric_gauge","text":"Put an ITensorNetwork into the symmetric gauge and also return the message tensors (which are the diagonal bond matrices)\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.tdvp-Tuple{Any, Number, ITensorNetworks.AbstractTreeTensorNetwork}","page":"Home","title":"ITensorNetworks.tdvp","text":"tdvp(H::TTN, t::Number, psi0::TTN; kwargs...)\n\nUse the time dependent variational principle (TDVP) algorithm to compute exp(H*t)*psi0 using an efficient algorithm based on alternating optimization of the state tensors and local Krylov exponentiation of H.\n\nReturns:\n\npsi - time-evolved state\n\nOptional keyword arguments:\n\noutputlevel::Int = 1 - larger outputlevel values resulting in printing more information and 0 means no output\nobserver - object implementing the Observer interface which can perform measurements and stop early\nwrite_when_maxdim_exceeds::Int - when the allowed maxdim exceeds this value, begin saving tensors to disk to free memory in large calculations\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.to_vec-Tuple{Any}","page":"Home","title":"ITensorNetworks.to_vec","text":"to_vec(x)\n\nTransform x into a Vector. Returns the vector and a closure which inverts the transformation.\n\nModeled after FiniteDifferences.to_vec:\n\nhttps://github.com/JuliaDiff/FiniteDifferences.jl/blob/main/src/to_vec.jl\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.update_all_mts-Tuple{ITensorNetwork, DataGraph}","page":"Home","title":"ITensorNetworks.update_all_mts","text":"Do an update of all message tensors for a given ITensornetwork and its partition into sub graphs\n\n\n\n\n\n","category":"method"},{"location":"#ITensorNetworks.update_mt-Tuple{ITensorNetwork, Vector, Vector{ITensors.ITensor}}","page":"Home","title":"ITensorNetworks.update_mt","text":"DO a single update of a message tensor using the current subgraph and the incoming mts\n\n\n\n\n\n","category":"method"},{"location":"#ITensors.apply-Tuple{ITensorNetworks.AbstractTreeTensorNetwork, ITensorNetworks.AbstractTreeTensorNetwork}","page":"Home","title":"ITensors.apply","text":"Overload of ITensors.apply.\n\n\n\n\n\n","category":"method"},{"location":"#ITensors.dmrg-Tuple{Any, ITensorNetworks.AbstractTreeTensorNetwork}","page":"Home","title":"ITensors.dmrg","text":"Overload of ITensors.dmrg.\n\n\n\n\n\n","category":"method"},{"location":"#KrylovKit.eigsolve-Tuple{Any, ITensorNetworks.AbstractTreeTensorNetwork}","page":"Home","title":"KrylovKit.eigsolve","text":"Overload of KrylovKit.eigsolve.\n\n\n\n\n\n","category":"method"},{"location":"#KrylovKit.linsolve","page":"Home","title":"KrylovKit.linsolve","text":"linsolve(\n    A::ITensorNetworks.AbstractTreeTensorNetwork,\n    b::ITensorNetworks.AbstractTreeTensorNetwork,\n    x₀::ITensorNetworks.AbstractTreeTensorNetwork\n)\nlinsolve(\n    A::ITensorNetworks.AbstractTreeTensorNetwork,\n    b::ITensorNetworks.AbstractTreeTensorNetwork,\n    x₀::ITensorNetworks.AbstractTreeTensorNetwork,\n    a₀::Number\n)\nlinsolve(\n    A::ITensorNetworks.AbstractTreeTensorNetwork,\n    b::ITensorNetworks.AbstractTreeTensorNetwork,\n    x₀::ITensorNetworks.AbstractTreeTensorNetwork,\n    a₀::Number,\n    a₁::Number;\n    kwargs...\n)\n\n\nCompute a solution x to the linear system:\n\n(a₀ + a₁ * A)*x = b\n\nusing starting guess x₀. Leaving a₀, a₁ set to their default values solves the  system A*x = b.\n\nTo adjust the balance between accuracy of solution and speed of the algorithm, it is recommed to first try adjusting the solver_tol keyword argument descibed below.\n\nKeyword arguments:\n\nishermitian::Bool=false - should set to true if the MPO A is Hermitian\nsolver_krylovdim::Int=30 - max number of Krylov vectors to build on each solver iteration\nsolver_maxiter::Int=100 - max number outer iterations (restarts) to do in the solver step\nsolver_tol::Float64=1E-14 - tolerance or error goal of the solver\n\nOverload of KrylovKit.linsolve.\n\n\n\n\n\n","category":"function"},{"location":"#NDTensors.contract-Tuple{ITensorNetworks.AbstractTreeTensorNetwork, ITensorNetworks.AbstractTreeTensorNetwork}","page":"Home","title":"NDTensors.contract","text":"Overload of ITensors.contract.\n\n\n\n\n\n","category":"method"},{"location":"#Observers.update!-Tuple{Nothing}","page":"Home","title":"Observers.update!","text":"Overload of Observers.update!.\n\n\n\n\n\n","category":"method"}]
}
