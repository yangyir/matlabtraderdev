function [output] = pnlriskbreakdownbbg2(optcarryinfo,qc,qu,volume)
%function to break down the pnl attribution of the input option from the
%previous business date as of the input cobdate to cobdate
%i.e.pnl and risk  intraday
%bloomberg version
%codeup for 300ETF and 50ETF
if nargin < 4, volume = 1; end

code_bbg = optcarryinfo.code;

%%
cobdate = today;
if isholiday(cobdate), cobdate = getlastbusinessdate;end
mult = 10000; 
predate = businessdate(cobdate,-1);
if predate ~= datenum(optcarryinfo.date2,'yyyy-mm-dd')
    error('invalid optcarryinfo input');
end

nextdate = businessdate(cobdate,1);
price1_underlier = optcarryinfo.spot2;
price2_underlier = 0.5*(qu(1) + qu(2));

pv1_sec = optcarryinfo.premium2/mult;
if strcmpi(code_bbg(20),'C')
    optclass = 'call';
    pv2_sec = 0.5*(qc(1)+qc(2));
else
    optclass = 'put';
    pv2_sec = 0.5*(qc(3)+qc(4));
end

k = str2double(code_bbg(21:end-7));

bid_fwd = k+qc(1)-qc(4);
ask_fwd = k+qc(2)-qc(3);
fwd1_underlier = optcarryinfo.fwd2;
fwd2_underlier = 0.5*(ask_fwd+bid_fwd);


opt_expiry_date1 = datenum(code_bbg(11:18),'mm/dd/yy');

tau2 = (opt_expiry_date1 - datenum(cobdate))/365;
tau3 = (opt_expiry_date1 - datenum(nextdate))/365;
r = 0.025;

yld2 = log(fwd2_underlier/price2_underlier)/tau2-r;
%

%%

iv1 = optcarryinfo.iv2;
iv2 = blkimpv(fwd2_underlier,k,r,tau2,pv2_sec,[],[],{optclass});
if isnan(iv2), iv2 = 0.01;end


%pvcarry: from previous business date
%pvcarry_:to next business date
if strcmpi(code_bbg(20),'C')
    pvcarry_ = blkprice(fwd2_underlier,k,r,tau3,iv2);
else
    [~,pvcarry_] = blkprice(fwd2_underlier,k,r,tau3,iv2);
end

thetacarry = pvcarry_ - pv2_sec;
pnl_theta = optcarryinfo.thetacarry;

%delta/gamma carry
bump = 0.005;
priceup_ = price2_underlier*(1+bump)*exp((r+yld2)*tau2);
pricedn_ = price2_underlier*(1-bump)*exp((r+yld2)*tau2);

if strcmpi(code_bbg(20),'C')
    pvup_ = blkprice(priceup_,k,r,tau3,iv2);
    pvdn_ = blkprice(pricedn_,k,r,tau3,iv2);
else
    [~,pvup_] = blkprice(priceup_,k,r,tau3,iv2);
    [~,pvdn_] = blkprice(pricedn_,k,r,tau3,iv2);
end

pnl_delta = optcarryinfo.deltacarry*(price2_underlier-price1_underlier)/price1_underlier;
pnl_gamma = optcarryinfo.gammacarry*(price2_underlier-price1_underlier)^2/price1_underlier/price1_underlier*100*0.5;
%
deltacarry = (pvup_-pvdn_)/(priceup_-pricedn_);
gammacarry = (pvup_+pvdn_-2*pvcarry_)/(bump*price2_underlier)^2*price2_underlier/100;

%vega
if strcmpi(code_bbg(20),'C')
    pvvolup_ = blkprice(fwd2_underlier,k,r,tau3,iv2+bump);
    pvvoldn_ = blkprice(fwd2_underlier,k,r,tau3,iv2-bump);
else
    [~,pvvolup_] = blkprice(fwd2_underlier,k,r,tau3,iv2+bump);
    [~,pvvoldn_] = blkprice(fwd2_underlier,k,r,tau3,iv2-bump);
end

pnl_vega = optcarryinfo.vegacarry*(iv2-iv1)*100;
vegacarry = pvvolup_ - pvvoldn_;
%
pnl = (pv2_sec-pv1_sec)*mult;
pnl_explained = pnl_theta+pnl_delta+pnl_gamma+pnl_vega;
pnl_unexplained = pnl-pnl_explained;

output = struct('code',code_bbg,...
    'pnltotal',pnl*volume,...
    'pnltheta',optcarryinfo.thetacarry*volume,...
    'pnldelta',pnl_delta*volume,...
    'pnlgamma',pnl_gamma*volume,...
    'pnlvega',pnl_vega*volume,...
    'pnlunexplained',pnl_unexplained*volume,...
    'date1',datestr(predate,'yyyy-mm-dd'),...
    'date2',datestr(cobdate,'yyyy-mm-dd'),...
    'iv1',iv1,...
    'iv2',iv2,...
    'spot1',price1_underlier,...
    'spot2',price2_underlier,...
    'fwd1',fwd1_underlier,...
    'fwd2',fwd2_underlier,...
    'premium1',pv1_sec*volume*mult,...
    'premium2',pv2_sec*volume*mult,...
    'volume',volume,...
    'deltacarry',deltacarry*volume*mult*price2_underlier,...
    'gammacarry',gammacarry*volume*mult*price2_underlier,...
    'thetacarry',thetacarry*volume*mult,...
    'vegacarry',vegacarry*volume*mult);
    
end