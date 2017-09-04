function [ TPnl,UPnl,OPnl,FPnl,Delta ,UnderlyingPath,TradingDay,PerPnl,StrikePath,AveragePath,VegaPath] = HisSimConstByTD( Parameter,TradingDay,UnderlyingPath )
    while (isempty(find(TradingDay==datenum(Parameter.EndDate),1)))
        Parameter.EndDate=datestr(datenum(Parameter.EndDate)+1);
    end
    while(isempty(find(TradingDay==datenum(Parameter.AverageStartDate),1)))
        Parameter.AverageStartDate=datestr(datenum(Parameter.AverageStartDate)+1);
    end
    while(isempty(find(TradingDay==datenum(Parameter.AverageEndDate),1)))
        Parameter.AverageEndDate=datestr(datenum(Parameter.AverageEndDate)+1);
    end
    k1=find(TradingDay==datenum(Parameter.AverageStartDate));
    k2=find(TradingDay==datenum(Parameter.AverageEndDate));
    AverageDay=TradingDay(k1:k2);
    k3=find(TradingDay==datenum(Parameter.StartDate));
    k4=find(TradingDay==datenum(Parameter.EndDate));
    TradingDay=TradingDay(k3:k4);
    UnderlyingPath=UnderlyingPath(k3:k4);
    Average=Parameter.AverageNow;
    n=length(AverageDay);
    m=0;
    delta_old=0;
    cash_sum=0;
    Total_pnl_old = 0;
    OptionPrice=zeros(1,length(TradingDay));
    delta=zeros(1,length(TradingDay));
    gamma=zeros(1,length(TradingDay));
    Fee=zeros(1,length(TradingDay));
    UnderlyingPnl=zeros(1,length(TradingDay));
    OptionPnl=zeros(1,length(TradingDay));
    TotalPnl=zeros(1,length(TradingDay));
    AveragePath = zeros(1,length(TradingDay));
    StrikePath = ones(1,length(TradingDay)) * Parameter.Strike;
    VegaPath = zeros(1,length(TradingDay));
    for i=1:1:length(TradingDay);
        if (AverageDay(1)-TradingDay(i)>0)
            mpvk=find(TradingDay==AverageDay(1));
            t1=(mpvk-i)/252;
            T=(length(TradingDay)-i)/252;
            OptionPrice(i)=AsianCurran(Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
            delta(i)=AsianGreeks('delta',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
            gamma(i)=AsianGreeks('gamma',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
            VegaPath(i) = AsianGreeks('vega',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
            AveragePath(i) = Average;
            delta_new=delta(i);
            cash_sum=cash_sum+(-(-delta_new+delta_old)*UnderlyingPath(i));
            Fee(i)=abs((-delta_new+delta_old));
            UnderlyingPnl(i)=-delta_new*UnderlyingPath(i)+cash_sum;
            OptionPnl(i)=OptionPrice(i)-OptionPrice(1);
            TotalPnl(i)=UnderlyingPnl(i)+OptionPnl(i);
            perDayPnl(i) = TotalPnl(i) - Total_pnl_old;
            Total_pnl_old = TotalPnl(i);
            delta_old=delta(i);
        else
            if(TradingDay(i)==datenum(Parameter.EndDate))
                Average=(Average*m+UnderlyingPath(i))/(m+1);
                AveragePath(i) = Average;
                m=m+1;
                OptionPrice(i)=max(Parameter.cp*(Average-Parameter.Strike),0);
                delta(i)=0;
                gamma(i)=0;
                delta_new=delta(i);
                cash_sum=cash_sum+(-(-delta_new+delta_old)*UnderlyingPath(i));
                Fee(i)=abs((-delta_new+delta_old));
                UnderlyingPnl(i)=-delta_new*UnderlyingPath(i)+cash_sum;
                OptionPnl(i)=OptionPrice(i)-OptionPrice(1);
                TotalPnl(i)=UnderlyingPnl(i)+OptionPnl(i);
                perDayPnl(i) = TotalPnl(i) - Total_pnl_old;
                Total_pnl_old = TotalPnl(i);
                delta_old=delta(i);
            else
                Average=(Average*m+UnderlyingPath(i))/(m+1);
                AveragePath(i) = Average;
                m=m+1;
                mpvk=find(TradingDay==TradingDay(i));
                t1=1/252;
                T=(length(TradingDay)-mpvk)/252;
                OptionPrice(i)=AsianCurran(Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
                delta(i)=AsianGreeks('delta',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
                gamma(i)=AsianGreeks('gamma',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
                VegaPath(i) = AsianGreeks('vega',Parameter.cp,UnderlyingPath(i),Average,Parameter.Strike,t1,T,n,m,Parameter.RiskFreeRate,Parameter.CostOfCarry,Parameter.Vol);
                delta_new=delta(i);
                cash_sum=cash_sum+(-(-delta_new+delta_old)*UnderlyingPath(i));
                Fee(i)=abs((-delta_new+delta_old));
                UnderlyingPnl(i)=-delta_new*UnderlyingPath(i)+cash_sum;
                OptionPnl(i)=OptionPrice(i)-OptionPrice(1);
                TotalPnl(i)=UnderlyingPnl(i)+OptionPnl(i);
                perDayPnl(i) = TotalPnl(i) - Total_pnl_old;
                Total_pnl_old = TotalPnl(i);
                delta_old=delta(i);
            end
        end
    end
    TPnl=-TotalPnl;
    UPnl=-UnderlyingPnl;
    OPnl=-OptionPnl;
    FPnl=Fee;
    PerPnl = -perDayPnl;
    Delta= delta;
end