using DataGraphs: DataGraph
using Graphs: add_vertex!, vertices
using LinearAlgebra: normalize

"""
Approximate a `partition` into an output ITensorNetwork
with the binary tree structure defined by `out_tree` by
first transforming the partition into a ttn, then truncating
the ttn using a sequence of SVDs.
"""
function _approx_itensornetwork_ttn_svd!(
  input_partition::DataGraph;
  root=first(vertices(partition)),
  cutoff=1e-15,
  maxdim=10000,
  contraction_sequence_kwargs,
)
  tn = ITensorNetwork()
  for v in vertices(input_partition)
    add_vertex!(tn, v)
    tn[v] = _optcontract(Vector{ITensor}(input_partition[v]); contraction_sequence_kwargs)
  end
  truncate_ttn = truncate(ttn(tn); cutoff, maxdim, root_vertex=root)
  out_tn = ITensorNetwork(truncate_ttn)
  out_tn[root] = normalize(out_tn[root])
  return out_tn, log(root_norm)
end
