ucs = {'st','lt'};
path = '~/Dropbox (MREL)/MATLAB/OO-TechEc/output_data/tests/';

for uc = 1:1
    for i = 1:1
        optSave(path,['wiodt_' char(ucs(uc))],'ssm',1,1,i,uc)
        optSave(path,['wicot_' char(ucs(uc))],'ssm',1,2,i,uc)
        optSave(path,['inaut_' char(ucs(uc))],'ssm',2,1,i,uc)
        optSave(path,['inhut_' char(ucs(uc))],'ssm',2,2,i,uc)
        optSave(path,['wcont_' char(ucs(uc))],'ssm',3,1,i,uc)
        optSave(path,['wocot_' char(ucs(uc))],'ssm',3,2,i,uc)
        optSave(path,['wodut_' char(ucs(uc))],'ssm',3,3,i,uc)
        optSave(path,['dgent_' char(ucs(uc))],'ssm',4,1,i,uc)
    end
end