function [tiv,tcm,twf,cis,rsp,cos,szo,pmm, ...
    lft,dtc,osv,spv,tmt,eol,dep,bcc,bhc,utp,ild,sdr,s0] ...
    = doSensSM1(batchtype,batchpm,batchscen,batchloc,batchc)

n = 10; %sensitivity discretization
rsv = 8; %resource specific variables

tTot = tic;
optInputs %load inputs
disp(['Sensitivity small multiple beginning. n = ' num2str(n) ...
    ', location: ' batchloc ', use case: ' char(opt.usecases(batchc)) ...
    ', resource: ' char(opt.powermodules(batchpm)) ', scenario: ' ...
    char(opt.scens(batchscen))])
uc = uc(c);
opt.S = n; %for command window notification

tp{1} = 'tiv'; %turbine interventions
ta(1,:) = linspace(0,2.25,n);
tp{2} = 'tcm'; %turbine cost multiplier
ta(2,:) = linspace(0.1,1.9,n);
tp{3} = 'twf'; %turbine weight factor
ta(3,:) = linspace(20,110,n);
tp{4} = 'cis'; %cut in speed
ta(4,:) = linspace(0,6.75,n);
tp{5} = 'rsp'; %rated speed
ta(5,:) = linspace(8,14.75,n);
tp{6} = 'cos'; %cut out speed
ta(6,:) = linspace(16,34,n);
% tp{7} = 'tef'; %turbine efficiency
% ta(7,:) = linspace(0.25,.475,n);
tp{7} = 'szo'; %surface roughness
%ta(7,:) = linspace(0.005,0.05,n);
ta(7,:) = linspace(0.05,0.5,n);
tp{8} = 'pmm'; %platform material multiplier
ta(8,:) = linspace(3,12,n);

tp{rsv+1} = 'lft'; %lifetime [years]
ta(rsv+1,:) = linspace(1,10,n);
tp{rsv+2} = 'dtc'; %distance to coast [km]
ta(rsv+2,:) = linspace(10,1400,n);
tp{rsv+3} = 'osv'; %offshore suppport vessel cost [$/day]
ta(rsv+3,:) = linspace(250,42750,n);
tp{rsv+4} = 'spv'; %specialized vessel cost [$/day]
ta(rsv+4,:) = linspace(7500,97500,n);
tp{rsv+5} = 'tmt'; %time spent on site for power system maintenance [h]
ta(rsv+5,:) = linspace(1,12,n);
tp{rsv+6} = 'eol'; %battery end of life [percent as decimal]
ta(rsv+6,:) = linspace(.05,27.5,n);
tp{rsv+7} = 'dep'; %water depth [m]
ta(rsv+7,:) = linspace(120,5500,n);
tp{rsv+8} = 'bcc'; %battery cell cost [$/kWh]
ta(rsv+8,:) = linspace(66,786,n);
tp{rsv+9} = 'bhc'; %battery housing cost (multiplier)
ta(rsv+9,:) = linspace(0.25,2.5,n);
tp{rsv+10} = 'utp'; %uptime percent [percent as decimal]
ta(rsv+10,:) = linspace(0.8,1,n);
tp{rsv+11} = 'ild'; %instrumentation load [W]
ta(rsv+11,:) = linspace(100,400,n);
tp{rsv+12} = 'sdr'; %self-discharge rate of battery [%/month]
ta(rsv+12,:) = linspace(0,15,n);
  
tiv = doSens(ta(1,:),tp{1},batchtype,batchpm,batchscen,batchloc,batchc);
tcm = doSens(ta(2,:),tp{2},batchtype,batchpm,batchscen,batchloc,batchc);
twf = doSens(ta(3,:),tp{3},batchtype,batchpm,batchscen,batchloc,batchc);
cis = doSens(ta(4,:),tp{4},batchtype,batchpm,batchscen,batchloc,batchc);
rsp = doSens(ta(5,:),tp{5},batchtype,batchpm,batchscen,batchloc,batchc);
cos = doSens(ta(6,:),tp{6},batchtype,batchpm,batchscen,batchloc,batchc);
%tef = doSens(ta(7,:),tp{7},batchtype,batchpm,batchscen,batchloc,batchc);
szo = doSens(ta(7,:),tp{7},batchtype,batchpm,batchscen,batchloc,batchc);
pmm = doSens(ta(8,:),tp{8},batchtype,batchpm,batchscen,batchloc,batchc);

lft = doSens(ta(1+rsv,:),tp{1+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
dtc = doSens(ta(2+rsv,:),tp{2+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
osv = doSens(ta(3+rsv,:),tp{3+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
spv = doSens(ta(4+rsv,:),tp{4+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
tmt = doSens(ta(5+rsv,:),tp{5+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
eol = doSens(ta(6+rsv,:),tp{6+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
dep = doSens(ta(7+rsv,:),tp{7+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
bcc = doSens(ta(8+rsv,:),tp{8+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
bhc = doSens(ta(9+rsv,:),tp{9+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
utp = doSens(ta(10+rsv,:),tp{10+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
ild = doSens(ta(11+rsv,:),tp{11+rsv},batchtype,batchpm,batchscen,batchloc,batchc);
sdr = doSens(ta(12+rsv,:),tp{12+rsv},batchtype,batchpm,batchscen,batchloc,batchc);

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

