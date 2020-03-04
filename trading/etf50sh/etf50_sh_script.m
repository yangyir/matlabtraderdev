% [ iv_c_feb,iv_p_feb,marked_fwd_fed ] = etf50_sh_iv( conn,opt_c_feb,opt_p_feb,exp_feb,k );
[ iv_c_mar,iv_p_mar,marked_fwd_mar,quotes_opt50_mar,quotes_50etf] = etf50_sh_iv( conn,opt50_c_mar,opt50_p_mar,exp_mar,k );
% [ iv_c_jun,iv_p_jun,marked_fwd_jun ] = etf50_sh_iv( conn,opt50_c_jun,opt50_p_jun,exp_jun,k );
%%
% EOD info:
% CALL
n_c_mar = length(opt50_c_mar);
bd_c_mar = cell(n_c_mar,1);
tbl_c_mar = [k',zeros(length(k),3)];
cobdate = '2020-03-04';
for i = 1:n_c_mar
    try
        bd_c_mar{i} = pnlriskbreakdownbbg(opt50_c_mar{i},datenum(cobdate));
        tbl_c_mar(i,2) = bd_c_mar{i}.iv1;
        tbl_c_mar(i,3) = bd_c_mar{i}.iv2;
        tbl_c_mar(i,4) = bd_c_mar{i}.deltacarry/bd_c_mar{i}.spot2/10000;
    catch
        bd_c_mar{i} = [];
        tbl_c_mar(i,2:4) = NaN;
    end
end
% PUT
n_p_mar = length(opt50_p_mar);
bd_p_mar = cell(n_p_mar,1);
tbl_p_mar = [k',zeros(length(k),3)];
for i = 1:n_p_mar
    try
        bd_p_mar{i} = pnlriskbreakdownbbg(opt50_p_mar{i},datenum(cobdate));
        tbl_p_mar(i,2) = bd_p_mar{i}.iv1;
        tbl_p_mar(i,3) = bd_p_mar{i}.iv2;
        tbl_p_mar(i,4) = bd_p_mar{i}.deltacarry/bd_p_mar{i}.spot2/10000;
    catch
        bd_p_mar{i} = [];
        tbl_p_mar(i,2:4) = NaN;
    end
end
%% vol 1d change
fwd1 = bd_c_mar{1}.fwd1;fwd2 = bd_c_mar{1}.fwd2;
m1 = tbl_c_mar(:,1)/fwd1;
m2 = tbl_c_mar(:,1)/fwd2;
m = max(min(m1),min(m2)):0.01:min(max(m1),max(m2));
volinterp1 = interp1(m1,tbl_c_mar(:,2),m);
volinterp2 = interp1(m1,tbl_c_mar(:,3),m);

subplot(211);
% plot(m1,tbl_c_mar(:,2),'-');hold on;
plot(m,volinterp1,'-');hold on;
if bd_c_mar{1}.spot1 < bd_c_mar{1}.spot2
    color = 'r';
    plot(m,volinterp2,'r-');
else
    color = 'g';
    plot(m,volinterp2,'g-');
end
hold off;
legend(bd_c_mar{1}.date1,bd_c_mar{1}.date2);
xlabel('moneyness');ylabel('vol');
subplot(212);

bar(m,volinterp2-volinterp1,color);
xlabel('moneyness');ylabel('spread');
%%
port1_mar = {'p2.65';'p2.75';'p2.8';'p2.85';'c2.85';'p2.9';'c2.9';'c3.0';'c3.2'};
v1_mar = [-110;21;74;-5;-15;-53;-48;77;-40];
deltapnl = zeros(length(port1_mar),1);
gammapnl = zeros(length(port1_mar),1);
thetapnl = zeros(length(port1_mar),1);
vegapnl = zeros(length(port1_mar),1);
unexplainedpnl = zeros(length(port1_mar),1);
deltacarry = zeros(length(port1_mar),1);
gammacarry = zeros(length(port1_mar),1);
thetacarry = zeros(length(port1_mar),1);
vegacarry = zeros(length(port1_mar),1);
iv1 = zeros(length(port1_mar),1);
iv2 = zeros(length(port1_mar),1);
for i = 1:length(port1_mar)
    opt_i = port1_mar{i};
    cpflag = opt_i(1);
    strike = str2double(opt_i(2:end));
    j = find(k==strike,1,'first');
    if strcmpi(cpflag,'p')
        bd_i = bd_p_mar{j};
    else
        bd_i = bd_c_mar{j};
    end
    deltapnl(i) = v1_mar(i)*bd_i.pnldelta;
    gammapnl(i) = v1_mar(i)*bd_i.pnlgamma;
    thetapnl(i) = v1_mar(i)*bd_i.pnltheta;
    vegapnl(i) = v1_mar(i)*bd_i.pnlvega;
    unexplainedpnl(i) = v1_mar(i)*bd_i.pnlunexplained;
    vegacarry(i) = v1_mar(i)*bd_i.vegacarry;
    deltacarry(i) = v1_mar(i)*bd_i.deltacarry;
    gammacarry(i) = v1_mar(i)*bd_i.gammacarry;
    thetacarry(i) = v1_mar(i)*bd_i.thetacarry;
    iv1(i) = bd_i.iv1;
    iv2(i) = bd_i.iv2;
end

