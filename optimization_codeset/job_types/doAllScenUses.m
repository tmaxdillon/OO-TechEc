function [allScenUses] = doAllScenUses(batchtype,scen,loc,c)
tTot = tic;
optInputs %load inputs
if bc == 1 %agm chemistry
    batt = agm;
elseif bc == 2 %lfp chemistry
    batt = lfp;
end
data = load(loc,loc);
data = data.(loc);
%initialize outputs
allScenUses(econ.wave.scenarios,length(opt.usecases)) = struct();
for scen_n = 1:econ.wave.scenarios
    econ.wave.scen = scen_n;
    for c = 1:length(opt.usecases)
        disp(['Optimization with ' char(opt.wavescens(scen_n)) ...
            ' scenario for ' char(opt.usecases(c))  ...
            ' application beginning after ' ...
            num2str(round(toc(tTot),2)) ' seconds.'])
        [allScenUses(scen_n,c).output, ...
            allScenUses(scen_n,c).opt] = ...
            optRun(pm,opt,data,atmo,batt,econ,uc(c),bc, ...
            inso,turb,wave,dies);
        allScenUses(scen_n,c).data = data;
        allScenUses(scen_n,c).atmo = atmo;
        allScenUses(scen_n,c).batt = batt;
        allScenUses(scen_n,c).econ = econ;
        allScenUses(scen_n,c).uc = uc(c);
        allScenUses(scen_n,c).pm = pm;
        allScenUses(scen_n,c).c = c;
        allScenUses(scen_n,c).loc = string(opt.locations(scen_n));
        if pm == 1
            allScenUses(scen_n,c).turb = turb;
        elseif pm == 2
            allScenUses(scen_n,c).inso = inso;
        elseif pm == 3
            allScenUses(scen_n,c).wave = wave;
        elseif pm == 4
            allScenUses(scen_n,c).dies = dies;
        end
        disp(['Optimization with ' char(opt.wavescens(scen_n)) ...
            ' scenario for ' char(opt.usecases(c))  ...
            ' application complete after ' ...
            num2str(round(toc(tTot),2)) ' seconds.'])
    end
end
end

