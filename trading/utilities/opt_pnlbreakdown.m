function [output] = opt_pnlbreakdown(opt,cobdate)
%function to break down the pnl attribution of the input option from the
%previous business date as of the input cobdate to cobdate
if ischar(opt)
    try
        opt = cOption(opt);
        opt.loadinfo([opt.code_ctp,'_info.txt']);
    catch e
        fprintf(['error:',e.message,'\n']);
        return
    end 
elseif ~isa(opt,'cOption')
    error('opt_pnlbreakdown:invalid option input')
end

%%
underlier = opt.code_ctp_underlier;
data = cDataFileIO.loadDataFromTxtFile([underlier,'_daily.txt']);
predate = businessdate(cobdate,-1);
price1_underlier = data(data(:,1)==datenum(predate),end);
price2_underlier = data(data(:,1)==datenum(cobdate),end);
if isempty(price1_underlier) || isempty(price2_underlier)
    error(['underlier ',underlier,' historical price not saved!'])
end

data = cDataFileIO.loadDataFromTxtFile([opt.code_ctp,'_daily.txt']);
pv1_opt = data(data(:,1)==datenum(predate),end);
pv2_opt = data(data(:,1)==datenum(cobdate),end);
if isempty(pv1_opt) || isempty(pv2_opt)
    error(['underlier ',underlier,' historical price not saved!'])
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
    iv2 = bjsimpv(price2_underlier,k,r,datenum(cobdate),opt.opt_expiry_date2,pv2_opt,[],r,[],optclass);
else
    iv1 = blkimpv(price1_underlier,k,r,tau1,pv1_opt,[],[],{optclass});
    iv2 = blkimpv(price2_underlier,k,r,tau2,pv2_opt,[],[],{optclass});
end

%pvcarry
if opt.opt_american
    pvcarry = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
else
    pvcarry = blkprice(price1_underlier,k,r,tau2,iv1);
end
pnl_theta = pvcarry - pv1_opt;

%delta/gamma carry
bump = 0.005;
priceup = price1_underlier*(1+bump);
pricedn = price1_underlier*(1-bump);
if opt.opt_american
    pvup = bjsprice(priceup,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
    pvdn = bjsprice(pricedn,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1,r);
else
    pvup = blkprice(priceup,k,r,tau2,iv1);
    pvdn = blkprice(pricedn,k,r,tau2,iv1);
end
delta = (pvup-pvdn)/(priceup-pricedn);
gamma = (pvup+pvdn-2*pvcarry)/(bump*price1_underlier)^2*price1_underlier/100;
pnl_delta = delta*(price2_underlier-price1_underlier);
pnl_gamma = 0.5*gamma*(price2_underlier-price1_underlier)^2/price1_underlier*100;

%vega
if opt.opt_american
    pvvolup = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1+bump,r);
    pvvoldn = bjsprice(price1_underlier,k,r,datenum(cobdate),opt.opt_expiry_date1,iv1-bump,r);
else
    pvvolup = blkprice(price1_underlier,k,r,tau2,iv1+bump);
    pvvoldn = blkprice(price1_underlier,k,r,tau2,iv1-bump);
end
vega = pvvolup - pvvoldn;
pnl_vega = vega*(iv2-iv1)/(2*bump);
%
pnl = pv2_opt-pv1_opt;
pnl_explained = pnl_theta+pnl_delta+pnl_gamma+pnl_vega;
pnl_unexplained = pnl-pnl_explained;

output = struct('pnltotal',pnl,...
    'pnltheta',pnl_theta,...
    'pnldelta',pnl_delta,...
    'pnlgamma',pnl_gamma,...
    'pnlvega',pnl_vega,...
    'pnlunexplained',pnl_unexplained,...
    'date1',datestr(predate,'yyyy-mm-dd'),...
    'date2',datestr(cobdate,'yyyy-mm-dd'),...
    'iv1',iv1,...
    'iv2',iv2,...
    'spot1',price1_underlier,...
    'spot2',price2_underlier,...
    'premium1',pv1_opt,...
    'premium2',pv2_opt);
    




    


end