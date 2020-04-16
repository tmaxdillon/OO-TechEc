function [s1,s2,s3,s4,s5,s6,s7,s8,s9] = doNinePanel()

n = 10;
f = 2;

optInputs %load inputs
uc = uc(c);
opt.S = length(opt.tuning_array);
if pm == 1 %wind
    tp{1} = 'mzm'; %marinization multiplier
    ta(1,:) = linspace(econ.wind.marinization/f, ...
        econ.wind.marinization*f,n);
    tp{2} = 'sbm'; %spar buoyancy multiplier
    ta(2,:) = linspace(turb.spar_bm/f,turb.spar_bm*f,n);
    tp{3} = 'tiv'; %turbine interventions
    ta(3,:) = linspace(uc.turb.lambda/f,uc.turb.lambda*f,n);
    tp{4} = 'twf'; %turbine weight factor
    ta(4,:) = linspace(turb.wf/f,turb.wf*f,n);
end
tp{5} = 'ild'; %instrumentation load
ta(5,:) = linspace(uc.draw/f,uc.draw*f,n);
tp{6} = 'osv'; %osv cost
ta(6,:) = linspace(econ.vessel.osvcost/f,econ.vessel.osvcost*f,n);
tp{7} = 'nbl'; %nominal battery life-cycle
ta(7,:) = linspace(batt.lc_nom/f,batt.lc_nom*f,n);
tp{8} = 'sdr'; %battery self discharge rate
ta(8,:) = linspace(batt.sdr/f,batt.sdr*f,n);
tp{9} = 'utp'; %uptime percent
ta(9,:) = linspace(.80,1,n);

s1 = doSens(ta(1,:),tp{1});
s2 = doSens(ta(2,:),tp{2});
s3 = doSens(ta(3,:),tp{3});
s4 = doSens(ta(4,:),tp{4});
s5 = doSens(ta(5,:),tp{5});
s6 = doSens(ta(6,:),tp{6});
s7 = doSens(ta(7,:),tp{7});
s8 = doSens(ta(8,:),tp{8});
s9 = doSens(ta(9,:),tp{9});

end

