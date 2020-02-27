% [ iv_c_feb,iv_p_feb,marked_fwd_fed ] = etf300_sh_iv( conn,opt_c_feb,opt_p_feb,exp_feb,k );
[ iv_c_mar,iv_p_mar,marked_fwd_mar ] = etf300_sh_iv( conn,opt_c_mar,opt_p_mar,exp_mar,k );
%%
p = hd(:,1:5);
nfractal = 6;
outputmat = tools_technicalplot1(p,nfractal,1);
[~,~,~,up,dn] = fractalenhanced(p,nfractal,'volatilityperiod',6);
figure(2);
candle(p(:,3),p(:,4),p(:,5),p(:,2));
hold on;
stairs(up,'r--');stairs(dn,'g--');hold off;grid off;