library(multiweb)
library(igraph)

load("igcomplete.rda")

pro_res <- calc_topological_indices(igcomplete)

plot_troph_level(igcomplete[["Constable lake"]])
plot(igcomplete[["Constable lake"]])

igraph::components(igcomplete[["Constable lake"]], mode = "weak")

igcomplete_ok <- lapply(igcomplete, function(x){
  components <- igraph::clusters(x, mode="weak")
  biggest_cluster_id <- which.max(components$csize)
  vert_ids <- V(x)[components$membership == biggest_cluster_id]
  g_largest <- igraph::induced_subgraph(x, vert_ids)
})

pro_res_ok <- calc_topological_indices(igcomplete_ok)

mod_res <- calc_modularity(igcomplete_ok, ncores = 4)

save(mod_res, file = "ModResults.rda")




