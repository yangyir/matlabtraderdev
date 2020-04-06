p = cDataFileIO.loadDataFromTxtFile('rb2005_daily.txt');
fprintf('last record date:%s\n',datestr(p(end,1)));
%
nfractal = 2;
res = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0.001);
res(:,1) = x2mdate(res(:,1));
px = res(:,1:5);
idxHH = res(:,6);idxLL = res(:,7);HH = res(:,8);LL = res(:,9);
jaw = res(:,10);teeth = res(:,11);lips = res(:,12);
bs = res(:,13);ss = res(:,14);
lvlup = res(:,15);lvldn = res(:,16);
bc = res(:,17);sc = res(:,18);
wad = williamsad(px);
%%
flagweakb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','weak');
flagmediumb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','medium');
flagstrongb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','strong');
flagb1 = flagweakb1 + flagmediumb1 + flagstrongb1;
%1.weak;2.medium;3.strong
idxfractalb1 = [find(flagb1==1),ones(length(find(flagb1==1)),1);...
    find(flagb1==2),2*ones(length(find(flagb1==2)),1);...
    find(flagb1==3),3*ones(length(find(flagb1==3)),1)];
idxfractalb1 = sortrows(idxfractalb1);
%% long trade check
clc;
idx1 = 201;
idx2 = idx1;
for i = idx1:size(p,1)
    if p(i,5) - lips(i)< -0.002
        idx2 = i;
        break
    end
end
idx11 = find(idxHH(1:idx1)==1,1,'last');
temp = timeseries_window(res,'fromdate',p(idx11-4,1),'todate',p(idx2+5,1));
tools_technicalplot2(temp,1,num2str(idx1));
%
b1type = idxfractalb1(idxfractalb1(:,1)==idx1,2);
extrainfo = struct('px',px(1:idx1,:),'ss',ss(1:idx1),'sc',sc(1:idx1),...
    'lvlup',lvlup(1:idx1),'lvldn',lvldn(1:idx1),...
    'idxhh',idxHH(1:idx1),'hh',HH(1:idx1),...
    'lips',lips(1:idx1),'teeth',teeth(1:idx1),'jaw',jaw(1:idx1),...
    'wad',wad(1:idx1));
[~,~,~,nkaboveteeth2,nkfromhh,teethjawcrossed] = fractal_countb(px(1:idx1,:),idxHH(1:idx1),nfractal,lips(1:idx1),teeth(1:idx1),jaw(1:idx1));
op = fractal_filterb1_singleentry(b1type,nfractal,extrainfo);
fprintf('breach type:%s\n',num2str(b1type));
fprintf('nkaboveteeth:%s\n',num2str(nkaboveteeth2));
fprintf('nkfromhh:%s\n',num2str(nkfromhh));
fprintf('teethjawcrossed:%s\n',num2str(teethjawcrossed));
fprintf('use:%s\n',num2str(op.use));
fprintf('comment:%s\n',op.comment);
%%
flagweaks1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','weak');
flagmediums1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','medium');
flagstrongs1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','strong');
flags1 = flagweaks1 + flagmediums1 + flagstrongs1;
%1.weak;2.medium;3.strong
idxfractals1 = [find(flags1==1),ones(length(find(flags1==1)),1);...
    find(flags1==2),2*ones(length(find(flags1==2)),1);...
    find(flags1==3),3*ones(length(find(flags1==3)),1)];
idxfractals1 = sortrows(idxfractals1);
%%
clc;
idx1 = 218;
idx2 = idx1;
for i = idx1:size(p,1)
    if p(i,5) - lips(i) > -0.002
        idx2 = i;
        break
    end
end
idx11 = find(idxLL(1:idx1)==-1,1,'last');
temp = timeseries_window(res,'fromdate',p(idx11-4,1),'todate',p(min(idx2+5,size(p,1)),1));
tools_technicalplot2(temp,1,num2str(idx1));
%
s1type = idxfractals1(idxfractals1(:,1)==idx1,2);
extrainfo = struct('px',px(1:idx1,:),'bs',bs(1:idx1),'bc',bc(1:idx1),...
    'lvlup',lvlup(1:idx1),'lvldn',lvldn(1:idx1),...
    'idxll',idxLL(1:idx1),'ll',LL(1:idx1),...
    'lips',lips(1:idx1),'teeth',teeth(1:idx1),'jaw',jaw(1:idx1),...
    'wad',wad(1:idx1));
[~,~,nkbelowlips,nkbelowteeth,nkfromll,teethjawcrossed] = fractal_counts(px(1:idx1,:),idxLL(1:idx1),nfractal,lips(1:idx1),teeth(1:idx1),jaw(1:idx1));
op = fractal_filters1_singleentry(s1type,nfractal,extrainfo);
fprintf('breach type:%s\n',num2str(s1type));
fprintf('nkbelowteeth:%s\n',num2str(nkbelowteeth));
fprintf('nkfromll:%s\n',num2str(nkfromll));
fprintf('teethjawcrossed:%s\n',num2str(teethjawcrossed));
fprintf('use:%s\n',num2str(op.use));
fprintf('comment:%s\n',op.comment);