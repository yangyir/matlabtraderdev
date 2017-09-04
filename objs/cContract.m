classdef cContract
    % class of futures contract
    %
    properties (Access = public)
        AssetName               %underlying asset name
        Tenor                   %expiry year and month,e.g.1612
    end
    
    %
    properties (GetAccess = public, SetAccess = private, Dependent)
        Asset          % cAsset
        BloombergCode
        WindCode
        Symbol
        Exchange
        Expiry
        TradingHours
        TradingBreak
        ContractSize
        TickSize
        TimeSeriesFileNames    % time series file names
    end
    %
    
    methods 
        %GET method
        %
        function assetname = get.AssetName(obj)
            assetname = obj.AssetName;
        end
        %
        
        function tenor = get.Tenor(obj)
            tenor = obj.Tenor;
        end
        %
        
        function bcode = get.BloombergCode(obj)
            a = cAsset('AssetName',obj.AssetName);
            cl = a.ContractList;
            flag = false;
            for i = 1:size(cl,1)
                expiry = cl{i,3};
                yy = year(expiry)-2000;
                mm = month(expiry);
                if yy < 10
                    yy_str = ['0',num2str(yy)];
                else
                    yy_str = num2str(yy);
                end
                if mm < 10
                    mm_str = ['0',num2str(mm)];
                else
                    mm_str = num2str(mm);
                end
                expiry_str = [yy_str,mm_str];
                if strcmpi(obj.Tenor,expiry_str)
                    bcode = cl{i,1};
                    flag = true;
                    break
                end                
            end
            if ~flag
                error('bloomberg not found in the contract list')
            end
        end
        %
        
        function wcode = get.WindCode(obj)
            a = cAsset('AssetName',obj.AssetName);
            cl = a.ContractList;
            flag = false;
            for i = 1:size(cl,1)
                expiry = cl{i,3};
                yy = year(expiry)-2000;
                mm = month(expiry);
                if yy < 10
                    yy_str = ['0',num2str(yy)];
                else
                    yy_str = num2str(yy);
                end
                if mm < 10
                    mm_str = ['0',num2str(mm)];
                else
                    mm_str = num2str(mm);
                end
                expiry_str = [yy_str,mm_str];
                if strcmpi(obj.Tenor,expiry_str)
                    wcode = cl{i,2};
                    flag = true;
                    break
                end                
            end
            if ~flag
                error('bloomberg not found in the contract list')
            end
        end
        %
        
        function exchange = get.Exchange(obj)
            assetinfo = getassetinfo(obj.AssetName);
            exchange = assetinfo.ExchangeCode;
        end
        %
        
        function symbol = get.Symbol(obj)
            windCode = obj.WindCode;
            exchange = obj.Exchange;
            symbol = windCode(1:end-length(exchange));
        end
        %
        
        function asset = get.Asset(obj)
            asset = cAsset('AssetName',obj.AssetName);
        end
        %
        
        function expiry = get.Expiry(obj)
            a = cAsset('AssetName',obj.AssetName);
            cl = a.ContractList;
            flag = false;
            for i = 1:size(cl,1)
                expiry = cl{i,3};
                yy = year(expiry)-2000;
                mm = month(expiry);
                if yy < 10
                    yy_str = ['0',num2str(yy)];
                else
                    yy_str = num2str(yy);
                end
                if mm < 10
                    mm_str = ['0',num2str(mm)];
                else
                    mm_str = num2str(mm);
                end
                expiry_str = [yy_str,mm_str];
                if strcmpi(obj.Tenor,expiry_str)
                    expiry = cl{i,3};
                    flag = true;
                    break
                end
            end
            if ~flag
                error('bloomberg not found in the contract list')
            end
        end
        %
        
        function th = get.TradingHours(obj)
            an = obj.AssetName;
            info = getassetinfo(an);
            th = info.TradingHours;
        end
        %
        
        function tb = get.TradingBreak(obj)
            an = obj.AssetName;
            info = getassetinfo(an);
            tb = info.TradingBreak;
        end
        %
        
        function cs = get.ContractSize(obj)
            an = obj.AssetName;
            info = getassetinfo(an);
            cs = info.ContractSize;
        end
        %
        
        function ts = get.TickSize(obj)
            an = obj.AssetName;
            info = getassetinfo(an);
            ts = info.TickSize;
        end
        %
        
        function tsfiles = get.TimeSeriesFileNames(obj)
            path = obj.Asset.ExtraInfo.directory;
            bcode = regexp(obj.BloombergCode,' ','split');
            files = cell(3,1);
            files{1,1} = [path,'b_',bcode{1},'_1d'];
            files{2,1} = [path,'b_',bcode{1},'_1m'];
            files{3,1} = [path,'b_',bcode{1},'_tick'];
            tsfiles.bfiles = files;
            %
            idx = strfind(obj.WindCode,'.');
            wcode = obj.WindCode(1:idx-1);
            files = cell(3,1);
            files{1,1} = [path,'w_',wcode,'_1d'];
            files{2,1} = [path,'w_',wcode,'_1m'];
            files{3,1} = [path,'w_',wcode,'_tick'];
            tsfiles.wfiles = files;
        end
        %
        
        %
        %SET methods
        %
        function obj = set.AssetName(obj,an)
            obj.AssetName = an;
        end
        %
        
        function obj = set.Tenor(obj,tenor)
            obj.Tenor = tenor;
        end
        %
        
    end
    %methods end
    
    methods (Access = public)
        %
        function obj = cContract(varargin)
            obj = init(obj,varargin{:});
        end
        %
        
        function cost = getTransactionCost(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('IsIntraday',false,@islogical);
            p.parse(varargin{:});
            isintraday = p.Results.IsIntraday;
            an = obj.AssetName;
            info = getassetinfo(an);
            if isintraday
                cost.Value = info.TransactionCostIntraday;
                cost.Type = info.TransactionCostType;
            else
                cost.Value = info.TransactionCost;
                cost.Type = info.TransactionCostType;
            end
        end
        %
        
        function margin = getMarginRate(obj)
            an = obj.AssetName;
            info = getassetinfo(an);
            margin = info.MarginRate;
        end
        %
        
        function reblanceTime = getReblanceTime(obj)
           tradingHours = regexp(obj.TradingHours,';','split');
           mktcloseStr = tradingHours{2}(end-4:end);
           reblanceTime = str2double(mktcloseStr(1:2))*60+str2double(mktcloseStr(end-1:end));
           reblanceTime = reblanceTime/1440;
        end
        %
        
        function openTimes = getOpenTimes(obj)
            %the open time includes the morning open time, afternoon open
            %time and evening open time if the contract trades in the
            %evening session
            tradingHours = regexp(obj.TradingHours,';','split');
            mktOpenStr1 = tradingHours{1}(1:5);
            mktOpenStr2 = tradingHours{2}(1:5);
            n = 2;
            if ~strcmpi(tradingHours{3},'n/a')
                mktOpenStr3 = tradingHours{3}(1:5);
                n = n+1;
            end
            openTimes = zeros(n,1);
            openTimes(1) = str2double(mktOpenStr1(1:2))*60+...
                str2double(mktOpenStr1(end-1:end));
            openTimes(2) = str2double(mktOpenStr2(1:2))*60+...
                str2double(mktOpenStr2(end-1:end));
            if ~strcmpi(tradingHours{3},'n/a')
                openTimes(n) = str2double(mktOpenStr3(1:2))*60+...
                    str2double(mktOpenStr3(end-1:end));
            end
            openTimes = openTimes/1440;
            
        end
        %
        
        function tradingLength = getTradingLength(obj)
            %this function calculate how many minutes does the contract
            %trade in a day. This will help to scale the volatility from
            %daily to different time intevals
            tradingHours = regexp(obj.TradingHours,';','split');
            tradingBreak = obj.TradingBreak;
            
            tradingLength = 0;
            for i = 1:3
                if ~strcmpi(tradingHours{i},'n/a')
                    mktOpenStr = tradingHours{i}(1:5);
                    mktCloseStr = tradingHours{i}(end-4:end);
                    mktOpenMin = str2double(mktOpenStr(1:2))*60+...
                        str2double(mktOpenStr(end-1:end));
                    mktCloseMin = str2double(mktCloseStr(1:2))*60+...
                        str2double(mktCloseStr(end-1:end));
                    if mktCloseMin < mktOpenMin
                        tradingLength = tradingLength + 1440-mktOpenMin + mktCloseMin;
                    else
                        tradingLength = tradingLength + mktCloseMin-mktOpenMin;
                    end
                end
                
            end
            
            if ~strcmpi(tradingBreak,'n/a')
                tradingLength = tradingLength - 15;
            end
           
            
        end
        %
        
        function bool = isTradingHour(obj,t)
            if ischar(t)
                t = datenum(t);
            end
            tradingHours = regexp(obj.TradingHours,';','split');
            tradingBreak = obj.TradingBreak;
            mktOpenMin = zeros(3,1);
            mktCloseMin = zeros(3,1);
            for i = 1:3
                if ~strcmpi(tradingHours{i},'n/a')
                    mktOpenStr = tradingHours{i}(1:5);
                    mktCloseStr = tradingHours{i}(end-4:end);
                    mktOpenMin(i) = str2double(mktOpenStr(1:2))*60+...
                        str2double(mktOpenStr(end-1:end));
                    mktCloseMin(i) = str2double(mktCloseStr(1:2))*60+...
                        str2double(mktCloseStr(end-1:end));
                else
                    mktOpenMin(i) = NaN;
                    mktCloseMin(i) = NaN;
                end
            end
            
            d = floor(t);
            tmin = (t - d)*1440;
            
            if ~isnan(mktOpenMin(end))
                 if (tmin >= 0 && tmin <= mktCloseMin(i)) ||...
                        (tmin >= mktOpenMin(i) && tmin <= 1440)
                    %evening hour trading session
                    %note:no evening market in case there follows a public
                    %holiday
                    nextBusday = businessdate(d,1);
                    [~,holidays] = isholiday(d);
                    idx = find(holidays < nextBusday, 1, 'last' );
                    lastHoliday = holidays(idx);
                    if d <= lastHoliday
                        bool = false;
                    else
                        bool = true;
                    end
                    return
                 end
            end
            
            bool = false;
            for i = 1:3
                if mktOpenMin(i) < mktCloseMin(i)
                    if tmin >= mktOpenMin(i) && tmin <= mktCloseMin(i)
                        bool = true;
                        break
                    end
                elseif mktOpenMin(i) > mktCloseMin(i)
                    if (tmin >= 0 && tmin <= mktCloseMin(i)) ||...
                        (tmin >= mktOpenMin(i) && tmin <= 1440)
                        bool = true;
                        break
                    end
                end
            end
            
            if bool && ~strcmpi(tradingBreak,'n/a')
                if tmin >= 615 && tmin <= 630
                    bool = false;
                end
            end
        end
        %
        
        function tsobjs = listTimeSeriesObjs(obj)    % get cell of cTimeSeries objects
            tsobjs = cell(3,2);
            bfiles = obj.TimeSeriesFileNames.bfiles;
            wfiles = obj.TimeSeriesFileNames.wfiles;
            if ~isempty(bfiles)
                for i = 1:3
                    filename = bfiles{i,1};
                    flag = isfile(filename);
                    if flag
                        tsobjs{i,1} = cTimeSeries('FileName',filename);
                    else
                        %do nothing
                    end
                end
            end
            %
            if ~isempty(wfiles)
                for i = 1:3
                    filename = wfiles{i,1};
                    flag = isfile(filename);
                    if flag
                        tsobjs{i,2} = cTimeSeries('FileName',filename);
                    else
                        %do nothing
                    end
                end
            end
        end
        %
        
        function tsobj = getTimeSeriesObj(obj,varargin)
            if isempty(varargin)
                error('cContract:getTimeSeriesObj:insufficient function inputs!');
            end
            %
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            p.addParameter('Connection',{},...
                @(x) validateattributes(x,{'char'},{},'','Connection'));
            p.addParameter('Frequency',{},...
                @(x) validateattributes(x,{'char'},{},'','Frequency'));
            p.parse(varargin{:});
            conn = p.Results.Connection;
            freq = p.Results.Frequency;
            if isempty(conn)
                error('cContract:getTimeSeriesObj:source required!');
            end
            if isempty(freq)
                error('cContract:getTimeSeriesObj:frequency required!');
            end
            %
            if strcmpi(conn,'Bloomberg')
                bfiles = obj.TimeSeriesFileNames.bfiles;
                if strcmpi(freq,'1d')
                    filename = bfiles{1};
                elseif strcmpi(freq,'1m')
                    filename = bfiles{2};
                elseif strcmpi(freq,'tick')
                    filename = bfiles{3};
                else
                    error('cContract:getTimeSeries:invalid tenor input!');
                end
            elseif strcmpi(conn,'Wind')
                wfiles = obj.TimeSeriesFileNames.wfiles;
                if strcmpi(freq,'1d')
                    filename = wfiles{1};
                elseif strcmpi(freq,'1m')
                    filename = wfiles{2};
                elseif strcmpi(freq,'tick')
                    filename = wfiles{3};
                else
                    error('cContract:getTimeSeries:invalid tenor input!');
                end
                
            else
                error('cContract:getTimeSeriesObj:invalid soure input!')
            end
            tsobj = cTimeSeries('FileName',filename);
        end
        %    
        
        function ts = getTimeSeries(obj,varargin)
            if isempty(varargin)
                error('cContract:getTimeSeries:insufficient function inputs');
            end
            %
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            p.addParameter('Fields',{},...
                @(x) validateattributes(x,{'char','cell'},{},'','Fields'));
            p.addParameter('FromDate',[],...
                @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
            p.addParameter('ToDate',[],...
                @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
            p.addParameter('Frequency',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','Frequency'));
            p.addParameter('Connection',{},...
                @(x) validateattributes(x,{'char'},{},'','Connection'));
            p.parse(varargin{:});
            fields = p.Results.Fields;
            dateFrom = p.Results.FromDate;
            dateTo = p.Results.ToDate;
            freq = p.Results.Frequency;
            conn = p.Results.Connection;
            %
            % bbg always has a piority
            files = obj.TimeSeriesFileNames.bfiles;
            if strcmpi(conn,'Wind')
                files = obj.TimeSeriesFileNames.wfiles;
            end
                  
            %todo:add tick data
            if strcmpi(freq(end),'m')
                filename = files{2,1};
            elseif strcmpi(freq,'1d')
                filename = files{1,1};
            else
                filename = files{3,1};
            end
            flag = isfile(filename);
            if ~flag
                error('cContract:getTimeSeries:data file unloaded!');
            end
            
            tsObj = cTimeSeries('FileName',filename);
            ts = tsObj.getTimeSeries('Fields',fields,...
                                     'FromDate',dateFrom,...
                                     'ToDate',dateTo,...
                                     'Frequency',freq,...
                                     'TradingHours',obj.TradingHours,...
                                     'TradingBreak',obj.TradingBreak);
            %
        end
        %
        
        function tsobjs = initTimeSeries(obj,varargin)    % initiate cell of cTimeSeries objects
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Frequency',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','Frequency'));
            p.addParameter('Connection',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','Connection'));
            p.parse(varargin{:});
            freq = p.Results.Frequency;
            conn = p.Results.Connection;
            if ischar(freq)
                freq = {freq};
            end
            if isempty(conn)
                isBBG = 1;
                isWIND = 1;
            else
                if ~(strcmpi(conn,'Bloomberg') || strcmpi(conn,'Wind'))
                    error('cContract:initTimeSeries:Invalid Connection input!');
                end
                if strcmpi(conn,'Bloomberg') 
                    isBBG = 1;
                else
                    isBBG = 0;
                end
                if strcmpi(conn,'Wind')
                    isWIND = 1;
                else
                    isWIND = 0;
                end
            end
            tsobjs = cell(size(freq,2),isBBG+isWIND);
            
            if isBBG
                bcode = obj.BloombergCode;
                if ~isempty(bcode)
                    try
                        ts_b = initTimeSeriesBloomberg(obj,varargin{:});
                        for i = 1:size(ts_b,1)
                            tsobjs{i,isBBG} = ts_b{i,1};
                        end
                    catch me
                        disp(me.message);
                    end
                end
            end
            %
            
            if isWIND
                wcode = obj.WindCode;
                if ~isempty(wcode)
                    try
                        ts_w = initTimeSeriesWind(obj,varargin{:});
                        for i = 1:size(ts_w,1)
                            tsobjs{i,isWIND+isBBG} = ts_w{i,1};
                        end
                    catch me
                        disp(me.message);
                    end
                end
            end
        end
        %
        
        function tsobjsNew = updateTimeSeries(obj,varargin) % update cell of cTimeSeries objects
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            p.addParameter('Frequency',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','Frequency'));
            p.addParameter('Connection',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','Connection'));
            %updatefile controls whether to write data to the local file
            p.addParameter('UpdateLocalFile','yes',...
                @(x) validateattributes(x,{'char'},{},'','UpdateLocalFile'));
            p.parse(varargin{:});
            updateLocalFile = p.Results.UpdateLocalFile;
            freq = p.Results.Frequency;
            conn = p.Results.Connection;
            
            if ~(strcmpi(updateLocalFile,'yes') || strcmpi(updateLocalFile,'no'))
               error('cContract:updateTimeSeries:Invalid UpdateLocalFile input!'); 
            end
            
            if isempty(freq)
                freq = {'1d','1m','tick'}; 
            end
            if ischar(freq)
                freq = regexp(freq,',','split');
                if ischar(freq)
                    freq = {freq};
                end
            end
            updateDaily = 0;
            updateIntradayBar = 0;
            updateTick = 0;
            for i = 1:length(freq)
                if strcmpi(freq{i},'1d')
                    updateDaily = 1;
                elseif strcmpi(freq{i},'1m')
                    updateIntradayBar = 1;
                elseif strcmpi(freq{i},'tick')
                    updateTick = 1;
                end
            end
                
            if isempty(conn)
                updateBloomberg = 1;
                updateWind = 1;
            else
                updateBloomberg = 0;
                updateWind = 0;
                if ischar(conn)
                    conn = regexp(conn,',','split');
                    if ischar(conn)
                        conn = {conn};
                    end
                end
                for i = 1:length(conn)
                    if ~(strcmpi(conn{i},'Bloomberg') || strcmpi(conn{i},'Wind'))
                        error('cContract:updateTimeSeries:Invalid Connection input!'); 
                    end
                    if strcmpi(conn{i},'Bloomberg')
                        updateBloomberg = 1;
                    elseif strcmpi(conn{i},'Wind')
                        updateWind = 1;
                    end   
                end
            end
            
            if strcmpi(updateLocalFile,'yes')
                updateLocalFile = true;
            else
                updateLocalFile = false;
            end
            expiry = obj.Expiry;
            if expiry + 30 < today
                %nothing to do in case the expiry date is 30 days before
                %the current date
                return
            end
            %listTimeSeriesObjs just read the data from file saved locally
            tsobjsOld = obj.listTimeSeriesObjs;
            runinit = 0;
            if isempty(tsobjsOld{1,1}) && updateBloomberg && updateDaily
                obj.initTimeSeries('connection','bloomberg','frequency','1d','datasource','internet');
                runinit = 1;
            end
            
            if isempty(tsobjsOld{2,1}) && updateBloomberg && updateIntradayBar
                obj.initTimeSeries('connection','bloomberg','frequency','1m','datasource','internet');
                runinit = 1;
            end
            
            if isempty(tsobjsOld{2,1}) && updateBloomberg && updateTick
                obj.initTimeSeries('connection','bloomberg','frequency','tick','datasource','internet');
                runinit = 1;
            end
            
            if isempty(tsobjsOld{1,2}) && updateWind && updateDaily
                obj.initTimeSeries('connection','bloomberg','frequency','1d','datasource','internet');
                runinit = 1;
            end
            
            if isempty(tsobjsOld{2,2}) && updateWind && updateIntradayBar
                obj.initTimeSeries('connection','bloomberg','frequency','1m','datasource','internet');
                runinit = 1;
            end
            
            if isempty(tsobjsOld{3,2}) && updateWind && updateTick
                obj.initTimeSeries('connection','bloomberg','frequency','tick','datasource','internet');
                runinit = 1;
            end
            
            if runinit
                tsobjsOld = obj.listTimeSeriesObjs;
            end
                
            tsobjsNew = cell(updateDaily+updateIntradayBar+updateTick,updateBloomberg+updateWind);
            for i = 1:size(tsobjsOld,1)
                if i == 1
                    rIdx = updateDaily;
                elseif i == 2
                    rIdx = updateDaily+updateIntradayBar;
                else
                    rIdx = updateDaily+updateIntradayBar+updateTick;
                end
                for j = 1:size(tsobjsOld,2)
                    if j == 1
                        cIdx = updateBloomberg;
                    else
                        cIdx = updateBloomberg + updateWind;
                    end
                    tsobjOld = tsobjsOld{i,j};
                    if isempty(tsobjOld)
                        update = 0;
                    else
                    %check whether to update
                        if strcmpi(tsobjOld.Frequency,'1d') && updateDaily
                            update = 1;
                        elseif strcmpi(tsobjOld.Frequency,'1m') && updateIntradayBar
                            update = 1;
                        elseif strcmpi(tsobjOld.Frequency,'tick') && updateTick
                            update = 1;
                        else
                            update = 0;
                        end
                        if isempty(tsobjOld.Codes{1}) && ~isempty(tsobjOld.Codes{2})
                            isBloomberg = 0;
                        elseif ~isempty(tsobjOld.Codes{1}) && isempty(tsobjOld.Codes{2})
                            isBloomberg = 1;
                        else
                            error('unknown error');
                        end
                        if isBloomberg
                            update = update * updateBloomberg;
                        else
                            update = update * updateWind;
                        end
                    end
                    
                    if ~isempty(tsobjOld) && isa(tsobjOld,'cTimeSeries') && update == 1
                        tsobjNew = tsobjOld.updateTimeSeries;
                        if j == 1
                            %the 1st column is the bloomberg one
                            if updateLocalFile
                                tsobjNew.writeTimeSeries2File('FileName',...
                                            obj.TimeSeriesFileNames.bfiles{i,1});
                            end
                        else
                            if updateLocalFile
                                tsobjNew.writeTimeSeries2File('FileName',...
                                            obj.TimeSeriesFileNames.wfiles{i,1});
                            end
                        end
                        tsobjsNew{rIdx,cIdx} = tsobjNew;
                    else
                        if isempty(tsobjOld) && update == 1
                            %local file cannot be found in most cases
                            error('cContract:updateTimeSeries:cannot found timeseries to be updated');
                        end
                    end
                end
            end   
        end
        %
        
    end
    %methods end
    
    methods (Access = private)
        %
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('AssetName',{},...
                @(x) validateattributes(x,{'char'},{},'','AssetName'));
            p.addParameter('Tenor',{},...
                @(x) validateattributes(x,{'char'},{},'','Tenor'));
            p.parse(varargin{:});
            %
            obj.AssetName = p.Results.AssetName;
            obj.Tenor = p.Results.Tenor;
            %sanity checks
            if isempty(obj.AssetName)
                error('cContract:invalid or empty input of AssetName');
            end
        end
        %
        
        function tsobjs = initTimeSeriesBloomberg(obj,varargin)
            bcode = obj.BloombergCode;
            expiry = obj.Expiry;
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Frequency',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','Frequency'));
            p.addParameter('TickFields',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','TickFields'));
            p.addParameter('DataSource','local',...
                @(x) validateattributes(x,{'char'},{},'','DataSource'));
            p.addParameter('UpdateLocalFile','yes',...
                @(x) validateattributes(x,{'char'},{},'','UpdateLocalFile'));
            p.parse(varargin{:});
            freq = p.Results.Frequency;
            tickFields = p.Results.TickFields;
            dataSource = p.Results.DataSource;
            updateLocalFile = p.Results.UpdateLocalFile;
            if isempty(freq)
                %default interval:daily,intra-day 1 minute and tick data
                freq = {'1d','1m','tick'};
            end
            if ischar(freq)
                freq = {freq};
            end
            if isempty(tickFields)
                tickFields = 'trade';
            end
            if ~(strcmpi(dataSource,'local') || strcmpi(dataSource,'internet'))
                error('error:cContract:initTimeSeriesBloomberg:invalid datasource input,must be either "local" or "internet"!');
            end
            %
            tsobjs = cell(size(freq,2),1);
            %
            for i = 1:size(freq,2)
                freq_i = freq{i};
                if strcmpi(freq_i,'1d')
                    filename = obj.TimeSeriesFileNames.bfiles{1,1};
                elseif strcmpi(freq_i,'1m')
                    filename = obj.TimeSeriesFileNames.bfiles{2,1};
                elseif strcmpi(freq_i,'tick')
                    filename = obj.TimeSeriesFileNames.bfiles{3,1};
                end
                
                if strcmpi(dataSource,'local')
                    flag = isfile(filename);
                    if ~flag
                        error(['cContract:initTimeSeriesBloomberg:no file named "',...
                            filename,'" found!']);
                    end
                    tsobjs{i,1} = cTimeSeries('FileName',filename);
                else
                    if strcmpi(expiry,'n/a')
                        % no expiry information is available in Bloomberg
                        tsobjs{i,1} = cTimeSeries;
                        return
                    end
                    %
                    lastbd = businessdate(today,-1);
                    if strcmpi(freq_i,'1d')
                        fields = {'px_open','px_high','px_low'...
                                      'px_last','volume','open_int'};
                        % 1 year time window in case it is available
                        fromDate = min(datenum(expiry)-365,lastbd-365);
                        toDate = min(datenum(expiry),lastbd);          
                    elseif strcmpi(freq_i,'1m') 
                        fields = {'trade'};
                        freq_i = 1;
                        % 6 month time window in case it is available
                        fromDate = [datestr(min(datenum(expiry)-180,lastbd-180),'yyyy-mm-dd'),' 09:00:00'];
                        toDate = [datestr(min(datenum(expiry),lastbd),'yyyy-mm-dd'),' 15:15:00'];
                    elseif strcmpi(freq_i,'tick')
                        fields = tickFields;
                        %initilization with the last business day tick data
                        fromDate = [datestr(lastbd,'yyyy-mm-dd'),' 09:00:00'];
                        toDate = [datestr(lastbd,'yyyy-mm-dd'),' 15:15:00'];
                    end
                    c = bbgconnect;
                    tsobjs{i,1} = cTimeSeries('Connection',c,...
                                              'BloombergCode',bcode,...
                                              'Fields',fields,...
                                              'FromDate',fromDate,...
                                              'ToDate',toDate,...
                                              'Frequency',freq_i);
                    if strcmpi(updateLocalFile,'yes')
                        tsobjs{i,1}.writeTimeSeries2File('FileName',filename);
                    end
                    close(c);
                end
            end
        end
        %
        
        %
        function tsobjs = initTimeSeriesWind(obj,varargin)
            wcode = obj.WindCode;
            expiry = obj.Expiry;
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Frequency',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','Frequency'));
            p.addParameter('TickFields',{},...
                @(x) validateattributes(x,{'cell','char'},{},'','TickFields'));
            p.addParameter('DataSource','local',...
                @(x) validateattributes(x,{'char'},{},'','DataSource'));
            p.addParameter('UpdateLocalFile','yes',...
                @(x) validateattributes(x,{'char'},{},'','UpdateLocalFile'));
            p.parse(varargin{:});
            freq = p.Results.Frequency;
            tickFields = p.Results.TickFields;
            dataSource = p.Results.DataSource;
            updateLocalFile = p.Results.UpdateLocalFile;
            if isempty(freq)
                %default interval:daily,intra-day 1 minute and tick data
                freq = {'1d','1m','tick'};    %todo:handle tick data
            end
            if ischar(freq)
                freq = {freq};
            end
            if isempty(tickFields)
                tickFields = 'last';
            end
            if ~(strcmpi(dataSource,'local') || strcmpi(dataSource,'internet'))
                error('error:cContract:initTimeSeriesWind:invalid datasource input,must be either "local" or "internet"!');
            end
            
            tsobjs = cell(size(freq,2),1);
            %
            for i = 1:size(freq,2)
                freq_i = freq{i};
                if strcmpi(freq_i,'1d')
                    filename = obj.TimeSeriesFileNames.wfiles{1,1};
                elseif strcmpi(freq_i,'1m')
                    filename = obj.TimeSeriesFileNames.wfiles{2,1};
                elseif strcmpi(freq_i,'tick')
                    filename = obj.TimeSeriesFileNames.wfiles{3,1};
                end
                if strcmpi(dataSource,'local')
                    flag = isfile(filename);
                    if ~flag
                        error(['cContract:initTimeSeriesWind:no file named "',...
                            filename,'" found!']);
                    end
                    tsobjs{i,1} = cTimeSeries('FileName',filename);    
                else
                    lastbd = businessdate(today,-1);
                    if strcmpi(freq_i,'1d')
                        fields = 'open,high,low,close,volume,oi';
                        % 1 year time window in case it is available
                        fromDate = min(datenum(expiry)-365,lastbd-365);
                        toDate = min(datenum(expiry),lastbd);   
                    elseif strcmpi(freq_i,'1m')
                        fields = 'open,high,low,close,volume';
                        freq_i = 1;
                        % 6 month time window in case it is available
                        fromDate = min(datenum(expiry)-180,lastbd-180);
                        toDate = min(datenum(expiry),lastbd);         
                    elseif strcmpi(freq_i,'tick')
                        fields = tickFields;
                        fromDate = [datestr(lastbd,'yyyy-mm-dd'),' 09:00:00'];
                        toDate = [datestr(lastbd,'yyyy-mm-dd'),' 15:15:00'];
                    end
                    w = windconnect;
                    tsobjs{i,1} = cTimeSeries('Connection',w,...
                                              'WindCode',wcode,...
                                              'Fields',fields,...
                                              'FromDate',fromDate,...
                                              'ToDate',toDate,...
                                              'Frequency',freq_i);
                    if strcmpi(updateLocalFile,'yes')
                        tsobjs{i,1}.writeTimeSeries2File('FileName',filename);
                    end
                end
            end
        end
        %
        
        
    end
    %methods end
end

