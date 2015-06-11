program define anonymize
	syntax varlist(default=none min=1 max=5)

di "You have entered the following variables: " "`varlist'" _newline

drop if samp_juris == 0

* Declare breaks to use later for bucket-shifting
local break1 = 400
local break2 = 1000

* Get number of arguments to determine helper function
local numargs = wordcount("`varlist'")

* Get max_shifts and min count of how many in a cell
di "Please enter the maximum shift for the lower cutoff: " _request(_BOT_MAX_SHIFT)
di "Please enter the maximum shift for the higher cutoff: " _request(_TOP_MAX_SHIFT)

di "Please enter the number of responses at which crosstabs should be cut"
di "(ie, entering 1 removes responses where there are only one response"
di "in a crosstab): " _request(_min_cell)

* Check composition of crosstabs in general
egen s_count = count(1), by(pop_density "`varlist'" soss_reg)

count if s_count <= `min_cell' & s_count != 0
local mcount = r(N)

global drop_count_num = `mcount'
global drop_count = "s_count"

* Ends program if there are no singles
if (`mcount' == 0) {
	di "No single items, exiting..."
	exit
}

* Summarize to get values without output
quietly: summarize popdens if s_count <= `min_cell' & s_count != 0 & pop_density == 1
local low_min_mac = round(r(min) - 10)
local low_mean_mac = round(r(mean) - 10)
local low_max_mac = round(r(max) - 10)

quietly: summarize popdens if s_count <= `min_cell' & s_count != 0 & pop_density == 2
local mid_max_mac = round(r(max) + 10)
local mid_min_mac = round(r(min) - 10)

quietly: summarize popdens if s_count <= `min_cell' & s_count != 0 & pop_density == 3
local hi_min_mac = round(r(min) + 10)
local hi_max_mac = round(r(max) + 10)
local hi_mean_mac = round(r(mean) + 10)

local max_shift_bot1 = `break1' - `BOT_MAX_SHIFT'
local max_shift_bot2 = `break1' + `BOT_MAX_SHIFT'

local max_shift_top1 = `break2' - `TOP_MAX_SHIFT'
local max_shift_top2 = `break2' + `TOP_MAX_SHIFT'

* Prints output
di _newline "Breakpoints:"
di "Low-density min is " `low_min_mac'
dis "Low-density mean is " `low_mean_mac'
dis "Low-density max is " `low_max_mac' _newline

di "Mid-density min is " `mid_min_mac'
di "Mid-density max is " `mid_max_mac' _newline

di "High-density min is " `hi_min_mac'
di "High-density max is " `hi_max_mac'
di "High-density mean is " `hi_mean_mac' _newline

global print_bot_break = 400
global print_top_break = 1000

global round = 1

global bot_list_macs
global top_list_macs `break2'
global bot_list2_macs `break1'
global top_list2_macs

/*

Check to make sure none of the macros are empty, if they are empty, do nothing
If they have a value, add it to the global macro list to be run through

*/

if !mi(`low_min_mac') {
	global bot_list_macs `"$bot_list_macs `low_min_mac'"'
}
if !mi(`low_mean_mac') {
	global bot_list_macs `"$bot_list_macs `low_mean_mac'"'
}
if !mi(`low_max_mac') {
	global bot_list_macs `"$bot_list_macs `low_max_mac'"'
}
if !mi(`mid_min_mac') {
	global bot_list_macs `"$bot_list_macs `mid_min_mac'"'
}

if !mi(`mid_max_mac') {
	global top_list_macs `"$top_list_macs `mid_max_mac'"'
}
if !mi(`hi_min_mac') {
	global top_list_macs `"$top_list_macs `hi_min_mac'"'
}
if !mi(`hi_max_mac') {
	global top_list_macs `"$top_list_macs `hi_max_mac'"'
}
if !mi(`hi_mean_mac') {
	global top_list_macs `"$top_list_macs `hi_mean_mac'"'
}
if !mi(`max_shift_top1') {
	global top_list_macs `"$top_list_macs `max_shift_top1'"'
}
if !mi(`max_shift_top2') {
	global top_list_macs `"$top_list_macs `max_shift_top2'"'
}

if !mi(`max_shift_bot1') {
	global bot_list2_macs `"$bot_list2_macs `max_shift_bot1'"'
}
if !mi(`max_shift_bot2') {
	global bot_list2_macs `"$bot_list2_macs `max_shift_bot2'"'
}

if !mi(`mid_max_mac') {
	global top_list2_macs `"$top_list2_macs `mid_max_mac'"'
}
if !mi(`hi_max_mac') {
	global top_list2_macs `"$top_list2_macs `hi_max_mac'"'
}
if !mi(`hi_mean_mac') {
	global top_list2_macs `"$top_list2_macs `hi_mean_mac'"'
}
if !mi(`hi_min_mac') {
	global top_list2_macs `"$top_list2_macs `hi_min_mac'"'
}


/*

Loop through every possible combination on the list, the second section below
accounts for making sure that top values still are run even if every bottom
value is empty

Lists are constructed to make sure that in two layered loops, every single
combination that needs to be examined is gone through and checked for

Combinations are shown above, and can be manually adjusted, ie, currently the
combination that would be the maximum breaks in either direction is ignored,
because in almost every case shifting the breaks so that the mid-density
category is as small as possible produces the least singles, but also shrinks
the category beyond usefulness

*/

if !mi($bot_list_macs) {
	foreach bot in $bot_list_macs {
		if abs(`break1' - `bot') <= `BOT_MAX_SHIFT' {
			foreach top in $top_list_macs {
				if abs(`break2' - `top') <= `TOP_MAX_SHIFT' {
					anon_helper "`varlist'" `bot' `top' `min_cell'
				}
			}
		}
	}
}

if !mi($top_list2_macs) {
	foreach top in $top_list2_macs {
		if abs(`break2' - `top') <= `TOP_MAX_SHIFT' {
			foreach bot in $bot_list2_macs {
				anon_helper "`varlist'" `bot' `top' `min_cell'
			}
		}
	}
}

di "The lowest number of singles is: " $drop_count_num
di "The following jurisdictions will be dropped: "

* list all respondents that will be dropped
list respondent_id if $drop_count <= `min_cell' & $drop_count != 0

* Show summary statistics for respondents being dropped
global drop_stats `"soss_reg pop_density `varlist'"'

foreach stat in $drop_stats {
	di _newline "Table on `stat' for responses being dropped"
	tabulate `stat' if $drop_count <= `min_cell' & $drop_count != 0
}

drop if $drop_count <= `min_cell' & $drop_count != 0

di "Final bottom break is: " $print_bot_break
di "Final top break: " $print_top_break _newline

* Count and display single amounts of jurisdictions in each category in old data
count if pop_density == 1
local low_dens_old = r(N)

count if pop_density == 2
local mid_dens_old = r(N)

count if pop_density == 3
local high_dens_old = r(N)

di "There are " `low_dens_old' " low-density jurisdictions in the old dataset"
di "There are " `mid_dens_old' " mid-density jurisdictions in the old dataset"
di "There are " `high_dens_old' " high-density jurisdictions in the old dataset" _newline


* Recode variables based on final decision for breaks
replace pop_density = 1 if popdens < $print_bot_break
replace pop_density = 2 if popdens >= $print_bot_break & popdens < $print_top_break
replace pop_density = 3 if popdens >= $print_top_break

* Count and display single amounts of jurisdictions in each category in new data
count if pop_density == 1
local low_dens_final = r(N)

count if pop_density == 2
local mid_dens_final = r(N)

count if pop_density == 3
local high_dens_final = r(N)

di "There are " `low_dens_final' " low-density jurisdictions in the new dataset"
di "There are " `mid_dens_final' " mid-density jurisdictions in the new dataset"
di "There are " `high_dens_final' " high-density jurisdictions in the new dataset" _newline

label define popdenslabels 1 "Low <$print_bot_break" 2 "Mid" 3 "High >=$print_top_break"
label val pop_density popdenslabels

* Final drops
capture confirm variable test_pop1
if !_rc {
	drop test_pop*
}

drop s_count* popdens

end
