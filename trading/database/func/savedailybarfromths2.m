function savedailybarfromths2(ths,code_ths,varargin)
%utility function to save data from THS
%for stocks only
if ~isa(ths,'cTHS')
    error('saveintradaybarfromths2;invalid ths instance input')
end

if ~ischar(code_ths)
    error('saveintradaybarfromths2;invalid ths code input')
end

p = inputParser;
p.addParameter('Directory','',@ischar);
p.parse(varargin{:});
dir_data_ = p.Results.Directory;
if isempty(dir_data_)
    dir_data_ = [getenv('DATAPATH'),'dailybar\'];
end

stock = code2instrument(code_ths);
if isempty(stock.ipo_date1)
    try
        stock.init(ths);
        fn_info_ = [getenv('DATAPATH'),'info_stock\',code_ths,'_info.txt'];
        stock.saveinfo(fn_info_);
    catch
        %the security cannot initiate from wind
        fprintf('%s:invaid_security......\n',code_ths);
        return
    end
end

cd(dir_data_);
permission = 'w';
usedatestr = false;

fn_dailybar = [dir_data_,code_ths,'_daily.txt'];
try
    dailybar_old = cDataFileIO.loadDataFromTxtFile(fn_dailybar);
    dt1 = dailybar_old(end,1); 
catch
    %fn_dailybar not found
    dailybar_old = [];
    dt1 = stock.ipo_date1;
end

dt2 = getlastbusinessdate;
if dt1 < dt2
    dailybar_new = ths.history(stock,'open;high;low;close;volume',datestr(dt1,'yyyy-mm-dd'),datestr(dt2,'yyyy-mm-dd'));
else
    dailybar_new = [];
end

if isempty(dailybar_old)
    dailybar = dailybar_new;
else
    if ~isempty(dailybar_new)
        lastdt = dailybar_old(end,1);
        idx = dailybar_new(:,1) > lastdt;
        ncols = size(dailybar_new,2);
        dailybar = [dailybar_old(:,1:ncols);dailybar_new(idx,:)];
    else
        dailybar = dailybar_old;
    end
end

if ~isempty(dailybar_new)
    coldefs = {'date','open','high','low','close','volume'};
    cDataFileIO.saveDataToTxtFile(fn_dailybar,dailybar,coldefs,permission,usedatestr);
end

fprintf('done daily bar with %s\n',code_ths);

end

