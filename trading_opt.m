%%
stratopt = cStratOptSingleStraddle;
for i = 1:size(strikes_soymeal)
    stratopt.registerinstrument(opt_c_m1801{i});stratopt.registerinstrument(opt_p_m1801{i});
    %
    qms_opt_m.registerinstrument(opt_c_m1801{i});qms_opt_m.registerinstrument(opt_p_m1801{i});
end

%%
qms_opt_m.refresh;quotes = qms_opt_m.getquote;for i = 1:size(quotes,1), quotes{i}.print; end

%%
fprintf('\n')
stratopt.update(qms_opt_m);

%%
qms_opt_m.refresh;
stratopt.querypositions(c_ly,qms_opt_m);

%%
opt_savepositions(stratopt.instruments_,stratopt.underliers_,c_ly,qms_local)

%%
lastbd = getlastbusinessdate;
%print the pnl and risk as of the position carried from the previous
%business date of the last business date 
[pnltbl1,risktbl1] = stratopt.pnlrisk1(lastbd);
printpnltbl(pnltbl1);printrisktbl(risktbl1);
%update the cost as of the the last business date
stratopt.updatecost(lastbd,risktbl1);

%%
qms_opt_m.refresh;quotes = qms_opt_m.getquote;
[pnltbl2,risktbl2] = stratopt.pnlrisk2(quotes);

%%
qms_opt_m.refresh
idx = 7;
sec = opt_p_m1801{idx};
q = qms_opt_m.getquote(sec);
fprintf('\n%s %d %4.1f%%  %8.0f\n',q.opt_type,q.opt_strike,q.impvol*100, q.delta*q.last_trade_underlier*sec.contract_size);

%%
% trade single options
s1 = sec.code_ctp;
direction = -1;
offset = 1;

n = 5;

e1 = Entrust;
if direction == 1
    e1.fillEntrust(1,s1,direction,q.ask1,n,offset,s1);
else
    e1.fillEntrust(1,s1,direction,q.bid1,n,offset,s1);
end

c_ly.placeEntrust(e1);

%%
% eod operations
qms_opt_m.refresh
residual = risktbl2.deltacarry(end);
spot = qms_opt_m.getquote{1}.last_trade_underlier;
if residual > 0
    %we need to sell call options
    for idx_opt = 1:size(opt_c_m1801,1)-1
        if opt_c_m1801{idx_opt}.opt_strike <= spot && opt_c_m1801{idx_opt+1}.opt_strike >= spot
            opt1 = opt_c_m1801{idx_opt};
            opt2 = opt_c_m1801{idx_opt+1};
            break
        end
    end
elseif residual < 0
    %we need to sell put options
    for idx_opt = 1:size(opt_c_m1801,1)-1
        if opt_p_m1801{idx_opt}.opt_strike <= spot && opt_p_m1801{idx_opt+1}.opt_strike >= spot
            opt1 = opt_p_m1801{idx_opt};
            opt2 = opt_p_m1801{idx_opt+1};
            break
        end
    end
end

q1 = qms_opt_m.getquote(opt1);
q2 = qms_opt_m.getquote(opt2);
fprintf('\n%s %d %4.1f%%  %8.0f\n',q1.opt_type,q1.opt_strike,q1.impvol*100, q1.delta*q1.last_trade_underlier*opt1.contract_size);
fprintf('%s %d %4.1f%%  %8.0f\n',q2.opt_type,q2.opt_strike,q2.impvol*100, q2.delta*q2.last_trade_underlier*opt2.contract_size);

ratio1 = (spot - opt1.opt_strike) ./ (opt2.opt_strike - opt1.opt_strike);
ratio2 = 1-ratio1;

n2 = 3;
n1 = round(n2*ratio1/ratio2);

e1 = Entrust;
e2 = Entrust;
e1.fillEntrust(1,opt1.code_ctp,-1,q1.bid1,n1,1,opt1.code_ctp);
e2.fillEntrust(1,opt2.code_ctp,-1,q2.bid1,n2,1,opt2.code_ctp);

c_ly.placeEntrust(e1);
c_ly.placeEntrust(e2);


%%
%close positions
n = 3;
direction = 1;
offset = -1;

qms_opt_m.refresh;
for i = 1:size(risktbl2.Properties.RowNames,1)
    sec = risktbl2.Properties.RowNames{i};
    if strcmpi(sec,'m1801'), continue;end
    if strcmpi(sec,'total'), continue;end
    ni = risktbl2.volume(i);
    %todo:
    %some sanity check here
    q = qms_opt_m.getquote(sec);
    code = q.code_ctp;
    e = Entrust;
    if direction == 1
        e.fillEntrust(1,sec,direction,q.ask1,min(n,abs(ni)),offset,sec);
    else
        e.fillEntrust(1,sec,direction,q.bid1,min(n,abs(ni)),offset,sec);
    end
    c_ly.placeEntrust(e);
end








