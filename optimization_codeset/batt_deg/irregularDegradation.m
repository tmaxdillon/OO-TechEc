function [L,lft] = irregularDegradation(s_in,time_in,sys_lft,batt)

if length(s_in) < 8760 %if less than a year, extend to a year
    tStart = datevec(time_in(1));
    tEnd = tStart; tEnd(1) = tStart(1) + 1;
    time_out = [time_in ...
        zeros(1,etime(tEnd,tStart)/(60*60)-length(s_in))];
    s_out = [s_in  zeros(1,etime(tEnd,tStart)/(60*60)-length(s_in))];
    for i = length(time_in)+1:length(time_out)
        %give time vector a value an hour ahead
        time_out(i) = time_in(end) + (i-length(time_in)+1)/24;
        %give s vector a value a month prior
        tVec = datevec(time_out(i)); %current time
        tVec_past = tVec;
        %set the time replicant month to be equidistant from jan
        tVec_past(2) = 1 + (1 - tVec(2));
        if tVec_past(2) < 1 %skiped back a year
            tVec_past(2) = 12 + tVec_past(2);
            tVec_past(1) = tVec_past(1) - 1;
            if tVec_past(2) < 10 %no data past October for irmSea
                tVec_past(2) = 10;
            end
        end
        [~,s_ind] = min(abs(time_out(1:i-1) - ...
            datenum(tVec_past))); %find past index
        s_out(i) = s_out(s_ind);
    end
    time_in = time_out;
    s_in = s_out;
end
%extend SoC timeseries to five years
orig_l = length(s_in);
tStart = datevec(time_in(1));
tEnd = tStart; tEnd(1) = tEnd(1) + sys_lft;
time_ext = [time_in zeros(1,etime(tEnd,tStart)/(60*60)-length(time_in))];
s_ext = [s_in zeros(1,etime(tEnd,tStart)/(60*60)-length(s_in))];
for i = orig_l+1:length(s_ext)
    time_ext(i) = time_ext(i-1) + 1/24;
    s_ext(i) = s_ext(i - 8760); %a year earlier
end
%compute degradation
ts = 60*60*24*(time_in(2) - time_in(1)); %[s]
t_tot_ext = 3600*length(s_ext); %[s]
L = batDegModel(s_ext,ts,batt.T,t_tot_ext,batt.rf_os);
lft = batt.EoL/L*t_tot_ext*12/(3600*8760); %[mo]

end

