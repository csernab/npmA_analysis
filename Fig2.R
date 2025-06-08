## Fig2.R — reproduce panels a & b of Figure 2
## Carlos Serna, 2025-06-08

library(tidyverse); library(ape); library(ggtree); library(treeio); library(phytools)
library(viridis)

plot_phylo_heatmap <- function(tree_f, meta_f, out_svg, tree_title="") {
  # 1. Read phylogeny
  tr <- read.tree(tree_f)
  
  # 2. Read & prep metadata (preserve rownames for gheatmap)
  meta_df <- read_csv(meta_f, show_col_types = FALSE) %>%
    filter(biosample_id %in% tr$tip.label) %>%
    as.data.frame()
  rownames(meta_df) <- meta_df$biosample_id
  meta_df <- meta_df[, c("niche","country","npmA_presence","Composite_Tn","ICE_MGE_type")]
  meta_df[] <- lapply(meta_df, as.character)
  
  # 3. Base circular tree
  p <- ggtree(midpoint.root(tr), layout = "rectangular")
  
  # 4. Add heatmap of metadata
  p2 <- gheatmap(p, meta_df,
                 offset           = 0.02,
                 width            = 0.80,
                 colnames_position= "top",
                 colnames_angle   = 90,
                 colnames_offset_y= 0.5,
                 font.size        = 2
  )
  
  
  # 6. Save
  ggsave(out_svg, p2, width = 6, height = 6, dpi = 300)
}

# **Paths** — adjust if needed, no setwd()
dat_dir <- "data"
fig_dir <- "figs"

# Panel a: ST11
plot_phylo_heatmap(
  tree_f    = file.path(dat_dir, "Fig2a.treefile"),
  meta_f    = file.path(dat_dir, "Fig2a.csv"),
  out_svg   = file.path(fig_dir, "Figure2a_ST11_tree.svg"),
)

# Panel b: ST54
plot_phylo_heatmap(
  tree_f    = file.path(dat_dir, "Fig2b.treefile"),
  meta_f    = file.path(dat_dir, "Fig2b.csv"),
  out_svg   = file.path(fig_dir, "Figure2b_ST54_tree.svg"),
)


