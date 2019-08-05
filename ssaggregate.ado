*! version 1.1, 22aug2018
*! Kirill Borusyak (borusyak@princeton.edu), Peter Hull (hull@uchicago.edu), Xavier Jaravel (x.jaravel@lse.ac.uk)
program def ssaggregate
	version 11.0
	syntax varlist [if] [in] [aw iw fw pw/], n(string) s(string) [t(varlist) Controls(string asis) ADDMissing ///
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
		replace `s' = 1-float(`s')

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
				append using `"`sfilename'"'
				tempfile newshares
				save `"`newshares'"', replace
				local sfilename = `"`newshares'"'
			}
		
		use `"`main'"', clear	
		if (`checkcontrols') merge 1:1 `l' `t' using `"`missingind'"', assert(2 3) keep(3) nogen
		
		* Residualize outcomes on each set of controls
		tempvar resid
		tokenize `"`controls'"'
		local vars = ""
		local cset = 0
		while (`"`*'"'!="" | `cset'==0) {
			local cset = `cset'+1
			if (`checkcontrols') { // Make sure S_l is perfectly predicted by each set of controls, then no problem
				reg `s0' `1'
				if (e(r2)<0.9999) {
					if ("`addmissing'"=="") {
						noi di as error "WARNING: You are in the incomplete share case (the sum of exposure shares varies)"
						noi di as error "and you have not controlled for the sum of shares (in control set `cset')."
						noi di as error "You should either include the missing industry or (better in most cases) add the sum-of-share"
						noi di as error "control. Otherwise the shock-level IV coefficient does not equal the shift-share IV."
					}
					else {
						noi di "Warning: You are in the incomplete share case (the sum of exposure shares varies)"
						noi di "and you have not controlled for the sum of shares (in control set `cset')."
						noi di "Keep in mind that this imposes the assumption that shocks are mean-zero."
					}
					drop `s0'
					local checkcontrols = 0
				}
			}
			
			foreach v of varlist `varlist' {
				reg `v' `1' `ww'
				predict `resid', resid
				gen `v'`cset' = `resid'
				local vars `vars' `v'`cset'
				drop `resid'
			}
			macro shift
		}
		if (`cset'<=1) { // at most one set of controls
			foreach v of varlist `varlist' {
				drop `v'
				rename `v'1 `v'
			}
			local vars `varlist'
		}
		
		* Merge with the shares
		if (`wideformat') drop `s'*
		merge 1:m `l' `t' using `"`sfilename'"', assert(2 3) keep(3) nogen
		
		* Collapse to industry level
		if ("`weight'"!="") replace `s' = `s' * (`exp')
		collapse (rawsum) s_n=`s' (mean) `vars' [aw=`s'], by(`n' `t') fast
	}
end
