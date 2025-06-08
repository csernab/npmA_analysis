## FigS1.R — panels a & b for Supplementary Figure S1
## Carlos Serna, 2025-06-XX

library(tidyverse)
library(ggvenn)

# Paths to ID lists
base <- "data/"
files <- list(
  ENA        = file.path(base, "FigS1_ENA.txt"),
  ENTEROBASE = file.path(base, "FigS1_EnteroBase.txt"),
  NCBI       = file.path(base, "FigS1_NCBI.txt")
)

# Read into named vectors
id_lists <- map(files, ~ read_lines(.x))

# --- Panel (b): Venn diagram ---
# You can use ggvenn for simple sets...
p_venn <- ggvenn(id_lists,
                 fill_color   = c("#E69F00", "#56B4E9", "#009E73"),
                 stroke_size  = 0.5,
                 set_name_size= 5) +
  theme_void() +
  theme(legend.position = "none")


# Save panel (b)
ggsave("figs/FigureS1b_venn.svg", p_venn, width = 5, height = 5, dpi = 300)
