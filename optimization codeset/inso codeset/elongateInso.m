function [inso_out,time_out] = elongateInso(inso_in,time_in)
%for use in simInso, the irradiance timeseries must be at least 1 year
%long. this function is used to artificially extend the length of an
%irradiance timeseries that is shorter than a year.

%elongate irradiance timeseries (needs to be at least one year)
tStart = datevec(time_in(1)); %start of timesereis
tEnd = tStart; tEnd(1) = tStart(1) + 1; %make end of timeseries one year later
time_out = [time_in ; zeros(etime(tEnd,tStart)/(60*60)- ...
    length(inso_in),1)]; %preallocate time vector
inso_out = [inso_in ; zeros(etime(tEnd,tStart)/(60*60)- ...
    length(inso_in),1)]; %preallocate inso vector
for t = length(time_in)+1:length(time_out)
    %give time vector a value an hour ahead
   time_out(t) = time_in(end) + (t-length(time_in)+1)/24;
    %give inso vector a value a month prior
    tVec = datevec(time_out(t)); %current time
    tVec_past = tVec; tVec_past(2) = tVec(2) - 1; %time a month ago
    [~,inso_ind] = min(abs(time_out(1:t-1) - ... 
        datenum(tVec_past))); %find index a month ago
    inso_out(t) = inso_out(inso_ind);
end

end

