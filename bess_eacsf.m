function bess_eacsf(subject)

% ASSUMPTIONS

% This code assumes that synthseg has already been run on a subject and
% uses that segmentation to get the thickness of their extra-axial CSF

% We also assume that there is a folder called "templates" where
% "AC_mask_plane" and a mask of the ventricles is stored

path2templates = '';

% Finally, we are assuming that the defaced T1w scan is called "T1w_defaced" and synthseg segmentation is callled "T1w_defeaced_synthseg"

% CODE

% 1. Get to the right folder

cd(['subjects/',subject]); % edit to whatever gets you to do the folder where the T1w scan and segmentations are 

% 2. Extract ea-csf from synthseg segmentation

system('fslmaths synthseg_output/T1w_defaced_synthseg -thr 24 -uthr 24 -bin eacsf');

% 3. Extract brain with synthseg mask

system('fslmaths T1w_defaced -mas synthseg_output/T1w_defaced_synthseg T1w_brain_ss');

% 4. Create transformation between mni and native scan

system('flirt -in ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -ref T1w_brain_ss -omat mni2bet.mat');

% 4. Remove csf in ventricles and cisterns (need ventricle mask for this)

system(['flirt -in ',path2template,'/MNI152_T1_2mm_VentricleMask_sc_full -ref T1w_brain_ss -init mni2bet.mat -applyxfm -o ventricle_mask_native']);
system('fslmaths ventricle_mask_native -thr 0.5 -bin ventricle_mask_native');
system('fslmaths ventricle_mask_native -binv ventricle_invmask_native');

system('fslmaths eacsf -mas ventricle_invmask_native eacsf');

% 5. Get ventral eacsf mask (need AC_mask_plane for this)

system(['flirt -in ',path2templates,'/AC_mask_plane -ref T1w_brain_ss -init mni2bet.mat -applyxfm -o AC_mask_native']);
system('fslmaths AC_mask_native -thr 0.5 -bin AC_mask_native');
system('fslmaths eacsf -mas AC_mask_native eacsf_north');

% 6. Get thickness of the ventral eacsf_mask (AFNI)

system('qsub ../../../run_bb_thick.sh'); % run_bb_thick is a simple script but I run it separately because I couldn't get the AFNI module to load in matlab and it takes a while to run

cd('../..')


end