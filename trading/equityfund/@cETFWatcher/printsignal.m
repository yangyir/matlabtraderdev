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
    nfractal = 4;
    
    fprintf('\n');
    if strcmpi(code2print,'all')
        for i = 1:n_index
            extrainfo_i = obj.intradaybarstruct_index_{i};
            [ret,direction,breachtime,breachidx] = fractal_hasintradaybreach(timet,extrainfo_i,ticksize);
            if ret
                ei_breach = struct('px',extrainfo_i.px(1:breachidx,:),...
                    'ss',extrainfo_i.ss(1:breachidx),'sc',extrainfo_i.sc(1:breachidx),...
                    'bs',extrainfo_i.bs(1:breachidx),'bc',extrainfo_i.bc(1:breachidx),...
                    'idxhh',extrainfo_i.idxhh(1:breachidx),'idxll',extrainfo_i.idxll(1:breachidx),...
                    'lvlup',extrainfo_i.lvlup(1:breachidx),'lvldn',extrainfo_i.lvldn(1:breachidx),...
                    'hh',extrainfo_i.hh(1:breachidx),'ll',extrainfo_i.ll(1:breachidx),...
                    'lips',extrainfo_i.lips(1:breachidx),'teeth',extrainfo_i.teeth(1:breachidx),'jaw',extrainfo_i.jaw(1:breachidx),...
                    'wad',extrainfo_i.wad(1:breachidx));
                [signal,op] = fractal_signal_unconditional(ei_breach,ticksize,nfractal);
                if direction == 1
                    fprintf('%s:BreachUP:%s:\t',datestr(breachtime+1/48,'yyyy-mm-dd HH:MM'),obj.codes_index_{i}(1:6));
                    fprintf('%2d\t%s(%s)\n',signal(1),op.comment,obj.names_index_{i});
                else
                    
                    fprintf('%s:BreachDN:%s:\t',datestr(breachtime+1/48,'yyyy-mm-dd HH:MM'),obj.codes_index_{i}(1:6));
                    fprintf('%2d\t%s(%s)\n',signal(1),op.comment,obj.names_index_{i});
                end
            end
        end
        %
        for i = 1:n_sector
            extrainfo_i = obj.intradaybarstruct_sector_{i};
            [ret,direction,breachtime,breachidx] = fractal_hasintradaybreach(timet,extrainfo_i,ticksize);
            if ret
                ei_breach = struct('px',extrainfo_i.px(1:breachidx,:),...
                    'ss',extrainfo_i.ss(1:breachidx),'sc',extrainfo_i.sc(1:breachidx),...
                    'bs',extrainfo_i.bs(1:breachidx),'bc',extrainfo_i.bc(1:breachidx),...
                    'idxhh',extrainfo_i.idxhh(1:breachidx),'idxll',extrainfo_i.idxll(1:breachidx),...
                    'lvlup',extrainfo_i.lvlup(1:breachidx),'lvldn',extrainfo_i.lvldn(1:breachidx),...
                    'hh',extrainfo_i.hh(1:breachidx),'ll',extrainfo_i.ll(1:breachidx),...
                    'lips',extrainfo_i.lips(1:breachidx),'teeth',extrainfo_i.teeth(1:breachidx),'jaw',extrainfo_i.jaw(1:breachidx),...
                    'wad',extrainfo_i.wad(1:breachidx));
                [signal,op] = fractal_signal_unconditional(ei_breach,ticksize,nfractal);
                if direction == 1
                    fprintf('%s:BreachUP:%s:\t',datestr(breachtime+1/48,'yyyy-mm-dd HH:MM'),obj.codes_sector_{i}(1:6));
                    fprintf('%2d\t%s(%s)\n',signal(1),op.comment,obj.names_sector_{i});
                else
                    fprintf('%s:BreachDN:%s:\t',datestr(breachtime+1/48,'yyyy-mm-dd HH:MM'),obj.codes_sector_{i}(1:6));
                    fprintf('%2d\t%s(%s)\n',signal(1),op.comment,obj.names_sector_{i});
                end
            end
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