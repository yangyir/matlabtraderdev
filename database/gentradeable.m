function [tradeable,leginfo] = gentradeable(contracts,varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('Contracts',@(x)validateattributes(x,{'cell','cContract'},{},'','Contracts'));
p.addParameter('Weights',{},@(x)validateattributes(x,{'numeric'},{},'','Weights'));
p.addParameter('FromDate',NaN,@(x)validateattributes(x,{'numeric','char'},{},'','FromDate'));
p.addParameter('ToDate',NaN,@(x)validateattributes(x,{'numeric','char'},{},'','ToDate'));
p.addParameter('Frequency','1m',@(x)validateattributes(x,{'char'},{},'','Frequency'));
p.addParameter('JoinMethod','outer',@(x)validateattributes(x,{'char'},{},'','JoinMethod'));
p.addParameter('ReturnLegInfo',true,@(x)validateattributes(x,{'logical'},{},'','ReturnLegInfo'));
p.parse(contracts,varargin{:});

cl = p.Results.Contracts;
if iscell(cl)
    ncontract = size(cl,1);
    for i = 1:ncontract
        if ~isa(cl{i},'cContract')
            error('gentradeable:invalid contracts input')
        end
    end
else
    ncontract = 1;
end

weights = p.Results.Weights;
if isempty(weights)
    weights = ones(ncontract,1);
else
    if ncontract ~= size(weights,1)
        error('gentradeable:invalid weights input')
    end
end

datefrom = p.Results.FromDate;
dateto = p.Results.ToDate;
freq = p.Results.Frequency;
if strcmpi(freq,'tick')
    error('gentradable:tick data is not support')
end
joinmethod = p.Results.JoinMethod;
rtnleginfo = p.Results.ReturnLegInfo;

if ncontract == 1
    if iscell(contracts)
        contract = contracts{1};
    else
        contract = contracts;
    end
    try
        tradeable = contract.getTimeSeries('connection','bloomberg',...
            'frequency','1m',...
            'fields',{'close','volume'},...
            'fromdate',datefrom,...
            'todate',dateto);
        if rtnleginfo
            leginfo = tradeable;
        end
        tradeable = [tradeable(:,1),weights.*tradeable(:,2)];
    catch me
        fprintf([me.message,'\n']);
    end
else
    if rtnleginfo
        leginfo = cell(ncontract,1);
    end
    contract = contracts{1};
    try
        tradeable = contract.getTimeSeries('connection','bloomberg',...
            'frequency','1m',...
            'fields',{'close','volume'},...
            'fromdate',datefrom,...
            'todate',dateto);
        if rtnleginfo
            leginfo{1} = tradeable;
        end
        tradeable = [tradeable(:,1),weights(1).*tradeable(:,2)];
    catch me
        fprintf([me.message,'\n']);
    end
    
    for i = 2:ncontract
        contract = contracts{i};
        try
            data = contract.getTimeSeries('connection','bloomberg',...
                'frequency','1m',...
                'fields',{'close','volume'},...
                'fromdate',datefrom,...
                'todate',dateto);
            if rtnleginfo
                leginfo{i} = data;
            end
            data = [data(:,1),weights(i)*data(:,2)];
            if strcmpi(joinmethod,'inner')
                [t,ia,ib] = intersect(tradeable(:,1),data(:,1));
                tradeable = [t,tradeable(ia,end)+data(ib,end)];
            elseif strcmpi(joinmethod,'outer')
                ds1 = dataset(tradeable(:,1),tradeable(:,end),'VarNames',{'Time','Last1'});
                ds2 = dataset(data(:,1),data(:,end),'VarNames',{'Time','Last2'});
                c = join(ds1,ds2,'Key','Time','Type',joinmethod,'MergeKeys',true);
                t = c.Time;
                px1 = c.Last1;
                px2 = c.Last2;
                flagNaN = isnan(px1(1)) | isnan(px2(1));
                idxStart = 1;
                if flagNaN
                    for j=1:size(px1,1)
                        if ~isnan(px1(j)) && ~isnan(px2(j))
                            idxStart = j;
                            break
                        end
                    end
                end
                for j = idxStart:size(px1,1)
                    if j > 1
                        if isnan(px1(j))
                            px1(j) = px1(j-1);
                        end
                        if isnan(px2(j))
                            px2(j) = px2(j-1);
                        end
                    end
                end
                tradeable = [t(idxStart:end),px1(idxStart:end)+px2(idxStart:end)];
            end
        catch me
            error(me.Message)
        end
    end
    
end
tradeable = timeseries_compress(tradeable,'Frequency',freq);
tradeable = [tradeable(:,1),tradeable(:,end)];



end