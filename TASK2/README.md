# Image Processing - Task 2

This folder contains MATLAB implementations and outputs for image enhancement, image analysis, and digital watermarking techniques.

## Experiments

### 1. Bit-Plane Slicing

An 8-bit grayscale image is decomposed into its 8 individual bit planes using `bitget()`.

The bit planes are numbered from **Bit 0 (LSB)** to **Bit 7 (MSB)**.

- **Bit 0 (LSB)** contains the least significant information.
- **Bit 7 (MSB)** contains the most significant intensity information.
- Higher-order bit planes generally contain more of the important visual information of the image.
- Lower-order bit planes contain finer details and contribute less to the overall visual appearance.

The individual bit planes are extracted and displayed to observe how image information is distributed across different bits.

### 2. Histogram Equalization

Different histogram-based contrast enhancement techniques are implemented and compared.

#### Global Histogram Equalization

The entire image is treated as a single region and histogram equalization is applied using MATLAB's `histeq()` function.

#### Local Histogram Equalization

The image is divided into smaller blocks, and histogram equalization is applied independently to each block.

This allows contrast enhancement to depend on the local intensity distribution of different regions.

#### Adaptive Histogram Equalization

Contrast enhancement is performed according to the local characteristics of different regions of the image.

This is useful when different areas of an image have significantly different intensity distributions.

#### CLAHE

Contrast Limited Adaptive Histogram Equalization enhances local contrast while limiting excessive amplification.

The contrast limit helps prevent over-enhancement and excessive noise amplification in relatively uniform regions.

The original and processed images, along with their corresponding histograms, are displayed for comparison.

### 3. Digital Image Watermarking

A watermark is embedded into a cover image using the **Least Significant Bit (LSB)** technique.

The process involves:

- Reading the cover image and watermark image
- Converting the images to grayscale where required
- Converting the watermark into a binary image
- Embedding the watermark into the LSB of the cover image
- Generating the watermarked image
- Extracting the embedded watermark from the watermarked image

Since only the least significant bit is modified, the visual difference between the original and watermarked images is minimal.

## Input Images

The image processing experiments use the following input images:

- `autumn.png` - used for bit-plane slicing and histogram equalization
- `cover.png` - cover image used for watermarking
- `watermark.jpeg` - watermark image used for embedding

## Tools Used

- MATLAB
- Image Processing Toolbox
- GitHub

## Folder Structure

```text
Task2/
├── README.md
├── bit_plane_slicing.m
├── histogram_equalization.m
├── watermarking.m
├── autumn.png
├── cover.png
├── watermark.jpeg
│   
└── Output/
    ├── bit_plane_slicing_output.png
    ├── histogram_equalization_output.png
    └── watermarking_output.png
