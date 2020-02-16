classdef cStratConfig < handle
    %class cStratConfig
    %used in trading for storing all parameters
    
    properties (GetAccess = public, SetAccess = public)
        name_@char
        
        codectp_@char
        
        samplefreq_@char = '5m'       %sample frequency, e.g. 5m, 15m
        
        %risk related
        riskmanagername_@char = 'standard'
        stoptypepertrade_@char = 'rel'     % rel or abs
        stopamountpertrade_@double = -9.99          
        limittypepertrade_@char = 'rel'    % rel or abs
        limitamountpertrade_@double = -9.99
        %todo:
        %we shall add stop/limit per asset as well going forward
               
        %order/entrust related
        %positive bid spread means to order a sell with a higher price
        bidopenspread_@double = 0
        bidclosespread_@double = 0
        %positive ask spread means to order a buy with a lower price
        askopenspread_@double = 0
        askclosespread_@double = 0
        
        %size related
        baseunits_@double = 0
        maxunits_@double = 0
        
        %automatic trading?
        autotrade_@double = 0
        %
        use_@double = 0
        
    end
    
    properties ( Dependent = true )
        instrument_@cInstrument
    
    end
    
    methods
        function obj = cStratConfig(varargin)
           p = inputParser;
           p.CaseSensitive = false; p.KeepUnmatched = true;
           p.addParameter('code','',@ischar);
           p.parse(varargin{:});
           code = p.Results.code;
           obj.codectp_ = code;
           obj.name_ = 'cStratConfig';
        end
        
    end
    
    methods
        function instrument = get.instrument_(obj)
            if ~isempty(obj.codectp_)
                instrument = code2instrument(obj.codectp_);
            else
                instrument = [];
            end
        end
        
        function [] = set.stoptypepertrade_(obj,typein)
            if ~(strcmpi(typein,'abs') ||...
                    strcmpi(typein,'rel') ||...
                    strcmpi(typein,'opt'))
                error([class(obj),':invalid stoptypepertrade_'])
            end
            obj.stoptypepertrade_ = typein;
        end
        
        function [] = set.limittypepertrade_(obj,typein)
            if ~(strcmpi(typein,'abs') ||...
                    strcmpi(typein,'rel')||...
                    strcmpi(typein,'opt'))
                error([class(obj),':invalid limitamountpertrade_'])
            end
            obj.limittypepertrade_ = typein;
        end
        
        function [] = set.stopamountpertrade_(obj,val)
            if val > 0, val = -val;end
            obj.stopamountpertrade_ = val;
        end
        
        function [] = set.limitamountpertrade_(obj,val)
            if val == -9.99
                obj.limitamountpertrade_ = val;
            else
                obj.limitamountpertrade_ = abs(val);
            end
        end
        
        function [] = set.riskmanagername_(obj,val)
            if ~(strcmpi(val,'standard') ||...
                    strcmpi(val,'batman') ||...
                    strcmpi(val,'wrstep') ||...
                    strcmpi(val,'stairs') ||...
                    strcmpi(val,'spiderman'))
                error([class(obj),':invalid riskmanagername_'])
            end
            obj.riskmanagername_ = val;
        end
        
    end
    
    methods
        [] = loadfromfile(obj,varargin)
        [ret] = isequal(obj,anotherconfig)
        function [] = setname(obj,namestr)
            obj.name_ = namestr;
        end
    end
    
    methods (Static = true)
        [] = demo()
    end
    
end

