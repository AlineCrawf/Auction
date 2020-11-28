--DROP ROLE Admin;
--DROP ROLE Expert;
--DROP ROLE Seller;
--DROP ROLE Customer;

CREATE ROLE Admin with LOGIN PASSWORD 'admin';
CREATE ROLE Expert with LOGIN PASSWORD 'expert';
CREATE ROLE Seller with LOGIN PASSWORD 'qwerty';
CREATE ROLE Customer with LOGIN PASSWORD 'customer';

GRANT CONNECT ON DATABASE "Auction" TO Seller; --Customer;
REVOKE CONNECT ON DATABASE "Auction" FROM Seller; --Admin;

SELECT t.* FROM prodavec INNER JOIN polzovately  ON id = idpolzovately INNER JOIN Tovar t USING(idprodavec) where telefon = '+380635254502'

SELECT * FROM torg where idtovar = 10;
SELECT tovar.* , t.name as "type" , CASE when t2.idtovar IS NULL THEN false ELSE true END  as torg FROM tovar INNER JOIN typetovara t USING(idtypetovara)
LEFT JOIN torg t2 USING(idtovar)

SELECT tovar.* , t.name as type , CASE when t2.idtovar IS NULL THEN true ELSE false END  as torg  FROM tovar INNER JOIN typetovara t USING(idtypetovara) LEFT JOIN torg t2 USING(idtovar)

--DROP VIEW open_torg ;
CREATE VIEW open_torg AS
(
SELECT torg.idtorg,
       idtovar,
       data_open,
       min_stavka,
       document,
       tovar.name                      tovar,
       sostoyanie,
       t.name                       as type,
       p2.surname || ' ' || p2.name as prodavec,
       stoimosty
FROM torg
         INNER JOIN tovar USING (idtovar)
         INNER JOIN prodavec p USING (idprodavec)
         INNER JOIN typetovara t USING (idtypetovara)
         INNER JOIN polzovately p2 on p.idpolzovately = p2.id
WHERE data_close IS NULL
    )

create OR REPLACE view pokupki (idtovar, phone, idpokupka, datapokupki, itogstoimosty, tovar, sostoyanie, name, prodavec) as
SELECT p.idtovar,
       ppt.telefon           AS phone,
       p.idpokupka,
       p.datapokupki,
       p.itogstoimosty,
       t.name                AS tovar,
       t.sostoyanie,
       tt.name,
       pl.name || ' '|| pl.surname AS prodavec
FROM pokupka p
         JOIN pokupatel pt USING (idpokupatel)
         JOIN polzovately ppt ON ppt.id = pt.idpolzovately
         JOIN tovar t USING (idtovar)
         JOIN typetovara tt USING (idtypetovara)
         JOIN prodavec pr USING (idprodavec)
         JOIN polzovately pl ON pl.id = pr.idpolzovately;

alter table pokupki
    owner to postgres;
