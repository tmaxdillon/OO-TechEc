function [allLocUses] = doAllLocUses()
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
allLocUses(length(opt.locations),length(opt.usecases)) = struct();
for loc_n = 1:length(opt.locations)
    data = load(string(opt.locations(loc_n)), ...
        string(opt.locations(loc_n)));
    data = data.(string(opt.locations(loc_n)));
    for c = 1:length(opt.usecases)
        disp(['Optimization at ' char(opt.locations(loc_n)) ...
            ' using ' char(opt.powermodules(pm)) ' for ' ...
            char(opt.usecases(c)) ' application beginning after ' ...
            num2str(round(toc(tTot),2)) ' seconds.'])
        [allLocUses(loc_n,c).output, ...
            allLocUses(loc_n,c).opt] = ...
            optRun(pm,opt,data,atmo,batt,econ,uc(c),bc, ...
            inso,turb,wave,dies);
        allLocUses(loc_n,c).data = data;
        allLocUses(loc_n,c).atmo = atmo;
        allLocUses(loc_n,c).batt = batt;
        allLocUses(loc_n,c).econ = econ;
        allLocUses(loc_n,c).uc = uc(c);
        allLocUses(loc_n,c).pm = pm;
        allLocUses(loc_n,c).c = c;
        allLocUses(loc_n,c).loc = string(opt.locations(loc_n));
        if pm == 1
            allLocUses(loc_n,c).turb = turb;
        elseif pm == 2
            allLocUses(loc_n,c).inso = inso;
        elseif pm == 3
            allLocUses(loc_n,c).wave = wave;
        elseif pm == 4
            allLocUses(loc_n,c).dies = dies;
        end
        disp(['Optimization at ' char(opt.locations(loc_n)) ...
            ' using ' char(opt.powermodules(pm)) ' for ' ...
            char(opt.usecases(c)) ' application complete after ' ...
            num2str(round(toc(tTot),2)) ' seconds.'])
    end
end
end

