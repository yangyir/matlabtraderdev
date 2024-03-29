function savedailybarfromwind(w,code_ctp,override)
%utility function to save data from wind
%for options and futures traded in SHFE,DCE,CZC and CFE only
if ~isa(w,'cWind')
    error('saveintradaybarfromwind;invalid wind instance input')
end

if ~ischar(code_ctp)
    error('saveintradaybarfromwind;invalid CTP code input')
end

if nargin < 3
    override = true;
end

dir_ = getenv('DATAPATH');
dir_data_ = [dir_,'dailybar\'];
try
    cd(dir_data_);
catch
    mkdir(dir_data_);
end

%first try to load information from local drive
if isoptchar(code_ctp)
    f = cOption(code_ctp);
    dir_info_ = [dir_,'info_option\'];
else
    f = cFutures(code_ctp);
    dir_info_ = [dir_,'info_futures\'];
end
fn_info_ = [dir_info_,code_ctp,'_info.txt'];
f.loadinfo(fn_info_);
if isempty(f.contract_size)
    %not loaded
    try
        f.init(w);
        f.saveinfo(fn_info_);
    catch
        %the security cannot initiate from bbg
        fprintf('%s:invaid_security......\n',code_ctp);
        return
    end
end

files = dir(dir_data_);
nfiles = size(files,1);


coldefs = {'date','open','high','low','close','volume','openinterest'};
permission = 'w';
usedatestr = false;
startdate = f.first_trade_date1;
lbd = getlastbusinessdate;
enddate = min(lbd,f.last_trade_date1);

fn_ = [f.code_ctp,'_daily.txt'];
%first check whether fn_ exists
flag = false;
for j = 1:nfiles
    if strcmpi(fn_,files(j).name)
        flag = true;
        break
    end
end

if ~flag || (flag && override)
    data = w.history(f,'open,high,low,close,volume,oi',startdate,enddate);
    if isempty(data)
        fprintf('%s:there is no available data for the currently loaded security......\n',code_ctp);
        return
    end
    cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
end

if flag && ~override
    data = cDataFileIO.loadDataFromTxtFile(fn_);
    lastcob = data(end,1);
    if lastcob < enddate
        data_new = w.history(f,'open,high,low,close,volume,oi',businessdate(lastcob,1),enddate);
        data = [data,data_new];
        cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
    end    
end

fprintf('done daily bar with %s\n',code_ctp);

end

