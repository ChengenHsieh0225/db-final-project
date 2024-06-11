USE final_project;
CALL conv2d_1('input_image_batch');
CALL maxpooling2d_1_process();
CALL conv2d_2();
CALL maxpooling2d_2_process();
CALL flatten();
CALL dense_1_process();
CALL dense_2_process();
    
DROP VIEW IF EXISTS result;
CREATE VIEW result AS
SELECT  image_index, dim1 FROM dense_2_output AS t1 
WHERE value =(
	SELECT MAX(value)
    FROM dense_2_output AS t2
    WHERE t2.image_index = t1.image_index
);

SELECT * from result NATURAL JOIN image_label;
SELECT * from result NATURAL JOIN image_label WHERE dim1 <> label;