function [ saveName ] = createPDF( LuFu,timeStamp,events,eventTime, figTitel )
% Plot EIT data and creat a ped report 
% install ghosscript to run this 
% avoit symbold and special chracters from the file path 

% moving mean 
% TODO: verify this
n = 30;%  breath 
LuFu=filter(ones(1,n)/n,1,LuFu);

h1 = figure, h=plot(datetime(datestr(timeStamp(1:end,:))),LuFu(1:end)); hold on; 
title(figTitel); 
xlabel('Time','Fontsize',14); 

% add the events to the pdf 
pos = find(~cellfun(@isempty,events)); % get non empty entries 
y = get(gca,'ylim'); % y-axis lim    


% this is quite slow nor sure if we really need it. 
for iEvent = 1:length(pos) 
    h=plot([datetime(datestr(timeStamp(pos(iEvent),:))),datetime(datestr(timeStamp(pos(iEvent),:)))],y ,'-.','Color',[0.5 0.5 0.5],'Linewidth',1); hold on;
    hh = text(h.XData(1),(min(y)),events(pos(iEvent)),'FontWeight','bold');
    set(hh, 'rotation', 90); 
end 
 
orient(h1,'landscape'); 
saveas(h1,[figTitel,'.pdf']);
saveName= strcat([figTitel,'.pdf']);

close all; 
% maybe better use time stamp insted of breath 
% figure, plot(datenum(timeStamp),LuFu)


end

