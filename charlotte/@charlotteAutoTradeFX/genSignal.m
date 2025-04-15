function [] = genSignal(obj,code)
% a charlotteAutoTradeFX function
    idxfound = -1;
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end
    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteData:genSignal:invalid code input...'));
        return
    end
    p = obj.candles_{idxfound};
    if isempty(p), return; end
    if isempty(obj.freq_{idxfound}), return;end
    
    nfractal = charlotte_freq2nfracal(obj.freq_{idxfound});
    [~,ei] = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0);
%     fprintf('%s latest bar time: %s and close at %s\n', ...
%                 code, datestr(ei.px(end,1),'yyyymmdd HH:MM'),num2str(ei.px(end,5)));
    if idxfound == 1
        fprintf('%10s%10s%14s%10s%10s%8s%8s%10s%10s%10s%10s%10s\n',...
                        'code','last','datetime(ldn)','hh','ll','bs','ss','levelup','leveldn','jaw','teeth','lips');
    end    
    
    if strcmpi(code,'USDJPY')
        dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.3f%10.3f%10.3f\n';
    elseif strcmpi(code,'XAUUSD')
        dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.2f%10.2f%10.2f\n';
    else
        dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.4f%10.4f%10.4f\n';
    end
    fprintf(dataformat,code,...
        num2str(ei.px(end,5)),...
        datestr(ei.px(end,1),'dd-mmm HH:MM'),...
        num2str(ei.hh(end)),num2str(ei.ll(end)),...
        num2str(ei.bs(end)),num2str(ei.ss(end)),num2str(ei.lvlup(end)),num2str(ei.lvldn(end)),...
        ei.jaw(end),ei.teeth(end),ei.lips(end));
    if idxfound == size(obj.codes_,1)
        fprintf('\n');
    end
    
end