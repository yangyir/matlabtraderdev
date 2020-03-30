output_count = zeros(size(idxfractalb1,1),7);
for i = 1:size(idxfractalb1,1)
    j = idxfractalb1(i,1);
    [output_count(i,1),output_count(i,2),output_count(i,3),output_count(i,4),output_count(i,5),output_count(i,6),output_count(i,7)] = fractal_countb(p(1:j,:),idxHH,nfractal,lips,teeth,jaw);
end
%% long trade check
idx1 = 1301;
idx2 = idx1;
for i = idx1:size(p,1)
    if p(i,5) - lips(i)< -0.002
        idx2 = i;
        break
    end
end
idx1 = find(idxHH(1:idx1)==1,1,'last');
temp = timeseries_window(res,'fromdate',p(idx1-4,1),'todate',p(idx2+5,1));
tools_technicalplot2(temp);
%%
output_count_s = zeros(size(idxfractals1,1),7);
for i = 1:size(idxfractals1,1)
    j = idxfractals1(i,1);
    [output_count_s(i,1),output_count_s(i,2),output_count_s(i,3),output_count_s(i,4),output_count_s(i,5),output_count_s(i,6),output_count_s(i,7)] = fractal_counts(p(1:j,:),idxLL,nfractal,lips,teeth,jaw);
end
%% short trade check
idx1 = 1934;
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