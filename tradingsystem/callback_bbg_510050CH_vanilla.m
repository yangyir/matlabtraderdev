function callback_bbg_510050CH_vanilla(obj,event,c,strikes,tenor)
%callback function to retrieve option quotes from bloomberg

if isempty(obj.UserData)
    %first time to run the callback function after initialization
    %the latest daily price return
    underlier = '510050 CH Equity';
    data = getdata(c,underlier,'last_close_trr_1d');
    dailyReturn = data.last_close_trr_1d/100;
    data = getdata(c,underlier,'px_close');
    closePrice = data.px_close;
    data = getdata(c,underlier,'px_close_dt');
    closeDate = data.px_close_dt;
    
    %option security bbg code
    nStrike = length(strikes);
    cSec = cell(nStrike,1);
    pSec = cell(nStrike,1);
    for i = 1:nStrike
        cSec{i} = ['510050 CH ',num2str(tenor),' C',num2str(strikes(i)),' Equity'];
        pSec{i} = ['510050 CH ',num2str(tenor),' P',num2str(strikes(i)),' Equity'];
    end
    
    %here we need to pop up business days information for option valuation
    data = getdata(c,cSec{1},'maturity');
    maturity = data.maturity;
    if ~isholiday(today)
        startDate = today;
    else
        startDate = businessdate(today,-1);
    end
    businessDays = gendates('fromdate',startDate,'todate',maturity);
    
    
    userData = struct('Underlier',underlier,...
        'LastCloseDate',closeDate,...
        'LastClosePrice',closePrice,...
        'LastDailyReturn',dailyReturn,...
        'Calls',{cSec},...
        'Puts',{pSec},...
        'RemainingBusDays',businessDays);
    obj.UserData = userData;    
end

ud = obj.UserData;

%---option quotoes and valuation
cSec = ud.Calls;
pSec = ud.Puts;
cData = getdata(c,cSec,{'bid','ask'});
pData = getdata(c,pSec,{'bid','ask'});
uData = getdata(c,ud.Underlier,{'bid','ask'});

%implied volatility
price = (uData.bid + uData.ask)/2;
cIV = zeros(length(cSec),1);
pIV = zeros(length(cSec),1);

rate = 0.035;
yield = 0.005;
t = (ud.RemainingBusDays(end)-ud.RemainingBusDays(1))/365;

for i = 1:length(cSec)
    cBid = cData.bid(i);
    cAsk = cData.ask(i);
    cIV(i) = blsimpv(price,strikes(i),rate,t,(cBid+cAsk)/2,[],yield,[],true);
    %
    pBid = pData.bid(i);
    pAsk = pData.ask(i);
    pIV(i,1) = blsimpv(price,strikes(i),rate,t,(pBid+pAsk)/2,[],yield,[],false);
end

%risks,i.e.delta,gamma,vega,theta
cDelta = zeros(length(cSec),1);
pDelta = zeros(length(pSec),1);
cGamma = cDelta;
pGamma = cGamma;
cVega = cDelta;
pVega = cVega;
cTheta = cDelta;
pTheta = cTheta;

priceUp = price*1.005;
priceDown = price*0.995;
if length(ud.RemainingBusDays)>1
    tCarry = (ud.RemainingBusDays(end)-ud.RemainingBusDays(2))/365;
else
    tCarry = NaN;
end

for i = 1:length(cSec)
    cBid = cData.bid(i);
    cAsk = cData.ask(i);
    pBid = pData.bid(i);
    pAsk = pData.ask(i);
    
    if ~isnan(cIV(i))
        cSpotUp = blsprice(priceUp,strikes(i),rate,t,cIV(i),yield);
        cSpotDown = blsprice(priceDown,strikes(i),rate,t,cIV(i),yield);
        cDelta(i) = (cSpotUp-cSpotDown)/(priceUp-priceDown);
        %calculate gamma
        cGamma(i) = (cSpotUp+cSpotDown-(cBid+cAsk))/((price*0.005)^2)*0.01;
        %calculate vega
        cVolUp = blsprice(price,strikes(i),rate,t,cIV(i)+0.01,yield);
        cVega(i) = cVolUp - (cBid+cAsk)/2;
        %calculate theta
        cCarry = blsprice(price,strikes(i),rate,tCarry,cIV(i),yield);
        cTheta(i) = cCarry - (cBid+cAsk)/2;
    else
        cDelta(i) = NaN;
        cGamma(i) = NaN;
        cVega(i) = NaN;
        cTheta(i) = NaN;
    end
    
    if ~isnan(pIV(i))    
        [~,pSpotUp] = blsprice(priceUp,strikes(i),rate,t,pIV(i),yield);
        [~,pSpotDown] = blsprice(priceDown,strikes(i),rate,t,pIV(i),yield);
        pDelta(i) = (pSpotUp-pSpotDown)/(priceUp-priceDown);
        %calculate gamma
        pGamma(i) = (pSpotUp+pSpotDown-(pBid+pAsk))/((price*0.005)^2)*0.01;
        %calculate vega
        [~,pVolUp] = blsprice(price,strikes(i),rate,t,pIV(i)+0.01,yield);
        pVega(i) = pVolUp - (pBid+pAsk)/2;
        %calculate theta
        [~,pCarry] = blsprice(price,strikes(i),rate,tCarry,pIV(i),yield);
        pTheta(i) = pCarry - (pBid+pAsk)/2;
    else
        pDelta(i) = NaN;
        pGamma(i) = NaN;
        pVega(i) = NaN;
        pTheta(i) = NaN;
    end 
end

%print results on screen
fprintf('%s underlying spot:%8.3f\n',datestr(event.Data.time),price);
fprintf('%s %5s %10s %8s %7s %9s \t\t%5s %10s %8s %7s %9s\n',...
    'strike','cMid','cDelta','cGamma','cVega','cTheta',...
    'pMid','pDelta','pGamma','pVega','pTheta');
for i = 1:length(cSec)
    cMid = (cData.bid(i)+cData.ask(i))/2;
    pMid = (pData.bid(i)+pData.ask(i))/2;
    fprintf('%.2f %9.4f %8.4f %8.4f %8.4f %9.4f %11.4f %8.4f %8.4f %8.4f %9.4f\n',...
        strikes(i),cMid,cDelta(i),cGamma(i),cVega(i),cTheta(i),...
        pMid,pDelta(i),pGamma(i),pVega(i),pTheta(i));
    
end
fprintf('\n');









end