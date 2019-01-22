function [] = visOptTime(multStruct_s,multStruct_ns)

for i = 1:length(multStruct_s)
    time_ns(:,i) = [multStruct_ns(i).output.tInitOpt ;  ... 
        multStruct_ns(i).output.tFminOpt];
    time_s(:,i) = [multStruct_s(i).output.tInitOpt ; ...
        multStruct_s(i).output.tFminOpt];
    sqrtmn = sqrt(multStruct_ns(i).opt.tuning_array);
end

figure
ax(1) = subplot(2,1,1);
bar(sqrtmn,time_ns','stacked')
legend('Initial Optimization Runtime','Nelder-Mead Runtime', ...
    'location','north')
xlabel('sqrt(m*n)')
ylabel('[s]')
grid on
ax(2) = subplot(2,1,2);
bar(sqrtmn,time_s','stacked');
legend('Initial Optimization Runtine','Nelder-Mead Runtime', ... 
    'location','north')
xlabel('sqrt(m*n)')
ylabel('[s]')
grid on

linkaxes(ax,'xy')

end

