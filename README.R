## ---- include = FALSE------------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  gargle_oauth_email = "mara@rstudio.com"
)


## ----libraries, message=FALSE----------------------------------------------------
library(tidyverse)
library(googlesheets4)
library(googledrive)


## ----gs4-auth--------------------------------------------------------------------
gs4_auth(email = "mara@rstudio.com")
drive_auth(email = "mara@rstudio.com")


## ----import-data-----------------------------------------------------------------
w_finals_df <- drive_get("Competition_Results_Exports_UIPM_2021_Pentathlon_World_Championships") %>%
  read_sheet(sheet = "Women Finals")


## ----raw-data--------------------------------------------------------------------
w_finals_df


## ----glimpse-raw-----------------------------------------------------------------
glimpse(w_finals_df)


## ----clean-data------------------------------------------------------------------
w_mp_finals <- w_finals_df %>%
  janitor::clean_names() %>%
  separate("name", into = c("name", "uipm_id"), sep = "\n") %>%
  separate("uipm_id", into = c("uipm_id", "dob"), sep = " ") %>%
  separate("fencing", into = c("fencing_pts", "f_rest"), sep = ' \\(') %>%
  separate("f_rest", into = c("fencing_pos", "f_rest"), sep = '\\)\n') %>%
  separate("f_rest", into = c("fencing_wins", "f_rest"), sep = " V - ") %>%
  separate("f_rest", into = c("fencing_losses", NA), sep = " ") %>%
  separate("swimming", into = c("swim_pts", "s_rest"), sep = ' \\(') %>%
  separate("s_rest", into = c("swim_pos", "swim_time"), sep = '\\)\n') %>%
  separate("riding", into = c("riding_pts", "r_rest"), sep = ' \\(') %>%
  separate("r_rest", into = c("riding_pos", "riding_score"), sep = '\\)\n') %>%
  separate("laser_run", into = c("laser_run_pts", "lr_rest"), sep = ' \\(') %>%
  separate("lr_rest", into = c("lr_pos", "lr_time"), sep = '\\)\n')

w_mp_finals


## ----glimpse-clean---------------------------------------------------------------
glimpse(w_mp_finals)


## ----format-results--------------------------------------------------------------
w_mp_finals %>%
  mutate(across(ends_with("pts") | ends_with("pos") | starts_with("fencing") | starts_with("riding"), readr::parse_double)) %>%
  mutate(time_difference = readr::parse_number(time_difference)) %>%
  mutate(dob = readr::parse_date(dob, "%Y-%m-%d")) %>%
  mutate(time_difference = replace_na(time_difference, 0)) -> w_mp_finals

glimpse(w_mp_finals)


## ----duration-stuff--------------------------------------------------------------
w_mp_finals %>%
  separate(lr_time, into = c("lr_mins", "lr_secs"), sep = ":", remove = FALSE) %>%
  mutate(lr_mins = lubridate::dminutes(as.numeric(lr_mins))) %>%
  mutate(across(c("lr_secs", "time_difference"), lubridate::dseconds)) %>%
  mutate(lr_secs = lr_mins + lr_secs) %>%
  mutate(finish_time = lr_secs + time_difference) %>%
  select(-lr_mins) -> w_mp_finals
  
glimpse(w_mp_finals)


## ----mens-finals-----------------------------------------------------------------
m_mp_finals <- drive_get("Competition_Results_Exports_UIPM_2021_Pentathlon_World_Championships") %>%
  read_sheet(sheet = "Men Finals") %>%
  janitor::clean_names() %>%
  separate("name", into = c("name", "uipm_id"), sep = "\n") %>%
  separate("uipm_id", into = c("uipm_id", "dob"), sep = " ") %>%
  separate("fencing", into = c("fencing_pts", "f_rest"), sep = ' \\(') %>%
  separate("f_rest", into = c("fencing_pos", "f_rest"), sep = '\\)\n') %>%
  separate("f_rest", into = c("fencing_wins", "f_rest"), sep = " V - ") %>%
  separate("f_rest", into = c("fencing_losses", NA), sep = " ") %>%
  separate("swimming", into = c("swim_pts", "s_rest"), sep = ' \\(') %>%
  separate("s_rest", into = c("swim_pos", "swim_time"), sep = '\\)\n') %>%
  separate("riding", into = c("riding_pts", "r_rest"), sep = ' \\(') %>%
  separate("r_rest", into = c("riding_pos", "riding_score"), sep = '\\)\n') %>%
  separate("laser_run", into = c("laser_run_pts", "lr_rest"), sep = ' \\(') %>%
  separate("lr_rest", into = c("lr_pos", "lr_time"), sep = '\\)\n') %>%
  mutate(across(ends_with("pts") | ends_with("pos") | starts_with("fencing") | starts_with("riding"), readr::parse_double)) %>%
  mutate(time_difference = readr::parse_number(time_difference)) %>%
  mutate(dob = readr::parse_date(dob, "%Y-%m-%d")) %>%
  mutate(time_difference = replace_na(time_difference, 0)) %>%
  separate(lr_time, into = c("lr_mins", "lr_secs"), sep = ":", remove = FALSE) %>%
  mutate(lr_mins = lubridate::dminutes(as.numeric(lr_mins))) %>%
  mutate(across(c("lr_secs", "time_difference"), lubridate::dseconds)) %>%
  mutate(lr_secs = lr_mins + lr_secs) %>%
  mutate(finish_time = lr_secs + time_difference) %>%
  select(-lr_mins)

glimpse(m_mp_finals)  


## --------------------------------------------------------------------------------
m_mp_finals %>%
  select(c(rank, lr_pos, lr_time, time_difference, finish_time))

