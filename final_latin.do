use "/Users/amuna/Downloads/2023_renamed.dta", clear
append using "/Users/amuna/Downloads/2018_renamed.dta"

keep if idenpa == 152
gen year23 = (numinves == 23)



*dropping don't know and doesn't answer

recode lifesatisfaction governedbyfew (-5 -1 = .)
recode countryprogress countryeconomicsituation country12monthseconsituation countrynext12monthseconsituation familynext12monthseconsituation economysatisfaction incomedistfairness socioeconclass religion race education (-2 -1 = .)
recode leftrightscale (-8 -2 -1 97 = .)

*age group
gen agecat = 1 if age >=19 & age <= 24
replace agecat = 2 if age >=25 & age <=34
replace agecat = 3 if age >=35 & age <=44	
replace agecat = 4 if age >=45 & age <=54	
replace agecat = 5 if age >=55 & age <=64
replace agecat = 6 if age >=65

label variable agecat "Age Group"
label define age_cat 1 "19-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65 and above"
label values agecat age_cat

*left/right
gen leftscale = 1 if leftrightscale <= 3
replace leftscale = 2 if leftrightscale >= 4 & leftrightscale <= 6
replace leftscale = 3 if leftrightscale >= 7
label variable leftscale "Political Left-Right Self-Alignment"
label define left_scale 1 "Left Leaning" 2 "Middle" 3 "Right Leaning"
label values leftscale left_scale

gen metroregion = inlist(reg, 152000, 152008, 152005, 152007, 152009, 152010, 152006, 152004, 152002)
label define metro_lbl 0 "Relatively Less Urban" 1 "Relatively More Urban"
label values metroregion metro_lbl


global controls i.religion i.race i.leftscale i.sex

*creating a z-score
egen z_lifesatisfaction = std(lifesatisfaction)
gen governed_byfewrecodedbinary = (governedbyfew== 1)
egen z_governedbyfew = std(governed_byfewrecodedbinary)
egen z_countryprogress = std(countryprogress)
egen z_countryeconomicsit = std(countryeconomicsituation)
egen z_country12monthseconsit = std(country12monthseconsituation)
egen z_countrynext12monthseconsit = std(countrynext12monthseconsituation)
egen z_familynext12monthseconsit = std(familynext12monthseconsituation)
egen z_economysatisfaction = std(economysatisfaction)
egen z_incomedistfairness = std(incomedistfairness)
egen economicoutlook = rowmean(countryprogress countryeconomicsit ///
    country12monthseconsit countrynext12monthseconsit ///
    familynext12monthseconsit economysatisfaction incomedistfairness)
gen xeconomicoutlook = -1*economicoutlook

replace socioeconclass = 1 if inlist(socioeconclass, 1, 2)

*economic outlook regression 

*basic
regress xeconomicoutlook i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
regress xeconomicoutlook i.year23 i.metroregion i.year23##i.metroregion, robust
regress xeconomicoutlook i.year23 i.agecat i.year23##i.agecat, robust
regress xeconomicoutlook i.year23 i.leftscale i.year23##i.leftscale, robust


*with controls
regress xeconomicoutlook i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.socioeconclass $controls, robust
regress xeconomicoutlook i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.metroregion $controls, robust
regress xeconomicoutlook i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.agecat $controls, robust
*democracy

recode democracybest (-5 -1 = .)
recode democracysatisfaction democracypreference (-2 -1 = .)
egen z_democracysatisfaction = std(democracysatisfaction)
egen z_democracybest = std(democracybest)
*need to recode 1 = yes democracy = 0 no democracy
gen support_democracy = (democracypreference == 1)
egen z_support_democracy = std(support_democracy)

egen democracy = rowmean(z_support_democracy z_democracysatisfaction z_democracybest)
gen xdemocracy = -1*democracy

*democracy regression
*basic
regress xdemocracy i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
regress xdemocracy i.year23 i.metroregion i.year23##i.metroregion, robust
regress xdemocracy i.year23 i.agecat i.year23##i.agecat, robust
regress xdemocracy i.year23 i.leftscale i.year23##i.leftscale, robust

*with controls
regress xdemocracy i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.socioeconclass $controls, robust
regress xdemocracy i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.metroregion $controls, robust
regress xdemocracy i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.agecat $controls, robust

*trust in government inst

recode trustinarmedforces trustinpolice trustincongress trustinnationalgovernment ///
       trustinjudiciary trustinpoliticalparties trustinelectoralinst ///
       trustinnatcompanies trustinbanks trustintradeunions ///
       trustinmultilateral trustinchurch trustinpeople (-2 -1 = .)

recode presleadershipapproval (-5 -1 = .)


*creating a z-score 
egen z_trustinarmedforces = std(trustinarmedforces)
egen z_trustinpolice = std(trustinpolice)
egen z_trustincongress = std(trustincongress)
egen z_trustinnationalgovernment = std(trustinnationalgovernment)
egen z_trustinjudiciary = std(trustinjudiciary)
egen z_trustinpoliticalparties = std(trustinpoliticalparties)
egen z_trustinelectoralinst = std(trustinelectoralinst)
egen z_presleadershipapproval = std(presleadershipapproval)
egen trustingovtinst = rowmean(z_trustinarmedforces z_trustinpolice z_trustincongress ///
                                  z_trustinnationalgovernment z_trustinjudiciary ///
                                  z_trustinpoliticalparties z_trustinelectoralinst ///
                                  z_presleadershipapproval)

gen xtrustingovinst = -1*trustingovtinst
								  
egen z_trustinnatcompanies = std(trustinnatcompanies)
egen z_trustinbanks = std(trustinbanks)
egen z_trustintradeunions = std(trustintradeunions)
egen z_trustinmultilateral = std(trustinmultilateral)
egen z_trustinchurch = std(trustinchurch)
egen z_trustinpeople = std(trustinpeople)
egen trustinnongovtinst = rowmean(z_trustinnatcompanies z_trustinbanks ///
                                     z_trustintradeunions z_trustinmultilateral ///
                                     z_trustinchurch z_trustinpeople)
									 
gen xtrustinnongovtinst = -1*trustinnongovtinst



*basic
regress xtrustingovinst i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
regress xtrustingovinst i.year23 i.metroregion i.year23##i.metroregion, robust
regress xtrustingovinst i.year23 i.agecat i.year23##i.agecat, robust
regress xtrustingovinst i.year23 i.leftscale i.year23##i.leftscale, robust

regress xtrustinnongovtinst i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
regress xtrustinnongovtinst i.year23 i.metroregion i.year23##i.metroregion, robust
regress xtrustinnongovtinst i.year23 i.agecat i.year23##i.agecat, robust
regress xtrustinnongovtinst i.year23 i.leftscale i.year23##i.leftscale, robust
*with controls
regress xtrustingovinst i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.socioeconclass $controls, robust
regress xtrustingovinst i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.metroregion $controls, robust
regress xtrustingovinst i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.agecat $controls, robust

regress xtrustinnongovtinst i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.socioeconclass $controls, robust
regress xtrustinnongovtinst i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.metroregion $controls, robust
regress xtrustinnongovtinst i.year23 i.socioeconclass i.metroregion i.agecat i.year23##i.agecat $controls, robust

label define soclbl 1 "Upper" ///
                  3 "Middle" ///
                  4 "Lower-Mid" ///
                  5 "Lower"
label values socioeconclass soclbl



global tbl  "/Users/amuna/Downloads/Econ Final Paper"  // change path

*-----------------------------------------------------*
*  SOCIO-ECONOMIC CLASS                               *
*-----------------------------------------------------*
eststo clear
eststo m1: regress xeconomicoutlook  i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
eststo m2: regress xdemocracy       i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
eststo m3: regress xtrustingovinst  i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
eststo m4: regress xtrustinnongovtinst i.year23 i.socioeconclass i.year23##i.socioeconclass, robust


	 	  
esttab m1 m2 m3 m4 using "${tbl}\Class_Table.doc", replace ///
    b(2) se(2) star(* 0.10 ** 0.05 *** 0.01) ///
    nobaselevels ///
    drop(_cons) ///
    coeflabels( ///
        3.socioeconclass "Middle class" ///
        4.socioeconclass "Lower-Mid class" ///
        5.socioeconclass "Low class" ///
        1.year23#3.socioeconclass "2023 x Middle class" ///
        1.year23#4.socioeconclass "2023 x Lower-Mid class" ///
        1.year23#5.socioeconclass "2023 x Low class" ///
    ) ///
    stats(N r2, fmt(%9.0fc %6.3f) labels("Obs." "R-sq"))


*-----------------------------------------------------*
*  URBAN / RURAL                                      *
*-----------------------------------------------------*
eststo clear
eststo m1: regress xeconomicoutlook  i.year23 i.metroregion i.year23##i.metroregion, robust
eststo m2: regress xdemocracy       i.year23 i.metroregion i.year23##i.metroregion, robust
eststo m3: regress xtrustingovinst  i.year23 i.metroregion i.year23##i.metroregion, robust
eststo m4: regress xtrustinnongovtinst i.year23 i.metroregion i.year23##i.metroregion, robust

esttab m1 m2 m3 m4 using "${tbl}\UrbanRural_Table.doc", replace   ///
      b(2) se(2) star(* 0.10 ** 0.05 *** 0.01) nobaselevels drop(_cons) ///
      stats(N r2, fmt(%9.0fc %6.3f) labels("Obs." "R-sq"))

*-----------------------------------------------------*
*  AGE CATEGORY                                       *
*-----------------------------------------------------*
eststo clear
eststo m1: regress xeconomicoutlook  i.year23 i.agecat i.year23##i.agecat, robust
eststo m2: regress xdemocracy       i.year23 i.agecat i.year23##i.agecat, robust
eststo m3: regress xtrustingovinst  i.year23 i.agecat i.year23##i.agecat, robust
eststo m4: regress xtrustinnongovtinst i.year23 i.agecat i.year23##i.agecat, robust

esttab m1 m2 m3 m4 using "${tbl}\Age_Table.doc", replace          ///
      b(2) se(2) star(* 0.10 ** 0.05 *** 0.01) nobaselevels drop(_cons) ///
	  coeflabels( ///
        2.agecat "25-34" ///
        3.agecat "35-44" ///
        4.agecat "45-54" ///
        5.agecat "55-64" ///
        6.agecat "65+" ///
        1.year23#2.agecat "2023 x 25-34" ///
        1.year23#3.agecat "2023 x 35-44" ///
        1.year23#4.agecat "2023 x 45-54" ///
        1.year23#5.agecat "2023 x 55-64" ///
        1.year23#6.agecat "2023 x 65+" ///
      ) ///
      stats(N r2, fmt(%9.0fc %6.3f) labels("Obs." "R-sq"))


*-----------------------------------------------------*
*  LEFT / RIGHT  (your last block)                    *
*-----------------------------------------------------*
eststo clear
eststo m1: regress xeconomicoutlook  i.year23 i.leftscale i.year23##i.leftscale, robust
eststo m2: regress xdemocracy       i.year23 i.leftscale i.year23##i.leftscale, robust
eststo m3: regress xtrustingovinst  i.year23 i.leftscale i.year23##i.leftscale, robust
eststo m4: regress xtrustinnongovtinst i.year23 i.leftscale i.year23##i.leftscale, robust

esttab m1 m2 m3 m4 using "${tbl}\Ideology_Table.doc", replace     ///
      b(2) se(2) star(* 0.10 ** 0.05 *** 0.01) nobaselevels drop(_cons) ///
	  coeflabels( ///
	  2.leftscale "Middle" ///
	  3.leftscale "Right Leaning" ///
	  1.year23#2.leftscale "2023 x Middle" ///
	  1.year23#3.leftscale "2023 x Middle" ///
	  ) ///
      stats(N r2, fmt(%9.0fc %6.3f) labels("Obs." "R-sq"))

*countryproblems -- use it for sth at some point 



recode countryproblems (-2 -1 97 = .)

recode talkoftenpolitics (-2 -1 = .)
recode interestinpolitics (-2 -1 = .)
recode workforcommunity (-2 -1 = .)
recode authdemonst (-5 = .)
recode nonauthdemonst (-5 = .)
recode protestinsocmedia (-5 = .)
recode protestagree (-5 = .)
  
foreach var in talkoftenpolitics interestinpolitics workforcommunity ///
              authdemonst nonauthdemonst protestinsocmedia ///
				protestagree {
    egen z_`var' = std(`var')
}

egen xprotest_index = rowmean(z_talkoftenpolitics z_interestinpolitics z_workforcommunity ///
                              z_authdemonst z_nonauthdemonst z_protestinsocmedia ///
                              z_protestagree)
							  
gen protest_index = -1*xprotest_index				
	



graph box protest_index, over(leftscale) ///
    title("Protest Index by Political Ideology") ///
    ytitle("Protest Index") ///
    box(1, color(orange)) scheme(s1color)	



	  
/*





graph box protest_index, over(leftscale) ///
    title("Protest Index by Socioeconomic Class") ///
    ytitle("Protest Index") ///
    box(1, color(orange)) scheme(s1color)		




* By age
graph box protest_index, over(agecat) title("Protest Index by Age Group") ///
		ytitle("Protest Index")
		

graph box protest_index, over(socioeconclass) ///
    title("Protest Index by Socioeconomic Class") ///
    ytitle("Protest Index") ///
    box(1, color(pink)) scheme(s1color)		
		
			
		

preserve

keep if agecat == 1

contract year23 countryproblems

bysort year23 (countryproblems): gen total = sum(_freq)
bysort year23 (countryproblems): replace total = total[_N]
gen pct = 100 * _freq / total

by year23: gen rank = _n
keep if rank <= 5


graph hbar pct if year23 == 0, over(countryproblems, sort(1) descending) ///
    title("Top 5 National Problems – 2018") ///
	subtitle("19-24 year-olds") ///
	ytitle("Percentage of Respondents") ///
    blabel(bar, format(%4.1f)) ///
    bar(1, color(blue))
	  
restore	

graph hbar pct if year23 == 1, over(countryproblems, sort(1) descending) ///
    title("Top 5 National Problems – 2023") ///
	subtitle("19-24 year-olds") ///
	ytitle("Percentage of Respondents") ///
    blabel(bar, format(%4.1f)) ///
    bar(1, color(maroon))
	
graph hbar pct if year23 == 0, over(countryproblems, sort(1) descending) ///
    title("Top 5 National Problems – 2018") ///
	ytitle("Percentage of Respondents") ///
    blabel(bar, format(%4.1f)) ///
    bar(1, color(navy))

contract year23 countryproblems

bysort year23 (countryproblems): gen total = sum(_freq)
bysort year23 (countryproblems): replace total = total[_N]
gen pct = 100 * _freq / total

by year23: gen rank = _n
keep if rank <= 10



graph hbar pct if year23 == 0, over(countryproblems, sort(1) descending) ///
    title("Top 10 National Problems – 2018") ///
    blabel(bar, format(%4.1f)) ///
    bar(1, color(navy))

graph hbar pct if year23 == 1, over(countryproblems, sort(1) descending) ///
    title("Top 10 National Problems – 2023") ///
    blabel(bar, format(%4.1f)) ///
    bar(1, color(maroon))




* after running your regressions - socio econ class
eststo clear
eststo m1: regress xeconomicoutlook i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
eststo m2: regress xdemocracy i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
eststo m3: regress xtrustingovinst i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
eststo m4: regress xtrustinnongovtinst i.year23 i.socioeconclass i.year23##i.socioeconclass, robust

* export to Word or LaTeX
esttab m1 m2 m3 using Results.doc, ///
      replace                                    ///
      b(2) se(2) star(* 0.10 ** 0.05 *** 0.01)   ///
      nobaselevels                               /// ← removes the 0-rows
      drop(_cons)                                ///
      stats(N r2, fmt(%9.0fc %6.3f) labels("Obs." "R-sq"))

	  
	  
	  	
* after running your regressions - urban/rural
eststo clear
eststo m1: regress xeconomicoutlook i.year23 i.metroregion i.year23##i.metroregion, robust
eststo m2: regress xdemocracy i.year23 i.metroregion i.year23##i.metroregion, robust
eststo m3: regress xtrustingovinst i.year23 i.metroregion i.year23##i.metroregion, robust
eststo m4: regress xtrustinnongovtinst i.year23 i.metroregion i.year23##i.metroregion, robust

* export to Word or LaTeX
esttab m1 m2 m3 using Results.doc, ///
      replace                                    ///
      b(2) se(2) star(* 0.10 ** 0.05 *** 0.01)   ///
      nobaselevels                               /// ← removes the 0-rows
      drop(_cons)                                ///
      stats(N r2, fmt(%9.0fc %6.3f) labels("Obs." "R-sq"))

	  
	  
* after running your regressions - age category
eststo clear
eststo m1: regress xeconomicoutlook i.year23 i.agecat i.year23##i.agecat , robust
eststo m2: regress xdemocracy i.year23 i.agecat  i.year23##i.agecat, robust
eststo m3: regress xtrustingovinst i.year23 i.agecat  i.year23##i.agecat, robust
eststo m4: regress xtrustinnongovtinst i.year23 i.agecat  i.year23##i.agecat, robust

* export to Word or LaTeX
esttab m1 m2 m3 using Results.doc, ///
      replace                                    ///
      b(2) se(2) star(* 0.10 ** 0.05 *** 0.01)   ///
      nobaselevels                               /// ← removes the 0-rows
      drop(_cons)                                ///
      stats(N r2, fmt(%9.0fc %6.3f) labels("Obs." "R-sq"))

	  
	  
* after running your regressions - left/right
eststo clear
eststo m1: regress xeconomicoutlook i.year23 i.agecat i.year23##i.socioeconclass, robust
eststo m2: regress xdemocracy i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
eststo m3: regress xtrustingovinst i.year23 i.socioeconclass i.year23##i.socioeconclass, robust
eststo m4: regress xtrustinnongovtinst i.year23 i.socioeconclass i.year23##i.socioeconclass, robust

* export to Word or LaTeX
esttab m1 m2 m3 using Results.doc, ///
      replace                                    ///
      b(2) se(2) star(* 0.10 ** 0.05 *** 0.01)   ///
      nobaselevels                               /// ← removes the 0-rows
      drop(_cons)                                ///
      stats(N r2, fmt(%9.0fc %6.3f) labels("Obs." "R-sq"))
	  
	  
	  
	  
	  

/*






margins agecat, over(year23)
marginsplot


/*
*Trust Variable
*use P13* using "/Users/amuna/Downloads/F00017011-Latinobarometro_2023_Stata_v1_0 (1)/Latinobarometro_2023_Eng_Stata_v1_0.dta", clear

rename *, lower
recode p13stgbs_b p13stgbs_c p13st_e p13st_f  (-2 -1 = .) (1=4) (2=3) (3=2) (4=1)

lab val p13st_e
lab val p13stgbs_b

egen trustpolz = std(p13stgbs_b)
egen trustgovz = std(p13st_e)
egen trust = rowmean(trustpolz trustgovz)
*removing not at all, na but not dropping
egen trustgovz = std(p13st_e) , by(year)
