function contracts = listcontracts_industrial(assetName,varargin)
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
if strcmpi(assetName,'coke') 
    init_mm = 9;
    init_yy = 2011;
elseif strcmpi(assetName,'coking coal')
    init_mm = 9;
    init_yy = 2013;
elseif strcmpi(assetName,'deformed bar') 
    init_mm = 10;
    init_yy = 2009;
elseif strcmpi(assetName,'iron ore') 
    init_mm = 5;
    init_yy = 2014;
elseif strcmpi(assetName,'glass') 
    init_mm = 5;
    init_yy = 2014;
else
    error('invalid industrial asset name');
end

curr_dd = today;
curr_yy = year(curr_dd);
curr_mm = month(curr_dd);

%number of contracts traded in total
n = ceil((12-init_mm)/4)+...    %contracts first year
    (curr_yy-1-init_yy)*3+...   %contracts between next year and last year
    ceil(curr_mm/4)+...         %contracts traded so far this year
    +3;                         %contracts listed from this month

contracts = cell(n,1);
i=1;
while i<=n
    if strcmpi(assetName,'deformed bar') && init_mm==10
        init_mm = 9;
    end
    mm = (i-1)*4+init_mm;
    if strcmpi(assetName,'deformed bar') && mod(mm,12)==9
        mm = mm+1;
    end
    if mod(mm,12)==0
        yy = init_yy+mm/12-1;
    else
        yy = init_yy+floor(mm/12);
    end
    yy_str = num2str(yy);
    mm = mod(mm,12);
    if mm==0
        mm = 12;
    end;
    if mm<10
        mm_str = ['0',num2str(mm)];
    else
        mm_str = num2str(mm);
    end
    if iswind
        if ~strcmpi(exchange,'.CZC')
            contracts{i,1} = [wcode,yy_str(end-1:end),mm_str,exchange];
        else
            if yy>2010
                contracts{i,1} = [wcode,yy_str(end),mm_str,exchange];
            else
                contracts{i,1} = [wcode,yy_str(end-1:end),mm_str,exchange];
            end
        end
    else
        futcode = getfutcode(str2double(mm_str));
        if str2double(yy_str) >= curr_yy
            contracts{i,1} = [bcode,futcode,yy_str(end),' Comdty'];
        else
            contracts{i,1} = [bcode,futcode,yy_str(end-1:end),' Comdty'];
        end
    end
    i = i+1;
end



end