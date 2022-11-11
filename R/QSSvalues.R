# Cargar datos
load("../data/igcomplete.rda")
igcomplete

# Cargar paquetes
require(multiweb)

# Correr análisis QSS
qssValues <- multiweb::calc_QSS(igcomplete, nsim = 1000, ncores = 8, 
                                istrength = FALSE, returnRaw = FALSE)

# Guardar resultados
save(qssValues, file = "qssResults.rda")
