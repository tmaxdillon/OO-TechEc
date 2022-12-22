clearvars -except wiod_ssm wico_ssm inau_ssm inhu_ssm wcon_ssm ...
    woco_ssm wodu_ssm dgen_ssm
path = '~/Dropbox (MREL)/MATLAB/OO-TechEc/output_data/oossm_out/';
ucs = {'st','lt'};

%preallocate - don't think this buys me much here? ins't correct anyway
% wiod(3,2) = struct();
% wico(3,2) = struct();
% inhu(3,2) = struct();
% inau(3,2) = struct();
% woco(3,2) = struct();
% wcon(3,2) = struct();
% wodu(3,2) = struct();
% dgen(3,2) = struct();

%load data - takes a while
if ~exist('wiod','var') && ~exist('wico','var') && ...
        ~exist('inhu','var') && ~exist('inau','var') && ...
        ~exist('woco','var') && ~exist('wcon','var') && ...
        ~exist('wodu','var') && ~exist('dgen','var')
    tt = tic;
    for l = 1:3
        for uc = 1:2
            disp(['Loading l = ' num2str(l) ' & uc = ' char(ucs(uc)) ...
                ' after ' num2str(toc(tt)/60,2) ' minutes.'])
            wiod_ssm(l,uc) = load([path 'wiod_' ucs{uc} '_' num2str(l)]);
            disp(['      wiod loaded after ' num2str(toc(tt)/60,2) ' mins...'])
            wico_ssm(l,uc) = load([path 'wico_' ucs{uc} '_' num2str(l)]);
            disp(['      wico loaded after ' num2str(toc(tt)/60,2) ' mins...'])
            inhu_ssm(l,uc) = load([path 'inhu_' ucs{uc} '_' num2str(l)]);
            disp(['      inhu loaded after ' num2str(toc(tt)/60,2) ' mins...'])
            inau_ssm(l,uc) = load([path 'inau_' ucs{uc} '_' num2str(l)]);
            disp(['      inau loaded after ' num2str(toc(tt)/60,2) ' mins...'])
            woco_ssm(l,uc) = load([path 'woco_' ucs{uc} '_' num2str(l)]);
            disp(['      woco loaded after ' num2str(toc(tt)/60,2) ' mins...'])
            wcon_ssm(l,uc) = load([path 'wcon_' ucs{uc} '_' num2str(l)]);
            disp(['      wcon loaded after ' num2str(toc(tt)/60,2) ' mins...'])
            wodu_ssm(l,uc) = load([path 'wodu_' ucs{uc} '_' num2str(l)]);
            disp(['      wodu loaded after ' num2str(toc(tt)/60,2) ' mins...'])
            dgen_ssm(l,uc) = load([path 'dgen_' ucs{uc} '_' num2str(l)]);
            disp(['      dgen loaded after ' num2str(toc(tt)/60,2) ' mins...'])
        end
    end
end

wiod_ssm = wiod;
wico_ssm = wico;
inau_ssm = inau;
inhu_ssm = inhu;
wcon_ssm = wcon;
woco_ssm = woco;
wodu_ssm = wodu;
dgen_ssm = dgen;



%wind
visOoSsmOut('tiv','wiod',wiod)
visOoSsmOut('tiv','wico',wico)
visOoSsmOut('tcm','wiod',wiod)
visOoSsmOut('tcm','wico',wico)
visOoSsmOut('twf','wiod',wiod)
visOoSsmOut('twf','wico',wico)
visOoSsmOut('cis','wiod',wiod)
visOoSsmOut('cis','wico',wico)
visOoSsmOut('rsp','wiod',wiod)
visOoSsmOut('rsp','wico',wico)
visOoSsmOut('cos','wiod',wiod)
visOoSsmOut('cos','wico',wico)
visOoSsmOut('tef','wiod',wiod)
visOoSsmOut('tef','wico',wico)
visOoSsmOut('szo','wiod',wiod)
visOoSsmOut('szo','wico',wico)
visOoSsmOut('lft','wiod',wiod)
visOoSsmOut('lft','wico',wico)
visOoSsmOut('dtc','wiod',wiod)
visOoSsmOut('dtc','wico',wico)
visOoSsmOut('osv','wiod',wiod)
visOoSsmOut('osv','wico',wico)
visOoSsmOut('spv','wiod',wiod)
visOoSsmOut('spv','wico',wico)
visOoSsmOut('tmt','wiod',wiod)
visOoSsmOut('tmt','wico',wico)
visOoSsmOut('eol','wiod',wiod)
visOoSsmOut('eol','wico',wico)
visOoSsmOut('dep','wiod',wiod)
visOoSsmOut('dep','wico',wico)
visOoSsmOut('bcc','wiod',wiod)
visOoSsmOut('bcc','wico',wico)
visOoSsmOut('bhc','wiod',wiod)
visOoSsmOut('bhc','wico',wico)
visOoSsmOut('utp','wiod',wiod)
visOoSsmOut('utp','wico',wico)
visOoSsmOut('ild','wiod',wiod)
visOoSsmOut('ild','wico',wico)
visOoSsmOut('sdr','wiod',wiod)
visOoSsmOut('sdr','wico',wico)
%inso
visOoSsmOut('pvd','inau',inau)
visOoSsmOut('pvd','inhu',inhu)
visOoSsmOut('pcm','inau',inau)
visOoSsmOut('pcm','inhu',inhu)
visOoSsmOut('pwf','inau',inau)
visOoSsmOut('pwf','inhu',inhu)
visOoSsmOut('pve','inau',inau)
visOoSsmOut('pve','inhu',inhu)
visOoSsmOut('lft','inau',inau)
visOoSsmOut('lft','inhu',inhu)
visOoSsmOut('dtc','inau',inau)
visOoSsmOut('dtc','inhu',inhu)
visOoSsmOut('osv','inau',inau)
visOoSsmOut('osv','inhu',inhu)
visOoSsmOut('spv','inau',inau)
visOoSsmOut('spv','inhu',inhu)
visOoSsmOut('tmt','inau',inau)
visOoSsmOut('tmt','inhu',inhu)
visOoSsmOut('eol','inau',inau)
visOoSsmOut('eol','inhu',inhu)
visOoSsmOut('dep','inau',inau)
visOoSsmOut('dep','inhu',inhu)
visOoSsmOut('bcc','inau',inau)
visOoSsmOut('bcc','inhu',inhu)
visOoSsmOut('bhc','inau',inau)
visOoSsmOut('bhc','inhu',inhu)
visOoSsmOut('utp','inau',inau)
visOoSsmOut('utp','inhu',inhu)
visOoSsmOut('ild','inau',inau)
visOoSsmOut('ild','inhu',inhu)
visOoSsmOut('sdr','inau',inau)
visOoSsmOut('sdr','inhu',inhu)
%wave
visOoSsmOut('wiv','wcon',wcon)
visOoSsmOut('wiv','woco',woco)
visOoSsmOut('wiv','wodu',wodu)
visOoSsmOut('wcm','wcon',wcon)
visOoSsmOut('wcm','woco',woco)
visOoSsmOut('wcm','wodu',wodu)
visOoSsmOut('whl','wcon',wcon)
visOoSsmOut('whl','woco',woco)
visOoSsmOut('whl','wodu',wodu)
visOoSsmOut('ect','wcon',wcon)
visOoSsmOut('ect','woco',woco)
visOoSsmOut('ect','wodu',wodu)
visOoSsmOut('lft','wcon',wcon)
visOoSsmOut('lft','woco',woco)
visOoSsmOut('lft','wodu',wodu)
visOoSsmOut('dtc','wcon',wcon)
visOoSsmOut('dtc','woco',woco)
visOoSsmOut('dtc','wodu',wodu)
visOoSsmOut('osv','wcon',wcon)
visOoSsmOut('osv','woco',woco)
visOoSsmOut('osv','wodu',wodu)
visOoSsmOut('spv','wcon',wcon)
visOoSsmOut('spv','woco',woco)
visOoSsmOut('spv','wodu',wodu)
visOoSsmOut('tmt','wcon',wcon)
visOoSsmOut('tmt','woco',woco)
visOoSsmOut('tmt','wodu',wodu)
visOoSsmOut('eol','wcon',wcon)
visOoSsmOut('eol','woco',woco)
visOoSsmOut('eol','wodu',wodu)
visOoSsmOut('dep','wcon',wcon)
visOoSsmOut('dep','woco',woco)
visOoSsmOut('dep','wodu',wodu)
visOoSsmOut('bcc','wcon',wcon)
visOoSsmOut('bcc','woco',woco)
visOoSsmOut('bcc','wodu',wodu)
visOoSsmOut('bhc','wcon',wcon)
visOoSsmOut('bhc','woco',woco)
visOoSsmOut('bhc','wodu',wodu)
visOoSsmOut('utp','wcon',wcon)
visOoSsmOut('utp','woco',woco)
visOoSsmOut('utp','wodu',wodu)
visOoSsmOut('ild','wcon',wcon)
visOoSsmOut('ild','woco',woco)
visOoSsmOut('ild','wodu',wodu)
visOoSsmOut('sdr','wcon',wcon)
visOoSsmOut('sdr','woco',woco)
visOoSsmOut('sdr','wodu',wodu)
%dgen
visOoSsmOut('giv','dgen',dgen)
visOoSsmOut('fco','dgen',dgen)
visOoSsmOut('fca','dgen',dgen)
visOoSsmOut('fsl','dgen',dgen)
visOoSsmOut('oci','dgen',dgen)
visOoSsmOut('gcm','dgen',dgen)
visOoSsmOut('lft','dgen',dgen)
visOoSsmOut('dtc','dgen',dgen)
visOoSsmOut('osv','dgen',dgen)
visOoSsmOut('spv','dgen',dgen)
visOoSsmOut('tmt','dgen',dgen)
visOoSsmOut('eol','dgen',dgen)
visOoSsmOut('dep','dgen',dgen)
visOoSsmOut('bcc','dgen',dgen)
visOoSsmOut('bhc','dgen',dgen)
visOoSsmOut('utp','dgen',dgen)
visOoSsmOut('ild','dgen',dgen)
visOoSsmOut('sdr','dgen',dgen)





