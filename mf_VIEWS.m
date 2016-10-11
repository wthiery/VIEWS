

% --------------------------------------------------------------------
% function to apply logistic regression to the OT image
% --------------------------------------------------------------------


function [LOGR AUC rho] = mf_VIEWS(predictor, predictant, date_vec, threshold)


               

% --------------------------------------------------------------------
% initialisation
% --------------------------------------------------------------------



% --------------------------------------------------------------------
% manipulations
% --------------------------------------------------------------------


% construct binary time series from input predictant time series
% should be "extremes" only
extr = predictant > threshold;


% flag point if predictor contains only zeros
if isempty(find(predictor, 1))
    ispredictor = 0;
else
    ispredictor = 1;
end


% given previous check, we can suppres this warning
warning('off', 'stats:glmfit:IllConditioned')


% % perform logistic regression on ALL data
% b_all = glmfit(predictor, extr, 'binomial'); % perform logistic regression 
% p_all = glmval(b_all, predictor, 'logit');   % get probabilities


% perform logistic regression on ALL data - get 95% confidence interval
[b_all, ~, b_all_stats] = glmfit(predictor, extr, 'binomial'); % perform logistic regression 
[p_all]                 = glmval(b_all, predictor, 'logit');   % get probabilities


% perform logistic regression using leave one YEAR out cross validation (LOYOCV)
p_LOYOCV = NaN(size(predictor));
for i=date_vec(1,1):date_vec(end,1)   % loop over years
    
    % get indices
    isyear    = date_vec(:,1) == i;
    
    % perform logistic regression on all data except that year
    b         = glmfit(predictor(~isyear), extr(~isyear), 'binomial'); 
    
    % get probabilities for that year
    p_LOYOCV(isyear) = glmval(b, predictor(isyear), 'logit');       
    
end


% same as extr vector, but now as cell array and with words 
% (required input for perfcurve function)
cases         = cell(length(extr),1);
cases(:,1)    = {'normal'};
cases(extr,1) = {'extreme'};


% generate ROC curve 
% False alarm rate (F) on x-axis
% Hit rate (H) on y-axis
[F, H, T, AUC] = perfcurve(cases, p_LOYOCV, 'extreme');


% compute diagnostics - optimal point
[opt, ind_opt] = nanmax(H - F);
H_opt          = H(ind_opt);
F_opt          = F(ind_opt);
T_opt          = T(ind_opt);


% compute diagnostics - warnings associated with optimal point
warnings = p_LOYOCV >= T_opt;


% compute diagnostics - Odds Ratio (for optimal point)
%           X - 2x2 data matrix composed like this: 
%...........................................extrnight..normnight
%                                              ___________
%Warning                                      |  A  |  B  |
%                                             |_____|_____|
%No warning                                   |  C  |  D  |
%                                             |_____|_____|
% Then: Odds Ratio = (A * D) / (C * B)
% nwarnings = length(find( warnings ));
% nextr     = length(find( extr     ));
A  = length(find( warnings &  extr));
B  = length(find( warnings & ~extr));
C  = length(find(~warnings &  extr));
D  = length(find(~warnings & ~extr));
OR = (A * D) / (C * B);


% compute diagnostics - False alarms rates (F) associated with fixed Hit rates (H)
F_His05 = F(find(H >= 0.5, 1, 'first'));
F_His09 = F(find(H >= 0.9, 1, 'first')); 
F_His10 = F(find(H >= 1.0, 1, 'first'));


% compute diagnostics - rank correlation
rho = corr(predictor, predictant, 'type', 'spearman', 'rows', 'pairwise');


% prepare output structure
LOGR.predictor   = predictor;
LOGR.extr        = extr;
LOGR.ispredictor = ispredictor;
LOGR.b_all       = b_all;
LOGR.b_all_stats = b_all_stats;
LOGR.p_all       = p_all;
LOGR.p_LOYOCV    = p_LOYOCV;
LOGR.F           = F;
LOGR.H           = H;
LOGR.T           = T;
LOGR.AUC         = AUC;
LOGR.opt         = opt;
LOGR.ind_opt     = ind_opt;
LOGR.H_opt       = H_opt;
LOGR.F_opt       = F_opt;
LOGR.T_opt       = T_opt;
LOGR.warnings    = warnings;
LOGR.OR          = OR;
LOGR.F_His05     = F_His05;
LOGR.F_His09     = F_His09;
LOGR.F_His10     = F_His10;
LOGR.rho         = rho;



end
