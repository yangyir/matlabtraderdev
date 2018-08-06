classdef cTradeOpen < handle
    %class to define open trade position
    properties
        id_
        countername_@char
        bookname_@char
        code_@char
        instrument_@cInstrument
        opendatetime1_@double
        opendatetime2_@char
        openprice_@double
        opendirection_@double
        openvolume_@double
        stopdatetime1_@double
        stopdatetime2_@char
        closedatetime1_@double
        closedatetime2_@char
        closeprice_@double
        runningpnl_@double
        closepnl_@double
        status_@char
        %
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
              
        [] = update(obj,varargin)
        [] = setsignalinfo(obj,varargin)
        [] = setriskmanager(obj,varargin)
        
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
    
    methods (Static = true)
        [] = demo()
    end
    
end

