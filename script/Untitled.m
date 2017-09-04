%%
%manually get market quote
asset = 'sugar';
tenor = '1709';

output = listedoptinfo(c,asset,tenor,'PrintOutput',true);

%%
%strategy anaysis
mid = (output.Bid+output.Ask)/2;
nStrikes = length(output.Strike);
midStrikeIdx = (nStrikes+1)/2;

pxCall = output.CallQuote(midStrikeIdx,:);
deltaCall = output.CallDelta(midStrikeIdx,:);
gammaCall = output.CallGamma(midStrikeIdx,:);
thetaCall = output.CallTheta(midStrikeIdx,:);
%
pxPut = output.PutQuote(midStrikeIdx,:);
deltaPut = output.PutDelta(midStrikeIdx,:);
gammaPut = output.PutGamma(midStrikeIdx,:);
thetaPut = output.PutTheta(midStrikeIdx,:);


%calc vega
volbump = 0.01;
volCall = output.CallImpVol(midStrikeIdx,1);
pxCallVolBump = bjsprice(mid,output.Strike(midStrikeIdx),...
    output.InterestRates,...
    today,output.OptionExpiry,...
    volCall+volbump,...
    output.InterestRates);
vegaCall = pxCallVolBump-mean(pxCall);
volPut = output.PutImpVol(midStrikeIdx,1);
[~,pxPutVolBump] = bjsprice(mid,output.Strike(midStrikeIdx),...
    output.InterestRates,...
    today,output.OptionExpiry,...
    volPut+volbump,...
    output.InterestRates);
vegaPut = pxPutVolBump-mean(pxPut);

%desc
%long call and put at the same time
weights = [1,1];
contractSize = 10;
numContract = 1;
premiumPaid = (weights(1)*pxCall(2)+weights(2)*pxPut(2))*contractSize*numContract;
deltaCash = (weights(1)*deltaCall+weights(2)*deltaPut)*mid*contractSize*numContract;
gammaCash = (weights(1)*gammaCall+weights(2)*gammaPut)*mid*contractSize*numContract;
theta = (weights(1)*thetaCall+weights(2)*thetaPut)*contractSize*numContract;
vega = (weights(1)*vegaCall+weights(2)*vegaPut)*contractSize*numContract;
breakEven = 0.1*sqrt(abs(theta/gammaCash/0.5));

fprintf('premium:%4.2f; delta:%4.2f; gamma:%4.2f; vega:%4.2f; theta:%4.2f; breakeven:%4.1f%%\n',...
    premiumPaid,deltaCash,gammaCash,vega,theta,breakEven*100);







