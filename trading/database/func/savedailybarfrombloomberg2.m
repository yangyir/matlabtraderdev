function savedailybarfrombloomberg2(bbg,code_bbg)
%codeup for 50ETF and 300ETF only

if ~isa(bbg,'cBloomberg')
    error('saveintradaybarfrombloomberg;invalid bloomberg instance input')
end

if ~ischar(code_bbg)
    error('saveintradaybarfrombloomberg;invalid CTP code input')
end


dir_ = getenv('DATAPATH');
dir_data_ = [dir_,'dailybar\'];
try
    cd(dir_data_);
catch
    mkdir(dir_data_);
end

permission = 'w';
usedatestr = false;

if strcmpi(code_bbg,'510050 CH Equity') || strcmpi(code_bbg,'510300 CH Equity')
    coldefs = {'date','open','high','low','close','volume'};
    fn_ = [code_bbg(1:6),'_daily.txt'];
    startdate = datenum('2010-01-01','yyyy-mm-dd');
    enddate = getlastbusinessdate;
    data = bbg.ds_.history(code_bbg,{'px_open','px_high','px_low','px_last','volume'},startdate,enddate);
else
    coldefs = {'date','open','high','low','close','volume','openinterest'};
    last_trade_date = datenum(code_bbg(11:18),'mm/dd/yy');
    startdate = last_trade_date-365;
    lbd = getlastbusinessdate;
    enddate = min(lbd,last_trade_date);
    fn_ = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
    data = bbg.ds_.history(code_bbg,{'px_open','px_high','px_low','px_last','volume','open_int'},startdate,enddate);
end


if isempty(data)
    fprintf('%s:there is no available data for the currently loaded security......\n',code_bbg);
    return
end

cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
fprintf('done daily bar with %s\n',code_bbg);

end

