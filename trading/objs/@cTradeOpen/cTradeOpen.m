classdef cTradeOpen < handle
    %class to define open trade position
    properties
        id_
        bookname_@char
        tradername_@char
        countername_@char
        code_@char
        opendatetime1_@double
        openprice_@double
        opendirection_@double
        openvolume_@double
        stopdatetime1_@double
        closedatetime1_@double
        closeprice_@double
        runningpnl_@double
        closepnl_@double
        status_@char
        %
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent = true)
        opendatetime2_@char
        stopdatetime2_@char
        closedatetime2_@char
        instrument_@cInstrument
    end
    
    properties
        %properties with data types defined as self-defined class
        opensignal_@cSignalInfo
        riskmanager_@cTradeRiskManager
    end
    
    methods
        function obj = cTradeOpen(varargin)
            obj = init(obj,varargin{:});
        end
        
        function set.status_(obj,status)
            if ~(strcmpi(status,'unset') || strcmpi(status,'set') ||...
                    strcmpi(status,'closed'))
                error('cTradeOpen:invalid status')
            end
            obj.status_ = status;
        end
        
        function set.opendirection_(obj,direction)
            if ~isempty(direction)
                if ~(direction == 1 || direction == -1), error('cTrade:invalid open direction');end
                obj.opendirection_ = direction;
            end
        end
        
        function set.openvolume_(obj,volume)
            if ~isempty(volume)
                if volume <= 0, error('cTrade:invalid open volume');end
                obj.openvolume_ = volume;
            end
        end
        
        function set.openprice_(obj,price)
            if ~isempty(price)
                if price <= 0, error('cTrade:invalid open price');end
                obj.openprice_ = price;
            end
        end
        
        function instrument = get.instrument_(obj)
            if ~isempty(obj.code_)
                instrument = code2instrument(obj.code_);
            else
                instrument = [];
            end
        end
        
        function opendatetime2 = get.opendatetime2_(obj)
            if ~isempty(obj.opendatetime1_)
                opendatetime2 = datestr(obj.opendatetime1_,'yyyy-mm-dd HH:MM:SS');
            else
                opendatetime2 = '';
            end
        end
        
        function stopdatetime2 = get.stopdatetime2_(obj)
            if ~isempty(obj.stopdatetime1_)
                stopdatetime2 = datestr(obj.stopdatetime1_,'yyyy-mm-dd HH:MM:SS');
            else
                stopdatetime2 = '';
            end
        end
        
        function closedatetime2 = get.closedatetime2_(obj)
            if ~isempty(obj.closedatetime1_)
                closedatetime2 = datestr(obj.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
            else
                closedatetime2 = '';
            end
        end
        
        %todo:set with class variables rather than struct variables
        [] = setsignalinfo(obj,varargin)
        [] = setriskmanager(obj,varargin)
        [data,headers] = tradeopen2table(obj)
        [obj] = table2tradeopen(obj,headers,data)
        [newtrade] = copy(obj)
        [data,headers] = tradeopen2table2(obj)
        [obj] = table2tradeopen2(obj,headers,data)
        
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [] = setriskmanager_standard(obj,varargin)
        [] = setriskmanager_batman(obj,varargin)
        [] = setriskmanager_wrstep(obj,varargin) 
        [] = setriskmanager_stairs(obj,varargin)
    end
    
    methods (Static = true)
        [] = demo()
    end
    
end

