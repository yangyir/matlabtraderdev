function [ Price ] = AsianCurran( cp,S,A,K,t1,T,n,m,r,b,v )
    dt=(T-t1)/(n-1);
    if b==0
        EA=S;
    else
        EA=S/n*exp(b*t1)*(1-exp(b*dt*n))/(1-exp(b*dt));
    end
    if m>0
        if A>(n/m*K)
            if cp==-1
                Price=0;
                return;
            else
                A=A*m/n+EA*(n-m)/n;
                Price=(A-K)*exp(-r*T);
                return;
            end
        end
    end
    if m==(n-1)
        K=n*K-(n-1)*A;
        Price=GBlack(cp,S,K,T,r,b,v)*1/n;
        return;
    end
    if m>0
        K=n/(n-m)*K-m/(n-m)*A;
    end
    vx=v*sqrt(t1+dt*(n-1)*(2*n-1)/(6*n));
    my=log(S)+(b-v*v*0.5)*(t1+(n-1)*dt/2);
    sum1=0;
    for i=1:1:n
        ti=dt*i+t1-dt;
        vi=v*sqrt(t1+(i-1)*dt);
        vxi=v*v*(t1+dt*((i-1)-i*(i-1)/(2*n)));
        myi=log(S)+(b-v*v*0.5)*ti;
        sum1=sum1+exp(myi+vxi/(vx*vx)*(log(K)-my)+(vi*vi-vxi*vxi/(vx*vx))*0.5);
    end
    Km=2*K-1/n*sum1;
    sum2=0;
    for i=1:1:n
        ti=dt*i+t1-dt;
        vi=v*sqrt(t1+(i-1)*dt);
        vxi=v*v*(t1+dt*((i-1)-i*(i-1)/(2*n)));
        myi=log(S)+(b-v*v*0.5)*ti;
        sum2=sum2+exp(myi+vi*vi*0.5)*CND(cp*((my-log(Km))/vx+vxi/vx));
    end
    Price=exp(-r*T)*cp*(1/n*sum2-K*CND(cp*(my-log(Km))/vx))*(n-m)/n;
end

