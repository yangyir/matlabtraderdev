function [upper1,lower1] = tdsq_updateboundary(p,bs,ss,lvlup,lvldn,upper0,lower0)
    upper1 = upper0;
    lower1 = lower0;
    %%
    if isnan(upper0) && isnan(lower0)
        if ~(bs(end) == 9 || ss(end) == 9), return;end
        if bs(end) == 9, upper1 = lvlup(end);return;end
        if ss(end) == 9, lower1 = lvldn(end);return;end
    end
    %%
    idxss = find(ss == 9);
    idxbs = find(bs == 9);
    matss = [idxss,lvldn(ss==9)];
    matbs = [idxbs,lvlup(bs==9)];
    matall = [matss;matbs];
    %首先按时间顺序排列
    matsorted = sortrows(matall);
    %%
    if isnan(upper0) && ~isnan(lower0)
        if ~(bs(end) == 9 || ss(end) == 9)
            if p(end,5) >= lower0
                lower1 = lower0;
            else
                upper1 = lower0;
                %这里可能是以下2种情况：
                %1.市场一路上涨过程中没有出现过buy setup sequential
                if isempty(idxbs)
                    %按照时间排序找到最后一个大于收盘价的lvldn
                    i = find(matsorted(:,end)<p(end,5),1,'last');
                    if isempty(i)
                        lower1 = NaN;
                    else
                        lower1 = matsorted(i,end);
                    end
                else
                %2.市场上涨过程中曾经出现过buy setup sequential    
                    temp = sort(matsorted(:,end));
                    i = find(temp<p(end,5),1,'last');
                    if isempty(i)
                        lower1 = NaN;
                    else
                        lower1 = temp(i);
                    end
                end
            end
            return
        end
        if ss(end) == 9
            %因为此时upper0仍然不存在，标志着价格没有向下穿透过lower0
            %同时也无需用考虑向上穿透boundary的情况
            lower1 = lvldn(end);
            if p(end,5) > lower0
                lower1 = max(lower1,lower0);
            end
            return
        end
        if bs(end) == 9
            %因为upper0仍然不存在，所以当buy setup sequential形成的时候第一次明确了upper1
            upper1 = lvlup(end);
            if p(end,5) >= lower0
                %如果价格仍在lower0之上
                lower1 = lower0;
            else
                %价格向下穿透了原来的lower0
                upper1 = lower0;
                i = find(matsorted(:,end)<p(end,5),1,'last');
                if isempty(i)
                    lower1 = NaN;
                else
                    lower1 = matsorted(i,end);
                end
            end
        end
        return
    end
    %%
    if ~isnan(upper0) && isnan(lower0)
        if ~(bs(end) == 9 || ss(end) == 9)
            if p(end,5) < upper0
                upper1 = upper0;
            else
                lower1 = upper0;
                %这里可能是以下2种情况：
                %1.市场一路下跌过程中没有出现过sell setup sequential
                if isempty(idxss)
                    %按照时间排序找到最后一个大于收盘价的lvlup
                    i = find(matsorted(:,end)>p(end,5),1,'last');
                    if isempty(i)
                        upper1 = NaN;
                    else
                        upper1 = matsorted(i,end);
                    end
                else
                %2.市场下跌过程中曾经出现过sell setup sequential
                    temp = sort(matsorted(:,end));
                    i = find(temp>p(end,5),1,'first');
                    if isempty(i)
                        upper1 = NaN;
                    else
                        upper1 = temp(i);
                    end
                end
            end
            return
        end
        if ss(end) == 9
            %因为lower0仍然不存在，所以当sell setup sequential形成的时候第一次明确了lower1
            lower1 = lvldn(end);
            if p(end,5) < upper0
                %如果价格仍在upper0之下
                upper1 = upper0;
            else
                %价格向上穿透了原来的upper0
                i = find(matsorted(:,end) >p(end,5),1,'last');
                if isempty(i)
                    upper1 = NaN;
                else
                    upper1 = matsorted(i,end);
                end
            end
            return
        end
        if bs(end) == 9
            %因为此时lower0仍然不存在，标志着价格没有向上穿透过upper0
            %同时也无需用考虑向下穿透boundary的情况
            upper1 = lvlup(end);
            if p(end,5) < upper0
                upper1 = min(upper1,upper0);
            end
        end
        return
    end
    %%
    %如果upper0和lower0都存在
    if ~(bs(end) == 9 || ss(end) == 9)
        %情景一：收盘价仍然在之前的区间内，即大于等于lower0且小于upper0
        if p(end,5) >= lower0 && p(end,5) <= upper0, return;end
        %情景二：收盘价向上突破了upper0
        if p(end,5) > upper0
            %价格可能出现跳高的情况，所以需要确定最大的lower
            i = find(matsorted(:,end)<p(end,5),1,'last');
            lower1 = matsorted(i,end);
            if lower1 < upper0
                lower1 = upper0;
            end
            i = find(matsorted(:,end)>p(end,5),1,'last');
            if isempty(i)
                upper1 = NaN;
            else
                upper1 = matsorted(i,end);
                idx = matsorted(i,1);
                if bs(idx) == 9
                    %检查buy setup sequential形成的过程中是否有向下击穿之前的支撑
                    if ~isempty(find(p(idx-8:idx,5) < lvldn(idx-8),1,'first'))
                        temp = lvldn(idx-8);
                        if p(end,5) < temp
                            upper1 = temp;
                        end
                    end
                end
            end
        %情景三：收盘价向下突破了lower0    
        elseif p(end,5) < lower0
            upper1 = lower0;
            i = find(matsorted(:,end)<p(end,5),1,'last');
            if isempty(i)
                lower1 = NaN;
            else
                lower1 = matsorted(i,end);
                idx = matsorted(i,1);
                if ss(idx) == 9
                    %检查sell setup sequential形成的过程中是否有向上击穿之前的压力
                    if ~isempty(find(p(idx-8:idx,5) > lvlup(idx-8),1,'first'))
                        temp = lvlup(idx-8);
                        if p(end,5) > temp
                            lower1 = temp;
                        end
                    end
                end
            end
        end
            
        return
    end
    %
    if bs(end) == 9
        upper1 = lvlup(end);
        if p(end,5) < upper0
            upper1 = min(upper1,upper0);
        end
        if p(end,5) > upper0
            lower1 = upper0;
        else
            if p(end,5) > lower0
                lower1 = lower0;
            else
                %价格向下穿透了原来的lower0
                i = find(matsorted(:,end)<p(end,5),1,'last');
                if isempty(i)
                    lower1 = NaN;
                else
                    lower1 = matsorted(i,end);
                end
            end
        end
        return
    end
    %
    if ss(end) == 9
        lower1 = lvldn(end);
        if p(end,5) > lower0
            lower1 = max(lower1,lower0);
        end
        if p(end,5) < lower0
            upper1 = lower0;
        else
            if p(end,5) < upper0
                upper1 = upper0;
            else
                %价格向上穿透了原来的upper0
                i = find(matsorted(:,end)>p(end,5),1,'last');
                if isempty(i)
                    upper1 = NaN;
                else
                    upper1 = matsorted(i,end);
                end
            end
        end
        return
    end
    
end