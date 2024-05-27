CREATE VIEW input_image_batch AS
	SELECT *
	FROM input_image
	WHERE image_index >= 0 AND image_index <= 0+750;

# conv2d_1
DROP PROCEDURE IF EXISTS conv2d_part_1;
delimiter //
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
delimiter ;

-- CALL conv2d_part_1(2, 1);

DROP PROCEDURE IF EXISTS conv2d_1_process;
delimiter //
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
delimiter ;

CALL conv2d_1_process(); -- 7.386 sec


# conv2d_2
DROP PROCEDURE IF EXISTS conv2d_part_2;
DROP PROCEDURE IF EXISTS conv2d_2;
delimiter //
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

CREATE PROCEDURE conv2d_2 ()
BEGIN
	DECLARE i int default 0;
    DECLARE j int default 0;
	WHILE i<3 DO
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
delimiter ;

CALL conv2d_2();

# delete all
DELETE FROM conv2d_1_output;
DELETE FROM conv2d_2_output;