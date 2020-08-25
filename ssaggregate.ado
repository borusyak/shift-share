*! version 1.2.2, jan2020
*! Kirill Borusyak (k.borusyak@ucl.ac.uk), Peter Hull (hull@uchicago.edu), Xavier Jaravel (x.jaravel@lse.ac.uk)
program def ssaggregate
	version 11.0
	syntax varlist [if] [in] [aw iw fw pw/], n(string) s(string) [t(varlist) Controls(string asis) Absorb(string asis) ADDMissing ///
		STRring /// wide syntax only
		l(varlist) SFILEname(string)] // long syntax only
	
	qui {
		local wideformat = (`"`sfilename'"'=="")

		* Check syntax
		if (`wideformat' & ("`l'"!="")) { 
			di as error "Option l may not be used with shares in wide format"
			exit 198
		}
		if ((!`wideformat') & ("`string'"!="")) {
			di as error "Option string may not be used with shares in long format"
			exit 198
		}
		if (strtrim(`"`controls'"')!="" & !regexm(`"`controls'"',`"""')) {
			di as error "Each set of controls must be specified in quotes"
			exit 198
		}
		if (strtrim(`"`absorb'"')!="" & !regexm(`"`absorb'"',`"""')) {
			di as error "Each set of fixed effects must be specified in quotes"
			exit 198
		}

		if ("`weight'"=="") local ww = ""
			else local ww = `"[`weight' = `exp']"'

		* Prepare main file
		marksample touse
		keep if `touse'
		
		if (`wideformat') {
			tempvar l
			gen `l' = _n
		}
		tempfile main
		save `"`main'"'

		* Reshape to get long shares file
		if (`wideformat') {
			keep `l' `t' `s'*
			reshape long `s', i(`l' `t') j(`n') `string'
			tempfile sfilename
			save `"`sfilename'"'
		}
		
		* Deal with missing industry shares
		use `"`sfilename'"', clear
		collapse (sum) `s', by(`l' `t')
		replace `s' = 1-`s'

			* If sum of shares varies, will verify S_l is controlled for
			sum `s'
			if (r(sd)>10^-5) {
				tempvar s0
				rename `s' `s0'
				local checkcontrols = 1
				tempfile missingind
				save `"`missingind'"'
				rename `s0' `s'
			}
			else local checkcontrols = 0
			
			* Add missing industry
			if ("`addmissing'"!="") {
				replace `s'=0 if inrange(`s',-10^-5,0) // if the sum of shares is one, it can look like 1.00001 => creates negative weights
				append using `"`sfilename'"'
				tempfile newshares
				save `"`newshares'"', replace
				local sfilename = `"`newshares'"'
			}
		
		use `"`main'"', clear	
		if (`checkcontrols') merge 1:1 `l' `t' using `"`missingind'"', assert(2 3) keep(3) nogen
		
		* Residualize outcomes on each set of controls
		tempvar resid
		
		if (`"`controls'"'!="") {
			tokenize `"`controls'"'
			if (`"`51'"'!="") {
				noi di as error "More than 50 control sets are not allowed"
				exit 198
			}
			local ccount = 50
			while (`"``ccount''"'=="" & `ccount'>0) {
				local ccount = `ccount' - 1
			}
			if (`ccount'>0) {
				forvalues index = 1/`ccount' {
					local cset`index' = `"``index''"'
				}
			}
		}
		else local ccount = 0

		if (`"`absorb'"'!="") {
			tokenize `"`absorb'"'
			if (`"`51'"'!="") {
				noi di as error "More than 50 fixed effect sets are not allowed"
				exit 198
			}
			local acount = 50
			while (`"``acount''"'=="" & `acount'>0) {
				local acount = `acount' - 1
			}
			if (`acount'>0) {
				forvalues index = 1/`acount' {
					local aset`index' = `"``index''"'
				}
			}
		}
		else local acount = 0 // # of absorb sets

		local cacount = max(`acount',`ccount',1) // if no controls or FE, still have one iteration with simple demeaning
		
		local vars = ""
		forvalues index = 1/`cacount' {
			if (`checkcontrols') { // Make sure S_l is perfectly predicted by each set of controls, then no problem
				if (`"`aset`index''"'=="") reg `s0' `cset`index''
					else reghdfe `s0' `cset`index'', absorb(`aset`index'')		
				if (e(r2)<0.9999) {
					if ("`addmissing'"=="") {
						noi di as error "WARNING: You are in the incomplete share case (the sum of exposure shares varies)"
						noi di as error "and you have not controlled for the sum of shares (in control set `index')."
						noi di as error "You should either include the missing industry or (better in most cases) add the sum-of-share"
						noi di as error "control. Otherwise the shock-level IV coefficient does not equal the shift-share IV."
					}
					else {
						noi di "Warning: You are in the incomplete share case (the sum of exposure shares varies)"
						noi di "and you have not controlled for the sum of shares (in control set `index')."
						noi di "Keep in mind that this imposes the assumption that shocks are mean-zero."
					}
					drop `s0'
					local checkcontrols = 0
				}
			}
			
			foreach v of varlist `varlist' {
				if (`"`aset`index''"'=="") {
					reg `v' `cset`index'' `ww'
					predict `resid', resid
				}
				else reghdfe `v' `cset`index'' `ww', absorb(`aset`index'') resid(`resid') keepsing
				
				if (`cacount'>1) {
					gen `v'`index' = `resid'
					local vars `vars' `v'`index'
				}
				else { // if <=1 set of controls & FE, don't append 1 to variable names
					replace `v' = `resid'
					local vars `vars' `v'
				}
				drop `resid'
				
			}
		}
		
		* Merge with the shares
		if (`wideformat') drop `s'*
		merge 1:m `l' `t' using `"`sfilename'"', assert(2 3) keep(3) nogen
		
		* Collapse to industry level
		if ("`weight'"!="") replace `s' = `s' * (`exp')
		collapse (rawsum) s_n=`s' (mean) `vars' [aw=`s'], by(`n' `t') fast
		sum s_n
		replace s_n = s_n/r(sum)
	}
end
