function [a_out,t_out] = extendToLifetime(a_in,t_in,y)

if length(a_in) < 8760 %if less than a year, extend to a year
    tStart = datevec(t_in(1));
    tEnd = tStart; tEnd(1) = tStart(1) + 1;
    t_yl = [t_in; zeros(etime(tEnd,tStart)/(60*60)-length(a_in),1)];
    a_yl = [a_in; zeros(etime(tEnd,tStart)/(60*60)-length(a_in),1)];
    for i = length(t_in)+1:length(t_yl)
        %give time vector a value an hour ahead
        t_yl(i) = t_in(end) + (i-length(t_in)+1)/24;
        %give s vector a value a month prior
        tVec = datevec(t_yl(i)); %current time
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
        [~,a_ind] = min(abs(t_yl(1:i-1) - ... 
            datenum(tVec_past))); %find past index
        a_yl(i) = a_yl(a_ind);
    end
    t_in = t_yl;
    a_in = a_yl;
end
%extend SoC timeseries to five years
orig_l = length(a_in);
tStart = datevec(t_in(1));
tEnd = tStart; tEnd(1) = tEnd(1) + y;
t_out = [t_in; zeros(etime(tEnd,tStart)/(60*60)-length(t_in),1)];
a_out = [a_in; zeros(etime(tEnd,tStart)/(60*60)-length(a_in),1)];
for i = orig_l+1:length(a_out)
    t_out(i) = t_out(i-1) + 1/24;
    a_out(i) = a_out(i - 8760); %a year earlier
end

end

