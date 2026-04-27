import numpy as np
import SimpleITK as sitk
import matplotlib.pyplot as plt

def apply_window(image, wl, ww):
    lower = wl - ww / 2
    upper = wl + ww / 2
    windowed = np.clip(image, lower, upper)
    return windowed

def plot_volume(volume_path, wl, ww, mask_path=None, z_index=None):
    # Read and orient image
    ct_image = sitk.ReadImage(volume_path)
    ct_image = sitk.DICOMOrient(ct_image, "LPS")  # enforce standard orientation
    ct_np = sitk.GetArrayFromImage(ct_image)

    if mask_path:
        mask_image = sitk.ReadImage(mask_path)
        mask_image = sitk.DICOMOrient(mask_image, "LPS")  # IMPORTANT: same orientation
        mask_np = sitk.GetArrayFromImage(mask_image)

    def show_slice(idx):
        windowed_slice = apply_window(ct_np[idx], wl, ww)

        plt.imshow(windowed_slice, cmap="gray", origin="lower")  # fix display flip
        if mask_path:
            plt.imshow(mask_np[idx], alpha=0.4, origin="lower")

        plt.title(f"Slice {idx}")
        plt.axis("off")
        plt.show()

    if z_index is not None:
        show_slice(z_index)
    else:
        for i in range(ct_np.shape[0]):
            show_slice(i)