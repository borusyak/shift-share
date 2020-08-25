{smcl}
{* *! version 1.2.2 January 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "ssaggregate##syntax"}{...}
{viewerjumpto "Description" "ssaggregate##description"}{...}
{viewerjumpto "Options" "ssaggregate##options"}{...}
{viewerjumpto "Examples" "ssaggregate##examples"}{...}
{title:Title}

{phang}
{bf:ssaggregate} {hline 2} Create industry-level aggregates for shift-share IV


{marker syntax}{...}
{title:Syntax}

{phang}
Using "long" exposure weights, saved separately (executes faster): 

{p 8 17 2}
{cmdab:ssaggregate} 
{it:{help varlist}}
[{it:{help if}}]
[{it:{help in}}]
[{it:{help weight}}], {bf:n(}{it:{help varlist}}{bf:)}  {bf:s(}{it:{help varname}}{bf:)} {bf:l(}{it:{help varlist}}{bf:)}
{bf:sfilename(}{it:{help filename}}{bf:)}
[{cmd:}{it:other options}]

{phang}
Using "wide" exposure weights, saved in memory: 

{p 8 17 2}
{cmdab:ssaggregate} 
{it:{help varlist}}
[{it:{help if}}]
[{it:{help in}}]
[{it:{help weight}}], {bf:n(}{it:{help varname}}{bf:)} {bf:s(}{it:stubname}{bf:)}
[{cmd:}{it:other options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:General}
{synopt:{opt t(varlist)}} period identifiers {p_end}
{synopt:{opt c:ontrols(strings)}}  sets of control variables to be partialled out {p_end}
{synopt:{opt a:bsorb(strings)}}  sets of catagorical variables that identify fixed effects to be absorbed {p_end}
{synopt:{opt addm:issing}}  create "missing industry" observations {p_end}

{syntab:With "long" exposure weights}
{synopt:{opt n(varlist)}} industry identifiers (required){p_end}
{synopt:{opt s(varname)}} name of exposure weight variable (required){p_end}
{synopt:{opt l(varlist)}} location identifiers (required){p_end}
{synopt:{opt sfile:name(filename)}} exposure weight dataset (required){p_end}

{syntab:With "wide" exposure weights}
{synopt:{opt n(varname)}} industry identifier (required){p_end}
{synopt:{opt s(stubname)}} stub of the names of exposure weight variables (required){p_end}
{synopt:{opt str:ing}} indicates that the industry identifier is a string {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:ssaggregate} converts "location-level" variables in a shift-share IV dataset to a dataset of exposure-weighted "industry-level" aggregates, as described in {browse "https://arxiv.org/abs/1806.01221":Borusyak, Hull, and Jaravel (2020)}.

{pstd} There are two ways to specify {cmd:ssaggregate}, depending on whether the industry exposure weights are saved in "long" format (in a separate dataset) or in "wide" format (in the dataset in memory). 
In general {cmd:ssaggregate} will execute faster with "long" exposure weights. See the 
{it:{help ssaggregate##examples:examples}} for proper syntax in both cases. 

{pstd}In the "long" case the dataset in memory must be uniquely identified by the cross-sectional variables in {bf:l()} and, when applicable, the period identifiers in {bf:t()}. The
separate shares dataset is given by {bf:sfilename()} and should be uniquely indexed by the variables in {bf:l()} and {bf:n()} (and {bf:t()}, when specified). 
{bf:s()} should contain the name of the exposure weight variable, and the two datasets should contain only matching values of {bf:l()} and {bf:t()}.

{pstd}In the "wide" case the {bf:s()} option should contain the common stub of the names of exposure weight variables, and {bf:n()} should contain the target name of the shock identifier.
For example, {bf:s(share)} should be specified when the exposure variables are named {it:share101}, {it:share102}, etc., with 101 and 102 being values of the shock identifier in {bf:n()}. 
The {bf:string} option should be specified when the shock identifer is a string variable. Missing values in any of the exposure weight variables are interpreted as zeros.
The dataset in memory may be a panel or repeated cross section, with periods indexed by {bf:t()}.

{pstd}In both cases there should be no missing values for the location-level variables, conditional
on any {it:if} and {it:in} sample restrictions. The resulting industry-level dataset will contain exposure-weighted
de-meaned averages of the location-level variables, along with the average exposure weight {it:s_n}. This dataset will be be indexed by 
the variables in {bf:n()} (and {bf:t()}, when specified). 

{pstd}When the {bf:controls()}
option is included the location-level variables are first residualized by each of the specified sets of controls. Each set should be included in the option as a separate string (in quotes);
for example as {bf:controls("var1" "var1 var2" "var1 var3 var4")}, where {it:var1}-{it:var4} are names of control variables in memory. If one set of controls is empty, it can be included (as {bf:""}) anywhere but in the final position 
due to a technical issue. The transformed variables are then indexed by the control set number: for example 
{it:y1}-{it:y3} when {it:y} is the variable in memory to be transformed. An exception is when either {bf:controls()} or {bf:absorb()} or both are included with only a single set of controls or fixed effects (still in quotes),
or when both commands are omitted. Then the transformation of variable {it:y} is also named {it:y}.

{pstd}When the {bf:absorb()}
option is included the location-level variables are first residualized by each of the specified sets of fixed effects. Each set should be included as a separate string (in quotes), as in the {bf:controls()} option.
If one set of controls is empty, it can be included (as {bf:""}) anywhere but in the final position due to a technical issue.
When both options are specified the sets of controls and fixed effects in the same position are included together in the first-step residualization. For example specifying both {bf:controls("var1" "var1 var2")}
and {bf:absorb("fe1" "fe1" "fe1 fe2")} will produce transformed variables {it:y1}-{it:y3} when {it:y} is the variable in memory to be transformed, where {it:y1} is residualized on {it:var1} and {it:fe1}, {it:y2} is
residualized on {it:var1}, {it:var2}, and {it:fe1}, and {it:y3} is residualized on {it:fe1} and {it:fe2}.

{pstd}Including the {bf:addmissing} option generates a "missing industry" observation, with exposure weights equal to one minus
the sum of a location's exposure weights. {browse "https://arxiv.org/abs/1806.01221":Borusyak, Hull, and Jaravel (2020)} recommend including
this option when the the sum of exposure weights varies across locations (see Section 3.2). The missing industry observations will
be identified by missing identifiers in {bf:n()}.

{pstd}Note that no information on industry shocks is used in the execution of {bf:ssaggregate};  once run, users can merge shocks and any industry-level controls to the aggregated dataset.
They can then estimate and validate quasi-experimental shift-share IV regressions with 
other Stata procedures. See Section 4 of {browse "https://arxiv.org/abs/1806.01221":Borusyak, Hull, and Jaravel (2020)} for details and below for {it:{help ssaggregate##examples:examples}}  of such procedures.


{marker options}{...}
{title:Options}
{dlgtab:General}

{phang}
{opt t(varlist)}  specifies the unique period indicators given a panel or repeated cross section of locations. The same variables must index the same time periods in the separate "long" exposure share dataset, when used.{p_end}

{phang}
{opt c:ontrols(varlist)}  gives sets of control variable to be separately partialled out prior to aggregation.  Each set should be included as a separate string in quotes, even when only one set is included.
Variable wildcards, factor variables, and time-series operators are allowed in the strings, as if they were sets of regression controls.{p_end}

{phang}
{opt a:bsorb(varlist)}  gives sets of catagorical variables identifying fixed effects to be separately absorbed prior to aggregation.  Each set should be included as a separate string in quotes, even when only one set is included.{p_end}

{phang}
{opt addm:issing} creates observations corresponding to the "missing industry" for when the exposure shares do not sum to one.
The identifiers in {bf:n()} will be missing for these observations (when {bf:t()} is specified, an observation is created
for each time period). {p_end}

{dlgtab:With "long" exposure shares}

{phang}
{opt n(varlist)}  specifies the industry identifiers in the external dataset. {bf:n()} is a required option. {p_end}

{phang}
{opt s(varname)}  specifies the exposure weight variable in the external dataset. {bf:s()} is a required option. {p_end}

{phang}
{opt l(varlist)}  specifies the location identifiers in both the dataset in memory and the external dataset. {bf:l()} is a required option.{p_end}

{phang}
{opt sfile:name(filename)} specifies the external dataset. {bf:sfilename()} is a required option.{p_end}


{dlgtab:With "wide" exposure shares}

{phang}
{opt n(varname)}  specifies the industry identifier. {bf:n()} is a required option. {p_end}

{phang}
{opt s(stubname)}  specifies stubs of the names of exposure weight variables in memory. {bf:s()} is a required option. {p_end}

{phang}
{opt str:ing} indicates that the shock identifier as a string (default is numeric). {p_end}



{marker examples}{...}
{title:Examples}

{pstd}The following examples of {bf:ssaggregate} can be run from the Borusyak, Hull, and Jaravel (2020) {browse "https://github.com/borusyak/shift-share":data archive},
after loading into memory the main Autor, Dorn, and Hanson (2013) replication dataset (with {cmd:use location_level, clear}).{p_end}

{phang2}{it:Using separate "long" share dataset}

{phang2}{cmd:. ssaggregate y x z l_sh_routine33 [aw=wei], n(sic87dd) t(year) s(ind_share) sfile(Lshares) l(czone) controls("t2 Lsh_manuf")}

{phang2}{it:Using "wide" shares in memory}

{phang2}{cmd:. merge 1:1 czone year using Lshares_wide, assert(3) nogen}

{phang2}{cmd:. ssaggregate y x z l_sh_routine33 [aw=wei], n(sic87dd) t(year) s(ind_share) controls("t2 Lsh_manuf")}

{phang2}{it:Partialling out multiple control sets}

{phang2}{cmd:. ssaggregate y x z l_sh_routine33 [aw=wei], n(sic87dd) t(year) s(ind_share) sfile(Lshares) l(czone) controls("t2 Lsh_manuf" "t2 c.Lsh_manuf#t2")}

{phang2}{it:Including the "missing industry"}

{phang2}{cmd:. ssaggregate y x z l_sh_routine33 [aw=wei], n(sic87dd) t(year) s(ind_share) sfile(Lshares) l(czone) controls("t2 Lsh_manuf") addmissing}

{pstd}After aggregation, shocks and any shock-level controls can be merged on to the new dataset. For example, after the previous command a user could run

{phang2}{cmd:. replace sic87dd = 0 if missing(sic87dd)}

{phang2}{cmd:. merge 1:1 sic87dd year using shocks, assert(1 3) nogen}

{phang2}{cmd:. merge m:1 sic87dd using industries, assert(1 3) nogen}

{phang2}{cmd:. foreach v of varlist g year sic3 {c -(}}

              {cmd:replace `v'= 0 if sic87dd == 0}

          {cmd:{c )-}}

{pstd} Note that the first line and last loop are unnecessary without the {bf:addmissing} option. 

{pstd}The user can then use the shock-level dataset to estimate different shift-share analyses:

{phang2}{it:Basic shift-share IV}

{phang2}{cmd:. ivreg2 y (x=g) year [aw=s_n], r}

{phang2}{it:Conditional shift-share IV with clustered standard errors}

{phang2}{cmd:. ivreg2 y (x=g) year if g < 45 [aw=s_n], cluster(sic3)}

{phang2}{it:Shift-share reduced form regression ({it:y} on {it:z})}

{phang2}{cmd:. ivreg2 y (z=g) year [aw=s_n], r}

{phang2}{it:Shock-level balance check}

{phang2}{cmd:. reg l_sh_routine33 g year [aw=s_n], r}

{pstd} See {browse "https://arxiv.org/abs/1806.01221":Borusyak, Hull, and Jaravel (2020)} for other examples of shock-level 
analyses and guidance on specifying and validating a quasi-experimental shift-share IV.


{title:Authors}

Kirill Borusyak, UCL: {browse "mailto:k.borusyak@ucl.ac.uk": k.borusyak@ucl.ac.uk}
Peter Hull, University of Chicago: {browse "mailto:hull@uchicago.edu": hull@uchicago.edu}
Xavier Jaravel, London School of Economics: {browse "mailto:x.jaravel@lse.ac.uk": x.jaravel@lse.ac.uk}

{p}
