function [ output_args ] = plotEvents( Events,TimeVector,hh )
%UNTITLED Summary of this function goes here

%   this functions plots the events to the figure 
        hold on;
        aa = get(gca,'YLim');  %# Get the range of the y axis
        eventPos = find(cellfun(@(x) isequal(x,'Event'),Events)); % Position in the array
        timeV = datetime(TimeVector(eventPos));
        
        % this is rather slow! not sure if we really need all the events in
        % the report tobe discussed 
         for iEvent=  1:(length(eventPos))
              h = plot([timeV(iEvent),timeV(iEvent)],aa,'-.','Color',[0.5 0.5 0.5],'Linewidth',1); hold on;
              hh = text(h.XData(1),(mean(aa)),datestr(timeV(iEvent)),'FontWeight','bold'); 
              set(hh, 'rotation', 90); 
         end
end
