function [s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s0] = doSensSM()

n = 10;
f = 2;

disp('Sensitivity small multiple beginning.')
tTot = tic;
optInputs %load inputs
uc = uc(c);
opt.S = length(opt.tuning_array); %for command window notification
if pm == 1 %wind
    nps = 4;
    tp{1} = 'mzm'; %marinization multiplier
    ta(1,:) = linspace(econ.wind.marinization/f, ...
        econ.wind.marinization*f,n);
    tp{2} = 'sbm'; %spar buoyancy multiplier
    ta(2,:) = linspace(turb.spar_bm/f,turb.spar_bm*f,n);
    tp{3} = 'tiv'; %turbine interventions
    ta(3,:) = linspace(uc.turb.lambda/f,uc.turb.lambda*f,n);
    tp{4} = 'twf'; %turbine weight factor
    ta(4,:) = linspace(turb.wf/f,turb.wf*f,n);
elseif pm == 3 %wave
    nps = 4;
    tp{1} = 'cwm'; %capture width multiplier
    ta(1,:) = linspace(1/f,f,n);
    tp{2} = 'wiv'; %wec interventions
    ta(2,:) = 0:1:9;
    tp{3} = 'wcm'; %wec cost multiplier
    ta(3,:) = 1:1:10;
    tp{4} = 'whl'; %wec hotel load
    ta(4,:) = 0:.02:.18;
end
tp{nps+1} = 'ild'; %instrumentation load
ta(nps+1,:) = linspace(uc.draw/f,uc.draw*f,n);
tp{nps+2} = 'osv'; %osv cost
ta(nps+2,:) = linspace(econ.vessel.osvcost/f,econ.vessel.osvcost*f,n);
tp{nps+3} = 'nbl'; %nominal battery life-cycle
ta(nps+3,:) = linspace(batt.lc_nom/f,batt.lc_nom*f,n);
tp{nps+4} = 'sdr'; %battery self discharge rate
ta(nps+4,:) = linspace(batt.sdr/f,batt.sdr*f,n);
tp{nps+5} = 'utp'; %uptime percent
ta(nps+5,:) = linspace(.80,1,n);
tp{nps+6} = 'bhc'; %battery housing cost
ta(nps+6,:) = linspace(econ.batt.enclmult/f,econ.batt.enclmult*f,n);
tp{nps+7} = 'dep'; %depth modifier
ta(nps+7,:) = linspace(1/f,f,n);
tp{nps+8} = 'dtc'; %battery housing cost
ta(nps+8,:) = linspace(1/f,f,n);

if pm == 3
    s1 = doSens(ta(1,:),tp{1});
    s2 = doSens(ta(2,:),tp{2});
    s3 = doSens(ta(3,:),tp{3});
    s4 = doSens(ta(4,:),tp{4});
    s5 = doSens(ta(5,:),tp{5});
    s6 = doSens(ta(6,:),tp{6});
    s7 = doSens(ta(7,:),tp{7});
    s8 = doSens(ta(8,:),tp{8});
    s9 = doSens(ta(9,:),tp{9});
    s10 = doSens(ta(10,:),tp{10});
    s11 = doSens(ta(11,:),tp{11});
    s12 = doSens(ta(12,:),tp{12});
end

%get S0, default results
optInputs %load inputs
data = load(loc,loc);
data = data.(loc);
[output,opt] = ...
    optRun(pm,opt,data,atmo,batt,econ,uc(c),bc,inso,turb,wave,dies);
s0.output = output;
s0.opt = opt;
s0.data = data;
s0.atmo = atmo;
s0.batt = batt;
s0.econ = econ;
s0.uc = uc(c);
s0.pm = pm;
s0.c = c;
s0.loc = loc;
if pm == 1
    s0.turb = turb;
elseif pm == 2
    s0.inso = inso;
elseif pm == 3
    s0.wave = wave;
elseif pm == 4
    s0.dies = dies;
end

disp(['Sensitivity small multiple complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes.'])

end

