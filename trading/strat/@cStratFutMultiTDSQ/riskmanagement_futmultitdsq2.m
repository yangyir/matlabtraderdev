function [] = riskmanagement_futmultitdsq2(strategy,varargin)
%cStratFutMultiTDSQ
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@ischar);
    p.parse(varargin{:});
    code = p.Results.Code;
    
    trade_perfectbs = strategy.getlivetrade_tdsq(code,'reverse','perfectbs');
    trade_semiperfectbs = strategy.getlivetrade_tdsq(code,'reverse','semiperfectbs');
    trade_imperfectbs = strategy.getlivetrade_tdsq(code,'reverse','imperfectbs');
    trade_perfectss = strategy.getlivetrade_tdsq(code,'reverse','perfectss');
    trade_semiperfectss = strategy.getlivetrade_tdsq(code,'reverse','semiperfectss');
    trade_imperfectss = strategy.getlivetrade_tdsq(code,'reverse','imperfectss');
    trade_singlelvldn = strategy.getlivetrade_tdsq(code,'trend','single-lvldn');
    trade_singlelvlup = strategy.getlivetrade_tdsq(code,'trend','single-lvlup');
    trade_doublerange = strategy.getlivetrade_tdsq(code,'trend','double-range');
    trade_doublebullish = strategy.getlivetrade_tdsq(code,'trend','double-bullish');
    trade_doublebearish = strategy.getlivetrade_tdsq(code,'trend','double-bearish');

    if ~isempty(trade_perfectbs)
        strategy.riskmanagement_perfectbs(trade_perfectbs);
    end
        
    if ~isempty(trade_semiperfectbs)
        strategy.riskmanagement_semiperfectbs(trade_semiperfectbs);
    end

    if ~isempty(trade_imperfectbs)
        strategy.riskmanagement_imperfectbs(trade_imperfectbs);
    end

    if ~isempty(trade_perfectss)
        strategy.riskmanagement_perfectss(trade_perfectss);
    end

    if ~isempty(trade_semiperfectss)
        strategy.riskmanagement_semiperfectss(trade_semiperfectss);
    end

    if ~isempty(trade_imperfectss)
        strategy.riskmanagement_imperfectss(trade_imperfectss);
    end
    
    if ~isempty(trade_singlelvldn)
        strategy.riskmanagement_singlelvldn(trade_singlelvldn);
    end
    
    if ~isempty(trade_singlelvlup)
        strategy.riskmanagement_singlelvlup(trade_singlelvlup);
    end
    
    if ~isempty(trade_doublerange)
        strategy.riskmanagement_doublerange(trade_doublerange);
    end
    
    if ~isempty(trade_doublebullish)
        strategy.riskmanagement_doublebullish(trade_doublebullish);
    end
    
    if ~isempty(trade_doublebearish)
        strategy.riskmanagement_doublebearish(trade_doublebearish);
    end
    
end