Chapter 13 -- Model-Based Design and V-Model verification (MIL/SIL/PIL/HIL)
01068007 Control Systems, KMITL -- MATLAB R2026a, base MATLAB only
(stepinfo/tf are used only if Control System Toolbox is present)

Case study: RC plant on Arduino UNO R4 WiFi (DAC A0 -> R 10k -> C 100uF -> A1)
  tau = RC = 1 s, PI with Ti = tau, tcl = 0.5 s -> Kp = 2, Ki = 2, Ts = 20 ms

Library
  ch13_params      parameters (Name,Value override)
  ch13_pi_step     UNIT UNDER TEST -- line-for-line mirror of pi_step() in C
  ch13_cast        float32 emulation of the controller constants
  ch13_sim_mil     MIL : continuous PI + plant, RK4 1 ms
  ch13_sim_sil     SIL : UUT + ADC/DAC quantisation + exact ZOH plant
                   ch13_sim_sil(P,"single")      -> PIL emulation (float32)
                   ch13_sim_sil(P,"double",J)    -> sampling jitter J (s)
                   P.Ctrue / P.noise             -> HIL-like true plant
  ch13_metrics     tr, Mp, ts, ess, IAE, umin/umax
  ch13_b2b         back-to-back comparison (max, RMS)
  ch13_ref, ch13_quant, ch13_write_dat

Examples (run in order, or ch13_run_all)
  ch13_01_requirements    REQ -> test case -> PASS/FAIL (13.2)
  ch13_02_mil             MIL vs theory (13.4)
  ch13_03_sil_ts_sweep    effect of Ts, PM loss of ZOH (13.5)
  ch13_04_quantization    converter resolution (13.5)
  ch13_05_pil_equivalence float32 vs double, tolerance bound (13.6)
  ch13_06_hil_tolerance   C +-20 %, ADC noise (13.7)
  ch13_07_timing          delay and jitter (13.9)
  ch13_08_windup_test     saturation test case (13.4)
  ch13_09_exercises       numerical answers
  ch13_10_export_dat      data/*.dat for the slides
