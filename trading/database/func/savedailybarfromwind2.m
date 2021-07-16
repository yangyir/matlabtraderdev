function savedailybarfromwind2(w,code_wind)
%download equity data from WIND
if ~isa(w,'cWind')
    error('saveintradaybarfromwind2;invalid wind instance input')
end

if ~ischar(code_wind)
    error('saveintradaybarfromwind2;invalid wind code input')
end
%20210716:the format shall be number only from this date onwards
if strcmpi(code_wind(1),'5') || strcmpi(code_wind(1),'6')
    code_wind_ = [code_wind,'.SH'];
else
    code_wind_ = [code_wind,'.SZ'];
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


coldefs = {'date','open','high','low','close','volume'};
fn_ = [code_wind,'_daily.txt'];

try
    wdata = w.ds_.wss(code_wind_,'ipo_date');
    startdate = datenum(wdata{1});
catch
    startdate = datenum('2010-01-01','yyyy-mm-dd');
end

enddate = getlastbusinessdate;
data = w.history(code_wind_,'open,high,low,close,volume',startdate,enddate);
if isempty(data)
    fprintf('saveintradaybarfromwind2:%s:there is no available data for the currently loaded security......\n',code_wind);
    return
end
cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);


fprintf('done daily bar with %s\n',code_wind);

end

