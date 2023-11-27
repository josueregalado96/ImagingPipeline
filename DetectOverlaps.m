%%%for detecting overlap cells%%%%

%%%need to figure out better method of picking one cell over another%%%

load 'Fall.mat'

center_sorted=[];
for i=1:(numel(F(:,1)))
    
center_sorted(i,1)=median(stat{1,i}.xpix); %x
center_sorted(i,2)=median(stat{1,i}.ypix); %y
center_sorted(i,3)=stat{1,i}.iplane; %plane
center_sorted(i,4)=i; %neuron number
center_sorted(i,5)=iscell(i,1); %is a cell or not?

if center_sorted(i,1)>=510 && center_sorted(i,1)<=1020
    center_sorted(i,1)=center_sorted(i,1)-510;
elseif center_sorted(i,1)>=1000
    center_sorted(i,1)=center_sorted(i,1)-1020;
end

if center_sorted(i,2)>=510 && center_sorted(i,2)<=1020
    center_sorted(i,2)=center_sorted(i,2)-510;
elseif center_sorted(i,2)>=1000
    center_sorted(i,2)=center_sorted(i,2)-1020;
end
    
end


k=1;
pixelThreshold =10;
new=0;
newneuron=0;
overlapcells=[0 0];
allcomps=[0 0];
stayon=1;
for i = 1:(size(center_sorted,1)) %for every neuron
    stayon=1;
    for j = (i+1):(size(center_sorted,1)) %for every next neuron
        if center_sorted(i,5)==1 && center_sorted(j,5)==1 %if both are actually neurons  
         if abs(center_sorted(j,1)-center_sorted(i,1))<pixelThreshold  %if neuron j's x minus neuron i's x is <pixel threshold
              if abs(center_sorted(j,2)-center_sorted(i,2))<pixelThreshold  %if neuron j's y minus neuron i's y is < pixel threshold
                  
                  %then check if the plane difference in neuron j and
                  %neuron i is 30, 60, or 90 microns
                   if center_sorted(i,3)~=center_sorted(j,3)
                         
                         new=new+1;
                         correlation=corrcoef(F(center_sorted(i,4),:),F(center_sorted(j,4),:));
                         allcorrs(new)=correlation(1,2);
                         %put NaN in this place;keep the middle ones.
                         if correlation(1,2)>.4 && stayon==1
                             if any(allcomps(:,2)==i)
                             else
                                newneuron=newneuron+1;
                                hello
                                min1=min(F(i,:));
                                max1=max(F(i,:));
                                min2=min(F(j,:));
                                max2=max(F(j,:));
                                
                                if max1-min1>max2-min2
                                    keptneurons(newneuron)=i;
                                elseif max2-min2>max1-min1
                                    keptneurons(newneuron)=j;
                                elseif max1-min1==max2-min2
                                    hello
                                end
                                stayon=0;


                                index_repeat(k)=center_sorted(j,4);
                                t(k) = correlation(1,2);
                                k=k+1;
                                overlapcells(k-1,:)=[i j];
                              end
                         end
                       allcomps(new,:)=[i j];
                    end
                end
            end
        end
    end
end

for i=1:numel(keptneurons)
    Fnew(i,:)=F(keptneurons(i),:);
end


filename= 'Fall_new.mat'
save(filename)