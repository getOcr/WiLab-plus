%实验2：raw=100 density=30 MCS=5 BW=40 v=40 
CRLB_15kHz_350B=[0.0124119841880696
0.137058866090798
0.147760063176208
1.33017921342868
0.0113237408315023
0.534903694102189
0.00555245282792109
0.00190357111907829
0.137058866090798
0.333679860587587
1.46948649493669
2.63185027092774
0.0139900764839247
2.94446935742101
0.0307719406271908
0.000156250605484290
0.0162735172832285
0.432105029601092
0.0162735172832285
0.439687465955604
0.00701254170954800
0.326779391936825
0.535051055260697
1.05574231602502
0.439687465955604
0.0520550329429666
0.801011233251080
0.192964798435454
0.616480422250324
0.856610945889182
0.819589436096457
0.871058140857846
0.00454310876655884
0.119949479568523];
d1 = [16.1418205805366
30.0280287069113
33.1019825913592
47.5934381385748
19.2097317137642
57.6017783524938
15.1513369414963
6.49486952090310
30.0280287069113
44.7601960225328
68.9220652853857
59.6514077831511
14.3590680682180
80.5421087718171
27.6612434434788
1.89195833722852
20.5324062058886
46.4528183615646
20.5324062058886
42.5531959114518
18.8044193372058
52.4912146516569
54.3198302677623
60.9498224570079
42.5531959114518
18.9123901513348
53.7536195742821
30.0684313236012
48.9660395771003
58.0420515393800
54.0298476711381
60.2072704197373
11.4487596063642
37.8692014790414];

CRLB_30kHz_350B=[2.32531080702730
0.00620599209403480
0.0685294330453990
0.0738800315881041
0.665089606714341
0.00566187041575117
0.267451847051094
0.00277622641396055
0.000951785559539148
1.95367520789632
0.0685294330453990
0.166839930293794
0.734743247468344
1.31592513546387
0.00699503824196234
1.90112911952203
1.47223467871050
0.0153859703135954
2.11512866890706
7.81253027421448e-05
0.00813675864161423
2.25294370583317
0.216052514800546
0.00813675864161423
0.219843732977802
0.00350627085477400
0.163389695968413
1.62536949609084
2.43110938402554
0.267525527630349
2.11512866890706
0.527871158012509
0.219843732977802
0.0260275164714833 ];
d2 = [113.981119489195
16.1418205805366
30.0280287069113
33.1019825913592
47.5934381385748
19.2097317137642
57.6017783524938
15.1513369414963
6.49486952090310
84.4996584517619
30.0280287069113
44.7601960225328
68.9220652853857
59.6514077831511
14.3590680682180
81.2790004697612
80.5421087718171
27.6612434434788
62.7773925930780
1.89195833722852
20.5324062058886
70.7877850669338
46.4528183615646
20.5324062058886
42.5531959114518
18.8044193372058
52.4912146516569
67.6752859035144
49.5864003701235
54.3198302677623
62.7773925930780
60.9498224570079
42.5531959114518
18.9123901513348];

% CRLB_60kHz_350B=[0.0150 0.0334 0.0752 0.1337 0.2063 ];
% d3 = [];

CRLB_15kHz_1000B = [0.0310299604701740
0.342647165226995
0.369400157940520
0.0283093520787559
1.33725923525547
0.0138811320698027
0.00475892779769574
0.342647165226995
0.834199651468968
0.0349751912098117
0.0769298515679769
0.000390626513710724
0.0406837932080712
1.08026257400273
0.0406837932080712
1.09921866488901
0.0175313542738700
0.816948479842062
1.33762763815174
2.63935579006254
1.09921866488901
0.130137582357417
2.00252808312770
0.482411996088634
1.54120105562581
2.14152736472295
2.04897359024114
2.17764535214462
0.0113577719163971
0.299873698921309
0.130678709016717
0.172414403816976
2.45721987425162
2.26109781109101
0.714060658484224
2.11603775140462
0.0202539534554211];
d4 = [16.1418205805366
30.0280287069113
33.1019825913592
19.2097317137642
57.6017783524938
15.1513369414963
6.49486952090310
30.0280287069113
44.7601960225328
14.3590680682180
27.6612434434788
1.89195833722852
20.5324062058886
46.4528183615646
20.5324062058886
42.5531959114518
18.8044193372058
52.4912146516569
54.3198302677623
60.9498224570079
42.5531959114518
18.9123901513348
53.7536195742821
30.0684313236012
48.9660395771003
58.0420515393800
54.0298476711381
60.2072704197373
11.4487596063642
37.8692014790414
27.9966980078170
33.4560501295455
51.1261712258681
42.4332881173809
37.5347469234405
35.5824240760926
18.9932194376633];

CRLB_30kHz_1000B = [0.0155149802350870
0.171323582613497
0.184700078970260
1.66272401678585
0.0141546760393779
0.668629617627736
0.00694056603490136
0.00237946389884787
0.171323582613497
0.417099825734484
1.83685811867086
0.0174875956049058
0.0384649257839884
0.000195313256855362
0.0203418966040356
0.540131287001365
0.0203418966040356
0.549609332444505
0.00876567713693500
0.408474239921031
0.668813819075872
1.31967789503127
0.549609332444505
0.0650687911787083
1.00126404156385
0.241205998044317
0.770600527812906];
d5 = [16.1418205805366
30.0280287069113
33.1019825913592
47.5934381385748
19.2097317137642
57.6017783524938
15.1513369414963
6.49486952090310
30.0280287069113
44.7601960225328
68.9220652853857
14.3590680682180
27.6612434434788
1.89195833722852
20.5324062058886
46.4528183615646
20.5324062058886
42.5531959114518
18.8044193372058
52.4912146516569
54.3198302677623
60.9498224570079
42.5531959114518
18.9123901513348
53.7536195742821
30.0684313236012
48.9660395771003];

% CRLB_60kHz_1000B = [0.0212 0.0473 0.1064 0.1891 0.2954];
% d6 = [];

% 绘图
figure;
hold on;
loglog(sort(d1), sort(sqrt(CRLB_15kHz_350B)), 'b-', 'linewidth',1,'MarkerFaceColor', 'blue', 'DisplayName', 'pack: 1000B, SCS: 15 kHz');
loglog(sort(d2), sort(sqrt(CRLB_30kHz_350B)), 'r-', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'pack: 1000B, SCS: 30 kHz');
%loglog(sort(d3), sort(sqrt(CRLB_60kHz_350B)), 'black-s', 'linewidth',1 , 'MarkerFaceColor', 'black', 'DisplayName', 'pack: 350B, SCS: 60 kHz');

loglog(sort(d4), sort(sqrt(CRLB_15kHz_1000B)), 'b-.', 'linewidth',1 , 'MarkerFaceColor', 'blue', 'DisplayName', 'pack:350B , SCS: 15 kHz');
loglog(sort(d5), sort(sqrt(CRLB_30kHz_1000B)), 'r-.', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'pack:350B , SCS: 30 kHz');
%loglog(sort(d6), sort(sqrt(CRLB_60kHz_1000B)), 'black--s', 'linewidth',1 , 'MarkerFaceColor', 'black', 'DisplayName', 'pack:1000B , SCS: 60 kHz')

hold off;

% 设置图例
legend('Location', 'best');

% 设置坐标轴标签
xlabel('距离[m]');
ylabel('CRLB的二次根号值[m]');

% 设置标题
title('测距估计的克拉美罗界受数据包大小影响');

% 网格显示
grid on;
set(gca, 'XScale', 'log', 'YScale', 'log'); % 确保坐标轴是对数刻度