function [ Price ] = GBlack( cp,S,K,T,r,b,v )
    d1=(log(S/K)+(b+v*v/2)*T)/(v*sqrt(T));
    d2=d1-v*sqrt(T);
    if cp==1
        Price=S*exp((b-r)*T)*CND(d1)-K*exp(-r*T)*CND(d2);
    else
        Price=K*exp(-r*T)*CND(-d2)-S*exp((b-r)*T)*CND(-d1);
    end
end

