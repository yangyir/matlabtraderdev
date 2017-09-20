function savedailybarfrombloomberg(bbg,code_ctp,override)

if ~isa(bbg,'cBloomberg')
    error('saveintradaybarfrombloomberg;invalid bloomberg instance input')
end

if ~ischar(code_ctp)
    error('saveintradaybarfrombloomberg;invalid CTP code input')
end

if nargin < 3
    override = true;
end

dir_ = getenv('DATAPATH');
dir_data_ = [dir_,'dailybar\',code_ctp,'\'];
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
    f.init(bbg);
    f.saveinfo(fn_info_);
end

files = dir(dir_data_);
nfiles = size(files,1);


coldefs = {'date','open','high','low','close'};
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
    data = bbg.history(f,{'px_open','px_high','px_low','px_last'},startdate,enddate);
    cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
end

if flag && ~override
    data = cDataFileIO.loadDataFromTxtFile(fn_);
    lastcob = data(end,1);
    if lastcob < enddate
        data_new = bbg.history(f,{'px_open','px_high','px_low','px_last'},businessdate(lastcob,1),enddate);
        data = [data,data_new];
        cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
    end    
end

fprintf('done daily bar with %s\n',code_ctp);

end

