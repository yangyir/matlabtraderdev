clear;
clc;

Commission=2;
Coeffcient=10;
Lots=13000;
MarginRate=0.11;

Parameter.cp=-1;
Parameter.UnderlyingPrice=1;
Parameter.AverageNow=0;
Parameter.Strike=1;
Parameter.StartDate='19-Jun-2017';
Parameter.EndDate='19-Oct-2017';
Parameter.AverageStartDate='01-Aug-2017';
Parameter.AverageEndDate='19-Oct-2017';
Parameter.RiskFreeRate=0.045;
Parameter.CostOfCarry=0;
Parameter.Vol=0.19;

StrHoliday=['02-Oct-2017';'03-Oct-2017';'04-Oct-2017';'05-Oct-2017';'06-Oct-2017'];
TradingDay=CalculateTradingDay(Parameter.StartDate,Parameter.EndDate,StrHoliday);                                            
RealVol=0.19;
SimNumber=10000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parpool('local',4);
tic;
   parfor i=1:SimNumber
  %for i = 1: 100
    [TotalPnl(i,:),UnderlyingPnl(i,:),OptionPnl(i,:),FeePnl(i,:),Delta(i,:),...
        UnderlyingPath(i,:),PerdayPnl(i,:),VegaPath(i,:),StrikePath(i,:),AveragePath(i,:),RealUVol(i)] = ...
    SimOne(Parameter,TradingDay,RealVol,StrHoliday);
  %end
   end
toc;
delete(gcp('nocreate'));

Price=3880;
UnderlyingPath = UnderlyingPath.*Price;
StrikePath = StrikePath .* Price;
AveragePath = StrikePath .* AveragePath;
TotalFee=sum(FeePnl,2).*Lots/Coeffcient * Commission;
TotalPnl=TotalPnl.*Price.*Lots;
UnderlyingPnl = UnderlyingPnl .*Price.*Lots;
OptionPnl = OptionPnl  .*Price.*Lots;
Delta=Delta';
Margin = max(abs(Delta)) .* Price .* Lots .* MarginRate;
DeltaScale=max(abs(Delta)).*Price.*Lots.*MarginRate;
DeltaCost=DeltaScale.*Parameter.RiskFreeRate.*(datenum(Parameter.EndDate)-datenum(Parameter.StartDate))/363;
initalVega = VegaPath(:,1) .* Lots .* Price / 100;

[a,b]=hist(TotalPnl(:,size(TotalPnl,2))-TotalFee,30);
[c,d]=hist(DeltaCost,30);
p1=strcat(strcat('mean=',num2str(mean(TotalPnl(:,size(TotalPnl,2))-TotalFee))),strcat(',std=',num2str(std(TotalPnl(:,size(TotalPnl,2))-TotalFee))));
p2=strcat(strcat('mean=',num2str(mean(DeltaCost))),strcat(',std=',num2str(std(DeltaCost))));

figure;
bar(b,a/sum(a));
xlabel('Pnl');ylabel('Prob');title('Pnl Distribution 10000times');legend(p1);
figure;
bar(d,c/sum(c));
xlabel('DeltaCost');ylabel('Prob');title('DeltaCost Distribution 10000times');legend(p2);

figure;
histogram(Margin,30);
p1=strcat(strcat('mean=',num2str(mean(Margin))),strcat(',std=',num2str(std(Margin))));
xlabel('Margin');ylabel('Prob');title('Margin Distribution 10000times');legend(p1);

figure;
histogram(initalVega,30);
p1=strcat(strcat('mean=',num2str(mean(initalVega))),strcat(',std=',num2str(std(initalVega))));
xlabel('VegaCash');ylabel('Prob');title('VegaCash Distribution 10000times');legend(p1);


figure;
histogram(RealUVol,30);
p1=strcat(strcat('mean=',num2str(mean(RealUVol))),strcat(',std=',num2str(std(RealUVol))));
xlabel('RealUVol');ylabel('Prob');title('RealUVol Distribution 10000times');legend(p1);


drawPnl( 1,TotalPnl, UnderlyingPnl,OptionPnl,UnderlyingPath,Delta,PerdayPnl,TotalFee,StrikePath,AveragePath,Parameter,RealUVol,0);
drawPnl( 0.75,TotalPnl, UnderlyingPnl,OptionPnl,UnderlyingPath,Delta,PerdayPnl,TotalFee,StrikePath,AveragePath,Parameter,RealUVol,0);
drawPnl( 0.50,TotalPnl, UnderlyingPnl,OptionPnl,UnderlyingPath,Delta,PerdayPnl,TotalFee,StrikePath,AveragePath,Parameter,RealUVol,0);
drawPnl( 0.25,TotalPnl, UnderlyingPnl,OptionPnl,UnderlyingPath,Delta,PerdayPnl,TotalFee,StrikePath,AveragePath,Parameter,RealUVol,0);
drawPnl( 0.0,TotalPnl, UnderlyingPnl,OptionPnl,UnderlyingPath,Delta,PerdayPnl,TotalFee,StrikePath,AveragePath,Parameter,RealUVol,0);

