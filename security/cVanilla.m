classdef cVanilla < cSecurity
    % class of vanilla option, i.e. European or American
    properties (Access = public)
        Underlier
        Strike
        OptionType
        IssueDate
        ExpiryDate
        Notional
        RateCurrency
        PayCurrency
        ReferenceSpot
        AmericanFlag
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent)
        AssetName
    end
    
    methods %SET/GET methods
        function assetname = get.AssetName(obj)
            assetname = obj.Underlier.WindCode(1:end-4);
        end
        
        function expiry = get.ExpiryDate(obj)
            expiry = datestr(obj.ExpiryDate,'yyyy-mm-dd');
        end
        
        function issueDate = get.IssueDate(obj)
            issueDate = datestr(obj.IssueDate,'yyyy-mm-dd');
        end
        
        function obj = set.OptionType(obj,type)
            if ~(strcmpi(type,'c') || strcmpi(type,'p') || ...
                strcmpi(type,'call') || strcmpi(type,'put') || ...
                strcmpi(type,'straddle'))
                error('cEuropean:invalid option type');
            end
            if strcmpi(type,'c') || strcmpi(type,'call')
                obj.OptionType = 'Call';
            elseif strcmpi(type,'p') || strcmpi(type,'put')
                obj.OptionType = 'Put';
            else
                obj.OptionType = 'Straddle';
            end 
        end
        
    end
    
    methods (Access = public)
        function obj = cVanilla(objhandle,varargin)
            obj = init(obj,objhandle,varargin{:});
        end
    end
    
    methods (Access = private)
        function obj = init(obj,objhandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('ObjHandle',@ischar);
            p.addParameter('Underlier',{},...
                @(x) validateattributes(x,{'cContract','char'},{},'','Underlier'));
            p.addParameter('Strike',100,...
                @(x) validateattributes(x,{'numeric'},{},'','Strike'));
            p.addParameter('OptionType','C',...
                @(x) validateattributes(x,{'char'},{},'','OptionType'));
            p.addParameter('IssueDate',{},...
                @(x) validateattributes(x,{'char','numeric'},{},'','IssueDate'));
            p.addParameter('ExpiryDate',{},...
                @(x) validateattributes(x,{'char','numeric'},{},'','ExpiryDate'));
            p.addParameter('Notional',1,...
                @(x) validateattributes(x,{'numeric'},{},'','Notional'));
            p.addParameter('RateCurrency',{},...
                @(x) validateattributes(x,{'char'},{},'','RateCurrency'));
            p.addParameter('PayCurrency',{},...
                @(x) validateattributes(x,{'char'},{},'','PayCurrency'));
            p.addParameter('ReferenceSpot',{},...
                @(x) validateattributes(x,{'numeric'},{},'','ReferenceSpot'));
            p.addParameter('AmericanFlag',false,@islogical);
           
            p.parse(objhandle,varargin{:});
            obj.ObjHandle = p.Results.ObjHandle;
            obj.ObjType = 'SECURITY';
            obj.SecurityName = 'VANILLA';
            obj.Underlier = p.Results.Underlier;
            obj.Strike = p.Results.Strike;
            obj.OptionType = p.Results.OptionType;
            obj.IssueDate = datenum(p.Results.IssueDate);
            obj.ExpiryDate = datenum(p.Results.ExpiryDate);
            obj.Notional = p.Results.Notional;
            obj.RateCurrency = p.Results.RateCurrency;
            obj.PayCurrency = p.Results.PayCurrency;
            obj.ReferenceSpot = p.Results.ReferenceSpot;
            if isempty(obj.RateCurrency)
                obj.RateCurrency = 'CNY';
            end
            if isempty(obj.PayCurrency)
                obj.PayCurrency = obj.RateCurrency;
            end
            obj.AmericanFlag = p.Results.AmericanFlag;
               
        end
        
    end
end