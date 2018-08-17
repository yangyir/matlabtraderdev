classdef cPos < handle
    properties
        code_ctp_@char
        direction_@double
        position_total_@double
        position_today_@double
        cob_date1_ = today
        cost_carry_@double
        cost_open_@double
        %note:yangyiran:20180817
        %property 'cost_carry_' may be removed later as it is not essential
        %for either pnl or risk management, but only a demo purpose
    end
    
    properties (Dependent)
        instrument_@cInstrument
        cob_date2_@char
        is_opt_@double
    end
    
    %get methods for dependent variables
    methods
        function d2 = get.cob_date2_(obj)
            d2 = datestr(obj.cob_date1_,'yyyy-mm-dd');
        end
        %
        function flag = get.is_opt_(obj)
            if isempty(obj.code_ctp_)
                flag = 0;
            else
                flag = isoptchar(obj.code_ctp_);
            end
        end
        %
        function instrument = get.instrument_(obj)
            if isempty(obj.code_ctp_)
                instrument = {};
                return; 
            end
            if obj.is_opt_
                instrument = cOption(obj.code_ctp_);
            else
                instrument = cFutures(obj.code_ctp_);
            end
            instrument.loadinfo([obj.code_ctp_,'_info.txt']);
        end
    end
    
    methods
        [] = print(obj)
        [] = override(obj,varargin)
        [] = add(obj,varargin)
        [pnl] = calc_pnl(obj,varargin)
    end
    
    methods (Static = true)
        [] = demo(~)
    end
end