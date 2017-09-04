function [ Out ] = ArraySort( A )
    Mpv=[A;1:1:length(A)];
    for i=1:1:length(A)
        for j=i:1:length(A)
            if Mpv(1,i)>Mpv(1,j)
                a=Mpv(:,j);
                Mpv(:,j)=Mpv(:,i);
                Mpv(:,i)=a;
            end
        end
    end
    Out=Mpv;
end

