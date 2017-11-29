classdef cStratOpt < cStrat
    properties
        delta_underlier_@double
        closeyesterday_underlier_@double
        %
        delta_@double
        gamma_@double
        vega_@double
        theta_@double
        impvol_@double
        %
        deltacarry_@double
        gammacarry_@double
        vegacarry_@double
        thetacarry_@double
        %
        deltacarryyesterday_@double
        gammacarryyesterday_@double
        vegacarryyesterday_@double
        thetacarryyesterday_@double
        impvolcarryyesterday_@double
        pvcarryyesterday_@double
        %
        portfoliobase_@cPortfolio   %the portfolio as of last business date
        %
        optnewlytraded_@cell
        
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
                elseif strcmpi(riskname,'impvol')
                    if isempty(obj.impvol_), obj.impvol_ = zeros(obj.count,1);end
                    obj.impvol_(idx,1) = value;    
                elseif strcmpi(riskname,'deltacarry')
                    if isempty(obj.deltacarry_), obj.deltacarry_ = zeros(obj.count,1);end
                    obj.deltacarry_(idx,1) = value;
                elseif strcmpi(riskname,'gammacarry')
                    if isempty(obj.gammacarry_), obj.gammacarry_ = zeros(obj.count,1);end
                    obj.gammacarry_(idx,1) = value;
                elseif strcmpi(riskname,'vegacarry')
                    if isempty(obj.vegacarry_), obj.vegacarry_ = zeros(obj.count,1);end
                    obj.vegacarry_(idx,1) = value;
                elseif strcmpi(riskname,'thetacarry')
                    if isempty(obj.thetacarry_), obj.thetacarry_ = zeros(obj.count,1);end
                    obj.thetacarry_(idx,1) = value;
                elseif strcmpi(riskname,'deltacarryyesterday')
                    if isempty(obj.deltacarryyesterday_), obj.deltacarryyesterday_ = zeros(obj.count,1);end
                    obj.deltacarryyesterday_(idx,1) = value;
                elseif strcmpi(riskname,'gammacarryyesterday')
                    if isempty(obj.gammacarryyesterday_), obj.gammacarryyesterday_ = zeros(obj.count,1);end
                    obj.gammacarryyesterday_(idx,1) = value;
                elseif strcmpi(riskname,'vegacarryyesterday')
                    if isempty(obj.vegacarryyesterday_), obj.vegacarryyesterday_ = zeros(obj.count,1);end
                    obj.vegacarryyesterday_(idx,1) = value;
                elseif strcmpi(riskname,'thetacarryyesterday')
                    if isempty(obj.thetacarryyesterday_), obj.thetacarryyesterday_ = zeros(obj.count,1);end
                    obj.thetacarryyesterday_(idx,1) = value;
                elseif strcmpi(riskname,'impvolcarryyesterday')
                    if isempty(obj.impvolcarryyesterday_), obj.impvolcarryyesterday_ = zeros(obj.count,1);end
                    obj.impvolcarryyesterday_(idx,1) = value;
                elseif strcmpi(riskname,'pvcarryyesterday')
                    if isempty(obj.pvcarryyesterday_), obj.pvcarryyesterday_ = zeros(obj.count,1);end
                    obj.pvcarryyesterday_(idx,1) = value;
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
                elseif strcmpi(riskname,'impvol')
                    value = obj.impvol_(idx,1);
                elseif strcmpi(riskname,'deltacarry')
                    value = obj.deltacarry_(idx,1);
                elseif strcmpi(riskname,'gammacarry')
                    value = obj.gammacarry_(idx,1);
                elseif strcmpi(riskname,'vegacarry')
                    value = obj.vegacarry_(idx,1);
                elseif strcmpi(riskname,'thetacarry')
                    value = obj.thetacarry_(idx,1); 
                elseif strcmpi(riskname,'deltacarryyesterday')
                    value = obj.deltacarryyesterday_(idx,1);
                elseif strcmpi(riskname,'gammacarryyesterday')
                    value = obj.gammacarryyesterday_(idx,1);
                elseif strcmpi(riskname,'vegacarryyesterday')
                    value = obj.vegacarryyesterday_(idx,1);
                elseif strcmpi(riskname,'thetacarryyesterday')
                    value = obj.thetacarryyesterday_(idx,1);
                elseif strcmpi(riskname,'impvolcarryyesterday')
                    value = obj.impvolcarryyesterday_(idx,1);
                elseif strcmpi(riskname,'pvcarryyesterday')
                    value = obj.pvcarryyesterday_(idx,1);
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
            %note:delta/gamma/vega/theta/impvol is the real time greeks which are
            %updated via the qutoes
            obj.setriskvalue(instrument,'delta',0);
            obj.setriskvalue(instrument,'gamma',0);
            obj.setriskvalue(instrument,'vega',0);
            obj.setriskvalue(instrument,'theta',0);
            obj.setriskvalue(instrument,'impvol',0);
            %
            %note:deltacarry/gammacarry/vegacarry/thetacarry are the risks
            %carried on the end of current business date
            obj.setriskvalue(instrument,'deltacarry',0);
            obj.setriskvalue(instrument,'gammacarry',0);
            obj.setriskvalue(instrument,'vegacarry',0);
            obj.setriskvalue(instrument,'thetacarry',0);
            %
            pnlriskoutput = pnlriskbreakdown1(instrument,getlastbusinessdate);
            %note:deltacarry/gammacarry/vegacarry and thetacarry are the
            %risk carry on the end of the last business date
            obj.setriskvalue(instrument,'deltacarryyesterday',pnlriskoutput.deltacarry);
            obj.setriskvalue(instrument,'gammacarryyesterday',pnlriskoutput.gammacarry);
            obj.setriskvalue(instrument,'vegacarryyesterday',pnlriskoutput.vegacarry);
            obj.setriskvalue(instrument,'thetacarryyesterday',pnlriskoutput.thetacarry);
            %note:iv2 is the implied vol using the close price of the
            %option and its underlier as of the last business date
            obj.setriskvalue(instrument,'impvolcarryyesterday',pnlriskoutput.iv2);
            %note:premium2 is the close price of the option as of the last
            %business date
            obj.setriskvalue(instrument,'pvcarryyesterday',pnlriskoutput.premium2);
            
            %pls note all the risk figures above have not been scaled by
            %the volume which is embedded in the portfolio
            
        end
        %end of registerinstrument
        
        function [] = registeroptions(obj,code_ctp_underlier,numoptions)
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
            
            [~,idxu] = obj.underliers_.hasinstrument(underlier);
            data = cDataFileIO.loadDataFromTxtFile([underlier.code_ctp,'_daily.txt']);
            priceunderlier = data(data(:,1)==datenum(getlastbusinessdate),end);
            if isempty(priceunderlier)
                error(['underlier ',underlier.code_ctp,' historical price not saved!'])
            end
            obj.closeyesterday_underlier_(idxu,1) = priceunderlier;
            
        end
        %end of registeroptions
        
        function [] = loadportfoliofromfile(obj,fn,dateinput)
            if nargin < 3
                obj.portfoliobase_ = opt_loadpositions(fn);
            else
                obj.portfoliobase_ = opt_loadpositions(fn,dateinput);
            end
            
            n = obj.portfoliobase_.count;
            list_ = obj.portfoliobase_.instrument_list;
            volume_ = obj.portfoliobase_.instrument_volume;
            cost_ = obj.portfoliobase_.instrument_avgcost;
            
            %copy the portfoliobase_ to portfolio_
            obj.portfolio_ = cPortfolio;
            for i = 1:n
                obj.portfolio_.addinstrument(list_{i},cost_(i),volume_(i),getlastbusinessdate);
            end
            
        end
        %end of loadportfoliofromfile
        
        function [] = loadportfoliofromcounter(obj)
            for i = 1:obj.count
                instrument_i = obj.instruments_.getinstrument{i};
                pos_i = loadpositionfromcounter(obj.counter_,instrument_i);
                %using carry cost rather than the open cost for daily pnl
                %calculation
                if pos_i.volume ~= 0
                    obj.portfoliobase_.addinstrument(instrument_i,pos_i.carrycost,pos_i.volume,pos_i.carrydate1);
                    obj.portfolio_.addinstrument(instrument_i,pos_i.carrycost,pos_i.volume,pos_i.carrydate1);
                end
            end
            
            for i = 1:obj.countunderliers
                underlier_i = obj.underliers_.getinstrument{i};
                pos_i = loadpositionfromcounter(obj.counter_,underlier_i);
                %using carry cost rather than the open cost for daily pnl
                %calculation
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
           [pnltbl,risktbl] = obj.pnlrisk2;
           
            
        end
        %end of pnlriskrealtime
    end
    %end of pnl/risk related
    
    %derived methods from cStrat base class
    methods
        function signals = gensignals(obj)
            variablenotused(obj);
            signals = {};
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            variablenotused(obj);
            variablenotused(signals);
        end
        %end of autoplaceentrusts
        

        
    end
    
    methods (Access = private)
        function [pnltbl,risktbl] = pnlrisk2(obj)
            pnltbl = {};
            risktbl = {};
            if isempty(obj.portfolio_), return; end
            p = obj.portfolio_;
            total = zeros(p.count+1,1);
            theta = zeros(p.count+1,1);
            delta = zeros(p.count+1,1);
            gamma = zeros(p.count+1,1);
            vega = zeros(p.count+1,1);
            unexplained = zeros(p.count+1,1);
            volume = zeros(p.count+1,1);
            %
            thetacarry = zeros(p.count+1,1);
            deltacarry = zeros(p.count+1,1);
            gammacarry = zeros(p.count+1,1);
            vegacarry = zeros(p.count+1,1);
            ivbase = zeros(p.count+1,1);
            ivcarry = zeros(p.count+1,1);
            
            rownames = cell(p.count+1,1);
            
            for i = 1:p.count
                [~,idx] = obj.instruments_.hasinstrument(p.instrument_list{i});
                if idx == 0
                    %not in the option list and it might be futures
                    [~,idx] = obj.underliers_.hasinstrument(p.instrument_list{i});
                    if idx == 0
                        error('invalid instrument')
                    else
                        isfut = true;
                        isopt = false;
                    end
                else
                    isopt = true;
                    isfut = false;
                end
                carrycost = p.instrument_avgcost(i);
                volume_total = p.instrument_volume(i);
                volume_today = p.instrument_volume_today(i);
                rownames{i} = p.instrument_list{i}.code_ctp;
                volume(i,1) = volume_total;
                if isopt
                    opt = p.instrument_list{i};
                    mult = opt.contract_size;
                    underlier_code = opt.code_ctp_underlier;
                    [~,idxu] = obj.underliers_.hasinstrument(underlier_code);
                    closepyesterday = obj.closeyesterday_underlier_(idxu);
                    q = obj.mde_opt_.qms_.getquote(opt);
                    if isempty(q), continue; end
                    if q.update_date1 == getlastbusinessdate
                        hh = hour(q.update_time1);
                        if hh >= 9 && hh <= 15
                            calc_theta = 0;
                        else
                            calc_theta = 1;
                        end
                    else
                        calc_theta = 1;
                    end
                    ret = (q.last_trade_underlier-closepyesterday)/closepyesterday;
%                     note:todo:we will updat the pnl attribution
%                     with bid/ask prices
%                     if volume_total < 0
%                         total(i,1) = (q.ask1-carrycost)*volume_total*mult;
%                     else
%                         total(i,1) = (q.bid1-carrycost)*volume_total*mult;
%                     end
                    total(i,1) = (q.last_trade-carrycost)*volume_total*mult;
                    if volume_total ~= 0
                        if volume_today == 0
                            
                            if calc_theta
                                theta(i,1) = obj.thetacarryyesterday_(idx)*volume_total;
                            end
                            delta(i,1) = obj.deltacarryyesterday_(idx)*ret;
                            gamma(i,1) = 0.5*obj.gammacarryyesterday_(idx)*ret^2*100;
                            thetacarry(i,1) = obj.theta_(idx)*volume_total;
                            deltacarry(i,1) = obj.deltacarry_(idx)*volume_total;
                            gammacarry(i,1) = obj.gammacarry_(idx)*volume_total;
                            vegacarry(i,1) = obj.vegacarry_(idx)*volume_total;
                            ivbase(i,1) = obj.impvolcarryyesterday_(idx);
                            ivcarry(i,1) = obj.impvol_(idx);
                            vega(i,1) = obj.vegacarryyesterday_(idx)*(ivcarry(i,1)-ivbase(i,1))/0.01*volume_total;
                            unexplained(i,1) = total(i,1)-(theta(i,1)+delta(i,1)+gamma(i,1)+vega(i,1));
                        else
                            error('todo:volume_today not equal to zero')
%                             volume_before = volume_total - volume_today;
                            
                            
                            
                            %we have newly traded positions
                            %note:we don't record the underlier price, and
                            %thus the implied vol when we issue new trades
                        end
                    end
                elseif isfut
                    fut = p.instrument_list{i};
                    mult = fut.contract_size;
                    q = obj.mde_fut_.qms_.getquote(fut);
                    %note:todo:we will updat the pnl attribution with
                    %bid/ask prices
%                     if volume_total < 0
%                         total(i,1) = (q.ask1-carrycost)*volume_total*mult;
%                     else
%                         total(i,1) = (q.bid1-carrycost)*volume_total*mult;
%                     end
                    total(i,1) = (q.last_trade-carrycost)*volume_total*mult;
                    delta(i,1) = total(i,1);
                end
                
            end
            total(end) = sum(total(1:end-1));
            theta(end) = sum(theta(1:end-1));
            delta(end) = sum(delta(1:end-1));
            gamma(end) = sum(gamma(1:end-1));
            vega(end) = sum(vega(1:end-1));
            unexplained(end) = sum(unexplained(1:end-1));
            volume(end) = NaN;
            %
            deltacarry(end) = sum(deltacarry(1:end-1));
            gammacarry(end) = sum(gammacarry(1:end-1));
            thetacarry(end) = sum(thetacarry(1:end-1));
            vegacarry(end) = sum(vegacarry(1:end-1));
            ivcarry(end) = NaN;
            
            rownames{end} = 'total';
            
            pnltbl = table(total,theta,delta,gamma,vega,unexplained,volume,...
                ivbase,ivcarry,...
                'RowNames',rownames);
            
            risktbl = table(thetacarry,deltacarry,gammacarry,vegacarry,...
                ivcarry,volume,'RowNames',rownames);
            
        end
        %end of pnlrisk2
    end
    
end