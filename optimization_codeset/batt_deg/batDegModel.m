function [L, d] = batDegModel(s, ts, T, t_tot)
%% Title: Degradation calculation
% Author: Bolun Xu
% Date: 2012-04-19
% Summary:
%   Calculate degradation in percentage(0 to 1) from the given SoC profile
%   since the battery began to operate.
%   The program first uses the rainflow counting algorithm to count cycles
%   in the current profile. Then a degradation model (CDF_Custom) is 
%   applied to calculate the degradation
% Input:
%   s - SoC profile since battery start, in dec percentage
%   ts - sampling time of the profile, in seconds
%   T - battery temperature profile, in Celsius
%   t - total operation time of the battery, in seconds
% Output:
%   L - the nonlinear capacity degradation since a fresh battery
%   d - the linearized capacity degradation

% Heavily modified by Trent Dillon on 2020-12-05
% Summary:
%   Rainflow is now a function in the signal processing toolbox. There are
%   no longer restirictions on the maximum data points rainflow can handle.
%   The outputs of rainflow are also slightly different than the MEX code 
%   Adam wrote in the 00's. Otherwise, the code functions the same and
%   documentation has been updated to capture all changes.

%% rainflow counting

rf = rainflow(s);

% rf(:,1) whether this is a 1 or 0.5 cycle
% rf(:,2) cycle range
% rf(:,3) cycle mean value
% rf(:,4) initial sample index
% rf(:,5) final sample index

N = rf(:,1); %full cycle or half cycle
DoD = rf(:,2); %depth of discharge, not multiplied by 2? [dec %]
SoC = rf(:,3); %mean state of charge [dec %]
t = ts * (rf(:,5) - rf(:,4)); % duration [s]
if length(T) > 1
    T = T(ceil((rf(:,4) + rf(:,5))/2)); % medium temperature
end

%% linearized degradation
d = Linear_degradation(DoD, SoC, T, N, t_tot);

%% nonlinear part
L = Nonlinear_degradation( d );




