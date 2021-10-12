%this script displays the consistent waveforms determined by the confrim neurons script

%the purpose of this script is to demonstrate how to iuse the goodmatrix and goodneurons variables

disp('load spikes')
load('goodmatrix')
load('goodneurons')

calendar = [1 2];

spikes = struct();

%load data into spikes struct

numberofdays = size(calendar, 2);

for day = 1:numberofdays
    
    filename = append('data', string(day), '.mat');
    spikes(day).day = load(filename);
    
end

disp('load waves')

%load waveform data

wavesdata = struct();

for day = 1:numberofdays
    
    for neuron =  1:size(spikes(day).day.chan, 2)
        
        neuronname = spikes(day).day.unitNames(neuron, :);
        wave = spikes(day).day.waveform(neuron, :);
        
        index = find(strcmp(uniquenames, neuronname));
        
        wavesdata(day).day(index).wave = wave;
        wavesdata(day).day(index).name = neuronname(1:end -1);
        
    end
    
end

disp('plot waves')

spectralmap = cbrewer('div', 'Spectral', (calendar(end) - 1)*10 + 1, 'spline') / 1.02;
  
%go through every neuron

for neuron = 1:size(goodneurons, 2)
    
    figure
    
    neuronname = goodneurons{neuron};
    
    neuroncalendar = goodmatrix(neuron, :);
    
    dataperday = [];

    if size(neuroncalendar, 1) == 1
        
        dataperday = neuroncalendar;
        
    else
        
        dataperday = sum(neuroncalendar);
        
    end

    gooddays = find(dataperday);
    
    %go through every day that neuron appears
        
    for day = gooddays

        dayidx = find(gooddays == day);

        signalindex = neuroncalendar(dayidx);
        
        %this is important: the signal will probably have an different index on each day
        %so you have to find the index of that signal on that particular day
        
        %start by getting the list of neurons for that day

        dayneurons = {wavesdata(day).day(:).name};

        neuronindexes = find(strcmp(dayneurons, neuronname));
        
        %and find the index of the signal we are looking for

        truesignalindex = neuronindexes(signalindex);
        
        wave = wavesdata(day).day(truesignalindex).wave;
        
        y = zscore(wave, 1, 'all');
        
        calendarday = calendar(day);
        
        %plot data
       
        plot(y, 'LineWidth', 2,  'color', spectralmap((calendarday - 1)*10 + 1, :))
        hold on
        
    end
    
    title(neuronname, 'FontWeight','Normal', 'FontSize', 14);
      
    colormap (spectralmap);
    h = colorbar('XTickLabel',{calendar(gooddays) - 1}, 'XTick', (calendar(gooddays) - 1)/(calendar(end) - 1), 'FontSize',12);
    ylabel(h, '       day', 'Rotation', 0)
    
    set(gca,'visible','off')
    set(findall(gca, 'type', 'text'), 'visible', 'on')
    set(gcf,'color','w');
    
    hold off
    
end
