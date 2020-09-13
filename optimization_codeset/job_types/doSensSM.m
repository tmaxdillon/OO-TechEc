function [s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s0] = ...
    doSensSM()

n = 10; %sensitivity discretization
f = 2; %factor

disp(['Sensitivity small multiple beginning. n = ' num2str(n) ])
tTot = tic;
optInputs %load inputs
uc = uc(c);
opt.S = n; %for command window notification
if pm == 1 %wind
    nps = 4; %number of power-specific parameters
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
    nps = 4; %number of power-specific parameters
    tp{1} = 'cwm'; %capture width multiplier [WEC]
    ta(1,:) = linspace(1/f,f,n);
    tp{2} = 'wiv'; %wec interventions [WEC]
    ta(2,:) = linspace(0,9,n);
    tp{3} = 'wcm'; %wec cost multiplier [WEC]
    ta(3,:) = linspace(1,10,n);
    tp{4} = 'whl'; %wec hotel load [WEC]
    ta(4,:) = linspace(0,.18,n);
end
tp{nps+1} = 'ild'; %instrumentation load [INST]
ta(nps+1,:) = linspace(uc.draw/f,uc.draw*f,n);
tp{nps+2} = 'osv'; %osv cost [OPEX]
ta(nps+2,:) = linspace(econ.vessel.osvcost/f,econ.vessel.osvcost*f,n);
tp{nps+3} = 'nbl'; %nominal battery life-cycle [BATT]
ta(nps+3,:) = linspace(batt.lc_nom/f,batt.lc_nom*f,n);
tp{nps+4} = 'sdr'; %battery self discharge rate [BATT]
ta(nps+4,:) = linspace(batt.sdr/f,batt.sdr*f,n);
tp{nps+5} = 'utp'; %uptime percent [INST]
ta(nps+5,:) = linspace(.80,1,n);
tp{nps+6} = 'bhc'; %battery housing cost [BATT]
ta(nps+6,:) = linspace(econ.batt.enclmult/f,econ.batt.enclmult*f,n);
tp{nps+7} = 'dep'; %depth modifier [INST]
ta(nps+7,:) = linspace(200,5500,n); %watch MDD bounds!
tp{nps+8} = 'dtc'; %distance to coast [OPEX]
ta(nps+8,:) = linspace(200,2000,n)*1000;
tp{nps+9} = 'mbl'; %maximum battery life-cycle [BATT]
ta(nps+9,:) = linspace(batt.lc_max*(2/5),batt.lc_max,n);
tp{nps+10} = 'lft'; %lifetime [INST]
ta(nps+10,:) = linspace(1,10,n);
tp{nps+11} = 'spv'; %specialized vessel cost [OPEX]
ta(nps+11,:) = linspace(econ.vessel.speccost/f,econ.vessel.speccost*f,n);
tp{nps+12} = 'tmt'; %time spent on site for maintenance [OPEX]
ta(nps+12,:) = linspace(1,24,n);

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
    s13 = doSens(ta(13,:),tp{13});
    s14 = doSens(ta(14,:),tp{14});
    s15 = doSens(ta(15,:),tp{15});
    s16 = doSens(ta(16,:),tp{16});
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

