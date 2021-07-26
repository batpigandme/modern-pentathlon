
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Modern Pentathlon 🤺🏊️🏇🏃️🔫

Playing around with results from [Union Internationale de Pentathlon
Moderne (UIPM) 2021 Pentathlon World
Championships](https://www.uipmworld.org/event/uipm-2021-pentathlon-world-championships).

## 📺 TidyX Episode 69

Ellis and Patrick were kind enough to have me as a guest on their TidyX
screencast to go through most of the code that’s in this document. You
can see the episode on YouTube here, [**TidyX Episode 69 \| Modern
Pentathlons with Mara Averick**](https://youtu.be/1356s1-as4o).

Here’s a pretty picture of what it looks like (plus some random graphics
I tossed on top):

![Screencap of TidyX Episode 69 - Modern Pentathlon with title overlaid
on top, thumbnail of TidyX, and emoji for fencing, swimming, riding,
running, and the water gun.](https://i.imgur.com/dfRWiIT.png)

OK, on with the story…

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
minutes*, and then doing something called a ***LASER RUN*** (which
involves running and shooting targets, and a bunch of other details I
can’t be bothered with)! The Olympics website has a [one-minute
explainer
video](https://olympics.com/tokyo-2020/en/sports/modern-pentathlon/)
that captures the sport in—wait for it—one minute! So peep that, if
you’re curious.

### Part 2: *Nasty* data formatting

In a recent episode of [Ellis Hughes](https://twitter.com/ellis_hughes)
and [Patrick Ward’s](https://twitter.com/OSPpatrick) TidyX Screencast,
[TidyX Episode 64 \| Data Cleaning - Ugly Excel Files Part
1](https://youtu.be/R8LK1SNH9p0), the hosts took on the kind of data I
often encounter when looking for various sports stats in the wild; it’s
formatted in a way that’s useful to *someone*, but that someone is *not
me* (or a database, for that matter). This can be particularly galling
when you’re in a so-close-but-so-far situation—e.g. they’re letting you
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
of what they were—losing formatting isn’t going to make things *more*
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
activities involved—if that’s you, hit me up), so I didn’t have that
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
file by name.

``` r
library(tidyverse)
library(googlesheets4)
library(googledrive)
```

In order to access my Google Sheets and Drive accounts, respectively,
I’ll be using the authorization function from googlesheets4,
[`gs4_auth()`](https://googlesheets4.tidyverse.org/reference/gs4_auth.html),
which allows you to either interactively select a pre-authorized account
in R, or takes you to the browser to generate obtain a new token for
your account. For posterity’s sake, I’m also showing the function from
the googledrive package,
[`drive_auth()`](https://googledrive.tidyverse.org/reference/drive_auth.html),
which does the same thing. To learn more about authenticating your
account in an R Markdown document, see the [Non-interactive
auth](https://gargle.r-lib.org/articles/non-interactive-auth.html#sidebar-2-i-just-want-my-rmd-to-render)
article for [{gargle}](https://gargle.r-lib.org/).

``` r
gs4_auth(email = "mara@rstudio.com")
drive_auth(email = "mara@rstudio.com")
```

Now, we’ll get the file with
[`googledrive::drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html),
and read in the sheet with
[`googlesheets4::read_sheet()`](https://googlesheets4.tidyverse.org/reference/range_read.html).

``` r
w_finals_df <- drive_get("Competition_Results_Exports_UIPM_2021_Pentathlon_World_Championships") %>%
  read_sheet(sheet = "Women Finals")
#> Auto-refreshing stale OAuth token.
#> ✓ The input `path` resolved to exactly 1 file.
#> Auto-refreshing stale OAuth token.
#> ✓ Reading from
#>   "Competition_Results_Exports_UIPM_2021_Pentathlon_World_Championships".
#> ✓ Range ''Women Finals''.
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

To see how the cell values turned out, let’s use
[`glimpse()`](https://pillar.r-lib.org/reference/glimpse.html).

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
[`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html).
I’m quite confident that someone better versed in regular expressions
would be a little less hacky about things, but that’s just life. I also
like to use
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
with wild-caught data because I loathe dealing with letter cases and
spaces.

``` r
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
#> # A tibble: 36 x 20
#>     rank name         uipm_id dob    nation fencing_pts fencing_pos fencing_wins
#>    <dbl> <chr>        <chr>   <chr>  <chr>  <chr>       <chr>       <chr>       
#>  1     1 PROKOPENKO … W039969 1985-… BLR    246         1           24          
#>  2     2 CLOUVEL Elo… W039469 1989-… FRA    220         8           20          
#>  3     3 GULYAS Mich… W042365 2000-… HUN    233         3           22          
#>  4     4 SCHLEU Anni… W003945 1990-… GER    214         14          19          
#>  5     5 MICHELI Ele… W040837 1999-… ITA    214         13          19          
#>  6     6 LANGREHR Re… W040067 1998-… GER    227         5           21          
#>  7     7 VEGA Tamara  W039422 1993-… MEX    214         15          19          
#>  8     8 KHOKHLOVA I… W039606 1990-… UKR    227         7           21          
#>  9     9 KOHLMANN Ja… W002853 1990-… GER    220         9           20          
#> 10    10 ASADAUSKAIT… W002054 1984-… LTU    212         17          18          
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
#> $ uipm_id         <chr> "W039969", "W039469", "W042365", "W003945", "W040837",…
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
[`readr::parse_*()`](https://readr.tidyverse.org/reference/parse_atomic.html)
functions (handy even when you’re not reading the data in) to get the
data types right. Using
[`readr::parse_number()`](https://readr.tidyverse.org/reference/parse_number.html)
is especially nice when working with numeric data that has any character
in front of or after the numbers themselves. Since we’re converting
`time_difference` to a number, we can also go ahead and replace the `NA`
in that column with a zero.

``` r
w_mp_finals %>%
  mutate(across(ends_with("pts") | ends_with("pos") | starts_with("fencing") | starts_with("riding"), readr::parse_double)) %>%
  mutate(time_difference = readr::parse_number(time_difference)) %>%
  mutate(dob = readr::parse_date(dob, "%Y-%m-%d")) %>%
  mutate(time_difference = replace_na(time_difference, 0)) -> w_mp_finals

glimpse(w_mp_finals)
#> Rows: 36
#> Columns: 20
#> $ rank            <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,…
#> $ name            <chr> "PROKOPENKO Anastasiya", "CLOUVEL Elodie", "GULYAS Mic…
#> $ uipm_id         <chr> "W039969", "W039469", "W042365", "W003945", "W040837",…
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
#> $ time_difference <dbl> 0, 12, 14, 23, 29, 29, 30, 41, 47, 50, 55, 59, 62, 65,…
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

(Sidenote: I’m being a *little* sketchy in my intermediary variables
below, as I temporarily use `lr_secs` to denote the seconds portion of
the total time, and then ultimately use the same name to denote the
final laser-run time in seconds. Because I’m playing things loose with
that, I’m keeping the original character-encoded time by using
`remove = FALSE` in my first `separate()` call).

``` r
w_mp_finals %>%
  separate(lr_time, into = c("lr_mins", "lr_secs"), sep = ":", remove = FALSE) %>%
  mutate(lr_mins = lubridate::dminutes(as.numeric(lr_mins))) %>%
  mutate(across(c("lr_secs", "time_difference"), lubridate::dseconds)) %>%
  mutate(lr_secs = lr_mins + lr_secs) %>%
  mutate(finish_time = lr_secs + time_difference) %>%
  select(-lr_mins) -> w_mp_finals
  
glimpse(w_mp_finals)
#> Rows: 36
#> Columns: 22
#> $ rank            <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,…
#> $ name            <chr> "PROKOPENKO Anastasiya", "CLOUVEL Elodie", "GULYAS Mic…
#> $ uipm_id         <chr> "W039969", "W039469", "W042365", "W003945", "W040837",…
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
#> $ time_difference <Duration> 0s, 12s, 14s, 23s, 29s, 29s, 30s, 41s, 47s, 50s, …
#> $ finish_time     <Duration> 719.8s (~12 minutes), 769.1s (~12.82 minutes), 77…
```

Huh! Now that I look at it this way, it seems that I *still* don’t
understand how that last part works. Clearly I need to go back and
review the rules and regulations of the Modern Pentathlon.

## All together now

To show you what this would all look like in one *long* series of pipes,
I’ll use the results from the same Excel file for the *Men’s* finals.
(⚠️ Caution: A series of pipes this long is likely hazardous to your
health…also, you shouldn’t copy and paste this much code in real life).

``` r
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
#> ✓ The input `path` resolved to exactly 1 file.
#> ✓ Reading from
#>   "Competition_Results_Exports_UIPM_2021_Pentathlon_World_Championships".
#> ✓ Range ''Men Finals''.

glimpse(m_mp_finals)  
#> Rows: 36
#> Columns: 22
#> $ rank            <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,…
#> $ name            <chr> "MAROSI Adam", "LIFANOV Alexander", "ELGENDY Ahmed", "…
#> $ uipm_id         <chr> "M000964", "M040502", "M042113", "M040924", "M039549",…
#> $ dob             <date> 1984-07-25, 1996-04-15, 2000-03-01, 1997-06-01, 1994-…
#> $ nation          <chr> "HUN", "RMPF", "EGY", "EGY", "GER", "KOR", "BLR", "KOR…
#> $ fencing_pts     <dbl> 256, 262, 196, 227, 217, 214, 244, 228, 233, 214, 232,…
#> $ fencing_pos     <dbl> 2, 1, 23, 10, 12, 14, 5, 8, 6, 13, 7, 9, 11, 26, 4, 20…
#> $ fencing_wins    <dbl> 26, 27, 16, 21, 19, 19, 24, 21, 22, 19, 22, 21, 20, 15…
#> $ fencing_losses  <dbl> 9, 8, 19, 14, 16, 16, 11, 14, 13, 16, 13, 14, 15, 20, …
#> $ swim_pts        <dbl> 302, 294, 305, 284, 296, 306, 300, 300, 304, 297, 292,…
#> $ swim_pos        <dbl> 11, 23, 5, 34, 18, 3, 14, 13, 6, 17, 25, 20, 24, 31, 3…
#> $ swim_time       <chr> "02:04.36", "02:08.29", "02:02.68", "02:13.05", "02:07…
#> $ riding_pts      <dbl> 300, 300, 292, 297, 300, 284, 286, 273, 259, 272, 286,…
#> $ riding_pos      <dbl> 2, 5, 15, 11, 3, 26, 24, 29, 33, 30, 25, 10, 21, 14, 2…
#> $ riding_score    <dbl> 66, 64, 68, 70, 65, 69, 65, 73, 73, 62, 66, 69, 70, 68…
#> $ laser_run_pts   <dbl> 577, 570, 624, 604, 596, 603, 575, 602, 605, 615, 585,…
#> $ lr_pos          <dbl> 19, 25, 1, 4, 10, 5, 22, 7, 3, 2, 14, 23, 21, 6, 28, 1…
#> $ lr_time         <chr> "12:03.50", "12:10.30", "11:16.90", "11:36.13", "11:44…
#> $ lr_secs         <Duration> 723.5s (~12.06 minutes), 730.3s (~12.17 minutes),…
#> $ mp_points       <dbl> 1435, 1426, 1417, 1412, 1409, 1407, 1405, 1403, 1401, …
#> $ time_difference <Duration> 0s, 9s, 18s, 23s, 26s, 28s, 30s, 32s, 34s, 37s, 4…
#> $ finish_time     <Duration> 723.5s (~12.06 minutes), 739.3s (~12.32 minutes),…
```

If we had any doubts about my misunderstanding the way that the time
difference plays into the final ranking, the men’s finals make it clear
that I am most definitely wrong. 😬

What makes me so sure? Well, given they’re supposed to cross the finish
line in the order of their ranking, `finish_time` would go lowest to
highest/match the order of `rank`, below.

``` r
m_mp_finals %>%
  select(c(rank, lr_pos, lr_time, time_difference, finish_time))
#> # A tibble: 36 x 5
#>     rank lr_pos lr_time  time_difference finish_time             
#>    <dbl>  <dbl> <chr>    <Duration>      <Duration>              
#>  1     1     19 12:03.50 0s              723.5s (~12.06 minutes) 
#>  2     2     25 12:10.30 9s              739.3s (~12.32 minutes) 
#>  3     3      1 11:16.90 18s             694.9s (~11.58 minutes) 
#>  4     4      4 11:36.13 23s             719.13s (~11.99 minutes)
#>  5     5     10 11:44.10 26s             730.1s (~12.17 minutes) 
#>  6     6      5 11:37.00 28s             725s (~12.08 minutes)   
#>  7     7     22 12:05.70 30s             755.7s (~12.6 minutes)  
#>  8     8      7 11:38.10 32s             730.1s (~12.17 minutes) 
#>  9     9      3 11:35.20 34s             729.2s (~12.15 minutes) 
#> 10    10      2 11:25.10 37s             722.1s (~12.04 minutes) 
#> # … with 26 more rows
```

For a quick sanity check, let’s make sure that the points for the
individual events (the variables with the `_pts` suffixes) add up to
`mp_points`. This could be *a bit* off, due to various penalties in the
rules and regulations that, theoretically, might be deducted from the
final score and not from an individual event. But that should be an
anomaly.

``` r
m_mp_finals %>%
  select(c(rank, ends_with("_pts"), mp_points)) %>%
  group_by(rank) %>%
  mutate("event_pt_sum" = sum(fencing_pts, swim_pts, riding_pts, laser_run_pts))
#> # A tibble: 36 x 7
#> # Groups:   rank [36]
#>     rank fencing_pts swim_pts riding_pts laser_run_pts mp_points event_pt_sum
#>    <dbl>       <dbl>    <dbl>      <dbl>         <dbl>     <dbl>        <dbl>
#>  1     1         256      302        300           577      1435         1435
#>  2     2         262      294        300           570      1426         1426
#>  3     3         196      305        292           624      1417         1417
#>  4     4         227      284        297           604      1412         1412
#>  5     5         217      296        300           596      1409         1409
#>  6     6         214      306        284           603      1407         1407
#>  7     7         244      300        286           575      1405         1405
#>  8     8         228      300        273           602      1403         1403
#>  9     9         233      304        259           605      1401         1401
#> 10    10         214      297        272           615      1398         1398
#> # … with 26 more rows
```

Well, that looks OK… Mysteries of the modern pentathlon abound.

## Learn more (about the R packages)

The ever-excellent Jenny Bryan (author of the gargle, googledrive, and
googlesheets4 packages) has written blog posts highlighting the latest
(as of this writing, 2021-07-26) changes in gogogledrive, and gargle:

-   [googledrive
    2.0.0](https://www.tidyverse.org/blog/2021/07/googledrive-2-0-0/)  
-   [gargle 1.2.0](https://www.tidyverse.org/blog/2021/07/gargle-1-2-0/)

A post on [googlesheets4
1.0.0](https://googlesheets4.tidyverse.org/news/index.html#googlesheets4-1-0-0-2021-07-21)
is in the pipeline, and will be out on the [tidyverse
blog](https://www.tidyverse.org/blog/) soon.

I cannot say enough good things about [Sam
Firke](https://samfirke.com/)’s
[janitor](https://sfirke.github.io/janitor/) package—so, be sure to peep
that, too.
