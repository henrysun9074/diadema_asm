# BiocManager::install(c("Biostrings", "GenomicRanges"))

library(Biostrings)
library(GenomicRanges)
library(dplyr)
library(ggplot2)
library(ggpubr)

fasta_file <- "/work/hs325/diadema/results/ragtag/scaffolded/filtered.fasta"
bin_size   <- 1e6       
min_gap    <- 1        
min_length <- 1e6      

# Read the assembly
genome <- readDNAStringSet(fasta_file)
names(genome) <- sub("\\s.*$", "", names(genome))

seq_info <- data.frame(
  seqname = names(genome),
  length  = width(genome)
) |>
  filter(length >= min_length)

genome <- genome[seq_info$seqname]

###### find gaps
find_gaps <- function(sequence, seqname, min_gap = 1) {
  sequence <- toupper(as.character(sequence))
  matches <- gregexpr("N+", sequence, perl = TRUE)[[1]]

  if (matches[1] == -1) {
    return(data.frame(
      seqname = character(),
      start = integer(),
      end = integer(),
      gap_length = integer()
    ))
  }

  lengths <- attr(matches, "match.length")

  data.frame(
    seqname = seqname,
    start = matches,
    end = matches + lengths - 1L,
    gap_length = lengths
  ) |>
    filter(gap_length >= min_gap)
}

gap_table <- bind_rows(
  lapply(seq_along(genome), function(i) {
    find_gaps(genome[[i]], names(genome)[i], min_gap)
  })
)

head(gap_table)


## create windows using genomicranges
bin_table <- bind_rows(
  lapply(seq_len(nrow(seq_info)), function(i) {
    starts <- seq(1, seq_info$length[i], by = bin_size)

    data.frame(
      seqname = seq_info$seqname[i],
      start = starts,
      end = pmin(starts + bin_size - 1, seq_info$length[i])
    )
  })
)

bin_gr <- GRanges(
  seqnames = bin_table$seqname,
  ranges = IRanges(bin_table$start, bin_table$end)
)

gap_gr <- GRanges(
  seqnames = gap_table$seqname,
  ranges = IRanges(gap_table$start, gap_table$end)
)

# Initialize empty bins
bin_table$gap_bp <- 0
bin_table$n_gaps <- 0

if (length(gap_gr) > 0) {
  hits <- findOverlaps(bin_gr, gap_gr)

  overlaps <- pintersect(
    bin_gr[queryHits(hits)],
    gap_gr[subjectHits(hits)]
  )

  overlap_table <- data.frame(
    bin_id = queryHits(hits),
    gap_id = subjectHits(hits),
    overlap_bp = width(overlaps)
  ) |>
    group_by(bin_id) |>
    summarise(
      gap_bp = sum(overlap_bp),
      n_gaps = n_distinct(gap_id),
      .groups = "drop"
    )

  bin_table$gap_bp[overlap_table$bin_id] <- overlap_table$gap_bp
  bin_table$n_gaps[overlap_table$bin_id] <- overlap_table$n_gaps
}

bin_table <- bin_table |>
  mutate(
    midpoint_mb = ((start + end) / 2) / 1e6,
    width_mb = (end - start + 1) / 1e6,
    gap_fraction = gap_bp / (end - start + 1),
    seqname = factor(seqname, levels = rev(seq_info$seqname))
  )


### plot heatmap

scaffold_order <- seq_info |>
  arrange(desc(length)) |>
  pull(seqname)

bin_table <- bin_table |>
  mutate(
    seqname = factor(seqname, levels = rev(scaffold_order))
  )

p <- ggplot(
  bin_table,
  aes(
    x = midpoint_mb,
    y = seqname,
    width = width_mb,
    height = 0.75,
    fill = gap_fraction
  )
) +
  geom_tile() +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "sqrt",
    limits = c(0, NA),
    labels = scales::label_percent(),
    name = "Gaps \nper 1 Mb window"
  ) +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.01))
  ) +
  labs(
    x = "Scaffold Position (Mb)",
    y = NULL
  ) +
  theme_pubr(base_size = 12) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 9),
    legend.position = "right"
  )
p
ggsave(
  "collapsed_v1_2.pdf",
  p,
  width = 11,
  height = max(4, 0.35 * nrow(seq_info) + 2)
)
