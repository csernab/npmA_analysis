## Fig1.R — reproduce all panels of Figure 1
## Carlos Serna, 2023-11-23

## Reads npmA presence, merges country centroids, and plots world map
library(tidyverse);library(sf);library(rnaturalearth);library(rnaturalearthdata)
library(ggspatial);library(countrycode)


# 1. Load data
npmA <- read_csv("data/Fig1.csv") %>%
  filter(QC_assemblies == "pass", study_id != "no_study") %>%
  mutate(iso_a3 = countrycode(country, 
                              origin = "country.name", 
                              destination = "iso3c"),
         count = npmA)     # assuming npmA is 0/1

centroids <- read_csv(
  "data/average-latitude-longitude-countries.csv",
  show_col_types = FALSE
) %>%
  rename(
    iso_a3    = `ISO.3166.Country.Code`,
    latitude  = Latitude,
    longitude = Longitude
  )

# 2. Summarise per country
country_counts <- npmA %>%
  group_by(iso_a3) %>%
  summarise(count = sum(count), .groups = "drop")

# 3. Prepare map
world <- ne_countries(scale = "medium", returnclass = "sf") %>%
  left_join(country_counts, by = c("iso_a3"))

world$count[is.na(world$count)] <- 0

# 4. Plot
p <- ggplot(world) +
  geom_sf(aes(fill = count), color = "grey30", size = 0.1) +
  scale_fill_gradientn(name = "n of isolates",
                       colours = colorRampPalette(RColorBrewer::brewer.pal(9, "Blues"))(100)) +
  coord_sf(expand = FALSE) +
  labs(x = "Longitude", y = "Latitude") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom") +
  annotation_scale(location = "bl", width_hint = 0.3) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.2, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering())

p

# 5. Save
ggsave("data/Figure1_npmA_map.svg", plot = p, width = 8, height = 6, dpi = 300)

# ---------------------------------------------------------------------------- #

# Panel (c1): ST by niche
st_niche <- npmA %>%
  count(mlst, niche) %>%
  complete(mlst, niche, fill = list(n = 0))

p_stn <- ggplot(st_niche, aes(x = reorder(mlst, n), y = n, fill = niche)) +
  geom_col() +
  coord_flip() +
  labs(x = "Sequence type (ST)", y = "n of isolates") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "right")

ggsave("Figure1c1_ST_by_niche.svg", p_stn, width = 6, height = 4, dpi = 300)


# Panel (c2): ST by country
st_ctry <- npmA %>%
  count(mlst, country) %>%
  complete(mlst, country, fill = list(n = 0))

p_stc <- ggplot(st_ctry, aes(x = reorder(mlst, n), y = n, fill = country)) +
  geom_col() +
  coord_flip() +
  labs(x = "ST", y = "n of isolates") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "right")

ggsave("Figure1c2_ST_by_country.svg", p_stc, width = 6, height = 4, dpi = 300)


# Panel (c3): isolates per collection year
npmA <- npmA %>%
  mutate(collection_year = as.integer(collection_year)) %>%
  filter(!is.na(collection_year))

yearly <- npmA %>%
  count(collection_year)

p_year <- ggplot(yearly, aes(x = collection_year, y = n)) +
  geom_col(color = "black", fill = "steelblue") +
  labs(x = "Collection year", y = "n of isolates") +
  scale_x_continuous(breaks = yearly$collection_year) +
  theme_minimal(base_size = 12)

ggsave("Figure1d_year.svg", p_year, width = 6, height = 3, dpi = 300)

