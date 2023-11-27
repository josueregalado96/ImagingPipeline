% By AT adapted from code by JR


%% get paths to behavior files

%%%%Andrea:this script finds the time that matlab sent the pulse to Bruker
%%%%and then adjusts all of the times of the imaging to get rid of the
%%%%frames captured prior to the pulse
%%%%You will want to first run your script to align lickrates to
%%%%behavior because it creates a variable (mine is called "behavior") that
%%%%you will align the frames to the experiment times

%%%%this you will want to change to 1 because you imaged in 1 plane
n_planes=6;


% hello



% %% read in NIDAQ data
% fid=fopen(sessiondaq,'r');
% [daqdata,~] = fread(fid,[5,inf],'double');
%     
% fclose(fid);
% t_daq = daqdata(1,:); %first row is time
% lick_daq = daqdata(2,:); % lick touch sensor
% trig_daq = daqdata(3,:); % behavior start trigger
% 
% %% Read in .mat data
% 
% matdata=load(sessionmat); % behavior .mat file
% %%%%%%% EDIT THIS. NEED SESSION TIME AND TRIGGER TIME
% %settings = matdata.settings;
% behavior=matdata.exper.M;
% N_behav = size(behavior,1); % NUMBER OF FRAMES IN MAT FILE
% 
% t_behav = behavior(:,1); % SESSION TIME IN MAT FILE
% % trig_behav = behavior(:,23); % TURN THIS INTO A VECTOR THATS THE SAME SIZE AS THE BEHAVIOR, AND IS 0 EVERYWHERE, 1 AT THE FRAME WHERE THE TRIGGER OCCURS
% 
% %% Correct for difference between niqdaq time keeping and virmen time
% % keeping using the start trigger
% t_daq_trigger = t_daq(find(trig_daq>1,1,'first'));
 t_behav_trigger = behavior(50,1);
% 
% differencetime = t_daq_trigger-t_behav_trigger;
% nidaq_t = t_daq - differencetime;
% 
% t_behav_end = t_behav(end);
% 
% %%%

%% Read in frame times from .xml file
d = xmlread(sessionxml);
frametimes = [];
i_seq = 0;
cnt = 1;
sequence = d.getElementsByTagName('Sequence');
while ~isempty(sequence.item(i_seq))
    curr_frames = sequence.item(i_seq).getElementsByTagName('Frame');
    i_fr = 0;
    while ~isempty(curr_frames.item(i_fr)) 
        frametimes(cnt) = str2num(curr_frames.item(i_fr).getAttributes.item(3).getValue);
        i_fr = i_fr+1;
        cnt = cnt+1;
    end
    i_seq = i_seq+1;
end

if i_fr <6
    frametimes = frametimes(1:end-i_fr);
end
img_idxs = 1:numel(frametimes);
%% Read in imaging voltage file, and remove frames before behavior trigger
opts = detectImportOptions(sessionv);
opts.SelectedVariableNames = [2:3];
vdata = readtable(sessionv,opts);
vdata=table2array(vdata);

% hello

if numel(find(diff(vdata(:,2))>2))>1
vtrigger = find(diff(vdata(:,2))>2,1,'last');
elseif numel(find(diff(vdata(:,2))>2))==1
vtrigger = find(diff(vdata(:,2))>2,1,'first');
end

[~,init_frameidx] = findpeaks(vdata(:,1),'MinPeakProminence',3);
frametrigger = find(init_frameidx>vtrigger,1,'first');
t_frametrigger = frametimes(frametrigger);

%%%%double check if necessary%%%%%%
% hello

frametimes_align = frametimes - (t_frametrigger)  %- t_behav_trigger);

dTf = min(diff(frametimes_align));
flyback = max(diff(frametimes_align));
dfts = [dTf,diff(frametimes_align)];
frametimes_seq = []; m1 = round(n_planes/2); m2 = round(n_planes/2)+1;
for i = 1:numel(frametimes_align)
    
    frametimes_seq(i) = (frametimes_align(i-1 - (mod(i-1,n_planes)-m1))+...
                            frametimes_align(i-1 - (mod(i-1,n_planes)-m2)) )/2;
end

frametimes_3rd=[];
thirdframe=0;
for i = 1:numel(frametimes_align)
    if mod(i,3)==0 && mod(i,6)~=0
        thirdframe=thirdframe+1;
    frametimes_3rd(thirdframe) = frametimes_seq(i);
    end
end


% hello

% img_idxs = img_idxs(frametimes_seq>=0 & frametimes_seq<=t_behav_end);
% 
% img_times = frametimes_seq(frametimes_seq>=0 & frametimes_seq<=t_behav_end);

%% interpolate behavior to match imaging rate
% 
% %%%%%% MATCH IMG TIMES AND BEHAVIOR TIMES LIKE PHOTOMETRY
% aligned_behavior = zeros(numel(img_times),size(behavior,2)); % will store lick in last column
% 
% for i_c = 1:size(aligned_behavior,2)
%     aligned_behavior(:,i_c) = interp1(t_behav,behavior(:,i_c),img_times,'previous');
% end
% aligned_behavior = [aligned_behavior,lick_count']; % lick_count is already aligned to image times, so just add it on
