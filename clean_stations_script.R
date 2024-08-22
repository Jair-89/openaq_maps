library("pacman")

p_load(
  tidyverse,
  openair,
  openairmaps,
  fs,
  sf,
  
)

path <- paste0(getwd(),"/data_base/")

dict_sinaica <- read.csv(
  paste0(
    path,"files/diccionario_sinaica.csv"
    ),
  fileEncoding = "latin1"
  )

status_stations_sinaica <- dict_sinaica |> 
  mutate(
    status_pol = case_when(
      o3 == "NO" | so2 == "NO" | co == "NO" | no2 == "NO" | pm2.5 == "NO" | pm10 == "NO" ~ "Incomplete",
      .default = "Complete"
    ),
    status_meteo = case_when(
      ws == "NO" | wd == "NO" | tout == "NO" | hr == "NO" | pp == "NO" | rs == "NO" ~ "Incomplete",
      .default = "Complete"
    )
  ) |> print()

count_par_pol <- status_stations_sinaica |> 
  select(id_estacion,o3,co,so2,no2,pm2.5,pm10) |> 
  pivot_longer(cols = 2:7, names_to = "par",values_to = "val") |>
  mutate(
    num_value = case_when(
      val == "SI" ~ 1,
      val == "NO" ~ 0,
      .default = 0
    )
  ) |> 
  group_by(id_estacion) |> 
  count(num_value) |> 
  filter(num_value == 1) |> 
  rename( station_yes_par_pol = n) 

count_par_meteo <- status_stations_sinaica |> 
  select(id_estacion,wd,ws,tout,hr,pp,rs) |> 
  pivot_longer(cols = 2:7, names_to = "par",values_to = "val") |>
  mutate(
    num_value = case_when(
      val == "SI" ~ 1,
      val == "NO" ~ 0,
      .default = 0
    )
  ) |> 
  group_by(id_estacion) |> 
  count(num_value) |> 
  filter(num_value == 1) |> 
  rename( station_yes_par_meteo = n) 

clean_dir_sinaica <- status_stations_sinaica |> 
  left_join(count_par_pol) |> 
  left_join(count_par_meteo) |> 
  mutate(
    station_yes_par_pol = case_when(
      is.na(station_yes_par_pol) ~ 0,
      .default = station_yes_par_pol
      ),
    station_yes_par_meteo = case_when(
      is.na(station_yes_par_meteo) ~ 0,
      .default = station_yes_par_meteo
      ),
    status_pol = case_when(
      status_pol == "Complete" ~ 1,
      .default = 0
      ),
    status_meteo = case_when(
      status_meteo == "Complete" ~ 1,
      .default = 0
      )
    ) |> 
  select(
    -c(o3,co,so2,no2,pm2.5,pm10,ws,wd,tout,hr,pp,rs)
    ) 

geo_station_rama <- read.csv(
  paste0(
    getwd(),"/data_base/files/cat_estacion.csv"
    ),
  fileEncoding = "latin1"
  ) |> 
  filter(
    obs_estac == ""
    ) |> 
  select(
    -c(cve_estac,obs_estac,id_station)
    ) |> 
  rename(
    nombre_estacion = nom_estac,
    lot = longitud,
    lat = latitud
  )

clean_dir_sinaica <- clean_dir_sinaica |> 
  left_join(geo_station_rama)

map_data("world")
