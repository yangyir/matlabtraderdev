positions = cell(size(opt_c_m1801,1)+size(opt_p_m1801,1)+1,4);

for i = 1:size(opt_c_m1801,1)
    try
        pos_i = c_ly.queryPositions(opt_c_m1801{i}.code_ctp);
        cost_i = pos_i.avg_price/opt_c_m1801{i}.contract_size;
        vol_i = pos_i.direction*pos_i.total_position;
    catch
        cost_i = 0;
        vol_i = 0;
    end
    positions{i,1} = opt_c_m1801{i}.code_ctp;
    positions{i,2} = vol_i;
    positions{i,3} = cost_i;
    positions{i,4} = opt_c_m1801{i};
end
%
nc = size(opt_c_m1801,1);
for i = 1:size(opt_p_m1801,1)
    try
        pos_i = c_ly.queryPositions(opt_p_m1801{i}.code_ctp);
        cost_i = pos_i.avg_price/opt_p_m1801{i}.contract_size;
        vol_i = pos_i.direction*pos_i.total_position;
    catch
        cost_i = 0;
        vol_i = 0;
    end
    positions{i+nc,1} = opt_p_m1801{i}.code_ctp;
    positions{i+nc,2} = vol_i;
    positions{i+nc,3} = cost_i;
    positions{i+nc,4} = opt_p_m1801{i};
end
%
try
    pos_i = c_ly.queryPositions(fut_m1801.code_ctp);
    cost_i = pos_i.avg_price/fut_m1801.contract_size;
    vol_i = pos_i.direction*pos_i.total_position;
catch
    cost_i = 0;
    vol_i = 0;
end

positions{end,1} = fut_m1801.code_ctp;
positions{end,2} = vol_i;
positions{end,3} = cost_i;
positions{end,4} = fut_m1801;

%%
qms_opt_ctp.refresh;
pnlrisk = cell(size(positions,1)+1,7);
for i = 1:size(positions,1)
    pnlrisk{i,1} = positions{i,1};
    pnlrisk{i,2} = positions{i,2};
    q = qms_opt_ctp.getquote(positions{i,4});
    if isa(q,'cQuoteOpt')
        delta = q.delta*q.last_trade_underlier*positions{i,2}*positions{i,4}.contract_size;
        gamma = q.gamma*positions{i,2}*positions{i,4}.contract_size;
        theta = q.theta*positions{i,2}*positions{i,4}.contract_size;
        vega = q.vega*positions{i,2}*positions{i,4}.contract_size;
    elseif isa(q,'cQuoteFut')
        delta = q.last_trade*positions{i,2}*positions{i,4}.contract_size;
        gamma = 0;
        theta = 0;
        vega = 0;
    end
    pnlrisk{i,3} = delta;
    pnlrisk{i,4} = gamma;
    pnlrisk{i,5} = theta;
    pnlrisk{i,6} = vega;
    pnlrisk{i,7} = (q.last_trade-positions{i,3})*positions{i,2}*positions{i,4}.contract_size;
end
pnlrisk{end,1} = 'total';
for j = 3:size(pnlrisk,2), pnlrisk{end,j} = sum(cell2mat(pnlrisk(1:end-1,j)));end
