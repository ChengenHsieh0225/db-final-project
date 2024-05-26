CREATE DATABASE IF NOT EXISTS final_project;
USE final_project;

# input images
CREATE TABLE IF NOT EXISTS input_image (
	image_index INT,
    dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT,
    CHECK (value >= 0 AND value <= 1)
);
DROP TABLE input_image;

# store the output of each layer
CREATE TABLE IF NOT EXISTS conv2d_1_output (
	dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT
);
CREATE TABLE IF NOT EXISTS max_pooling_1_output (
	dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT
);
CREATE TABLE IF NOT EXISTS conv2d_2_output (
	dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT
);
CREATE TABLE IF NOT EXISTS max_pooling_2_output (
	dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT
);
CREATE TABLE IF NOT EXISTS flatten_output (
	dim1 INT,
    value FLOAT
);
CREATE TABLE IF NOT EXISTS dense_1_output (
	dim1 INT,
    value FLOAT
);
CREATE TABLE IF NOT EXISTS dense_2_output (
	dim1 INT,
    value FLOAT
);

# store the weights for each layer
CREATE TABLE IF NOT EXISTS conv2d_1_weights (
	filter_index INT,
    dim1 INT,
    dim2 INT,
    channel INT,
    weight FLOAT,
    PRIMARY KEY (filter_index, dim1, dim2, channel)
);
DROP TABLE conv2d_1_weights;
CREATE TABLE IF NOT EXISTS conv2d_2_weights (
	filter_index INT,
    dim1 INT,
    dim2 INT,
    channel INT,
    weight FLOAT,
    PRIMARY KEY (filter_index, dim1, dim2, channel)
);
CREATE TABLE IF NOT EXISTS dense_1_weights (
	filter_index INT,
	dim1 INT,
    weight FLOAT,
    PRIMARY KEY (filter_index, dim1)
);
CREATE TABLE IF NOT EXISTS dense_2_weights (
	filter_index INT,
	dim INT,
    weight FLOAT,
    PRIMARY KEY (filter_index, dim)
);

# store the biases for each layer
CREATE TABLE IF NOT EXISTS conv2d_1_biases (
	filter_index INT PRIMARY KEY,
    weight FLOAT
);
CREATE TABLE IF NOT EXISTS conv2d_2_biases (
	filter_index INT PRIMARY KEY,
    weight FLOAT
);
CREATE TABLE IF NOT EXISTS dense_1_biases (
	filter_index INT PRIMARY KEY,
    weight FLOAT
);
CREATE TABLE IF NOT EXISTS dense_2_biases (
	filter_index INT PRIMARY KEY,
    weight FLOAT
);

# store the predictions of the current batch
CREATE TABLE IF NOT EXISTS predictions (
	data_index INT PRIMARY KEY,
    value1 FLOAT, value2 FLOAT, value3 FLOAT, value4 FLOAT, value5 FLOAT,
    value6 FLOAT, value7 FLOAT, value8 FLOAT, value9 FLOAT, value10 FLOAT
);