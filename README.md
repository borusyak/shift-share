# shift-share
Replication package and code for "Quasi-Experimental Shift-Share Designs"
(Borusyak, Hull, and Jaravel, Review of Economic Studies 2022, https://academic.oup.com/restud/article/89/1/181/6294942)

This repository includes the replication archive with all code and data necessary to replicate the results reported in the paper, described in detail in readme files in each of the subfolders. It's structured in three parts:
1) The Autor et al. (2013) application (produces Tables 1--4 and C1--C5 and Figure C1 of our paper)
2) The Bartik (1991) application (Table C6)
3) The Monte-Carlo simulation (Tables C7--C8)
We also include an updated version of the ssaggregate Stata command which constructs shock-level aggregates of the outcome and treatment variables. It can also be downloaded directly from ssc.

We appreciate all comments on the paper and code!

UPD 2025/03/01: A couple of issues have been brought to our attention.
1) Please execute "version 16" before running the replication code. Since the older versions of Stata, the sorting procedure has changed, which affects how Table 1 is displayed. Also, the "mixed" command used to compute intra-class correlations in Table 2 reports different standard errors than in our original analysis.
2) If you get an error "last estimates not found" when running the code for Table 4, please follow the advice here: https://github.com/sergiocorreia/ivreghdfe/issues/54
