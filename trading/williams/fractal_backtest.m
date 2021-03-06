function [pnl] = fractal_backtest(p,nfractal,varargin)
    ip = inputParser;
    ip.CaseSensitive = false;ip.KeepUnmatched = true;
    ip.addParameter('code','',@ischar);
    ip.addParameter('freq','1d',@ischar);
    ip.addParameter('volatilityperiod',13,@isnumeric);
    ip.addParameter('debug',false,@islogical);
    ip.parse(varargin{:});
    code = ip.Results.code;
    freq = ip.Results.freq;
    inpbandsperiod = ip.Results.volatilityperiod;
    debug = ip.Results.debug;
    
    jaw = smma(p,13,8);jaw = [nan(8,1);jaw];
    teeth = smma(p,8,5);teeth = [nan(5,1);teeth];
    lips = smma(p,5,3);lips = [nan(3,1);lips];
    [bs,ss,lvlup,lvldn,bc,sc] = tdsq(p(:,1:5));
    wad = williamsad(p(:,1:5));
    if inpbandsperiod > 0
        [~,~,HH,LL,upper,lower] = fractalenhanced(p,nfractal,'volatilityperiod',inpbandsperiod);
        [ idxfractalb1,idxfractals1 ] = fractal_genindicators1( p,upper,lower,jaw,teeth,lips );
        tradesfractalb1 = fractal_gentradesb1( idxfractalb1,p,upper,lower,bs,ss,lvlup,lvldn,bc,sc,'code',code,'freq',freq,'lips',lips,'wad',wad,'nfractal',nfractal,'debug',debug);
    tradesfractals1 = fractal_gentradess1( idxfractals1,p,upper,lower,bs,ss,lvlup,lvldn,bc,sc,'code',code,'freq',freq,'lips',lips,'wad',wad,'nfractal',nfractal,'debug',debug);
    else
        [~,~,HH,LL] = fractal(p,nfractal);
        [ idxfractalb1,idxfractals1 ] = fractal_genindicators1( p,HH,LL,jaw,teeth,lips );
        tradesfractalb1 = fractal_gentradesb1( idxfractalb1,p,HH,LL,bs,ss,lvlup,lvldn,bc,sc,'code',code,'freq',freq,'lips',lips,'wad',wad,'nfractal',nfractal,'debug',debug);
    tradesfractals1 = fractal_gentradess1( idxfractals1,p,HH,LL,bs,ss,lvlup,lvldn,bc,sc,'code',code,'freq',freq,'lips',lips,'wad',wad,'nfractal',nfractal,'debug',debug);
    end
    %gentrades with the upperchannel and lowerchannel
    
    nb1 = tradesfractalb1.latest_;
    ns1 = tradesfractals1.latest_;
    tradesfractal1 = cTradeOpenArray;
    for i = 1:nb1, tradesfractal1.push(tradesfractalb1.node_(i));end
    for i = 1:ns1, tradesfractal1.push(tradesfractals1.node_(i));end
    
    pnl = zeros(nb1+ns1,9);
    for i = 1:nb1+ns1
        tradein = tradesfractal1.node_(i);
        pnl(i,1) = find(p(:,1) == tradein.opendatetime1_);
        pnl(i,2) = tradein.opendirection_;
        pnl(i,3) = tradein.openprice_;
        
        tradeout = fractal_runtrade(tradein,p,HH,LL,jaw,teeth,lips,bs,ss,bc,sc,lvlup,lvldn,wad,debug);
        %run pnl with HH and LL instead of upperchannel and lowerchannel
%         tradeout = fractal_runtrade(tradein,p,HH,LL,jaw,teeth,lips,bs,ss,bc,sc,lvlup,lvldn);
        if isempty(tradeout)
            pnl(i,4) = size(p,1);
            pnl(i,5) = p(end,5);
            if ~isempty(tradein.runningpnl_)
                pnl(i,6) = tradein.runningpnl_;
            else
                pnl(i,6) = 0;
            end
        else
            pnl(i,4) = find(p(:,1) == tradein.closedatetime1_);
            pnl(i,5) = tradein.closeprice_;
            pnl(i,6) = tradein.closepnl_;
        end
        if i <= nb1
            k = idxfractalb1(:,1) == pnl(i,1);
            pnl(i,7) = idxfractalb1(k,2);
            if bc(pnl(i,1)) == 13, pnl(i,8) = 1;end
            if ss(pnl(i,1))>=9
                j = pnl(i,1);
                ssreached = ss(j);
                if p(j,5)>=max(p(j-ssreached+1:j,5)) && p(j,3)>=max(p(j-ssreached+1:j,3))
                    pnl(i,9) = 1;
                end
            end
        else
            k = idxfractals1(:,1) == pnl(i,1);
            pnl(i,7) = idxfractals1(k,2);
            if sc(pnl(i,1)) == 13, pnl(i-nb1,8) = 1;end
            if bs(pnl(i,1))>=9
                j = pnl(i,1);
                bsreached = bs(j);
                if p(j,5)<=min(p(j-bsreached+1:j,5)) && p(j,4)<=min(p(j-bsreached+1:j,4))
                    pnl(i-nb1,9) = 1;
                end
            end
        end
    end
    pnl = sortrows(pnl);
    
end