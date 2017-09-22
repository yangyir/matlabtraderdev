function output = opt_eodinfo(opt,cobdate)
    if ~isa(opt,'cOption')
        error('opt_eodinfo:invalid option input')
    end
    
    code_ctp_opt = opt.code_ctp;
    code_ctp_underlier = opt.code_ctp_underlier;
    
    fn_opt = [code_ctp_opt,'_daily.txt'];
    fn_underlier = [code_ctp_underlier,'_daily.txt'];
    
    data_opt = cDataFileIO.loadDataFromTxtFile(fn_opt);
    data_underlier = cDataFileIO.loadDataFromTxtFile(fn_underlier);
    
    pv = data_opt(data_opt(:,1) == datenum(cobdate),5);
    price = data_underlier(data_underlier(:,1) == datenum(cobdate),5);
    
    r = 0.035;
    k = opt.opt_strike;
    optclass = 'call';
    if strcmpi(opt.opt_type,'P'), optclass = 'put'; end
    
    if opt.opt_american
        iv = bjsimpv(price,k,r,datenum(cobdate),opt.opt_expiry_date1,pv,[],r,[],optclass);
    else
        tau = (sec.opt_expiry_date1 - datenum(cobdate))/365;
        iv = blkimpv(price,k,r,tau,pv,[],[],{optclass});
    end
    
    carrydate = datenum(businessdate(cobdate,1));
    %pvcarry
    if opt.opt_american
        if strcmpi(opt.opt_type,'C')
            pvcarry = bjsprice(price,k,r,carrydate,opt.opt_expiry_date1,iv,r);
        else
            [~,pvcarry] = bjsprice(price,k,r,carrydate,opt.opt_expiry_date1,iv,r);
        end
    else
        taucarry = (sec.opt_expiry_date1 - carrydate)/365;
        if strcmpi(sec.opt_type,'C')
            pvcarry = blkprice(price,k,r,taucarry,iv);
        else
            [~,pvcarry] = blkprice(price,k,r,taucarry,iv);
        end
    end
    
    theta = pvcarry - pv;
    
    %delta/gamma
    bump = 0.005;
    priceup = price*(1+bump);
    pricedn = price*(1-bump);
    if opt.opt_american
        if strcmpi(opt.opt_type,'C')
            pvup = bjsprice(priceup,k,r,carrydate,opt.opt_expiry_date1,iv,r);
            pvdn = bjsprice(pricedn,k,r,carrydate,opt.opt_expiry_date1,iv,r);
        else
            [~,pvup] = bjsprice(priceup,k,r,carrydate,opt.opt_expiry_date1,iv,r);
            [~,pvdn] = bjsprice(pricedn,k,r,carrydate,opt.opt_expiry_date1,iv,r);
        end
    else
        if strcmpi(opt.opt_type,'C')
            pvup = blkprice(priceup,k,r,taucarry,iv);
            pvdn = blkprice(pricedn,k,r,taucarry,iv);
        else
            [~,pvup] = blkprice(priceup,k,r,taucarry,iv);
            [~,pvdn] = blkprice(pricedn,k,r,taucarry,iv);
        end
    end
    delta = (pvup-pvdn)/(priceup-pricedn);
    gamma = (pvup+pvdn-2*pvcarry)/(bump*price)^2*price/100;
    
    %vega
    if opt.opt_american
        if strcmpi(opt.opt_type,'C')
            pvvolup = bjsprice(price,k,r,carrydate,opt.opt_expiry_date1,iv+bump,r);
            pvvoldn = bjsprice(price,k,r,carrydate,opt.opt_expiry_date1,iv-bump,r);
        else
            [~,pvvolup] = bjsprice(price,k,r,carrydate,opt.opt_expiry_date1,iv+bump,r);
            [~,pvvoldn] = bjsprice(price,k,r,carrydate,opt.opt_expiry_date1,iv-bump,r);
        end
    else
        if strcmpi(opt.opt_type,'C')
            pvvolup = blkprice(price,k,r,taucarry,iv+bump);
            pvvoldn = blkprice(price,k,r,taucarry,iv-bump);
        else
            [~,pvvolup] = blkprice(price,k,r,taucarry,iv+bump);
            [~,pvvoldn] = blkprice(price,k,r,taucarry,iv-bump);
        end
    end
    vega = pvvolup - pvvoldn;
    
    output = struct('code',opt.code_ctp,...
        'date',datestr(cobdate,'yyyy-mm-dd'),...
        'price',price,...
        'pv',pv,...    
        'iv',iv,...
        'theta',theta,...
        'delta',delta,...
        'gamma',gamma,...
        'vega',vega);
    
    
    
    
end