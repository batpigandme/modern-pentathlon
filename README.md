
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Modern Pentathlon 🤺🏊️🏇🏃️🔫

Playing around with results from [Union Internationale de Pentathlon
Moderne (UIPM) 2021 Pentathlon World
Championships](https://www.uipmworld.org/event/uipm-2021-pentathlon-world-championships).

## Motivation

### Part 1: I don’t get it!

The scoring of the modern pentathlon remains utterly inscrutable to me.
You can *kind of* get the gist of it from this article, [Modern
Pentathlon
Scoring](https://www.realbuzz.com/articles-interests/sports-activities/article/modern-pentathlon-scoring/).
But, to be honest, the more I read (including the bulk of the *lengthy*
[UIPM Competition Rules and
Regulations](https://www.uipmworld.org/sites/default/files/uipm_comp_rules_and_reg_2017_a5.pdf)),
the more confused I became.

Nevertheless, I can’t help but to be fascinated by a sport that consists
of: fencing, swimming, show jumping on a horse you’ve only known for *20
minutes*, and then doing something called a *LASER RUN* (which involves
running and shooting targets, and a bunch of other details I can’t be
bothered with)! The Olympics website has a [one-minute explainer
video](https://olympics.com/tokyo-2020/en/sports/modern-pentathlon/)
that captures the sport in – wait for it – one minute! So peep that, if
you’re curious.

### Part 2: *Nasty* data formatting

In a recent episode of [Ellis Hughes](https://twitter.com/ellis_hughes)
and [Patrick Ward’s](https://twitter.com/OSPpatrick) TidyX Screencast,
[TidyX Episode 64 \| Data Cleaning - Ugly Excel Files Part
1](https://youtu.be/R8LK1SNH9p0), the hosts took on the kind of data I
often encounter when looking for various sports stats in the wild; it’s
formatted in a way that’s useful to *someone*, but that someone is *not
me* (or a database, for that matter). This can be particularly galling
when you’re in a so-close-but-so-far situation–e.g. they’re letting you
export it to a familiar format, such as excel, and have all the
different pieces of data, but have smashed it together in such a way
that it’s a far cry from “tidy,” rectangular data.

UIPM indeed lets you export its world championships results data as one
big [Excel
file](https://www.uipmworld.org/event/uipm-2021-pentathlon-world-championships),
but then you take a peek and it looks like this…

![Screenshot of exported results for UIPM 2021 Pentathlon World
Championships opened in Google Sheets](https://i.imgur.com/hmjc8nU.png)

These are the moments that make you remember the value of domain
expertise. At a glance, I could see that there were multiple pieces of
information in various cells. But, with the exception of the second
column, **Name** (which has the competitor’s last name and first name in
bold above what I *assume* is some sort of unique identifier number for
the athlete and their date of birth), I had basically no clue what they
were.

## Data detectivery

Before trying to import my data, I wanted to have at least *some* idea
of what they were – losing formatting isn’t going to make things *more*
obvious. Since the data look slightly different to how they were
presented on the website (below, for example, is some of what you’ll see
for [UIPM 2021 World Championship
Results](https://www.uipmworld.org/event/uipm-2021-pentathlon-world-championships)
if you select **Women** and **Final**), I thought that might provide
some more insight.

![Screenshot of first few records for Women’s Finals results of UIPM for
2021 World Championship Final Results](https://i.imgur.com/qWgpF0m.png)
Indeed, the multiple headers seem to match up with information that’s
crammed into single cells in the Excel export. For example the value
under **Fencing** and **Pts** on the website maps to the first number in
the Excel **Fencing** column, and the number in parentheses next to it
in Excel matches with **Fencing** **Pos**. The value of **Fencing**
**Wins** is the same as the first number below the points and position
in the Excel sheet, so I took a guess that the `# V - # D` formatting
indicates the number of victories and defeats (further evidenced by the
fact that the sum of those two numbers is the same, 36, for each
athlete).

OK, we’re getting somewhere! All of this without even opening the
*160-page* PDF of rules and regulations. Please note that, if you know a
domain expert, *ask them for help*! I do not know any modern
pentathletes (I don’t even think I know anyone who does all five of the
activities involved–if that’s you, hit me up), so I didn’t have that
option. And, *no*, I *don’t* want to talk about how much time I spent
figuring out that **PWR Pts** stands for Pentathlon World Ranking
Points, that **MP Points** stands for Modern Pentathlon Points, or that
**HCP** stands for Handicap (this abbreviation is literally *never*
mentioned in the aforementioned 160-pager).

## Data import with {googlesheets4}

Since I don’t have Excel on this computer (not a flex, just a fact), I
brought the downloaded XLSX file into Google Sheets. So, hooray, we’ll
be using Jenny Bryan’s newly updated
[{googlesheets4}](https://googlesheets4.tidyverse.org/) package along
with [{googledrive}](https://googledrive.tidyverse.org/) for finding the
sheet by name.

``` r
library(tidyverse)
library(googlesheets4)
library(googledrive)
```

In order to access my drive, I’ll be using the authorization function
from googlesheets4, `gs4_auth()`, which allows you to either
interactively select a pre-authorized account in R, or takes you to the
browser to generate obtain a new token for your account.

``` r
gs4_auth()
#> ℹ Suitable tokens found in the cache, associated with these emails:
#> • 'mara@rstudio.com'
#> • 'maraaverick@gmail.com'
#>   Defaulting to the first email.
#> ! Using an auto-discovered, cached token.
#>   To suppress this message, modify your code or options to clearly consent to
#>   the use of a cached token.
#>   See gargle's "Non-interactive auth" vignette for more details:
#>   <https://gargle.r-lib.org/articles/non-interactive-auth.html>
#> ℹ The googlesheets4 package is using a cached token for 'mara@rstudio.com'.
```

Now, we’ll get the file with `googledrive::drive_get()`, and read in the
sheet with `googlesheets4::read_sheet()`.

``` r
w_finals_df <- drive_get("Competition_Results_Exports_UIPM_2021_Pentathlon_World_Championships") %>%
  read_sheet(sheet = "Women Finals")
#> ! Using an auto-discovered, cached token.
#>   To suppress this message, modify your code or options to clearly consent to
#>   the use of a cached token.
#>   See gargle's "Non-interactive auth" vignette for more details:
#>   <https://gargle.r-lib.org/articles/non-interactive-auth.html>
#> ℹ The googledrive package is using a cached token for 'mara@rstudio.com'.
#> ✓ The input `path` resolved to exactly 1 file.
#> Reading from "Competition_Results_Exports_UIPM_2021_Pentathlon_World_Championships"
#> Range "'Women Finals'"
```

And let’s take a quick peek at what that looks like…

``` r
w_finals_df
#> # A tibble: 36 x 9
#>     Rank Name        Nation Fencing    Swimming   Riding   LaserRun  `MP Points`
#>    <dbl> <chr>       <chr>  <chr>      <chr>      <chr>    <chr>           <dbl>
#>  1     1 "PROKOPENK… BLR    "246 (1)\… "251 (35)… "275 (3… "581 (1)…        1353
#>  2     2 "CLOUVEL E… FRA    "220 (8)\… "292 (1)\… "286 (1… "543 (6)…        1341
#>  3     3 "GULYAS Mi… HUN    "233 (3)\… "286 (4)\… "285 (2… "535 (10…        1339
#>  4     4 "SCHLEU An… GER    "214 (14)… "270 (15)… "293 (9… "553 (4)…        1330
#>  5     5 "MICHELI E… ITA    "214 (13)… "285 (5)\… "286 (1… "539 (8)…        1324
#>  6     6 "LANGREHR … GER    "227 (5)\… "267 (22)… "293 (1… "537 (9)…        1324
#>  7     7 "VEGA Tama… MEX    "214 (15)… "270 (16)… "297 (5… "542 (7)…        1323
#>  8     8 "KHOKHLOVA… UKR    "227 (7)\… "267 (21)… "298 (4… "520 (14…        1312
#>  9     9 "KOHLMANN … GER    "220 (9)\… "271 (14)… "300 (1… "515 (16…        1306
#> 10    10 "ASADAUSKA… LTU    "212 (17)… "269 (18)… "255 (3… "567 (2)…        1303
#> # … with 26 more rows, and 1 more variable: Time Difference <chr>
```

To see how the cell values turned out, let’s use `glimpse()`.

``` r
glimpse(w_finals_df)
#> Rows: 36
#> Columns: 9
#> $ Rank              <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1…
#> $ Name              <chr> "PROKOPENKO Anastasiya\nW039969 1985-09-20", "CLOUVE…
#> $ Nation            <chr> "BLR", "FRA", "HUN", "GER", "ITA", "GER", "MEX", "UK…
#> $ Fencing           <chr> "246 (1)\n24 V - 11 D", "220 (8)\n20 V - 15 D", "233…
#> $ Swimming          <chr> "251 (35)\n02:29.79", "292 (1)\n02:09.48", "286 (4)\…
#> $ Riding            <chr> "275 (30)\n71.00", "286 (17)\n65.00", "285 (21)\n68.…
#> $ LaserRun          <chr> "581 (1)\n11:59.80", "543 (6)\n12:37.10", "535 (10)\…
#> $ `MP Points`       <dbl> 1353, 1341, 1339, 1330, 1324, 1324, 1323, 1312, 1306…
#> $ `Time Difference` <chr> NA, "12''", "14''", "23''", "29''", "29''", "30''", …
```

## Time to clean up

OK, first thing’s first: getting the different pieces of data into their
own columns. To do this, I’m going to lean heavily on
`tidyr::separate()`. I’m quite confident that someone better versed in
regular expressions would be a little less hacky about things, but
that’s just life. I also like to use `janitor::clean_names()` with
wild-caught data because I loathe dealing with letter cases and spaces.

``` r
w_mp_finals <- w_finals_df %>%
  janitor::clean_names() %>%
  separate("name", into = c("name", "id"), sep = "\n") %>%
  separate("id", into = c("id", "dob"), sep = " ") %>%
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
#> # A tibble: 36 x 20
#>     rank name         id     dob     nation fencing_pts fencing_pos fencing_wins
#>    <dbl> <chr>        <chr>  <chr>   <chr>  <chr>       <chr>       <chr>       
#>  1     1 PROKOPENKO … W0399… 1985-0… BLR    246         1           24          
#>  2     2 CLOUVEL Elo… W0394… 1989-0… FRA    220         8           20          
#>  3     3 GULYAS Mich… W0423… 2000-1… HUN    233         3           22          
#>  4     4 SCHLEU Anni… W0039… 1990-0… GER    214         14          19          
#>  5     5 MICHELI Ele… W0408… 1999-0… ITA    214         13          19          
#>  6     6 LANGREHR Re… W0400… 1998-0… GER    227         5           21          
#>  7     7 VEGA Tamara  W0394… 1993-0… MEX    214         15          19          
#>  8     8 KHOKHLOVA I… W0396… 1990-0… UKR    227         7           21          
#>  9     9 KOHLMANN Ja… W0028… 1990-1… GER    220         9           20          
#> 10    10 ASADAUSKAIT… W0020… 1984-0… LTU    212         17          18          
#> # … with 26 more rows, and 12 more variables: fencing_losses <chr>,
#> #   swim_pts <chr>, swim_pos <chr>, swim_time <chr>, riding_pts <chr>,
#> #   riding_pos <chr>, riding_score <chr>, laser_run_pts <chr>, lr_pos <chr>,
#> #   lr_time <chr>, mp_points <dbl>, time_difference <chr>
```

``` r
glimpse(w_mp_finals)
#> Rows: 36
#> Columns: 20
#> $ rank            <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,…
#> $ name            <chr> "PROKOPENKO Anastasiya", "CLOUVEL Elodie", "GULYAS Mic…
#> $ id              <chr> "W039969", "W039469", "W042365", "W003945", "W040837",…
#> $ dob             <chr> "1985-09-20", "1989-01-14", "2000-10-24", "1990-04-03"…
#> $ nation          <chr> "BLR", "FRA", "HUN", "GER", "ITA", "GER", "MEX", "UKR"…
#> $ fencing_pts     <chr> "246", "220", "233", "214", "214", "227", "214", "227"…
#> $ fencing_pos     <chr> "1", "8", "3", "14", "13", "5", "15", "7", "9", "17", …
#> $ fencing_wins    <chr> "24", "20", "22", "19", "19", "21", "19", "21", "20", …
#> $ fencing_losses  <chr> "11", "15", "13", "16", "16", "14", "16", "14", "15", …
#> $ swim_pts        <chr> "251", "292", "286", "270", "285", "267", "270", "267"…
#> $ swim_pos        <chr> "35", "1", "4", "15", "5", "22", "16", "21", "14", "18…
#> $ swim_time       <chr> "02:29.79", "02:09.48", "02:12.27", "02:20.27", "02:12…
#> $ riding_pts      <chr> "275", "286", "285", "293", "286", "293", "297", "298"…
#> $ riding_pos      <chr> "30", "17", "21", "9", "18", "13", "5", "4", "1", "35"…
#> $ riding_score    <chr> "71.00", "65.00", "68.00", "61.00", "67.00", "64.00", …
#> $ laser_run_pts   <chr> "581", "543", "535", "553", "539", "537", "542", "520"…
#> $ lr_pos          <chr> "1", "6", "10", "4", "8", "9", "7", "14", "16", "2", "…
#> $ lr_time         <chr> "11:59.80", "12:37.10", "12:45.60", "12:27.90", "12:41…
#> $ mp_points       <dbl> 1353, 1341, 1339, 1330, 1324, 1324, 1323, 1312, 1306, …
#> $ time_difference <chr> NA, "12''", "14''", "23''", "29''", "29''", "30''", "4…
```

Now that we’ve separated our data out, let’s use some of the
`readr::parse_*()` functions (handy even when you’re not reading the
data in) to get the data types right. Using `readr::parse_number()` is
especially nice when working with numeric data that has any character in
front of or after the numbers themselves.

``` r
w_mp_finals %>%
  mutate(across(ends_with("pts") | ends_with("pos") | starts_with("fencing") | starts_with("riding"), readr::parse_double)) %>%
  mutate(time_difference = readr::parse_number(time_difference)) %>%
  mutate(dob = readr::parse_date(dob, "%Y-%m-%d")) -> w_mp_finals

glimpse(w_mp_finals)
#> Rows: 36
#> Columns: 20
#> $ rank            <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,…
#> $ name            <chr> "PROKOPENKO Anastasiya", "CLOUVEL Elodie", "GULYAS Mic…
#> $ id              <chr> "W039969", "W039469", "W042365", "W003945", "W040837",…
#> $ dob             <date> 1985-09-20, 1989-01-14, 2000-10-24, 1990-04-03, 1999-…
#> $ nation          <chr> "BLR", "FRA", "HUN", "GER", "ITA", "GER", "MEX", "UKR"…
#> $ fencing_pts     <dbl> 246, 220, 233, 214, 214, 227, 214, 227, 220, 212, 167,…
#> $ fencing_pos     <dbl> 1, 8, 3, 14, 13, 5, 15, 7, 9, 17, 34, 20, 10, 4, 16, 1…
#> $ fencing_wins    <dbl> 24, 20, 22, 19, 19, 21, 19, 21, 20, 18, 11, 18, 20, 22…
#> $ fencing_losses  <dbl> 11, 15, 13, 16, 16, 14, 16, 14, 15, 17, 24, 17, 15, 13…
#> $ swim_pts        <dbl> 251, 292, 286, 270, 285, 267, 270, 267, 271, 269, 268,…
#> $ swim_pos        <dbl> 35, 1, 4, 15, 5, 22, 16, 21, 14, 18, 20, 2, 13, 23, 25…
#> $ swim_time       <chr> "02:29.79", "02:09.48", "02:12.27", "02:20.27", "02:12…
#> $ riding_pts      <dbl> 275, 286, 285, 293, 286, 293, 297, 298, 300, 255, 299,…
#> $ riding_pos      <dbl> 30, 17, 21, 9, 18, 13, 5, 4, 1, 35, 2, 25, 11, 24, 22,…
#> $ riding_score    <dbl> 71, 65, 68, 61, 67, 64, 70, 69, 65, 85, 68, 77, 67, 77…
#> $ laser_run_pts   <dbl> 581, 543, 535, 553, 539, 537, 542, 520, 515, 567, 564,…
#> $ lr_pos          <dbl> 1, 6, 10, 4, 8, 9, 7, 14, 16, 2, 3, 17, 22, 21, 15, 20…
#> $ lr_time         <chr> "11:59.80", "12:37.10", "12:45.60", "12:27.90", "12:41…
#> $ mp_points       <dbl> 1353, 1341, 1339, 1330, 1324, 1324, 1323, 1312, 1306, …
#> $ time_difference <dbl> NA, 12, 14, 23, 29, 29, 30, 41, 47, 50, 55, 59, 62, 65…
```

If I had a sense of what I might do with them, I would probably use
[`lubridate::duration()`](https://lubridate.tidyverse.org/reference/duration.html)
and/or its related family of functions to deal with `swim_time`,
`lr_time`, and `time_difference`. This is helpful because time-math is
funky, and it’s easy to forget what you’re dealing with when you’ve got
minutes, seconds, *and* decimals in the mix. Actually, let’s take a
quick look at the laser-run time (`lr_time`) and `time_difference`
variables to see how the positions in the laser run can be different to
the overall rank even though the athletes cross the finish line in the
order of the final rankings.

``` r
w_mp_finals %>%
  separate(lr_time, into = c("lr_mins", "lr_secs"), sep = ":", remove = FALSE) %>%
  mutate(lr_mins = lubridate::dminutes(as.numeric(lr_mins))) %>%
  mutate(across(c("lr_secs", "time_difference"), lubridate::dseconds)) %>%
  mutate(lr_secs = lr_mins + lr_secs) %>%
  mutate(finish_time = lr_secs + time_difference) %>%
  select(-lr_mins) %>%
  glimpse()
#> Rows: 36
#> Columns: 22
#> $ rank            <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,…
#> $ name            <chr> "PROKOPENKO Anastasiya", "CLOUVEL Elodie", "GULYAS Mic…
#> $ id              <chr> "W039969", "W039469", "W042365", "W003945", "W040837",…
#> $ dob             <date> 1985-09-20, 1989-01-14, 2000-10-24, 1990-04-03, 1999-…
#> $ nation          <chr> "BLR", "FRA", "HUN", "GER", "ITA", "GER", "MEX", "UKR"…
#> $ fencing_pts     <dbl> 246, 220, 233, 214, 214, 227, 214, 227, 220, 212, 167,…
#> $ fencing_pos     <dbl> 1, 8, 3, 14, 13, 5, 15, 7, 9, 17, 34, 20, 10, 4, 16, 1…
#> $ fencing_wins    <dbl> 24, 20, 22, 19, 19, 21, 19, 21, 20, 18, 11, 18, 20, 22…
#> $ fencing_losses  <dbl> 11, 15, 13, 16, 16, 14, 16, 14, 15, 17, 24, 17, 15, 13…
#> $ swim_pts        <dbl> 251, 292, 286, 270, 285, 267, 270, 267, 271, 269, 268,…
#> $ swim_pos        <dbl> 35, 1, 4, 15, 5, 22, 16, 21, 14, 18, 20, 2, 13, 23, 25…
#> $ swim_time       <chr> "02:29.79", "02:09.48", "02:12.27", "02:20.27", "02:12…
#> $ riding_pts      <dbl> 275, 286, 285, 293, 286, 293, 297, 298, 300, 255, 299,…
#> $ riding_pos      <dbl> 30, 17, 21, 9, 18, 13, 5, 4, 1, 35, 2, 25, 11, 24, 22,…
#> $ riding_score    <dbl> 71, 65, 68, 61, 67, 64, 70, 69, 65, 85, 68, 77, 67, 77…
#> $ laser_run_pts   <dbl> 581, 543, 535, 553, 539, 537, 542, 520, 515, 567, 564,…
#> $ lr_pos          <dbl> 1, 6, 10, 4, 8, 9, 7, 14, 16, 2, 3, 17, 22, 21, 15, 20…
#> $ lr_time         <chr> "11:59.80", "12:37.10", "12:45.60", "12:27.90", "12:41…
#> $ lr_secs         <Duration> 719.8s (~12 minutes), 757.1s (~12.62 minutes), 76…
#> $ mp_points       <dbl> 1353, 1341, 1339, 1330, 1324, 1324, 1323, 1312, 1306, …
#> $ time_difference <Duration> NA, 12s, 14s, 23s, 29s, 29s, 30s, 41s, 47s, 50s, …
#> $ finish_time     <Duration> NA, 769.1s (~12.82 minutes), 779.6s (~12.99 minut…
```

Huh! Now that I look at it this way, it seems that I *still* don’t
understand how that last part works. Clearly I need to go back and
review the rules and regulations of the Modern Pentathlon.
