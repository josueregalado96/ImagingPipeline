%%%input stuff to extract signals, align to behavior, and make
%%%neuronstructure

clear all
clear all
close all
close all

ndata=0;
tdata=0;
zdata=1;

%%%%this is the behavior files
mousemat={'{}.mat'};
mousenidaq={'{}.bin'};

%%%%this is the xml file that is the output of the 2p imaging
sessionxml='{}.xml';

%%%%this is the csv file that is the output of the 2p voltage recording
sessionv='{}.csv';

run('DetectOverlaps.m')

run('ProcessNeurons.m')

run('AddLicksToVirmen2p')

run('alignData_Josue.m')

% hello

% run('ImagingAlign')
% 
% run('trialstructure.m')
% 
% run('HeatmapsNew.m')
% 
% run('BestFit.m')
% hello
% 
% run('ContextNeurons.m')