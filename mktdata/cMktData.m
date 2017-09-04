classdef cMktData < cObj
    %class for Market Data
    properties
        AssetName
        ValuationDate
        Currency
        Type
        Spot
%         Repo
        Dividends
    end
    
    methods
        function valdate = get.ValuationDate(obj)
            valdate = datestr(obj.ValuationDate,'yyyy-mm-dd');
        end
    end
    
    methods (Access = public)
        function obj = cMktData(objhandle,varargin)
            obj = init(obj,objhandle,varargin{:});
        end
        
        function objDecayed = DecayMktData(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('DecayDate',{},...
                 @(x) validateattributes(x,{'char','numeric'},{},'DecayDate'));
            p.parse(varargin{:});
            decayedDate = datenum(p.Results.DecayDate);
            objDecayed = obj;
            objDecayed.ValuationDate = decayedDate;
        end
        
        function objNew = ModifyMktData(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('PropertyName',{},...
                @(x) validateattributes(x,{'char'},{},'PropertyName'));
            p.addParameter('BumpSize',{},...
                @(x) validateattributes(x,{'numeric'},{},'BumpSize'));
            p.addParameter('BumpType',{},...
                @(x) validateattributes(x,{'char'},{},'BumpType'));
            p.parse(varargin{:});
            propName = p.Results.PropertyName;
            bumpSize = p.Results.BumpSize;
            bumpType = p.Results.BumpType;
            objNew = obj;
            if strcmpi(propName,'Spot')
                spotOld = obj.Spot;
                if strcmpi(bumpType,'ABS')
                    spotNew = spotOld+bumpSize;
                elseif strcmpi(bumpType,'REL')
                    spotNew = spotOld*(1+bumpSize);
                elseif strcmpi(bumpType,'EXACT')
                    spotNew = bumpSize;
                else
                    error('cMktData:ModifyMktData:invalid bump type');
                end
                objNew.Spot = spotNew;
            end
        end
       
        function fwd = MktDataFwd(obj,date,yc)
            if ~isa(yc,'cYieldCurve')
                error('cMktData:MktDataFwd:missing yieldcurve input!');
            end
            if ~strcmpi(obj.Currency,yc.Currency)
                error('cMktData:MktDataFwd:the currency shall be the same as the currency of the yield curve!');
            end
            dateIn = date;
            if ~isnumeric(dateIn)
                dateIn = datenum(date);
            end
            if strcmpi(obj.Type,'FORWARD')
                fwd = obj.Spot;
            else
                df = yc.DiscFact(dateIn);
                npv = 0;
                for i = 1:size(obj.Dividends)
                    if datenum(obj.Dividends(i,1)) <= dateIn && datenum(obj.Dividends(i,1)) >= obj.ValuationDate
                        dfi = yc.DiscFact(obj.Dividends(i,1));
                        di = obj.Dividends(i,2);
                        npv = npv+dfi*di;
                    end
                end
                fwd = obj.Spot/df - npv;
            end
            
            %todo:not finished yet
            
            
        end
        
        
        
    end
    
    methods (Access = private)
        function obj = init(obj,objhandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('ObjHandle',@ischar);
            p.addParameter('AssetName',{},...
                @(x) validateattributes(x,{'char'},{},'','AssetName'));
            p.addParameter('ValuationDate',{},...
                @(x) validateattributes(x,{'char','numeric'},{},'','ValuationDate'));
            p.addParameter('Currency','CNY',...
                @(x) validateattributes(x,{'char'},{},'','Currency'));
            p.addParameter('Type','FORWARD',...
                @(x) validateattributes(x,{'char'},{},'','Type'));
            p.addParameter('Spot',{},...
                @(x) validateattributes(x,{'numeric'},{},'','Spot'));
            p.addParameter('Dividends',{},...
                @(x) validateattributes(x,{'numeric'},{},'','Dividends'));
            %other parameters
            p.parse(objhandle,varargin{:});
            obj.ObjHandle = p.Results.ObjHandle;
            obj.ObjType = 'MKTDATA';
            obj.AssetName = p.Results.AssetName;
            obj.ValuationDate = datenum(p.Results.ValuationDate);
            obj.Currency = p.Results.Currency;
            obj.Type = p.Results.Type;
            if ~(strcmpi(obj.Type,'FORWARD') || strcmpi(obj.Type,'EQUITY'))
                error('cMktData:init:invalid type input');
            end
            obj.Spot = p.Results.Spot;
            obj.Dividends = p.Results.Dividends;
            if isempty(obj.Dividends)
                
            end
            
        end
    end
    
end