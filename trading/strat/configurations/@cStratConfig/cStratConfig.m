classdef cStratConfig < handle
    %class cStratConfig
    %used in trading for storing all parameters
    
    properties (GetAccess = public, SetAccess = public)
        name_@char
        
        codectp_@char
        
        samplefreq_@char = '5m'       %sample frequency, e.g. 5m, 15m
        
        pnlstoptype_@char = 'abs'     % rel or abs
        pnlstop_@double = -9.99          
        pnllimittype_@char = 'abs'    % rel or abs
        pnllimit_@double = -9.99       
               
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
        
        function [] = set.pnlstoptype_(obj,typein)
            if ~(strcmpi(typein,'abs') || strcmpi(typein,'rel'))
                error([class(obj),':invalid pnl_stop_type_'])
            end
            obj.pnlstoptype_ = typein;
        end
        
        function [] = set.pnllimittype_(obj,typein)
            if ~(strcmpi(typein,'abs') || strcmpi(typein,'rel'))
                error([class(obj),':invalid pnl_stop_type_'])
            end
            obj.pnllimittype_ = typein;
        end
        
        function [] = set.pnlstop_(obj,val)
            if val > 0, val = -val;end
            obj.pnlstop_ = val;
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

