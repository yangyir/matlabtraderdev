function [flag] = tdsq_is9139buycount(bs,ss,bc,sc)
    variablenotused(sc);
    
    last2bs = find(bs == 9,2,'last');
    if isempty(last2bs), flag = false;return;end
    if length(last2bs) == 1, flag = false;return;end
    
    lastbc = find(bc == 13,1,'last');
    if isempty(lastbc), flag = false;return;end
    if lastbc <= last2bs(1), flag = false;return;end
%     sctemp = sc(~isnan(sc(last2ss(1):lastsc)));
%     if length(sctemp) < 13, flag = false;return;end
        
    %1. The TD Buy Setup must not begin before or on the same price bar as
    %the completed TD Buy Countdown,
    if last2bs(2)-8 <= lastbc, flag = false;return;end
    
    %2. The ensuing TD Buy Setup must be preveded by a bullish TD Price
    %Flip
    if isempty(find(ss(last2bs(1):last2bs(2)) == 1,1,'first'))
        flag = false;
        return
    end
    
    %3. There must be no completed TD Sell Setup prior to the apprearance of
    %the TD Buy Setup
    if ~isempty(find(ss(last2bs(1):last2bs(2)) == 9,1,'first'))
        flag = false;
        return
    end
    
    flag = true;
    
    
end