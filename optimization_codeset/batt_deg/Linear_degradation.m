function d = Linear_degradation(DoD, SoC, T, N, t)
%%
% Title: Linearized battery degradation model
% Date: 2013-04-19
% Author: Bolun Xu
% Input: 
%   DoD - 
%   SoC - 
%   N - number of cycles
%   T - battery temperature in degree C
%   t - total operation time since the battery is put into use
% Output:
%   d - linear degradation rate

%% cycle ageing

% SoC stress model
k_soc = 1.039; % SoC stress model coefficient, NMC and LMO
SoC_ref = .6; % reference cycle average SoC, NMC and LMO
% k_soc = 0.916; % SoC stress model coefficient, LFP (Peterson A123)
% SoC_ref = .5; % reference cycle average SoC, LFP (Peterson A123)
d_SoC = exp(k_soc*(SoC-SoC_ref));

% DoD stress model
% k_DoD2 = 2.03; % DoD stress model nonlinear coefficient, NMC
% k_DoD1 = .2/(3000*.8^k_DoD2); % 3000 cycles @ 80% DoD till 80% EoL, NMC
% d_DoD = k_DoD1 .* DoD.^k_DoD2; % quadratic model, NMC
k_DoD2 = 0.717; % kco or coefficient of throughput, LFP, (Peterson A123)
k_DoD1 = 3.66e-5; % kex or exponent for DoD, LFP, (Peterson A123)
d_DoD = k_DoD1 .* DoD.*exp(k_DoD2.*DoD); % exponential model, LFP, Millner

% cell temperature effect
k_t = 0.0693; % Tfact from Millner article
T_ref = 25; % reference temperature in Celsius
d_temp = exp(k_t * (T-T_ref) * (273 + T_ref)./(273 + T));

% total cycle ageing
d_cycle = sum(d_DoD.*d_SoC.*d_temp'.*N);

%% calender aging

k_soc_cal = k_soc;
k_cal = 4.1375e-10; % time aging stress model coefficient, NMC and LMO
SoC_ref = .6; % reference cycle average SoC, NMC and LMO

SoC_avg = mean(SoC);
T_avg = mean(T);

d_cal = k_cal.*exp(k_soc_cal*(SoC_avg-SoC_ref)) .* t ...
    .* exp(k_t * (T_avg-T_ref) .* (273 + T_ref)./(273 + T_avg));

%% total linearized degradation
d = d_cycle + d_cal;