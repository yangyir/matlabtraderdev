function contracts = listcontracts_eqindex(assetName,varargin)
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('AssetName',@ischar);
p.addParameter('BloombergCode',{},...
       @(x) validateattributes(x,{'cell','char'},{},'','BloombergCode'));
p.addParameter('WindCode',{},...
       @(x) validateattributes(x,{'cell','char'},{},'','WindCode'));
p.addParameter('Exchange',{},...
       @(x) validateattributes(x,{'cell','char'},{},'','Exchange'));
p.parse(assetName,varargin{:});
assetName = p.Results.AssetName;
bcode = p.Results.BloombergCode;
wcode = p.Results.WindCode;
exchange = p.Results.Exchange;
if isempty(wcode)
    iswind = 0;
else
    iswind = 1;
end

%
if strcmpi(assetName,'eqindex_300')    %1st csi300 futures expired in May10
    init_mm = 5;
    init_yy = 2010;
%other equity index futures started trading in May2015 
else
    init_mm = 5;
    init_yy = 2015;
end
%
%note that the equity index futures expired on the 3rd friday of the month
%once the 1st futures contract expired, it rolled to the next month
%e.g.the first contract expired next month in case the trade date is in
%the 4th week of the month
curr_dd = today;
curr_yy = year(curr_dd);
curr_mm = month(curr_dd);
yy_str = num2str(curr_yy);
if curr_mm<10
    mm_str = ['0',num2str(curr_mm)];
else
    mm_str = num2str(curr_mm);
end
first_month_date = datenum([yy_str,mm_str,'01'],'yyyymmdd');
wkd = weekday(first_month_date);
if wkd==6
    first_friday_date = first_month_date;
else
    if wkd==7
        first_friday_date = first_month_date+6;
    else
        first_friday_date = first_month_date+6-wkd;
    end
end
third_friday_date = first_friday_date+14;
if curr_dd>third_friday_date
    curr_mm = curr_mm+1;
    if curr_mm>12
        curr_mm = curr_mm-12;
        curr_yy = curr_yy+1;
    end
end

%compute the current and next quarter month
if mod(curr_mm,3)>0
    curr_qt = 3*(floor(curr_mm/3)+1);
    if mod(curr_mm,3)==2
        curr_qt = curr_qt+3;
    end
else
    curr_qt = curr_mm+3;
end
next_qt = curr_qt+3;
%number of contracts traded in total
if init_yy<curr_yy
    n = (12-init_mm+1)+...          %contracts for the 1st year
        (curr_yy-1-init_yy)*12+...  %contracts between 2nd year and last year
        curr_mm+3;                  %contracts traded so far this year
else
    n = (curr_mm-init_mm+1)+3;
end
%
%list all contracts
contracts = cell(n,1);
i=1;
while i<=n
    %next month contract
    if i==n-2
        yy_str = num2str(curr_yy);
        if curr_mm+1>12
            mm_str = '01';
            yy_str = num2str(curr_yy+1);
        elseif curr_mm+1<10
            mm_str = ['0',num2str(curr_mm+1)];
        else
            mm_str = num2str(curr_mm+1);
        end
    %1st quarter month contract
    elseif i==n-1
        yy_str = num2str(curr_yy);
        if curr_qt > 12
            curr_qt = curr_qt-12;
            yy_str = num2str(curr_yy+1);
        end
        if curr_qt<10
            mm_str=['0',num2str(curr_qt)];
        else
            mm_str=num2str(curr_qt);
        end
    %2nd quarter month contract
    elseif i==n
        yy_str = num2str(curr_yy);
        if next_qt > 12
            next_qt = next_qt-12;
            yy_str = num2str(curr_yy+1);
        end
        if next_qt<10
            mm_str=['0',num2str(next_qt)];
        else
            mm_str=num2str(next_qt);
        end
    %current month contract plus all contracts in the past
    else
        mm = i+init_mm-1;
        if mod(mm,12)==0
            yy = init_yy+mm/12-1;
        else
            yy = init_yy+floor(mm/12);
        end
        yy_str = num2str(yy);
        mm = mod(mm,12);
        if mm==0
            mm = 12;
        end
        if mm<10
            mm_str = ['0',num2str(mm)];
        else
            mm_str = num2str(mm);
        end
    end
    if iswind
        contracts{i,1} = [wcode,yy_str(end-1:end),mm_str,exchange];
    else
        futcode = getfutcode(str2double(mm_str));
        if str2double(yy_str) >= curr_yy
            contracts{i,1} = [bcode,futcode,yy_str(end),' Index'];
        else
            contracts{i,1} = [bcode,futcode,yy_str(end-1:end),' Index'];
        end
    end
    i = i+1;        
end
   
end