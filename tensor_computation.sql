# ReLu
delimiter //
CREATE PROCEDURE relu (tableName VARCHAR(50))
BEGIN
    SET @query = CONCAT(
		'DELETE FROM ', tableName, ' WHERE value < 0'
    );
    PREPARE stmt FROM @query;
    EXECUTE stmt;
END //
delimiter ;



# inner product for conv2d
delimiter //
CREATE PROCEDURE inner_product_conv2d (dim1_shift INT, dim2_shift INT, I VARCHAR(50), W VARCHAR(50), OUT result FLOAT)
BEGIN
    SET @query = CONCAT(
        'SELECT SUM(', I, '.value * ', W, '.weight) INTO @result FROM ', I, ', ', W, 
        ' WHERE (', I, '.dim1 + ', dim1_shift, ') = ', W, '.dim1 AND (', 
        I, '.dim2 + ', dim2_shift, ') = ', W, '.dim2 AND ', I, '.channel = ', W, '.channel'
    );
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    SET result = @result;
END //
delimiter ;

# conv2d layer 1
delimiter //
CREATE PROCEDURE conv2d_1(IN dim1_size INT, IN dim2_size INT)
BEGIN
	DECLARE dim1, dim2 INT;
    SET @result = 0;
	SET dim1 = 0;
	loop1: LOOP
		IF dim1 < dim1_size THEN
			SET dim2 = 0;
            loop2: LOOP
				IF dim2 < dim2_size THEN
					CALL inner_product_conv2d(dim1, dim2, 'input_image', 'conv2d_1_weights', @RESULT);
                    INSERT INTO conv2d_1_output VALUES (dim1, dim2, channel, @RESULT);
					SET dim2 = dim2 + 1;
					ITERATE loop2;
				END IF;
                LEAVE loop2;
			END LOOP loop2;
            SET dim1 = dim1 + 1;
			ITERATE loop1;
		END IF;
		LEAVE loop1;
    END LOOP loop1;
END //
delimiter ;




# for debug

SET SQL_SAFE_UPDATES=0;
DELETE FROM conv2d_1_weights WHERE weight < 0;
CALL conv2d_1(3, 3);

DROP PROCEDURE inner_product_conv2d;
DROP PROCEDURE conv2d_1;

CALL inner_product_conv2d(0, 0, 'input_image', 'conv2d_1_weights', @RESULT);

SELECT * FROM conv2d_1_output;
DELETE FROM conv2d_1_output;

