%note:
%in tdsq_openlogic2;we will check cases below:
%1)open a long position if and only if macd is still negative
%2 open a short position if and only if macd is still positive
%
%in the 1st case, we would only allow the following scenario
%1a.breach up lvldn from below
%1b.breach up lvlup from below
%
%in the 2nd case,we would only allow the following scenario
%1a.breach down lvlup from above
%1b.breach down lvldn from above

clc;
for i = 2:np
    %add ticksize as the data records the trade price only, which could be
    %either the bid or the ask price
    breachuplvldn = p(i-1,5)<lvldn(i-1) && p(i,5)>lvldn(i-1) && diffvec(i)<0;
    breachuplvlup = p(i-1,5)<lvlup(i-1) && p(i,5)>lvlup(i-1) && diffvec(i)<0;
    breachdnlvldn = p(i-1,5)>lvldn(i-1) && p(i,5)<lvldn(i-1) && diffvec(i)>0;
    breachdnlvlup = p(i-1,5)>lvlup(i-1) && p(i,5)<lvlup(i-1) && diffvec(i)>0;
    
    if breachuplvldn || breachuplvlup || breachdnlvldn || breachdnlvlup
        refs = macdenhanced(i,p);
%         upperbound1 = refs.y1 + refs.k1*refs.x(end);
%         lowerbound1 = refs.y2 + refs.k2*refs.x(end);
        upperbound2 = refs.y3 + refs.k3*refs.x(end);
        lowerbound2 = refs.y4 + refs.k4*refs.x(end);
    else
        continue;
    end
    
    if isempty(upperbound2) && isempty(lowerbound2), continue;end
    
    if breachuplvldn
        if upperbound2>lowerbound2 && p(i,5) > upperbound2
            fprintf('B at %4d with ss %2d:breachup lvldn with macd negative\n',i,ss(i));
           
        else
            if p(i,5) > lowerbound2 && ss(i) > 0
                fprintf('B at %4d with ss %2d:breachup lvldn with macd negative but boundary crossed\n',i,ss(i));
            end
        end
    end
    %
    if breachuplvlup
        if upperbound2>lowerbound2 && p(i,5) > upperbound2    
            fprintf('B at %4d with ss %2d:breachup lvlup with macd negative\n',i,ss(i));
        else
            if p(i,5) > lowerbound2 && ss(i) > 0
                fprintf('B at %4d with ss %2d:breachup lvlup with macd negative but boundary crossed\n',i,ss(i));
            end
        end
    end
    %
    if breachdnlvldn
        if upperbound2>lowerbound2 && p(i,5) < lowerbound2
            fprintf('S at %4d with bs %2d:breachdn lvldn with macd positive\n',i,bs(i));
        else
            %upperbound2 and lowerbound2 was crossed before this time point
            %normally this is because the price jumped but then moves flat
            %in a smaller range
            if p(i,5) < upperbound2 && bs(i) > 0
                fprintf('S at %4d with bs %2d:breachdn lvldn with macd positive but boundary crossed\n',i,bs(i));
            end
        end
    end
    %
    if breachdnlvlup 
        if upperbound2>lowerbound2 && p(i,5) < lowerbound2
            fprintf('S at %4d with bs %2d:breachdn lvlup with macd positive\n',i,bs(i));
        else
            %upperbound2 and lowerbound2 was crossed before this time point
            %normally this is because the price jumped but then moves flat
            %in a smaller range
            if p(i,5) < upperbound2 && bs(i) > 0
                fprintf('S at %4d with bs %2d:breachdn lvlup with macd positive but boundary crossed\n',i,bs(i));
            end
        end
    end
    
end