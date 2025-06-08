## FigS9.R — Stability of pTG262::npmA2 over 6 days
## Carlos Serna, 2025-06-08

library(readxl);library(tidyverse);library(scales)

# 1. Read raw data
stab <- read_excel("data/FigS9.xlsx", sheet = 1)

# 2. Clean & summarise
stab_summary <- stab %>%
  filter(strain != "F") %>% 
  mutate(strain = recode(strain,
                         S = "E. coli HST08",
                         M = "E. coli MG1655",
                         J = "E. faecalis JH2-2")) %>%
  group_by(day, strain) %>%
  summarise(
    mean_stab = mean(stability),
    se_stab   = sd(stability) / sqrt(n()),
    .groups   = "drop"
  )

# 3. Plot
p <- ggplot(stab_summary, aes(x = day, y = mean_stab, color = strain)) +
  geom_line(size = 0.8) +
  geom_point(size = 2) +
  geom_errorbar(aes(ymin = mean_stab - se_stab,
                    ymax = mean_stab + se_stab),
                width = 0.2) +
  scale_x_continuous(breaks = 0:6) +
  scale_y_continuous(limits = c(0, 100),
                     labels = percent_format(scale = 1)) +
  labs(x = "Time (days)",
       y = "Stability (%)",
       color = NULL) +
  theme_bw(base_size = 12) +
  theme(legend.position = "right")

# 4. Save
ggsave("figs/FigureS9_stability.svg",
       plot   = p,
       width  = 6,    # inches
       height = 4,    # inches
       dpi    = 300)
