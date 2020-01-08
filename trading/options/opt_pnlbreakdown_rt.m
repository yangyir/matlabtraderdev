function [output] = opt_pnlbreakdown_rt(opt,quotes,volume)
%function to break down the pnl attribution of the input option from the
%previous business date as of the input cobdate to cobdate
if nargin < 3, volume = 1; end

if ischar(opt)
    try
        opt = code2instrument(opt);
%         opt = cOption(opt);
%         opt.loadinfo([opt.code_ctp,'_info.txt']);
    catch e
        fprintf(['error:',e.message,'\n']);
        return
    end 
elseif ~isa(opt,'cOption')
    error('opt_pnlbreakdown:invalid option input')
end

%%
idx = 0;
for i = 1:size(quotes,1)
    if strcmpi(opt.code_ctp,quotes{i}.code_ctp)
        idx = i;
        break
    end
end
try
    q = quotes{idx};
catch e
    error(e.message)
end

if isa(opt,'cFutures')
    predate = getlastbusinessdate;
    cobdate = businessdate(predate,1);
    mult = opt.contract_size;
    if ~isempty(strfind(opt.code_bbg,'TFC')) || ~isempty(strfind(opt.code_bbg,'TFT'))
        mult = mult/100;
    end
    data = cDataFileIO.loadDataFromTxtFile([opt.code_ctp,'_daily.txt']);
    pv1_sec = data(data(:,1)==datenum(predate),5);
    if volume > 0
        pv2_sec = q.bid1;
        pnl = q.bid1-pv1_sec;
    else
        pv2_sec = q.ask1;
        pnl = q.ask1-pv1_sec;
    end
    output = struct('pnltotal',pnl*volume*mult,...
    'pnltheta',0,...
    'pnldelta',pnl*volume*mult,...
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
    'deltacarry',pv2_sec*volume*mult,...
    'gammacarry',0,...
    'thetacarry',0,...
    'vegacarry',0);
    return
end


%%
underlier = opt.code_ctp_underlier;
mult = opt.contract_size; 
data = cDataFileIO.loadDataFromTxtFile([underlier,'_daily.txt']);

predate = getlastbusinessdate;
cobdate = businessdate(predate,1);

price1_underlier = data(data(:,1)==datenum(predate),5);
if isempty(price1_underlier)
    error(['underlier ',underlier,' historical price not saved!'])
end
price2_underlier = q.last_trade_underlier;

data = cDataFileIO.loadDataFromTxtFile([opt.code_ctp,'_daily.txt']);
pv1_opt = data(data(:,1)==datenum(predate),5);
if isempty(pv1_opt)
    error(['underlier ',underlier,' historical price not saved!'])
end
% pv2_opt = q.last_trade;
if (q.ask1-q.bid1)/q.last_trade < 0.05
    pv2_opt = 0.5*(q.bid1+q.ask1);
else
    pv2_opt = q.last_trade;
end

%%
k = opt.opt_strike;
optclass = 'call';
if strcmpi(opt.opt_type,'P'), optclass = 'put'; end
tau1 = (opt.opt_expiry_date1 - datenum(predate))/365;
tau2 = (opt.opt_expiry_date1 - datenum(cobdate))/365;
r = 0.035;
if opt.opt_american
    iv1 = bjsimpv(price1_underlier,k,r,datenum(predate),opt.opt_expiry_date1,pv1_opt,[],r,[],optclass);
    if isnan(iv1), iv1 = 0.01;end
    iv2 = bjsimpv(price2_underlier,k,r,datenum(cobdate),opt.opt_expiry_date2,pv2_opt,[],r,[],optclass);
    if isnan(iv2), iv2 = 0.01;end
else
    iv1 = blkimpv(price1_underlier,k,r,tau1,pv1_opt,[],[],{optclass});
    if isnan(iv1), iv1 = 0.01;end
    iv2 = blkimpv(price2_underlier,k,r,tau2,pv2_opt,[],[],{optclass});
    if isnan(iv2), iv2 = 0.01;end
end

%pvcarry
if opt.opt_american
    if strcmpi(opt.opt_type,'C')
        pvcarry = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
    else
        [~,pvcarry] = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
    end
else
    if strcmpi(opt.opt_type,'C')
        pvcarry = blkprice(price1_underlier,k,r,tau2,iv1);
    else
        [~,pvcarry] = blkprice(price1_underlier,k,r,tau2,iv1);
    end
end
pnl_theta = pvcarry - pv1_opt;

%delta/gamma carry
bump = 0.005;
priceup = price1_underlier*(1+bump);
pricedn = price1_underlier*(1-bump);
if opt.opt_american
    if strcmpi(opt.opt_type,'C')
        pvup = bjsprice(priceup,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
        pvdn = bjsprice(pricedn,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
    else
        [~,pvup] = bjsprice(priceup,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
        [~,pvdn] = bjsprice(pricedn,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
    end
else
    if strcmpi(opt.opt_type,'C')
        pvup = blkprice(priceup,k,r,tau2,iv1);
        pvdn = blkprice(pricedn,k,r,tau2,iv1);
    else
        [~,pvup] = blkprice(priceup,k,r,tau2,iv1);
        [~,pvdn] = blkprice(pricedn,k,r,tau2,iv1);
    end
end
delta = (pvup-pvdn)/(priceup-pricedn);
gamma = (pvup+pvdn-2*pvcarry)/(bump*price1_underlier)^2*price1_underlier/100;
pnl_delta = delta*(price2_underlier-price1_underlier);
pnl_gamma = 0.5*gamma*(price2_underlier-price1_underlier)^2/price1_underlier*100;

%vega
if opt.opt_american
    if strcmpi(opt.opt_type,'C')
        pvvolup = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1+bump,r);
        pvvoldn = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1-bump,r);
    else
        [~,pvvolup] = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1+bump,r);
        [~,pvvoldn] = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1-bump,r);
    end
else
    if strcmpi(opt.opt_type,'C')
        pvvolup = blkprice(price1_underlier,k,r,tau2,iv1+bump);
        pvvoldn = blkprice(price1_underlier,k,r,tau2,iv1-bump);
    else
        [~,pvvolup] = blkprice(price1_underlier,k,r,tau2,iv1+bump);
        [~,pvvoldn] = blkprice(price1_underlier,k,r,tau2,iv1-bump);
    end
end
vega = pvvolup - pvvoldn;
pnl_vega = vega*(iv2-iv1)/(2*bump);
%
pnl = pv2_opt-pv1_opt;
pnl_explained = pnl_theta+pnl_delta+pnl_gamma+pnl_vega;
pnl_unexplained = pnl-pnl_explained;

output = struct('code',opt.code_ctp,...
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
    'premium1',pv1_opt,...
    'premium2',pv2_opt);
    
end