function [output] = pnlriskbreakdownbbg(code_bbg,cobdate,volume)
%function to break down the pnl attribution of the input option from the
%previous business date as of the input cobdate to cobdate
%i.e.pnl and risk day to day
%bloomberg version
%codeup for 300ETF and 50ETF
if nargin < 3, volume = 1; end

if strcmpi(code_bbg,'510050 CH Equity') || strcmpi(code_bbg,'510300 CH Equity')
    predate = businessdate(cobdate,-1);
    data = cDataFileIO.loadDataFromTxtFile([code_bbg(1:6),'_daily.txt']);
    pv1_sec = data(data(:,1)==datenum(predate),5);
    pv2_sec = data(data(:,1)==datenum(cobdate),5);
    pnl = pv2_sec-pv1_sec;
    output = struct('code',code_bbg,...
    'pnltotal',pnl*volume*10000,...
    'pnltheta',0,...
    'pnldelta',pnl*volume*10000,...
    'pnlgamma',0,...
    'pnlvega',0,...
    'pnlunexplained',0,...
    'date1',datestr(predate,'yyyy-mm-dd'),...
    'date2',datestr(cobdate,'yyyy-mm-dd'),...
    'iv1',0,...
    'iv2',0,...
    'spot1',pv1_sec,...
    'spot2',pv2_sec,...
    'premium1',pv1_sec,...
    'premium2',pv2_sec,...
    'volume',volume,...
    'deltacarry',pv2_sec*volume*10000,...
    'gammacarry',0,...
    'thetacarry',0,...
    'vegacarry',0);
    return
end

%%
underlier = code_bbg(1:6);
mult = 10000; 
data = cDataFileIO.loadDataFromTxtFile([underlier,'_daily.txt']);
predate = businessdate(cobdate,-1);
nextdate = businessdate(cobdate,1);
price1_underlier = data(data(:,1)==datenum(predate),5);
price2_underlier = data(data(:,1)==datenum(cobdate),5);
if isempty(price1_underlier) || isempty(price2_underlier)
    error(['underlier ',underlier,' historical price not saved!'])
end
optstr = [underlier,'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7)];
data = cDataFileIO.loadDataFromTxtFile([optstr,'_daily.txt']);
pv1_sec = data(data(:,1)==datenum(predate),5);
pv2_sec = data(data(:,1)==datenum(cobdate),5);
if isempty(pv1_sec) || isempty(pv2_sec)
    error(['option ',optstr,' historical price not saved!'])
end

if strcmpi(code_bbg(20),'C')
    optclass = 'call';
    optstr2 = [underlier,'_',datestr(code_bbg(11:18),'mmmyy'),'_P',code_bbg(21:end-7)];
else
    optclass = 'put'; 
    optstr2 = [underlier,'_',datestr(code_bbg(11:18),'mmmyy'),'_C',code_bbg(21:end-7)];
end
data2 = cDataFileIO.loadDataFromTxtFile([optstr2,'_daily.txt']);
pv1_sec2 = data2(data2(:,1)==datenum(predate),5);
pv2_sec2 = data2(data2(:,1)==datenum(cobdate),5);
if isempty(pv1_sec) || isempty(pv2_sec)
    error(['option ',optstr,' historical price not saved!'])
end
k = str2double(code_bbg(21:end-7));
opt_expiry_date1 = datenum(code_bbg(11:18),'mm/dd/yy');

tau1 = (opt_expiry_date1 - datenum(predate))/365;
tau2 = (opt_expiry_date1 - datenum(cobdate))/365;
tau3 = (opt_expiry_date1 - datenum(nextdate))/365;
r = 0.025;

if strcmpi(code_bbg(20),'C')
    fwd1_underlier = (pv1_sec-pv1_sec2)*exp(r*tau1)+k;
    fwd2_underlier = (pv2_sec-pv2_sec2)*exp(r*tau2)+k;
else
    fwd1_underlier = (-pv1_sec+pv1_sec2)*exp(r*tau1)+k;
    fwd2_underlier = (-pv2_sec+pv2_sec2)*exp(r*tau2)+k;
end
%
yld1 = log(fwd1_underlier/price1_underlier)/tau1-r;
yld2 = log(fwd2_underlier/price2_underlier)/tau2-r;
%

%%

iv1 = blkimpv(fwd1_underlier,k,r,tau1,pv1_sec,[],[],{optclass});
if isnan(iv1), iv1 = 0.01;end
iv2 = blkimpv(fwd2_underlier,k,r,tau2,pv2_sec,[],[],{optclass});
if isnan(iv2), iv2 = 0.01;end


%pvcarry: from previous business date
%pvcarry_:to next business date
if strcmpi(code_bbg(20),'C')
    pvcarry = blkprice(fwd1_underlier,k,r,tau2,iv1);
    pvcarry_ = blkprice(fwd2_underlier,k,r,tau3,iv2);
else
    [~,pvcarry] = blkprice(fwd1_underlier,k,r,tau2,iv1);
    [~,pvcarry_] = blkprice(fwd2_underlier,k,r,tau3,iv2);
end

pnl_theta = pvcarry - pv1_sec;
thetacarry = pvcarry_ - pv2_sec;

%delta/gamma carry
bump = 0.005;
priceup = price1_underlier*(1+bump)*exp((r+yld1)*tau1);
pricedn = price1_underlier*(1-bump)*exp((r+yld1)*tau1);
priceup_ = price2_underlier*(1+bump)*exp((r+yld2)*tau2);
pricedn_ = price2_underlier*(1-bump)*exp((r+yld2)*tau2);

if strcmpi(code_bbg(20),'C')
    pvup = blkprice(priceup,k,r,tau2,iv1);
    pvdn = blkprice(pricedn,k,r,tau2,iv1);
    pvup_ = blkprice(priceup_,k,r,tau3,iv2);
    pvdn_ = blkprice(pricedn_,k,r,tau3,iv2);
else
    [~,pvup] = blkprice(priceup,k,r,tau2,iv1);
    [~,pvdn] = blkprice(pricedn,k,r,tau2,iv1);
    [~,pvup_] = blkprice(priceup_,k,r,tau3,iv2);
    [~,pvdn_] = blkprice(pricedn_,k,r,tau3,iv2);
end

delta = (pvup-pvdn)/(priceup-pricedn);
gamma = (pvup+pvdn-2*pvcarry)/(bump*price1_underlier)^2*price1_underlier/100;
pnl_delta = delta*(price2_underlier-price1_underlier);
pnl_gamma = 0.5*gamma*(price2_underlier-price1_underlier)^2/price1_underlier*100;
%
deltacarry = (pvup_-pvdn_)/(priceup_-pricedn_);
gammacarry = (pvup_+pvdn_-2*pvcarry_)/(bump*price2_underlier)^2*price2_underlier/100;

%vega
if strcmpi(code_bbg(20),'C')
    pvvolup = blkprice(fwd1_underlier,k,r,tau2,iv1+bump);
    pvvoldn = blkprice(fwd1_underlier,k,r,tau2,iv1-bump);
    pvvolup_ = blkprice(fwd2_underlier,k,r,tau3,iv2+bump);
    pvvoldn_ = blkprice(fwd2_underlier,k,r,tau3,iv2-bump);
else
    [~,pvvolup] = blkprice(fwd1_underlier,k,r,tau2,iv1+bump);
    [~,pvvoldn] = blkprice(fwd1_underlier,k,r,tau2,iv1-bump);
    [~,pvvolup_] = blkprice(fwd2_underlier,k,r,tau3,iv2+bump);
    [~,pvvoldn_] = blkprice(fwd2_underlier,k,r,tau3,iv2-bump);
end

vega = pvvolup - pvvoldn;
pnl_vega = vega*(iv2-iv1)/(2*bump);
vegacarry = pvvolup_ - pvvoldn_;
%
pnl = pv2_sec-pv1_sec;
pnl_explained = pnl_theta+pnl_delta+pnl_gamma+pnl_vega;
pnl_unexplained = pnl-pnl_explained;

output = struct('code',code_bbg,...
    'pnltotal',pnl*volume*mult,...
    'pnltheta',pnl_theta*volume*mult,...
    'pnldelta',pnl_delta*volume*mult,...
    'pnlgamma',pnl_gamma*volume*mult,...
    'pnlvega',pnl_vega*volume*mult,...
    'pnlunexplained',pnl_unexplained*volume*mult,...
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