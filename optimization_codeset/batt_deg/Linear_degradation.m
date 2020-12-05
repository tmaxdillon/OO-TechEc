function d = Linear_degradation(DoD, SoC, Crate, T, N, t)
%%
% Title: Linearized battery degradation model
% Date: 2013-04-19
% Author: Bolun Xu
% Input: 
%   DoD - 
%   SoC - 
%   Crate - 
%   N - number of cycles
%   T - battery temperature in degree C
%   t - total operation time since the battery is put into use
% Output:
%   d - linear degradation rate

%% cycle ageing

% SoC stress model
k_soc = 1.039; % SoC stress model coefficient
SoC_ref = .6; % reference cycle average SoC
d_SoC = exp(k_soc*(SoC-SoC_ref));

% DoD stress model
k_DoD2 = 2.03; % DoD stress model nonlinear coefficient
k_DoD1 = .2/(3000*.8^k_DoD2); % 3000 cycles @ 80% DoD till 80% end of life
d_DoD = k_DoD1 .* DoD.^k_DoD2;

% C-rate effect
d_Crate = 1; % C-rate effect is neglected for now

% cell temperature effect
k_t = 0.0693; 
T_ref = 25; % reference temperature in Celsiust
d_temp = exp(k_t * (T-T_ref) * (273 + T_ref)./(273 + T));


% total cycle ageing
d_cycle = sum(d_DoD .* d_SoC .* d_Crate .* d_temp .* N);

%% calender ageing

k_soc_cal = k_soc;
k_cal = 3.31e-9/8;
SoC_ref = .6;

SoC_avg = mean(SoC);
T_avg = mean(T);

d_cal = k_cal.*exp(k_soc_cal*(SoC_avg-SoC_ref)) .* t ...
    .* exp(k_t * (T_avg-T_ref) .* (273 + T_ref)./(273 + T_avg));

%% total linearized degradation
d = d_cycle + d_cal;