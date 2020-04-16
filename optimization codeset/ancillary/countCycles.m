function [cyc_n] = countCycles(S,Smax,per)

cyc_i = false; %when true % threshold has been crossed
cyc_n = 0; %cycle count

for i = 1:length(S)
    if ~cyc_i %above percent threshold (currently charged)
        if S(i) <= Smax*1000*(1-(per-1)/100) %dropped beneath threshold
            cyc_n = cyc_n +1;
            cyc_i = true;
        end
    elseif cyc_i %below threshold (currently discharged)
        if S(i) > Smax*1000*0.9 %rose above 90% 
            cyc_i = false;
        end
    end
    
end

