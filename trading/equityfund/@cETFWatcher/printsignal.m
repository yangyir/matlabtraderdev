function [] = printsignal(obj,varargin)
%cETFWatcher
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','all',@ischar);
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    code2print = p.Results.Code;
    timet = p.Results.Time;
    
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    
    ticksize = 0.001;
    candlebucket = 1/48;%intraday 30m bucket
    
    if strcmpi(code2print,'all')
        for i = 1:n_index
        end
        %
        for i = 1:n_sector
        end
        %
        return
    end
    %
    foundflag = false;
    for i = 1:n_index
        if strcmpi(code2print,obj.codes_index_{i}(1:end-3))
            foundflag = true;
            candlet = obj.intradaybarstruct_index_{i}.px(:,1);
            %found the last candle which was fully poped
            idx = find(candlet+candlebucket < timet,1,'last');
            px = obj.intradaybarstruct_index_{i}.px(1:idx,:);
            hh = obj.intradaybarstruct_index_{i}.hh(1:idx,:);
            ll = obj.intradaybarstruct_index_{i}.ll(1:idx,:);
            lips = obj.intradaybarstruct_index_{i}.lips(1:idx,:);
            teeth = obj.intradaybarstruct_index_{i}.teeth(1:idx,:);
            jaw = obj.intradaybarstruct_index_{i}.jaw(1:idx,:);
            bs = obj.intradaybarstruct_index_{i}.bs(1:idx,:);
            ss = obj.intradaybarstruct_index_{i}.ss(1:idx,:);
            bc = obj.intradaybarstruct_index_{i}.bc(1:idx,:);
            sc = obj.intradaybarstruct_index_{i}.sc(1:idx,:);
            lvlup = obj.intradaybarstruct_index_{i}.lvlup(1:idx,:);
            lvldn = obj.intradaybarstruct_index_{i}.lvldn(1:idx,:);
            
            vaildbreachhh = px(end,5)-hh(end-1)>=ticksize & px(end-1,5)<=hh(end-1) &...
                abs(hh(end-1)/hh(end)-1)<2*ticksize &...
                px(end,3)>lips(end) &...
                ~isnan(lips(end))&~isnan(teeth(end))&~isnan(jaw(end)) &... 
                hh(end)-teeth(end)>=ticksize;
            
            validbreachll = px(end,5)-ll(end-1)<=-ticksize & px(end-1,5)>=ll(end-1) &...
                abs(ll(end-1)/ll(end)-1)<2*ticksize &...
                px(end,4)<lips(end) &...
                ~isnan(lips(end))&~isnan(teeth(end))&~isnan(jaw(end)) &...
                ll(end)-teeth(end)<=-ticksize;
            
            if vaildbreachhh && ~validbreachll
                if teeth(end) > jaw(end)
                    b1type = 3;
                else
                    b1type = 2;
                end
                op = fractal_filterb1_singleentry(b1type,4,obj.intradaybarstruct_index_{i},ticksize);
                useflag = op.use;
                if ~useflag
                    status = fractal_b1_status(4,obj.intradaybarstruct_index_{i},ticksize);
                    if status.isclose2lvlup
                        fprintf('\t%s-%s%:s\n',obj.codes_index_{i}(1:end-3),obj.names_index_{i},'conditional:closetolvlup');
                    else
                        fprintf('\t%s-%s%:s\n',obj.codes_index_{i}(1:end-3),obj.names_index_{i},op.comment);
                    end
                else
                    validlongopen = px(end,5) > px(end,3)-0.382*(px(end,3)-ll(end)) & ...
                        px(end,5) < hh(end)+1.618*(hh(end)-ll(end)) & ...
                        px(end,5) > lips(end);
                    if validlongopen
                        fprintf('\t%s-%s%:s\n',obj.codes_index_{i}(1:end-3),obj.names_index_{i},op.comment);
                    else
                        fprintf('\t%s-%s%:s\n',obj.codes_index_{i}(1:end-3),obj.names_index_{i},'price failed in range');
                    end
                end
            elseif ~vaildbreachhh  && validbreachll
                %note:lower priority as we cannot short equity/fund
                %maybe later for risk management
            elseif ~vaildbreachhh && ~validbreachll
                
            else
                warning('cETFWatcher:printsignal:internal error...');
            end
            
            
            break
        end
    end
    
    if ~foundflag
        for i = 1:n_sector
            if strcmpi(code2print,obj.codes_sector_{i}(1:end-3))
                foundflag = true;
                
                break
        end
        end
    
    if ~foundflag
        warning('cETFWatcher:printsignal:input code not found......')
    end
    
    
    
    
end