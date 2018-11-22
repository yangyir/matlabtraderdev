function [] = plotvolslice(mdeopt,code_ctp_underlier,numstrikes,varargin)
%cMDEOpt
    [calls,puts] = getlistedoptions(code_ctp_underlier,numstrikes);
    strikes = zeros(numstrikes,1);
    ivcalls = zeros(numstrikes,1);
    ivputs = zeros(numstrikes,1);
    ivcallscarry = zeros(numstrikes,1);
    ivputscarry = zeros(numstrikes,1);
    for i = 1:numstrikes
        strikes(i) = calls{i}.opt_strike;
        greeksc_i = mdeopt.getgreeks(calls{i});
        ivcalls(i) = greeksc_i.impvol;
        ivcallscarry(i) = greeksc_i.impvolcarryyesterday;
        %
        greeksp_i = mdeopt.getgreeks(puts{i});
        ivputs(i) = greeksp_i.impvol;
        ivputscarry(i) = greeksp_i.impvolcarryyesterday;
    end
    figure(1);
    subplot(121);plot(strikes,ivcalls,'b-*');
    hold on;plot(strikes,ivcallscarry,'r-o');legend('iv-call','ivcarry-call');hold off;
    title('iv calls');grid on;
    %
    subplot(122);plot(strikes,ivputs,'b*-');
    hold on;plot(strikes,ivputscarry,'r-o');legend('iv-put','ivcarry-put');hold off;
    title('iv puts');grid on;
end