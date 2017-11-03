classdef cStratOptSingleStraddle < cStrat
    properties
%         portfolio_@cPortfolio
        costs_@cell
        pivottable_@cell
    end
    
    methods
        function obj = cStratOptSingleStraddle
            obj.name_ = 'optsinglestraddle';
        end
        
        
    end
    
    %%
    % real-time market data related methods
    methods
        function [] = update(obj,qms)
            qms.refresh;
            obj.displaypivottable(qms)
        end
        %end of update
    end
    
    %%
    %pnl and risk related methods
    methods
        function obj = loadportfoliofromfile(obj,fn)
            obj.portfolio_ = opt_loadpositions(fn);
        end
        %end of loadportfoliofromfile
        
        function [pnltbl,risktbl] = pnlrisk1(obj,bd)
            %note:end of day pnl as of the input business date
            %load the portfolio as of the previous business date as of the
            %input bd
            bd_ = businessdate(bd,-1);
            opt_pos_fn_ = ['opt_pos_',datestr(bd_,'yyyymmdd')];
            p = opt_loadpositions(opt_pos_fn_);
            pnltbl = cHelper.pnlrisk1(p,bd);
            
            %note:the carry risk as of the portfolio end of the input
            %business date
            opt_pos_fn = ['opt_pos_',datestr(bd,'yyyymmdd')];
            obj.loadportfoliofromfile(opt_pos_fn);
            [~,risktbl] = cHelper.pnlrisk1(obj.portfolio_,bd);
            
            %check whether the portfolio are the same and we may have new
            %trades
            n_ = p.count;
            n = obj.portfolio_.count;
            codes = cell(n_+n,1);
            for i = 1:n_, codes{i} = p.instrument_list{i}.code_ctp;end
            for i = 1:n, codes{n_+i} = obj.portfolio_.instrument_list{i}.code_ctp;end
            codes = unique(codes);
            v1 = zeros(size(codes,1),1);
            v2 = zeros(size(codes,1),1);
            for i = 1:size(codes,1)
                for j = 1:n_
                    instrument_ = p.instrument_list{j};
                    if strcmpi(codes{i},instrument_.code_ctp)
                        v1(i) = p.instrument_volume(j);
                        break
                    end
                end
                %
                for j = 1:n
                    instrument = obj.portfolio_.instrument_list{j};
                    if strcmpi(codes{i},instrument.code_ctp)
                        v2(i) = obj.portfolio_.instrument_volume(j);
                        break
                    end
                end
            end
            diff = v2-v1;
            if sum(diff) ~= 0
                %we have new transactions
                %todo
            end
            
            
            
        end
        %end of pnlrisk1
        
        function [pnltbl,risktbl] = pnlrisk2(obj,quotes)
            %note:real-time pnl and carry risk
            [pnltbl,risktbl] = cHelper.pnlrisk2(obj.portfolio_,quotes,obj.costs_);
            %print real-time pnl table
            printpnltbl(pnltbl);
            %
            %print real-time risk table
            printrisktbl(risktbl);
        end
        %end of pnlrisk2
        
        function obj = updatecost(obj,bd,risktbl)
            %note:
            %input: bd:business date
            %risktbl:risk table which shall be a table object
            if ~isa(risktbl,'table')
                error('cStratOptSingleStraddle:invalid risk table input')
            end
            
            opt_pos_fn = ['opt_pos_',datestr(bd,'yyyymmdd')];
            obj.loadportfoliofromfile(opt_pos_fn);
                        
            n = obj.portfolio_.count;
            costs = cell(n,1);
            for i = 1:n
                sec = obj.portfolio_.instrument_list{i};
                data = cDataFileIO.loadDataFromTxtFile([sec.code_ctp,'_daily.txt']);
                price = data(data(:,1) == bd,5);
                if isempty(price), error('price not found!'); end
                
                volume = risktbl.volume(i);
                if isa(sec,'cFutures')
                    costs{i} = struct('code',sec.code_ctp,...
                        'price',price,...
                        'date1',datenum(bd),...
                        'date2',datestr(bd,'yyyy-mm-dd'));
                elseif isa(sec,'cOption')
                    data = cDataFileIO.loadDataFromTxtFile([sec.code_ctp_underlier,'_daily.txt']);
                    price_underlier = data(data(:,1) == bd,5);
                    if isempty(price_underlier), error('price not found!'); end
                    
                    %cost per unit of option
                    costs{i} = struct('code',sec.code_ctp,...
                        'price_underlier',price_underlier,...
                        'price',price,...
                        'iv',risktbl.ivcarry(i),...
                        'thetacarry',risktbl.thetacarry(i)/volume,...
                        'gammacarry',risktbl.gammacarry(i)/volume,...
                        'deltacarry',risktbl.deltacarry(i)/volume,...
                        'vegacarry',risktbl.vegacarry(i)/volume,...
                        'date1',datenum(bd),...
                        'date2',datestr(bd,'yyyy-mm-dd'));
                end
                obj.costs_ = costs;
            end
            
        end
        %end of updatecost
        
    end
    
    %%
    methods
        function signals = gensignals(obj)
            %todo
            
            
        end
        %end of gensignal
        
        function [] = autoplacenewentrusts(obj,signals)
        end
        
        function [] = querypositions(obj,counter,qms)
            nu = obj.countunderliers;
            list_u = obj.underliers_.getinstrument;
            list_opt = obj.instruments_.getinstrument;
            if nu == 1
                [opt_delta,opt_gamma,opt_vega,opt_theta,opt_pnl] = opt_querypositions(obj.instruments_,counter,qms);
                q = qms.getquote(list_opt{1});
                last_trade = q.last_trade_underlier;
                [pos_u,ret_u] = counter.queryPositions(list_u{1}.code_ctp);
                if ret_u
                    fut_delta = pos_u(1).direction*pos_u(1).total_position*last_trade*list_u{1}.contract_size;
                else
                    fut_delta = 0;
                end
               
                fut_pnl = pos_u(1).direction*pos_u(1).total_position*(last_trade-pos_u(1).avg_price/list_u{1}.contract_size)*list_u{1}.contract_size;               
                fprintf('fut:%12s; ',list_u{1}.code_ctp)
                fprintf('iv:%4.1f%%; ',NaN);
                fprintf('delta:%9.0f; ',fut_delta);
                fprintf('gamma:%9.0f; ',0);
                fprintf('theta:%5.0f; ',0);
                fprintf('vega:%8.0f; ',0);
                fprintf('pos:%5d; ',pos_u(1).direction*pos_u(1).total_position);
                fprintf('pnl:%8.0f; ',fut_pnl);
                fprintf('\n');
                
                nresidual = -(opt_delta + fut_delta)/last_trade/list_u{1}.contract_size;
                fprintf('total:%12s', ' ');
                fprintf('iv:%4.1f%%; ',NaN);
                fprintf('delta:%9.0f; ',opt_delta+fut_delta);
                fprintf('gamma:%9.0f; ',opt_gamma);
                fprintf('theta:%5.0f; ',opt_theta);
                fprintf('vega:%8.0f; ',opt_vega);
                fprintf('pos:%5d; ',NaN);
                fprintf('pnl:%8.0f; ',opt_pnl+fut_pnl);
                fprintf('\n');
                fprintf('fut spot:%d;',last_trade);
                fprintf('lots:%d; ',round(nresidual));
                fprintf('\n');
            else
                %group the information by underlier
                %todo
                
            end
        end
        %end of querypositions
        
    end
    
    methods (Access = private)
        function strikes = getstrikes(obj)
            opts = obj.instruments_.getinstrument;
            n = obj.count;
            strikes = zeros(n,1);
            for i = 1:n
                strikes(i) = opts{i}.opt_strike;
            end
            strikes = unique(strikes);
            strikes = sort(strikes);
                
        end
        %end of getstrikes
        
        function tbl = pivottable(obj)
            nu = obj.countunderliers;
            no = obj.count;
            if mod(no,2) ~= 0, error('cStratOptSingleStraddle:pivottable:number of options shall be even'); end
            
            ul = obj.underliers_.getinstrument;
            ol = obj.instruments_.getinstrument;
            tbl = cell(no/2,4);
            
            count = 0;
            for i = 1:nu
                u = ul{i};
                for j = 1:no
                    o = ol{j};
                    if i == 1 && j == 1
                        count = count + 1;
                        tbl{count,1} = u.code_ctp;
                        tbl{count,2} = o.opt_strike;
                        if strcmpi(o.opt_type,'C'),tbl{count,3} = o.code_ctp;else tbl{count,4} = o.code_ctp;end
                    else
                        u_ = o.code_ctp_underlier;
                        strike = o.opt_strike;
                        flag = false;
                        for k = 1:count
                            if strcmpi(tbl{k,1},u_) && tbl{k,2} == strike
                                flag = true;
                                if strcmpi(o.opt_type,'C'),tbl{k,3} = o.code_ctp;else tbl{k,4} = o.code_ctp;end
                                break
                            end
                        end
                        if ~flag
                            count = count + 1;
                            tbl{count,1} = u_;
                            tbl{count,2} = strike;
                            if strcmpi(o.opt_type,'C'), tbl{count,3} = o.code_ctp;else tbl{count,4} = o.code_ctp;end
                        end
                    end  
                end 
            end
            obj.pivottable_ = tbl;
        end
        %end of pivottable
        
        function [] = displaypivottable(obj,qms)
            if ~isa(qms,'cQMS'), error('cStratOptSingleStraddle:update:invalid qms input'); end
                        
            n = obj.count;
            if size(obj.pivottable_,1) ~= n, obj.pivottable;end
            
            qs = qms.getquote;
            
            fprintf('\t%s','ticker');
            fprintf('\t%8s','bid(c)');fprintf('%7s','ask(c)');fprintf('%8s','ivm(c)');
            fprintf('\t%s','strike');
            fprintf('\t%9s','ticker');
            fprintf('\t%8s','bid(p)');fprintf('%7s','ask(p)');fprintf('%8s','ivm(p)');
            fprintf('\n');
            
            for i = 1:size(obj.pivottable_,1)
                strike = obj.pivottable_{i,2};
                c = obj.pivottable_{i,3};
                p = obj.pivottable_{i,4};
                
                idxc = 0;
                for j = 1:size(qs,1)
                    if strcmpi(c,qs{j}.code_ctp),idxc = j;break; end
                end
                
                idxp = 0;
                for j = 1:size(qs,1)
                    if strcmpi(p,qs{j}.code_ctp),idxp = j;break; end
                end
                
                ivc = qs{idxc}.impvol;
                bc = qs{idxc}.bid1;
                ac = qs{idxc}.ask1;
                ivp = qs{idxp}.impvol;
                bp = qs{idxp}.bid1;
                ap = qs{idxp}.ask1;
                
                if i > 1 && ~strcmpi(obj.pivottable_{i,1},obj.pivottable_{i-1,1}) ,fprintf('\n'); end
                
                fprintf('%12s ', obj.pivottable_{i,3});
                fprintf('%6.1f ',bc);
                fprintf('%6.1f ',ac);
                fprintf('%6.1f%% ',ivc*100);
                fprintf('%6.0f ',strike);
                fprintf('%14s ', obj.pivottable_{i,4});
                fprintf('%6.1f ',bp);
                fprintf('%6.1f ',ap);
                fprintf('%6.1f%% ',ivp*100);
                fprintf('\n');
                
            end
        end
        %end of displaypivottable
        
        
    end
end