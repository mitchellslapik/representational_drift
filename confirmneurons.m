disp('load spikes')

calendar = [1 2];
thresholdpercentile = 99;

spikes = struct();

%load data into spikes struct

numberofdays = size(calendar, 2);

for day = 1:numberofdays
    
    filename = append('data', string(day), '.mat');
    spikes(day).day = load(filename);
    
end

names = {};

%get list of all the channels across all days

for day = 1:numberofdays
    
    for neuron = 1:size(spikes(day).day.unitNames, 1)
    
        names{end + 1} = spikes(day).day.unitNames(neuron, :);
        
    end
end

%find the unique channel names 

uniquenames =  unique(names);

neuronmatrix = zeros(size(uniquenames, 2), numberofdays);

%make matrix of all neurons

disp('make matrix')

for day = 1:numberofdays
    
      for neuron = 1:size(spikes(day).day.chan, 2)
          
        index = find(strcmp(uniquenames, spikes(day).day.unitNames(neuron, :)));
        
        neuronmatrix(index, day) = 1;
        
      end
      
end

%display all neurons

figure;

set(gcf,'color','w');
h = heatmap(neuronmatrix, 'Colormap', flipud(gray), 'CellLabelColor','none');
colorbar off
ax = gca;
grid off
set(gcf, 'Position',  [150, 150, 300, 1000]);
ax.YData = uniquenames;
ax.XData = calendar;
title('all neurons');
xlabel('day');
ylabel('neuron');

disp('load waves')

%get wave data

wavesdata = struct();

for day = 1:numberofdays
    
    for neuron =  1:size(spikes(day).day.chan, 2)
        
        neuronname = spikes(day).day.unitNames(neuron, :);
        wave = spikes(day).day.waveform(neuron, :);
        
        index = find(strcmp(uniquenames, neuronname));
        
        wavesdata(day).day(index).wave = wave;
        
    end
    
end

%make list of the channel names, with no signal letter at the end

cutnames = {};

for n = 1:size(uniquenames, 2)
    
    name = uniquenames{n};
    newname = name(1:end-1);
    cutnames{end + 1} = newname;
    
end

uniquecutnames = unique(cutnames);

correlations = [];

%find correlation between all the waveforms, making sure they are
%not on the same channel. This gives you the distribution you'd expect for
%waveforms from different neurons

disp('find threshold')

for day1 = 1:numberofdays
    
    for day2 = day1 + 1:numberofdays
        
        for neuron1 = 1:size(wavesdata(day1).day, 2)
        
            for neuron2 = neuron1 + 1:size(wavesdata(day2).day, 2)
                
                neuronname1 = cutnames{neuron1};
                neuronname2 = cutnames{neuron2};
                
                if size(wavesdata(day1).day(neuron1).wave, 1) > 0 & size(wavesdata(day2).day(neuron2).wave, 1) > 0 
                
                    %confirm not the same neuron
                    if not(strcmp(neuronname1, neuronname2))

                        wave1 = wavesdata(day1).day(neuron1).wave;
                        wave2 = wavesdata(day2).day(neuron2).wave;
                        
                        r = corrcoef(wave1, wave2);
                        correlations = [correlations, r(1, 2)];

                    end
                    
                end
                
            end
            
        end
        
    end
    
end

%set threshold for correlations: for example the 99th percentile of the
%distribution

threshold = prctile(correlations, thresholdpercentile);

disp('find good neurons')

goodmatrix = zeros(1, numberofdays);

goodneurons = [];

%look through each neuron

%find subset of days where all pairs are correlated
%with each other greater than the threshold you set
   
for neuron = 1:size(uniquecutnames, 2)
    
    neuronname = uniquecutnames{neuron};
    
    neuronindexes = find(strcmp(cutnames, neuronname));
    
    neuroncalendar = neuronmatrix(neuronindexes, :);
    
    if size(neuroncalendar, 1) == 1
        
        dataperday = neuroncalendar;
        
    else
        
        dataperday = sum(neuroncalendar);
        
    end

    gooddays = find(dataperday);

    % start with a combo size which is the total number of days 
    %that neuron shows up
    
    daycombosize = size(gooddays, 2);

    while daycombosize > 1

        foundit = 0; 
        
        neuronsignalindexes = {};
        
        %find the signal indexes of that neuron for each day
        %this is important because a certain signal can have
        %a different index on a different day
        
        for day = 1:numberofdays

            signalindexes = find(neuroncalendar(:, day));

            neuronsignalindexes{day} = signalindexes;

        end

        %make a list of all the combos of days for that combo size
        
        daycombos = nchoosek(gooddays, daycombosize);
        
        %look at all of these day combos

        for daycomboidx = 1:size(daycombos, 1)

            daycombo = daycombos(daycomboidx, :);
            
            %get list of the signal indexes for each of those days
            %this is essentially the same as the neuron signal indexes
            %but only for the subset of days we want to look at
            
            daycombosignalindexes = {};
            
            for day = daycombo
                
                daycombosignalindexes{end + 1} = neuronsignalindexes{day};
                
            end
            
            %make list of all the combos of signals (signal a b c etc.) 
            %this is important because on any given day the signal letter
            %attached to a waveform is arbitrary. Therefore signal a on one
            %day could be signal b on another day.

            signalcombos = cell(1, numel(daycombosignalindexes)); 
            [signalcombos{:}] = ndgrid(daycombosignalindexes{:});
            signalcombos = cellfun(@(x) x(:), signalcombos,'uniformoutput',false); 
            signalcombos = [signalcombos{:}]; 
            
            %look at all of these signal combos
          
            for signalidx = 1:size(signalcombos, 1)
                
                signalcombo = signalcombos(signalidx, :);

                correlations = [];
                
                daypairs = nchoosek(daycombo, 2);
                
                %look at every pair of days for this day combo and signal
                %combo. Make sure every pair meets the threshold you set

                for pairidx = 1:size(daypairs, 1)

                    day1 = daypairs(pairidx, 1);
                    day2 = daypairs(pairidx, 2);

                    day1index = find(daycombo == day1);
                    day2index = find(daycombo == day2);
                    
                    signalindex1 = signalcombo(day1index);
                    signalindex2 = signalcombo(day2index);

                    index1 = neuronindexes(signalindex1);
                    index2 = neuronindexes(signalindex2);

                    wave1 = wavesdata(day1).day(index1).wave;
                    wave2 = wavesdata(day2).day(index2).wave;

                    r = corrcoef(wave1, wave2);
                    correlations = [correlations, r(1, 2)];

                end

                meetthreshold = correlations > threshold;
                
                %if all the pairs meet the threshold, then add this group
                %to the good matrix and good neuron list, take them out of
                %the neuron calendar, and repeat the process for the
                %remaining signals in the neuron calendar
    
                if mean(meetthreshold) == 1
                    
                    %make new row for good matrix
                    newrow = zeros(1, numberofdays);

                    for day = daycombo

                        dayindex = find(daycombo == day);
                        signalindex = signalcombo(dayindex);

                        neuroncalendar(signalindex, day) = 0;

                        newrow(day) = signalindex;

                    end
                    
                    %add to new goodmatrix and good neuron list
                    goodmatrix = [goodmatrix; newrow];
                    goodneurons = [goodneurons, uniquecutnames(neuron)];

                    if size(neuroncalendar, 1) == 1

                        dataperday = neuroncalendar;

                    else

                        dataperday = sum(neuroncalendar);

                    end
                    
                    %set new combo size to the number of remaining
                    %days for that neuron
                    gooddays = find(dataperday);
                    daycombosize = size(gooddays, 2);
                   

                    foundit = 1;

                    break

                end

               if foundit == 1

                   break

               end

            end

            if foundit == 1

               break

            end

        end

        if foundit == 0
            
            %if you went through all the combos and found nothing, then
            %look for slightly smaller combos and repeat the process
            
            daycombosize = daycombosize - 1;
            
        end

    end

end

goodmatrix = goodmatrix(2:end, :);

figure

%display consistent neurons across days

set(gcf,'color','w');
h = heatmap(goodmatrix, 'Colormap', flipud(gray), 'CellLabelColor','none', 'ColorLimits',[0 1]);
colorbar off
ax = gca;
grid off
set(gcf, 'Position',  [150, 150, 300, 1000]);
ax.YDisplayLabels = goodneurons;
ax.XDisplayLabels = calendar;
ax.title(["neurons that pass " + string(thresholdpercentile) + "% threshold"]);
xlabel('day');
ylabel('neuron');

%save variables

save('goodneurons');
save('goodmatrix');
