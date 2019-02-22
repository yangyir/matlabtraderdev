function [output] = pnlriskbreakdown1(sec,cobdate,volume)
%function to break down the pnl attribution of the input option from the
%previous business date as of the input cobdate to cobdate
%i.e.pnl and risk day to day
if nargin < 3, volume = 1; end

if ischar(sec)
    flag = isoptchar(sec);
    if ~flag
        try
            sec = cFutures(sec);
            sec.loadinfo([sec.code_ctp,'_info.txt']);
        catch e
            fprintf(['error:',e.message,'\n']);
            return
        end
    else
        try
            sec = cOption(sec);
            sec.loadinfo([sec.code_ctp,'_info.txt']);
        catch e
            fprintf(['error:',e.message,'\n']);
            return
        end
    end
end

if isa(sec,'cFutures')
    predate = businessdate(cobdate,-1);
    mult = sec.contract_size;
    if ~isempty(strfind(sec.code_bbg,'TFC')) || ~isempty(strfind(sec.code_bbg,'TFT'))
        mult = mult/100;
    end
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
underlier = sec.code_ctp_underlier;
mult = sec.contract_size; 
data = cDataFileIO.loadDataFromTxtFile([underlier,'_daily.txt']);
predate = businessdate(cobdate,-1);
nextdate = businessdate(cobdate,1);
price1_underlier = data(data(:,1)==datenum(predate),5);
price2_underlier = data(data(:,1)==datenum(cobdate),5);
if isempty(price1_underlier) || isempty(price2_underlier)
    error(['underlier ',underlier,' historical price not saved!'])
end

data = cDataFileIO.loadDataFromTxtFile([sec.code_ctp,'_daily.txt']);
pv1_sec = data(data(:,1)==datenum(predate),5);
pv2_sec = data(data(:,1)==datenum(cobdate),5);
if isempty(pv1_sec) || isempty(pv2_sec)
    error(['option ',sec.code_ctp,' historical price not saved!'])
end

%%
k = sec.opt_strike;
optclass = 'call';
if strcmpi(sec.opt_type,'P'), optclass = 'put'; end
tau1 = (sec.opt_expiry_date1 - datenum(predate))/365;
tau2 = (sec.opt_expiry_date1 - datenum(cobdate))/365;
tau3 = (sec.opt_expiry_date1 - datenum(nextdate))/365;
r = 0.035;
if sec.opt_american
    iv1 = bjsimpv(price1_underlier,k,r,datenum(predate),sec.opt_expiry_date1,pv1_sec,[],r,[],optclass);
    iv2 = bjsimpv(price2_underlier,k,r,datenum(cobdate),sec.opt_expiry_date2,pv2_sec,[],r,[],optclass);
else
    iv1 = blkimpv(price1_underlier,k,r,tau1,pv1_sec,[],[],{optclass});
    iv2 = blkimpv(price2_underlier,k,r,tau2,pv2_sec,[],[],{optclass});
end

%pvcarry: from previous business date
%pvcarry_:to next business date
if sec.opt_american
    if strcmpi(sec.opt_type,'C')
        pvcarry = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
        pvcarry_ = bjsprice(price2_underlier,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2,r);
        
    else
        [~,pvcarry] = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
        [~,pvcarry_] = bjsprice(price2_underlier,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2,r);
    end
else
    if strcmpi(sec.opt_type,'C')
        pvcarry = blkprice(price1_underlier,k,r,tau2,iv1);
        pvcarry_ = blkprice(price2_underlier,k,r,tau3,iv2);
    else
        [~,pvcarry] = blkprice(price1_underlier,k,r,tau2,iv1);
        [~,pvcarry_] = blkprice(price2_underlier,k,r,tau3,iv2);
    end
end
pnl_theta = pvcarry - pv1_sec;
thetacarry = pvcarry_ - pv2_sec;

%delta/gamma carry
bump = 0.005;
priceup = price1_underlier*(1+bump);
pricedn = price1_underlier*(1-bump);
priceup_ = price2_underlier*(1+bump);
pricedn_ = price2_underlier*(1-bump);
if sec.opt_american
    if strcmpi(sec.opt_type,'C')
        pvup = bjsprice(priceup,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
        pvdn = bjsprice(pricedn,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
        pvup_ = bjsprice(priceup_,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2,r);
        pvdn_ = bjsprice(pricedn_,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2,r);
    else
        [~,pvup] = bjsprice(priceup,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
        [~,pvdn] = bjsprice(pricedn,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1,r);
        [~,pvup_] = bjsprice(priceup_,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2,r);
        [~,pvdn_] = bjsprice(pricedn_,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2,r);
    end
else
    if strcmpi(sec.opt_type,'C')
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
end
delta = (pvup-pvdn)/(priceup-pricedn);
gamma = (pvup+pvdn-2*pvcarry)/(bump*price1_underlier)^2*price1_underlier/100;
pnl_delta = delta*(price2_underlier-price1_underlier);
pnl_gamma = 0.5*gamma*(price2_underlier-price1_underlier)^2/price1_underlier*100;
%
deltacarry = (pvup_-pvdn_)/(priceup_-pricedn_);
gammacarry = (pvup_+pvdn_-2*pvcarry_)/(bump*price2_underlier)^2*price2_underlier/100;

%vega
if sec.opt_american
    if strcmpi(sec.opt_type,'C')
        pvvolup = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1+bump,r);
        pvvoldn = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1-bump,r);
        pvvolup_ = bjsprice(price2_underlier,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2+bump,r);
        pvvoldn_ = bjsprice(price2_underlier,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2-bump,r);
    else
        [~,pvvolup] = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1+bump,r);
        [~,pvvoldn] = bjsprice(price1_underlier,k,r,datenum(cobdate),sec.opt_expiry_date1,iv1-bump,r);
        [~,pvvolup_] = bjsprice(price2_underlier,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2+bump,r);
        [~,pvvoldn_] = bjsprice(price2_underlier,k,r,datenum(nextdate),sec.opt_expiry_date1,iv2-bump,r);
    end
else
    if strcmpi(sec.opt_type,'C')
        pvvolup = blkprice(price1_underlier,k,r,tau2,iv1+bump);
        pvvoldn = blkprice(price1_underlier,k,r,tau2,iv1-bump);
        pvvolup_ = blkprice(price2_underlier,k,r,tau3,iv2+bump);
        pvvoldn_ = blkprice(price2_underlier,k,r,tau3,iv2-bump);
    else
        [~,pvvolup] = blkprice(price1_underlier,k,r,tau2,iv1+bump);
        [~,pvvoldn] = blkprice(price1_underlier,k,r,tau2,iv1-bump);
        [~,pvvolup_] = blkprice(price2_underlier,k,r,tau3,iv2+bump);
        [~,pvvoldn_] = blkprice(price2_underlier,k,r,tau3,iv2-bump);
    end
end
vega = pvvolup - pvvoldn;
pnl_vega = vega*(iv2-iv1)/(2*bump);
vegacarry = pvvolup_ - pvvoldn_;
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
    'premium1',pv1_sec*volume*mult,...
    'premium2',pv2_sec*volume*mult,...
    'volume',volume,...
    'deltacarry',deltacarry*volume*mult*price2_underlier,...
    'gammacarry',gammacarry*volume*mult*price2_underlier,...
    'thetacarry',thetacarry*volume*mult,...
    'vegacarry',vegacarry*volume*mult);
    
end