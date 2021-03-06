# mpps-anonymize
Stata program created for the Center for Local, State, and Urban Policy's biannual Michigan Public Policy Survey to identify and eliminate any potentially identifiable information. Individuals could potentially identify respondents by running crosstabs on identifiable information collected by the survey (ie, types of transit, specific laws, region). This program allows users to choose which variables are identifiable, then the program identifies how many respondents are vulnerable through creating a new variable (pop_density) and moving it around to create the smallest amount of identifiable responses. 

Responses that, following this process, are still identifiable, are dropped from the dataset. These datasets are soon going to be shared publicly on the CLOSUP website as well as in several University of Michigan courses.

Public datasets can be accessed [through the openICPSR site](http://doi.org/10.3886/E52395V7)
