function [flag] = tdsq_is9139sellcount(bs,ss,bc,sc)
    variablenotused(bc);
    
    last2ss = find(ss == 9,2,'last');
    if isempty(last2ss), flag = false;return;end
    if length(last2ss) == 1, flag = false;return;end
    
    lastsc = find(sc == 13,1,'last');
    if isempty(lastsc), flag = false;return;end
    if lastsc <= last2ss(1), flag = false;return;end
%     sctemp = sc(~isnan(sc(last2ss(1):lastsc)));
%     if length(sctemp) < 13, flag = false;return;end
        
    %1. The TD Sell Setup must not begin before or on the same price bar as
    %the completed TD Sell Countdown,
    if last2ss(2)-8 <= lastsc, flag = false;return;end
    
    %2. The ensuing TD Sell Setup must be preveded by a bearish TD Price
    %Flip
    if isempty(find(bs(last2ss(1):last2ss(2)) == 1,1,'first'))
        flag = false;
        return
    end
    
    %3. There must be no completed TD Buy Setup prior to the apprearance of
    %the TD Sell Setup
    if ~isempty(find(bs(last2ss(1):last2ss(2)) == 9,1,'first'))
        flag = false;
        return
    end
    
    flag = true;
    
    
end