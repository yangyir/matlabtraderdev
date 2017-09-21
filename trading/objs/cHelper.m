classdef cHelper < handle
    methods (Static)
        function pnltbl = pnl1(p,d1)
            %calculate the pnl and its breakdown of the portfolio at the
            %end of d1 from the previous business date
            if ~isa(p,'cPortfolio')
                error('cHelper,pnl1:invalid portfolio input')
            end
            total = zeros(p.count+1,1);
            theta = zeros(p.count+1,1);
            delta = zeros(p.count+1,1);
            gamma = zeros(p.count+1,1);
            vega = zeros(p.count+1,1);
            unexplained = zeros(p.count+1,1);
            rownames = cell(p.count+1,1);
            
            for i = 1:p.count
                sec = p.instrument_list{i};
                volume = p.instrument_volume(i);
                output = pnlbreakdown1(sec,d1,volume);
                total(i) = output.pnltotal;
                theta(i) = output.pnltheta;
                delta(i) = output.pnldelta;
                gamma(i) = output.pnlgamma;
                vega(i) = output.pnlvega;
                unexplained(i) = output.pnlunexplained;
                rownames{i} = sec.code_ctp;
            end
            total(end) = sum(total(1:end-1));
            theta(end) = sum(theta(1:end-1));
            delta(end) = sum(delta(1:end-1));
            gamma(end) = sum(gamma(1:end-1));
            vega(end) = sum(vega(1:end-1));
            unexplained(end) = sum(unexplained(1:end-1));
            rownames{end} = 'total';
            
            
            pnltbl = table(total,theta,delta,gamma,vega,unexplained,...
                'RowNames',rownames);    
        end
        %end of pnl1
        
        function pnltbl = pnl2(p,quotes)
            if ~isa(p,'cPortfolio')
                error('cHelper,pnl2:invalid portfolio input')
            end
        end
        
    end
end
