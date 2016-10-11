
% --------------------------------------------------------------------
% The Lake Victoria Intense storm Early Warning System (VIEWS)
% --------------------------------------------------------------------


% --------------------------------------------------------------------
% main script to perform intense storm prediction
% --------------------------------------------------------------------


% start clock
tic


% clean up
clc;
clear;
close all;


% flags
flags.conc = 0; % 0: use optimised model configuration from Thiery et al., 2017 ERL
                % 1: request input from user
flags.plot = 1; % 0: do not plot
                % 1: plot



% --------------------------------------------------------------------
% initialisation
% --------------------------------------------------------------------


% define hours considered as "day" and "night"
hours_night = [22:24 1:9]; % final estimate based on OT diurnal cycle


% define percentile above which events are considered 'severe'
perc_severe = 99;


% initialise model parameters
res_reg = 0.20; % predefined regular grid



% --------------------------------------------------------------------
% load OT data
% --------------------------------------------------------------------


ms_load



% --------------------------------------------------------------------
% manipulations: general
% --------------------------------------------------------------------


ms_manip



% --------------------------------------------------------------------
% Perform prediction
% --------------------------------------------------------------------


mf_VIEWS



% --------------------------------------------------------------------
% visualise output
% --------------------------------------------------------------------


if flags.plot == 1
   ms_plotscript
end



% stop clock
toc
