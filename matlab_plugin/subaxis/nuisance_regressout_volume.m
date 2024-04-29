function nuisance_regressout_volume(img_path, regressor_path, clean_data_path)
	ori_img = load_untouch_nii(img_path);
	img_data = ori_img.img;
	load(regressor_path);
	Multi_Regessor = [ones(size(score,1),1), score];

	clean = reshape(img_data, [], size(img_data, 4));
	% ori = reshape(img_data, [], size(img_data, 4));
	clean = double(clean);

	for iii = 1:size(clean,1)
		[Beta,~,Residual] = regress(squeeze(clean(iii,:))',Multi_Regessor);
		clean(iii,:) = Residual + Beta(1);
	end
	clean_img = reshape(clean, size(img_data));
	ori_img.img = clean_img;
	save_untouch_nii(ori_img, clean_data_path);
end