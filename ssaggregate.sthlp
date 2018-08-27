{smcl}
{* *! version 1.0 20 Aug 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "ssaggregate##syntax"}{...}
{viewerjumpto "Description" "ssaggregate##description"}{...}
{viewerjumpto "Options" "ssaggregate##options"}{...}
{viewerjumpto "Examples" "ssaggregate##examples"}{...}
{title:Title}

{phang}
{bf:ssaggregate} {hline 2} Create shock-level aggregates for shift-share IV


{marker syntax}{...}
{title:Syntax}

{phang}
Using "wide" exposure shares saved in memory: 

{p 8 17 2}
{cmdab:ssaggregate} 
{it:{help varlist}}
[{it:{help if}}]
[{it:{help in}}]
[{it:{help weight}}], {bf:n(}{it:{help varname}}{bf:)} {bf:s(}{it:stubname}{bf:)}
[{cmd:}{it:other options}]

{phang}
Using "long" exposure shares saved separately {it:(executes faster)}: 

{p 8 17 2}
{cmdab:ssaggregate} 
{it:{help varlist}}
[{it:{help if}}]
[{it:{help in}}]
[{it:{help weight}}], {bf:n(}{it:{help varlist}}{bf:)}  {bf:s(}{it:{help varname}}{bf:)} {bf:l(}{it:{help varlist}}{bf:)}
{bf:sfilename(}{it:{help filename}}{bf:)}
[{cmd:}{it:other options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:General}
{synopt:{opt t(varlist)}} period identifiers {p_end}
{synopt:{opt c:ontrols(strings)}}  sets of control variables to be partialled out {p_end}
{synopt:{opt addm:issing}}  create "missing industry" observations {p_end}

{syntab:With "wide" exposure shares}
{synopt:{opt n(varname)}} shock identifier (required){p_end}
{synopt:{opt s(stubname)}} stub of the names of exposure share variables (required){p_end}
{synopt:{opt str:ing}} indicates that the shock identifier is a string {p_end}

{syntab:With "long" exposure shares}
{synopt:{opt n(varlist)}} shock identifiers (required){p_end}
{synopt:{opt s(varname)}} name of exposure share variable (required){p_end}
{synopt:{opt l(varlist)}} cross-sectional observation identifiers (required){p_end}
{synopt:{opt sfile:name(filename)}} exposure share dataset (required){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:ssaggregate} converts variables of a shift-share IV dataset in memory into a dataset of weighted shock-level aggregates, as described in {browse "https://arxiv.org/abs/1806.01221":Borusyak, Hull, and Jaravel (2018)}.

{pstd} There are two ways to specify {cmd:ssaggregate}, depending on whether the shock exposure weights are saved in "wide" format (in the dataset in memory), or in "long" format (in a separate dataset).  
In the "wide" case the {bf:s()} option must contain the common stub of the names of exposure weight variables, and the target name of the variable identifying shocks is given in {bf:n()}. 
For example, {bf:s(share)} should be included when the exposure variables are named {it:share101}, {it:share102}, etc., with 101 and 102 being values of the shock identifier designated by {bf:n()}. In the "long" case {bf:s()}
should contain the name of the exposure weight variable itself, {bf:n()} can contain a set of shock identifying variables, and the 
{bf:l()} and {bf:sfilename()} options must be included. The {bf:l()} option uniquely identifies observations in the dataset in memory (along with {bf:t()}, when included), and 
{bf:sfilename()}  identifies the external dataset of exposure weights. This dataset should be uniquely indexed by the variables in {bf:l()} and {bf:n()} (and {bf:t()}, when included). See the {it:{help ssaggregate##examples:examples}} 
for proper syntax in both cases. 

{pstd} The transformed dataset contains exposure-weighted averages of the specified variables, along with the average exposure weight {it:s_n}. If the {bf:controls()}
option is included the variables are first residualized by each of the specified sets of controls. Each set should be included in the option as a separate string (in quotes);
for example as {bf:controls("var1" "var1 var2" "var1 var3 var4")}, where {it:var1}-{it:var4} are names of control variables in memory. The transformed variables are then indexed by the control set number: for example 
{it:y1}-{it:y4} when {it:y} is the variable in memory to be transformed. An exception is when {bf:controls()} is included with only a single set of controls (still in quotes),
or when {bf:controls()} is omitted. Then the transformation of variable {it:y} is also named {it:y}.

{pstd} Once {cmd:ssaggregate} is used, users can merge in any shift-share shocks and shock-level controls via the unique identifiers in {bf:n()} (and {bf:t()}, when included). 
They can then estimate and validate quasi-experimental shift-share IV regressions with 
standard Stata procedures. See Section 4 of {browse "https://arxiv.org/abs/1806.01221":Borusyak, Hull, and Jaravel (2018)} for details and below for examples of such procedures.


{marker options}{...}
{title:Options}
{dlgtab:General}

{phang}
{opt t(varlist)}  specifies the variables whose values uniquely identify time periods when panel data is used. The same variables must index time periods in the separate "long" exposure share dataset, when used.{p_end}

{phang}
{opt c:ontrols(varlist)}  gives sets of control variable to be separately partialled out prior to aggregation.  Each set should be included as a separate string in quotes, even when only one set is included.
Variable wildcards, factor variables, and time-series operators are allowed in the strings as if they were {it:varlist}s.{p_end}

{phang}
{opt addm:issing} creates observations corresponding to the "missing industry" when the exposure shares do not sum to one.
The identifiers in {bf:n()} will be missing for these observations (when {bf:t()} is specified, an observation is created
for each time period). {browse "https://arxiv.org/abs/1806.01221":Borusyak, Hull, and Jaravel (2018)} recommend controlling for the sum of exposure shares
when it varies; in this case the "missing industry" can be excluded from shock-level analyses. To remind users 
of this issue, {bf:ssaggregate} will issue a warning when the sum of exposure shares varies and is not controlled for. {p_end}

{dlgtab:With "wide" exposure shares}

{phang}
{opt n(varname)}  specifies the single variable whose values uniquely identify shocks in the cross-section. {bf:n()} is a required option. {p_end}

{phang}
{opt s(stubname)}  gives stubs of the name of exposure share variables in memory. {bf:s()} is a required option. {p_end}

{phang}
{opt str:ing} creates the shock identifier as a string when the external share dataset is reshaped (default is numeric). {p_end}

{dlgtab:With "long" exposure shares}

{phang}
{opt n(varlist)}  specifies the variables whose values uniquely identify shocks in the cross-section. {bf:n()} is a required option. {p_end}

{phang}
{opt s(varname)}  gives the name of the exposure share variable in the external dataset. {bf:s()} is a required option. {p_end}

{phang}
{opt l(varlist)}  specifies the variables whose values uniquely identify observations in the cross-section. The same variables must index observations 
in the separate share dataset (along with the variables in {bf:n()}, and in {bf:t()} when included). {bf:l()} is a required option.{p_end}

{phang}
{opt sfile:name(filename)} specifies the separate dataset of exposure shares. {bf:sfilename()} is a required option.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}The following examples of {bf:ssaggregate} can be run from the Borusyak, Hull, and Jaravel (2018) {browse "https://github.com/borusyak/shift-share":data archive},
after loading into memory the main Autor, Dorn, and Hanson (2013) replication dataset (with {cmd:use location_level, clear}).{p_end}

{phang2}{it:Using separate "long" share dataset}

{phang2}{cmd:. ssaggregate y x z l_sh_routine33 [aw=wei], n(sic87dd) t(year) s(ind_share) sfile(Lshares) l(czone) controls("t2 Lsh_manuf")}

{phang2}{it:Using "wide" shares in memory}

{phang2}{cmd:. merge 1:1 czone year using Lshares_wide, assert(3) nogen}

{phang2}{cmd:. ssaggregate y x z l_sh_routine33 [aw=wei], n(sic87dd) t(year) s(ind_share) controls("t2 Lsh_manuf")}

{phang2}{it:Partialling out multiple control sets}

{phang2}{cmd:. ssaggregate y x z l_sh_routine33 [aw=wei], n(sic87dd) t(year) s(ind_share) sfile(Lshares) l(czone) controls("t2 Lsh_manuf" "t2 c.Lsh_manuf#t2")}

{phang2}{it:Including the "missing industry"}

{phang2}{cmd:. ssaggregate y x z l_sh_routine33 [aw=wei], n(sic87dd) t(year) s(ind_share) sfile(Lshares) l(czone) controls("t2") addmissing}

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

{pstd} See {browse "https://arxiv.org/abs/1806.01221":Borusyak, Hull, and Jaravel (2018)} for other examples of shock-level 
analyses and guidance on specifying and validating a quasi-experimental shift-share IV.


{title:Authors}

Kirill Borusyak, Princeton University: {browse "mailto:borusyak@princeton.edu": borusyak@princeton.edu}
Peter Hull, University of Chicago: {browse "mailto:hull@uchicago.edu": hull@uchicago.edu}
Xavier Jaravel, London School of Economics: {browse "mailto:x.jaravel@lse.ac.uk": x.jaravel@lse.ac.uk}

{p}
