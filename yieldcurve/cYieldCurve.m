classdef cYieldCurve < cObj
    % class of yield curve
    properties
        ValuationDate
        Currency
        DiscountBasis
        Compounding
        Type
    end
    
    properties (GetAccess = private, SetAccess = private)
        pIRDataCurve@IRDataCurve
    end
    
    methods
        %SET/GET methods
        function valdate = get.ValuationDate(obj)
            valdate = datestr(obj.ValuationDate,'yyyy-mm-dd');
        end
        
    end
    
    methods
        function objDecayed = DecayYieldCurve(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('DecayDate',{},...
                 @(x) validateattributes(x,{'char','numeric'},{},'DecayDate'));
            p.parse(varargin{:});
            decayDate = datenum(p.Results.DecayDate);
            if isempty(obj.pIRDataCurve)
                objDecayed = obj;
                objDecayed.ValuationDate = decayDate;
            else
                %need to re-bootstrap the decayed curve
            end
        end
        
        
        function df = DiscFact(obj,date)
            if isempty(obj.pIRDataCurve)
                df = 1;
            else
                df = obj.pIRDataCurve.getDiscountFactors(date);
            end
        end
        
        function r = ZeroRate(obj,date)
            if isempty(obj.pIRDataCurve)
                r = 0;
            else
                r = obj.pIRDataCurve.getZeroRates(date);
            end
        end
        
%         function f = FwdRate(obj,date)
%             r = bootModel.getForwardRates(
%         end
    end
    
    methods (Access = public)
        function obj = cYieldCurve(objhandle,varargin)
            obj = init(obj,objhandle,varargin{:});
        end
    end
    
    methods (Access = private)
        function obj = init(obj,objhandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('ObjHandle',@ischar);
            p.addParameter('ValuationDate',{},...
                @(x) validateattributes(x,{'char','numeric'},{},'','ValuationDate'));
            p.addParameter('Currency','CNY',...
                @(x) validateattributes(x,{'char'},{},'','Currency'));
            p.addParameter('DiscountBasis','ACT/365',...
                @(x) validateattributes(x,{'char'},{},'','DiscountBasis'));
            p.addParameter('Compounding',-1,@isscalar);
            p.addParameter('Type','Zero',@ischar);
            p.addParameter('Dates',{},...
                @(x) validateattributes(x,{'cell','numeric'},{},'','Dates'));
            p.addParameter('Rates',[],@isnumeric);
            %other parameters
            p.parse(objhandle,varargin{:});
            obj.ObjHandle = p.Results.ObjHandle;
            obj.ObjType = 'YIELDCURVE';
            obj.ValuationDate = datenum(p.Results.ValuationDate);
            obj.Currency = p.Results.Currency;
            obj.DiscountBasis = p.Results.DiscountBasis;
            obj.Compounding = p.Results.Compounding;
            obj.Type = p.Results.Type;
            if ~strcmpi(obj.Type,'Zero')
                error('cYieldCurve:invalid curve type,only ZERO is valid')
            end
            dates = p.Results.Dates;
            rates = p.Results.Rates;
            if ~isempty(dates) && ~isempty(rates)
                obj.pIRDataCurve = IRDataCurve(obj.Type,obj.ValuationDate,dates,rates,...
                    'Compounding',obj.Compounding,'Basis',basis2num(obj.DiscountBasis));
            else
%                 obj.pIRDataCurve = {};
            end
            
            
        end
        
        function obj = bootstrap(obj)
            
        end
    end
end