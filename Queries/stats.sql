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

GRANT SELECT ON TABLE toplot_stat TO seller;
GRANT SELECT ON TABLE tovar TO admin;
GRANT SELECT ON TABLE pokupka TO admin, seller;

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

SELECT tovar.*, t.name as type, CASE when t2.idtovar IS NULL THEN 'Да' ELSE 'Нет' END as torg,
       CASE when p.idtovar IS NULL THEN 'Нет' ELSE 'Да' END as purchase
FROM tovar
         INNER JOIN typetovara t USING (idtypetovara)
         LEFT JOIN pokupka p USING (idtovar)
         LEFT JOIN torg t2 USING (idtovar) WHERE idprodavec is not null