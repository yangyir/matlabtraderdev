%%
% md login using CTP
md_ctp = ctpmdconnect; 
md_info = md_ctp.printinfo;
disp(md_info);

%%
% init counter citic kim
if ~exist('c_kim','var') || ~isa(c_kim,'CounterCTP')
    c_kim = CounterCTP.citic_kim_fut;
end

if ~c_kim.is_Counter_Login, c_kim.login; end
c_kim_info = c_kim.printInfo;
disp(c_kim_info);

%%
% init counter huaxin liyang
if ~exist('c_ly','var') || ~isa(c_ly,'CounterCTP')
    c_ly = CounterCTP.huaxin_liyang_fut;
end

if ~c_ly.is_Counter_Login, c_ly.login; end
c_ly_info = c_ly.printInfo;
disp(c_ly_info);

%%
%qms for soymeal listed options
if ~exist('qms_opt_m','var') || ~isa(qms_opt_m,'cQMS')
    qms_opt_m = cQMS;
    qms_opt_m.setdatasource('ctp');
end

%qms for sugar listed options
if ~exist('qms_opt_sr','var') || ~isa(qms_opt_sr,'cQMS')
    qms_opt_sr = cQMS;
    qms_opt_sr.setdatasource('ctp');
end

%qms for govtbond futures
if ~exist('qms_fut_govtbond','var') || ~isa(qms_fut_govtbond,'cQMS')
    qms_fut_govtbond = cQMS;
    qms_fut_govtbond.setdatasource('ctp');
end

%qms for other futures
if ~exist('qms_fut','var') || ~isa(qms_fut,'cQMS')
    qms_fut = cQMS;
    qms_fut.setdatasource('ctp');
end
    










