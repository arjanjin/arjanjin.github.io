function ch12_run_all()
%CH12_RUN_ALL  Run every Chapter 12 script in order.
%   Each script runs in its own workspace, so the "clear" at the top of a
%   script does not wipe this loop.
%   01068007 Control Systems, Chapter 12 PID Control Enhancement
%   Assoc. Prof. Dr. Arjin Numsomran, KMITL
scripts = {'ch12_01_pid_forms','ch12_02_deriv_filter','ch12_03_windup', ...
           'ch12_04_2dof_sweep','ch12_05_robustness','ch12_06_diskmargin', ...
           'ch12_07_tuning_compare','ch12_08_digital','ch12_09_exercises', ...
           'ch12_10_export_dat'};
for k = 1:numel(scripts)
    fprintf('\n==================== %s ====================\n', scripts{k});
    try
        run_one(scripts{k});
    catch ME
        fprintf(2,'  %s failed: %s\n', scripts{k}, ME.message);
    end
end
end

function run_one(name)
run(name);
end
