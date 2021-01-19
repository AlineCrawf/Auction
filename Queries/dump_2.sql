--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.18
-- Dumped by pg_dump version 10.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: dostavka_t; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.dostavka_t AS ENUM (
    'Pochta',
    'Samovivoz',
    'Kuryerskaya'
);


ALTER TYPE public.dostavka_t OWNER TO postgres;

--
-- Name: sostoyanie_t; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.sostoyanie_t AS ENUM (
    'novoe',
    'B/U'
);


ALTER TYPE public.sostoyanie_t OWNER TO postgres;

--
-- Name: add_staff(text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_staff(p_name text, p_surname text, p_password text, p_udoslich text) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
		new_user text;
BEGIN
	IF char_length(p_password) != 32
		THEN p_password := MD5(p_password);
	END IF;
	
	INSERT INTO staff (udoslich, name, surname )
			VALUES (p_udoslich, p_name, p_surname);
				
	new_user= 'INSERT INTO Login (phone, password, role) VALUES ('''|| p_udoslich ||''', '''|| p_password || ''', 2)';
	RAISE NOTICE '%', new_user;
	
	PERFORM dblink_exec('dbname=users host=localhost port=5433 user=postgres password=postgres',new_user);							-- !!! Поменять на 5432
	
END;

$$;


ALTER FUNCTION public.add_staff(p_name text, p_surname text, p_password text, p_udoslich text) OWNER TO postgres;

--
-- Name: add_user(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_user(p_name text, p_surname text, p_udoslich text, p_phone text, p_email text) RETURNS void
    LANGUAGE plpgsql
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
	

	
	INSERT INTO polzovately (udoslich, name, surname, email, telefon)
			VALUES (p_udoslich, p_name, p_surname, p_email, p_phone)
	RETURNING id INTO v_idpolzovately;
			
	INSERT INTO pokupatel (idpolzovately) VALUES (v_idpolzovately);
	
END;
$$;


ALTER FUNCTION public.add_user(p_name text, p_surname text, p_udoslich text, p_phone text, p_email text) OWNER TO postgres;

--
-- Name: block(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.block() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE cherniy int;
        BEGIN
                SELECT idcherniy_pokupatel INTO cherniy
				FROM Cherniy_pokupatel cp
				RIGHT JOIN Pokupatel p ON idcherniy_pokupatel =  NEW.idpokupatel;
				
				IF(cherniy IS NOT NULL)
					THEN RAISE EXCEPTION 
						'Покупатель  в черном списке(Триггер)';
				END IF;
				RETURN NEW;
        END;
$$;


ALTER FUNCTION public.block() OWNER TO postgres;

--
-- Name: close_torg(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.close_torg(p_idtorg integer) RETURNS void
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.close_torg(p_idtorg integer) OWNER TO postgres;

--
-- Name: controly(integer, integer, numeric, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.controly(idpokupatel_ integer, idtovar_ integer, itogstoimosty_ numeric, adress text, dostavka_ text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE cherniy int;
			idpokupka_ int;
        BEGIN
				if (dostavka_ not in ('Pochta', 'Samovivoz', 'Kuryerskaya'))
					THEN RAISE EXCEPTION 
						'Неверный тип доставки';
				END IF;
						
                SELECT idcherniy_pokupatel INTO cherniy
				FROM Cherniy_pokupatel cp
				RIGHT JOIN Pokupatel p ON idcherniy_pokupatel =  idpokupatel_;
				
				IF(cherniy IS NOT NULL)
					THEN RAISE EXCEPTION 
						'Покупатель  в черном списке';
				END IF;
				
				
				insert into pokupka (datapokupki, itogstoimosty, idpokupatel, idtovar) 
				values (CURRENT_DATE, itogstoimosty_, idpokupatel_, idtovar_);
				
				SELECT MAX(idpokupka) INTO idpokupka_
				FROM pokupka;
				
				insert into dostavka (idpokupka, dostavka, adress) 
				values (idpokupka_, CAST(dostavka_ AS dostavka_t) , adress);
        END;
$$;


ALTER FUNCTION public.controly(idpokupatel_ integer, idtovar_ integer, itogstoimosty_ numeric, adress text, dostavka_ text) OWNER TO postgres;

--
-- Name: insert_torg_history_stavka(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_torg_history_stavka() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF new.stavka <= (SELECT COALESCE(stavka, 1) FROM torg_history th WHERE th.idtorg = new.idtorg ORDER BY idtorg_history DESC LIMIT 1)
		THEN RAISE EXCEPTION 'Ваша ставка должна быть больше последней сделанной';
	END IF;
	
	RETURN new; -- Без этого ничего не произойдет 
END;
$$;


ALTER FUNCTION public.insert_torg_history_stavka() OWNER TO postgres;

--
-- Name: new_torg(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.new_torg(p_idtovar integer, p_min_stavka numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
	v_id_torg int;
BEGIN
	INSERT INTO torg(
	idtovar, data_open, data_close, max_stavka, min_stavka)
	VALUES (p_idtovar, CURRENT_DATE, null,null , p_min_stavka)
	RETURNING idtorg INTO v_id_torg;
	
	INSERT INTO torg_history(idpokupatel, idtorg, stavka)
	VALUES ( 1, v_id_torg, p_min_stavka);
END;
$$;


ALTER FUNCTION public.new_torg(p_idtovar integer, p_min_stavka numeric) OWNER TO postgres;

--
-- Name: new_tovar(text, text, integer, integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.new_tovar(p_name text, sostoyanie text, p_idtypetovara integer, p_idprodavec integer, p_stoimosty numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

	INSERT INTO public.tovar( document, name, sostoyanie, idtypetovara, idprodavec, stoimosty)
	VALUES ('doc '||p_name, p_name, sostoyanie::sostoyanie_t, p_idtypetovara, p_idprodavec, p_stoimosty);
END;
$$;


ALTER FUNCTION public.new_tovar(p_name text, sostoyanie text, p_idtypetovara integer, p_idprodavec integer, p_stoimosty numeric) OWNER TO postgres;

--
-- Name: pokupatel_to_black_list(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pokupatel_to_black_list(p_id_pokupatel integer, p_prichina text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO cherniy_pokupatel (idcherniy_pokupatel, prichina) VALUES (p_id_pokupatel, p_prichina);
	-- TODO Добавить блокировку покупателя
END;
$$;


ALTER FUNCTION public.pokupatel_to_black_list(p_id_pokupatel integer, p_prichina text) OWNER TO postgres;

--
-- Name: pokupatel_to_prodavec(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pokupatel_to_prodavec(p_idpolzovately integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO Prodavec (idpolzovately) VALUES (p_idpolzovately);
	
	UPDATE Pokupatel SET prodavec_request = false WHERE idpolzovately = p_idpolzovately;
END;
$$;


ALTER FUNCTION public.pokupatel_to_prodavec(p_idpolzovately integer) OWNER TO postgres;

--
-- Name: raznica(numeric, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.raznica(numeric, tovar integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
	DECLARE max numeric;
			min numeric;
BEGIN 
	select min_stavka, max_stavka into min, max
	from torg 
	where idtovar=tovar;
	
	RETURN max - min;
END;
$$;


ALTER FUNCTION public.raznica(numeric, tovar integer) OWNER TO postgres;

--
-- Name: raznicaprocent(numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.raznicaprocent(raznica_ numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN	
	RETURN raznica_/100;
END;
$$;


ALTER FUNCTION public.raznicaprocent(raznica_ numeric) OWNER TO postgres;

--
-- Name: user_id(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.user_id(p_phone text) RETURNS integer
    LANGUAGE sql
    AS $$
	select idpokupatel from polzovately pl
                    inner join pokupatel pk on pl.id = pk.idpolzovately
                   where telefon = p_phone
$$;


ALTER FUNCTION public.user_id(p_phone text) OWNER TO postgres;

--
-- Name: podchetraznicprice(integer); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.podchetraznicprice(integer) (
    SFUNC = public.raznica,
    STYPE = numeric,
    INITCOND = '0.0',
    FINALFUNC = public.raznicaprocent
);


ALTER AGGREGATE public.podchetraznicprice(integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cherniy_pokupatel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cherniy_pokupatel (
    idcherniy_pokupatel integer NOT NULL,
    prichina text NOT NULL
);


ALTER TABLE public.cherniy_pokupatel OWNER TO postgres;

--
-- Name: cherniy_prodavec; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cherniy_prodavec (
    idcherniy_prodavec integer NOT NULL,
    prichina text NOT NULL
);


ALTER TABLE public.cherniy_prodavec OWNER TO postgres;

--
-- Name: dostavka; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dostavka (
    iddostavka integer NOT NULL,
    dostavka public.dostavka_t NOT NULL,
    idpokupka integer NOT NULL,
    adress text NOT NULL
);


ALTER TABLE public.dostavka OWNER TO postgres;

--
-- Name: dostavka_iddostavka_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dostavka_iddostavka_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dostavka_iddostavka_seq OWNER TO postgres;

--
-- Name: dostavka_iddostavka_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dostavka_iddostavka_seq OWNED BY public.dostavka.iddostavka;


--
-- Name: expert; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expert (
    idexpert integer NOT NULL,
    otchetadmin text NOT NULL,
    otchetprodavca text NOT NULL,
    idpolzovately integer
);


ALTER TABLE public.expert OWNER TO postgres;

--
-- Name: expert_idexpert_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.expert_idexpert_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expert_idexpert_seq OWNER TO postgres;

--
-- Name: expert_idexpert_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.expert_idexpert_seq OWNED BY public.expert.idexpert;


--
-- Name: expertiza; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expertiza (
    idexpertiza integer NOT NULL,
    idtovar integer NOT NULL,
    idexpert integer NOT NULL,
    opisanie text NOT NULL
);


ALTER TABLE public.expertiza OWNER TO postgres;

--
-- Name: expertiza_idexpertiza_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.expertiza_idexpertiza_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expertiza_idexpertiza_seq OWNER TO postgres;

--
-- Name: expertiza_idexpertiza_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.expertiza_idexpertiza_seq OWNED BY public.expertiza.idexpertiza;


--
-- Name: polzovately; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.polzovately (
    id integer NOT NULL,
    udoslich text NOT NULL,
    name text NOT NULL,
    surname text NOT NULL,
    email text,
    telefon character varying(13) NOT NULL
);


ALTER TABLE public.polzovately OWNER TO postgres;

--
-- Name: prodavec; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prodavec (
    idprodavec integer NOT NULL,
    idpolzovately integer NOT NULL
);


ALTER TABLE public.prodavec OWNER TO postgres;

--
-- Name: tovar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tovar (
    idtovar integer NOT NULL,
    document text,
    name text NOT NULL,
    sostoyanie public.sostoyanie_t NOT NULL,
    idtypetovara integer NOT NULL,
    idprodavec integer NOT NULL,
    stoimosty numeric NOT NULL,
    CONSTRAINT tovar_stoimosty_check CHECK ((stoimosty > (0)::numeric))
);


ALTER TABLE public.tovar OWNER TO postgres;

--
-- Name: typetovara; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.typetovara (
    idtypetovara integer NOT NULL,
    idparenttype integer,
    name text NOT NULL
);


ALTER TABLE public.typetovara OWNER TO postgres;

--
-- Name: infotovar; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.infotovar AS
 SELECT t.document,
    t.name,
    t.sostoyanie,
    pz.name AS prodavec_name,
    pz.surname AS prodavec_surname,
    tt.name AS type_tovara,
    t.stoimosty
   FROM ((((public.tovar t
     LEFT JOIN public.expertiza ex USING (idtovar))
     JOIN public.typetovara tt USING (idtypetovara))
     JOIN public.prodavec p USING (idprodavec))
     JOIN public.polzovately pz ON ((pz.id = p.idpolzovately)))
  WHERE (ex.idexpertiza IS NULL);


ALTER TABLE public.infotovar OWNER TO postgres;

--
-- Name: torg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.torg (
    idtorg integer NOT NULL,
    idtovar integer NOT NULL,
    data_open timestamp without time zone NOT NULL,
    data_close timestamp without time zone,
    max_stavka numeric,
    min_stavka numeric NOT NULL,
    CONSTRAINT torg_max_stavka_check CHECK ((max_stavka > (0)::numeric)),
    CONSTRAINT torg_min_stavka_check CHECK ((min_stavka > (0)::numeric))
);


ALTER TABLE public.torg OWNER TO postgres;

--
-- Name: open_torg; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.open_torg AS
 SELECT torg.idtorg,
    torg.idtovar,
    torg.data_open,
    torg.min_stavka,
    tovar.document,
    tovar.name AS tovar,
    tovar.sostoyanie,
    t.name AS type,
    ((p2.surname || ' '::text) || p2.name) AS prodavec,
    tovar.stoimosty
   FROM ((((public.torg
     JOIN public.tovar USING (idtovar))
     JOIN public.prodavec p USING (idprodavec))
     JOIN public.typetovara t USING (idtypetovara))
     JOIN public.polzovately p2 ON ((p.idpolzovately = p2.id)))
  WHERE (torg.data_close IS NULL);


ALTER TABLE public.open_torg OWNER TO postgres;

--
-- Name: pokupatel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pokupatel (
    idpokupatel integer NOT NULL,
    idpolzovately integer NOT NULL,
    prodavec_request boolean DEFAULT false NOT NULL
);


ALTER TABLE public.pokupatel OWNER TO postgres;

--
-- Name: pokupatel_idpokupatel_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pokupatel_idpokupatel_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pokupatel_idpokupatel_seq OWNER TO postgres;

--
-- Name: pokupatel_idpokupatel_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pokupatel_idpokupatel_seq OWNED BY public.pokupatel.idpokupatel;


--
-- Name: pokupka; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pokupka (
    idpokupka integer NOT NULL,
    datapokupki date NOT NULL,
    itogstoimosty numeric NOT NULL,
    idpokupatel integer NOT NULL,
    idtovar integer NOT NULL
);


ALTER TABLE public.pokupka OWNER TO postgres;

--
-- Name: pokupka_idpokupka_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pokupka_idpokupka_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pokupka_idpokupka_seq OWNER TO postgres;

--
-- Name: pokupka_idpokupka_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pokupka_idpokupka_seq OWNED BY public.pokupka.idpokupka;


--
-- Name: pokupki; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.pokupki AS
 SELECT p.idtovar,
    ppt.telefon AS phone,
    p.idpokupka,
    p.datapokupki,
    p.itogstoimosty,
    t.name AS tovar,
    t.sostoyanie,
    tt.name,
    ((pl.name || ' '::text) || pl.surname) AS prodavec
   FROM ((((((public.pokupka p
     JOIN public.pokupatel pt USING (idpokupatel))
     JOIN public.polzovately ppt ON ((ppt.id = pt.idpolzovately)))
     JOIN public.tovar t USING (idtovar))
     JOIN public.typetovara tt USING (idtypetovara))
     JOIN public.prodavec pr USING (idprodavec))
     JOIN public.polzovately pl ON ((pl.id = pr.idpolzovately)));


ALTER TABLE public.pokupki OWNER TO postgres;

--
-- Name: polzovately_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.polzovately_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.polzovately_id_seq OWNER TO postgres;

--
-- Name: polzovately_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.polzovately_id_seq OWNED BY public.polzovately.id;


--
-- Name: prodavec_idprodavec_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prodavec_idprodavec_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prodavec_idprodavec_seq OWNER TO postgres;

--
-- Name: prodavec_idprodavec_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prodavec_idprodavec_seq OWNED BY public.prodavec.idprodavec;


--
-- Name: roles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.roles AS
 SELECT pol.id,
    pol.udoslich,
    pol.name,
    pol.surname,
    pol.email,
    pol.telefon,
        CASE
            WHEN (prod.idpolzovately IS NOT NULL) THEN true
            ELSE false
        END AS prodavec,
        CASE
            WHEN (pok.idpolzovately IS NOT NULL) THEN true
            ELSE false
        END AS pokupatel,
        CASE
            WHEN (ex.idpolzovately IS NOT NULL) THEN true
            ELSE false
        END AS expert
   FROM (((public.polzovately pol
     LEFT JOIN public.prodavec prod ON ((pol.id = prod.idpolzovately)))
     LEFT JOIN public.pokupatel pok ON ((pol.id = pok.idpolzovately)))
     LEFT JOIN public.expert ex ON ((pol.id = ex.idpolzovately)));


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff (
    id integer NOT NULL,
    udoslich text NOT NULL,
    name text NOT NULL,
    surname text NOT NULL
);


ALTER TABLE public.staff OWNER TO postgres;

--
-- Name: staff_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staff_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staff_id_seq OWNER TO postgres;

--
-- Name: staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staff_id_seq OWNED BY public.staff.id;


--
-- Name: top_pokupatel_; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.top_pokupatel_ AS
SELECT
    NULL::integer AS id,
    NULL::text AS name,
    NULL::text AS surname,
    NULL::bigint AS tovar,
    NULL::bigint AS pokupatel,
    NULL::bigint AS torg;


ALTER TABLE public.top_pokupatel_ OWNER TO postgres;

--
-- Name: torg_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.torg_history (
    idtorg_history integer NOT NULL,
    idpokupatel integer NOT NULL,
    idtorg integer NOT NULL,
    stavka numeric NOT NULL,
    time_stavka time without time zone DEFAULT ('now'::text)::time with time zone NOT NULL,
    CONSTRAINT torg_history_stavka_check CHECK ((stavka > (0)::numeric))
);


ALTER TABLE public.torg_history OWNER TO postgres;

--
-- Name: toplot; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.toplot AS
 WITH top_lot AS (
         SELECT tgh.idtorg,
            count(tgh.idpokupatel) AS pokupatelschet,
            ((th.max_stavka - th.min_stavka) / (100)::numeric) AS raznicastavka
           FROM (public.torg_history tgh
             JOIN public.torg th USING (idtorg))
          GROUP BY tgh.idtorg, th.min_stavka, th.max_stavka
        )
 SELECT top_lot.idtorg,
    dense_rank() OVER (ORDER BY top_lot.pokupatelschet DESC) AS pokupatelschet,
    dense_rank() OVER (ORDER BY top_lot.raznicastavka DESC) AS raznicastavka
   FROM top_lot;


ALTER TABLE public.toplot OWNER TO postgres;

--
-- Name: torg_history_idtorg_history_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.torg_history_idtorg_history_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.torg_history_idtorg_history_seq OWNER TO postgres;

--
-- Name: torg_history_idtorg_history_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.torg_history_idtorg_history_seq OWNED BY public.torg_history.idtorg_history;


--
-- Name: torg_idtorg_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.torg_idtorg_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.torg_idtorg_seq OWNER TO postgres;

--
-- Name: torg_idtorg_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.torg_idtorg_seq OWNED BY public.torg.idtorg;


--
-- Name: torginfo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.torginfo AS
 SELECT tg.idtorg,
    tv.name,
    tt.name AS type,
    tv.sostoyanie,
    tg.data_open,
    tg.min_stavka
   FROM ((public.torg tg
     JOIN public.tovar tv USING (idtovar))
     JOIN public.typetovara tt USING (idtypetovara));


ALTER TABLE public.torginfo OWNER TO postgres;

--
-- Name: tovar_idtovar_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tovar_idtovar_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tovar_idtovar_seq OWNER TO postgres;

--
-- Name: tovar_idtovar_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tovar_idtovar_seq OWNED BY public.tovar.idtovar;


--
-- Name: typetovara_idtypetovara_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.typetovara_idtypetovara_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.typetovara_idtypetovara_seq OWNER TO postgres;

--
-- Name: typetovara_idtypetovara_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.typetovara_idtypetovara_seq OWNED BY public.typetovara.idtypetovara;


--
-- Name: dostavka iddostavka; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dostavka ALTER COLUMN iddostavka SET DEFAULT nextval('public.dostavka_iddostavka_seq'::regclass);


--
-- Name: expert idexpert; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expert ALTER COLUMN idexpert SET DEFAULT nextval('public.expert_idexpert_seq'::regclass);


--
-- Name: expertiza idexpertiza; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expertiza ALTER COLUMN idexpertiza SET DEFAULT nextval('public.expertiza_idexpertiza_seq'::regclass);


--
-- Name: pokupatel idpokupatel; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokupatel ALTER COLUMN idpokupatel SET DEFAULT nextval('public.pokupatel_idpokupatel_seq'::regclass);


--
-- Name: pokupka idpokupka; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokupka ALTER COLUMN idpokupka SET DEFAULT nextval('public.pokupka_idpokupka_seq'::regclass);


--
-- Name: polzovately id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polzovately ALTER COLUMN id SET DEFAULT nextval('public.polzovately_id_seq'::regclass);


--
-- Name: prodavec idprodavec; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prodavec ALTER COLUMN idprodavec SET DEFAULT nextval('public.prodavec_idprodavec_seq'::regclass);


--
-- Name: staff id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff ALTER COLUMN id SET DEFAULT nextval('public.staff_id_seq'::regclass);


--
-- Name: torg idtorg; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.torg ALTER COLUMN idtorg SET DEFAULT nextval('public.torg_idtorg_seq'::regclass);


--
-- Name: torg_history idtorg_history; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.torg_history ALTER COLUMN idtorg_history SET DEFAULT nextval('public.torg_history_idtorg_history_seq'::regclass);


--
-- Name: tovar idtovar; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tovar ALTER COLUMN idtovar SET DEFAULT nextval('public.tovar_idtovar_seq'::regclass);


--
-- Name: typetovara idtypetovara; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typetovara ALTER COLUMN idtypetovara SET DEFAULT nextval('public.typetovara_idtypetovara_seq'::regclass);


--
-- Data for Name: cherniy_pokupatel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cherniy_pokupatel (idcherniy_pokupatel, prichina) FROM stdin;
2	krichit vo vremya aukciona
3	ssdd
\.


--
-- Data for Name: cherniy_prodavec; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cherniy_prodavec (idcherniy_prodavec, prichina) FROM stdin;
\.


--
-- Data for Name: dostavka; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dostavka (iddostavka, dostavka, idpokupka, adress) FROM stdin;
\.


--
-- Data for Name: expert; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expert (idexpert, otchetadmin, otchetprodavca, idpolzovately) FROM stdin;
1	1	1	14
2	2	2	15
3	3	3	16
\.


--
-- Data for Name: expertiza; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expertiza (idexpertiza, idtovar, idexpert, opisanie) FROM stdin;
1	1	1	gotovo
2	2	2	gotovo
3	3	3	gotovo
\.


--
-- Data for Name: pokupatel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pokupatel (idpokupatel, idpolzovately, prodavec_request) FROM stdin;
1	9	f
2	10	f
3	11	f
4	12	f
5	13	f
6	14	f
8	16	f
15	23	f
17	25	f
7	15	t
18	26	f
19	27	f
20	29	f
21	30	f
22	31	f
23	32	f
24	33	f
25	34	f
\.


--
-- Data for Name: pokupka; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pokupka (idpokupka, datapokupki, itogstoimosty, idpokupatel, idtovar) FROM stdin;
31	2020-11-23	15000	7	3
32	2020-11-23	15000	7	2
33	2020-11-24	41	20	8
34	2020-11-28	1000000	23	7
35	2020-11-28	1010	23	12
36	2020-11-28	1001	24	11
37	2020-11-28	1400000	24	9
38	2020-11-28	330000	25	10
\.


--
-- Data for Name: polzovately; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.polzovately (id, udoslich, name, surname, email, telefon) FROM stdin;
1	9	Jenya	Fedorchuck	fedorchuckevgen@gmail.com	+380803260409
2	10	Sayva	Marchenko	syavariziy@gmail.com	+380505187409
3	11	Misha	Lamin	limanlaminat@mail.ru	+380609525409
4	12	Yuriy	Lyabzin	lybzlibaz@mail.ru	+380785160409
6	14	Vlad	Sheva	shevashevich@gmail.com	+380556512313
9	1	Serega	Graviy	sergei11@mail.ru	+380505160409
10	3	Sasha	Gavorun	govorunsasha77@gmail.com	+380509525409
11	4	Valera	Pan	panpanval@mail.ru	+380605160409
12	5	Vlad	Rizun	rizenrizun@gmail.com	+380406170409
13	6	Edick	Masenko	masenkoedick123@gmail.com	+380938191742
14	7	Valik	Romanov	molodoiisilniy@mail.ru	+380951598770
16	2	Georg	Budin	budinvald@gmail.com	+380505140409
23	asdfdgd6464	Aline	Crawf	crawfInc@gmail	+380665654433
25	asdfdgd6464	Aline	NotCrawf	crawfIncf@gmail	+380665654833
5	13	Andrey	Kovalski	''Andrey@gmail	+380326170409
7	15	Karina	Velikaya	karina@gmail	+380654521387
8	16	Va\tleria	Bivalay	'Valeria@gmail	+380777777777
15	8	Andrey	Semchenko	Semchenko@gmail	+380954672720
26	123098	Анна	Иванова	anna_iv@gmail.com	+380635254500
27	1237560	Анна	Иванова	anna_not@gmail.com	+380635254501
29	757575757	Ксюха	Афанасиева	ksksks@gmail.com	+380635254502
30	g	g	g	g@	+380666666666
31	fff	ff	ff	r@	+380000000000
32	Допустим	Алина	Ткаченко	aline@gmail.com	+380635254503
33	34348121	Дарья	Эзерович	dasha@gmail	+380635254504
34	TS0001	Ваня	Тестовый	testtest@gmail	+380635254505
\.


--
-- Data for Name: prodavec; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prodavec (idprodavec, idpolzovately) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	15
10	29
11	32
12	33
14	34
\.


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff (id, udoslich, name, surname) FROM stdin;
1	admin	Yura	Rudenko
2	12345678	Aline	Tkachenko
\.


--
-- Data for Name: torg; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.torg (idtorg, idtovar, data_open, data_close, max_stavka, min_stavka) FROM stdin;
2	1	2020-03-22 00:00:00	2020-11-23 11:44:19.377539	100000	1000000000
3	3	2020-03-14 00:00:00	2020-11-23 17:46:42.332461	15000	600
1	2	2020-03-12 00:00:00	2020-11-23 19:12:58.208563	10000000000000	1200
9	6	2020-11-24 00:00:00	\N	\N	666666
11	8	2020-11-24 00:00:00	2020-11-24 13:06:03.749824	41	40
10	7	2020-11-24 00:00:00	2020-11-28 02:44:38.747358	1000000	666666
17	12	2020-11-28 00:00:00	2020-11-28 04:08:10.545063	1010	1000
16	11	2020-11-28 00:00:00	2020-11-28 04:30:45.0871	1001	1000
12	9	2020-11-24 00:00:00	2020-11-28 04:54:36.970549	1400000	1366613
15	10	2020-11-28 00:00:00	2020-11-28 21:11:48.641271	330000	322000
18	17	2020-11-28 00:00:00	\N	\N	101
\.


--
-- Data for Name: torg_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.torg_history (idtorg_history, idpokupatel, idtorg, stavka, time_stavka) FROM stdin;
1	1	2	1200	10:49:58.337232
4	1	2	100000	10:49:58.337232
9	1	3	600	10:49:58.337232
2	8	2	10000	10:49:58.337232
3	3	2	10020	10:49:58.337232
5	7	1	1000000000	10:49:58.337232
6	3	1	100000003000	10:49:58.337232
7	7	1	1000000000000	10:49:58.337232
8	4	1	10000000000000	10:49:58.337232
10	6	3	800	10:49:58.337232
11	5	3	1200	10:49:58.337232
12	2	3	14320	10:49:58.337232
13	1	1	1200	10:49:58.337232
16	3	2	1000	10:49:58.337232
22	1	1	23456	10:49:58.337232
23	1	1	767676	10:49:58.337232
27	1	2	1234	10:49:58.337232
28	1	1	6	11:05:23.851457
29	1	1	12345	15:17:46.540579
31	7	1	1111	15:29:26.270763
32	7	1	355	15:43:31.281951
48	7	1	1234	17:29:53.577936
51	7	1	14444	17:35:00.28327
52	7	3	15000	17:43:47.899591
57	1	9	666666	13:04:52.917896
58	1	10	666666	13:04:52.917896
59	1	11	40	13:04:52.917896
60	1	12	1366613	13:04:52.917896
62	20	11	41	13:05:44.203233
70	23	10	1000000	02:38:48.560219
71	1	15	322000	02:56:00.580648
72	1	16	1000	03:27:14.709176
73	1	17	1000	04:07:49.918158
74	23	17	1010	04:08:02.62204
76	24	16	1001	04:30:41.320363
77	24	12	1400000	04:54:34.783943
78	25	15	330000	21:11:43.842137
79	1	18	101	21:46:42.389748
\.


--
-- Data for Name: tovar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tovar (idtovar, document, name, sostoyanie, idtypetovara, idprodavec, stoimosty) FROM stdin;
3	ДОСТАЛИ Архидревний стул  99/12/14	Stulchak Fizrucka	B/U	2	1	600
2	2	Pufic Ravshana	B/U	2	1	1201
1	1	Divan Kleoptry	B/U	2	1	100000000
6	doc Левый носок Товарища Сталина	Левый носок Товарища Сталина	B/U	3	10	666666
7	doc Правый носок Товарища Сталина	Правый носок Товарища Сталина	B/U	3	10	666666
8	doc То что еще не придумал Илон Маск	То что еще не придумал Илон Маск	novoe	2	10	40
9	doc Ложе Аида	Ложе Аида	B/U	1	10	1366613
10	Чаша Гермеса.doc	Чаша Гермеса	B/U	3	10	322000
11	1	Первая ёлка в мире	B/U	3	11	1000
12	ёлочка новогодняя	Ёлка	novoe	3	11	1000
15	просто игрушка	Ёлочная игрушка	novoe	3	11	100
16	Товар	Еще один	novoe	1	12	10
17	Источник не иссекаемой  энергии	Кофе студента	novoe	2	14	101
\.


--
-- Data for Name: typetovara; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.typetovara (idtypetovara, idparenttype, name) FROM stdin;
1	\N	mebel
2	\N	tehnika
3	\N	ukrasheniya
\.


--
-- Name: dostavka_iddostavka_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dostavka_iddostavka_seq', 6, true);


--
-- Name: expert_idexpert_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.expert_idexpert_seq', 3, true);


--
-- Name: expertiza_idexpertiza_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.expertiza_idexpertiza_seq', 3, true);


--
-- Name: pokupatel_idpokupatel_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pokupatel_idpokupatel_seq', 25, true);


--
-- Name: pokupka_idpokupka_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pokupka_idpokupka_seq', 38, true);


--
-- Name: polzovately_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.polzovately_id_seq', 34, true);


--
-- Name: prodavec_idprodavec_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prodavec_idprodavec_seq', 14, true);


--
-- Name: staff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.staff_id_seq', 2, true);


--
-- Name: torg_history_idtorg_history_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.torg_history_idtorg_history_seq', 79, true);


--
-- Name: torg_idtorg_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.torg_idtorg_seq', 18, true);


--
-- Name: tovar_idtovar_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tovar_idtovar_seq', 18, true);


--
-- Name: typetovara_idtypetovara_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.typetovara_idtypetovara_seq', 3, true);


--
-- Name: cherniy_pokupatel cherniy_pokupatel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cherniy_pokupatel
    ADD CONSTRAINT cherniy_pokupatel_pkey PRIMARY KEY (idcherniy_pokupatel);


--
-- Name: cherniy_prodavec cherniy_prodavec_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cherniy_prodavec
    ADD CONSTRAINT cherniy_prodavec_pkey PRIMARY KEY (idcherniy_prodavec);


--
-- Name: dostavka dostavka_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dostavka
    ADD CONSTRAINT dostavka_pkey PRIMARY KEY (iddostavka);


--
-- Name: expert expert_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expert
    ADD CONSTRAINT expert_pkey PRIMARY KEY (idexpert);


--
-- Name: expertiza expertiza_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expertiza
    ADD CONSTRAINT expertiza_pkey PRIMARY KEY (idexpertiza);


--
-- Name: pokupatel pokupatel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokupatel
    ADD CONSTRAINT pokupatel_pkey PRIMARY KEY (idpokupatel);


--
-- Name: pokupka pokupka_idtovar_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokupka
    ADD CONSTRAINT pokupka_idtovar_key UNIQUE (idtovar);


--
-- Name: pokupka pokupka_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokupka
    ADD CONSTRAINT pokupka_pkey PRIMARY KEY (idpokupka);


--
-- Name: polzovately polzovately_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polzovately
    ADD CONSTRAINT polzovately_email_key UNIQUE (email);


--
-- Name: polzovately polzovately_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polzovately
    ADD CONSTRAINT polzovately_pkey PRIMARY KEY (id);


--
-- Name: polzovately polzovately_telefon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polzovately
    ADD CONSTRAINT polzovately_telefon_key UNIQUE (telefon);


--
-- Name: prodavec prodavec_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prodavec
    ADD CONSTRAINT prodavec_pkey PRIMARY KEY (idprodavec);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);


--
-- Name: staff staff_udoslich_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_udoslich_key UNIQUE (udoslich);


--
-- Name: torg_history torg_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.torg_history
    ADD CONSTRAINT torg_history_pkey PRIMARY KEY (idtorg_history);


--
-- Name: torg torg_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.torg
    ADD CONSTRAINT torg_pkey PRIMARY KEY (idtorg);


--
-- Name: tovar tovar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tovar
    ADD CONSTRAINT tovar_pkey PRIMARY KEY (idtovar);


--
-- Name: typetovara typetovara_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typetovara
    ADD CONSTRAINT typetovara_name_key UNIQUE (name);


--
-- Name: typetovara typetovara_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typetovara
    ADD CONSTRAINT typetovara_pkey PRIMARY KEY (idtypetovara);


--
-- Name: top_pokupatel_ _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.top_pokupatel_ AS
 WITH ratepers_ AS (
         SELECT py.id,
            py.name,
            py.surname,
            count(tv.idtovar) AS tovarschet,
            count(pk.idpokupka) AS pokupkaschet,
            count(tgh.idtorg_history) AS torgschet
           FROM (((((public.polzovately py
             LEFT JOIN public.prodavec pc ON ((py.id = pc.idpolzovately)))
             LEFT JOIN public.pokupatel pl ON ((py.id = pl.idpolzovately)))
             LEFT JOIN public.tovar tv USING (idprodavec))
             LEFT JOIN public.pokupka pk USING (idpokupatel))
             LEFT JOIN public.torg_history tgh USING (idpokupatel))
          GROUP BY py.id
        )
 SELECT ratepers_.id,
    ratepers_.name,
    ratepers_.surname,
    dense_rank() OVER (ORDER BY ratepers_.tovarschet DESC) AS tovar,
    dense_rank() OVER (ORDER BY ratepers_.pokupkaschet DESC) AS pokupatel,
    dense_rank() OVER (ORDER BY ratepers_.torgschet DESC) AS torg
   FROM ratepers_;


--
-- Name: torg_history insert_torg_history_stavka_t; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER insert_torg_history_stavka_t BEFORE INSERT ON public.torg_history FOR EACH ROW EXECUTE PROCEDURE public.insert_torg_history_stavka();


--
-- Name: cherniy_pokupatel cherniy_pokupatel_idpokupatel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cherniy_pokupatel
    ADD CONSTRAINT cherniy_pokupatel_idpokupatel_fkey FOREIGN KEY (idcherniy_pokupatel) REFERENCES public.pokupatel(idpokupatel) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cherniy_prodavec cherniy_prodavec_idprodavec_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cherniy_prodavec
    ADD CONSTRAINT cherniy_prodavec_idprodavec_fkey FOREIGN KEY (idcherniy_prodavec) REFERENCES public.prodavec(idprodavec) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dostavka dostavka_idpokupka_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dostavka
    ADD CONSTRAINT dostavka_idpokupka_fkey FOREIGN KEY (idpokupka) REFERENCES public.pokupka(idpokupka) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: expert expert_idpolzovately_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expert
    ADD CONSTRAINT expert_idpolzovately_fkey FOREIGN KEY (idpolzovately) REFERENCES public.polzovately(id);


--
-- Name: expertiza expertiza_idexpert_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expertiza
    ADD CONSTRAINT expertiza_idexpert_fkey FOREIGN KEY (idexpert) REFERENCES public.expert(idexpert) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: expertiza expertiza_idtovar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expertiza
    ADD CONSTRAINT expertiza_idtovar_fkey FOREIGN KEY (idtovar) REFERENCES public.tovar(idtovar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokupatel pokupal_idpolzovately_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokupatel
    ADD CONSTRAINT pokupal_idpolzovately_fkey FOREIGN KEY (idpolzovately) REFERENCES public.polzovately(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokupka pokupka_idpokupatel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokupka
    ADD CONSTRAINT pokupka_idpokupatel_fkey FOREIGN KEY (idpokupatel) REFERENCES public.pokupatel(idpokupatel) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokupka pokupka_idtovar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokupka
    ADD CONSTRAINT pokupka_idtovar_fkey FOREIGN KEY (idtovar) REFERENCES public.tovar(idtovar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prodavec prodavec_idpolzovately_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prodavec
    ADD CONSTRAINT prodavec_idpolzovately_fkey FOREIGN KEY (idpolzovately) REFERENCES public.polzovately(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: torg_history torg_history_idpokupatel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.torg_history
    ADD CONSTRAINT torg_history_idpokupatel_fkey FOREIGN KEY (idpokupatel) REFERENCES public.pokupatel(idpokupatel) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: torg_history torg_history_idtorg_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.torg_history
    ADD CONSTRAINT torg_history_idtorg_fkey FOREIGN KEY (idtorg) REFERENCES public.torg(idtorg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: torg torg_idtovar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.torg
    ADD CONSTRAINT torg_idtovar_fkey FOREIGN KEY (idtovar) REFERENCES public.tovar(idtovar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tovar tovar_idprodavec_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tovar
    ADD CONSTRAINT tovar_idprodavec_fkey FOREIGN KEY (idprodavec) REFERENCES public.prodavec(idprodavec) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tovar tovar_idtypetovara_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tovar
    ADD CONSTRAINT tovar_idtypetovara_fkey FOREIGN KEY (idtypetovara) REFERENCES public.typetovara(idtypetovara) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: typetovara typetovara_idparenttype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typetovara
    ADD CONSTRAINT typetovara_idparenttype_fkey FOREIGN KEY (idparenttype) REFERENCES public.typetovara(idtypetovara) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TABLE polzovately; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.polzovately TO admin;
GRANT SELECT ON TABLE public.polzovately TO seller;
GRANT SELECT ON TABLE public.polzovately TO customer;


--
-- Name: TABLE prodavec; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.prodavec TO admin;


--
-- Name: TABLE tovar; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tovar TO expert;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tovar TO seller;
GRANT SELECT ON TABLE public.tovar TO customer;


--
-- Name: TABLE typetovara; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.typetovara TO expert;
GRANT SELECT ON TABLE public.typetovara TO seller;
GRANT SELECT ON TABLE public.typetovara TO customer;


--
-- Name: TABLE torg; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.torg TO expert;
GRANT SELECT ON TABLE public.torg TO seller;
GRANT SELECT ON TABLE public.torg TO customer;


--
-- Name: TABLE open_torg; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.open_torg TO admin;
GRANT SELECT ON TABLE public.open_torg TO expert;
GRANT SELECT ON TABLE public.open_torg TO seller;
GRANT SELECT ON TABLE public.open_torg TO customer;


--
-- Name: TABLE pokupatel; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.pokupatel TO admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.pokupatel TO seller;
GRANT SELECT,INSERT,UPDATE ON TABLE public.pokupatel TO customer;


--
-- Name: TABLE pokupki; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.pokupki TO seller;
GRANT SELECT ON TABLE public.pokupki TO customer;


--
-- Name: SEQUENCE prodavec_idprodavec_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.prodavec_idprodavec_seq TO admin;


--
-- Name: TABLE torg_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE public.torg_history TO seller;
GRANT SELECT,INSERT ON TABLE public.torg_history TO customer;


--
-- PostgreSQL database dump complete
--

