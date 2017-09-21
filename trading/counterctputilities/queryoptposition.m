function [delta,gamma,theta,vega] = queryoptposition(counter,opt,quote,doprint)
    if ~isa(counter,'CounterCTP')
        error('queryoptposition:invalid counter input')
    end
    
    if ~isa(opt,'cOption')
        error('queryoptposition:invalid option input')
    end
    
    if ~isa(quote,'cQuoteOpt')
        error('queryoptposition:invalid quote input')
    end
    
    if nargin < 4, doprint = true; end
    
    code_ctp = opt.code_ctp;
    [pos,ret] = counter.queryPositions(code_ctp);
    if ~ret, return; end
    delta = pos.direction*pos.total_position*quote.delta*quote.last_trade_underlier*opt.contract_size;
    gamma = pos.direction*pos.total_position*quote.gamma*opt.contract_size;
    vega = pos.direction*pos.total_position*quote.vega*opt.contract_size;
    theta = pos.direction*pos.total_position*quote.theta*opt.contract_size;
    
    if ~doprint, return; end
    
    fprintf('opt:%s; ',code_ctp)
    fprintf('iv:%4.1f%%; ',quote.impvol*100);
    fprintf('delta:%8.0f; ',delta);
    fprintf('gamma:%5.0f; ',gamma);
    fprintf('theta:%5.0f; ',theta);
    fprintf('vega:%8.0f; ',vega);
    fprintf('pos:%4d ',pos(1).total_position*pos.direction);
    fprintf('\n');
    

end

