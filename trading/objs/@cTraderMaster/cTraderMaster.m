classdef cTraderMaster < handle
    %class of a master trader who can have access to multiple trading
    %accounts and link 
    properties
        mdefut_@cMDEFut
        mdeopt_@cMDEOpt
        counterfut_@CounterCTP
        counteropt1_@CounterCTP
        counteropt2_@CounterCTP
    end
    
    properties (Hidden = true)
        qms_@cQMS
    end
    
    methods
        function obj = cTraderMaster
            obj = init(obj);
        end
    end
    
    methods (Access = private)
        function obj = init(obj)
            if ~isempty(obj.counterfut_) || ...
                    ~isa(obj.counterfut_,'CounterCTP') || ...
                    (isa(obj.counterfut_,'CounterCTP') && ~strcmpi(obj.counterfut_.char,'citic_kim_fut'))
                try
                    obj.counterfut_.logout;
                catch
                end
                obj.counterfut_ = CounterCTP.citic_kim_fut;
            end
            if ~obj.counterfut_.is_Counter_Login, obj.counterfut_.login;end
                
                    
                
%             obj.counteropt1_ = CounterCTP.ccb_liyang_fut;
%             obj.counteropt2_ = CounterCTP.huaxin_liyang_fut;
%             obj.qms_ = cQMS;
%             obj.qms_.setdatasource('ctp');
%             obj.mdefut_ = cMDEFut;
%             obj.mdefut_.qms_ = obj.qms_;
%             obj.mdeopt_ = cMDEOpt;
%             obj.mdeopt_.qms_ = obj.qms_;
        end
    end
end