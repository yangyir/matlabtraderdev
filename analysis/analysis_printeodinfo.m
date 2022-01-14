function [] = analysis_printeodinfo(codes_list,names_list)
    if ischar(codes_list)
        codes_list = {codes_list};
    end
    ncodes = length(codes_list);
    
    %hard-coded parameters here:
    nfractal = 2;
    doplot = false;
    
    if ncodes > 0
        fprintf('\neod info:\n');
        fprintf('%10s %8s %8s %9s %12s %10s %10s %4s %4s %10s %10s %10s %10s %10s %15s\n',...
        'code','latest','close','change','date','hh','ll','bs','ss','levelup','leveldn','jaw','teeth','lips','name');
        dataformat = '%10s %8s %8s %8.2f%% %12s %10s %10s %4s %4s %10s %10s %10.3f %10.3f %10.3f %15s\n';
    else
        return
    end
    
    for i = 1:ncodes
        dailybar_i = cDataFileIO.loadDataFromTxtFile([codes_list{i},'_daily.txt']);
        [dailybarmat_i,dailybarstruct_i] = tools_technicalplot1(dailybar_i,nfractal,doplot);
        dailybarmat_i(:,1) = x2mdate(dailybarmat_i(:,1));
        latest = dailybarmat_i(end,5);
        preclose = dailybarmat_i(end-1,5);
        timet = datestr(dailybarmat_i(end,1),'yy-mm-dd');
        delta = (latest/preclose-1)*100;
        buysetup = dailybarstruct_i.bs(end);
        sellsetup = dailybarstruct_i.ss(end);
        levelup = dailybarstruct_i.lvlup(end);
        leveldn = dailybarstruct_i.lvldn(end);
        jaw = dailybarstruct_i.jaw(end);
        teeth = dailybarstruct_i.teeth(end);
        lips = dailybarstruct_i.lips(end);
        HH = dailybarstruct_i.hh(end);
        LL = dailybarstruct_i.ll(end);
        
        fprintf(dataformat,codes_list{i},num2str(latest),num2str(preclose),...
            delta,timet,...
            num2str(HH),num2str(LL),...
            num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
            jaw,teeth,lips,...
            names_list{i});
    end
end