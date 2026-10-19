%% Chapter 11 - รันตัวอย่างทั้งหมด
%  การออกแบบตัวชดเชยโดยใช้แผนภาพโบด (Compensator Design using Bode Diagram)
%  ต้องใช้ Control System Toolbox
%  (แต่ละไฟล์มี clear/close all ในตัว จึงเรียกทีละบรรทัด)
fprintf('\n===== Example 1 : Lead =====\n');          L11_Ex1_Lead;          pause(1);
fprintf('\n===== Example 2 : Lead (Type-2) =====\n'); L11_Ex2_Lead_Type2;    pause(1);
fprintf('\n===== Example 3 : Lag =====\n');           L11_Ex3_Lag;           pause(1);
fprintf('\n===== Example 4 : Lag =====\n');           L11_Ex4_Lag;           pause(1);
fprintf('\n===== Example 5 : Lead-Lag =====\n');      L11_Ex5_LeadLag;       pause(1);
fprintf('\n===== Example 6 : Lead-Lag =====\n');      L11_Ex6_LeadLag;       pause(1);
fprintf('\n===== Practice 1 : Lag-Lead =====\n');     L11_Practice1_LagLead; pause(1);
fprintf('\n===== Example 7 : PID (Freq. domain) =====\n'); L11_Ex7_PID_FreqDomain;
