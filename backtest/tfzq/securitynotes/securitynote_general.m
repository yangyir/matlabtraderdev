hd_eqindex500 = load('hd_eqindex500.mat');
hd_eqindex500 = hd_eqindex500.hd_eqindex500;
%%
%3m running period
notional = 62;
lastidx = size(hd_eqindex500,1)-notional;
payoff = zeros(lastidx,2);
for i = 1:lastidx
%     [payoff(i,1),payoff(i,2)] = payoff_sharkfin_bull(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'minimumpayoff',0.025,'knockoutlevel',1.18,'knockoutpayoff',0.035,'participateratio',0.45);
%     [payoff(i,1),payoff(i,2)] = payoff_sharkfin_bull(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'minimumpayoff',0.01,'knockoutlevel',1.18,'knockoutpayoff',0.01,'participateratio',1.06);
%     [payoff(i,1),payoff(i,2)] = payoff_sharkfin_bear(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'minimumpayoff',0.025,'knockoutlevel',0.9,'knockoutpayoff',0.025,'participateratio',1.25);
%     [payoff(i,1),payoff(i,2)] = payoff_sharkfin_straddle(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'minimumpayoff',0.02,'knockoutupperlevel',1.1,'knockoutlowerlevel',0.9,'knockoutupperpayoff',0.02,'knockoutlowerpayoff',0.02,'participateratioupper',1,'participateratiolower',1);
%     [payoff(i,1),payoff(i,2)] = payoff_sharkfin_straddle(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'minimumpayoff',0.02,'knockoutupperlevel',1.1,'knockoutlowerlevel',0.9,'knockoutupperpayoff',0.05,'knockoutlowerpayoff',0.02,'participateratioupper',7/8,'participateratiolower',1);
%     [payoff(i,1)] = payoff_bullspread(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'minimumpayoff',0.02,'upperstrikelevel',1.08,'participateratio',0.62);
%     [payoff(i,1)] = payoff_bearspread(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'minimumpayoff',0.02,'lowerstrikelevel',0.96,'participateratio',9/4);
%     [payoff(i,1)] = payoff_snowball(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'minimumpayoff',0.001,'knockoutlevel',1,'knockoutpayoff',0.075,'participateratio',1,'principalprotectionlevel',0.926);
    [payoff(i,1)] = payoff_snowball_ki(hd_eqindex500,'startdate',hd_eqindex500(i,1),'expirydate',hd_eqindex500(i+62,1),'knockoutlevel',1,'knockinlevel',0.7,'knockoutpayoff',0.073,'participateratio',1);
end
totalpayoff = sum(payoff(:,1));
annualreturn = totalpayoff/notional/lastidx*252;
%expected annual return of shark fin bull with high fixed but low floating is 4.02%
%expected annual return of shark fin bull with low fixed but high floating is 4.14%
%expected annual return of shark fin bear is 4.51%
%expected anuual return of shark fin straddle is 4.91%
%expected annual return of shark fin straddle with asymetric payoff is 5.39%
%expected annual return of bullspread(100-108) with 0.62 pr is 3.98%
%expected annual return of bearspread(96-100) with 2.25 pr is 6.04%
%expected annual return of principal-proctected snowball is 4.94%
%expected annual return of non-principal-proctected snowball with 70% KI is7.09%
%%
blkprice(1,1.05,0.03,0.25,0.25)

