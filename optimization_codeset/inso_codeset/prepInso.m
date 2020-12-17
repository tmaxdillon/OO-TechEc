function [data] = prepInso(data,inso,uc)

inso_in = data.met.shortwave_irradiance;
time_in = data.met.time;

%for use in simInso, the irradiance timeseries must be at least 1 year
%long. this function is used to artificially extend the length of an
%irradiance timeseries that is shorter than a year.
if length(data.met.shortwave_irradiance) < 8760
    %elongate irradiance timeseries (needs to be at least one year)
    tStart = datevec(time_in(1)); %start of timesereis
    tEnd = tStart;
    tEnd(1) = tStart(1) + 1; %make end of timeseries one year later
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
    data.met.shortwave_irradiance = inso_out;
    data.met.time = time_out;
end

%extend dataset to lifetime of instrumentation (to examine degradation)
data.swso = fillmissing(data.met.shortwave_irradiance,'linear'); %[W/m^2]
orig_l = length(data.swso);
tStart = datevec(data.met.time(1));
tEnd = tStart;
tEnd(1) = tEnd(1) + uc.lifetime;
data.swso = [data.swso; ...
    zeros(etime(tEnd,tStart)/(60*60)-length(data.swso),1)];
time = [data.met.time; ...
    zeros(etime(tEnd,tStart)/(60*60)-length(data.swso),1)];
for t = orig_l+1:length(data.swso)
    data.swso(t) = data.swso(orig_l - rem(t,8760));
    time(t) = time(t-1) + 1/24;
end

%winter cleaning
if inso.cleanstrat == 3 %winter cleaning
    %winter cleaning (if applicable)
    if data.lat < 0 %southern hemisphere
        wint_clean_mo = 5; %may
    else
        wint_clean_mo = 11; %november
    end
    dv = datevec(time);
    data.wint_clean_ind = find(dv(:,2) == wint_clean_mo & dv(:,3) == 1 ...
        & dv(:,4) == 0);
end

end

