load("ISP2022/data/igcomplete.rda")
igcomplete

require(multiweb)

qssValues <- multiweb::calc_QSS(igcomplete, nsim = 1000)
