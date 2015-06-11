{smcl}
{* *! version 1.2.1  07mar2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "anonymize##syntax"}{...}
{viewerjumpto "Description" "anonymize##description"}{...}
{viewerjumpto "Options" "anonymize##options"}{...}
{viewerjumpto "Remarks" "anonymize##remarks"}{...}
{viewerjumpto "Examples" "anonymize##examples"}{...}
{title:Anonymize MPPS Datasets}

{phang}
{bf:anonymize} {hline 2} Anonymize MPPS data by collecting variables that are 
identifiable, attempting to shift population density categories to obscure 
identifiable information, then drop any responses that cannot be adjusted out


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:anonymize}
[{list of identifiable variables}]


{marker description}{...}
{title:Description}

{pstd}
{cmd:anonymize} creates crosstabs and checks for identifiable respondents for 
the variables in {varlist}. Users can input up to 5 variables they find to be
identifying, and then are prompted for the cutoff point between low and mid, as 
well as the cutoff point between mid and high. 

Finally, they are prompted for the minimum number of occurrences of a pattern 
of response (typically 1 is most doable, but as many as are inputted can be 
requested). Keep in mind that the higher the number of minimum responses of a 
specific pattern is, the more responses will be dropped from the dataset.

Full process is as follows:
1. Merge the respondents dataset with the Gazzetteer dataset with population
densities for every jurisdiction

2. Run an initial .do file that will categorize the densities into their default
configurations (currently, file is pop_dens_ps.do, and cutoffs are 400 and 1000,
these must be adjusted in the files themselves.

3. Input command name followed by 1-5 identifying variables in the dataset.

4. When prompted, enter the lower population density cutoff, the higher cutoff, 
and the minimum number of responses of a certain pattern to allow (typical is 1).

5. Read through output to determine whether current settings are optimal for 
desired intent of the dataset.


{marker remarks}{...}
{title:Remarks}

{pstd}
anonymize.ado should remain in the same working directory as whatever dataset
it is being used on, in addition to anon_helper.ado (which is a file used to 
reduce the redundancy of the code in anonymize.ado). 

{marker examples}{...}
{title:Examples}

{phang}{cmd:. anonymize q7b_summary}{p_end}

{phang}{cmd:. anonymize q7b_summary q7c_summary}{p_end}
