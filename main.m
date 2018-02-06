
% --------------------------------------------------------------------
% The Lake Victoria Intense storm Early Warning System (VIEWS)
% 
% When using this model please cite this reference:
% 
% Thiery, W., Gudmundsson, L., Bedka, K., Semazzi, F.H.M., Lhermitte, 
% S., Willems, P., van Lipzig, N.P.M. and Seneviratne, S.I. Early 
% warnings of hazardous thunderstorms on Lake Victoria, Env. Res. 
% Lett., in review.
% --------------------------------------------------------------------


% to do:
% - hours_day differs between whole lake, KEN, TAN and UGA !!!
% - 'clock' should be UTC not local time  !!!



% --------------------------------------------------------------------
% main script to perform intense storm prediction
% tested on MATLAB 7.12.0 (R2011a)
% --------------------------------------------------------------------


% start clock
tic


% clean up
clc;
clear;
close all;


% flags
flags.user_OTdata = 2; % 0: use historical data
                       % 1: request input from user about OT data
                       % 2: operational mode with data from NASA server
flags.user_config = 0; % 0: use optimised model configuration from Thiery et al., 2017 ERL
                       % 1: request input from user about model configuration
flags.plot        = 0; % 0: do not plot
                       % 1: plot



% --------------------------------------------------------------------
% initialisation
% --------------------------------------------------------------------


% define hours considered as "day" and "night"
hours_night = [22:24 1:9]; % final estimate based on OT diurnal cycle
hours_day   = 10:15;


% define percentile above which events are considered 'severe'
perc_severe = 99;


% initialise model parameters
res_reg = 0.20; % predefined regular grid


% name of the best logistic regression model (obtained by optimisation, see paper section 4)
model_best = 'OT_models_best.mat';


% name of the best logistic regression model (obtained by optimisation, see paper section 4)
% OT_data_test = 'OT_d_best_20050311.mat';   % example data for testing the model - calm day    (11/03/2005)
OT_data_test = 'OT_d_best_20050314.mat'; % example data for testing the model - extreme day (14/03/2005)


% Define remote path where OT data can be downloaded
OT_rpath = 'https://clouds.larc.nasa.gov/prod/exp/lake_victoria';


% add data path to work path
addpath('data')


% --------------------------------------------------------------------
% load data
% --------------------------------------------------------------------


% load best logistic regression model
if     flags.user_config == 0
    load(model_best)
elseif flags.user_config == 1
    model_user = input('Please name the file containing the logistic regression model (e.g. LOGR_OT_best.mat)\n\n','s');
    load(model_user)
end


% load Overshooting Top (OT) data
if     flags.user_OTdata == 0    % use historical data
    
    disp(sprintf(['Loading test data (' OT_data_test ')\n'])) %#ok<*DSPS>
    load(OT_data_test)
    
elseif flags.user_OTdata == 1    % request input from user about OT data
    
    OT_data_user = input('Please name the file containing the afternoon OT map (e.g. OT_d_best_20050311.mat)\n\n','s');
    load(OT_data_user)
    
elseif flags.user_OTdata == 2    % operational mode with data from NASA server
        
    [OT_d, OT_d_regridded_daysum] = mf_get_OT_today(OT_rpath, LOGR_OT_best.hours_day, LOGR_OT_best.lat, LOGR_OT_best.lon);
        
end



% --------------------------------------------------------------------
% Perform prediction
% --------------------------------------------------------------------


% whole lake
mf_VIEWS('Whole lake', OT_d, LOGR_OT_best);


% Sector Uganda
mf_VIEWS('Uganda'    , OT_d, LOGR_OT_best_Uga);


% Sector Kenya
mf_VIEWS('Kenya'     , OT_d, LOGR_OT_best_Ken);


% Sector Tanzania
mf_VIEWS('Tanzania'  , OT_d, LOGR_OT_best_Tan);


% stop clock
toc
