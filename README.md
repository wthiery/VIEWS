# VIEWS
The Lake Victoria Intense storm Early Warning System (VIEWS)

Version 1.0 of the package, termed Lake Victoria Intense storm Early Warning System (VIEWS), is available at https://github.com/wthiery/VIEWS and is released under the MIT licence. 

At this stage the prediction system needs to be considered as a prototype; more research as well as input from the user community is needed to improve its skill, strengthen the links to societal losses (e.g. Semazzi and Mera, 2006 JAMC), assess uncertainties (e.g. Lhermitte et al., 2010 RSE), and test its applicability to other African Great Lakes. 

At forecast lead time, the software first downloads the OT images corresponding to the daytime hours from an open data repository. It subsequently computes the predictor value OT_day for each country and the whole lake by performing the appropriate spatial and temporal selection (see equation 2 and table 1 in Thiery et al., 2017 ERL). The OT_day values then serve as input for the respective logistic regressions (see equation 1 and table 1 in Thiery et al., 2017 ERL), yielding the probability for an extreme event. Depending on the threshold probability defined by the user, the software will indicate whether or not a warning is to be issued for a specific lake sector or the whole lake.
