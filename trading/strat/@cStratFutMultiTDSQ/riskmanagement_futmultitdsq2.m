function [] = riskmanagement_futmultitdsq2(strategy,varargin)
%cStratFutMultiTDSQ
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter(
    
    scenarioname = tdsq_getscenarioname(bs,ss,levelup,leveldn,bc,sc,p)

    instruments = strategy.getinstruments;
    for i = 1:strategy.count
        code = instruments{i}.code_ctp;
        v_perfectbs = strategy.getlivetradevolume(code,'reverse','perfectbs');
        v_semiperfectbs = strategy.getlivetradevolume(code,'reverse','semiperfectbs');
        v_imperfectbs = strategy.getlivetradevolume(code,'reverse','imperfectbs');
        v_perfectss = strategy.getlivetradevolume(code,'reverse','perfectss');
        v_semiperfectss = strategy.getlivetradevolume(code,'reverse','semiperfectss');
        v_imperfectss = strategy.getlivetradevolume(code,'reverse','imperfectss');
        
        macdvec = strategy.macdvec_{i};
        sigvec = strategy.nineperma_{i};
        bs = strategy.bs_{i};
        ss = strategy.ss_{i};
        
        
        includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','includelastcandle');
        candlesticks = strategy.mde_fut_.getallcandles(instruments{i});
        p = candlesticks{1};
        if ~includelastcandle, p = p(1:end-1,:);end
        idxkeep = ~(p(:,2)==p(:,3)&p(:,2)==p(:,4)&p(:,2)==p(:,5));
        p = p(idxkeep,:);
        
        if v_perfectbs > 0
            
        end
        
        if v_semiperfectbs > 0
            error('not implemented')
        end
        
        if v_imperfectbs > 0 
            error('not implemented')
        end
        
        if v_perfectss < 0
            error('not implemented')
        end
        
        if v_semiperfectss < 0
            error('not implemented')
        end
        
        if v_imperfectss < 0
            error('not implemented')
        end
        
    end
    
end