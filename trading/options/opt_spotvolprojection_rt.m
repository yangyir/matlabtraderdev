function [] = opt_spotvolprojection_rt(port,pos,mdeopt,spotsladder,volshifts)
    spotsladder = 5150:50:5650;
    volshifts = [0];
    
    nspots = length(spotsladder);
    nvols = length(volshifts);
    
    underlier = mdeopt.underliers_.getinstrument{1};
    spot = mdeopt.qms_.getquote(underlier).last_trade;
    hh = hour(mdeopt.qms_.getquote(underlier).update_time1);
    if hh >= 9 && hh <= 15
        valdate = mdeopt.qms_.getquote(underlier).update_date1;
    else
        valdate = businessdate(mdeopt.qms_.getquote(underlier).update_date1,1);
    end
    ivbase = zeros(size(port,1),1);
    for i = 1:size(port,1)
        ivbase(i) = mdeopt.qms_.getquote(port{i}).impvol;
    end
    res = mdeopt.getportfoliogreeks(port,pos);
    premium = res.premium;
           
    pvmat = zeros(nspots,nvols);
    deltamat = zeros(nspots,nvols);
    gammamat = zeros(nspots,nvols);
    thetamat = zeros(nspots,nvols);
    vegamat = zeros(nspots,nvols);
    
    for ispots = 1:nspots
        s = spotsladder(ispots);
        for ivol = 1:nvols
            iv_ = ivbase + volshifts(ivol)/100;
            for iport = 1:length(port)
                [ pv,theta,deltacarry,gammacarry,vegacarry ] = opt_val( port{iport},valdate,s,iv_(iport));
                pvmat(ispots,ivol) = pvmat(ispots,ivol) + pv*pos(iport);
                thetamat(ispots,ivol) = thetamat(ispots,ivol) + theta*pos(iport);
                deltamat(ispots,ivol) = deltamat(ispots,ivol) + deltacarry*pos(iport);
                gammamat(ispots,ivol) = gammamat(ispots,ivol) + gammacarry*pos(iport);
                vegamat(ispots,ivol) = vegamat(ispots,ivol) + vegacarry*pos(iport);
            end            
        end
    end
    
    %plot
    subplot(221)
    plot(spotsladder,pvmat-premium);title('pnl')
    %
    subplot(222)
    plot(spotsladder,deltamat);
    %
    subplot(223);
    plot(spotsladder,gammamat);
    %
    subplot(224);
    plot(spotsladder,vegamat);
    
    
    
    
end