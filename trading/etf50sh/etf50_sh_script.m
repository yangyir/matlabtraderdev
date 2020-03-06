% [ iv_c_feb,iv_p_feb,marked_fwd_fed ] = etf50_sh_iv( conn,opt_c_feb,opt_p_feb,exp_feb,k );
[ iv_c_mar,iv_p_mar,marked_fwd_mar,quotes_opt50_mar,quotes_50etf] = etf50_sh_iv( conn,opt50_c_mar,opt50_p_mar,exp_mar,k );
% [ iv_c_jun,iv_p_jun,marked_fwd_jun ] = etf50_sh_iv( conn,opt50_c_jun,opt50_p_jun,exp_jun,k );
%%
% EOD info:
% CALL
n_c_mar = length(opt50_c_mar);
bd_c_mar = cell(n_c_mar,1);
tbl_c_mar = [k_50',zeros(length(k_50),3)];
cobdate = '2020-03-06';
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
tbl_p_mar = [k_50',zeros(length(k_50),3)];
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
n_c_jun = length(opt50_c_jun);
bd_c_jun = cell(n_c_jun,1);
tbl_c_jun = [k_50',zeros(length(k_50),3)];
for i = 1:n_c_jun
    try
        bd_c_jun{i} = pnlriskbreakdownbbg(opt50_c_jun{i},datenum(cobdate));
        tbl_c_jun(i,2) = bd_c_jun{i}.iv1;
        tbl_c_jun(i,3) = bd_c_jun{i}.iv2;
        tbl_c_jun(i,4) = bd_c_jun{i}.deltacarry/bd_c_jun{i}.spot2/10000;
    catch
        bd_c_jun{i} = [];
        tbl_c_jun(i,2:4) = NaN;
    end
end
% PUT
n_p_jun = length(opt50_p_jun);
bd_p_jun = cell(n_p_jun,1);
tbl_p_jun = [k_50',zeros(length(k_50),3)];
for i = 1:n_p_jun
    try
        bd_p_jun{i} = pnlriskbreakdownbbg(opt50_p_jun{i},datenum(cobdate));
        tbl_p_jun(i,2) = bd_p_jun{i}.iv1;
        tbl_p_jun(i,3) = bd_p_jun{i}.iv2;
        tbl_p_jun(i,4) = bd_p_jun{i}.deltacarry/bd_p_jun{i}.spot2/10000;
    catch
        bd_p_jun{i} = [];
        tbl_p_jun(i,2:4) = NaN;
    end
end
%
%% vol 1d change
fwd1 = bd_c_jun{1}.fwd1;fwd2 = bd_c_jun{1}.fwd2;
m1 = tbl_c_jun(:,1)/fwd1;
m2 = tbl_c_jun(:,1)/fwd2;
m = max(min(m1),min(m2)):0.01:min(max(m1),max(m2));
volinterp1 = interp1(m1,tbl_c_jun(:,2),m);
volinterp2 = interp1(m1,tbl_c_jun(:,3),m);

subplot(211);
% plot(m1,tbl_c_jun(:,2),'-');hold on;
plot(m,volinterp1,'-');hold on;
if bd_c_jun{1}.spot1 < bd_c_jun{1}.spot2
    color = 'r';
    plot(m,volinterp2,'r-');
else
    color = 'g';
    plot(m,volinterp2,'g-');
end
hold off;
legend(bd_c_jun{1}.date1,bd_c_jun{1}.date2);
xlabel('moneyness');ylabel('vol');
subplot(212);

bar(m,volinterp2-volinterp1,color);
xlabel('moneyness');ylabel('spread');