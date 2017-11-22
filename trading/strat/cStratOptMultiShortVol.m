classdef cStratOptMultiShortVol < cStrat
    properties
    end
    
    methods
        function [] = clear(obj)
            obj.instruments_.clear;
            obj.underliers_.clear;
            obj.mde_fut_ = {};
            obj.mde_opt_ = {};
            obj.counter_ = {};
            
        end
        %end of clear
        
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
            
            if isempty(obj.portfolio_)
                obj.portfolio_ = cPortfolio;
            end
            
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
    
    %trading-related
    methods
        function [] = shortopensingleopt(obj,ctp_code,lots)
            instrument = cOption(ctp_code);
            [bool, idx] = obj.instruments_.hasinstrument(instrument);
            if bool
                instrument = obj.instruments_.getinstrument{idx};
                e = Entrust;
                direction = -1;
                offset = 1;
                q = obj.mde_opt_.qms_.getquote(ctp_code);
                price = q.bid1;
                e.fillEntrust(1,ctp_code,direction,price,lots,offset,ctp_code);
                e.assetType = 'Future';
                e.multiplier = 10;
                obj.entrusts_.push(e);
                ret = obj.counter_.placeEntrust(e);
                if ret
                    ret = obj.counter_.queryEntrust(e);
                    if ret && e.dealVolume > 0
                        t = cTransaction;
                        t.instrument_ = instrument;
                        t.price_ = e.dealAmount./e.dealVolume;
                        t.volume_ = e.dealVolume;
                        t.direction_ = direction;
                        t.offset_ = offset;
                        t.datetime1_ = e.time;
                        obj.portfolio_.updateportfolio(t);
                    end
                end
                
                
            end
        end
        %end of shortopensigleopt
        
        function [] = shortclosesingleopt(obj,ctp_code,lots)
        end
        %end of shortclosesigleopt
        
        function [] = longopensingleopt(obj,ctp_code,lots)
        end
        %end of longopensigleopt
        
        function [] = longclosesingleopt(obj,ctp_code,lots)
        end
        %end of longopensigleopt
        
    end
    
    methods
        function signals = gensignals(obj)
            variablenotused(obj);
            signals = {};
        end
        
        function [] = autoplacenewentrusts(obj,signals)
            variablenotused(obj);
            variablenotused(signals);
        end
        
    end
    
end