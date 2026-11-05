# quick UpSet plot of gene-GO pairs from the four annotation sources

infile <- "diadema_go_strict.gene2go.tsv"
outpfx <- "diadema_go_strict.upset"

sources <- c("eggnog", "interpro", "pannzer", "spur_ortholog")
labels  <- expression("eggNOG-mapper", "InterProScan", "PANNZER2",
                      italic("S. purpuratus") ~ "orthologs")

# read data
d      <- read.delim(infile, stringsAsFactors = FALSE)
combos <- sort(table(d$sources), decreasing = TRUE)
counts <- as.vector(combos)
stopifnot(sum(counts) == nrow(d))

# TRUE where a combination includes a source (rows = combinations, cols = sources)
parts  <- strsplit(names(combos), ";")
member <- t(sapply(parts, function(x) sources %in% x))
colnames(member) <- sources
set_size <- colSums(member * counts)

print(data.frame(combination = names(combos), pairs = counts))
print(set_size)

comma <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE)

draw_plot <- function() {
  ink   <- "grey20"
  n     <- length(counts)
  xs    <- seq_len(n)
  ys    <- rev(seq_along(sources))       
  xlim  <- c(0.2, n + 0.5)
  ylim  <- c(0.5, length(sources) + 0.5)
  floor <- 100  
  ticks <- 10^(2:6)

  layout(matrix(c(0, 1, 2, 3), 2, byrow = TRUE), widths = c(3.8, 5), heights = c(3, 1.6))

  # intersection sizes
  par(mar = c(0.5, 6.5, 1, 1), mgp = c(4.8, 0.7, 0))
  plot(NA, xlim = xlim, ylim = c(floor, 1.5e6), log = "y", xaxs = "i", yaxs = "i",
       axes = FALSE, xlab = "", ylab = "GO terms")
  rect(xs - 0.32, floor, xs + 0.32, counts, col = ink, border = NA)
  text(xs, counts, comma(counts), pos = 3, cex = 0.72, offset = 0.3, xpd = NA)
  axis(2, at = ticks, labels = comma(ticks), las = 1)

  # GO terms per source 
  par(mar = c(4, 3, 0.5, 10.5), mgp = c(2.4, 0.7, 0))
  plot(NA, xlim = c(5e6, floor), ylim = ylim, log = "x", xaxs = "i", yaxs = "i",
       axes = FALSE, xlab = "GO terms per source", ylab = "")
  rect(set_size, ys - 0.3, floor, ys + 0.3, col = ink, border = NA)
  text(set_size, ys, comma(set_size), pos = 2, cex = 0.8, offset = 0.3, xpd = NA)
  axis(1, at = c(1e2, 1e4, 1e6), labels = comma(c(1e2, 1e4, 1e6)))
  axis(4, at = ys, labels = labels, las = 1, tick = FALSE)

  par(mar = c(4, 6.5, 0.5, 1))
  plot(NA, xlim = xlim, ylim = ylim, xaxs = "i", yaxs = "i", axes = FALSE, xlab = "", ylab = "")
  rect(xlim[1], ys[c(FALSE, TRUE)] - 0.5, xlim[2], ys[c(FALSE, TRUE)] + 0.5,
       col = "grey96", border = NA)
  for (i in xs) {
    on <- ys[member[i, ]]
    points(rep(i, length(ys)), ys, pch = 19, cex = 1.3, col = "grey88")
    segments(i, min(on), i, max(on), lwd = 2, col = ink)
    points(rep(i, length(on)), on, pch = 19, cex = 1.3, col = ink)
  }
}

pdf(paste0(outpfx, ".pdf"), width = 11, height = 6)
draw_plot()
dev.off()

png(paste0(outpfx, ".png"), width = 11, height = 6, units = "in", res = 300, type = "cairo")
draw_plot()
dev.off()
