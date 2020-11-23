-- 13.11.2020
CREATE EXTENSION dblink;  	-- Подключение к другой БД

ALTER TABLE public.expert 
	ADD COLUMN idpolzovately int REFERENCES Polzovately; 

ALTER TABLE public.polzovately
  ADD UNIQUE (email),
  ADD UNIQUE (telefon);
   
CREATE TABLE Staff
(
	id			SERIAL PRIMARY KEY,
	udoslich 	text  NOT NULL UNIQUE,
    name 		text  NOT NULL,
    surname 	text  NOT NULL
);
	
INSERT INTO Staff (udoslich, name, surname) values ('admin', 'Yura', 'Rudenko');

-- Update| Insert
UPDATE Expert
	SET idpolzovately = CASE idexpert 
							when  1 then 14
							when 2 then 15
							when 3 then 16
						end;
						
-- Queries
CREATE OR REPLACE View roles as
(
	SELECT pol.*, 	CASE 
						WHEN prod.idpolzovately IS NOT NULL THEN True 
						ELSE False
					END Prodavec,
					CASE 
						WHEN pok.idpolzovately IS NOT NULL THEN True 
						ELSE False
					END Pokupatel,
					CASE 
						WHEN ex.idpolzovately IS NOT NULL THEN True
						ELSE False
					END Expert
					
	FROM polzovately pol
	LEFT JOIN prodavec prod ON pol.id = prod.idpolzovately
	LEFT JOIN pokupatel pok ON pol.id = pok.idpolzovately
	LEFT JOIN expert	ex  ON pol.id = ex.idpolzovately
);


CREATE OR REPLACE FUNCTION add_user(p_name text, p_surname text, p_password text, p_udoslich text, p_phone text, p_email text)
							RETURNS Void
AS $$
	DECLARE
		v_idpolzovately int;
		new_user text;
BEGIN
	IF p_email NOT LIKE '%@%' 
		THEN RAISE EXCEPTION 'Некорректный email';
	END IF;
	
	IF char_length(p_phone) != 13 
		THEN RAISE EXCEPTION 'Некорректный номер телефона';
	END IF;
	
	IF char_length(p_password) != 32
		THEN p_password := MD5(p_password);
	END IF;
	
	INSERT INTO polzovately (udoslich, name, surname, email, telefon)
			VALUES (p_udoslich, p_name, p_surname, p_email, p_phone)
	RETURNING id INTO v_idpolzovately;
			
	INSERT INTO pokupatel (idpolzovately) VALUES (v_idpolzovately);
	
	new_user= 'INSERT INTO Login (phone, password, role) VALUES ('''|| p_phone ||''', '''|| p_password || ''', 4)';
	RAISE NOTICE '%', new_user;
	
	PERFORM dblink_exec('dbname=users host=localhost port=5433 user=postgres password=postgres',new_user);							-- !!! Поменять на 5432
	
END;
$$ LANGUAGE 'plpgsql';
	
COMMENT ON FUNCTION  add_user (p_name text, p_surname text, p_password text, p_udoslich text, p_phone text, p_email text)
								is 'Регистрация пользователя как покупателя. 
								Для регистрации продавца пользователь отпарвляет заявку администратору. 
								Для регистрации эксперта, администратор лично создает в личном кабинете';
								
								
								
-----23.11.2020

ALTER TABLE torg_history
	ADD COLUMN time_stavka	time NOT NULL DEFAULT CURRENT_TIME,		-- Время, когда сделана ставка
 
 
CREATE OR REPLACE FUNCTION close_torg(p_idtorg int)
							RETURNS Void
AS $$
BEGIN
	UPDATE torg
		SET data_close = CURRENT_TIMESTAMP,
			max_stavka = (SELECT MAX(stavka) FROM torg_history WHERE idtorg = p_idtorg)
	WHERE idtorg = p_idtorg;
	
	INSERT INTO pokupka (datapokupki, itogstoimosty, idpokupatel, idtovar)
				SELECT CURRENT_TIMESTAMP, th.stavka, th.idpokupatel, t.idtovar
				FROM torg_history th
				INNER JOIN torg t ON t.idtorg = p_idtorg
				ORDER BY idtorg_history DESC
				LIMIT 1;
END;
$$ LANGUAGE 'plpgsql';

ALTER TABLE torg
	ALTER COLUMN data_close DROP NOT NULL;
	
TRUNCATE TABLE pokupka CASCADE;

UPDATE torg
	SET data_close = NULL;

DROP VIEW pokupki;

CREATE OR REPLACE VIEW pokupki AS 
(
		select idtovar, ppt.telefon as phone, idpokupka, datapokupki, itogstoimosty,  t.name as tovar, sostoyanie,  
				tt.name, pl.name || pl.surname as prodavec
		from pokupka p
		inner join pokupatel pt USING(idpokupatel)
		inner join polzovately ppt ON ppt.id = pt.idpolzovately
		inner join tovar t using(idtovar)
		inner join typetovara tt USING(idtypetovara)
		inner join prodavec pr USING (idprodavec)
		inner join polzovately pl ON pl.id = pr.idpolzovately 
); 

CREATE FUNCTION user_id(p_phone text)
				RETURNS int
AS $$
	select idpokupatel from polzovately pl
                    inner join pokupatel pk on pl.id = pk.idpolzovately
                   where telefon = p_phone
$$ LANGUAGE 'sql'

CREATE OR REPLACE FUNCTION insert_torg_history_stavka() RETURNS TRIGGER
AS $$
BEGIN
	IF new.stavka <= (SELECT stavka FROM torg_history ORDER BY idtorg_history DESC LIMIT 1)
		THEN RAISE EXCEPTION 'Ваша ставка должна быть больше последней сделанной';
	END IF;
	
	RETURN new; -- Без этого ничего не произойдет 
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER insert_torg_history_stavka_t
BEFORE INSERT ON torg_history
FOR EACH ROW EXECUTE PROCEDURE insert_torg_history_stavka();

ALTER TABLE pokupatel
	ADD COLUMN prodavec_request BOOL NOT NULL DEFAULT False; -- Заявка стать продавцом
