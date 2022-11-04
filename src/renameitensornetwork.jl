#RENAME THE VERTICES OF AN ITENSORNETWORK
function rename_vertices(psi::ITensorNetwork, name_map::Dictionary)
  old_g = NamedDimGraph(vertices(psi))

  for e in edges(psi)
    add_edge!(old_g, e)
  end

  new_g = rename_vertices(old_g, name_map)

  psi_new = ITensorNetwork(new_g)
  for v in vertices(psi)
    psi_new[name_map[v]] = psi[v]
  end

  return psi_new
end

function rename_vertices(psi::ITensorNetwork, name_map::Function)
  original_vertices = vertices(psi)
  return rename_vertices(psi, Dictionary(original_vertices, name_map.(original_vertices)))
end
