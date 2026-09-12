# Image Processing - Task 3

This folder contains MATLAB implementations and outputs for image transformation and image compression techniques.

## Experiments

### 1. Discrete Wavelet Transform (DWT)

Discrete Wavelet Transform is implemented to analyze an image at different frequency levels.

The grayscale image is decomposed into four sub-bands:

- **LL (Approximation):** Contains the low-frequency information of the image.
- **LH (Horizontal Details):** Contains horizontal edge information.
- **HL (Vertical Details):** Contains vertical edge information.
- **HH (Diagonal Details):** Contains diagonal and high-frequency information.

The original image and the resulting wavelet sub-bands are displayed for analysis.

### 2. Huffman Coding

Huffman Coding is implemented as a lossless image compression technique.

The grayscale image is analyzed to determine the frequency and probability of different pixel intensity values.

The process involves:

- Calculating the histogram of pixel intensities
- Determining the probability of each symbol
- Generating the Huffman dictionary
- Encoding the image using Huffman codes
- Decoding the encoded data
- Reconstructing the decoded image
- Comparing the original and decoded images to verify lossless reconstruction


### 3. Shannon-Fano Coding

Shannon-Fano Coding is implemented as a lossless image compression technique based on the probability of occurrence of image symbols.

The process involves:

- Calculating the frequency and probability of pixel intensity values
- Sorting symbols according to their probabilities
- Dividing the symbols into groups with approximately equal probabilities
- Assigning binary codes recursively
- Encoding the image using Shannon-Fano codes
- Decoding the encoded data
- Reconstructing the decoded image
- Verifying the decoded image against the original image

#### Performance parameters are calculated for analysis for both Huffman and Shannon Fano Coding, including:

- Entropy
- Average code length
- Coding efficiency
- Redundancy
- Compression ratio
- Compression percentage
- Encoding time
- Decoding time
- Memory usage

## Input Images

The experiments use the following input image:

- `autumn.png` - Input image used for DWT
- `clipart.jpg` - Input image used for Huffman Coding, and Shannon-Fano Coding

## Tools Used

- MATLAB
- Image Processing Toolbox
- Wavelet Toolbox
- GitHub

## Folder Structure

```text
Task3/
│
├── README.md
├── discrete_wavelet_transform.m
├── huffman_coding.m
├── shannon_fano_coding.m
├── autumn.png
├── clipart.jpg
│
└── Output/
    ├── dwt_output.png
    │
    ├── huffman_original_vs_decoded.png
    ├── huffman_code_length_analysis.png
    ├── huffman_symbol_frequency.png
    ├── huffman_metrics_summary.png
    └── huffman_codebook.png
    │
    ├── shannon_fano_original_vs_decoded.png
    ├── shannon_fano_code_length_analysis.png
    ├── shannon_fano_symbol_frequency.png
    ├── shannon_fano_metrics_summary.png
    └── shannon_fano_codebook.png
