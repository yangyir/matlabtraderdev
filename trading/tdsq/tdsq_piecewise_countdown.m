function [bcout,scout] = tdsq_piecewise_countdown(data,bs,ss,lvlup,lvldn,bcin,scin)
%TDSQ_PIECEWISE_COUNTDOWN Summary of this function goes here
%   Detailed explanation goes here
    
    np = size(data,1);
    nbs = size(bs,1);
    nbcin = size(bcin,1);
    
    if np ~= nbs, error('tdsq_piecewise_countdown:invalid input');end
    if np - nbcin ~= 1, error('tdsq_piecewise_countdown:invalid input');end
    
    bcout = [bcin;NaN];
    scout = [scin;NaN];
    
%     idxbs = find(bs == 9);
%     idxss = find(ss == 9);

    idxbs = find(bs==9,3,'last');
    idxss = find(ss==9,3,'last');
    
    if isempty(idxbs) && isempty(idxss), return; end
    
    %sell countdown
    if ~isempty(idxss) && data(end,5) >= data(end-2,3)
        countinfos = cell(length(idxss),1);
        breaktypes = cell(length(idxss),1);
        extrainfos = zeros(length(idxss),1);
        lastcounts = zeros(length(idxss),1);
        
        if (isempty(idxbs) || idxss(end) > idxbs(end))
            [countinfo,breaktype,extrainfo] = tdsq_single_sc(idxss(end),data,bs,lvldn(idxss(end)));
            countinfos{end} = countinfo;
            breaktypes{end} = breaktype;
            extrainfos(end) = extrainfo;
            if strcmpi(breaktype,'finished')
                if countinfo(end,2) == np, scout(end) = 13;end
            elseif strcmpi(breaktype,'unfinished')
                ii = 0;
                breaktype_other = breaktype;
                lastcheckidx = 1;
                while strcmpi(breaktype_other,'unfinished') && ii < length(idxss)-1
                    ii = ii + 1;
                    [countinfo_other,breaktype_other,extrainfo] = tdsq_single_sc(idxss(end-ii),data,bs,lvldn(idxss(end-ii)));
                    countinfos{end-ii} = countinfo_other;
                    breaktypes{end-ii} = breaktype_other;
                    extrainfos(end-ii) = extrainfo;
                    if strcmpi(breaktype_other,'finished') && countinfo_other(end,2) == np
                        scout(end) = 13;
                        break
                    end
                    if ~strcmpi(breaktype_other,'unfinished')
                        lastcheckidx = length(idxss) - ii;
                        break
                    end
                end
                if isnan(scout(end))
                    for j = lastcheckidx:length(idxss)
                        countinfo_j = countinfos{j};
                        if strcmpi(breaktypes{j},'finished') || strcmpi(breaktypes{j},'cancel1') || strcmpi(breaktypes{j},'cancel2')
                            continue;
                        else
                            lastcounts(j) = find(countinfo_j(:,2) == -1,1,'first')-1;
                        end
                        if lastcounts(j) == 0, continue;end
                        if lastcounts(j) == 12 && extrainfos(j) == 1, continue;end
                        scout(end) = lastcounts(j);
                        %break if it is valid
                        if strcmpi(breaktypes{j},'unfinished'), break;end
                    end
                end
            end
        end
    end
    %end of calc sell countdown
    %
    %
    %buy countdown
    if ~isempty(idxbs) && data(end,5) <= data(end-2,4)
        countinfos = cell(length(idxbs),1);
        breaktypes = cell(length(idxbs),1);
        extrainfos = zeros(length(idxbs),1);
        lastcounts = zeros(length(idxbs),1);
        
        if (isempty(idxss) || idxbs(end) > idxss(end))
            [countinfo,breaktype,extrainfo] = tdsq_single_bc(idxbs(end),data,ss,lvlup(idxbs(end)));
            countinfos{end} = countinfo;
            breaktypes{end} = breaktype;
            extrainfos(end) = extrainfo;
            if strcmpi(breaktype,'finished')
                if countinfo(end,2) == np, bcout(end) = 13;end
            elseif strcmpi(breaktype,'unfinished')
                ii = 0;
                breaktype_other = breaktype;
                lastcheckidx = 1;
                while strcmpi(breaktype_other,'unfinished') && ii < length(idxbs)-1
                    ii = ii + 1;
                    [countinfo_other,breaktype_other,extrainfo] = tdsq_single_bc(idxbs(end-ii),data,ss,lvlup(idxbs(end-ii)));
                    countinfos{end-ii} = countinfo_other;
                    breaktypes{end-ii} = breaktype_other;
                    extrainfos(end-ii) = extrainfo;
                    if strcmpi(breaktype_other,'finished') && countinfo_other(end,2) == np
                        bcout(end) = 13;
                        break
                    end
                    if ~strcmpi(breaktype_other,'unfinished')
                        lastcheckidx = length(idxbs) - ii;
                        break
                    end
                end
                if isnan(bcout(end))
                    for j = lastcheckidx:length(idxbs)
                        countinfo_j = countinfos{j};
                        if strcmpi(breaktypes{j},'finished') || strcmpi(breaktypes{j},'cancel1') || strcmpi(breaktypes{j},'cancel2')
                            continue;
                        else
                            lastcounts(j) = find(countinfo_j(:,2) == -1,1,'first')-1;
                        end
                        if lastcounts(j) == 0, continue;end
                        if lastcounts(j) == 12 && extrainfos(j) == 1, continue;end
                        bcout(end) = lastcounts(j);
                        %break if it is valid
                        if strcmpi(breaktypes{j},'unfinished'), break;end
                    end
                end
            end
        end
    end    
    

end

