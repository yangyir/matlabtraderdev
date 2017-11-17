function [delta,gamma,vega,theta,pnl] = opt_querypositions(instruments,counter,qms)
    if ~isa(instruments,'cInstrumentArray')
        error('opt_querypositions:invalid instruments input')
    end
    
    if ~isa(counter,'CounterCTP')
        error('opt_querypositions:invalid counter input')
    end
    
    if ~isa(qms,'cQMS')
        error('opt_querypositions:invalid qms input')
    end
    
    delta = 0;
    gamma = 0;
    vega = 0;
    theta = 0;
    pnl = 0;
    
    qms.refresh;
    opts = instruments.getinstrument;
    
    fprintf('\n');
    for i = 1:size(opts,1)
        q_i = qms.getquote(opts{i});
        if isempty(q_i), continue; end
        code_i = opts{i}.code_ctp;
        [pos_i,ret_i] = counter.queryPositions(code_i);
        if ~ret_i, continue; end
        if isa(q_i,'cQuoteOpt')
            delta_i = pos_i.direction*pos_i.total_position*q_i.delta*q_i.last_trade_underlier*opts{i}.contract_size;
            gamma_i = pos_i.direction*pos_i.total_position*q_i.gamma*opts{i}.contract_size*q_i.last_trade_underlier;
            vega_i = pos_i.direction*pos_i.total_position*q_i.vega*opts{i}.contract_size;
            theta_i = pos_i.direction*pos_i.total_position*q_i.theta*opts{i}.contract_size;
            pnl_i = pos_i.direction*pos_i.total_position*opts{i}.contract_size*(q_i.last_trade-pos_i.avg_price/opts{i}.contract_size);
            if isnan(pnl_i)
                pnl_i = 0;
            end
        else
            delta_i = 0;
            for j = 1:size(pos_i,2)
                delta_i = delta_i + pos_i(j).direction*pos_i(j).total_position*q_i.last_trade*opts{i}.contract_size;
            end
            gamma_i = 0;
            vega_i = 0;
            theta_i = 0;
            pnl_i = 0;
            for j = 1:size(pos_i,2)
                pnl_i = pnl_i + pos_i(j).direction*pos_i(j).total_position*opts{i}.contract_size*(q_i.last_trade-pos_i(j).avg_price/opts{i}.contract_size);
            end
        end
        fprintf('opt:%12s; ',code_i)
        fprintf('iv:%4.1f%%; ',q_i.impvol*100);
        fprintf('delta:%9.0f; ',delta_i);
        fprintf('gamma:%9.0f; ',gamma_i);
        fprintf('theta:%5.0f; ',theta_i);
        fprintf('vega:%8.0f; ',vega_i);
        fprintf('pos:%5d; ',pos_i(1).total_position*pos_i.direction);
        fprintf('pnl:%8.0f ',pnl_i);
        delta = delta + delta_i; 
        gamma = gamma + gamma_i;
        vega = vega + vega_i;
        theta = theta + theta_i;
        pnl = pnl+pnl_i;
        fprintf('\n');
    end

    

end