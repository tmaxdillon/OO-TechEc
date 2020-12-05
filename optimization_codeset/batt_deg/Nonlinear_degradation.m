function [ L ] = Nonlinear_degradation( d )
%%
% Title: Nonlinearize the linearized model
% Date: 2013-04-19
% Author: Bolun Xu
% Input: 
%   d - calculated linearized degradation
% Output:
%   L - nonlinear degradation rate

%% nonlinear part
% d_perCycle = d_tot/N;
% 
% p1 = 1329;
% p2 = .02353;
% a = p1 * d_perCycle + p2;

a = .0575;
b = 121; % averaging from data

%% modulate
L = 1 - a*exp(-b*d) - (1-a)*exp(-d);

end

