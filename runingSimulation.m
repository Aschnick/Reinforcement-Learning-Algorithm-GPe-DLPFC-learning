function [ ] = runingSimulation( correctChoices,runningParamVal,runningParamName,constantParamVAl, condition, count )
%Running TD-learning alpha modulating algorithm
%   correctChoices - The task's correct choices
%   runningParamVal - the running values of the changing parameter.
%   runningParamName - the name of the changing parameter ('temprature' or ''alphaConst').
%   constantParamVAl - the value of the constant parameter.
%   alternative returens:
%   [R_Pswitch_alpha, R_Psuccswitch_alpha, R_success_model_behavior, R_switch_model_behavior, R_sucSwitch_model_behavior,RMS_successRate, RMS_switch,RMS_sucSwitch]


switch runningParamName
    case 'alphaConst'
        alphaConst = runningParamVal;
        temprature = constantParamVAl;
    case 'temprature'
        temprature = runningParamVal;
        alphaConst = constantParamVAl;
end
inc = 0.5;


for i=1:length(runningParamVal)
    switch runningParamName
        case 'alphaConst'
            [ simBehaviorMat, endBehaviorMat, simTrialsAvg(i,:)] = ReinforcementLearningAlphaSurprise( correctChoices,temprature, alphaConst(i));
            switch condition
                case 1
                    %alphaConst color map
                    %black to blue:
                    cMap = interp1([0;1],[0 0 0; 0 0 1],linspace(0,1,length(runningParamVal)+1));
                case 2
                    %color map for alphaConst change three colors for - 13Hz, PCP and 130Hz
                    cMap = interp1([1;0;0.5],[0 0 1;0 1 0 ;1 0 0],linspace(0,1,length(runningParamVal)+1));
            end
        case 'temprature'
            [ simBehaviorMat, endBehaviorMat, simTrialsAvg(i,:) ] = ReinforcementLearningAlphaSurprise( correctChoices,temprature(i), alphaConst);
            %color map for temprature:
            %black to red:
            cMap = interp1([0;1],[0 0 0; 1 0 0],linspace(0,1,length(runningParamVal)+1));
            
    end
    
    colormap(cMap)
    hotcustom = cMap;
    
    countM = 1;
    countC = 1;
    for ii=1:size(simBehaviorMat,1)
        for jj=1:size(simBehaviorMat,2)
            if jj <= size(simBehaviorMat,2) - 1
                if simBehaviorMat(ii,jj,1) == 0 %post mistake trials
                    PswitchPostM(countM) = simBehaviorMat(ii,jj+1,2);
                    alphaPostMistakeAct(countM) = simBehaviorMat(ii,jj+1,3);
                    countM = countM + 1;
                elseif simBehaviorMat(ii,jj,1) == 1 %post correct trials
                    PswitchPostC(countC) = simBehaviorMat(ii,jj+1,2);
                    alphaPostCorrectAct(countC) = simBehaviorMat(ii,jj+1,3);
                    countC = countC + 1;
                end
            end
        end
    end
    
    [ dynamic_successCriterion ] = dynamicLearningCriterion( simBehaviorMat );
    figure(3)
    subplot(3,3,count)
    hold on
    plot(runningParamVal(i),mean(dynamic_successCriterion,"omitnan"),'o','MarkerFaceColor',hotcustom(i,:),'MarkerEdgeColor',hotcustom(i,:));
    xlabel(runningParamName)
    ylabel('learning criterion (trial number)')
    
    switch runningParamName
        case 'alphaConst'
            figure(3)
            subplot(3,3,count+6)
            hold on
            plot(runningParamVal(i),mean(PswitchPostC,"omitnan"),'v','MarkerFaceColor',hotcustom(i,:),'MarkerEdgeColor',hotcustom(i,:));
            ylabel('P(random exploration)')
            xlabel('alpha P.correct')
            zlabel(runningParamName);
            
            figure(3)
            subplot(3,3,count+3)
            hold on
            plot(runningParamVal(i),mean(PswitchPostM,"omitnan"),'square','MarkerFaceColor',hotcustom(i,:),'MarkerEdgeColor',hotcustom(i,:));
            ylabel('P(directed exploration)')
            xlabel('alpha P.mistake')
            zlabel(runningParamName);
            
        case 'temprature'
            figure(3)
            subplot(3,3,count+6)
            hold on
            plot(mean(alphaPostCorrectAct,"omitnan"),mean(PswitchPostC,"omitnan"),'v','MarkerFaceColor',hotcustom(i,:),'MarkerEdgeColor',hotcustom(i,:));
            ylabel('P(random exploration)')
            xlabel('alpha P.correct')
            zlabel(runningParamName);
            
            
            figure(3)
            subplot(3,3,count+3)
            hold on
            plot(mean(alphaPostMistakeAct,"omitnan"),mean(PswitchPostM,"omitnan"),'square','MarkerFaceColor',hotcustom(i,:),'MarkerEdgeColor',hotcustom(i,:));
            ylabel('P(directed exploration)')
            xlabel('alpha P.mistake')
            zlabel(runningParamName);
    end
    
    
    inc = inc+0.1;
    
end

end

