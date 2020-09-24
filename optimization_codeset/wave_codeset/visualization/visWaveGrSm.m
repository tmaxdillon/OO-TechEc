function [output] = visWaveGrSm(Gr,Sm,data,i)

optInputs

%prep for simulation
opt = prepWave(data,opt,wave,atmo);
opt.p_dev.t = calcDeviceVal('turbine',[],econ.wind_n);
wave.cw_mod = 1; %capture width modifier
c = 1; %use case
scen = 1; %conservative
%set econ scenario
switch scen
    case 1 %conservative
        econ.wave.costmult = econ.wave.costmult_con; %cost multiplier
        econ.wave.lambda = econ.wave.highfail; %vessel interventions
    case 2 %optimistic cost
        econ.wave.costmult = econ.wave.costmult_opt; %cost multiplier
        econ.wave.lambda = econ.wave.highfail; %vessel interventions
    case 3 %optimistic durability
        econ.wave.costmult = econ.wave.costmult_con; %cost multiplier
        econ.wave.lambda = econ.wave.lowfail; %vessel interventions
end
opt.fmin = false;

%run simulation and store outputs
output.kW = Gr;
output.Smax = Sm;
[output.cost,output.surv,output.CapEx,output.OpEx,...
    output.kWcost,output.Scost,output.Icost, ...
    output.Pmtrl,output.Pinst, ...
    output.Pmooring,output.vesselcost, ...
    output.wecrepair,output.battreplace,output.battencl, ...
    output.triptime,output.nvi, ...
    output.dp,output.width,output.cw, ...
    output.S,output.P,output.D,output.L] ...
    = simWave(Gr,Sm,opt,data,atmo,batt,econ,uc(c),bc,wave);
output.batt_dyn_lc = batt.lc_nom*(output.Smax/ ...
    (output.Smax - (min(output.S)/1000)))^batt.beta;
output.CF = mean(output.P)/(1000*output.kW);
output.cw_avg = mean(output.cw); %average capture width
output.cwr_avg = mean(output.cw_avg/output.width); %average cwr
%cycles per year
output.cyc60 = countCycles(output.S,output.Smax,60)/ ...
    (length(data.wave.time)/8760);
output.cyc80 = countCycles(output.S,output.Smax,80)/ ...
    (length(data.wave.time)/8760);
output.cyc100 = countCycles(output.S,output.Smax,100)/ ...
    (length(data.wave.time)/8760);

%visualize
S.data = data;
S.output.min = output;
visWaveSim(S,i)
    

end

