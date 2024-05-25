# inner product for conv2d
delimiter //
CREATE PROCEDURE inner_product_conv2d (IN dim1_shift INT, IN dim2_shift INT, IN I VARCHAR(50), IN W VARCHAR(50), OUT RESULT FLOAT)
BEGIN
	DECLARE query VARCHAR(255);
	SET query = 'SELECT SUM(' + I + '.value * ' + W + '.weight) INTO RESULT FROM ' + I + ', ' + W
    + 'WHERE (' + I + '.dim1 + dim1_shift) = ' + W + '.dim1 AND (' + I + '.dim2 + dim2_shift) = ' + W + '.dim2 AND (' + I + '.channel = ' + W + '.channel)';
    EXECUTE query;
END //
delimiter ;

# conv2d layer 1
delimiter //
CREATE PROCEDURE conv2d_1(IN dim1_size INT, IN dim2_size INT)
BEGIN
	SET dim1 = 0;
	loop1: LOOP
		IF dim1 < dim1_size THEN
			SET dim2 = 0;
            loop2: LOOP
				IF dim2 < dim2_size THEN
					CALL inner_product_conv2d(dim1, dim2, 'input_image', 'conv2d_1_weights', @RESULT);
                    INSERT INTO conv2d_1_output VALUES (dim1, dim2, channel, RESULT);
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



