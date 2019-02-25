classdef cSyntheticStraddle < handle
    
    properties
        id_
        code_@char
        callleg_@cTradeOpen
        putleg_@cTradeOpen
        strike_@double
        notional_@double
        stopdatetime1_@double   %the expiry datetime of the synthetic straddle
        callcost_@double        %the premium of the synthetic call on open
        putcost_@double         %the premium of the synthetic put on open
        calldelta_@double
        putdelta_@double
        
    end
    
    properties (Dependent = true, SetAccess = private, GetAccess = public)
        bookname_@char
        tradername_@char
        countername_@char
        opendatetime1_@double
        opendatetime2_@double
        stopdatetime2_@double
        closedatetime1_@double
        closedatetime2_@double
        runningpnl_@double
        closepnl_@double
        status_@char
    end
    
    methods
        function obj = cSyntheticStraddle(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        function bookname = get.bookname_(obj)
            if ~isempty(obj.callleg_)
                bookname = obj.callleg_.bookname_;
            else
                bookname = '';
            end
        end
        %
        function tradername = get.tradername_(obj)
            if ~isempty(obj.callleg_)
                tradername = obj.callleg_.tradername_;
            else
                tradername = '';
            end
        end
        %
        function countername = get.countername_(obj)
            if ~isempty(obj.callleg_)
                countername = obj.callleg_.countername_;
            else
                countername = '';
            end
        end
        %
        function opendatetime1 = get.opendatetime1_(obj)
            if ~isempty(obj.callleg_)
                opendatetime1 = obj.callleg_.opendatetime1_;
            else
                opendatetime1 = [];
            end
        end
        %
        function opendatetime2 = get.opendatetime2_(obj)
            if ~isempty(obj.callleg_)
                opendatetime2 = obj.callleg_.opendatetime2_;
            else
                opendatetime2 = '';
            end
        end
        %
        function stopdatetime2 = get.stopdatetime2_(obj)
            if ~isempty(obj.stopdatetime1_)
                stopdatetime2 = datestr(obj.stopdatetime1_,'yyyy-mm-dd HH:MM:SS');
            else
                stopdatetime2 = '';
            end
        end
        %
        function closedatetime1 = get.closedatetime1_(obj)
            if ~isempty(obj.callleg_)
                closedatetime1 = obj.callleg_.closedatetime1_;
            else
                closedatetime1 = [];
            end
        end
        %
        function closedatetime2 = get.closedatetime2_(obj)
            if ~isempty(obj.callleg_)
                closedatetime2 = obj.callleg_.closedatetime2_;
            else
                closedatetime2 = '';
            end
        end
        %
        function runningpnl = get.runningpnl_(obj)
            runningpnl = 0;
            if ~isempty(obj.callleg_)
                runningpnl = obj.callleg_.runningpnl_ + obj.putleg_.runningpnl_;                
            end
        end
        %
        function closepnl = get.closepnl_(obj)
            closepnl = 0;
            if ~isempty(obj.callleg_)
                closepnl = obj.callleg_.closepnl_ + obj.putleg_.closepnl_;                
            end
        end
        %
        function status = get.status_(obj)
            status = 'unset';
            if ~isempty(obj.callleg_)
                status = obj.callleg_.status_;
            end
        end

    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
    
end