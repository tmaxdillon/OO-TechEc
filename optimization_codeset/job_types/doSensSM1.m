function [tiv,tcm,twf,cis,rsp,cos,tef,szo, ...
    lft,dtc,osv,spv,tmt,eol,dep,bcc,bhc,utp,ild,sdr,s0] ...
    = doSensSM1(batchtype,batchpm,batchscen,batchloc,batchc)

n = 10; %sensitivity discretization

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
ta(2,:) = linspace(0.1,1.225,n);
tp{3} = 'twf'; %turbine weight factor
ta(3,:) = linspace(20,110,n);
tp{4} = 'cis'; %cut in speed
ta(4,:) = linspace(0,6.75,n);
tp{5} = 'rsp'; %rated speed
ta(5,:) = linspace(8,14.75,n);
tp{6} = 'cos'; %cut out speed
ta(6,:) = linspace(22,40,n);
tp{7} = 'tef'; %turbine efficiency
ta(7,:) = linspace(0.25,.475,n);
tp{8} = 'szo'; %surface roughness
ta(8,:) = linspace(0.005,0.02,n);

tp{9} = 'lft'; %lifetime [years]
ta(9,:) = linspace(1,10,n);
tp{10} = 'dtc'; %distance to coast [km]
ta(10,:) = linspace(10,1400,n);
tp{11} = 'osv'; %offshore suppport vessel cost [$/day]
ta(11,:) = linspace(2500,40000,n);
tp{12} = 'spv'; %specialized vessel cost [$/day]
ta(12,:) = linspace(35000,150000,n);
tp{13} = 'tmt'; %time spent on site for power system maintenance [h]
ta(13,:) = linspace(1,12,n);
tp{14} = 'eol'; %battery end of life [percent as decimal]
ta(14,:) = linspace(.05,27.5,n);
tp{15} = 'dep'; %water depth [m]
ta(15,:) = linspace(120,5500,n);
tp{16} = 'bcc'; %battery cell cost [$/kWh]
ta(16,:) = linspace(40,850,n);
tp{17} = 'bhc'; %battery housing cost (multiplier)
ta(17,:) = linspace(0.25,2.5,n);
tp{18} = 'utp'; %uptime percent [percent as decimal]
ta(18,:) = linspace(0.8,1,n);
tp{19} = 'ild'; %instrumentation load [W]
ta(19,:) = linspace(100,400,n);
tp{20} = 'sdr'; %self-discharge rate of battery [%/month]
ta(20,:) = linspace(0,15,n);
    
tiv = doSens(ta(1,:),tp{1},batchtype,batchpm,batchscen,batchloc,batchc);
tcm = doSens(ta(2,:),tp{2},batchtype,batchpm,batchscen,batchloc,batchc);
twf = doSens(ta(3,:),tp{3},batchtype,batchpm,batchscen,batchloc,batchc);
cis = doSens(ta(4,:),tp{4},batchtype,batchpm,batchscen,batchloc,batchc);
rsp = doSens(ta(5,:),tp{5},batchtype,batchpm,batchscen,batchloc,batchc);
cos = doSens(ta(6,:),tp{6},batchtype,batchpm,batchscen,batchloc,batchc);
tef = doSens(ta(7,:),tp{7},batchtype,batchpm,batchscen,batchloc,batchc);
szo = doSens(ta(8,:),tp{8},batchtype,batchpm,batchscen,batchloc,batchc);

lft = doSens(ta(9,:),tp{9},batchtype,batchpm,batchscen,batchloc,batchc);
dtc = doSens(ta(10,:),tp{10},batchtype,batchpm,batchscen,batchloc,batchc);
osv = doSens(ta(11,:),tp{11},batchtype,batchpm,batchscen,batchloc,batchc);
spv = doSens(ta(12,:),tp{12},batchtype,batchpm,batchscen,batchloc,batchc);
tmt = doSens(ta(13,:),tp{13},batchtype,batchpm,batchscen,batchloc,batchc);
eol = doSens(ta(14,:),tp{14},batchtype,batchpm,batchscen,batchloc,batchc);
dep = doSens(ta(15,:),tp{15},batchtype,batchpm,batchscen,batchloc,batchc);
bcc = doSens(ta(16,:),tp{16},batchtype,batchpm,batchscen,batchloc,batchc);
bhc = doSens(ta(17,:),tp{17},batchtype,batchpm,batchscen,batchloc,batchc);
utp = doSens(ta(18,:),tp{18},batchtype,batchpm,batchscen,batchloc,batchc);
ild = doSens(ta(19,:),tp{19},batchtype,batchpm,batchscen,batchloc,batchc);
sdr = doSens(ta(20,:),tp{20},batchtype,batchpm,batchscen,batchloc,batchc);

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

