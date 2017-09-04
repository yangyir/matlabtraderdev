function output = listedoptinfo(conn,asset,tenor,varargin)
    if nargin < 2
        error('listedoptinfo:insufficient number of inputs')
    end
    
    if ~isa(conn,'blp')
        error('listedoptinfo:invalid database connection')
    end
    
    if ~ischar(asset)
        error('listedoptinfo:invalid asset input')
    end
    
    if ~(strcmpi(asset,'soymeal') || strcmpi(asset,'sugar') ...
            || strcmpi(asset,'50ETF'))
        error('listedoptinfo:only soymeal,sugar and 50ETF is supported')
    end
    
    if nargin < 3 && isempty(tenor) && ~strcmpi(asset,'50ETF')
        error('listedoptinfo:missing tenor input')
    end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('PrintOutput',false,@islogical);
    p.addParameter('NumberOfStrikes',5,@islogical);
    p.parse(varargin{:});
    printoutput = p.Results.PrintOutput;
    nStrikes = p.Results.NumberOfStrikes;
    
    if strcmpi(asset,'soymeal') || strcmpi(asset,'sugar')
        underlier = cContract('assetname',asset,'tenor',tenor);
        americanOpt = true;
        if strcmpi(asset,'soymeal')
            bucket = 50;
        else
            bucket = 100;
        end
    elseif strcmpi(asset,'50ETF')
        underlier = struct('AssetName',asset,...
            'BloombergCode','510050 CH Equity',...
            'TradingHours','09:30-11:30;13:00-15:00',...
            'TradingBreak','n/a',...
            'ContractSize',10000,...
            'TickSize',0.001);
        americanOpt = false;
        bucket = 0.05;
    end
    
    %1.get underlier price
    data = getdata(conn,underlier.BloombergCode,{'bid','ask','time'});
    bid = data.bid;
    ask = data.ask;
    mid = (bid+ask)/2;
    timeUpdate = today + datenum(data.time);
    strikeMid = round(mid/bucket)*bucket;
    idxMid = (nStrikes-1)/2+1;
    strikes = zeros(nStrikes,1);
    for i = 1:nStrikes
        strikes(i) = strikeMid+(i-idxMid)*bucket;
    end
    
    handlesCall = cell(nStrikes,1);
    handlesPut = cell(nStrikes,1);
    pxCall = zeros(nStrikes,2);
    pxPut = zeros(nStrikes,2);
    
    ratesSec = 'CCSWOC CMPN Curncy';    %CNY IRS(7D repo) 3MO
    %note:DayCount = ACT/365 and PayFrequency = 'Quarterly'
    data = getdata(conn,ratesSec,'px_last');
    r = data.px_last/100;
    
    if strcmpi(asset,'soymeal') || strcmpi(asset,'sugar')
        code = underlier.BloombergCode(1:end-length('Comdty')-1);
    elseif strcmpi(asset,'50etf')
        code = underlier.BloombergCode(1:end-length('Equity')-1);
    end
        
     
    
    for i = 1:nStrikes
        if strcmpi(asset,'soymeal') || strcmpi(asset,'sugar')
            handlesCall{i} = [code,'C ',num2str(strikes(i)),' Comdty'];
            handlesPut{i} = [code,'P ',num2str(strikes(i)),' Comdty'];
        elseif strcmpi(asset,'50etf')
            if isnumeric(tenor)
                tenor = num2str(tenor);
            end
            handlesCall{i} = [code,' ',tenor,' C',num2str(strikes(i)),' Equity'];
            handlesPut{i} = [code,' ',tenor,' P',num2str(strikes(i)),' Equity'];
        end
    end
    
    data = getdata(conn,handlesCall,{'bid','ask'});
    pxCall(:,1) = data.bid;
    pxCall(:,2) = data.ask;

    data = getdata(conn,handlesPut,{'bid','ask'});
    pxPut(:,1) = data.bid;
    pxPut(:,2) = data.ask;
        
    for i = 1:nStrikes
        try
            data = getdata(conn,handlesCall{i},'opt_expire_dt');
            expiry = data.opt_expire_dt;
            if isnumeric(expiry)
                break
            end
        catch
            %do nothing
        end
    end
       
    %note:we calculate the mid vol only
    ivCall = zeros(nStrikes,1);
    ivPut = zeros(nStrikes,1);
    if americanOpt
        for i = 1:nStrikes
            midCall = 0.5*(pxCall(i,1)+pxCall(i,2));
            midPut= 0.5*(pxPut(i,1)+pxPut(i,2));
            ivCall(i,1) = bjsimpv(mid,strikes(i),r,today,expiry,midCall,[],r,[],'call');
            ivPut(i,1) = bjsimpv(mid,strikes(i),r,today,expiry,midPut,[],r,[],'put');
        end
    else
        %for 50etf options only
        yield = 0.005;
        tau = (expiry-today)/365;
        ivCall = blsimpv(mid,strikes,r,tau,0.5*sum(pxCall,2),[],yield,[],true);
        ivPut = blsimpv(mid,strikes,r,tau,0.5*sum(pxPut,2),[],yield,[],false);
    end
    %
    
    % ---calculate the risk
    %delta/gamma calcs using spot bump as of 0.5% down and 0.5% up
    %theta calcs using 1 business date moving forward
    %vega calcs using 1 implied vol up
    
    %delta/gamma
    midUp = mid*(1+0.005);
    midDn = mid*(1-0.005);
    deltaCall = zeros(nStrikes,1);
    deltaPut = zeros(nStrikes,1);
    gammaCall = zeros(nStrikes,1);
    gammaPut = zeros(nStrikes,1);
    %note:since some IVs are NaN, we don't do a group pricing here
    for i = 1:nStrikes
        if americanOpt
            pxCallUp = bjsprice(midUp,strikes(i),r,today,expiry,ivCall(i),r);
            pxCallDn = bjsprice(midDn,strikes(i),r,today,expiry,ivCall(i),r);   
            %
            [~,pxPutUp] = bjsprice(midUp,strikes(i),r,today,expiry,ivPut(i),r);
            [~,pxPutDn] = bjsprice(midDn,strikes(i),r,today,expiry,ivPut(i),r);
        else
            %for 50etf options only
            yield = 0.005;
            tau = (expiry-today)/365;
            if isnan(ivCall(i))
                pxCallUp = NaN;
                pxCallDn = NaN;
            else
                pxCallUp = blsprice(midUp,strikes(i),r,tau,ivCall(i),yield);
                pxCallDn = blsprice(midDn,strikes(i),r,tau,ivCall(i),yield);
            end
            %
            if isnan(ivPut(i))
                pxPutUp = NaN;
                pxPutDn = NaN;
            else
                [~,pxPutUp] = blsprice(midUp,strikes(i),r,tau,ivPut(i),yield);
                [~,pxPutDn] = blsprice(midDn,strikes(i),r,tau,ivPut(i),yield);
            end
            
        end
        %note:we record the percentage level delta and gamma
        deltaCall(i) = (pxCallUp - pxCallDn)/(midUp-midDn);
        gammaCall(i) = (pxCallUp+pxCallDn-sum(pxCall(i,:)))/(0.005^2)*0.01/mid;
        %
        deltaPut(i) = (pxPutUp - pxPutDn)/(midUp-midDn);
        gammaPut(i) = (pxPutUp+pxPutDn-sum(pxPut(i,:)))/(0.005^2)*0.01/mid;
    end
    
    thetaCall = zeros(nStrikes,1);
    thetaPut = zeros(nStrikes,1);
    carryDate = businessdate(today,1);
    for i = 1:nStrikes
        if americanOpt
            pxCallCarry = bjsprice(mid,strikes(i),r,carryDate,expiry,ivCall(i),r);
            %
            [~,pxPutCarry] = bjsprice(mid,strikes(i),r,carryDate,expiry,ivPut(i),r);
        else
            yield = 0.005;
            tauCarry = (expiry-carryDate)/365;
            if isnan(ivCall(i))
                pxCallCarry = NaN;
            else
                pxCallCarry = blsprice(mid,strikes(i),r,tauCarry,ivCall(i),yield);
            end
            %
            if isnan(ivPut(i))
                pxPutCarry = NaN;
            else
                [~,pxPutCarry] = blsprice(mid,strikes(i),r,tauCarry,ivPut(i),yield);
            end
        end
        thetaCall(i) = pxCallCarry - 0.5*sum(pxCall(i,:));
        thetaPut(i) = pxPutCarry - 0.5*sum(pxPut(i,:));
    end
        
    %plot the implied volatility
    if printoutput
        plot(strikes,ivCall,'-bo');
        hold on;
        plot(strikes,ivPut,'-r*');
        hold off;
        legend('call','put','Location','northwest');
        title([underlier.BloombergCode,' option implied vols']);
        xlabel('strike');ylabel('implied vol');
    end
    
    %print the price/iv/risks
    if printoutput
        if strcmpi(asset,'soymeal') || strcmpi(asset,'sugar')
            fprintf('%s %s bid:%4.0f ask:%4.0f\n',...
                datestr(timeUpdate,'HH:MM:SS'),underlier.BloombergCode,bid,ask);
        else
            fprintf('%s %s bid:%4.3f ask:%4.3f\n',...
                datestr(timeUpdate,'HH:MM:SS'),underlier.BloombergCode,bid,ask);
        end
        fprintf('%s\n',datestr(expiry));

        for i = 1:nStrikes
           if i == 1
               if strcmpi(asset,'soymeal') || strcmpi(asset,'sugar')
                   fprintf('%4s %8s%8s%9s%10s%9s%10s %8s%8s%9s%10s%9s%10s\n','strike',...
                       'bid(c)','ask(c)','ivm(c)','delta(c)','gamma(c)','theta(c)',...
                       'bid(p)','ask(p)','ivm(p)','delta(p)','gamma(p)','theta(c)');
               else
                   fprintf('%4s %8s%9s%10s%11s%10s%10s %9s%9s%10s%11s%10s%10s\n','strike',...
                       'bid(c)','ask(c)','ivm(c)','delta(c)','gamma(c)','theta(c)',...
                       'bid(p)','ask(p)','ivm(p)','delta(p)','gamma(p)','theta(c)');
               end
           end
           %
           if strcmpi(asset,'soymeal') || strcmpi(asset,'sugar')
               fprintf('%4.0f %9.1f%8.1f%8.1f%%%7.1f%%%7.1f%%%10.1f %11.1f%8.1f%8.1f%%%8.1f%%%6.1f%%%10.1f\n',strikes(i),...
                   pxCall(i,1),pxCall(i,2),ivCall(i)*100,deltaCall(i)*100,gammaCall(i)*100,thetaCall(i),...
                   pxPut(i,1),pxPut(i,2),ivPut(i)*100,deltaPut(i)*100,gammaPut(i)*100,thetaPut(i));
           else
                fprintf('%4.2f %10.4f%9.4f%8.1f%%%8.1f%%%9.1f%%%12.4f %10.4f%9.4f%8.1f%%%9.1f%%%8.1f%%%12.4f\n',strikes(i),...
                   pxCall(i,1),pxCall(i,2),ivCall(i)*100,deltaCall(i)*100,gammaCall(i)*100,thetaCall(i),...
                   pxPut(i,1),pxPut(i,2),ivPut(i)*100,deltaPut(i)*100,gammaPut(i)*100,thetaPut(i));
           end
        end
        
        fprintf('\n');
        
    end
        
    output = struct('Underlier',underlier.BloombergCode,...
        'Bid',bid,...
        'Ask',ask,...
        'OptionExpiry',expiry,...
        'Strike',strikes,...
        'CallHandles',{handlesCall},...
        'CallQuote',pxCall,...
        'CallImpVol',ivCall,...
        'CallDelta',deltaCall,...
        'CallGamma',gammaCall,...
        'CallTheta',thetaCall,...
        'PutHandles',{handlesPut},...
        'PutQuote',pxPut,...
        'PutImpVol',ivPut,...
        'PutDelta',deltaPut,...
        'PutGamma',gammaPut,...
        'PutTheta',thetaPut,...
        'American',americanOpt,...
        'InterestRates',r);
    

end


