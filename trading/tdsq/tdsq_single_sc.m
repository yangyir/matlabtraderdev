function [countinfo,breaktype,extrainfo] = tdsq_single_sc(idxstart,p,bs,lvldn)
% sell countdown in a seperate series
% idxstart is when bs == 9
    n = size(p,1);
    countinfo = zeros(13,2);
    for i = 1:13, countinfo(i,1) = i;countinfo(i,2) = -1;end
    
    sellcount = 0;
    breaktype = 'unfinished';
    extrainfo = 0;
    for i = idxstart:n
        %first to introduce filters that cancel a developing TD Sell
        %Countdown
        %1.if the price action drops and generates a TD Buy Setup
        if bs(i) == 9
            breaktype = 'cancel1';
            break
        end
        %
        %2.or the market trades lower and posts a true high below
        %the true high of the prior TD Buy Setup - that is TDST support
        if lvldn > p(i,3)
            breaktype = 'cancel2';
            break
        end
        
        if p(i,5) >= p(i-2,3)
            if sellcount < 12
                sellcount = sellcount + 1;
                countinfo(sellcount,2) = i;
            elseif sellcount == 12
                %to complete a TD Sell countdown the high of TD
                %Sell Countdown bar thirteen must be greater than, or equal
                %to, the close of TD Sell Countdown bar eight
                close8 = p(countinfo(8,2),5);
                if p(i,3) >= close8
                    sellcount = sellcount + 1;
                    countinfo(sellcount,2) = i;
                    breaktype = 'finished';
                    break
                else
                    extrainfo = 1;
                end
            end
        end
        
    end
end