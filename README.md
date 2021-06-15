
<p align="center">
	<img src="https://github.com/dime-worldbank/moz-proirri-savings/raw/master/img/WB_logo.png?raw=true")>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<img src="https://github.com/dime-worldbank/moz-proirri-savings/raw/master/img/i2i.png?raw=true")
</p>

# Replication Package for "Do Private Consultants Promote Savings and Investments in Rural Mozambique?"

This repository contains the codes that replicate the figures and tables presented in the paper "Do Private Consultants Promote Savings and Investments in Rural Mozambique?" (2021) by Paul Christian, Steven Glover, Florence Kondylis, Valerie Mueller, Matteo Ruzzante and Astrid Zwager.

## Read First
The whole analysis in the paper can be rerun by using the script `MAIN_proirri.do`, which is in the [Dofiles](https://github.com/dime-worldbank/moz-proirri-savings/tree/master/DataWork/Dofiles) subfolder. It is only necessary to add your computer's username and path to the cloned replication folder(s) in line 97-100 of such do-file in *PART 1*.
You can select which section(s) to run by editing the locals in the preamble of the do-file. Make sure to run the *packages* section &ndash; *PART 0* to install all necessary packages before running the other sections.

The main script will take around a full day on a reasonable cluster. Without considering the do-files using bootstrapping replications (see section *Code Process* below), it would take around 3 minutes.

The individual do-files with their respective inputs and outputs are explained below.
The do-files employ finalized datasets, which are constructed from various data sources, listed and described below.

Computational reproducibility was verified by [DIME Analytics](https://worldbank.github.io/dimeanalytics/code-review/). Details of the reproducibility checklist can be found [here](https://github.com/dime-worldbank/moz-proirri-savings/tree/master/PROIRRI_Savings_Reproducibility_Checks.pdf).

&nbsp;

## Data Description
The final dataset `PROIRRI Financial Literacy - Savings paper data.dta` contains information on all 42 associations and 3,081 households in the experimental sample.
The corresponding ID variables are `associd` and `hhid`.

As presented in Section 3 of the paper, multiple sources of data were collected to assess the impact of the study program.
Every variable in the final dataset has a prefix, which specifies the origin of the information it contains.
Namely, we apply the following pattern to inform variable naming:
- `ad_` for project administrative data;
- `bp_` for box pick-up data;
- `bl_` for association and household baseline census;
- `el_` for household endline survey.

You can find a more detailed description of all the variables employed in the data analysis, especially with regard to variables constructed using survey data, [here](https://github.com/dime-worldbank/moz-proirri-savings/tree/master/DataWork/Documentation).

The survey instrument is also available in Portuguese [here](https://github.com/dime-worldbank/moz-proirri-savings/tree/master/DataWork/Documentation/QRE_HH_Endline_PT.xlsx) and the related CTO form [here](https://github.com/dime-worldbank/moz-proirri-savings/tree/master/DataWork/Documentation/CTO_HH_Endline.xlsx).



##  Code Process
The name of the do-files, which are run by the principal script `MAIN_proirri.do`, corresponds to the `.tex` or `.png` file to be created in the output folder, with the exception of `tab03-4,A04-6-hh_multiple_hypothesis_testing.do` and `tabA11-12-hh_multiple_hypothesis_testing_controls.do`.
The latter do-files estimate the program impact on secondary outcomes from household survey data, such as mechanization use and ownership, credit, input use and other costs. These variables were not part of our pre-analysis plan for the experiment filed in the [AEA RCT Registry](https://www.socialscienceregistry.org/trials/937) as "Group Interventions for Agricultural Transformation in Mozambique" (RCT ID: AEARCTR-0000937), and therefore we adjust the p-values for family-wise error rate using the free step-down procedure by Westfall and Young (1993).

All do-files use the final dataset, `PROIRRI Financial Literacy - Savings paper data.dta`.
All tables and figures were included &ndash; without further editing &ndash; in the TeX document containing the current version of the paper.

You can find a more detailed description of each do-file's inputs and outputs [here](https://github.com/dime-worldbank/moz-proirri-savings/tree/master/DataWork/Dofiles).

## Contact
If you have any comment, suggestion or request for clarifications, you can contact Matteo Ruzzante at <a href="mailto:matteo.ruzzante@u.northwestern.edu">matteo.ruzzante@u.northwestern.edu</a> or directly open an issue or pull request in this GitHub repository.</p>

&nbsp;

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
