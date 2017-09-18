classdef cTradingSystemHelper < handle
    properties(Hidden = true, GetAccess = private, SetAccess = private)
        listentrust_@EntrustArray
    end
    
    properties (Hidden = true, GetAccess = private, SetAccess = public)
        counter_@CounterCTP
    end
    
    methods
        function set.counter_(obj,c)
            if ~isa(c,'CounterCTP')
                error('cTradingSystemHelper:invalid counter input!')
            end
                obj.counter_ = c;
        end
    end
    
    methods
        function list = getallentrusts(obj)
            list = EntrustArray;
            for i = 1:obj.listentrust_.latest
               list.push(obj.listentrust_.node(i));
            end                
        end
        %end of getallentrusts
        
        function list = getentrusts(obj,instrument)
            if isa(instrument,'cInstrument')
                code = instrument.code_ctp;
            elseif ischar(instrument)
                code = instrument;
            else
                error('cTradingSystemHelper:getentrusts:invalid instrument input');
            end
            list = EntrustArray;
            for i = 1:obj.lisentrust_.latest
                e = obj.listentrust_.node(i);
                if strcmpi(e,code)
                    list.push(e);
                end
            end                
        end
        %end of getentrusts
        
        function addentrust(obj,e)
            obj.listentrust_.push(e);
        end
        %end of addentrust
        
        function clear(obj)
            obj.listentrust_.clear_array;
        end
        %end of clear
         
    end
end