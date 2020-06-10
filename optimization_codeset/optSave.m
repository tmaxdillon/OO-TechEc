function [] = optSave(name)

clearvars -except name
optScript

if exist('multStruct','var')
    stru.(name) = multStruct;
elseif exist('allLocUses','var')
    stru.(name) = allLocUses;
else
    stru.(name) = optStruct;
end

save([name '.mat'], '-struct','stru','-v7.3')
end

