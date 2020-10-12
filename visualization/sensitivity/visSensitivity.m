function [] = visSensitivity(multStruct)

%x axis title
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    xlab = 'Percent Uptime';
    xt = fliplr(multStruct(1).opt.tuning_array);
elseif isequal(multStruct(1).opt.tuned_parameter,'ild')
    xlab = 'Load [W]';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'bgd')
    xlab = 'Input Mesh Size: Smax Axis Extent [days of battery storage]';
    xt = min(multStruct(1).opt.tuning_array):3: ...
        max(multStruct(1).opt.tuning_array);
elseif isequal(multStruct(1).opt.tuned_parameter,'mxn')
    xlab = '1D Mesh Resolution';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'zo')
    xlab = 'Surface Roughness';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'mtbf')
    if multStruct(1).c == 3
        xlab = 'Mean Time Between Failure of Wind Turbine [years]';
        xt = multStruct(1).opt.tuning_array./12;
        xscale = 1/12;
        yscale = 1/1000;
        ylab = 'Cost in Millions';
    else
        xlab = 'Mean Time Between Failure of Wind Turbine [months]';
        xt = multStruct(1).opt.tuning_array;
    end
elseif isequal(multStruct(1).opt.tuned_parameter,'psr')
    xlab = 'Panel Soil Rate [%/year]';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'pvci')
    xlab = 'PV Cleaning Interval [months]';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'scm')
    xlab = 'Cleaning Month';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'utf')
    xlab = 'Number of Unexpected Failures';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'wcm')
    xlab = 'Wave Cost Multiplier (relative to wind $/kW)';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'wrp')
    xlab = 'Tp, Hs Percentile for Power Matrix Centroid';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'wcp')
    xlab = 'Tp, Hs Percentile for Power Matrix Cut Out';
    xt = fliplr(multStruct(1).opt.tuning_array);
elseif isequal(multStruct(1).opt.tuned_parameter,'whl')
    xlab = 'House Load [%]';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'imf')
    xlab = 'Marinization Multiplier';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'btm')
    xlab = 'Added time on site per kWh of Battery > 20 kWh';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'mbt')
    xlab = 'Minimum Battery Size for Added Time';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'dtc')
    xlab = 'Distance to Coast [km]';
    xt = multStruct(1).opt.tuning_array;
end

if ~exist('xscale','var')
    xscale = 1;
end
if multStruct(1).c == 3
    ylab = 'Cost in Millions';
    yscale = 1/1000;
end

if multStruct(1).pm == 1
    if multStruct(1).c == 3
        visWindSens(multStruct,xlab,xt,xscale,ylab,yscale)
    else 
        visWindSens(multStruct,xlab,xt)
    end
elseif multStruct(1).pm == 2
    if ~exist('ylab','var'), ylab = 'cost in thousands'; end
    if ~exist('yscale','var'), yscale = 1; end
    visInsoSens(multStruct,xlab,xt,xscale,ylab,yscale)
elseif multStruct(1).pm == 3 %wave
    if ~exist('ylab','var'), ylab = 'cost in thousands'; end
    if ~exist('yscale','var'), yscale = 1; end
    visWaveSens(multStruct,xlab,xt,xscale,ylab,yscale)
end

end



