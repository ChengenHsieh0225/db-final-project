# drop old database
DROP DATABASE IF EXISTS final_project;

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
-- CREATE TABLE IF NOT EXISTS input_image_transpos (
--     image_index INT,
--     dim1 INT,
--     dim2 INT,
--     channel INT,
--     value FLOAT,
--     CHECK (value >= 0 AND value <= 1)
-- );
-- INSERT INTO input_image_transpos (image_index, dim1, dim2, channel, value)
-- SELECT img.image_index, img.dim2, img.dim1, img.channel, img.value
-- FROM input_image AS img;

-- CREATE TABLE IF NOT EXISTS input_image_test (
--     image_index INT,
--     dim1 INT,
--     dim2 INT,
--     channel INT,
--     value FLOAT,
--     CHECK (value >= 0 AND value <= 1)
-- );

# image labels
CREATE TABLE IF NOT EXISTS image_label (
	image_index INT PRIMARY KEY,
    label INT
);

# store the output of each layer
CREATE TABLE IF NOT EXISTS conv2d_1_output (
    image_index INT,
    dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT,
    PRIMARY KEY (image_index, dim1, dim2, channel)
);

CREATE TABLE IF NOT EXISTS max_pooling_1_output (
    image_index INT,
    dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT,
    PRIMARY KEY (image_index, dim1, dim2, channel)
);
CREATE TABLE IF NOT EXISTS conv2d_2_output (
    image_index INT,
    dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT,
    PRIMARY KEY (image_index, dim1, dim2, channel)
);
CREATE TABLE IF NOT EXISTS max_pooling_2_output (
    image_index INT,
    dim1 INT,
    dim2 INT,
    channel INT,
    value FLOAT,
    PRIMARY KEY (image_index, dim1, dim2, channel)
);

CREATE TABLE IF NOT EXISTS flatten_output (
    image_index INT,
    dim1 INT,
    value FLOAT,
    PRIMARY KEY (image_index, dim1)
);
CREATE TABLE IF NOT EXISTS dense_1_output (
    image_index INT,
    dim1 INT,
    value FLOAT,
    PRIMARY KEY (image_index, dim1)
);
CREATE TABLE IF NOT EXISTS dense_2_output (
    image_index INT,
    dim1 INT,
    value FLOAT,
    PRIMARY KEY (image_index, dim1)
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
    dim1 INT,
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

# store the DENOMINATOR for softmax
CREATE TABLE IF NOT EXISTS denominators (
	image_index INT PRIMARY KEY,
    value FLOAT
);
