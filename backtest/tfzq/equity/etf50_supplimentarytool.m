output_count = zeros(size(idxfractalb1,1),7);
for i = 1:size(idxfractalb1,1)
    j = idxfractalb1(i,1);
    [output_count(i,1),output_count(i,2),output_count(i,3),output_count(i,4),output_count(i,5),output_count(i,6),output_count(i,7)] = fractal_countb(p(1:j,:),idxHH,nfractal,lips,teeth,jaw);
end
%% long trade check
idx1 = 1205;
idx2 = idx1;
for i = idx1:size(p,1)
    if p(i,5) - lips(i)< -0.002
        idx2 = i;
        break
    end
end
idx11 = find(idxHH(1:idx1)==1,1,'last');
temp = timeseries_window(res,'fromdate',p(idx11-4,1),'todate',p(min(idx2+5,size(p,1)),1));
tools_technicalplot2(temp,1,num2str(idx1));
%
b1type = idxfractalb1(idxfractalb1(:,1)==idx1,2);
extrainfo = struct('px',px(1:idx1,:),'ss',ss(1:idx1),'sc',sc(1:idx1),...
    'lvlup',lvlup(1:idx1),'lvldn',lvldn(1:idx1),...
    'idxhh',idxHH(1:idx1),'hh',HH(1:idx1),'ll',LL(1:idx1),...
    'lips',lips(1:idx1),'teeth',teeth(1:idx1),'jaw',jaw(1:idx1),...
    'wad',wad(1:idx1));
fractal_filterb1_singleentry(b1type,nfractal,extrainfo)


%%
output_count_s = zeros(size(idxfractals1,1),7);
for i = 1:size(idxfractals1,1)
    j = idxfractals1(i,1);
    [output_count_s(i,1),output_count_s(i,2),output_count_s(i,3),output_count_s(i,4),output_count_s(i,5),output_count_s(i,6),output_count_s(i,7)] = fractal_counts(p(1:j,:),idxLL,nfractal,lips,teeth,jaw);
end
%% short trade check
idx1 = 376;
idx2 = idx1;
for i = idx1:size(p,1)
    if p(i,5) > lips(i) > 0.002
        idx2 = i;
        break
    end
end
idx11 = find(idxLL(1:idx1)==-1,1,'last');
temp = timeseries_window(res,'fromdate',p(idx11-4,1),'todate',p(min(size(p,1),idx2+5),1));
tools_technicalplot2(temp,1,num2str(idx1));
%%
output1 = zeros(126,1);
output2 = cell(126,1);
for i = 1:126

idx1 = idxfractals1(i,1);
s1type = idxfractals1(i,2);
extrainfo = struct('px',px(1:idx1,:),'bs',bs(1:idx1),'bc',bc(1:idx1),...
    'lvlup',lvlup(1:idx1),'lvldn',lvldn(1:idx1),...
    'idxll',idxLL(1:idx1),'ll',LL(1:idx1),...
    'lips',lips(1:idx1),'teeth',teeth(1:idx1),'jaw',jaw(1:idx1),...
    'wad',wad(1:idx1));
temp = fractal_filters1_singleentry(s1type,nfractal,extrainfo);
output1(i) = temp.use;
output2{i} = temp.comment;
end