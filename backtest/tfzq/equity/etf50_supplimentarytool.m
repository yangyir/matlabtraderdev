output_count = zeros(size(idxfractalb1,1),7);
for i = 1:size(idxfractalb1,1)
    j = idxfractalb1(i,1);
    [output_count(i,1),output_count(i,2),output_count(i,3),output_count(i,4),output_count(i,5),output_count(i,6),output_count(i,7)] = fractal_countb(p(1:j,:),idxHH,nfractal,lips,teeth,jaw);
end
%%
%%
idx1 = 132;
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