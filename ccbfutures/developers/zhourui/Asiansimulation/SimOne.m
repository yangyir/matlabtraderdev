function [ Pnl,PnlU,PnlO,PnlF,Delta ,underlyingPath,PerDayPnl,vegaPath,StrikePath,AveragePath,RealUVol] = SimOne( Parameter,TradingDay,RealVol,StrHoliday )
    dt1=1/252;
    RandomArray=[0,(Parameter.CostOfCarry-0.5.*RealVol^2).*dt1+RealVol.*sqrt(dt1).*randn(1,length(TradingDay)-1)];
    UnderlyingPath=Parameter.UnderlyingPrice.*exp(cumsum(RandomArray,2));
    AverageDay=CalculateTradingDay(Parameter.AverageStartDate,Parameter.AverageEndDate,StrHoliday);
    delta_old=0;
    cash_sum=0;
    m=0;
    n=length(AverageDay);
    Average=0;
    TotalPnl_old= 0;
    Fee=zeros(1,length(TradingDay));
    OptionPrice=zeros(1,length(TradingDay));
    delta=zeros(1,length(TradingDay));
    gamma=zeros(1,length(TradingDay));
    UnderlyingPnl=zeros(1,length(TradingDay));
    OptionPnl=zeros(1,length(TradingDay));
    PerDayPnl=zeros(1,length(TradingDay));
    TotalPnl=zeros(1,length(TradingDay));
    AveragePath = zeros(1,length(TradingDay));
    vegaPath = zeros(1,length(TradingDay));
    StrikePath = ones(1,length(TradingDay)) * Parameter.Strike;
    returnSeris = UnderlyingPath(2:end) ./ UnderlyingPath(1:end-1);
    RealUVol = std(returnSeris) * sqrt(252);
    for i=1:1:length(TradingDay);
        if (AverageDay(1)-TradingDay(i)>0)
            t1=(AverageDay(1)-TradingDay(i))/365;
            T=(datenum(Parameter.EndDate)-TradingDay(i))/365;
            OptionPrice(i)=AsianCurran(Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
            delta(i)=AsianGreeks('delta',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
            gamma(i)=AsianGreeks('gamma',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
            vegaPath(i) = AsianGreeks('vega',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
            AveragePath(i) = Average;
            delta_new=delta(i);
            Fee(i)=abs((-delta_new+delta_old));
            cash_sum=cash_sum+(-(-delta_new+delta_old)*UnderlyingPath(i));
            UnderlyingPnl(i)=-delta_new*UnderlyingPath(i)+cash_sum;
            OptionPnl(i)=OptionPrice(i)-OptionPrice(1);
            TotalPnl(i)=UnderlyingPnl(i)+OptionPnl(i);
            PerDayPnl(i) = TotalPnl(i) - TotalPnl_old;
            TotalPnl_old = TotalPnl(i);
            delta_old=delta(i);
        else
            if (TradingDay(i)==datenum(Parameter.EndDate))
                Average=(Average*m+UnderlyingPath(i))/(m+1);
                AveragePath(i) = Average;
                m=m+1;
                OptionPrice(i)=max(Parameter.cp*(Average-Parameter.Strike),0);
                delta(i)=0;
                gamma(i)=0;
                delta_new=delta(i);
                Fee(i)=abs((-delta_new+delta_old));
                cash_sum=cash_sum+(-(-delta_new+delta_old)*UnderlyingPath(i));
                UnderlyingPnl(i)=-delta_new*UnderlyingPath(i)+cash_sum;
                OptionPnl(i)=OptionPrice(i)-OptionPrice(1);
                TotalPnl(i)=UnderlyingPnl(i)+OptionPnl(i);
                PerDayPnl(i) = TotalPnl(i) - TotalPnl_old;
                TotalPnl_old = TotalPnl(i);
                delta_old=delta(i);
            else
                Average=(Average*m+UnderlyingPath(i))/(m+1);
                AveragePath(i) = Average;
                m=m+1;
                t1=(AverageDay(m+1)-AverageDay(m))/365;
                T=(datenum(Parameter.EndDate)-TradingDay(i))/365;
                OptionPrice(i)=AsianCurran(Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
                delta(i)=AsianGreeks('delta',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
                gamma(i)=AsianGreeks('gamma',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
                vegaPath(i) = AsianGreeks('vega',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
                delta_new=delta(i);
                Fee(i)=abs((-delta_new+delta_old));
                cash_sum=cash_sum+(-(-delta_new+delta_old)*UnderlyingPath(i));
                UnderlyingPnl(i)=-delta_new*UnderlyingPath(i)+cash_sum;
                OptionPnl(i)=OptionPrice(i)-OptionPrice(1);
                TotalPnl(i)=UnderlyingPnl(i)+OptionPnl(i);
                PerDayPnl(i) = TotalPnl(i) - TotalPnl_old;
                TotalPnl_old = TotalPnl(i);
            
                delta_old=delta(i);
            end
        end
    end
    PerDayPnl = PerDayPnl .* -1;
    underlyingPath = UnderlyingPath;
    Pnl= -TotalPnl;
    PnlU= -UnderlyingPnl;
    PnlO= -OptionPnl;
    PnlF=Fee;
    Delta=delta;
end

