function [L, d] = batDegModel(s, T, t_tot,toggle_os,ID)
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
%   T - battery temperature profile, in Celsius, must be singular
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

if ~toggle_os %using signal processing toolbox
    rf = rainflow(s);
    % rf(:,1) whether this is a 1 or 0.5 cycle
    % rf(:,2) cycle range
    % rf(:,3) cycle mean value
    % rf(:,4) initial sample index
    % rf(:,5) final sample index
    N = rf(:,1); %full cycle or half cycle
    DoD = rf(:,2); %depth of discharge, not multiplied by 2? [dec %]
    SoC = rf(:,3); %mean state of charge [dec %]
    d = Linear_degradation(DoD, SoC, T, N, t_tot);
    L = Nonlinear_degradation( d );
else %using open source code (HPC friendly)
    [tp,exttime] = sig2ext(s); %calculate turning points
    if length(tp) < 6 %needs four cycles to evaluate
        d = 0;
        L = 0;
    else
        try
            %[tp,exttime] = sig2ext([1 2 3 4 5]); %calculate turning points            
            rf = rainflow_os(tp,exttime); %run rainflow algorithm
        catch ME
            if (strcmp(ME.identifier,'MATLAB:badsubscript'))
                msg = ['Bad subscript occurred: ' ...
                    'tp is ' num2str(length(tp)) ' long, ' ...
                    'id is ' num2str(ID(1)) ' kW ' ...
                    num2str(ID(2)) ' Smax'];
%                 msg = ['Bad subscript occurred: ' ...
%                     'tp is ' num2str(length(tp)) ' long.'];
                causeException = ...
                    MException('MATLAB:myCode:dimensions',msg);
                ME = addCause(ME,causeException);
            end
            rethrow(ME)
        end
        % rf(1,:) cycle range
        % rf(2,:) cycle mean value
        % rf(3,:) whether this is a 1 or 0.5 cycle
        % rf(4,:) initial sample index
        % rf(5,:) indicies cycle spans
        N = rf(3,:)'; %full cycle or half cycle
        DoD = rf(1,:)'; %depth of discharge, not multiplied by 2? [dec %]
        SoC = rf(2,:)'; %mean state of charge [dec %]
        d = Linear_degradation(DoD, SoC, T, N, t_tot);
        L = Nonlinear_degradation( d );
    end
end

end



