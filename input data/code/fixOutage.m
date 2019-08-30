function [resource_out] = fixOutage(resource_in,time_in, ... 
    t1,t2,f)

%inputs:
%resource time series, time time series, outage time start, outage time
%end, forward/backward reach indicator (f = 1 = foraward)

%elongate irradiance timeseries (needs to be at least one year)
tStart = datevec(time_in(1)); %start of timesereis
tEnd = tStart; tEnd(1) = tStart(1) + 1; %make end of timeseries one year later
time_out = [time_in ; zeros(etime(tEnd,tStart)/(60*60)- ...
    length(inso_in),1)]; %preallocate time vector
inso_out = [inso_in ; zeros(etime(tEnd,tStart)/(60*60)- ...
    length(inso_in),1)]; %preallocate inso vector

t1_ind = find(time_in == datenum(t1)

%prealloate
resource_out = resource_in;
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

