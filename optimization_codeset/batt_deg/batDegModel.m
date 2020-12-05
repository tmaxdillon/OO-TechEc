function [L, d] = batDegModel(s, ts, T, t_tot)
%% Title: Degradation calculation
% Author: Bolun Xu
% Date: 2012-04-19
% Summary:
%   Calculate degradation in percentage(0 to 1) from the given SoC profile
%   since the battery began to operate.
%   The program first uses the rainflow counting algorithm to count cycles
%   in the current profile. Then a degradation model (CDF_Custom) is applied
%   to calculate the degradation
% Input:
%   s - SoC profile since battery start, in percentage
%   ts - sampling time of the profile, in seconds
%   T - battery temperature profile, in Celsius
%   t - total operation time of the battery, in second
% Output:
%   L - the nonlinear capacity degradation since a fresh battery
%   d - the linearized capacity degradation

%% rainflow counting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Chop input data in segments (This is necessary 
% since there is a limit on how many data points 
% the rainflow implementation can handle) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=length(s);
Nmax=5000; % Number of data points in each segment
rf=zeros(5,1);

if N>Nmax
    nr_whole_seg=idivide(int32(N),Nmax);
    if nr_whole_seg*Nmax==N
        nr_seg=nr_whole_seg;
    else
        nr_seg=nr_whole_seg+1;
    end;
    
    for q=1:nr_seg
        if (q<nr_seg)
            n_start=(q-1)*Nmax+1;
            n_stop=n_start+Nmax-1;
            S=s(n_start:n_stop);
        else
            n_start=(q-1)*Nmax+1;
            n_stop=length(s);
            S=s(n_start:n_stop);
        end;
        [tp exttime]=sig2ext(S); % Calculate turning points
        rf_seg{q}=rainflow(tp,exttime); % Run rainflow algorithm
    end;
    
    for q=1:nr_seg
        rf=cat(2,rf,rf_seg{q});
    end;
else
    [tp exttime]=sig2ext(s); % Calculate turning points
    rf=rainflow(tp,exttime); % Run rainflow algorithm
end;

[Q,R]=size(rf);
rf=rf(:,2:R);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rf(1,:) Cycles amplitude,
% rf(2,:) Cycles mean value,
% rf(3,:) Number of cycles (0.5 or 1.0),
% rf(4,:) Begining time (when input includes dt or extt data),
% rf(5,:) Cycle period (when input includes dt or extt data),
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculate input parameters to degradation model
DoD = 2*rf(1,:);
SoC = rf(2,:);
N = rf(3,:);
if length(T) == 1
    Tb = T;
else
    Tb = T(ceil((rf(4,:) + rf(5,:))/2)); % medium temperature
end
t = ts * rf(5,:); % duration of each cycle

Crate = DoD .* (2*N) ./ (t/3600); % calculated by SoC change per hour

%% linearized degradation
d = Linear_degradation(DoD, SoC, Crate, T, N, t_tot);

%% nonlinear part
L = Nonlinear_degradation( d );




