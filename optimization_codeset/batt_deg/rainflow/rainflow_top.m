function [DoD, SoC, Crate, Tb, N] = rainflow_top(s, T)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Chop input data in segments (This is necessary 
% since there is a limit on how many data points 
% the rainflow implementation can handle) 
% [DoD, SoC, Crate, Tb, N] = rainflow_top(s, T)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=length(s);
Nmax=30*86400; % Number of data points in each segment
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
        rf_seg{q}(4,:) = rf_seg{q}(4,:) + double(q)*Nmax;
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
% t = ts * rf(5,:); % duration of each cycle

Crate = DoD .* (2*N) ./ (rf(5,:)/3600); % calculated by SoC change per hour

Crate(Crate > 4) = 4;