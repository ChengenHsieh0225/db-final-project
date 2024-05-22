# conv2d_1

# inner product
SELECT SUM(I.value * W.weight) AS val 
	FROM I, W
    WHERE I.dim1=W.dim1 AND I.dim2=W.dim2;

delimiter //
CREATE PROCEDURE inner_product (IN dim1_shift INT, dim2_shift INT, OUT RESULT INT)
BEGIN
	SELECT SUM(I.value * W.weight) INTO result 
	FROM I, W
    WHERE (I.dim1+dim1_shift)=W.dim1 AND (I.dim2+dim2_shift)=W.dim2;
END //
delimiter ;

CALL inner_product(1, 2, @RESULT);
SELECT @RESULT;


