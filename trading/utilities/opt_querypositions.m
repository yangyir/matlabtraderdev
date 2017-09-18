function [opt_delta,opt_gamma,opt_vega,opt_theta] = opt_querypositions(instruments,counter,qms)
    if ~isa(instruments,'cInstrumentArray')
        error('opt_querypositions:invalid instruments input')
    end
    
    if ~isa(counter,'CounterCTP')
        error('opt_querypositions:invalid counter input')
    end
    
    if ~isa(qms,'cQMS')
        error('opt_querypositions:invalid qms input')
    end
    
    opt_delta = 0;
    opt_gamma = 0;
    opt_vega = 0;
    opt_theta = 0;
    
    qms.refresh;
    opts = instruments.getinstrument;
    for i = 1:size(opts)
        q_i = qms.getquote(opts{i});
        if isempty(q_i), continue; end
        code_i = opts{i}.code_ctp;
        [pos_i,ret_i] = counter.queryPositions(code_i);
        if ~ret_i, continue; end
        delta_i = pos_i.direction*pos_i.total_position*q_i.delta*q_i.last_trade_underlier*opts{i}.contract_size;
        gamma_i = pos_i.direction*pos_i.total_position*q_i.gamma*opts{i}.contract_size;
        vega_i = pos_i.direction*pos_i.total_position*q_i.vega*opts{i}.contract_size;
        theta_i = pos_i.direction*pos_i.total_position*q_i.theta*opts{i}.contract_size;
        fprintf('opt:%s; ',code_i)
        fprintf('iv:%4.1f%%; ',q_i.impvol*100);
        fprintf('delta:%8.0f; ',delta_i);
        fprintf('gamma:%5.0f; ',gamma_i);
        fprintf('theta:%5.0f; ',theta_i);
        fprintf('vega:%8.0f; ',vega_i);
        fprintf('pos:%d ',pos_i(1).total_position);
        opt_delta = opt_delta + delta_i; 
        opt_gamma = opt_gamma + gamma_i;
        opt_vega = opt_vega + vega_i;
        opt_theta = opt_theta + theta_i;
        fprintf('\n');
    end
    

end