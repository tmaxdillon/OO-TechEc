ucs = {'st','lt'};
uc = 2;

%for uc = 2
    for i = 1:3
        optSave('',['wiodt_' char(ucs(uc))],'ssm',1,1,i,uc)
        optSave('',['wicot_' char(ucs(uc))],'ssm',1,2,i,uc)
        optSave('',['inaut_' char(ucs(uc))],'ssm',2,1,i,uc)
        optSave('',['inhut_' char(ucs(uc))],'ssm',2,2,i,uc)
        optSave('',['wcont_' char(ucs(uc))],'ssm',3,1,i,uc)
        optSave('',['wocot_' char(ucs(uc))],'ssm',3,2,i,uc)
        optSave('',['wodut_' char(ucs(uc))],'ssm',3,3,i,uc)
        optSave('',['dgent_' char(ucs(uc))],'ssm',4,1,i,uc)
    end
%end