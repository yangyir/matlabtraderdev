classdef cHelper < handle
    methods (Static)
        function [pnltbl,risktbl] = pnlrisk1(p,d1)
            %calculate the pnl and its breakdown of the portfolio at the
            %end of d1 from the previous business date
            %note:this is a day to day pnl calculation
            if ~isa(p,'cPortfolio')
                error('cHelper,pnl1:invalid portfolio input')
            end
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
                pos = p.pos_list{i};
                sec = pos.instrument_;
%                 sec = p.instrument_list{i};
                volume(i) = pos.direction_*pos.position_total_;
                output = pnlriskbreakdown1(sec,d1,volume(i));
                total(i) = output.pnltotal;
                theta(i) = output.pnltheta;
                delta(i) = output.pnldelta;
                gamma(i) = output.pnlgamma;
                vega(i) = output.pnlvega;
                unexplained(i) = output.pnlunexplained;
                rownames{i} = sec.code_ctp;
                %
                thetacarry(i) = output.thetacarry;
                deltacarry(i) = output.deltacarry;
                gammacarry(i) = output.gammacarry;
                vegacarry(i) = output.vegacarry;
                ivbase(i) = output.iv1;
                ivcarry(i) = output.iv2;
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
            ivbase(end) = NaN;
            ivcarry(end) = NaN;
            
            rownames{end} = 'total';
            
            
            pnltbl = table(total,theta,delta,gamma,vega,unexplained,volume,...
                 ivbase,ivcarry,...
                'RowNames',rownames);
            
            risktbl = table(thetacarry,deltacarry,gammacarry,vegacarry,...
                ivcarry,volume,'RowNames',rownames);
        end
        %end of pnl1
        
        function [pnltbl,risktbl] = pnlrisk2(p,quotes,costs)
            %real-time pnl
            if ~isa(p,'cPortfolio'), error('cHelper,pnl2:invalid portfolio input');end
            
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
                idxc = 0;
                for j = 1:size(costs,1)
                    if isstruct(costs{j})
                        if strcmpi(p.instrument_list{i}.code_ctp,costs{j}.code)
                            idxc = j;
                            break
                        end
                    end
                end
                if idxc == 0, error(['cHelper:pnl2:costs not found for ',p.instrument_list{i}.code_ctp]); end
                
                sec = p.instrument_list{i};
                volume(i) = p.instrument_volume(i);
                output = pnlriskbreakdown2(sec,quotes,costs{idxc},volume(i));
                total(i) = output.pnltotal;
                theta(i) = output.pnltheta;
                delta(i) = output.pnldelta;
                gamma(i) = output.pnlgamma;
                vega(i) = output.pnlvega;
                unexplained(i) = output.pnlunexplained;
                rownames{i} = sec.code_ctp;
                %
                thetacarry(i) = output.thetacarry;
                deltacarry(i) = output.deltacarry;
                gammacarry(i) = output.gammacarry;
                vegacarry(i) = output.vegacarry;
                ivbase(i) = output.iv1;
                ivcarry(i) = output.iv2;            %real-time impvol
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
        %end of pnl2
        
        function [summarytbl,tradestbl] = tradesummary(counter)
            if ~isa(counter,'CounterCTP')
                error('cHelper:tradesummary:invalid counter input')
            end
            trades = counter.queryTrades;
            tradestbl = cell(size(trades,2),5);
            for i = 1:size(trades,2)
                tradestbl{i,1} = trades(i).asset_code;
                tradestbl{i,2} = trades(i).direction;
                tradestbl{i,3} = trades(i).volume;
                tradestbl{i,4} = trades(i).trade_price;
                tradestbl{i,5} = trades(i).trade_time;
            end
            
            % some pivot table function
            code_list = unique(tradestbl(:,1));
            ncode = size(code_list,1);
            summarytbl = cell(2*ncode,4);
            for i = 1:ncode
                summarytbl{2*i-1,1} = code_list{i};
                summarytbl{2*i,1} = code_list{i};
                summarytbl{2*i-1,2} = 1;
                summarytbl{2*i,2} = -1;
                count_b = 0;
                notional_b = 0;
                count_s = 0;
                notional_s = 0;
                for j = 1:size(trades,2)
                    if strcmpi(trades(j).asset_code,code_list{i})
                        if trades(j).direction == 1
                            count_b = count_b + trades(j).volume;
                            notional_b = notional_b + trades(j).volume*trades(j).trade_price;
                        elseif trades(j).direction == -1
                            count_s = count_s + trades(j).volume;
                            notional_s = notional_s + trades(j).volume*trades(j).trade_price;
                        end
                    end
                end
                summarytbl{2*i-1,3} = count_b;
                if count_b ~= 0
                    summarytbl{2*i-1,4} = notional_b/count_b;
                end
                summarytbl{2*i,3} = count_s;
                if count_s ~= 0
                    summarytbl{2*i,4} = notional_s/count_s;
                end
                
            end
        end
        %end of tradesummary
        
        
        
    end
end
