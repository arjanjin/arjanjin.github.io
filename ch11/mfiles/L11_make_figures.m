%% สร้างรูป PNG ของทุกตัวอย่าง (ใช้ประกอบสไลด์) -> โฟลเดอร์ fig/
%  รันจากโฟลเดอร์ CH11_mfiles
setappdata(0,'L11_list', { ...
  'L11_Ex1_Lead','ex1'; 'L11_Ex2_Lead_Type2','ex2'; 'L11_Ex3_Lag','ex3'; ...
  'L11_Ex4_Lag','ex4'; 'L11_Ex5_LeadLag','ex5'; 'L11_Ex6_LeadLag','ex6'; ...
  'L11_Practice1_LagLead','pr1'; 'L11_Ex7_PID_FreqDomain','ex7'});
if ~exist('fig','dir'), mkdir fig; end
set(0,'DefaultFigureVisible','off');
set(0,'DefaultFigurePosition',[100 100 1100 720]);
for k = 1:8
    setappdata(0,'L11_k',k);
    L = getappdata(0,'L11_list');
    evalc(L{k,1});                       % รันตัวอย่าง (สคริปต์มี clear/close all)
    k = getappdata(0,'L11_k'); L = getappdata(0,'L11_list');
    figs = findall(0,'Type','figure');
    for f = figs'
        nm = get(f,'Name');
        set(f,'Units','pixels','Position',[100 100 1100 720]); drawnow;
        set(findall(f,'-property','FontSize'),'FontSize',13);
        if strcmp(L{k,2},'ex7') && ~contains(nm,'PID :'), continue; end
        if contains(nm,'Bode') && ~contains(nm,'comparison')
            exportgraphics(f, fullfile('fig',[L{k,2} '_bode.png']),'Resolution',140);
        elseif contains(nm,'Time response')
            exportgraphics(f, fullfile('fig',[L{k,2} '_time.png']),'Resolution',140);
        elseif contains(nm,'comparison')
            exportgraphics(f, fullfile('fig',[L{k,2} '_bode.png']),'Resolution',140);
        elseif contains(nm,'control effort')
            exportgraphics(f, fullfile('fig',[L{k,2} '_time.png']),'Resolution',140);
        end
    end
    close all;
end
set(0,'DefaultFigureVisible','on');
disp(dir('fig/*.png'));
