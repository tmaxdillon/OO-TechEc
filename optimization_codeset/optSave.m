function [] = optSave(name)

clearvars -except name
optScript

if exist('multStruct','var')
    stru.(name) = multStruct;
    save([name '.mat'], '-struct','stru','-v7.3')
else
    stru.(name) = allLocUses;
    save([name '.mat'], '-struct','stru','-v7.3')
end

end

