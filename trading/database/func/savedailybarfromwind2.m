function savedailybarfromwind2(w,code_wind,varargin)
%utility function to save data from wind
%for stocks only
if ~isa(w,'cWind')
    error('saveintradaybarfromwind2;invalid wind instance input')
end

if ~ischar(code_wind)
    error('saveintradaybarfromwind2;invalid wind code input')
end

p = inputParser;
p.addParameter('Directory','',@ischar);
p.parse(varargin{:});
dir_data_ = p.Results.Directory;
if isempty(dir_data_)
    dir_data_ = [getenv('DATAPATH'),'dailybar\'];
end

%20210716:the format shall be number only from this date onwards
if ~isempty(strfind(code_wind,'.SH')) || ...
        ~isempty(strfind(code_wind,'.SZ')) || ...
        ~isempty(strfind(code_wind,'.HK')) || ...
        ~isempty(strfind(code_wind,'.WI')) || ... 
        ~isempty(strfind(code_wind,'.CSI'))
    code_wind_ = code_wind;
else
    if length(code_wind) == 6
        if strcmpi(code_wind(1),'5') || strcmpi(code_wind(1),'6')
            code_wind_ = [code_wind,'.SH'];
        elseif strcmpi(code_wind(1),'0') || strcmpi(code_wind(1),'3') || strcmpi(code_wind(1),'1')
            code_wind_ = [code_wind,'.SZ'];
        elseif strcmpi(code_wind(1),'4') || strcmpi(code_wind(1),'8')
            code_wind_ = [code_wind,'.BJ'];
        end
    elseif length(code_wind) == 4
        code_wind_ = [code_wind,'.HK'];
    end 
end

if ~isempty(strfind(code_wind,'.WI'))
    %WINDÖ¸Êý
    stock = cStock(code_wind);
    if isempty(stock.ipo_date1)
        try
            stock.init(w);
            fn_info_ = [getenv('DATAPATH'),'info_stock\',code_wind,'_info.txt'];
            stock.saveinfo(fn_info_);
        catch
            %the security cannot initiate from wind
            fprintf('%s:invaid_security......\n',code_wind);
            return
        end
    end
else
    
    stock = cStock(code_wind);
    if isempty(stock.ipo_date1)
        try
            stock.init(w);
            fn_info_ = [getenv('DATAPATH'),'info_stock\',code_wind,'_info.txt'];
            stock.saveinfo(fn_info_);
        catch
            %the security cannot initiate from wind
            fprintf('%s:invaid_security......\n',code_wind);
            return
        end
    end
end


% dir_ = getenv('DATAPATH');

try
    cd(dir_data_);
catch
    mkdir(dir_data_);
end

permission = 'w';
usedatestr = false;


coldefs = {'date','open','high','low','close','volume'};

fn_ = [dir_data_,code_wind,'_daily.txt'];

try
    wdata = w.ds_.wss(code_wind_,'ipo_date');
    try
        startdate = datenum(wdata{1},'dd/mm/yyyy');
    catch
        startdate = datenum(wdata{1});
    end
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

