function stateMatrix = qt_initdecisiondata(decisionData)
orgIDs = decisionData.tickerList;
n = length(orgIDs);
% symbols = cell(n,1);
% exchanges = zeros(n,1);
futures = cell(n,1);

for i = 1:n
    tradingCode = getTradingCodeByOrgid(orgIDs(i));
    windcode = tradingCode{1,1};
    futures{i,1} = windcode2contract(windcode);
end

%define synthetic options
data = decisionData.(decisionData.varList{1}).data;
vp = cVanillaPortfolio('VP1');
for i = 1:n
    refSpot = data(i);
    v = CreateObj(['vanilla_',num2str(i)],'security',...
        'securityname','vanilla','strike',1,'issuedate',...
        today,'expirydate',dateadd(today,'1m'),...
        'underlier',futures{i},'optiontype','straddle',...
        'referencespot',refSpot);
    vp.add(v);
end

stateMatrix.Futures = futures;
stateMatrix.AccountSerialID = 1;
stateMatrix.VanillaPortfolio = vp;

stateMatrix.Positions = zeros(n,1);
stateMatrix.AvgPrice = zeros(n,1);
stateMatrix.PnL = zeros(n,1);


end