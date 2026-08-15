import numpy as np
from PIL import Image, ImageOps
import matplotlib.pyplot as plt
from io import BytesIO


# =========================================================
# RGB TO GRAYSCALE
# =========================================================

def rgb_to_grayscale(img_array):
    """
    Convert an RGB image into grayscale using
    different commonly used methods.
    """

    # Extract individual RGB channels
    R = img_array[:, :, 0]
    G = img_array[:, :, 1]
    B = img_array[:, :, 2]

    # -----------------------------------------------------
    # Create coloured versions of individual channels
    # -----------------------------------------------------
    # The channel is kept while the other two channels
    # are set to zero. This makes the colour contribution
    # of each channel easier to visualize.

    red_image = np.zeros_like(img_array)
    red_image[:, :, 0] = R

    green_image = np.zeros_like(img_array)
    green_image[:, :, 1] = G

    blue_image = np.zeros_like(img_array)
    blue_image[:, :, 2] = B

    # -----------------------------------------------------
    # Convert to float for arithmetic operations
    # -----------------------------------------------------

    R_float = R.astype(float)
    G_float = G.astype(float)
    B_float = B.astype(float)

    # -----------------------------------------------------
    # 1. Red channel method
    # -----------------------------------------------------

    gray_R = R

    # -----------------------------------------------------
    # 2. Green channel method
    # -----------------------------------------------------

    gray_G = G

    # -----------------------------------------------------
    # 3. Blue channel method
    # -----------------------------------------------------

    gray_B = B

    # -----------------------------------------------------
    # 4. Average method
    # -----------------------------------------------------

    gray_average = (
        R_float +
        G_float +
        B_float
    ) / 3

    gray_average = np.uint8(gray_average)

    # -----------------------------------------------------
    # 5. Weighted average / luminance method
    # -----------------------------------------------------
    # Human vision is more sensitive to green, so green
    # gets the highest weight.

    gray_weighted = (
        0.299 * R_float +
        0.587 * G_float +
        0.114 * B_float
    )

    gray_weighted = np.uint8(gray_weighted)

    # -----------------------------------------------------
    # 6. Maximum channel method
    # -----------------------------------------------------

    gray_max = np.maximum(
        np.maximum(R_float, G_float),
        B_float
    )

    gray_max = np.uint8(gray_max)

    # -----------------------------------------------------
    # 7. Minimum channel method
    # -----------------------------------------------------

    gray_min = np.minimum(
        np.minimum(R_float, G_float),
        B_float
    )

    gray_min = np.uint8(gray_min)

    # -----------------------------------------------------
    # 8. MATLAB-style standard grayscale conversion
    # -----------------------------------------------------

    original_image = Image.fromarray(img_array)

    gray_builtin = np.array(
        original_image.convert("L")
    )

    # -----------------------------------------------------
    # Return all results to the GUI
    # -----------------------------------------------------

    return {

        "Original RGB":
            Image.fromarray(img_array),

        # Coloured channel visualizations
        "Red Channel":
            Image.fromarray(red_image),

        "Green Channel":
            Image.fromarray(green_image),

        "Blue Channel":
            Image.fromarray(blue_image),

        # Grayscale conversion methods
        "Red Method":
            Image.fromarray(gray_R),

        "Green Method":
            Image.fromarray(gray_G),

        "Blue Method":
            Image.fromarray(gray_B),

        "Average Method":
            Image.fromarray(gray_average),

        "Weighted Method":
            Image.fromarray(gray_weighted),

        "Maximum Method":
            Image.fromarray(gray_max),

        "Minimum Method":
            Image.fromarray(gray_min),

        "Grayscale":
            Image.fromarray(gray_builtin),
    }


# =========================================================
# HISTOGRAM EQUALIZATION
# =========================================================

def histogram_equalization(img_array):
    """
    Perform manual histogram equalization and compare
    the result with the built-in equalization method.
    """

    # Convert RGB image to grayscale
    original_image = Image.fromarray(img_array)

    gray = np.array(
        original_image.convert("L")
    )

    # -----------------------------------------------------
    # Find histogram
    # -----------------------------------------------------

    histogram = np.bincount(
        gray.flatten(),
        minlength=256
    )

    # Normalize histogram to obtain probability
    pdf = histogram / gray.size

    # Calculate cumulative distribution function
    cdf = np.cumsum(pdf)

    # Create intensity mapping
    mapping = np.round(
        255 * cdf
    ).astype(np.uint8)

    # Apply mapping to every pixel
    manual_equalized = mapping[gray]

    # Built-in histogram equalization
    builtin_equalized = np.array(
        ImageOps.equalize(
            Image.fromarray(gray)
        )
    )

    # Create histogram images
    original_histogram = create_histogram_image(
        gray,
        "Original Histogram"
    )

    manual_histogram = create_histogram_image(
        manual_equalized,
        "Manual Equalized Histogram"
    )

    builtin_histogram = create_histogram_image(
        builtin_equalized,
        "Built-in Equalized Histogram"
    )

    # Return results
    return {

        "Original Grayscale":
            Image.fromarray(gray),

        "Manual Equalization":
            Image.fromarray(manual_equalized),

        "Built-in Equalization":
            Image.fromarray(builtin_equalized),

        "Original Histogram":
            original_histogram,

        "Manual Equalized Histogram":
            manual_histogram,

        "Built-in Equalized Histogram":
            builtin_histogram,
    }


# =========================================================
# CREATE HISTOGRAM IMAGE
# =========================================================

def create_histogram_image(gray_image, title):
    """
    Create a histogram using matplotlib and convert
    it into a PIL image for displaying in the GUI.
    """

    figure = plt.figure(
        figsize=(5, 3)
    )

    plt.hist(
        gray_image.flatten(),
        bins=256,
        range=(0, 255)
    )

    plt.title(title)
    plt.xlabel("Intensity")
    plt.ylabel("Number of Pixels")

    plt.tight_layout()

    # Store the graph temporarily in memory
    buffer = BytesIO()

    figure.savefig(
        buffer,
        format="png",
        dpi=120
    )

    plt.close(figure)

    buffer.seek(0)

    return Image.open(
        buffer
    ).convert("RGB")


# =========================================================
# TASK 1 OPERATIONS
# =========================================================

def get_task1_operations():
    """
    Return all Task 1 operations to the main application.
    """

    return {

        "Task 1 - RGB to Grayscale":
            rgb_to_grayscale,

        "Task 1 - Histogram Equalization":
            histogram_equalization,
    }