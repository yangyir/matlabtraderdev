%%
pathhome = getenv('HOME');
cd(pathhome);
%first to logoff and remove old variables
trading_logoff;
clc;
%%
% init counter
versioninfo = version;
if strfind(versioninfo,'R2014a')
    hh = hour(now);
    if (hh >= 8 && hh <= 16 || hh >= 20)
        ctp_proceed = true;
    else
        ctp_proceed = false;
    end
else
    ctp_proceed = false;
end
   
if ctp_proceed
    try
        if ~exist('c_kim','var') || ~isa(c_kim,'CounterCTP')
            c_kim = CounterCTP.citic_kim_fut;
        end
        if ~exist('c_ly','var') || ~isa(c_ly,'CounterCTP')
            c_ly = CounterCTP.huaxin_liyang_fut;
        end
        %
        
        if ~c_kim.is_Counter_Login, c_kim.login; end
        if ~c_ly.is_Counter_Login, c_ly.login; end
    catch e
        fprintf([e.message,'......\n']);
    end
end
%%
% md login using CTP
if ctp_proceed
    try
        if ~exist('md_ctp','var') || ~isa(md_ctp,'cCTP')
            md_ctp = cCTP.citic_kim_fut;
        end
        if ~md_ctp.isconnect, md_ctp.login; end
        
    catch e
        fprintf([e.message,'......\n']);
    end
end
%%
% init qms
% qms for listed options
try
    % for soymeal listed options
    if ctp_proceed
        if ~exist('qms_opt_m','var') || ~isa(qms_opt_m,'cQMS')
            qms_opt_m = cQMS;
            qms_opt_m.setdatasource('ctp');
        end 
    end
    % for sugar listed options
    if ctp_proceed
        if ~exist('qms_opt_sr','var') || ~isa(qms_opt_sr,'cQMS')
            qms_opt_sr = cQMS;
            qms_opt_sr.setdatasource('ctp');
        end 
    end
    % for govtbond futures
    if ctp_proceed
        if ~exist('qms_fut_govtbond','var') || ~isa(qms_fut_govtbond,'cQMS')
            qms_fut_govtbond = cQMS;
            qms_fut_govtbond.setdatasource('ctp');
        end 
    end
    % for other futures
    if ctp_proceed
        if ~exist('qms_fut','var') || ~isa(qms_fut,'cQMS')
            qms_fut = cQMS;
            qms_fut.setdatasource('ctp');
        end 
    end
    %
catch e
    fprintf([e.message,'......\n']);
end

try
    if ~exist('qms_bbg','var') || ~isa(qms_bbg,'cQMS')
        qms_bbg = cQMS;
        qms_bbg.setdatasource('bloomberg');
    end 
catch e
    fprintf([e.message,'......\n']);
end

try
    if ~exist('qms_local','var') || ~isa(qms_local,'cQMS')
        qms_local = cQMS;
        qms_local.setdatasource('local');
    end
catch e
    fprintf([e.message,'......\n']);
end
    
%%
fprintf('trading login finishes......\n');

clear hh
clear ans
clear versioninfo
clear ctp_proceed






