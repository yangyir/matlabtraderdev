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
    %���Ȱ�ʱ��˳������
    matsorted = sortrows(matall);
    %%
    if isnan(upper0) && ~isnan(lower0)
        if ~(bs(end) == 9 || ss(end) == 9)
            if p(end,5) >= lower0
                lower1 = lower0;
            else
                upper1 = lower0;
                %�������������2�������
                %1.�г�һ·���ǹ�����û�г��ֹ�buy setup sequential
                if isempty(idxbs)
                    %����ʱ�������ҵ����һ���������̼۵�lvldn
                    i = find(matsorted(:,end)<p(end,5),1,'last');
                    if isempty(i)
                        lower1 = NaN;
                    else
                        lower1 = matsorted(i,end);
                    end
                else
                %2.�г����ǹ������������ֹ�buy setup sequential    
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
            %��Ϊ��ʱupper0��Ȼ�����ڣ���־�ż۸�û�����´�͸��lower0
            %ͬʱҲ�����ÿ������ϴ�͸boundary�����
            lower1 = lvldn(end);
            if p(end,5) > lower0
                lower1 = max(lower1,lower0);
            end
            return
        end
        if bs(end) == 9
            %��Ϊupper0��Ȼ�����ڣ����Ե�buy setup sequential�γɵ�ʱ���һ����ȷ��upper1
            upper1 = lvlup(end);
            if p(end,5) >= lower0
                %����۸�����lower0֮��
                lower1 = lower0;
            else
                %�۸����´�͸��ԭ����lower0
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
                %�������������2�������
                %1.�г�һ·�µ�������û�г��ֹ�sell setup sequential
                if isempty(idxss)
                    %����ʱ�������ҵ����һ���������̼۵�lvlup
                    i = find(matsorted(:,end)>p(end,5),1,'last');
                    if isempty(i)
                        upper1 = NaN;
                    else
                        upper1 = matsorted(i,end);
                    end
                else
                %2.�г��µ��������������ֹ�sell setup sequential
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
            %��Ϊlower0��Ȼ�����ڣ����Ե�sell setup sequential�γɵ�ʱ���һ����ȷ��lower1
            lower1 = lvldn(end);
            if p(end,5) < upper0
                %����۸�����upper0֮��
                upper1 = upper0;
            else
                %�۸����ϴ�͸��ԭ����upper0
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
            %��Ϊ��ʱlower0��Ȼ�����ڣ���־�ż۸�û�����ϴ�͸��upper0
            %ͬʱҲ�����ÿ������´�͸boundary�����
            upper1 = lvlup(end);
            if p(end,5) < upper0
                upper1 = min(upper1,upper0);
            end
        end
        return
    end
    %%
    %���upper0��lower0������
    if ~(bs(end) == 9 || ss(end) == 9)
        %�龰һ�����̼���Ȼ��֮ǰ�������ڣ������ڵ���lower0��С��upper0
        if p(end,5) >= lower0 && p(end,5) <= upper0, return;end
        %�龰�������̼�����ͻ����upper0
        if p(end,5) > upper0
            %�۸���ܳ������ߵ������������Ҫȷ������lower
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
                    %���buy setup sequential�γɵĹ������Ƿ������»���֮ǰ��֧��
                    if ~isempty(find(p(idx-8:idx,5) < lvldn(idx-8),1,'first'))
                        temp = lvldn(idx-8);
                        if p(end,5) < temp
                            upper1 = temp;
                        end
                    end
                end
            end
        %�龰�������̼�����ͻ����lower0    
        elseif p(end,5) < lower0
            upper1 = lower0;
            i = find(matsorted(:,end)<p(end,5),1,'last');
            if isempty(i)
                lower1 = NaN;
            else
                lower1 = matsorted(i,end);
                idx = matsorted(i,1);
                if ss(idx) == 9
                    %���sell setup sequential�γɵĹ������Ƿ������ϻ���֮ǰ��ѹ��
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
                %�۸����´�͸��ԭ����lower0
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
                %�۸����ϴ�͸��ԭ����upper0
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