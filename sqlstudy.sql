-- 4. mileage 테이블에 type이라는 컬럼을 추가하고 각 레코드에 board라는 값을 업데이트한다.
ALTER table mileage ADD type varchar(50) NOT NULL;
UPDATE mileage SET type = 'board';

-- 5. 사용자 테이블을 최신 등록순으로 정렬하여 조회
SELECT * FROM user ORDER BY created_at DESC;

-- 6. 게시판 테이블의 조회수가 30이상인 것의 데이터를 높은 조회순으로 정렬하여 조회
SELECT * FROM board WHERE view_count >= 30 ORDER BY view_count DESC;

-- 7. 게시판 테이블의 높은 조회순으로 조회하고 상위 5개 레코드의 조회수를 합한 값을 total_count라는 별칭으로 조 회
SELECT SUM(view_count) AS total_count FROM 
		(SELECT view_count FROM board ORDER BY view_count DESC LIMIT 0, 5) AS top5;

-- 8. 게시판 테이블의 user_idx로 그룹핑하여 조회수의 합산값들을 조회하고 user_idx로 역정렬하여 조회. 합산값은 total_count라는 별칭으로 조회
SELECT user_idx, SUM(view_count) AS total_count FROM board GROUP BY user_idx ORDER BY user_idx DESC;

-- 9. 게시판 테이블의 user_idx로 그룹핑하여 조회수의 합산값 및 user_idx들을 조회하고 합산값이 높은순으로 조회 하고 합산값이 100이상인 값을 조회. 합산값은 total_count라는 별칭으로 조회
SELECT * FROM 
		(SELECT user_idx, SUM(view_count) AS total_count FROM board GROUP BY user_idx) AS total
	WHERE total_count >= 100 ORDER BY total_count DESC;

-- 10. 9번의 내용의 데이터에서 사용자 이름까지 노출하여 조회
SELECT b.user_idx, u.name, b.total_count FROM 
		(SELECT user_idx, SUM(view_count) AS total_count FROM board GROUP BY user_idx) b, user u
	WHERE b.total_count >= 100 AND u.idx = b.user_idx ORDER BY total_count DESC;

-- 11. 전체 사용자 마일리지 합산 정보를 total_mileage라는 별칭으로 조회, name, total_mileage
SELECT SUM(point) AS total_mileage FROM mileage;

-- 12. 사용자별 마일리지 합산 정보를 total_mileage라는 별칭으로 조회, name, total_mileage
SELECT 	u.name, m.total_mileage FROM
		(SELECT user_idx, SUM(point) AS total_mileage FROM mileage GROUP BY user_idx) m, user u
	WHERE m.user_idx = u.idx;

-- 13. 사용자별 name, 누적 마일리지, 게시글 수, 등록된 게시글의 조회수의 합을 하나의 쿼리로 조회 (inner query 찾 아서 사용해 보세요!)	
SELECT MI.name, MI.total_mileage, BO.content_count, BO.total_view_count FROM
		(SELECT m.user_idx, u.name, m.total_mileage FROM
			(SELECT user_idx, SUM(point) AS total_mileage FROM mileage GROUP BY user_idx) m, user u
		WHERE m.user_idx = u.idx) MI
	INNER JOIN
		(SELECT user_idx, COUNT(idx) AS content_count, SUM(view_count) AS total_view_count FROM board GROUP BY user_idx) BO
	ON MI.user_idx = BO.user_idx;