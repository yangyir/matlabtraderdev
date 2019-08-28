function [countinfo,breaktype,extrainfo] = tdsq_single_bc(idxstart,p,ss,lvlup)
% buy countdown in a seperate series
% idxstart is when bs == 9
    n = size(p,1);
    countinfo = zeros(13,2);
    for i = 1:13, countinfo(i,1) = i;countinfo(i,2) = -1;end
    
    buycount = 0;
    breaktype = 'unfinished';
    extrainfo = 0;
    for i = idxstart:n
        %first to introduce filters that cancel a developing TD Buy
        %Countdown
        %1.if the price action rallies and generates a TD Sell
        %Setup
        if ss(i) == 9
            breaktype = 'cancel1';
            break
        end
        %
        %2.or the market trades higher and posts a true low above
        %the true high of the prior TD Buy Setup - that is TDST
        %resisitence
        if lvlup < p(i,4)
            breaktype = 'cancel2';
            break
        end
        
        if p(i,5) <= p(i-2,4)
            if buycount < 12
                buycount = buycount + 1;
                countinfo(buycount,2) = i;
            elseif buycount == 12
                %to complete a TD buy countdown the low of TD Buy
                %Countdown bar thirteen must be less than, or equal
                %to, the close of TD Buy Countdown bar eight
                close8 = p(countinfo(8,2),5);
                if p(i,4) <= close8
                    buycount = buycount + 1;
                    countinfo(buycount,2) = i;
                    breaktype = 'finished';
                    break
                else
                    extrainfo = 1;
                end
            end
        end
        
    end
end