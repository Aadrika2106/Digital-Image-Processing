# Image Processing - Task 4

This folder contains MATLAB implementations and outputs for first-order and second-order edge detection techniques.

## Experiments

### 1. First-Order Edge Detection

First-order edge detection techniques are implemented using gradient-based operators to detect edges by identifying regions of rapid intensity change.

The following operators are implemented:

- **Roberts Operator**
- **Sobel Operator**
- **Prewitt Operator**

For each operator, a manual implementation is compared with the corresponding MATLAB built-in edge detection method.

The output includes:

- Original image
- Grayscale image
- Manual Roberts, Sobel and Prewitt edge detection
- MATLAB built-in Roberts, Sobel and Prewitt edge detection

### 2. Second-Order Edge Detection

Second-order edge detection techniques are implemented using the second derivative of image intensity.

The following techniques are included:

- **Laplacian of Gaussian (LoG)**
- **Difference of Gaussians (DoG)**
- **Zero-Crossing Edge Detection**

#### Laplacian of Gaussian (LoG)

LoG combines Gaussian smoothing with the Laplacian operator to detect edges while reducing the effect of noise.

The implementation includes:

- Manual generation of the Gaussian kernel
- Manual generation of the LoG kernel
- Manual LoG filtering
- Zero-crossing detection of the LoG response
- MATLAB built-in LoG edge detection

#### Difference of Gaussians (DoG)

DoG is implemented by subtracting two Gaussian-smoothed versions of the image using different standard deviations.

The implementation includes:

- Generation of two Gaussian kernels
- Gaussian smoothing using both kernels
- Calculation of the DoG response
- Zero-crossing detection of the DoG response
- Comparison with MATLAB-based Gaussian filtering

#### Zero-Crossing Detection

Zero-crossing detection is applied to the LoG and DoG filter responses to obtain the final edge locations.

A zero crossing is detected when the filter response changes sign in a local neighbourhood, with a threshold used to reduce insignificant detections.

## Output Visualization

For first-order edge detection, the output figures compare the manual and MATLAB built-in implementations of Roberts, Sobel and Prewitt operators.

For second-order edge detection, the output figures contain:

1. Original image
2. LoG Manual Response
3. LoG Zero Crossing / Final Manual Edge
4. LoG Built-in
5. Grayscale image
6. DoG Manual Response
7. DoG Zero Crossing / Final Manual Edge
8. DoG Built-in

## Performance Analysis

The programs also calculate and display performance information including:

- Total execution time
- MATLAB variable memory usage
- CPU core information
- Available system RAM
- Maximum MATLAB array memory
- Time complexity
- Memory leakage indicator

The filtering and zero-crossing operations are considered to have an overall theoretical time complexity of **O(N)**, where `N` is the number of image pixels.

## Input Images

The experiments use the following input images:

- `cameraman.jpg`
- `coins.jpg`

## Tools Used

- MATLAB
- Image Processing Toolbox
- GitHub

## Folder Structure

```text
Task4/
│
├── README.md
├── cameraman.jpg
├── coins.jpg
├── first_order_edge_detection.m
├── second_order_edge_detection.m
│
└── Outputs/
    │
    ├── first_order_comparison_cameraman.png
    ├── first_order_comparison_coins.png
    ├── first_order_cmd.jpeg
    ├── second_order_comparison_cameraman.png
    ├── second_order_comparison_coins.png
    └── second_order_cmd.jpeg
