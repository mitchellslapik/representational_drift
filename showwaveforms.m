%this script displays the consistent waveforms determined by the confirm neurons script

%the purpose of this script is to demonstrate how to use the confirmedcalendar and confirmedneurons variables

disp('load spikes');

load('confirmedcalendar.mat');
load('confirmedneurons.mat');

calendar = [1, 6, 36, 37, 41, 43, 50, 57, 62];
numberofdays = size(calendar, 2);

spikes = struct();

for day = 1:numberofdays
    
    filename = append('spikes/spikes', string(day), '.mat');
    temp = load(filename);
    spikes(day).day = temp.Trial_cut_tasks{1, 1};
    
end

wavedata = struct();

for day = 1:numberofdays
    
    filename = append('waves/waves', string(day), '.mat');
    temp = load(filename);
    wavedata(day).day = temp.waveform;
    
end

organizedwaves = struct();

for day = 1:numberofdays
    
    for neuron = 1:size(spikes(day).day.Unit_IDs, 2)
    
        neuronname = spikes(day).day.Unit_IDs{neuron};
        singlewave = wavedata(day).day(neuron, :);

        organizedwaves(day).day(neuron).wave = singlewave;
        organizedwaves(day).day(neuron).name = neuronname(1:end - 1);
        
    end
    
end

disp('calculate color preferences');

colorpreferences = struct();

for day = 1:numberofdays
    
    for neuron = 1:size(spikes(day).day.Unit_IDs, 2)
    
        neuronname = spikes(day).day.Unit_IDs{neuron};
        trials = spikes(day).day.asig1_sp_allt(:, neuron, :);
        trialmeans = (mean(trials(:, 1100 + 40 : 1549 + 40), 2) - mean(trials(:, 1100 - 260 : 1100 + 40), 2))*1000;
        targets = spikes(day).day.code_target;
        
        %find average response for each color
        
        colormeans = [];
        colorsems = [];
        
        for color = 1:8
            
            indexes = find(targets == color);
            goodindexes = indexes(indexes > 80);
            colormean = mean(trialmeans(goodindexes));
            colorsem = std(trialmeans(goodindexes))/size(goodindexes, 1);
            
            colormeans = [colormeans, colormean];
            colorsems = [colorsems, colorsem];
            
        end
            
        colorpreferences(day).day(neuron).means = colormeans;
        colorpreferences(day).day(neuron).error = colorsems;
        colorpreferences(day).day(neuron).name = neuronname(1:end - 1);
        
    end
    
end

disp('plot waves')

%label channels a b c d so that none of them have the same name

fullnames = {};

signalletters = 'abcd';

for neuron = 1:size(confirmedneurons, 2)
    
    neuronname = confirmedneurons{neuron};
    
    signalnumber = 1;
    
    if neuron > 1
    
        if strcmp(confirmedneurons{neuron - 1}, confirmedneurons{neuron}) 
            
            signalnumber = signalnumber + 1;
            
        else 
            
            signalnumber = 1;
            
        end
        
    end

    signalletter = signalletters(signalnumber);

    fullname = [neuronname signalletter];

    fullnames{end + 1} = fullname;
    
end

for neuron = 1:size(confirmedneurons, 2)
    
    neuronname = confirmedneurons{neuron};
    
    neuroncalendar = confirmedcalendar(neuron, :);
    
    dataperday = sum(neuroncalendar, 1);

    gooddays = find(dataperday);
    
    %go through every day that neuron appears
    
    if size(gooddays, 2) > 7
        
        figure('visible', 'on');
                
        spectralmap = cbrewer('div', 'Spectral', (calendar(end) - 6)*10 + 1, 'spline') / 1.008;
    
        for day = gooddays

            dayidx = find(gooddays == day);

            signalindex = neuroncalendar(day);

            %figure out the correct index of the neuron on that day. It
            %will not be the same as its index in the confirmed neuron list

            dayneurons = {organizedwaves(day).day(:).name};

            neuronindexes = find(strcmp(dayneurons, neuronname));

            %and find the index of the signal we are looking for

            truesignalindex = neuronindexes(signalindex);

            wave = organizedwaves(day).day(truesignalindex).wave;

            y = zscore(wave, 1, 'all');
            
            x = 1:size(y, 2);

            calendarday = calendar(day);

            %plot data

            patchline(x, y, 'linewidth', 2,  'edgecolor', spectralmap((calendarday - 6)*10 + 1, :), 'edgealpha', .8)
            hold on
        
        end
        
        fullname = fullnames{neuron};
        
        title(fullname, 'FontWeight','Normal', 'FontSize', 14);

        %add colorbar
        colormap (spectralmap);
        h = colorbar('XTickLabel',{calendar(gooddays) - 5}, 'XTick', (calendar(gooddays) - 6)/56, 'FontSize',12);
        ylabel(h, 'day')

        set(gca,'visible','off')
        set(findall(gca, 'type', 'text'), 'visible', 'on')
        set(gcf,'color','w');

        hold off;
        
        saveas(gcf,[fullname '-waveforms.jpg'])

    end
    
end
