classdef cTDSQInfo < cSignalInfo
    properties
        scenario_@char
        mode_@char = 'unset'
        type_@char = 'unset'
        lvlup_@double
        lvldn_@double
        risklvl_@double
    end
    
    methods
        function obj = cTDSQInfo
            obj.name_ = 'tdsq';
        end
        
        function [] = set.scenario_(obj,val)
            %todo:some variable controls
            obj.scenario_ = val;
        end
        
        function [] = set.mode_(obj,val)
            if strcmpi(val,'reverse') || strcmpi(val,'trend') || strcmpi(val,'unset')
                obj.mode_ = val;
            else
                error('cTDSQInfo:invalid mode_ input')
            end
        end
        
        function [] = set.type_(obj,val)
            if strcmpi(val,'perfectbs') || ...
                    strcmpi(val,'semiperfectbs') || ...
                    strcmpi(val,'imperfectbs') || ...
                    strcmpi(val,'perfectss') || ...
                    strcmpi(val,'semiperfectss') || ...
                    strcmpi(val,'imperfectss') || ...
                    strcmpi(val,'single-lvldn') || ...
                    strcmpi(val,'single-lvlup') || ...
                    strcmpi(val,'double-range') || ...
                    strcmpi(val,'double-bullish') || ...
                    strcmpi(val,'double-bearish') || ...
                    strcmpi(val,'simpletrend') || ...
                    strcmpi(val,'unset')
                obj.type_ = val;
            else
               error('cTDSQInfo:invalid type input') 
            end
        end
        
    end
end