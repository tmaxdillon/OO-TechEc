% varnames = {'\begin{tabular}[c]{@{}l@{}}Argentine \\ Basin\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}Coastal \\ Endurance\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}Irminger \\ Sea\end{tabular}'};
% rownames = { ...
%     'Mooring Elements' ...
%     'Mooring Installation' ...
%     'Battery Cells' ...
%     'Battery Housing' ...
%     'WEC Device' ...
%     'WEC Installation' ...
%     'Battery Replacements' ...
%     'WEC Refurbishments' ...
%     'Vessel Operations' ...
%     'Total'};

T = table('Size',[11 3],'VariableTypes',{'string','string','string'});

wstruct = dgen;

% load('waveoptd')
% load('waveoptc')
% load('wavecons')

%allStruct = mergeWaWaWa(wodu,woco,wavecons);

for u = 1:2
%     for s = 1:3
        for l = [1,2,4]
            %tc = wstruct(l,u).output.min.cost;
            c = wstruct(l,u).output.min.Pmooring;
            T(1,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.Pinst;
            T(2,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.Pmtrl;
            T(3,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']}; 
            c = wstruct(l,u).output.min.Scost;
            T(4,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.battencl;
            T(5,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.kWcost;
            T(6,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.genencl;
            T(7,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.fuel;
            T(8,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.battreplace;
            T(9,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.genrepair;
            T(10,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.vesselcost;
            T(11,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
            c = wstruct(l,u).output.min.cost;
            T(12,l) = {['\$' ...
                num2str(round(c/1000,1)) 'k']};
        end
        if u == 1
            T_st_optd = T;
            csvname = 'T_st_dgen';
        elseif u == 2
            T_lt_optd = T;
            csvname = 'T_lt_dgen';
        end
%         writetable(T,['~/Dropbox (MREL)/Research/OO-TechEc/wave-comparison/' ...
%             'paper_figures/' csvname '.csv'],'Delimiter',',','QuoteStrings',false, ...
%             'WriteVariableNames',false)
        writetable(T,['~/Documents/OO-TechEc/' ...
            'paper_figures/' csvname '.csv'],'Delimiter',',','QuoteStrings',false, ...
            'WriteVariableNames',false)
        %     end
end

clearvars -except T_lt_cons T_st_cons T_lt_optc T_st_optc ...
    T_lt_optd T_st_optd dgen


% writetable(T_st_optd,['~/Dropbox (MREL)/Research/OO-TechEc/paper_figures/' ...
%     'costtable_test.csv'],'Delimiter',',','QuoteStrings',false, ...
%     'WriteVariableNames',false)

% rownames = { ...
%     '\begin{tabular}[c]{@{}l@{}}Mooring \\ Elements\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}Mooring \\ Installation\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}Battery \\ Cells\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}Battery \\ Housing\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}WEC \\ Device\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}WEC \\ Installation\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}Battery \\ Replacements\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}WEC \\ Refurbishments\end{tabular}' ...
%     '\begin{tabular}[c]{@{}l@{}}Vessel \\ Operations\end{tabular}' ...
%     'Total'};
