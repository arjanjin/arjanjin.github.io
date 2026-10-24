Chapter 12 PID Control Enhancement -- MATLAB files
01068007 Control Systems, Assoc. Prof. Dr. Arjin Numsomran, KMITL

Run everything:   >> ch12_run_all

Helpers
  ch12_params.m        case-study plant G = 1.2e^{-30s}/(150s+1) and SIMC PI
  ch12_sim_pi.m        2-DOF PI simulator: exact dead time, saturation, anti-windup
  ch12_metrics.m       IAE, IE, ISE, ITAE, TV, emax, ts
  ch12_write_dat.m     writes pgfplots .dat files

Interactive app
  PIDTunerApp2.m            2-DOF PID tuner: 25 process cards + TCLab case + custom plant,
                            b/c weights, D-filter N, anti-windup (none/clamping/back-calc),
                            SIMC / ZN / Cohen-Coon, servo/regulatory/effort metrics,
                            Ms, Mt, GM, PM, Nyquist.  No toolbox needed.   >> PIDTunerApp2
                            Headless: P = PIDTunerApp2.plantFromCard(0); (see slides 47-49)

Scripts (section in the chapter)
  ch12_01_pid_forms.m       12.2   form conversions, Theorem 12.1, Ex 12.2-12.3
  ch12_02_deriv_filter.m    12.3   derivative filter N, Ex 12.4
  ch12_03_windup.m          12.4   Example 12.1, no AW / back-calc / conditional
  ch12_04_2dof_sweep.m      12.5-12.8  decoupling theorem, IE_d, IE_r, b table, TV scan
  ch12_05_robustness.m      12.7   Gang of Four, Ms/Mt, GM/PM, Ms bounds
  ch12_06_diskmargin.m      12.8.4 disk margin alpha, eq. (12.25)
  ch12_07_tuning_compare.m  12.8.4 SIMC vs pidtune vs systune   (needs toolboxes)
  ch12_08_digital.m         12.10  velocity form, ZOH PM loss, sampled PI, Ex 12.11
  ch12_09_exercises.m       12.11  numeric answers
  ch12_10_export_dat.m      regenerates data/*.dat for the XeLaTeX figures

Expected key values
  Kp = 2.0833, Ti = 150 s, Ms = 1.5905, Mt = 1.0000, GM = 3.14 (9.94 dB), PM = 61.4 deg
  IE_d = -72.00, e_max = 0.3510, disk margin alpha = 0.8832 (+/-8.24 dB, +/-47.65 deg)
  windup: no AW Mp 17.39 %, back-calc and conditional Mp 0 %

Verified: scripts 01-06 and 08-10 run in GNU Octave 8.4 and reproduce every
number in the chapter; data/*.dat is byte-for-byte equal to gen_ch12_data.py.
ch12_07 and the toolbox cross-checks in 05, 06, 08 (margin, diskmargin, pidtune,
systune, c2d) need MATLAB and were not run.

PIDTunerApp2 checked on R2026a (TCLab, SIMC PI, no saturation): Kc 2.0833, Ti 150,
Ms 1.5905, GM 9.94 dB, PM 61.35 deg, Mp(b=1) 4.11 %, IE_r 59.9/209.9 (b=1/0),
IE_d +/-14.36 for d = -/+0.2.  Note: the TCLab preset (d = -0.2, 0 <= u <= 1) needs
u = 1.033 > umax at steady state -> permanent offset e = 0.04 (IE_d = 41.1).
