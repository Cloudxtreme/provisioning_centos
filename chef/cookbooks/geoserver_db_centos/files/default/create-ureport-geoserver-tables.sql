

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;


CREATE TABLE district (id char(5), district varchar(100), slug varchar(100),iso_code varchar(5), poll_id integer ,poll_result varchar(3));

--
-- Name: geoserver_pollcategorydata; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geoserver_pollcategorydata (
    id integer NOT NULL,
    district character varying(100),
    poll_id integer NOT NULL,
    deployment_id integer NOT NULL,
    top_category integer,
    description text NOT NULL
);


ALTER TABLE public.geoserver_pollcategorydata OWNER TO postgres;

--
-- Name: geoserver_pollcategorydata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE geoserver_pollcategorydata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.geoserver_pollcategorydata_id_seq OWNER TO postgres;

--
-- Name: geoserver_pollcategorydata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE geoserver_pollcategorydata_id_seq OWNED BY geoserver_pollcategorydata.id;


--
-- Name: geoserver_pollcategorydata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('geoserver_pollcategorydata_id_seq', 1, false);


--
-- Name: geoserver_polldata; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geoserver_polldata (
    id integer NOT NULL,
    district character varying(100),
    poll_id integer NOT NULL,
    deployment_id integer NOT NULL,
    yes double precision,
    no double precision,
    uncategorized double precision,
    unknown double precision
);


ALTER TABLE public.geoserver_polldata OWNER TO postgres;

--
-- Name: geoserver_polldata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE geoserver_polldata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.geoserver_polldata_id_seq OWNER TO postgres;

--
-- Name: geoserver_polldata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE geoserver_polldata_id_seq OWNED BY geoserver_polldata.id;


--
-- Name: geoserver_polldata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('geoserver_polldata_id_seq', 1, false);


--
-- Name: geoserver_pollresponsedata; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geoserver_pollresponsedata (
    id integer NOT NULL,
    district character varying(100),
    poll_id integer NOT NULL,
    deployment_id integer NOT NULL,
    percentage double precision
);


ALTER TABLE public.geoserver_pollresponsedata OWNER TO postgres;

--
-- Name: geoserver_pollresponsedata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE geoserver_pollresponsedata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.geoserver_pollresponsedata_id_seq OWNER TO postgres;

--
-- Name: geoserver_pollresponsedata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE geoserver_pollresponsedata_id_seq OWNED BY geoserver_pollresponsedata.id;


--
-- Name: geoserver_pollresponsedata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('geoserver_pollresponsedata_id_seq', 1, false);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geoserver_pollcategorydata ALTER COLUMN id SET DEFAULT nextval('geoserver_pollcategorydata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geoserver_polldata ALTER COLUMN id SET DEFAULT nextval('geoserver_polldata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geoserver_pollresponsedata ALTER COLUMN id SET DEFAULT nextval('geoserver_pollresponsedata_id_seq'::regclass);


--
-- Data for Name: geoserver_pollcategorydata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY geoserver_pollcategorydata (id, district, poll_id, deployment_id, top_category, description) FROM stdin;
\.


--
-- Data for Name: geoserver_polldata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY geoserver_polldata (id, district, poll_id, deployment_id, yes, no, uncategorized, unknown) FROM stdin;
\.


--
-- Data for Name: geoserver_pollresponsedata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY geoserver_pollresponsedata (id, district, poll_id, deployment_id, percentage) FROM stdin;
\.


--
-- Name: geoserver_pollcategorydata_deployment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geoserver_pollcategorydata
    ADD CONSTRAINT geoserver_pollcategorydata_deployment_id_key UNIQUE (deployment_id, poll_id, district);


--
-- Name: geoserver_pollcategorydata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geoserver_pollcategorydata
    ADD CONSTRAINT geoserver_pollcategorydata_pkey PRIMARY KEY (id);


--
-- Name: geoserver_polldata_deployment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geoserver_polldata
    ADD CONSTRAINT geoserver_polldata_deployment_id_key UNIQUE (deployment_id, poll_id, district);


--
-- Name: geoserver_polldata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geoserver_polldata
    ADD CONSTRAINT geoserver_polldata_pkey PRIMARY KEY (id);


--
-- Name: geoserver_pollresponsedata_deployment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geoserver_pollresponsedata
    ADD CONSTRAINT geoserver_pollresponsedata_deployment_id_key UNIQUE (deployment_id, poll_id, district);


--
-- Name: geoserver_pollresponsedata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geoserver_pollresponsedata
    ADD CONSTRAINT geoserver_pollresponsedata_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

