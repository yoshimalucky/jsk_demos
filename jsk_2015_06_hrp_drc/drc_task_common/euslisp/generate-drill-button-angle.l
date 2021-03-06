#!/usr/bin/env roseus

(load "package://drc_task_common/euslisp/generate-drill-motion.l")
(setq *robot-name* "HRP2JSKNTS")
(setq *drill-main-arm* :rarm)
(setq *answers* nil)
(generate-robot *robot-name* :generate-ri? nil)
(set-drill-environment :draw? nil)
(send *robot* :angle-vector (get-watch-drill-pose))
(setq i (round (ros::get-param "/i" 0)))
(setq x (round (ros::get-param "/ix" 0)))
(setq y (round (ros::get-param "/iy" 0)))
(setq z (round (ros::get-param "/iz" 0)))
(setq r (round (ros::get-param "/ir" 0)))
(load (format nil "/home/leus/hrp2_dataset/pre-angle~A.l" (* i 30)))

(ros::ros-info (format nil "~A ~A ~A" x y z))
(defun save (i ix iy iz ir)
  (format t "initialize")
  (send (send *drill* :get :grasp-coords) :rotate (* (deg2rad 30) i) :z)
  (ros::ros-info "loop rotation")
  (dotimes (ip 8)
    (dotimes (iy2 8)
      (send *robot* :angle-vector (get-watch-drill-pose))
      (send *robot* :fix-leg-to-coords (make-coords))
      (set-drill-default-coords)
      (send *drill* :transform (make-coords :pos (float-vector (* 200 (- ix 1)) (* 200 (- iy 1)) (* 200 (- iz 1))) :rpy (list (deg2rad (* 45 ir)) (deg2rad (* 45 ip)) (deg2rad (* 45 iy2)))))
      (ros::ros-info (format nil "i ~A ix ~A iy ~A iz ~A ir ~A ip ~A iy ~A answer-size ~A" i ix iy iz ir ip iy2 (length *answers*)))
      (let ((ik-result (fullbody-inverse-kinematics-for-drill-button :draw? nil :stop 40)))
        (when ik-result
          (format t "IK SUCCEEDED")
          (push ik-result *answers*)
          )
        )            
      ))
    
  (dump-loadable-structure (format nil "/home/leus/hrp2_dataset/pre-angle~A.l" (* i 30)) *answers*)
  )

(save i x y z r)
(exit)