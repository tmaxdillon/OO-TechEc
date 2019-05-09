function [] = visSensitivity(multStruct)

%x axis title
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    xlab = 'Percent Uptime';
    xt = fliplr(multStruct(1).opt.tuning_array);
elseif isequal(multStruct(1).opt.tuned_parameter,'load')
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
end
if multStruct(1).pm == 2
    if ~exist('ylab','var')
        ylab = 'cost in thousands';
    end
    if ~exist('yscale','var')
        yscale = 1;
    end
    visInsoSens(multStruct,xlab,xt,xscale,ylab,yscale)
end

end

