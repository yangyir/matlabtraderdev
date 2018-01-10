function [pnltbl,risktbl] = pnlriskrealtime(obj)
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
        pos = p.pos_list{i};
        [~,idx] = obj.instruments_.hasinstrument(pos.instrument_);
        if idx == 0
            %not in the option list and it might be futures
            [~,idx] = obj.underliers_.hasinstrument(pos.instrument_);
            if idx == 0
                error('invalid instrument')
            else
                isfut = true;
                isopt = false;
            end
        else
            isopt = isoptchar(pos.code_ctp_);
            if ~isopt
                isfut = true;
            else
                isfut = false;
            end
        end
        carrycost = pos.cost_carry_;
        volume_total = pos.direction_*pos.position_total_;
        volume_today = pos.direction_*pos.position_today_;
        rownames{i} = pos.code_ctp_;
        volume(i,1) = volume_total;
        if isopt
            opt = pos.instrument_;
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
            total(i,1) = (q.last_trade-carrycost)*volume_total*mult;
            thetacarry(i,1) = obj.thetacarry_(idx)*volume_total;
            deltacarry(i,1) = obj.deltacarry_(idx)*volume_total;
            gammacarry(i,1) = obj.gammacarry_(idx)*volume_total;
            vegacarry(i,1) = obj.vegacarry_(idx)*volume_total;
            ivbase(i,1) = obj.impvolcarryyesterday_(idx);
            ivcarry(i,1) = obj.impvol_(idx);
            if volume_total ~= 0
                if volume_today == 0
                    if calc_theta
                        theta(i,1) = obj.thetacarryyesterday_(idx)*volume_total;
                    end
                    delta(i,1) = obj.deltacarryyesterday_(idx)*ret*volume_total;
                    gamma(i,1) = 0.5*obj.gammacarryyesterday_(idx)*ret^2*100*volume_total;
                    
                    vega(i,1) = obj.vegacarryyesterday_(idx)*(ivcarry(i,1)-ivbase(i,1))/0.01*volume_total;
                    unexplained(i,1) = total(i,1)-(theta(i,1)+delta(i,1)+gamma(i,1)+vega(i,1));
                else
                    %in case we have new position traded, we only compute
                    %the pnl for the old carried positions as it would be
                    %difficult to record all the trading cost and greeks
                    %associated with the time the trade happens
                    if calc_theta
                        theta(i,1) = obj.thetacarryyesterday_(idx)*(volume_total-volume_today);
                    end
                    delta(i,1) = obj.deltacarryyesterday_(idx)*ret*(volume_total-volume_today);
                    gamma(i,1) = 0.5*obj.gammacarryyesterday_(idx)*ret^2*100*(volume_total-volume_today);
                    
                    vega(i,1) = obj.vegacarryyesterday_(idx)*(ivcarry(i,1)-ivbase(i,1))/0.01*(volume_total-volume_today);
                end
                unexplained(i,1) = total(i,1)-(theta(i,1)+delta(i,1)+gamma(i,1)+vega(i,1));
            end
        elseif isfut
            fut = p.instrument_list{i};
            mult = fut.contract_size;
            q = obj.mde_fut_.qms_.getquote(fut);
            %note:todo:we will updat the pnl attribution with
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