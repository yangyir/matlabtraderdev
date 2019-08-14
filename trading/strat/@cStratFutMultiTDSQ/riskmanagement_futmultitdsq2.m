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

    if ~isempty(trade_perfectbs), strategy.riskmanagement_perfectbs(trade_perfectbs);end
        
    if ~isempty(trade_semiperfectbs)
        error('not implemented')
    end

    if ~isempty(trade_imperfectbs)
        error('not implemented')
    end

    if ~isempty(trade_perfectss), strategy.riskmanagement_perfectss(trade_perfectss);end

    if ~isempty(trade_semiperfectss)
        error('not implemented')
    end

    if ~isempty(trade_imperfectss)
        error('not implemented')
    end
    
end