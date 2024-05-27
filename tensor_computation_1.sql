CREATE VIEW input_image_batch AS
	SELECT *
	FROM input_image
	WHERE image_index >= 0 AND image_index <= 0+750;

# conv2d_1
DROP PROCEDURE IF EXISTS conv2d_part_1;
DELIMITER //
CREATE PROCEDURE conv2d_part_1 (IN dim1_shift INT, dim2_shift INT)
BEGIN
	INSERT INTO conv2d_1_output
	SELECT
		3*FLOOR((I.dim1-dim1_shift)/3)+dim1_shift AS dim1,
		3*FLOOR((I.dim2-dim2_shift)/3)+dim2_shift AS dim2,
		W.filter_index AS channel,
		SUM(I.value * W.weight) + B.weight
	FROM
		input_image_batch AS I,
        conv2d_1_weights AS W,
        conv2d_1_biases AS B
    WHERE
		(I.dim1-dim1_shift)%3=W.dim1
        AND (I.dim2-dim2_shift)%3=W.dim2
        AND W.filter_index = B.filter_index
        AND I.channel = W.channel
    GROUP BY 1, 2, 3;
END //
DELIMITER ;

-- CALL conv2d_part_1(2, 1);

DROP PROCEDURE IF EXISTS conv2d_1_process;
DELIMITER //
CREATE PROCEDURE conv2d_1_process ()
BEGIN
	DECLARE i int default 0;
    DECLARE j int default 0;
	WHILE i<3 DO
		WHILE j<3 DO
			CALL conv2d_part_1(i, j);
            SET j = j+1;
		END WHILE;
		SET i = i+1;
	END WHILE;
    DELETE FROM conv2d_1_output WHERE (dim1<0 or dim1>=26) or (dim2<0 or dim2>=26);
    -- relu
    DELETE FROM conv2d_1_output WHERE value <= 0;
END //
DELIMITER ;

# maxPooling2d_1
DROP PROCEDURE IF EXISTS maxpooling2d_1;
DROP PROCEDURE IF EXISTS maxpooling2d_1_process;
DELIMITER //
CREATE PROCEDURE maxpooling2d_1 (IN channels INT)
BEGIN
	INSERT INTO max_pooling_1_output 
	SELECT 
    FLOOR(output.dim1 / 2) AS dim1,
    FLOOR(output.dim2 / 2) AS dim2,
    channels AS channel,
    MAX(value) AS value
    FROM conv2d_1_output AS output
    WHERE  output.channel = channels
	GROUP BY 
        FLOOR(output.dim1 / 2), FLOOR(output.dim2 / 2);
END //

CREATE PROCEDURE maxpooling2d_1_process()
BEGIN
	DECLARE i int default 0;   
    # Delete previous values
    TRUNCATE TABLE max_pooling_1_output;

	WHILE i<13 DO
		CALL maxpooling2d_1(i);
		SET i = i+1;
	END WHILE;
    
END //
DELIMITER ;

# conv2d_2
DROP PROCEDURE IF EXISTS conv2d_part_2;
DROP PROCEDURE IF EXISTS conv2d_2;
DELIMITER //
CREATE PROCEDURE conv2d_part_2 (IN dim1_shift INT, dim2_shift INT)
BEGIN
	INSERT INTO conv2d_2_output
	SELECT
		3*FLOOR((I.dim1-dim1_shift)/3)+dim1_shift AS dim1,
		3*FLOOR((I.dim2-dim2_shift)/3)+dim2_shift AS dim2,
		W.filter_index AS channel,
		SUM(I.value * W.weight) + B.weight
	FROM
		max_pooling_1_output AS I,
        conv2d_2_weights AS W,
        conv2d_2_biases AS B
    WHERE
		(I.dim1-dim1_shift)%3=W.dim1
        AND (I.dim2-dim2_shift)%3=W.dim2
        AND W.filter_index = B.filter_index
        AND I.channel = W.channel
    GROUP BY 1, 2, 3;
END //

CREATE PROCEDURE conv2d_2 ()
BEGIN
	DECLARE i int default 0;
    DECLARE j int default 0;
    
    TRUNCATE TABLE conv2d_1_output;
	WHILE i<3 DO
		SET j = 0;
		WHILE j<3 DO
			CALL conv2d_part_2(i, j);
            SET j = j+1;
		END WHILE;
		SET i = i+1;
	END WHILE;
    DELETE FROM conv2d_2_output WHERE (dim1<0 or dim1>=11) or (dim2<0 or dim2>=11);
    -- relu
    DELETE FROM conv2d_2_output WHERE value <= 0;
END //
DELIMITER ;

# maxPooling2d_2
DROP PROCEDURE IF EXISTS maxpooling2d_2;
DROP PROCEDURE IF EXISTS maxpooling2d_2_process;
DROP PROCEDURE IF EXISTS init_maxpooling2d_2;
DELIMITER //

CREATE PROCEDURE init_maxpooling2d_2 ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE k INT DEFAULT 0;

    -- Delete previous values
    TRUNCATE TABLE max_pooling_2_output;
    WHILE i < 5 DO
        WHILE j < 5 DO
            WHILE k < 4 DO
                INSERT INTO max_pooling_2_output (dim1, dim2, channel, value)
                VALUES (i, j, k, 0);
                SET k = k + 1;
            END WHILE;
            SET j = j + 1;
            SET k = 0; -- Reset k for next iteration of j
        END WHILE;
        SET i = i + 1;
        SET j = 0; -- Reset j for next iteration of i
    END WHILE;
END //

CREATE PROCEDURE maxpooling2d_2 (IN channels INT)
BEGIN
    INSERT INTO max_pooling_2_output (dim1, dim2, channel, value)
    SELECT 
        FLOOR(output.dim1 / 2) AS dim1,
        FLOOR(output.dim2 / 2) AS dim2,
        channels AS channel,
        MAX(value) AS value
    FROM conv2d_2_output AS output
    WHERE  output.channel = channels
    GROUP BY 
        FLOOR(output.dim1 / 2), FLOOR(output.dim2 / 2)
    ON DUPLICATE KEY UPDATE 
        value = VALUES(value);
END //

CREATE PROCEDURE maxpooling2d_2_process()
BEGIN
	DECLARE i int default 0;   
    # Delete previous values
    CALL init_maxpooling2d_2();
	WHILE i<13 DO
		CALL maxpooling2d_2(i);
		SET i = i+1;
	END WHILE;
    DELETE FROM max_pooling_2_output WHERE (dim1 >= 5) OR (dim2 >= 5);
END //
DELIMITER ;


# flattern
DROP PROCEDURE flattern;
CREATE PROCEDURE flattern()
	INSERT INTO flatten_output
	SELECT 0 AS dim1, value
	FROM max_pooling_2_output
	ORDER BY dim1, dim2, channel;

DELIMITER //
CREATE PROCEDURE cnn_train()
BEGIN
	CALL conv2d_1();
    CALL maxpooling2d_1_process();
    CALL conv2d_2();
    CALL maxpooling2d_2_process();
	CALL flattern();
END //
<<<<<<< HEAD
delimiter ;
CALL flattern();

#dense: relu
DROP PROCEDURE relu;
DROP PROCEDURE relu_process;
delimiter //
CREATE PROCEDURE relu(IN channels INT)
BEGIN
	INSERT INTO dense_1_output
	SELECT
		W.filter_index AS dim1,		
		SUM(I.value * W.weight) + B.weight AS value
	FROM
		flatten_output AS I,
        dense_1_weights AS W,
        dense_1_biases AS B
    WHERE
		I.dim1=W.dim1        
        AND W.filter_index = B.filter_index
        AND channels = W.filter_index
    GROUP BY W.filter_index;
END //
delimiter ;

delimiter //
CREATE PROCEDURE relu_process()
BEGIN
    DECLARE i INT DEFAULT 0; 
    TRUNCATE TABLE dense_1_output;
    WHILE i<16 DO
		CALL relu(i);
        SET i = i + 1;
	END WHILE;
    UPDATE dense_1_output SET value = 0 WHERE value < 0;
END //
delimiter ;
CALL relu_process();

#dense softmax
DROP PROCEDURE softmax;
DROP PROCEDURE predict;
delimiter //
CREATE PROCEDURE softmax(IN channels INT)
BEGIN
	INSERT INTO dense_2_output
	SELECT
		W.filter_index AS dim1,		
		SUM(I.value * W.weight) + B.weight AS value
	FROM
		dense_1_output AS I,
        dense_2_weights AS W,
        dense_2_biases AS B
    WHERE
		I.dim1=W.dim        
        AND W.filter_index = B.filter_index
        AND channels = W.filter_index
    GROUP BY W.filter_index;
END //
delimiter ;
SELECT COUNT(value)  FROM dense_2_output;

delimiter //
CREATE PROCEDURE predict()
BEGIN
	DECLARE value_count FLOAT;
	SELECT SUM(value) INTO value_count FROM dense_2_output;
    IF value_count > 0 THEN
        UPDATE dense_2_output SET value = (value / value_count);
    END IF;
    
END //
delimiter ;


delimiter //
CREATE PROCEDURE softmax_process()
BEGIN
    DECLARE i INT DEFAULT 0; 
    TRUNCATE TABLE dense_2_output;
    TRUNCATE TABLE predictions;
    WHILE i<10 DO
		CALL softmax(i);
        SET i = i + 1;
	END WHILE;
    UPDATE dense_2_output SET value = 0 WHERE value < 0;
    CALL predict();
END //
delimiter ;
CALL softmax_process();

# delete all
DELETE FROM conv2d_1_output;
DELETE FROM conv2d_2_output;
=======
DELIMITER ;
>>>>>>> b2d7f1a0e04bd14491161a2937f26623ad54807b
