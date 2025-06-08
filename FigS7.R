## FigS7.R — contig‐length histograms for Figure S7
## Carlos Serna, 2025‐06‐08

library(tidyverse)

# 1. Read data explicitly as two columns
contigs <- read_delim("data/FigS7.tab", 
                      delim    = ",",
                      col_names= c("contig","length"),
                      show_col_types = FALSE) %>%
  mutate(length_mb = length / 1e6)

# 2. Panel a: full range
p_full <- ggplot(contigs, aes(x = length_mb)) +
  geom_histogram(bins = 70, fill = "#453253", color = "black") +
  labs(x = "Contig length (Mb)", y = "Frequency") +
  theme_minimal(base_size = 12)

ggsave("figs/FigureS7a_contig_length_full.svg",
       plot = p_full, width = 6, height = 4, dpi = 300)

# 3. Panel b: zoom 0–1 Mb
p_zoom <- contigs %>%
  filter(length_mb <= 1) %>%
  ggplot(aes(x = length_mb)) +
  geom_histogram(bins = 40, fill = "#453253", color = "black") +
  labs(x = "Contig length (Mb)", y = "Frequency") +
  theme_minimal(base_size = 12)

ggsave("figs/FigureS7b_contig_length_zoom.svg",
       plot = p_zoom, width = 6, height = 4, dpi = 300)

