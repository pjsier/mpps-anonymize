program define anon_helper
  args idq bot_break top_break min_cell
* All of these arguments are passed in by anonymize

di "Attempting bottom break at: " `bot_break'
di "Attempting top break at: " `top_break' _newline

* Generate custom counted population to get counts for
gen test_pop${round}=1
replace test_pop${round}=2 if (popdens>=`bot_break' & popdens<`top_break')
replace test_pop${round}=3 if (popdens>=`top_break')

* Create variable like in anonymize of frequencies
egen s_count${round} = count(1), by(test_pop${round} `idq' soss_reg)

* Make independent count of singles for this configuration
count if s_count${round} <= `min_cell' & s_count${round} != 0
local mcount${round} = r(N)

* Print out num singles
di "There are " `mcount${round}' " singles in altered version" _newline

* Check if it's the lowest so far, and switch the pending drop to it if it is
if `mcount${round}' < $drop_count_num {
  global drop_count_num =  `mcount${round}'
  global drop_count = "s_count${round}"
  global print_bot_break = `bot_break'
  global print_top_break = `top_break'
}

* Increment round to allow for creation of new numbered variables
global round = $round + 1

end
