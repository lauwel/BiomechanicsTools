% using statsDotPlot
close all
clear
clc
ligament_data = rand(6,5); 

group_names = {'lig1','lig2','lig3'};

trial_names = {'flexion','extension'};

group_num = [1, 1, 2, 2, 3, 3];
trial_num = [1, 2, 1, 2, 1, 2];
% 3 colours in rows (1 for each ligament/group)
cols = [0.2422    0.1504    0.6603;...
        0.1786    0.5289    0.9682;...
    0.9892    0.8136    0.1885    ];

marker = 'o';

makeGroupedStatsDotPlot(ligament_data,group_num,trial_num,group_names,trial_names,cols,marker)