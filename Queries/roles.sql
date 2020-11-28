DROP ROLE  Admin;
DROP ROLE Expert;
DROP ROLE Seller;
DROP ROLE Customer;

CREATE ROLE admin with LOGIN PASSWORD 'admin';
CREATE ROLE expert with LOGIN PASSWORD 'expert';
CREATE ROLE seller with LOGIN PASSWORD 'seller';
CREATE ROLE customer with LOGIN PASSWORD 'customer';


GRANT CONNECT ON DATABASE "Auction" TO admin;
GRANT CONNECT ON DATABASE "Auction" TO expert;
GRANT CONNECT ON DATABASE "Auction" TO seller;
GRANT CONNECT ON DATABASE "Auction" TO customer;


-- Main Page
GRANT SELECT ON TABLE open_torg TO admin, expert, seller, customer;

-- Tovar
GRANT SELECT ON TABLE Tovar TO   seller, customer;
GRANT SELECT ON TABLE typetovara TO   seller, customer;
GRANT SELECT ON TABLE torg TO  seller, customer;
GRANT SELECT, INSERT ON TABLE torg_history TO  seller, customer;
GRANT SELECT, INSERT, UPDATE ON TABLE pokupatel TO  seller, customer;
GRANT SELECT ON TABLE polzovately TO  seller, customer;
GRANT SELECT ON TABLE pokupatel TO  seller, customer;

GRANT INSERT, UPDATE, DELETE ON Tovar TO seller;
-- Customer_shop
GRANT SELECT ON TABLE pokupki TO   seller, customer;

-- Request
GRANT SELECT, INSERT, UPDATE ON TABLE pokupatel TO admin;
GRANT SELECT ON TABLE polzovately TO admin;
GRANT SELECT, INSERT, UPDATE ON TABLE prodavec TO admin;
GRANT USAGE ON SEQUENCE prodavec_idprodavec_seq TO admin;


--REVOKE ALL ON ALL TABLES IN SCHEMA public FROM expert, seller, customer;

--REVOKE CONNECT ON DATABASE "Auction" FROM Admin;
--REVOKE CONNECT ON DATABASE "Auction" FROM Customer;
/*
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
*/