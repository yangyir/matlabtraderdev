function [] = print(mdefx,varargin)
%cmdefx
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    tnum = p.Results.Time;
    tstr = datestr(tnum,'yyyy-mm-dd HH:MM:SS');
    
    fprintf('called cmdefx::print %s\n',tstr);
    
    fprintf('%10s %8s %10s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s\n',...
        'code','latest','preclose','change','Ktime','hh','ll','bs','ss','levelup','leveldn','teeth','lips');
%     dataformat = '%10s %8s %10s %8.2f%% %11s %10s %10s %4s %4s %10s %10s %10.4f %10.4f\n';
    
    nfx = size(mdefx.codes_fx_,1);
    for i = 1:nfx
        code = mdefx.codes_fx_{i}(1:end-3);
        latest = mdefx.dailybar_fx_{i}(end,5);
        lastclose = mdefx.dailybar_fx_{i}(end-1,5);
        delta = (latest/lastclose-1)*100;
        buysetup = mdefx.struct_fx_{i}.bs(end);
        sellsetup = mdefx.struct_fx_{i}.ss(end);
        levelup = mdefx.struct_fx_{i}.lvlup(end);
        leveldn = mdefx.struct_fx_{i}.lvldn(end);
        teeth = mdefx.struct_fx_{i}.teeth(end);
        lips = mdefx.struct_fx_{i}.lips(end);
        HH = mdefx.struct_fx_{i}.hh(end);
        LL = mdefx.struct_fx_{i}.ll(end);
        if ~isempty(strfind(code,'JPY'))
            dataformat = '%10s %8.2f %10.2f %8.2f%% %11s %10.2f %10.2f %4s %4s %10.2f %10.2f %10.2f %10.2f\n';
        else
            dataformat = '%10s %8.4f %10.4f %8.2f%% %11s %10.4f %10.4f %4s %4s %10.4f %10.4f %10.4f %10.4f\n';
        end
        
        fprintf(dataformat,code,latest,lastclose,...
            delta,datestr(tnum,'HH:MM'),...
            HH,LL,...
            num2str(buysetup),num2str(sellsetup),levelup,leveldn,...
            teeth,lips);
    end
    
    fprintf('\n');
    
    for i = 1:nfx
        try
            if ~isempty(strfind(mdefx.codes_fx_{i},'JPY'))
                tools_technicalplot2(mdefx.mat_fx_{i}(end-62:end,:),i+1,mdefx.codes_fx_{i},true,0.02);
            else
                tools_technicalplot2(mdefx.mat_fx_{i}(end-62:end,:),i+1,mdefx.codes_fx_{i},true,0.0005);
            end
        catch
            continue;
        end
    end
    
     % ---------- signal refresh ------------
    mdefx.updatesignal_fx;
    
    
end

