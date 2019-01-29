%% user inputs
code_ctp_underlier = 'c1905';
underlier = code2instrument(code_ctp_underlier);
numstrikes = 5;
%%
mdeopt = cMDEOpt;
[calls,puts] = mdeopt.loadoptions(code_ctp_underlier,numstrikes);
strikes = zeros(numstrikes,1);
for i = 1:numstrikes, strikes(i) = calls{i}.opt_strike;end
%%
mdeopt.login('connection','ctp','countername','ccb_ly_fut');
mdeopt.start
%%
c_opt = CounterCTP.ccb_ly_fut;
c_opt.login
%%
% short put and long all and sell the underlier
mdeopt.qms_.refresh;
fprintf('\n');
qc = cell(numstrikes,1);
qp = qc;
qu = qc;
for i = 1:numstrikes
    qc{i} = mdeopt.qms_.getquote(calls{i});
    qp{i} = mdeopt.qms_.getquote(puts{i});
    qu{i} = mdeopt.qms_.getquote(code_ctp_underlier);
    cost = qu{i}.bid1-(calls{i}.opt_strike - qp{i}.bid1 + qc{i}.ask1);
    fprintf('cost:%s\n',num2str(cost));
end
%%
i = 1;
buy = 1;
sell = -1;
offset = 1;
volume = 2;
if cost > 0
    entrust1 = Entrust;
    entrust2 = Entrust;
    entrust3 = Entrust;
    entrust1.fillEntrust(1,calls{i}.code_ctp,buy,qc{i}.ask1,volume,offset,calls{i}.code_ctp);
    entrust2.fillEntrust(1,puts{i}.code_ctp,sell,qp{i}.bid1,volume,offset,puts{i}.code_ctp);
    entrust3.fillEntrust(1,code_ctp_underlier,sell,qu{i}.bid1,volume,offset,code_ctp_underlier);
    c_opt.placeEntrust(entrust1);
    c_opt.placeEntrust(entrust2);
    c_opt.placeEntrust(entrust3);
end
    
%%
mdeopt.stop
%%
posc = cell(numstrikes,1);
posp = cell(numstrikes,1);
for i = 1:numstrikes
    posc{i} = c_opt.queryPositions(calls{i}.code_ctp);
    posp{i} = c_opt.queryPositions(puts{i}.code_ctp);
    if posc{i}.total_position ~= posp{i}.total_position
        error('c-p parity failed')
    end
end
posu = c_opt.queryPositions(code_ctp_underlier);
%%
longcarrycost = zeros(numstrikes,2);
for i = 1:numstrikes
    longcarrycost(i,1) = calls{i}.opt_strike+posc{i}.avg_price/calls{i}.contract_size-posp{i}.avg_price/puts{i}.contract_size;
    longcarrycost(i,2) = posc{i}.total_position;
end
longcarryavgcost = sum(longcarrycost(:,1).*longcarrycost(:,2))/sum(longcarrycost(:,2));
%
risklessprofit = (posu.avg_price/underlier.contract_size-longcarryavgcost)*underlier.contract_size*posu.total_position;
fprintf('riskless profit:%s\n',num2str(risklessprofit));


