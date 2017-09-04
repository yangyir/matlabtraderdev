function [ Greeks ] = AsianGreeks( TypeValue,cp,S,A,K,t1,T,n,m,r,b,v )
    if strcmp(TypeValue,'delta')
        Greeks=(AsianCurran(cp,S*1.0005,A,K,t1,T,n,m,r,b,v)-AsianCurran(cp,S*0.9995,A,K,t1,T,n,m,r,b,v))/(0.001*S);
    elseif strcmp(TypeValue,'gamma')
        Greeks=(AsianCurran(cp,S*1.0005,A,K,t1,T,n,m,r,b,v)-2*AsianCurran(cp,S,A,K,t1,T,n,m,r,b,v)+AsianCurran(cp,S*0.9995,A,K,t1,T,n,m,r,b,v))/(0.001*S*0.001*S);
    elseif strcmp(TypeValue,'vega')
        Greeks=(AsianCurran(cp,S,A,K,t1,T,n,m,r,b,v*1.001)-AsianCurran(cp,S,A,K,t1,T,n,m,r,b,v*0.999))/(v*0.002);
    elseif strcmp(TypeValue,'theta')
        
    elseif strcmp(TypeValue,'rho')
        Greeks=(AsianCurran(cp,S,A,K,t1,T,n,m,r*1.001,b,v)-AsianCurran(cp,S,A,K,t1,T,n,m,r*0.999,b,v))/(r*0.002);
    else
        Greeks=-100000;
    end
end

