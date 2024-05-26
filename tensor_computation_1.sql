-- ver.1 : DELETE
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
		input_image AS I,
        conv2d_1_weights AS W,
        conv2d_1_biases AS B
    WHERE
		(I.dim1-dim1_shift)%3=W.dim1
        AND (I.dim2-dim2_shift)%3=W.dim2
        AND W.filter_index = B.filter_index
    GROUP BY 1, 2, 3;
END //
delimiter ;

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

CALL conv2d_1_process(); -- 234.714 sec


-- ver.2 : ugly WHERE clause

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
		input_image AS I,
        conv2d_1_weights AS W,
        conv2d_1_biases AS B
    WHERE
		(I.dim1 >= dim1_shift AND I.dim1 <= 25+(dim1_shift+1)%3)
        AND (I.dim2 >= dim2_shift AND I.dim2 <= 25+(dim2_shift+1)%3)
		AND (I.dim1-dim1_shift)%3=W.dim1
        AND (I.dim2-dim2_shift)%3=W.dim2
        AND W.filter_index = B.filter_index
    GROUP BY 1, 2, 3;
END //
delimiter ;

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
    -- relu
    DELETE FROM conv2d_1_output WHERE value <= 0;
END //
delimiter ;

CALL conv2d_1_process(); -- 232.075 sec


-- delete all

DELETE FROM conv2d_1_output;