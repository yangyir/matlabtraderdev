classdef cStratOpt < cStrat
    properties
        delta_underlier_@double
        %
        delta_@double
        theta_@double
        gamma_@double
        vega_@double
        %
        deltacarry_@double
        gammacarry_@double
        vegacarry_@double
        %
        portfoliobase_@cPortfolio   %the portfolio as of last business date
        
    end
    
    %set/get methods
    methods
        function [] = setriskvalue(obj,instrument,riskname,value)
            if ~isnumeric(value)
                error('cStratOptMultiShortVol:setriskvalue:invalid value input')
            end
            
            isopt = false;
            isunderlier = false;
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if flag
                isopt = true;
            else
                [isunderlier,idx] = obj.underliers_.hasinstrument(instrument);
                if ~isunderlier
                    error('cStratOptMultiShortVol:setriskvalue:instrument not found')
                end
            end
            
            if isopt
                if strcmpi(riskname,'delta')
                    if isempty(obj.delta_), obj.delta_ = zeros(obj.count,1);end
                    obj.delta_(idx,1) = value;
                elseif strcmpi(riskname,'gamma')
                    if isempty(obj.gamma_), obj.gamma_ = zeros(obj.count,1);end
                    obj.gamma_(idx,1) = value;
                elseif strcmpi(riskname,'vega')
                    if isempty(obj.vega_), obj.vega_ = zeros(obj.count,1);end
                    obj.vega_(idx,1) = value;
                elseif strcmpi(riskname,'theta')
                    if isempty(obj.theta_), obj.theta_ = zeros(obj.count,1);end
                    obj.theta_(idx,1) = value;
                elseif strcmpi(riskname,'deltacarry')
                    if isempty(obj.deltacarry_), obj.deltacarry_ = zeros(obj.count,1);end
                    obj.deltacarry_(idx,1) = value;
                elseif strcmpi(riskname,'gammacarry')
                    if isempty(obj.gammacarry_), obj.gammacarry_ = zeros(obj.count,1);end
                    obj.gammacarry_(idx,1) = value;
                elseif strcmpi(riskname,'vegacarry')
                    if isempty(obj.vegacarry_), obj.vegacarry_ = zeros(obj.count,1);end
                    obj.vegacarry_(idx,1) = value;
                else
                    error('cStratOptMultiShortVol:invalid risk name input for option')
                end
            end
            
            if isunderlier
                if strcmpi(riskname,'delta') || strcmpi(riskname,'deltacarry')
                    if isempty(obj.delta_underlier_), obj.delta_underlier_ = zeros(obj.countunderliers,1);end
                    obj.delta_underlier_(idx,1) = value;
                else
                    error('cStratOptMultiShortVol:invalid risk name input for underlier')
                end
            end

        end
        %end of setriskvalue
        
        function [value] = getriskvalue(obj,instrument,riskname)
            isopt = false;
            isunderlier = false;
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if flag
                isopt = true;
            else
                [isunderlier,idx] = obj.underliers_.hasinstrument(instrument);
                if ~isunderlier
                    error('cStratOptMultiShortVol:instrument not found')
                end
            end
            
            if isopt
                if strcmpi(riskname,'delta')
                    value = obj.delta_(idx,1);
                elseif strcmpi(riskname,'gamma')
                    value = obj.gamma_(idx,1);
                elseif strcmpi(riskname,'vega')
                    value = obj.vega_(idx,1);
                elseif strcmpi(riskname,'theta')
                    value = obj.theta_(idx,1);
                elseif strcmpi(riskname,'deltacarry')
                    value = obj.deltacarry_(idx,1);
                elseif strcmpi(riskname,'gammacarry')
                    value = obj.gammacarry_(idx,1);
                elseif strcmpi(riskname,'vegacarry')
                    value = obj.vegacarry_(idx,1);
                else
                    error('cStratOptMultiShortVol:getriskvalue:invalid risk name input for option')
                end
            end
            
            if isunderlier
                if strcmpi(riskname,'delta') || strcmpi(riskname,'deltacarry')
                    value = obj.delta_underlier_(idx,1);
                else
                    error('cStratOptMultiShortVol:getriskvalue:invalid risk name input for underlier')
                end
            end
        end
        %end of getriskvalue
        
    end
    %end of set/get methods
    
    %strategy initialization related
    methods
        function [] = clear(obj)
            obj.instruments_.clear;
            obj.underliers_.clear;
            obj.mde_fut_ = {};
            obj.mde_opt_ = {};
            obj.counter_ = {};
            
        end
        %end of clear
        
        function obj = cStratOpt
            obj.name_ = 'stratopt';
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
            
            if isempty(obj.portfolio_),obj.portfolio_ = cPortfolio;end
            
            if isempty(obj.portfoliobase_),obj.portfoliobase_ = cPortfolio;end
            
        end
        %end of cStratOpt
        
        function [] = registerinstrument(obj,instrument)
            registerinstrument@cStrat(obj,instrument);
            obj.setlimitamount(instrument,inf);
            obj.setlimittype(instrument,'abs');
            obj.setstopamount(instrument,-inf);
            obj.setstoptype(instrument,'abs');
            obj.setautotradeflag(instrument,0);
            obj.setbidspread(instrument,0);
            obj.setaskspread(instrument,0);
            obj.setriskvalue(instrument,'delta',0);
            obj.setriskvalue(instrument,'gamma',0);
            obj.setriskvalue(instrument,'vega',0);
            obj.setriskvalue(instrument,'theta',0);
            obj.setriskvalue(instrument,'deltacarry',0);
            obj.setriskvalue(instrument,'gammacarry',0);
            obj.setriskvalue(instrument,'vegacarry',0);

        end
        %end of registerinstrument
        
        function [] = loadoptions(obj,code_ctp_underlier,numoptions)
            if nargin < 3
                [calls,puts,underlier] = getlistedoptions(code_ctp_underlier);
            else
                [calls,puts,underlier] = getlistedoptions(code_ctp_underlier,numoptions);
            end
            
            for i = 1:size(calls,1)
                obj.registerinstrument(calls{i});
                obj.registerinstrument(puts{i});
                %
                obj.mde_opt_.registerinstrument(calls{i});
                obj.mde_opt_.registerinstrument(puts{i});
            end

            obj.setriskvalue(underlier,'delta',0);
            
        end
        %end of loadoptions
        
        function [] = loadportfoliofromfile(obj,fn,dateinput)
            if nargin < 3
                obj.portfoliobase_ = opt_loadpositions(fn);
            else
                obj.portfoliobase_ = opt_loadpositions(fn,dateinput);
            end
            %copy the portfoliobase_ to portfolio_
            obj.portfolio_ = cPortfolio;
            
            n = obj.portfoliobase_.count;
            list_ = obj.portfoliobase_.instrument_list;
            volume_ = obj.portfoliobase_.instrument_volume;
            cost_ = obj.portfoliobase_.instrument_avgcost;
            for i = 1:n
                obj.portfolio_.addinstrument(list_{i},cost_(i),volume_(i),getlastbusinessdate);
            end
            
        end
        %end of loadportfoliofromfile
        
        function [] = loadportfoliofromcounter(obj)
            for i = 1:obj.count
                instrument_i = obj.instruments_.getinstrument{i};
                pos_i = loadpositionfromcounter(obj.counter_,instrument_i);
                if pos_i.volume ~= 0
                    obj.portfoliobase_.addinstrument(instrument_i,pos_i.carrycost,pos_i.volume,pos_i.carrydate1);
                    obj.portfolio_.addinstrument(instrument_i,pos_i.carrycost,pos_i.volume,pos_i.carrydate1);
                end
            end
            
            for i = 1:obj.countunderliers
                underlier_i = obj.underliers_.getinstrument{i};
                pos_i = loadpositionfromcounter(obj.counter_,underlier_i);
                if pos_i.volume ~= 0
                    obj.portfoliobase_.addinstrument(underlier_i,pos_i.carrycost,pos_i.volume,pos_i.carrydate1);
                    obj.portfolio_.addinstrument(underlier_i,pos_i.carrycost,pos_i.volume,pos_i.carrydate1);
                end
            end
            
        end
        %end of loadportfoliofromcounter
        
        function [] = saveportfoliotofile(obj,fn,clearportfolio)
            if nargin < 3
                clearportfolio = 0;
            end
            fid = fopen(fn,'w');
            for i = 1:obj.portfolio_.count;
                code_i = obj.portfolio_.instrument_list{i}.code_ctp;
                p_i = obj.portfolio_.instrument_volume(i);
                cost_i = obj.portfolio_.instrument_avgcost(i);
                fprintf(fid,'%s\t%d\t%f\n',code_i,p_i,cost_i);
            end
            fclose(fid);
            if clearportfolio
                obj.portfoliobase_ = cPortfolio;
                obj.portfolio_ = cPortfolio;
            end
        end
        %end of saveportfoliotofile
        
    end
    %end of strategy initialization
    
    
    %pnl/risk related
    methods
        function [pnltbl,risktbl] = pnlriskeod(obj)
            if isempty(obj.portfolio_), return; end
            
            pnltbl = cHelper.pnlrisk1(obj.portfoliobase_,getlastbusinessdate);
            
            %the carry risk of the latest portfolio
            [~,risktbl] = cHelper.pnlrisk1(obj.portfoliobase_,getlastbusinessdate);
            
        end
        %end of pnlriskeod
        
        function [pnltbl,risktbl] = pnlriskrealtime(obj)
           
           
            
        end
    end
    %end of pnl/risk related
    
    %trading-related
    methods
        function [] = shortopensingleinstrument(obj,ctp_code,lots)
            instrument = cOption(ctp_code);
            [bool, idx] = obj.instruments_.hasinstrument(instrument);
            %only place entrusts in case the instrument has been registered
            %with the strategy
            if bool
                isopt = isoptchar(ctp_code);
                e = Entrust;
                direction = -1;
                offset = 1;
                if isopt
                    q = obj.mde_opt_.qms_.getquote(ctp_code);
                else
                    q = obj.mde_fut_.qms_.getquote(ctp_code);
                end
                price = q.bid1 + obj.bidspread_(idx);
                e.fillEntrust(1,ctp_code,direction,price,lots,offset,ctp_code);
                obj.entrusts_.push(e);
                ret = obj.counter_.placeEntrust(e);
                if ret, obj.updateportfoliowithentrust(e); end
            end
        end
        %end of shortopensigleinstrument
        
        function [] = shortclosesingleinstrument(obj,ctp_code,lots)
            instrument = cOption(ctp_code);
            [f1, idx] = obj.instruments_.hasinstrument(instrument);
            [f2,idxp] = obj.portfolio_.hasinstrument(instrument);
            if f1&&f2
                volume = abs(obj.portfolio_.instrument_list(idxp));
                if volume < lots
                    error('cStratOpt:shortclosesingleinstrument:input size exceeds existing size')
                end
                if volume <= 0
                    error('cStratOpt:shortclosesingleinstrument:existing long position not found')
                end
                
                isopt = isoptchar(ctp_code);
                e = Entrust;
                direction = -1;
                offset = -1;
                if isopt
                    q = obj.mde_opt_.qms_.getquote(ctp_code);
                else
                    q = obj.mde_fut_.qms_.getquote(ctp_code);
                end
                price = q.bid1 + obj.bidspread_(idx);
                e.fillEntrust(1,ctp_code,direction,price,lots,offset,ctp_code);
                obj.entrusts_.push(e);
                ret = obj.counter_.placeEntrust(e);
                if ret
                    pnl = obj.updateportfoliowithentrust(e); 
                    obj.pnl_close_(idx) = obj.pnl_close_(idx) + pnl;
                end
            end
        end
        %end of shortclosesigleinstrument
        
        function [] = longopensingleinstrument(obj,ctp_code,lots)
            instrument = cOption(ctp_code);
            [bool, idx] = obj.instruments_.hasinstrument(instrument);
            %only place entrusts in case the instrument has been registered
            %with the strategy
            if bool
                isopt = isoptchar(ctp_code);
                e = Entrust;
                direction = 1;
                offset = 1;
                if isopt
                    q = obj.mde_opt_.qms_.getquote(ctp_code);
                else
                    q = obj.mde_fut_.qms_.getquote(ctp_code);
                end
                price = q.ask + obj.askspread_(idx);
                e.fillEntrust(1,ctp_code,direction,price,lots,offset,ctp_code);
                obj.entrusts_.push(e);
                ret = obj.counter_.placeEntrust(e);
                if ret, obj.updateportfoliowithentrust(e); end
            end
        end
        %end of longopensigleinstrument
        
        function [] = longclosesingleinstrument(obj,ctp_code,lots)
            instrument = cOption(ctp_code);
            [f1, idx] = obj.instruments_.hasinstrument(instrument);
            [f2,idxp] = obj.portfolio_.hasinstrument(instrument);
            if f1&&f2
                volume = abs(obj.portfolio_.instrument_list(idxp));
                if volume < lots
                    error('cStratOpt:longclosesingleinstrument:input size exceeds existing size')
                end
                if volume >= 0
                    error('cStratOpt:longclosesingleinstrument:existing short position not found')
                end
                isopt = isoptchar(ctp_code);
                e = Entrust;
                direction = 1;
                offset = -1;
                if isopt
                    q = obj.mde_opt_.qms_.getquote(ctp_code);
                else
                    q = obj.mde_fut_.qms_.getquote(ctp_code);
                end
                price = q.ask + obj.askspread_(idx);
                e.fillEntrust(1,ctp_code,direction,price,lots,offset,ctp_code);
                obj.entrusts_.push(e);
                ret = obj.counter_.placeEntrust(e);
                if ret
                    pnl = obj.updateportfoliowithentrust(e); 
                    obj.pnl_close_(idx) = obj.pnl_close_(idx) + pnl;
                end
            end
        end
        %end of longopensigleinstrument
        
    end
    
    %derived methods from cStrat base class
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
    
    methods (Access = private)
    end
    
end