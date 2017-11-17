classdef cStratOptMultiShortVol < cStrat
    properties
    end
    
    methods
        function obj = cStratOptMultiShortVol
            obj.name_ = 'optmultishortvol';
            if isempty(obj.instruments_), obj.instruments_ = cInstrumentArray; end
            if isempty(obj.underliers_), obj.underliers_ = cInstrumentArray; end
            
            if isempty(obj.mde_fut_)
                obj.mde_fut_ = cMDEFut;
                qms_fut_ = cQMS;
                qms_fut_.setdatasource('ctp');
                obj.mde_fut_.qms_ = qms_fut_;
            end
            
            if isempty(obj.mde_opt_) 
                obj.mde_opt_ = cMDEOpt; 
                qms_opt_ = cQMS;
                qms_opt_.setdatasource('ctp');
                obj.mde_opt_.qms_ = qms_opt_;
            end
            
            obj.timer_interval_ = 60;
            
        end
        %end of cStratOptMultiShortVol
        
        function [] = loadoptions(obj,code_ctp_underlier,numoptions)
            if nargin < 3
                [calls,puts,underlier] = getlistedoptions(code_ctp_underlier);
            else
                [calls,puts,underlier] = getlistedoptions(code_ctp_underlier,numoptions);
            end
            
            for i = 1:size(calls,1)
                obj.instruments_.addinstrument(calls{i});
                obj.instruments_.addinstrument(puts{i});
                obj.mde_opt_.registerinstrument(calls{i});
                obj.mde_opt_.registerinstrument(puts{i});
            end
            
            obj.underliers_.addinstrument(underlier);
            obj.mde_fut_.registerinstrument(underlier);

        end
        %end of loadoptions
        
    end
    
    methods
        function signals = gensignals(obj)
        end
        
        function [] = autoplacenewentrusts(obj,signals)
        end
        
    end
    
end