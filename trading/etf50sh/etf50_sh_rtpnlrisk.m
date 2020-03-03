port_opt50_mar = {'p2.65';'p2.75';'p2.8';'p2.85';'c2.85';'p2.9';'c2.9';'c3.0';'c3.2'};
volume_opt50_mar = [-110;21;74;-5;-15;-53;-48;77;-40];
% port_opt50_mar
rtbd_opt50_mar = cell(length(port_opt50_mar),1); 
deltacarry_opt50_mar = zeros(length(port_opt50_mar),1);
gammacarry_opt50_mar = deltacarry_opt50_mar;
vegacarry_opt50_mar = deltacarry_opt50_mar;
thetacarry_opt50_mar = deltacarry_opt50_mar;
deltapnl_opt50_mar = deltacarry_opt50_mar;gammapnl_opt50_mar = deltacarry_opt50_mar;thetapnl_opt50_mar = deltacarry_opt50_mar;vegapnl_opt50_mar = deltacarry_opt50_mar;
%%
[iv_c_mar,iv_p_mar,marked_fwd_mar,quotes_opt50_mar,quotes_50etf] = etf50_sh_iv( conn,opt50_c_mar,opt50_p_mar,exp_mar,k );
%
for i = 1:length(port_opt50_mar)
    opt_i = port_opt50_mar{i};
    cpflag = opt_i(1);
    strike = str2double(opt_i(2:end));
    j = find(k==strike,1,'first');
    if strcmpi(cpflag,'c')
        bd_i = bd_opt50c_mar{j};
    else
        bd_i = bd_opt50p_mar{j};
    end
    rtbd_opt50_mar{i} = pnlriskbreakdownbbg2(bd_i,quotes_opt50_mar(j,:),quotes_50etf,volume_opt50_mar(i));
    deltacarry_opt50_mar(i) = rtbd_opt50_mar{i}.deltacarry;
    gammacarry_opt50_mar(i) = rtbd_opt50_mar{i}.gammacarry;
    vegacarry_opt50_mar(i) = rtbd_opt50_mar{i}.vegacarry;
    thetacarry_opt50_mar(i) = rtbd_opt50_mar{i}.thetacarry;
    deltapnl_opt50_mar(i) = rtbd_opt50_mar{i}.pnldelta;
    gammapnl_opt50_mar(i) = rtbd_opt50_mar{i}.pnlgamma;
    vegapnl_opt50_mar(i) = rtbd_opt50_mar{i}.pnlvega;
    thetapnl_opt50_mar(i) = rtbd_opt50_mar{i}.pnltheta;
end
fprintf('\nportfolio:\n');
fprintf('%5s%10s%15s%15s%15s%15s%15s%15s%15s%15s\n','code','volume','theta@','delta@','gamma@','vega@','theta$','delta$','gamma$','vega$');
for i = 1:length(port_opt50_mar)
    fprintf('%5s%10d%15.1f%15.1f%15.1f%15.1f%15.1f%15.1f%15.1f%15.1f\n',port_opt50_mar{i},...
        volume_opt50_mar(i),thetacarry_opt50_mar(i),deltacarry_opt50_mar(i),gammacarry_opt50_mar(i),vegacarry_opt50_mar(i),...
        thetapnl_opt50_mar(i),deltapnl_opt50_mar(i),gammapnl_opt50_mar(i),vegapnl_opt50_mar(i));
end
fprintf('%5s%10d%15.1f%15.1f%15.1f%15.1f%15.1f%15.1f%15.1f%15.1f\n','TOTAL',NaN,....
    sum(thetacarry_opt50_mar),sum(deltacarry_opt50_mar),sum(gammacarry_opt50_mar),sum(vegacarry_opt50_mar),...
    sum(thetapnl_opt50_mar),sum(deltapnl_opt50_mar),sum(gammapnl_opt50_mar),sum(vegapnl_opt50_mar));
