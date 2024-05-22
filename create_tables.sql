CREATE DATABASE final_project;
USE final_project;

# input images
CREATE TABLE input_image (
	image_index INT,
    dim1 INT,
    dim2 INT,
    value INT,
    CHECK (value >= 0 AND value <= 255)
);

# store the output of each layer
CREATE TABLE conv2d_1_output (
	dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT
);
CREATE TABLE max_pooling_1_output (
	dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT
);
CREATE TABLE conv2d_2_output (
	dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT
);
CREATE TABLE max_pooling_2_output (
	dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT
);
CREATE TABLE flatten_output (
	dim1 INT,
    value FLOAT
);
CREATE TABLE dense_1_output (
	dim1 INT,
    value FLOAT
);
CREATE TABLE dense_2_output (
	dim1 INT,
    value FLOAT
);

# store the weights for each layer
CREATE TABLE conv2d_1_weights (
	filter_index INT,
    dim1 INT,
    dim2 INT,
    weight FLOAT
);
CREATE TABLE conv2d_2_weights (
	filter_index INT,
    dim1 INT,
    dim2 INT,
    weight FLOAT
);
CREATE TABLE dense_1_weights (
	dim1 INT,
    weight FLOAT
);
CREATE TABLE dense_2_weights (
	dim INT,
    weight FLOAT
);

# store the predictions of the current batch
CREATE TABLE predictions (
	data_index INT PRIMARY KEY,
    value1 FLOAT, value2 FLOAT, value3 FLOAT, value4 FLOAT, value5 FLOAT,
    value6 FLOAT, value7 FLOAT, value8 FLOAT, value9 FLOAT, value10 FLOAT
);