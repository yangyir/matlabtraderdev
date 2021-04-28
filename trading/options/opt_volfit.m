function params = opt_volfit(code_underlier,cobdate,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('pivmodel','ny4',@ischar);
    p.addParameter('weights','none',@ischar);
    p.addParameter('initialguess',[],@isnumeric);
    p.parse(varargin{:});
    pivmodel = p.Results.pivmodel;
    if ~strcmpi(pivmodel,'ny4')
        error('opt_volfit:invalid pivmodel input');
    end
    weights = p.Results.weights;
    if ~(strcmpi(weights,'none') || strcmpi(weights,'vega'))
        error('opt_volfit:invalid weights input');
    end
    initialguess = p.Results.initialguess;
    
    hd_underlier = cDataFileIO.loadDataFromTxtFile([code_underlier,'_daily.txt']);
    if ischar(cobdate),cobdate = datenum(cobdate);end
    spot = hd_underlier(hd_underlier(:,1) == cobdate,5);
    if strcmpi(code_underlier(1:2),'SR')
        bucketsize = 100;
    elseif strcmpi(code_underlier(1:2),'CF')
        bucketsize = 200;
    elseif strcmpi(code_underlier(1:2),'cu')
        bucketsize = 1000;
    elseif strcmpi(code_underlier(1:2),'ru')
        bucketsize = 250;
    elseif strcmpi(code_underlier(1),'m')
        bucketsize = 50;
    elseif strcmpi(code_underlier(1:2),'IF')
        bucketsize = 50;
    elseif strcmpi(code_underlier(1:2),'au')
        bucketsize = 4;
    else
        bucketsize = 20;
    end
    
    k_dn = floor(spot/bucketsize)*bucketsize;
    k_up = ceil(spot/bucketsize)*bucketsize;
    if strcmpi(code_underlier(1:2),'SR') || strcmpi(code_underlier(1:2),'CF')
        interstrc = 'C';
        interstrp = 'P';
    elseif strcmpi(code_underlier(1:2),'cu') || strcmpi(code_underlier(1:2),'ru') ...
            || strcmpi(code_underlier(1:2),'au')
        interstrc = 'C';
        interstrp = 'P';
    else
        interstrc = '-C-';
        interstrp = '-P-';
    end
    if strcmpi(code_underlier(1:2),'IF')
        optcode = ['IO',code_underlier(3:end),interstrc,num2str(k_dn)];
    else
        optcode = [code_underlier,interstrc,num2str(k_dn)];
    end
    optinstr = code2instrument(optcode);
    optexpiry = optinstr.opt_expiry_date1;
    calendar_tau = (optexpiry-cobdate)/365;
    
    strikes = k_dn-5*bucketsize:bucketsize:k_up+5*bucketsize;
    nstrikes = length(strikes);
    vols = zeros(nstrikes,1);
    m = log(strikes./spot)/sqrt(calendar_tau);m=m';
   
        
    for i = 1:nstrikes
        if strcmpi(code_underlier(1:2),'IF')
            ci = ['IO',code_underlier(3:end),interstrc,num2str(strikes(i))];
        else
            ci = [code_underlier,interstrc,num2str(strikes(i))];
        end
        dataci = cDataFileIO.loadDataFromTxtFile([ci,'_daily.txt']);
        premiumci = dataci(dataci(:,1)==cobdate,5);
        %
        if strcmpi(code_underlier(1:2),'IF')
            pi = ['IO',code_underlier(3:end),interstrp,num2str(strikes(i))];
        else
            pi = [code_underlier,interstrp,num2str(strikes(i))];
        end
        datapi = cDataFileIO.loadDataFromTxtFile([pi,'_daily.txt']);
        premiumpi = datapi(datapi(:,1)==cobdate,5);

        fwdi = premiumci-premiumpi+strikes(i);
        if ~isnan(fwdi)
            if strikes(i) < spot
                vols(i) = bjsimpv(fwdi,strikes(i),0.035,cobdate,optexpiry,premiumpi,[],0.035,[],'put');
            else
                vols(i) = bjsimpv(fwdi,strikes(i),0.035,cobdate,optexpiry,premiumci,[],0.035,[],'call');
            end
        else
            if isnan(premiumci)
                vols(i) = bjsimpv(spot,strikes(i),0.035,cobdate,optexpiry,premiumpi,[],0.035,[],'put');
            else
                vols(i) = bjsimpv(spot,strikes(i),0.035,cobdate,optexpiry,premiumci,[],0.035,[],'call');
            end
        end
    end
    %
    % compute atm vol
    i_dn = find(strikes==k_dn);i_up = i_dn+1;
    vol_atm = vols(i_up)-(vols(i_up)-vols(i_dn))/(m(i_up)-m(i_dn))*m(i_up);
    
    if strcmpi(weights,'vega')
        % vega weighted
        vega = zeros(nstrikes,1);
        for i = 1:nstrikes
            vega(i) = blsvega(spot,strikes(i),0.035,calendar_tau,vols(i),0.035);
        end
        weights = vega/sum(vega);
    else
        weights = ones(nstrikes,1);
    end
    
    m = m/vol_atm;
    
    if isempty(initialguess)
        quadraticfit = fit(m,vols/vol_atm,'poly2');
        coeffs = coeffvalues(quadraticfit);
    else
        coeffs = initialguess(2:end);
    end
    [params, ~] = opt_piv_ny4fit(m, vols/vol_atm,weights,[coeffs(2),coeffs(1),1]);
    %
    %
    skew = params(1);
    smile = params(2);
    power = params(3);
    mplot = m(1)-0.02:0.02:m(end)+0.02;
    volfitted = (1 + skew .* mplot + smile.*mplot.^2).^power;
    plot(m,vols,'*');hold on;
    plot(mplot,volfitted.*vol_atm,'r');hold off;
    title(code_underlier);xlabel('moneyness');ylabel('implied vol');
    params = [vol_atm,params];
end
