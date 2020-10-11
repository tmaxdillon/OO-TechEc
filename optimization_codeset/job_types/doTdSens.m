function [multStruct] = doTdSens(batchtype,batchscen,batchloc,batchc)
tTot = tic;
optInputs %load inputs
data = load(loc,loc);
data = data.(loc);
opt.S1 = length(opt.tdsens_ta(1,:));
opt.S2 = length(opt.tdsens_ta(2,:));
%initalize outputs
clear multStruct
multStruct(opt.S1,opt.S2) = struct();
for i = 1:opt.S1
    opt.s1 = i;
    for j = 1:opt.S2
        opt.s2 = j;
        %additional battery maintenance/installation time analysis
        if isequal(opt.tdsens_tp{1},'btm') && ...
                isequal(opt.tdsens_tp{2},'mbt')
            batt.t_add_m = opt.tdsens_ta(1,i);
            batt.t_add_min = opt.tdsens_ta(2,j);
        end
        %rated power conditions
        if isequal(opt.tdsens_tp{1},'hra') && ...
                isequal(opt.tdsens_tp{2},'tra')
            wave.Hs_ra = opt.tdsens_ta(1,i);
            wave.Tp_ra = opt.tdsens_ta(2,j);
        end
        disp(['Optimization ' num2str(opt.s1) ' by ' num2str(opt.s2) ...
            ' out of ' num2str(opt.S1) ' by ' num2str(opt.S2)  ...
            ' beginning after ' num2str(round(toc(tTot),2)) ...
            ' seconds. ' newline opt.tdsens_tp{1} ' tuned to ' ...
            num2str(opt.tdsens_ta(1,opt.s1)) ' and ' ...
            opt.tdsens_tp{2} ' tuned to ' ...
            num2str(opt.tdsens_ta(2,opt.s2)) '.'])
        [multStruct(i,j).output,multStruct(i,j).opt] =  ...
            optRun(pm,opt,data,atmo,batt,econ,uc(c),bc, ...
            inso,turb,wave,dies);
        multStruct(i,j).data = data;
        multStruct(i,j).atmo = atmo;
        multStruct(i,j).batt = batt;
        multStruct(i,j).econ = econ;
        multStruct(i,j).uc = uc(c);
        multStruct(i,j).pm = pm;
        multStruct(i,j).c = c;
        multStruct(i,j).loc = loc;
        if pm == 1
            multStruct(i,j).turb = turb;
        elseif pm == 2
            multStruct(i,j).inso = inso;
        elseif pm == 3
            multStruct(i,j).wave = wave;
        elseif pm == 4
            multStruct(i,j).dies = dies;
        end
    end
end
disp([num2str(opt.s1*opt.s2) ' simulations complete after ' ...
    num2str(round(toc(tTot)/60,2)) ' minutes. '])
end

