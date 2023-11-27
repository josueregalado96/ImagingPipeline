

olddff=Fnew;
%normalize data
for n=1:numel(Fnew(:,1))
framerate=3; %per sec
seconds=20;
sec20=framerate*seconds;
totalframes=numel(Fnew(n,:));
for frame=1:totalframes
    if frame<=sec20
    runavg=mean(Fnew(n,1:sec20));
    else
    runavg=mean(Fnew(n,frame-sec20:frame));
    end
    normdff(n,frame)=(Fnew(n,frame)-runavg)/runavg;
end
end

if ndata==1
Fnew(n,:)=normdff(n,:);
end



%%%zscore data
for n=1:numel(Fnew(:,1))
zdff(n,:)=zscore(Fnew(n,:));
end

if zdata==1
Fnew=zdff;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate  noise to find transients: 
%(1) initialize a cutoff
%(2) calculate std of dff that fall below
%(3) compare 3std to the cut off

for i=1:numel(olddff(:,1))
    
%     hello
    
dataset=zdff(i,:);
% dataset=normdff(i,:);
significant_transients=[];

% Parameters
initial_cutoff = 3; % Initial cutoff value to separate signal and noise
initial_cutoff = std(dataset); % Initial cutoff value to separate signal and noise
max_iterations = 10; % Maximum number of iterations
tolerance = 0.02; % Tolerance for convergence

% Calculate baseline
baseline = mean(dataset, 2); % Assuming each column is a time series

% Initialize variables
cutoff = initial_cutoff;
previous_cutoff = cutoff - 1;
iteration = 0;
sig=std(dataset(:)<initial_cutoff);
significant_transients = dataset > cutoff;

while abs(cutoff - 3 * sig) > tolerance %&& iteration < max_iterations
    % Calculate delta F/F
%     delta_F = (dataset - baseline) ./ std(dataset, 0, 2);
%     delta_F = dataset;
    

    % Apply cutoff thresholding
    significant_transients = dataset > cutoff;
    
    % Calculate the standard deviation of values below the cutoff
    std_below_cutoff = std(dataset(dataset <= cutoff));
    
    % Update cutoff value
%     previous_cutoff = cutoff;
    
    if cutoff < 3 * sig
        cutoff = cutoff * 1.1; % Increase cutoff by 10%
        sig=std(dataset(:)<cutoff);
    elseif cutoff > 3 * sig
        cutoff = cutoff * 0.9; % Reduce cutoff by 10%
        sig=std(dataset(:)<cutoff);
    end
    
    % Increment iteration counter
    iteration = iteration + 1;
end

% hello

% Post-processing to remove short transients
window_size = 3; % Adjust the window size for transient detection
significant_transients = medfilt1(double(significant_transients), window_size);


%check transients to see if at least 1sec long
checktransient=1;
transientrise=zeros(1,numel(significant_transients(1,:)));
for t=1:numel(significant_transients)
    if significant_transients(t)==1 && checktransient==1
        checktransient=0;
        newt=find(significant_transients(t:end)==0,1,'first')+t-2;
        if newt-t<3
            significant_transients(t:newt)=0;
        end
        if newt-t>=3
            transientrise(t)=1;
        end
    end
    
    if significant_transients(t)==0
        checktransient=1;
    end
    
end

% % Plotting the significant transients
% figure;
% imagesc(significant_transients);
% colormap(gray);
% xlabel('Time');
% ylabel('Neuron');
% title('Significant GCaMP6f Transients');
% 
% Display the significant transients
significant_indices = find(significant_transients);
% disp('Significant Transient Indices:');
% disp(significant_indices);


% figure
% plot(delta_F,'LineWidth',1)
% hold on
% plot(zscore(dataset))




% figure
% plot(significant_transients-2,'LineWidth',1)
% hold on
% plot(zscore(dataset))

% hello

noisedff(i,:)=zeros(1,numel(significant_transients(1,:)));
noisedff(i,find(significant_transients(:)==1)')=zdff(i,find(significant_transients(:)==1)');

transientstart(i,:)=zeros(1,numel(significant_transients(1,:)));
transientstart(i,2:end)=(diff(significant_transients(:))==1);

% hello

% [pks,locs] = findpeaks(dF_mean,'MinPeakProminence',3*thresh*sig/4,...
%     'MinPeakHeight',thresh*sig+baseline,'MinPeakDistance',mindur/2,'MinPeakWidth',mindur);

% plot(zdff(i,:))
% hold on
% plot(noisedff(i,:))


iterationall(i)=iteration;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if tdata==1
% Fnew=noisedff;
end


%%%%plot the neurons
next=0;
figure
for i=1:numel(Fnew(:,1))
        next=next+1;
        new=Fnew(i,:);
    normA = new - min(new(:));
    normA = normA ./ max(normA(:));
%   new=normalize(new)
    plot(normA-next, 'color', [0 0 0])
    hold on
end

set(gcf, 'Position',  [0, 500, 500, 1000])
saveas(gcf,'AllNeuronsZ.tif')


%%%%plot the neurons
next=0;
figure
for i=1:numel(normdff(:,1))
        next=next+1;
        new=normdff(i,:);
    normA = new - min(new(:));
    normA = normA ./ max(normA(:));
%   new=normalize(new)
    plot(normA-next, 'color', [0 0 0])
    hold on
end

set(gcf, 'Position',  [0, 500, 500, 1000])
saveas(gcf,'AllNeuronsNorm.tif')

%%%%plot the neurons
next=0;
figure
for i=1:numel(noisedff(:,1))
        next=next+1;
        new=noisedff(i,:);
    normA = new - min(new(:));
    normA = normA ./ max(normA(:));
%   new=normalize(new)
    plot(normA-next, 'color', [0 0 0])
    hold on
end

set(gcf, 'Position',  [0, 500, 500, 1000])
saveas(gcf,'AllNeuronsTransient.tif')



filename= 'Fall_new.mat'
save(filename)