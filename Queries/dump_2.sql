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
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


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
-- Name: add_user(text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_user(p_name text, p_surname text, p_password text, p_udoslich text, p_phone text, p_email text) RETURNS void
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
	
	IF char_length(p_password) != 32
		THEN p_password := MD5(p_password);
	END IF;
	
	INSERT INTO polzovately (udoslich, name, surname, email, telefon)
			VALUES (p_udoslich, p_name, p_surname, p_email, p_phone)
	RETURNING id INTO v_idpolzovately;
			
	INSERT INTO pokupatel (idpolzovately) VALUES (v_idpolzovately);
	
	new_user= 'INSERT INTO Login (phone, password, role) VALUES ('''|| p_phone ||''', '''|| p_password || ''', 4)';
	RAISE NOTICE '%', new_user;
	
	PERFORM dblink_exec('dbname=users host=localhost port=5433 user=postgres password=postgres',new_user);
	
END;
$$;


ALTER FUNCTION public.add_user(p_name text, p_surname text, p_password text, p_udoslich text, p_phone text, p_email text) OWNER TO postgres;

--
-- Name: FUNCTION add_user(p_name text, p_surname text, p_password text, p_udoslich text, p_phone text, p_email text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.add_user(p_name text, p_surname text, p_password text, p_udoslich text, p_phone text, p_email text) IS 'Регистрация пользователя как покупателя. 
								Для регистрации продавца пользователь отпарвляет заявку администратору. 
								Для регистрации эксперта, администратор лично создает в личном кабинете';


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
-- Name: pokupatel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pokupatel (
    idpokupatel integer NOT NULL,
    idpolzovately integer NOT NULL
);


ALTER TABLE public.pokupatel OWNER TO postgres;

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
-- Name: torg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.torg (
    idtorg integer NOT NULL,
    idtovar integer NOT NULL,
    data_open timestamp without time zone NOT NULL,
    data_close timestamp without time zone NOT NULL,
    max_stavka numeric NOT NULL,
    min_stavka numeric NOT NULL,
    CONSTRAINT torg_max_stavka_check CHECK ((max_stavka > (0)::numeric)),
    CONSTRAINT torg_min_stavka_check CHECK ((min_stavka > (0)::numeric))
);


ALTER TABLE public.torg OWNER TO postgres;

--
-- Name: torg_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.torg_history (
    idtorg_history integer NOT NULL,
    idpokupatel integer NOT NULL,
    idtorg integer NOT NULL,
    stavka numeric NOT NULL,
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
-- Data for Name: cherniy_pokupatel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cherniy_pokupatel (idcherniy_pokupatel, prichina) FROM stdin;
2	krichit vo vremya aukciona
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
2	Pochta	1	Saharova
3	Kuryerskaya	2	Korolova 24
4	Samovivoz	3	Bocharova
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

COPY public.pokupatel (idpokupatel, idpolzovately) FROM stdin;
1	9
2	10
3	11
4	12
5	13
6	14
7	15
8	16
15	23
17	25
\.


--
-- Data for Name: pokupka; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pokupka (idpokupka, datapokupki, itogstoimosty, idpokupatel, idtovar) FROM stdin;
1	2020-04-12	100000	1	1
3	2020-08-12	14320	2	3
2	2020-04-15	10000000000000	8	2
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
1	2	2020-03-12 00:00:00	2020-03-12 00:00:00	100000	1200
2	1	2020-03-22 00:00:00	2020-03-22 00:00:00	10000000000000	1000000000
3	3	2020-03-14 00:00:00	2020-03-14 00:00:00	14320	600
\.


--
-- Data for Name: torg_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.torg_history (idtorg_history, idpokupatel, idtorg, stavka) FROM stdin;
1	1	2	1200
4	1	2	100000
9	1	3	600
2	8	2	10000
3	3	2	10020
5	7	1	1000000000
6	3	1	100000003000
7	7	1	1000000000000
8	4	1	10000000000000
10	6	3	800
11	5	3	1200
12	2	3	14320
13	1	1	1200
16	3	2	1000
\.


--
-- Data for Name: tovar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tovar (idtovar, document, name, sostoyanie, idtypetovara, idprodavec, stoimosty) FROM stdin;
2	2	Pufic Ravshana	B/U	2	1	1200
1	1	Divan Kleoptry	B/U	2	1	1000000000
5	4\n	Budilnik marsianina	B/U	2	3	1500000000
3	ДОСТАЛИ Архидревний стул  99/12/14	Stulchak Fizrucka	B/U	2	1	600
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
-- PostgreSQL database dump complete
--

