%main

clear all
clc

%naive parameters:
temprature_pre = 0.25;
alphaConst_pre = 0.64;

%Uploading naive data:
correctChoicesPre = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\correctChoicesPre.mat');
successRatePre = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\successRatePre.mat');
meanGPeFR_Pre =load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\meanGPeFR_Pre.mat');
NHPsChoicesPre = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\NHPsChoicesPre.mat');

%Uploading PCP data:
successRatePcp = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\successRatePcp.mat');
correctChoicesPcp = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\correctChoicesPcp.mat');
NHPsChoicesPcp = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\NHPsChoicesPcp.mat');

%Uploading Post data:
successRatePost = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\successRatePost.mat');
correctChoicesPost = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\correctChoicesPost.mat');
NHPsChoicesPost = load('C:\Users\niras\Desktop\PhD main project\functions\filesForOcean\NHPsChoicesPost.mat');

%running the unfree model based on the naive behavioral results:
[ simBehaviorMat, trialsAvg ] = unFreeModel( correctChoicesPre.correctChoices, alphaConst_pre, NHPsChoicesPre.NHPsChoicesPre );

%calculating mean alphe value accross the task
alphaMeansUnFreePre = mean(simBehaviorMat(:,1:15,3),"omitnan");

%correlating GPe FR and alpha value calculated based on the NHPs' choices
figure(1)
subplot(1,3,1)
line(1:15,meanGPeFR_Pre.C_AVG1,'Color','k','LineWidth',2)
ax1 = gca; % current axes
ax1.XColor = 'k';
ax1.YColor = 'k';
set(get(ax1,'Xlabel'),'String','trial number')
set(get(ax1,'Ylabel'),'String','GPe FR (z-score)')
set(ax1,'FontSize',16)
ax1_pos = ax1.Position;
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','bottom','YAxisLocation','right','Color','none');
line(1:15,alphaMeansUnFreePre,'Parent',ax2,'Color',[0.9290 0.6940 0.1250],'LineStyle','--','LineWidth',2)
ax2 = gca; % current axes
set(get(ax2,'Ylabel'),'String','sGPe')
set(ax2,'FontSize',16)
[r,p] = corrcoef(meanGPeFR_Pre.C_AVG1,alphaMeansUnFreePre);
corVal = sprintf('%s%0.3f','r = ',r(2));
pVal = sprintf('%s%0.3f',' p = ',p(2));
text(12,0.3,corVal)
text(12,0.25,pVal)


%running the unfree model on the NHPs' PCP behavioral choices:
[ simBehaviorMatPCP, trialsAvgPCP ] = unFreeModel( correctChoicesPcp.correctChoices, alphaConst_pre, NHPsChoicesPcp.NHPsChoicesPcp );

%calculating mean PCP alphe value of the unfree model
alphaMeansUnFreePcp = mean(simBehaviorMatPCP(:,1:15,3),"omitnan");

%Comparing alpha value of the unfree model based on naive and PCP
%behavioral choices:
figure(1);subplot(1,3,2);hold on;plot(alphaMeansUnFreePre,'--','Color',[0.9290 0.6940 0.1250],'LineWidth',2);plot(alphaMeansUnFreePcp,'-- r','LineWidth',2)
legend('mean alpha pre','mean alpha PCP')

%running the unfree model on the NHPs' Post behavioral choices:
[ simBehaviorMatPost, trialsAvgPost ] = unFreeModel( correctChoicesPost.correctChoices, alphaConst_pre, NHPsChoicesPost.NHPsChoicesPost );

%calculating mean Post alphe value of the unfree model
alphaMeansUnFreePost = mean(simBehaviorMatPost(:,1:15,3),"omitnan");

%Comparing alpha value of the unfree model based on naive and Post
%behavioral choices:
figure(1);subplot(1,3,3);hold on;plot(alphaMeansUnFreePre,'-- k','LineWidth',2);plot(alphaMeansUnFreePost,'-- b','LineWidth',2)
legend('mean alpha pre','mean alpha Post')

% Increasing alphaConst value
for i=alphaConst_pre:0.05:1
    [ simBehaviorMatPost, trialsAvgPost ] = unFreeModel( correctChoicesPost.correctChoices, i, NHPsChoicesPost.NHPsChoicesPost );
    %calculating mean Post alphe value of the unfree model
    alphaMeansUnFreePost = mean(simBehaviorMatPost(:,1:15,3),"omitnan");
    figure(1);subplot(1,3,3);hold on;plot(alphaMeansUnFreePost,'-- b')
end


%running the free model
[ simBehaviorMat, endBehaviorMat, simSuccessRate] =...
    ReinforcementLearningAlphaSurprise( correctChoicesPre.correctChoices,temprature_pre, alphaConst_pre );

%calculating mean alphe value accross the task
alphaMeansFreePre = mean(simBehaviorMat(:,1:15,3),"omitnan");
alphaMeansEnds = mean(endBehaviorMat(:,1:5,3),"omitnan");
alphaMeansAll = [alphaMeansEnds,alphaMeansFreePre];

% calculating switch probability accross the task
simAvgChange = mean(simBehaviorMat(:,1:15,2),"omitnan");
simAvgChangeEnds = mean(endBehaviorMat(:,1:5,2),"omitnan");
simAvgChangeAll = [simAvgChangeEnds,simAvgChange];

%correlating simulate success rate and NHPs success rate
[r,p] = corrcoef(simSuccessRate,successRatePre.allTrialsAvg);
corVal = sprintf('%s%0.3f','r = ',r(2));
pVal = sprintf('%s%0.3f',' p = ',p(2));
figure(2);subplot(3,1,1);plot(simSuccessRate,'-- k','LineWidth',2);hold on; plot(successRatePre.allTrialsAvg,'k','LineWidth',2);
text(0.8,0.8,corVal)
text(0.7,0.7,pVal)

%correlating simulation learning slope and alpha value
figure(2)
subplot(3,1,2);
line(1:14,diff(simSuccessRate(6:end)),'Color','k','LineWidth',2)
ax1 = gca; % current axes
ax1.XColor = 'k';
ax1.YColor = 'k';
set(get(ax1,'Xlabel'),'String','trial number')
set(get(ax1,'Ylabel'),'String','learning slope')
set(ax1,'FontSize',16)
ax1_pos = ax1.Position;
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','bottom','YAxisLocation','right','Color','none');
line(1:14,alphaMeansAll(7:end),'Parent',ax2,'Color',[0.9290 0.6940 0.1250],'LineStyle','--','LineWidth',2)
ax2 = gca; % current axes
set(get(ax2,'Ylabel'),'String','sGPe')
set(ax2,'FontSize',16)
[r,p] = corrcoef(diff(simSuccessRate(6:end)),alphaMeansAll(7:end));
corVal = sprintf('%s%0.3f','r = ',r(2));
pVal = sprintf('%s%0.3f',' p = ',p(2));
text(0.8,0.3,corVal)
text(0.8,0.25,pVal)

%correlating P(switch) and mean alpha
figure(2)
subplot(3,1,3);
line(1:20,simAvgChangeAll,'Color','k','LineWidth',2)
ax1 = gca; % current axes
ax1.XColor = 'k';
ax1.YColor = 'k';
set(get(ax1,'Xlabel'),'String','trial number')
set(get(ax1,'Ylabel'),'String','P(switch)')
set(ax1,'FontSize',16)
ax1_pos = ax1.Position;
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','bottom','YAxisLocation','right','Color','none');
line(1:20,alphaMeansAll,'Parent',ax2,'Color',[0.9290 0.6940 0.1250],'LineStyle','--','LineWidth',2)
ax2 = gca; % current axes
set(get(ax2,'Ylabel'),'String','sGPe')
set(ax2,'FontSize',16)
[r,p] = corrcoef(simAvgChangeAll(1:end),alphaMeansAll);
corVal = sprintf('%s%0.3f','r = ',r(2));
pVal = sprintf('%s%0.3f',' p = ',p(2));
text(0.8,0.3,corVal)
text(0.8,0.25,pVal)


% running simulation as temperature increases (naive-pcp)
alphaConst = 0.64;
temprature = 0.25:0.1:1;
count = 1;

runingSimulation( correctChoicesPre.correctChoices,temprature,'temprature',alphaConst,1,count );
count = count + 1;

% running simulation and increasing alphaConst (naive-post)
temprature = 0.25;
alphaConst = 0.64:0.05:1;
runingSimulation( correctChoicesPre.correctChoices,alphaConst,'alphaConst',temprature,1,count );
count = count + 1;
%Running sinulation with increased temperature modulating alphaConst(PCP-stimulation)
temprature = 0.4;
alphaConst = 0.4:0.04:1;
runingSimulation( correctChoicesPre.correctChoices,alphaConst,'alphaConst',temprature,2,count );

