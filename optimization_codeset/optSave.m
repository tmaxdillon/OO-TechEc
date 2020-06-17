function [] = optSave(prepath,name)

clearvars -except name prepath
optScript

if exist('s1','var') %save multiple structures
    if s1(1).pm == 1 %wind, needs update
        save([prepath name '.mat'],'s1','s2','s3','s4','s5','s6','s7', ...
            's8','s9')
    elseif s1(1).pm == 3 %wave
        save([prepath name '.mat'],'cwm','wiv','wcm','whl','ild','osv', ...
            'nbl','sdr','utp','bhc','dep','dtc','s0','-v7.3')
    end
else %save single structure
    if exist('multStruct','var')
        stru.(name) = multStruct;
    elseif exist('allLocUses','var')
        stru.(name) = allLocUses;
    else
        stru.(name) = optStruct;
    end
    save([prepath name '.mat'], '-struct','stru','-v7.3')
end

end

