classdef cTDSQInfo < cSignalInfo
    properties
        scenario_@char
        mode_@char = 'unset'
        reversetype_@char = 'unset'
        trendtype_@char = 'unset'
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
        
        function [] = set.reversetype_(obj,val)
            if strcmpi(val,'perfectbs') || ...
                    strcmpi(val,'semiperfectbs') || ...
                    strcmpi(val,'imperfectbs') || ...
                    strcmpi(val,'perfectss') || ...
                    strcmpi(val,'semiperfectss') || ...
                    strcmpi(val,'imperfectss') || ...
                    strcmpi(val,'unset')
                obj.reversetype_ = val;
            else
               error('cTDSQInfo:invalid reversetype input') 
            end
        end
        
        function [] = set.trendtype_(obj,val)
            if strcmpi(val,'single-lvldn') || ...
                    strcmpi(val,'single-lvlup') || ...
                    strcmpi(val,'double-range') || ...
                    strcmpi(val,'double-bullish') || ...
                    strcmpi(val,'twoway-bearish') || ...
                    strcmpi(val,'unset')
                obj.trendtype_ = val;
            else
                error('cTDSQInfo:invalid trendtype input')
            end
        end
    end
end