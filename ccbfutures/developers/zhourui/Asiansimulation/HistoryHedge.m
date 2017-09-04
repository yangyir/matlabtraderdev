clear;
clc;

MaturityDay=90;
TimeToFirstDay=60;
Query.UnderlyingName='CF.CZC';
Query.Fields='trade_hiscode,pre_close,close';
Query.StartDate='2015-06-19';
Query.EndDate='2017-06-19';

Parameter.cp=-1;
Parameter.UnderlyingPrice=0;
Parameter.AverageNow=0;
Parameter.Strike=100;
Parameter.StartDate='0';
Parameter.EndDate='0';
Parameter.AverageStartDate='0';
Parameter.AverageEndDate='0';
Parameter.RiskFreeRate=0.045;
Parameter.CostOfCarry=0;
Parameter.Vol=0.177;

Commission=6;
Coeffcient=5;
Lots=1000;
MarginRate=0.12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w=windmatlab;

[UnderlyingData,~,~,Times,~,~]=w.wsd(Query.UnderlyingName,Query.Fields,Query.StartDate,Query.EndDate);
[ExerciseData,~,~,ExerciseTimes,~,~]=w.wsd(Query.UnderlyingName,Query.Fields,datenum(Query.StartDate)-MaturityDay,datenum(Query.EndDate));
k=find(ExerciseTimes==Times(1));
for i=1:1:length(ExerciseTimes)
    if i>=k
        if (~strcmp(ExerciseData{i,1},ExerciseData{i-1,1}))
            [ExerciseData{i,2},~,~,~,~,~]=w.wsd(ExerciseData{i,1},'pre_close',ExerciseTimes(i,1),ExerciseTimes(i,1));
            UnderlyingData{i-k+1,2}=ExerciseData{i,2};
        end
    else
        if (i==1)||(~strcmp(ExerciseData{i,1},ExerciseData{i-1,1}))
            [ExerciseData{i,2},~,~,~,~,~]=w.wsd(ExerciseData{i,1},'pre_close',ExerciseTimes(i,1),ExerciseTimes(i,1));
        end
    end
end
Vol=HisVol(cell2mat(ExerciseData(:,2)),cell2mat(ExerciseData(:,3)),ExerciseTimes,Times);
%GarVol=garchVol(cell2mat(ExerciseData(:,2)),cell2mat(ExerciseData(:,3)),ExerciseTimes,Times);
%GarchVol = GarVik;
%GarchVol = GarVik;

LastDay=Times(length(Times))-MaturityDay;
while (isempty(find(Times==LastDay,1)));
   LastDay=LastDay-1;
   if LastDay<Times(1)
       pause;
   end
end
kk=find(Times==LastDay);

for i=1:1:kk
    tic;
    Parameter.UnderlyingPrice=UnderlyingData{i,3};
    Parameter.Strike=Parameter.UnderlyingPrice;
    Parameter.StartDate=datestr(Times(i));
    Parameter.EndDate=datestr(Times(i)+MaturityDay);
    Parameter.AverageStartDate=datestr(Times(i)+TimeToFirstDay);
    Parameter.AverageEndDate=datestr(Times(i)+MaturityDay);
    Parameter.Vol=Vol(i);
    [TotalPnl,UnderlyingPnl,OptionPnl,FeePnl,Delta,UnderlyingPath,TradingDay,perPnl,strikePath,averagePath,VegaCashPath] = ...
        HisSimConstByTD(Parameter,Times,cell2mat(UnderlyingData(:,3)));
    TotalPnl1{i,:}=TotalPnl *Lots; 
    UnderlyingPnl1{i,:}=UnderlyingPnl *Lots;
    OptionPnl1{i,:}=OptionPnl *Lots;
    FeePnl1{i,:}=FeePnl .*Commission*Lots/Coeffcient ;
    TotalFee(i) = sum(FeePnl) * Commission * Lots / Coeffcient ;
    Delta1{i,:} = Delta;
    UnderlyingPath1{i,:} = UnderlyingPath;
    strikePath1{i,:} = strikePath;
    averagePath1{i,:} = averagePath;
    TradingDay1{i,:} = TradingDay;
    PerdayPnl1{i,:} = perPnl .* Lots; 
    vegaCashPath{i,:} = VegaCashPath .*Lots /100;
    p(i) = Parameter;
    toc;
end

for i=1:1:size(TotalPnl1,1)
    Mpv1=TotalPnl1{i,:};
    Mpv2=FeePnl1{i,:};
    Mpv3=Delta1{i,:};
    Pnl(i)=Mpv1(end);
    Fee(i)=sum(Mpv2,2);
    DeltaCost(i)=max(abs(Mpv3))*UnderlyingData{i,3}*Lots*MarginRate*Parameter.RiskFreeRate*MaturityDay/365;
    Margin(i) = max(abs(Mpv3))*UnderlyingData{i,3}*Lots*MarginRate;
    initialVega(i) = vegaCashPath{i}(1);
end
figure;
[a,b]=hist((Pnl-Fee),25);
bar(b,a/sum(a));
p1=strcat(strcat('mean=',num2str(mean(Pnl-Fee))),strcat(',std=',num2str(std(Pnl-Fee))));
xlabel('Pnl');ylabel('Prob');title('Pnl Distribution 2 Years');legend(p1);

figure;
[a,b]=hist(DeltaCost,25);
bar(b,a/sum(a));
p2=strcat(strcat('mean=',num2str(mean(DeltaCost))),strcat(',std=',num2str(std(DeltaCost))));
xlabel('DeltaCost');ylabel('Prob');title('DeltaCost Distribution 2 Years');legend(p2);

figure;
[a,b]=hist(initialVega,25);
bar(b,a/sum(a));
p2=strcat(strcat('mean=',num2str(mean(initialVega))),strcat(',std=',num2str(std(initialVega))));
xlabel('VegaCash');ylabel('Prob');title('VegaCash Distribution 2 Years');legend(p2);

figure;
[a,b]=hist(Margin,25);
bar(b,a/sum(a));
p2=strcat(strcat('mean=',num2str(mean(Margin))),strcat(',std=',num2str(std(Margin))));
xlabel('Margin');ylabel('Prob');title('Margin Distribution 2 Years');legend(p2);
realVol = 0.177;
drawPnl( 1,TotalPnl1, UnderlyingPnl1,OptionPnl1,UnderlyingPath1,Delta1,PerdayPnl1,TotalFee,strikePath1,averagePath1,p,realVol,1);
drawPnl( 0.75,TotalPnl1, UnderlyingPnl1,OptionPnl1,UnderlyingPath1,Delta1,PerdayPnl1,TotalFee,strikePath1,averagePath1,p,realVol,1);
drawPnl( 0.50,TotalPnl1, UnderlyingPnl1,OptionPnl1,UnderlyingPath1,Delta1,PerdayPnl1,TotalFee,strikePath1,averagePath1,p,realVol,1);
drawPnl( 0.25,TotalPnl1, UnderlyingPnl1,OptionPnl1,UnderlyingPath1,Delta1,PerdayPnl1,TotalFee,strikePath1,averagePath1,p,realVol,1);
drawPnl( 0,TotalPnl1, UnderlyingPnl1,OptionPnl1,UnderlyingPath1,Delta1,PerdayPnl1,TotalFee,strikePath1,averagePath1,p,realVol,1);



% Mpv1=ArraySort(Pnl-Fee);
% min_v(1:1:3)=Mpv1(2,1:1:3);
% max_v(1:1:3)=Mpv1(2,size(Mpv1,2):-1:size(Mpv1,2)-2);
% mid_v(1:1:3)=Mpv1(2,floor(size(Mpv1,2)/2)-1:1:floor(size(Mpv1,2)/2)+1);
% 
% 
% [a,b]=hist((Pnl-Fee),20);
% [c,d]=hist(DeltaCost,20);
% p1=strcat(strcat('mean=',num2str(mean(Pnl-Fee))),strcat(',std=',num2str(std(Pnl-Fee))));
% p2=strcat(strcat('mean=',num2str(mean(DeltaCost))),strcat(',std=',num2str(std(DeltaCost))));
% 
% figure(1);
% bar(b,a/sum(a));
% xlabel('Pnl');ylabel('Prob');title('Pnl Distribution 2 Years');legend(p1);
% figure(2);
% bar(d,c/sum(c));
% xlabel('DeltaCost');ylabel('Prob');title('DeltaCost Distribution 2 Years');legend(p2);

