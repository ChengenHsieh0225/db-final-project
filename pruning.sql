CREATE VIEW conv2d_1_weights_pruned AS
	SELECT * FROM conv2d_1_weights
    WHERE filter_index NOT IN (1, 2);

DROP PROCEDURE IF EXISTS conv2d_part_1;
DELIMITER //
CREATE PROCEDURE conv2d_part_1 (IN input_image VARCHAR(40), IN dim1_shift INT, IN dim2_shift INT)
BEGIN
    SET @test2 = CONCAT(
        'INSERT INTO conv2d_1_output (image_index, dim1, dim2, channel, value) ', 
        'SELECT ',
            'I.image_index, ',
            '3*FLOOR((I.dim1 - ', dim1_shift, ') / 3) + ', dim1_shift, ' AS dim1, ',
            '3*FLOOR((I.dim2 - ', dim2_shift, ') / 3) + ', dim2_shift, ' AS dim2, ',
            'W.filter_index AS channel, ',
            'SUM(I.value * W.weight) + B.weight ',
        'FROM ', input_image, ' AS I, ',
            'conv2d_1_weights_pruned AS W, ',
            'conv2d_1_biases AS B ',
        'WHERE ',
            '(I.dim1 - ', dim1_shift, ') % 3 = W.dim1 ',
            'AND (I.dim2 - ', dim2_shift, ') % 3 = W.dim2 ',
            'AND W.filter_index = B.filter_index ',
            'AND I.channel = W.channel ',
        'GROUP BY I.image_index, dim1, dim2, channel'
    );

    PREPARE stmtconv FROM @test2;
    EXECUTE stmtconv;
    DEALLOCATE PREPARE stmtconv;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS dense_2;
delimiter //
CREATE PROCEDURE dense_2(IN channels INT)
BEGIN
	INSERT INTO dense_2_output_1
	SELECT
        I.image_index,
		W.filter_index AS dim1,		
		SUM(I.value * W.weight) + B.weight AS value
	FROM
		dense_1_output AS I,
        dense_2_weights AS W,
        dense_2_biases AS B
    WHERE
		I.dim1=W.dim1        
        AND W.filter_index = B.filter_index
        AND channels = W.filter_index
    GROUP BY I.image_index, W.filter_index;
END //
delimiter ;

#dense softmax
DROP PROCEDURE IF EXISTS softmax;
delimiter //
CREATE PROCEDURE softmax()
BEGIN
	UPDATE dense_2_output_1 SET value = EXP(value);

	TRUNCATE TABLE denominators;
	INSERT INTO denominators
    SELECT image_index, SUM(value)
	FROM dense_2_output_1
	GROUP BY image_index;
    
    UPDATE dense_2_output_1 SET value = value / 
    (
		SELECT value FROM denominators WHERE dense_2_output_1.image_index = denominators.image_index
    );
    
END //
delimiter ;

DROP PROCEDURE IF EXISTS dense_2_process;
delimiter //
CREATE PROCEDURE dense_2_process()
BEGIN
    DECLARE i INT DEFAULT 0; 
    TRUNCATE TABLE dense_2_output_1;
    WHILE i<10 DO
		CALL dense_2(i);
        SET i = i + 1;
	END WHILE;
    CALL softmax();
END //
delimiter ;

DROP TABLE IF EXISTS dense_2_output_1;
CREATE TABLE IF NOT EXISTS dense_2_output_1 (
    image_index INT,
    dim1 INT,
    value FLOAT,
    PRIMARY KEY (image_index, dim1)
);

CREATE VIEW result_1 AS
SELECT  image_index, dim1 FROM dense_2_output_1 AS t1 
WHERE value =(
	SELECT MAX(value)
    FROM dense_2_output_1 AS t2
    WHERE t2.image_index = t1.image_index
);


CALL conv2d_1('input_image_batch');
CALL maxpooling2d_1_process();
CALL conv2d_2();
CALL maxpooling2d_2_process();
CALL flatten();
CALL dense_1_process();
CALL dense_2_process();

SELECT
	l.image_index,
    r0.dim1 AS output_0,
    r1.dim1 AS output_1,
    label
FROM result AS r0
JOIN result_1 AS r1 ON r0.image_index = r1.image_index
JOIN image_label AS l ON l.image_index = r1.image_index
WHERE r0.dim1 <> r1.dim1;