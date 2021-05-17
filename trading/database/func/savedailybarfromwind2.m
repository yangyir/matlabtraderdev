function savedailybarfromwind2(w,code_wind)
%download equity data from WIND
if ~isa(w,'cWind')
    error('saveintradaybarfromwind2;invalid wind instance input')
end

if ~ischar(code_wind)
    error('saveintradaybarfromwind2;invalid wind code input')
end

idx = strfind(code_wind,'.SH');
if isempty(idx)
    idx = strfind(code_wind,'SZ');
end

if isempty(idx)
    error('saveintradaybarfromwind2;invalid equity wind code input')
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
fn_ = [code_wind(1:idx-1),'_daily.txt'];
if strcmpi(code_wind,'510300.SH')
    startdate = datenum('2012-05-28','yyyy-mm-dd');
elseif strcmpi(code_wind,'512400.SH')
    startdate = datenum('2017-09-01','yyyy-mm-dd');
else
    startdate = datenum('2010-01-01','yyyy-mm-dd');
end
enddate = getlastbusinessdate;
data = w.history(code_wind,'open,high,low,close,volume',startdate,enddate);
if isempty(data)
    fprintf('saveintradaybarfromwind2:%s:there is no available data for the currently loaded security......\n',code_wind);
    return
end
cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);


fprintf('done daily bar with %s\n',code_wind);

end

