%%%蒙特卡洛抽样%%%
%I类车(800)，夜晚充电，私家车；II类车(400)，夜晚充电，网约车；III类车(800)，白天充电，上班族。
%抽样得到不同类型的电动汽车，并分配至充电站
%其中前1000次为历史电动汽车数据，第1001次为仿真过程中的实际电动汽车数据
clear
clc
rng(1);%固定随机数种子(伪随机：保证蒙特卡洛抽样的结果稳定)
Ta_EV1=normrnd(18,2,[1001,1000]);%电动汽车1的停车时间抽样
Tl_EV1=normrnd(8,2,[1001,1000]);%电动汽车1的离开时间抽样
S0_EV1=unifrnd(0.4,0.6,[1001,1000]);%电动汽车1的初始SOC抽样
Ta_EV2=normrnd(21,1,[1001,500]);
Tl_EV2=normrnd(7,1,[1001,500]);
S0_EV2=unifrnd(0.2,0.4,[1001,500]);
Ta_EV3=normrnd(9,sqrt(2),[1001,1000]);
Tl_EV3=normrnd(17,sqrt(2),[1001,1000]);
S0_EV3=unifrnd(0.4,0.6,[1001,1000]);
EV1_CS1=round(unifrnd(180,220,[1001,1]));%充电站1中I类车的数量
EV1_CS2=round(unifrnd(180,220,[1001,1]));%充电站2中I类车的数量
EV1_CS3=zeros(1001,1);%充电站3中I类车的数量
EV1_CS4=round(unifrnd(380,420,[1001,1]));%充电站4中I类车的数量
EV2_CS1=round(unifrnd(190,210,[1001,1]));
EV2_CS2=round(unifrnd(80,120,[1001,1]));
EV2_CS3=round(unifrnd(90,110,[1001,1]));
EV2_CS4=zeros(1001,1);
EV3_CS1=zeros(1001,1);
EV3_CS2=round(unifrnd(380,420,[1001,1]));
EV3_CS3=round(unifrnd(380,420,[1001,1]));
EV3_CS4=zeros(1001,1);
%数据修正，从08:00开始计算，超出范围的进行截尾(截尾正态分布)
Ta_EV1=Ta_EV1-8;Tl_EV1=Tl_EV1+24-8;Ta_EV2=Ta_EV2-8;Tl_EV2=Tl_EV2+24-8;Ta_EV3=Ta_EV3-8;Tl_EV3=Tl_EV3-8;S0_EV1=32*S0_EV1;S0_EV2=32*S0_EV2;S0_EV3=32*S0_EV3;
DA_Ta_EV1=ceil(4*Ta_EV1(1:1000,:));DA_Ta_EV2=ceil(4*Ta_EV2(1:1000,:));DA_Ta_EV3=ceil(4*Ta_EV3(1:1000,:));%日前离散化
DA_Tl_EV1=floor(4*Tl_EV1(1:1000,:));DA_Tl_EV2=floor(4*Tl_EV2(1:1000,:));DA_Tl_EV3=floor(4*Tl_EV3(1:1000,:));
DA_S0_EV1=S0_EV1(1:1000,:);DA_S0_EV2=S0_EV2(1:1000,:);DA_S0_EV3=S0_EV3(1:1000,:);
RT_Ta_EV1=ceil(4*Ta_EV1(1001,:));RT_Ta_EV2=ceil(4*Ta_EV2(1001,:));RT_Ta_EV3=ceil(4*Ta_EV3(1001,:));%实时离散化
RT_Tl_EV1=floor(4*Tl_EV1(1001,:));RT_Tl_EV2=floor(4*Tl_EV2(1001,:));RT_Tl_EV3=floor(4*Tl_EV3(1001,:));
RT_S0_EV1=S0_EV1(1001,:);RT_S0_EV2=S0_EV2(1001,:);RT_S0_EV3=S0_EV3(1001,:);
DA_Ta_EV1(find(DA_Ta_EV1<1))=1;DA_Ta_EV2(find(DA_Ta_EV2<1))=1;DA_Ta_EV3(find(DA_Ta_EV3<1))=1;%Ta截首
RT_Ta_EV1(find(RT_Ta_EV1<1))=1;RT_Ta_EV2(find(RT_Ta_EV2<1))=1;RT_Ta_EV3(find(RT_Ta_EV3<1))=1;
DA_Ta_EV1(find(DA_Ta_EV1>96))=96;DA_Ta_EV2(find(DA_Ta_EV2>96))=96;DA_Ta_EV3(find(DA_Ta_EV3>96))=96;%Ta截尾
RT_Ta_EV1(find(RT_Ta_EV1>96))=96;RT_Ta_EV2(find(RT_Ta_EV2>96))=96;RT_Ta_EV3(find(RT_Ta_EV3>96))=96;
DA_Tl_EV1(find(DA_Tl_EV1<1))=1;DA_Tl_EV2(find(DA_Tl_EV2<1))=1;DA_Tl_EV3(find(DA_Tl_EV3<1))=1;%Tl截首
RT_Tl_EV1(find(RT_Tl_EV1<1))=1;RT_Tl_EV2(find(RT_Tl_EV2<1))=1;RT_Tl_EV3(find(RT_Tl_EV3<1))=1;
DA_Tl_EV1(find(DA_Tl_EV1>96))=96;DA_Tl_EV2(find(DA_Tl_EV2>96))=96;DA_Tl_EV3(find(DA_Tl_EV3>96))=96;%Tl截尾
RT_Tl_EV1(find(RT_Tl_EV1>96))=96;RT_Tl_EV2(find(RT_Tl_EV2>96))=96;RT_Tl_EV3(find(RT_Tl_EV3>96))=96;
index=find(0.25*6.6*(DA_Tl_EV1-DA_Ta_EV1+1)<32*0.9-DA_S0_EV1);%日前数据修正，若不合理则赋期望值
for i=1:length(index)
    DA_Ta_EV1(index(i))=40;DA_Tl_EV1(index(i))=96;
end
index=find(6.6*(DA_Tl_EV2-DA_Ta_EV2+1)<32*0.9-DA_S0_EV2);
for i=1:length(index)
    DA_Ta_EV2(index(i))=52;DA_Tl_EV2(index(i))=92;
end
index=find(6.6*(DA_Tl_EV3-DA_Ta_EV3+1)<32*0.9-DA_S0_EV3);
for i=1:length(index)
    DA_Ta_EV3(index(i))=4;DA_Tl_EV3(index(i))=36;
end
index=find(0.25*6.6*(RT_Tl_EV1-RT_Ta_EV1+1)<32*0.9-RT_S0_EV1);%实时数据修正，若不合理则赋期望值
for i=1:length(index)
    RT_Ta_EV1(index(i))=40;RT_Tl_EV1(index(i))=96;
end
index=find(0.25*6.6*(RT_Tl_EV2-RT_Ta_EV2+1)<32*0.9-RT_S0_EV2);
for i=1:length(index)
    RT_Ta_EV2(index(i))=52;RT_Tl_EV2(index(i))=92;
end
index=find(0.25*6.6*(RT_Tl_EV3-RT_Ta_EV3+1)<32*0.9-RT_S0_EV3);
for i=1:length(index)
    RT_Ta_EV3(index(i))=4;RT_Tl_EV3(index(i))=36;
end
%%%车辆分配%%%
for i=1:1000
    data_CS1(i).Ta=[DA_Ta_EV1(i,1:EV1_CS1(i)),DA_Ta_EV2(i,1:EV2_CS1(i)),DA_Ta_EV3(i,1:EV3_CS1(i))];
    data_CS2(i).Ta=[DA_Ta_EV1(i,1+EV1_CS1(i):EV1_CS1(i)+EV1_CS2(i)),DA_Ta_EV2(i,1+EV2_CS1(i):EV2_CS1(i)+EV2_CS2(i)),DA_Ta_EV3(i,1+EV3_CS1(i):EV3_CS1(i)+EV3_CS2(i))];
    data_CS3(i).Ta=[DA_Ta_EV1(i,1+EV1_CS1(i)+EV1_CS2(i):EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i)),DA_Ta_EV2(i,1+EV2_CS1(i)+EV2_CS2(i):EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i)),DA_Ta_EV3(i,1+EV3_CS1(i)+EV3_CS2(i):EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i))];
    data_CS4(i).Ta=[DA_Ta_EV1(i,1+EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i):EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i)+EV1_CS4(i)),DA_Ta_EV2(i,1+EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i):EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i)+EV2_CS4(i)),DA_Ta_EV3(i,1+EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i):EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i)+EV3_CS4(i))];
    data_CS1(i).Tl=[DA_Tl_EV1(i,1:EV1_CS1(i)),DA_Tl_EV2(i,1:EV2_CS1(i)),DA_Tl_EV3(i,1:EV3_CS1(i))];
    data_CS2(i).Tl=[DA_Tl_EV1(i,1+EV1_CS1(i):EV1_CS1(i)+EV1_CS2(i)),DA_Tl_EV2(i,1+EV2_CS1(i):EV2_CS1(i)+EV2_CS2(i)),DA_Tl_EV3(i,1+EV3_CS1(i):EV3_CS1(i)+EV3_CS2(i))];
    data_CS3(i).Tl=[DA_Tl_EV1(i,1+EV1_CS1(i)+EV1_CS2(i):EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i)),DA_Tl_EV2(i,1+EV2_CS1(i)+EV2_CS2(i):EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i)),DA_Tl_EV3(i,1+EV3_CS1(i)+EV3_CS2(i):EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i))];
    data_CS4(i).Tl=[DA_Tl_EV1(i,1+EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i):EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i)+EV1_CS4(i)),DA_Tl_EV2(i,1+EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i):EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i)+EV2_CS4(i)),DA_Tl_EV3(i,1+EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i):EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i)+EV3_CS4(i))];
    data_CS1(i).S0=[DA_S0_EV1(i,1:EV1_CS1(i)),DA_S0_EV2(i,1:EV2_CS1(i)),DA_S0_EV3(i,1:EV3_CS1(i))];
    data_CS2(i).S0=[DA_S0_EV1(i,1+EV1_CS1(i):EV1_CS1(i)+EV1_CS2(i)),DA_S0_EV2(i,1+EV2_CS1(i):EV2_CS1(i)+EV2_CS2(i)),DA_S0_EV3(i,1+EV3_CS1(i):EV3_CS1(i)+EV3_CS2(i))];
    data_CS3(i).S0=[DA_S0_EV1(i,1+EV1_CS1(i)+EV1_CS2(i):EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i)),DA_S0_EV2(i,1+EV2_CS1(i)+EV2_CS2(i):EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i)),DA_S0_EV3(i,1+EV3_CS1(i)+EV3_CS2(i):EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i))];
    data_CS4(i).S0=[DA_S0_EV1(i,1+EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i):EV1_CS1(i)+EV1_CS2(i)+EV1_CS3(i)+EV1_CS4(i)),DA_S0_EV2(i,1+EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i):EV2_CS1(i)+EV2_CS2(i)+EV2_CS3(i)+EV2_CS4(i)),DA_S0_EV3(i,1+EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i):EV3_CS1(i)+EV3_CS2(i)+EV3_CS3(i)+EV3_CS4(i))];
end
data_CS1(1001).Ta=[RT_Ta_EV1(1:EV1_CS1(1001)),RT_Ta_EV2(1:EV2_CS1(1001)),RT_Ta_EV3(1:EV3_CS1(1001))];
data_CS2(1001).Ta=[RT_Ta_EV1(1+EV1_CS1(1001):EV1_CS1(1001)+EV1_CS2(1001)),RT_Ta_EV2(1+EV2_CS1(1001):EV2_CS1(1001)+EV2_CS2(1001)),RT_Ta_EV3(1+EV3_CS1(1001):EV3_CS1(1001)+EV3_CS2(1001))];
data_CS3(1001).Ta=[RT_Ta_EV1(1+EV1_CS1(1001)+EV1_CS2(1001):EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001)),RT_Ta_EV2(1+EV2_CS1(1001)+EV2_CS2(1001):EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001)),RT_Ta_EV3(1+EV3_CS1(1001)+EV3_CS2(1001):EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001))];
data_CS4(1001).Ta=[RT_Ta_EV1(1+EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001):EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001)+EV1_CS4(1001)),RT_Ta_EV2(1+EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001):EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001)+EV2_CS4(1001)),RT_Ta_EV3(1+EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001):EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001)+EV3_CS4(1001))];
data_CS1(1001).Tl=[RT_Tl_EV1(1:EV1_CS1(1001)),RT_Tl_EV2(1:EV2_CS1(1001)),RT_Tl_EV3(1:EV3_CS1(1001))];
data_CS2(1001).Tl=[RT_Tl_EV1(1+EV1_CS1(1001):EV1_CS1(1001)+EV1_CS2(1001)),RT_Tl_EV2(1+EV2_CS1(1001):EV2_CS1(1001)+EV2_CS2(1001)),RT_Tl_EV3(1+EV3_CS1(1001):EV3_CS1(1001)+EV3_CS2(1001))];
data_CS3(1001).Tl=[RT_Tl_EV1(1+EV1_CS1(1001)+EV1_CS2(1001):EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001)),RT_Tl_EV2(1+EV2_CS1(1001)+EV2_CS2(1001):EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001)),RT_Tl_EV3(1+EV3_CS1(1001)+EV3_CS2(1001):EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001))];
data_CS4(1001).Tl=[RT_Tl_EV1(1+EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001):EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001)+EV1_CS4(1001)),RT_Tl_EV2(1+EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001):EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001)+EV2_CS4(1001)),RT_Tl_EV3(1+EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001):EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001)+EV3_CS4(1001))];
data_CS1(1001).S0=[RT_S0_EV1(1:EV1_CS1(1001)),RT_S0_EV2(1:EV2_CS1(1001)),RT_S0_EV3(1:EV3_CS1(1001))];
data_CS2(1001).S0=[RT_S0_EV1(1+EV1_CS1(1001):EV1_CS1(1001)+EV1_CS2(1001)),RT_S0_EV2(1+EV2_CS1(1001):EV2_CS1(1001)+EV2_CS2(1001)),RT_S0_EV3(1+EV3_CS1(1001):EV3_CS1(1001)+EV3_CS2(1001))];
data_CS3(1001).S0=[RT_S0_EV1(1+EV1_CS1(1001)+EV1_CS2(1001):EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001)),RT_S0_EV2(1+EV2_CS1(1001)+EV2_CS2(1001):EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001)),RT_S0_EV3(1+EV3_CS1(1001)+EV3_CS2(1001):EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001))];
data_CS4(1001).S0=[RT_S0_EV1(1+EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001):EV1_CS1(1001)+EV1_CS2(1001)+EV1_CS3(1001)+EV1_CS4(1001)),RT_S0_EV2(1+EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001):EV2_CS1(1001)+EV2_CS2(1001)+EV2_CS3(1001)+EV2_CS4(1001)),RT_S0_EV3(1+EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001):EV3_CS1(1001)+EV3_CS2(1001)+EV3_CS3(1001)+EV3_CS4(1001))];
save('data_EV','data_CS1','data_CS2','data_CS3','data_CS4');%电动汽车抽样数据