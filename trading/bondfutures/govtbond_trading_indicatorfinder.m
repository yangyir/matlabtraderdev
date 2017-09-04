%input matrix yldSpreads
%column order of yldSpreads:
%date,px5y,px10y,yld5y,yld10y,yldSpread(bp),md5y,md10y

%%
%try to search a proper trading indicator (which shall be a mathematic
%formula output,i.e.ind(x),where x is the yldSpread itself,for yldSpread
%trading
%
%
%0.calculate the performance of the yldSpreads
%the performance is calculated based on the ratio between the duration as
%of the end of each trading day,e.g.on 13-Aug-2015,the duration of 5y and
%10y govtbond futures are 4.6 and 8.5 respectively based on their futures
%close prices as of 98.305 and 95.52.
perf = zeros(size(yldSpreads,1)-1,1);
constRatio = -10;
for i = 2:size(yldSpreads,1)
    pos10y = constRatio;
    dur5y = yldSpreads(i-1,7);
    dur10y = yldSpreads(i-1,8);
    pos5y = round(-pos10y*dur10y/dur5y);
    perf(i-1) = pos5y*(yldSpreads(i,2)-yldSpreads(i-1,2))+...
        pos10y*(yldSpreads(i,3)-yldSpreads(i-1,3));
    perf(i-1) = 1e4*perf(i-1);
end

%1.try different ind(x) as of the indicator
%1.1 try ind(x) = x,i.e.the indicator is the yldSpread itself
indicator1 = yldSpreads(1:end-1,6);
%1.2 try ind(x) = macd(x)
indicator2 = macd(yldSpreads(1:end-1,6));
%1.3 try ind(x) = rsindex(x)
indicator3 = rsindex(yldSpreads(1:end-1,6));
%1.4 try ind(x) = yld10y
indicator4 = yldSpreads(1:end-1,5);
%
%
%2.make up a matrix as of indicator vs.performance and then sort the matrix
%via indicator, plot the indicator aginast the cumulative performance as of
%the sum of the sorted performance
matrix1 = [indicator1,perf];
%sort the indicator 
matrix1 = sortrows(matrix1);
matrix1 = [matrix1(:,1),cumsum(matrix1(:,2))];
close all;
plot(matrix1(:,1),matrix1(:,2));


%%
idx = ~isnan(indicator2);
matrix2 = [indicator2(idx),perf(idx)];
%sort the indicator 
matrix2 = sortrows(matrix2);
matrix2 = [matrix2(:,1),cumsum(matrix2(:,2))];
close all;
plot(matrix2(:,1),matrix2(:,2));

%%
idx = ~isnan(indicator3);
matrix3 = [indicator3(idx),perf(idx)];
%sort the indicator 
matrix3 = sortrows(matrix3);
matrix3 = [matrix3(:,1),cumsum(matrix3(:,2))];
close all;
plot(matrix3(:,1),matrix3(:,2));

%%
idx = ~isnan(indicator4);
matrix4 = [indicator4(idx),perf(idx)];
%sort the indicator 
matrix4 = sortrows(matrix4);
matrix4 = [matrix4(:,1),cumsum(matrix4(:,2))];
close all;
plot(matrix4(:,1),matrix4(:,2));


