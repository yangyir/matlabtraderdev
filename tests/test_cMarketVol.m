%test_cMarketVol
%%
%case1: flatvol
flatvol = CreateObj('flatvol','VOL','AssetName','RB1701',...
                   'VolName','MARKETVOL','VolType','STRIKEVOL',...
                   'Strikes',1.0,'Expiries','2017-01-16','Vols',0.12,...
                   'ReferenceSpot',1.0);

strikes = 0.6:0.1:1.5;
vols = zeros(1,length(strikes));

for i = 1:length(strikes)
    vols(i) = flatvol.getVol(strikes(i),datenum('2017-01-16'));
end

close all;
plot(strikes,vols);
xlabel('strike');ylabel('vol');title('flat vol case');

%%
%case2: smilevol, i.e. only 1 slice
strikes = [1.0,1.1];
vols = [0.3,0.4];
smilevol = CreateObj('flatvol','VOL','AssetName','RB1701',...
                   'VolName','MARKETVOL','VolType','STRIKEVOL',...
                   'Strikes',strikes,'Expiries','2017-01-16','Vols',vols,...
                   'ReferenceSpot',1.0,...
                   'InterpolationMethod','next');

strikes = 0.85:0.01:1.15;
vols = zeros(1,length(strikes));

for i = 1:length(strikes)
    vols(i) = smilevol.getVol(strikes(i),datenum('2017-01-16'));
end
figure(2);
plot(strikes,vols);
xlabel('strike');ylabel('vol');title('flat vol case');

