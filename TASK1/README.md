# Digital Image Processing Lab - Task 1

This folder contains the MATLAB implementations and outputs for Task 1 of the Digital Image Processing Lab.

## Experiments

### 1. Hello World

A basic MATLAB program to understand script execution and the MATLAB environment.

### 2. Tambola Ticket Generation

A random Tambola ticket is generated using `randperm()`.

The generated ticket follows the basic Tambola ticket conditions:

- 3 rows and 9 columns
- 5 numbers in each row
- 15 numbers in total
- At least one number in every column
- Numbers in each column are arranged in ascending order
- Numbers are selected according to their respective column ranges

### 3. RGB Image Processing and Grayscale Conversion

An RGB image is read using `imread()`.

The individual Red, Green and Blue channels are extracted and displayed separately.

The RGB image is converted into grayscale using different approaches to understand the effect of different grayscale conversion methods.

### 4. Histogram Equalization

Histogram equalization is implemented manually using:

- Histogram
- Probability Density Function (PDF)
- Cumulative Distribution Function (CDF)
- Intensity mapping

The manual implementation is also compared with MATLAB's built-in `histeq()` function.

## Input Image

The experiments involving image processing use `autumn.png` as the input image.

## Tools Used

- MATLAB
- Image Processing Toolbox
- GitHub

## Folder Structure

```text
LAB1/
├── README.md
├── hello_world.m
├── tambola_ticket.m
├── rgb_to_gray.m
├── histogram_equalization.m
├── autumn.png
└── outputs/
    ├── rgb_to_gray_output.png
    └── histogram_equalization_output.png
