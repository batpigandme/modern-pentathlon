
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
that captures the sport in–wait for it–one minute! So peep that, if
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
of what they were–losing formatting isn’t going to make things *more*
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
option.
