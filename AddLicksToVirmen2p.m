%analysis for measuring average lick rate across trial types flexible for
%Code from Josue and edited by Rhia and Ari
%JN 10.10.2017



behaviormean=[];
signalworks=[1 1 1 1 1];

%----------For Mouse B Training (past 10/23)----
% timecolumn=2;
% xcolumn=3;
% ycolumn=4;
% cue1column=6;
% cue2column=7;
% cue3column=8;
% watercolumn=9;
% sucrosecolumn=10;
% acidcolumn=11;
% outcomecolumn=15;
% speedcolumn=14;
% lickcolumn=17;
% trialcolumn=19;
% contextx=20;
% photometryindex=24;
%----------For habituation Mouse B/NewCohort VT----
timecolumn=1;
trialtimecolumn=2;
ycolumn=3;
xcolumn=4;
speedcolumn=5;
visualcolumn=6;
tonecolumn=7;
odorcolumn=8;
watercolumn=9;
sucrosecolumn=10;
acidcolumn=10;
puffon=11;
cuesequence=12;
trialtypes=13;
trialcolumn=14;
originalspeedcolumn=17;
%----------For New Cohort Training (past 10/23)----
% timecolumn=1;
% xcolumn=2;
% ycolumn=3;
% cue1column=5;
% cue2column=6;
% cue3column=7;
% watercolumn=8;
% sucrosecolumn=9;
% acidcolumn=10;
% outcomecolumn=11;
% contextnumcolumn=15;
% speedcolumn=16;
% lickcolumn=17;
% trialcolumn=18;
% photometryindex=21;

%----------For New Cohort Training (past 10/23)----

% timecolumn=1;
% xcolumn=2;
% ycolumn=3;
% cue1column=5;
% cue2column=6;
% cue3column=7;
% watercolumn=8;
% sucrosecolumn=9;
% acidcolumn=10;
% outcomecolumn=11;
% contextnumcolumn=15;
% speedcolumn=16;
% lickcolumn=17;

%use filenames that we'll loop through
filenames_MAT = mousemat;
filenames_NIDAQ = mousenidaq;

%duration to take lick data
lickBinDur = 500;
lickfactor = 1000 / lickBinDur;

%points to take around for averaging (units of linBinDur)
window_size = 8; %samples = ms 

%amnt of time after room entrance to take lick data for summary plots
secondsToTake = 30; %can do short time here for full cues days
valFinal = 10; %this is for calculating the final room lick rate, which we should probably just not collect


%if plotting raw lick data
manydaycount = 0;

for ii=1:length(filenames_MAT)
    %load the files iteratively, do analysis, then redo on next file.
    manydaycount = manydaycount + 1;
    dataMAT = load(filenames_MAT{ii});
    nidaqdata = fopen(filenames_NIDAQ{ii},'r'); %Open file for reading
    [dataNIDAQ,countmilk] = fread(nidaqdata,[5,inf],'double');
    fclose(nidaqdata);
    t = dataNIDAQ(1,:); %first row is time
    ch = dataNIDAQ(2:5,:); %each channel is a row
    
    %find lick events(Look through time row (ch1) and find peaks that have
    %an prominance of atleast 0.4., are 50 units aparts and a height of
    %3.9. 
    [lickPks,lickLocs] = findpeaks(diff(ch(1,:)),'MinPeakProminence',.4,'MinPeakDistance',50,'MinPeakHeight',3.5);

     figure; plot(ch(1,:),'-m'); %Time is plotted in maroon(-m)
     hold on
     plot(lickLocs(1,:),lickPks(1,:),'*','markersize',4) %(lickLOc(time of lick), LickPeak (intesity of peak)) are in blue
         
    %LickVect marks the location of the licks with ones
    lickVect = zeros(1,length(ch(1,:)));
    lickVect(lickLocs) = 1; 
    
    [imgPks,imgLocs]=findpeaks(diff(ch(2,:)),'MinPeakProminence',.4,'MinPeakDistance',30);
    
%      figure; plot(ch(2,:),'-m'); %Time is plotted in maroon(-m)
%      hold on
%      plot(imgLocs(1,:),imgPks(1,:),'*','markersize',4)
%      
      binranges = 0:lickBinDur:length(lickVect);    %Start @ 0, step by 500 and stop at the # of col in lickVect
      bincounts = histc(lickLocs,binranges);

     avgRate=tsmovavg(bincounts,'s',window_size,2);

    dataMAT.exper.M(1,4)=1;
    
    roomInfo=dataMAT.exper.M(:,4);
    roomStarts=find(dataMAT.exper.M(:,4)>0);
    roomIDs=dataMAT.exper.M(roomStarts,end-1); %for files before 9.25.2017, this should be (roomStarts,6)
    roomTimes=dataMAT.exper.M(roomStarts,1);
    roomTimesMilliseconds=roomTimes*1000; %these are pretty precise, so multiply by 1000 for ms, now comparable to
    allRoomData=[roomIDs,roomTimes,roomTimesMilliseconds]; %room number, roomEnterTime in seconds
     
    for j=1:length(dataMAT.exper.M(:,3))
    if dataMAT.exper.M(j,3)>0 & dataMAT.exper.M(j,3)<100
        dataMAT.exper.M(j,3)=dataMAT.exper.M(j,3)-20;
    end
    if dataMAT.exper.M(j,3)>100 & dataMAT.exper.M(j,3)<200
        dataMAT.exper.M(j,3)=dataMAT.exper.M(j,3)-120;
    end
    if dataMAT.exper.M(j,3)>200 & dataMAT.exper.M(j,3)<300
        dataMAT.exper.M(j,3)=dataMAT.exper.M(j,3)-220;
    end
end
    
    posTimes=dataMAT.exper.M(roomStarts,3);
    allPosData=[roomIDs,posTimes];
    
         avgRate(2,:)=binranges/1000; %the second row of avgRate will be the time in virmen seconds
     avgRate(1,:)=avgRate(1,:)*lickfactor;
     lickLocsSeconds=lickLocs./1000;
     imgLocsSeconds=imgLocs./1000;
    
     
%%%%%%%post processing%%%%%%
dataMAT=load(filenames_MAT{ii});
behavior=dataMAT.exper.M;
behavior(:,end+1)=0;
rooms=max(behavior(:,end-1));

%%%LICKS FROM ARDUINO TO SHEET%%%

%%%%for data on/after 7/11
turnfirstexposure=dataNIDAQ(1,find(dataNIDAQ(4,:)>1,1,'first'));
timeat50=behavior(50,timecolumn);
differencetime=turnfirstexposure-timeat50;
%%%



lickLocsSeconds(1,:) = lickLocsSeconds(1,:) - differencetime;
imgLocsSeconds(1,:) = imgLocsSeconds(1,:) - differencetime;


%%%%%%%%%%%

    %Mark when the licks occur in the behavior in a new column
[size_row, size_col] = size(behavior);
confirm_lick = zeros(size_row,1);

time = behavior(:,timecolumn);
lickLocsSeconds_vertical = transpose(lickLocsSeconds);

lickcolumn=numel(behavior(1,:))+1;

for j = 1:length(lickLocsSeconds_vertical)
    for i = 2:length(time)
        if lickLocsSeconds_vertical(j) <= time(i) && lickLocsSeconds_vertical(j) >= time(i-1)
            confirm_lick(i) = 1;
        end
    end
end
behavior(:,lickcolumn)=confirm_lick; 



%%%%%%%%%%%%%%%%%%%%%%%%  ANALYSIS OF LICKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

number_licks=nan(200,3);
lick_counter=0;
success=nan(200,3);
trial_missed_null=0;
trial_missed=0;
trial_correct=0;
lickrate_reward_on=nan(200,1);
lickrate_null=nan(200,3);
anticipatory_lickrate=nan(200,1);
antilickrate=0;

behavior(behavior(:,5)<0,5)=0;
lickrate=[];
%%%Calulate and add lickrates?
count=0;
for a=50:numel(behavior(1:end,1))
count=count+1;
b=find(behavior(:,1)<behavior(a,1)-1,1,'last');
lickrate(a,1)=sum(behavior(b:a,end))/(behavior(a,1)-behavior(b,1));
end

behavior(:,end+1)=lickrate;

lickcolumn=numel(behavior(1,:));


%behavior(:,end+1)=lickrate(:,1);
%Normalize speed and signals

speedsignal=[];
speedsignal=behavior(:,5)';
originalspeedsignal=behavior(:,5)';
threshold=nanmean(speedsignal)+7*nanstd(speedsignal)
for i=1:numel(speedsignal)
    if speedsignal(i)>threshold
        speedsignal(i)=0;
    end
end



speedsignal=speedsignal(~isnan(speedsignal));
speedsignal=zscore(speedsignal);
lowest=min(zscore(speedsignal));
speedsignal=speedsignal-lowest;
max(speedsignal)
behavior(1:numel(speedsignal),5)=speedsignal;
behavior(1:numel(originalspeedsignal),originalspeedcolumn)=originalspeedsignal;

differencetime;


behavior(1:end,end+1)=0;
pupilcolumn=20;

engagethreshold=mean(behavior(find(behavior(:,originalspeedcolumn)==2),5))
engagethresholdcompile(ii)=mean(behavior(find(behavior(:,originalspeedcolumn)==1),5))
%%%Determine what x value is for null, whether in training or no, in order to calculate stops in future

    stopthreshold=1;
    trialnumber=1;
%     for i=3:numel(behavior(:,1))
%         behavior(i-2,14)=trialnumber;
%         if behavior(i-1,4)-behavior(i,4)==-40 || behavior(i-1,4)-behavior(i,4)==40 || behavior(i-1,6)-behavior(i,6)==1
%             trialnumber=trialnumber+1;
%         end
%     end

%%%%check if nidaq stopped running at some point
% if runbehavior==1
% newbehavior=[];
% 
% timegap(ii,1)=behavior(end,1)-dataNIDAQ(1,end)
% 
% for i=1:numel(behavior(:,1))
%     if behavior(i,1)<=dataNIDAQ(1,end)
%         newbehavior(i,:)=behavior(i,:);
%     end
%     
% end
% behavior=newbehavior;
% 
% timegap(ii,2)=behavior(end,1)-dataNIDAQ(1,end)
% end

end
