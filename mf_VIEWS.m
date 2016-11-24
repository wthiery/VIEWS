

% --------------------------------------------------------------------
% function to perform logistic regression and compute ROC curve
% --------------------------------------------------------------------


function [warning] = mf_VIEWS(OT_d, LOGR_OT)


               

% --------------------------------------------------------------------
% initialisation
% --------------------------------------------------------------------



% --------------------------------------------------------------------
% manipulations
% --------------------------------------------------------------------


% get daytime daytime total OTs over highly correlated regions
OT_d_gp = nansum(nansum(OT_d(LOGR_OT.iscorr),1),2);


% get probability for an extreme night given the input logistic regression model
p_all = glmval(LOGR_OT.b_all, OT_d_gp, 'logit');


% decide whether warning nees to be issued 
% assume optimal point (threshold probability for the difference between
% hit rate and false alarm rate is maximum)
if     p_all <  LOGR_OT.T_opt % do not issue warning
    warning = 0;
    disp('NO WARNING')
elseif p_all >= LOGR_OT.T_opt % issue warning
    warning = 1;
    disp('WARNING: high probability for extreme nighttime thunderstorm activity on Lake Victoria')
end



end
