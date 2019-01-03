function [asset_list,type_list,bcode_list,wcode_list,exchange_list,...
          trading_hours,contract_size,tick_size,trading_break,...
          margin_rate,transaction_cost,asset_list_map] = getassetmaptable()
%
%asset name
asset_list={'eqindex_300';'eqindex_50';'eqindex_500';...
            'govtbond_5y';'govtbond_10y';...
            'gold';'silver';...
            'copper';'aluminum';'zinc';'lead';'nickel';...
            'pta';'lldpe';'pp';'methanol';'thermal coal';'crude oil';...
            'sugar';'cotton';'corn';'egg';...
            'soybean';'soymeal';'soybean oil';'palm oil';...
            'rapeseed oil';'rapeseed meal';...
            'apple';...
            'rubber';...
            'coke';'coking coal';'deformed bar';'iron ore';'hotroiled coil';'glass'};
%
%asset type
type_list={'eqindex';'eqindex';'eqindex';...
           'govtbond';'govtbond';...
           'preciousmetal';'preciousmetal';...
           'basemetal';'basemetal';'basemetal';'basemetal';'basemetal';...
           'energy';'energy';'energy';'energy';'energy';'energy';...
           'agriculture';'agriculture';'agriculture';'agriculture';...
           'agriculture';'agriculture';'agriculture';'agriculture';...
           'agriculture';'agriculture';...
           'agriculture';...
           'agriculture';...
           'industrial';'industrial';'industrial';'industrial';'industrial';'industrial';};
%
%bloomberg code
bcode_list={'IFB';'FFB';'FFD';...
            'TFC';'TFT';...
            'AUA';'SAI';...
            'CU';'AA';'ZNA';'PBL';'XII';...
            'PT';'POL';'PYL';'ZME';'TRC';'SCP';...
            'CB';'VV';'AC';'DCE';...
            'AK';'AE';'SH';'PAL';...
            'ZRO';'ZRR';...
            'APW';...
            'RT';...
            'KEE';'CKC';'RBT';'IOE';'ROC';'FGL'};
%
%wind code
wcode_list={'IF';'IH';'IC';...
            'TF';'T';...
            'AU';'AG';...
            'CU';'AL';'ZN';'PB';'NI';...
            'TA';'L';'PP';'MA';'ZC';'SC';...
            'SR';'CF';'C';'JD';...
            'A';'M';'Y';'P';...
            'OI';'RM';...
            'AP';...
            'RU';...
            'J';'JM';'RB';'I';'HC';'FG'};
%
%exchange code
exchange_list={'.CFE';'.CFE';'.CFE';...
               '.CFE';'.CFE';...
               '.SHF';'.SHF';...
               '.SHF';'.SHF';'.SHF';'.SHF';'.SHF';...
               '.CZC';'.DCE';'.DCE';'.CZC';'.CZC';'.SHF';...
               '.CZC';'.CZC';'.DCE';'.DCE';...
               '.DCE';'.DCE';'.DCE';'.DCE';...
               '.CZC';'.CZC';...
               '.CZC';...
               '.SHF';...
               '.DCE';'.DCE';'.SHF';'.DCE';'.SHF';'.CZC'};
%
%trading hours
trading_hours={'09:30-11:30','13:00-15:00','n/a';%eqindex_300
               '09:30-11:30','13:00-15:00','n/a';%eqindex_50
               '09:30-11:30','13:00-15:00','n/a';%eqindex_500
               '09:15-11:30','13:00-15:15','n/a';%govtbond_5y
               '09:15-11:30','13:00-15:15','n/a';%govtbond_10y
               '09:00-11:30','13:30-15:00','21:00-02:30';%gold
               '09:00-11:30','13:30-15:00','21:00-02:30';%silver
               '09:00-11:30','13:30-15:00','21:00-01:00';%copper
               '09:00-11:30','13:30-15:00','21:00-01:00';%aluminum
               '09:00-11:30','13:30-15:00','21:00-01:00';%zinc
               '09:00-11:30','13:30-15:00','21:00-01:00';%lead
               '09:00-11:30','13:30-15:00','21:00-01:00';%nickel
               '09:00-11:30','13:30-15:00','21:00-01:00';%pta
               '09:00-11:30','13:30-15:00','n/a';%lldpe
               '09:00-11:30','13:30-15:00','n/a';%pp
               '09:00-11:30','13:30-15:00','21:00-23:30';%methanol
               '09:00-11:30','13:30-15:00','21:00-23:00';%thermal coal
               '09:00-11:30','13:30-15:00','21:00-02:30';%crude oil
               '09:00-11:30','13:30-15:00','21:00-01:00';%sugar
               '09:00-11:30','13:30-15:00','21:00-23:30';%cotton
               '09:00-11:30','13:30-15:00','n/a';%corn
               '09:00-11:30','13:30-15:00','n/a';%egg
               '09:00-11:30','13:30-15:00','21:00-23:30';%soybean
               '09:00-11:30','13:30-15:00','21:00-23:30';%soymeal
               '09:00-11:30','13:30-15:00','21:00-23:30';%soybean oil
               '09:00-11:30','13:30-15:00','21:00-23:30';%palm oil
               '09:00-11:30','13:30-15:00','21:00-23:30';%rapeseed oil
               '09:00-11:30','13:30-15:00','21:00-23:30';%rapeseed meal
               '09:00-11:30','13:30-15:00','n/a';%apple
               '09:00-11:30','13:30-15:00','21:00-23:00';%rubber
               '09:00-11:30','13:30-15:00','21:00-23:30';%coke
               '09:00-11:30','13:30-15:00','21:00-23:30';%coking coal
               '09:00-11:30','13:30-15:00','21:00-23:00';%deformed bar
               '09:00-11:30','13:30-15:00','21:00-23:30';%iron ore
               '09:00-11:30','13:30-15:00','21:00-23:00';%hot-roiled coil
               '09:00-11:30','13:30-15:00','21:00-23:30'};%glass
 %             
 %trading break
 trading_break={'n/a';%eqindex_300
                'n/a';%eqindex_50
                'n/a';%eqindex_500
                'n/a';%govtbond_5y
                'n/a';%govtbond_10y
                '10:15-10:30';%gold
                '10:15-10:30';%silver
                '10:15-10:30';%copper
                '10:15-10:30';%aluminum
                '10:15-10:30';%zinc
                '10:15-10:30';%lead
                '10:15-10:30';%nickel
                '10:15-10:30';%pta
                '10:15-10:30';%lldpe
                '10:15-10:30';%pp
                '10:15-10:30';%methanol
                '10:15-10:30';%thermal coal
                '10:15-10:30';%crude oil
                '10:15-10:30';%sugar
                '10:15-10:30';%cotton
                '10:15-10:30';%corn
                '10:15-10:30';%egg
                '10:15-10:30';%soybean
                '10:15-10:30';%soymeal
                '10:15-10:30';%soybean oil
                '10:15-10:30';%palm oil
                '10:15-10:30';%rapeseed oil
                '10:15-10:30';%rapeseed meal
                '10:15-10:30';%apple
                '10:15-10:30';%rubber
                '10:15-10:30';%coke
                '10:15-10:30';%coking coal
                '10:15-10:30';%deformed bar
                '10:15-10:30';%iron ore
                '10:15-10:30';%hot-rolled coil
                '10:15-10:30'};%glass
%
%contract size
contract_size=[300;300;200;...%eqindex_300;eqindex_50;eqindex_500
               10000;10000;...%govtbond_5y;govtbond_10y
               1000;15;...%gold,silver
               5;5;5;5;1;...%copper;aluminum;zinc;lead;nickel
               5;5;5;10;100;1000;...%pta;lldpe;pp;methanol;thermal coal;crude oil
               10;5;10;5;...%sugar;cotton;corn;egg
               10;10;10;10;...%soybean;soymeal;soybean oil;palm oil
               10;10;...%rapeseed oil;rapeseed meal
               10;...%apple
               10;...%rubber
               100;60;10;100;10;20];%coke;coking coal;deformed bar;iron ore;glass
%
%tick size
tick_size=[0.2;0.2;0.2;...%eqindex_300;eqindex_50;eqindex_500
           0.005;0.005;...%govtbond_5y;govtbond_10y
           0.05;1;...%gold,silver
           10;5;5;5;10;...%copper;aluminum;zinc;lead;nickel
           2;5;1;1;0.2;0.1;...%pta;lldpe;pp;methanol;thermal coal;crude oil
           1;5;1;1;...%sugar;cotton;corn;egg
           1;1;2;2;...%soybean;soymeal;soybean oil;palm oil
           2;1;...%rapeseed oil;rapeseed meal
           1;...%apple
           5;...%rubber
           0.5;0.5;1;0.5;1;1];%coke;coking coal;deformed bar;iron ore;glass

%
%margin rate
margin_rate = [0.41;0.41;0.41;...%eqindex_300;eqindex_50;eqindex_500
               0.025;0.025;...%govtbond_5y;govtbond_10y
               0.11;0.14;...%gold,silver
               0.13;0.1;0.1;0.1;0.13;...%copper;aluminum;zinc;lead;nickel
               0.12;0.12;0.12;0.12;0.14;0.12;...%pta;lldpe;pp;methanol;thermal coal;crude oil
               0.1;0.12;0.11;0.12;...%sugar;cotton;corn;egg
               0.11;0.12;0.12;0.12;...%soybean;soymeal;soybean oil;palm oil
               0.08;0.12;...%rapeseed oil;rapeseed meal
               0.1;...%apple
               0.12;...%rubber
               0.2;0.2;0.13;0.15;0.08;0.12];%coke;coking coal;deformed bar;iron ore;glass

%
%transaction cost
transaction_cost = {0.000023,0.0023,'REL';%eqindex_300
    0.000023,0.0023,'REL';%eqindex_50
    0.000023,0.0023,'REL';%eqindex_500
    3,3,'ABS';%govtbond_5y
    3,3,'ABS';%govtbond_10y
    10,10,'ABS';%gold
    0.00005,0.00005,'REL';%silver
    0.00005,0.00005,'REL';%copper
    3,3,'ABS';%alumium
    3,3,'ABS';%zinc
    0.00004,0.00004,'REL';%lead
    6,6,'ABS';%nickel
    3,3,'ABS';%PTA
    2,2,'ABS';%LLDPE
    0.00006,0.00024,'REL';%PP
    2,6,'ABS';%methanol
    6,30,'ABS';%thermal coal
    20,20,'ABS';%crude oil
    3,3,'ABS';%sugar
    6,6,'ABS';%cotton
    1.2,1.2,'ABS';%corn
    0.00015,0.00015,'REL';%egg
    2,2,'ABS';%soybean
    1.5,1.5,'ABS';%soymeal
    2.5,2.5,'ABS';%soybean oil
    2.5,2.5,'ABS';%palm oil
    2.5,2,'ABS';%rapeseed oil
    3,2,'ABS';%rapeseed meak
    3,3,'ABS';%apple
    0.000045,0.000045,'REL';%rubber
    0.00012,0.00072,'REL';%coke
    0.00012,0.00072,'REL';%coking coal
    0.0001,0.0001,'REL';%deformed bar
    0.00012,0.0003,'REL';%iron ore
    0.0001,0.0001,'REL';%hot-rolled coil
    3,12,'ABS'};%glass

asset_list_map ={'CSI300';'SSE50';'CSI500';...
            'GovtBond5y';'GovtBond10y';...
            'Gold';'Silver';...
            'Copper';'Aluminum';'Zinc';'Lead';'Nickel';...
            'PTA';'LLDPE';'PP';'Methanol';'ThermalCoal';'Crude';...
            'Sugar';'Cotton';'Corn';'Egg';...
            'Soybean';'Soymeal';'SoybeanOil';'PalmOil';...
            'RapeseedOil';'RapeseedMeal';...
            'Apple';...
            'Rubber';...
            'Coke';'CokingCoal';'Rebar';'IronOre';'HotRolledCoil';'Glass'};


    
end

