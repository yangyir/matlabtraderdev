function [ pv,theta,deltacarry,gammacarry,vegacarry ] = opt_val( opt,valdate,s,iv)
if ischar(opt), opt = code2instrument(opt);end
k = opt.opt_strike;
tau1 = (opt.opt_expiry_date1 - datenum(valdate))/365;
nextdate = businessdate(valdate,1);
tau2 = (opt.opt_expiry_date1 - datenum(nextdate))/365;
r = 0.035;
mult = opt.contract_size; 
%pvcarry
if opt.opt_american
    if strcmpi(opt.opt_type,'C')
        pv = bjsprice(s,k,r,datenum(valdate),opt.opt_expiry_date1,iv,r);
        pvcarry = bjsprice(s,k,r,datenum(nextdate),opt.opt_expiry_date1,iv,r);
    else
        [~,pv] = bjsprice(s,k,r,datenum(valdate),opt.opt_expiry_date1,iv,r);
        [~,pvcarry] = bjsprice(s,k,r,datenum(nextdate),opt.opt_expiry_date1,iv,r);
    end
else
    if strcmpi(opt.opt_type,'C')
        pv = blkprice(s,k,r,tau1,iv);
        pvcarry = blkprice(s,k,r,tau2,iv);
    else
        [~,pv] = blkprice(s,k,r,tau1,iv);
        [~,pvcarry] = blkprice(s,k,r,tau2,iv);
    end
end
theta = (pvcarry - pv)*mult;

%delta/gamma carry
bump = 0.005;
priceup = s*(1+bump);
pricedn = s*(1-bump);
if opt.opt_american
    if strcmpi(opt.opt_type,'C')
        pvup = bjsprice(priceup,k,r,datenum(nextdate),opt.opt_expiry_date1,iv,r);
        pvdn = bjsprice(pricedn,k,r,datenum(nextdate),opt.opt_expiry_date1,iv,r);
    else
        [~,pvup] = bjsprice(priceup,k,r,datenum(nextdate),opt.opt_expiry_date1,iv,r);
        [~,pvdn] = bjsprice(pricedn,k,r,datenum(nextdate),opt.opt_expiry_date1,iv,r);
    end
else
    if strcmpi(opt.opt_type,'C')
        pvup = blkprice(priceup,k,r,tau2,iv);
        pvdn = blkprice(pricedn,k,r,tau2,iv);
    else
        [~,pvup] = blkprice(priceup,k,r,tau2,iv);
        [~,pvdn] = blkprice(pricedn,k,r,tau2,iv);
    end
end
deltacarry = (pvup-pvdn)/(priceup-pricedn)*mult*s;
gammacarry = (pvup+pvdn-2*pvcarry)/(bump*s)^2*s/100*mult*s;

%vega
if opt.opt_american
    if strcmpi(opt.opt_type,'C')
        pvvolup = bjsprice(s,k,r,datenum(nextdate),opt.opt_expiry_date1,iv+bump,r);
        pvvoldn = bjsprice(s,k,r,datenum(nextdate),opt.opt_expiry_date1,iv-bump,r);
    else
        [~,pvvolup] = bjsprice(s,k,r,datenum(nextdate),opt.opt_expiry_date1,iv+bump,r);
        [~,pvvoldn] = bjsprice(s,k,r,datenum(nextdate),opt.opt_expiry_date1,iv-bump,r);
    end
else
    if strcmpi(opt.opt_type,'C')
        pvvolup = blkprice(s,k,r,tau2,iv+bump);
        pvvoldn = blkprice(s,k,r,tau2,iv-bump);
    else
        [~,pvvolup] = blkprice(s,k,r,tau2,iv+bump);
        [~,pvvoldn] = blkprice(s,k,r,tau2,iv-bump);
    end
end
vegacarry = (pvvolup - pvvoldn)*mult;
pv = pv*mult;
end

