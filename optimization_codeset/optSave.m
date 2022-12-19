function [] = optSave(prepath,name,batchtype,batchpm,batchscen, ...
    batchloc,batchc)

%clearvars -except name prepath batchtype scen loc c

%unpack ARRAY TASK ID into batchloc
if isequal(batchtype,'ssm') %ssm
    loc_id = batchloc;
    switch loc_id
        case 1
            batchloc = 'argBasin';
        case 2
            batchloc = 'cosEndurance_wa';
        case 3
            batchloc = 'irmSea';
    end
end
optScript

if isequal(batchtype,'ssm') %ssm
    if pm == 1
        save([prepath name '.mat'], ...
            'tiv','tcm','twf','cis','rsp','cos','tef','szo', ...
            'lft','dtc','osv','spv','tmt','eol','dep','bcc', ...
            'bhc','utp','ild','sdr','s0','-v7.3')
    elseif pm == 2
        save([prepath name '.mat'], ...
            'pvd','pcm','pwf','pve', ...
            'lft','dtc','osv','spv','tmt','eol','dep','bcc', ...
            'bhc','utp','ild','sdr','s0','-v7.3')
    elseif pm == 3 
        save([prepath name '.mat'], ...
            'wiv','wcm','whl','ect', ...
            'lft','dtc','osv','spv','tmt','eol','dep','bcc', ...
            'bhc','utp','ild','sdr','s0','-v7.3')
    elseif pm == 4
        save([prepath name '.mat'], ...
            'giv','fco','fca','fsl','oci','gcm', ...
            'lft','dtc','osv','spv','tmt','eol','dep','bcc', ...
            'bhc','utp','ild','sdr','s0','-v7.3')
    end
else %save single structure
    if exist('multStruct','var')
        stru.(name) = multStruct;
    elseif exist('allLocUses','var')
        stru.(name) = allLocUses;
    elseif exist('allScenUses','var')
        stru.(name) = allScenUses;
    else
        stru.(name) = optStruct;
    end
    save([prepath name '.mat'], '-struct','stru','-v7.3')
end

end

