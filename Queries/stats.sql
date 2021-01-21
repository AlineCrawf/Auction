drop view toplot_stat;

create or replace view toplot_stat
            (idprodavec, name, typetov, idtorg, idtovar, customer_count, stavka_diff_perc, income, month) as
WITH top_lot AS (
    SELECT tgh.idtorg,
           th.idtovar,
           count(tgh.idpokupatel)                         AS customer_count,
           (th.max_stavka - th.min_stavka) / 100::numeric AS stavka_diff,
           th.max_stavka - th.min_stavka                  AS income,
           -- date_part('month',data_close)
           to_char(data_close, 'TMMonth')                 AS month
    FROM torg_history tgh
             JOIN torg th USING (idtorg)
    GROUP BY tgh.idtorg, th.idtovar, th.min_stavka, th.max_stavka, data_close
)
SELECT tovar.idprodavec, tovar.name, t.name as typetov, top_lot.*
FROM top_lot
         INNER JOIN tovar USING (idtovar)
         INNER JOIN typetovara t on tovar.idtypetovara = t.idtypetovara
WHERE stavka_diff BETWEEN 0 AND 10000;


CREATE OR REPLACE FUNCTION new_dostavka(idpokupka int, dostavka_type text, adres text)
    RETURNS VOID
AS
$$
insert into dostavka(dostavka, idpokupka, adress)
values (dostavka_type::dostavka_t, idpokupka, adres);
$$ LANGUAGE 'sql';


SELECT *
FROM pokupki
         INNER JOIN dostavka d on pokupki.idpokupka = d.idpokupka
WHERE dostavka IS NULL;

CREATE OR REPLACE FUNCTION dostavka_insert_trigger() RETURNS TRIGGER
AS
$$
BEGIN
    IF EXISTS(SELECT * FROM dostavka WHERE idpokupka = new.idpokupka)
    THEN
        RAISE EXCEPTION 'Доставка уже создана';
    END IF;

    RETURN new;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER unique_dostavka
    BEFORE INSERT
    ON dostavka
    FOR EACH ROW
EXECUTE PROCEDURE dostavka_insert_trigger();


ALTER TABLE dostavka
    ADD COLUMN registgration_date timestamp NOT NULL DEFAULT now();

GRANT SELECT ON TABLE toplot_stat, dostavka TO seller;
GRANT SELECT ON TABLE tovar, polzovately TO admin;
GRANT SELECT ON TABLE prodavec, expertiza, polzovately TO expert;
GRANT SELECT ON TABLE pokupka, expertiza TO admin, seller;

GRANT SELECT, INSERT ON TABLE dostavka TO customer;
GRANT EXECUTE ON FUNCTION new_dostavka(int, text, text) TO customer;

SELECT Tovar.*
FROM Tovar
         LEFT JOIN torg USING (idtovar)
         LEFT JOIN expertiza ex USING (idtovar)
WHERE idtorg IS NULL
  AND idprodavec = @idprodavec
  AND podlinosty IS True
  AND propaja IS false;
SELECT *
FROM tovar
         INNER JOIN typetovara t USING (idtypetovara)
         INNER JOIN prodavec p USING (idprodavec)
         LEFT JOIN expertiza ex USING (idtovar);
SELECT idtovar, name
FROM tovar
    LEFT JOIN expertiza ex USING(idtovar)
WHERE idexpertiza IS NULL;

SELECT *, pz.name || ' ' || pz.surname as fullname
FROM tovar
         INNER JOIN typetovara t USING (idtypetovara)
         INNER JOIN prodavec p USING (idprodavec)
         INNER JOIN polzovately pz ON p.idpolzovately = pz.id
         LEFT JOIN expertiza ex USING (idtovar);


ALTER TABLE expert
    DROP COLUMN otchetadmin,
    DROP COLUMN otchetprodavca;

ALTER TABLE expertiza
    ADD COLUMN otchetadmin    TEXT NOT NULL DEFAULT 'Empty',
    ADD COLUMN otchetprodavca TEXT NOT NULL DEFAULT 'Empty',
    ADD CONSTRAINT idtovar_unique UNIQUE (idtovar);

ALTER TABLE polzovately
    ADD COLUMN registration_date timestamp NOT NULL DEFAULT now();

ALTER TABLE tovar
    ADD COLUMN registration_date timestamp NOT NULL DEFAULT now();

-- DB users !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--ALTER TABLE login
--  ADD COLUMN registration_date timestamp NOT NULL DEFAULT now() ;

--UPDATE login
--set registration_date = now()
--where true;

--create or replace function add_login(p_phone text, p_password text) returns void
--    language plpgsql
--as
--$$
--BEGIN
--    IF char_length(p_password) != 32
--    THEN
--        p_password := MD5(p_password);
--    END IF;

--    INSERT INTO login (phone, password, role, registration_date) VALUES (p_phone, p_password, 4, now());

--END;

--$$;

-- DB users !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SELECT tovar.*,
       t.name                                                as type,
       CASE when t2.idtovar IS NULL THEN 'Да' ELSE 'Нет' END as torg,
       CASE when p.idtovar IS NULL THEN 'Нет' ELSE 'Да' END  as purchase
FROM tovar
         INNER JOIN typetovara t USING (idtypetovara)
         LEFT JOIN pokupka p USING (idtovar)
         LEFT JOIN torg t2 USING (idtovar)
WHERE idprodavec is not null;

----- Expert
sELECT *
FROM tovar
         INNER JOIN typetovara t USING (idtypetovara)
         INNER JOIN prodavec p USING (idprodavec)
         LEFT JOIN expertiza ex USING (idtovar);

ALTER TABLE expertiza
    ADD COLUMN podlinosty BOOL NOT NULL DEFAULT true,
    ADD COLUMN propaja    BOOL NOT NULL DEFAULT false;