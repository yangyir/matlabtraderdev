%%
pathdefs = regexp(matlabpath,';','split');
cd(pathdefs{1});
clear all;
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
try
    if ctp_proceed
        if ~exist('qms_ctp','var') || ~isa(qms_ctp,'cQMS')
            qms_ctp = cQMS;
            qms_ctp.setdatasource('ctp');
        end 
    end
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
% init watcher
if ctp_proceed
    try
        if ~exist('wfut','var')
            wfut = cWatcher;
            wfut.ds = md_ctp;
            wfut.conn = 'ctp';
        end
        
        if ~exist('wopt','var')
            wopt = cWatcher;
            wopt.ds = md_ctp;
            wopt.conn = 'ctp';
        end
    catch e
        fprintf([e.message,'......\n']);
    end
end

%%
% init contracts
if ~exist('TF1712','var') || ~isa(TF1712,'cFutures')
    TF1712 = cFutures('TF1712');TF1712.loadinfo('TF1712_info.txt');
end
if ~exist('T1712','var') || ~isa(T1712,'cFutures')
    T1712 = cFutures('T1712');T1712.loadinfo('T1712_info.txt');
end

%%
fprintf('trading init finishes......\n');








