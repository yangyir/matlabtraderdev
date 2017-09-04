function [ Out ] = CND( x )
    if x==0
        Out=0.5;
    else
        a1=0.31938153;
        a2=-0.356563782;
        a3=1.781477937;
        a4=-1.821255978;
        a5=1.330274429;
        
        L=abs(x);
        k=1/(1+0.2316419*L);
        mpv=1-1/sqrt(2*pi)*exp(-(L*L/2))*(a1*k+a2*k^2+a3*k^3+a4*k^4+a5*k^5);
        if x>0
            Out=mpv;
        else
            Out=1-mpv;
        end
    end
end

