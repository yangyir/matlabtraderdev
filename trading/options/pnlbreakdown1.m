function [output] = pnlbreakdown1(sec,cobdate,volume)
%function to break down the pnl attribution of the input option from the
%previous business date as of the input cobdate to cobdate
if nargin < 3, volume = 1; end

if ischar(sec)
    try
        sec = cOption(sec);
        sec.loadinfo([sec.code_ctp,'_info.txt']);
    catch e
        fprintf(['error:',e.message,'\n']);
        return
    end 
elseif isa(sec,'cFutures')
    predate = businessdate(cobdate,-1);
    mult = sec.contract_size;
    data = cDataFileIO.loadDataFromTxtFile([sec.code_ctp,'_daily.txt']);
    pv1_sec = data(data(:,1)==datenum(predate),end);
    pv2_sec = data(data(:,1)==datenum(cobdate),end);
    pnl = pv2_sec-pv1_sec;
    output = struct('pnltotal',pnl*volume*mult,...
    'pnltheta',0,...
    'pnldelta',pnl*volume*mult,...
    'pnlgamma',0,...
    'pnlvega',0,...
    'pnlunexplained',0,...
    'date1',datestr(predate,'yyyy-mm-dd'),...
    'date2',datestr(cobdate,'yyyy-mm-dd'),...
    'iv1',NaN,...
    'iv2',NaN,...
    'spot1',pv1_sec,...
    'spot2',pv2_sec,...
    'premium1',pv1_sec,...
    'premium2',pv2_sec,...
    'volume',volume);
    return
elseif isa(sec,'cOption')
    %donothing
else
    error('opt_pnlbreakdown:invalid option input')
end

%%
underlier = sec.code_ctp_underlier;
mult = sec.contract_size; 
data = cDataFileIO.loadDataFromTxtFile([underlier,'_daily.txt']);
predate = businessdate(cobdate,-1);
price1_underlier = data(data(:,1)==datenum(predate),end);
price2_underlier = data(data(:,1)==datenum(cobdate),end);
if isempty(price1_underlier) || isempty(price2_underlier)
    error(['underlier ',underlier,' historical price not saved!'])
end

data = cDataFileIO.loadDataFromTxtFile([sec.code_ctp,'_daily.txt']);
pv1_sec = data(data(:,1)==datenum(predate),end);
pv2_sec = data(data(:,1)==datenum(cobdate),end);
if isempty(pv1_sec) || isempty(pv2_sec)
    error(['underlier ',underlier,' historical price not saved!'])
end

%%
k = sec.opt_strike;
optclass = 'call';
if strcmpi(sec.opt_type,'P'), optclass = 'put'; end
tau1 = (sec.opt_expiry_date1 - datenum(predate))/365;
tau2 = (sec.opt_expiry_date1 - datenum(cobdate))/365;
r = 0.035;
if sec.opt_american
    iv1 = bjsimpv(price1_underlier,k,r,datenum(predate),sec.opt_expiry_date1,pv1_sec,[],r,[],optclass);
    iv2 = bjsimpv(price2_underlier,k,r,datenum(cobdate),sec.opt_expiry_date2,pv2_sec,[],r,[],optclass);
else
    iv1 = blkimpv(price1_underlier,k,r,tau1,pv1_sec,[],[],{optclass});
    iv2 = blkimpv(price2_underlier,k,r,tau2,pv2_sec,[],[],{optclass});
end

%pvcarry
if sec.opt_american
    if strcmpi(sec.opt_type,'C')
        pvcarry = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
    else
        [~,pvcarry] = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
    end
else
    if strcmpi(sec.opt_type,'C')
        pvcarry = blkprice(price1_underlier,k,r,tau2,iv1);
    else
        [~,pvcarry] = blkprice(price1_underlier,k,r,tau2,iv1);
    end
end
pnl_theta = pvcarry - pv1_sec;

%delta/gamma carry
bump = 0.005;
priceup = price1_underlier*(1+bump);
pricedn = price1_underlier*(1-bump);
if sec.opt_american
    if strcmpi(sec.opt_type,'C')
        pvup = bjsprice(priceup,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
        pvdn = bjsprice(pricedn,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
    else
        [~,pvup] = bjsprice(priceup,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
        [~,pvdn] = bjsprice(pricedn,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
    end
else
    if strcmpi(sec.opt_type,'C')
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
if sec.opt_american
    if strcmpi(sec.opt_type,'C')
        pvvolup = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1+bump,r);
        pvvoldn = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1-bump,r);
    else
        [~,pvvolup] = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1+bump,r);
        [~,pvvoldn] = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1-bump,r);
    end
else
    if strcmpi(sec.opt_type,'C')
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
pnl = pv2_sec-pv1_sec;
pnl_explained = pnl_theta+pnl_delta+pnl_gamma+pnl_vega;
pnl_unexplained = pnl-pnl_explained;

output = struct('pnltotal',pnl*volume*mult,...
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
    'premium1',pv1_sec,...
    'premium2',pv2_sec,...
    'volume',volume);
    
end