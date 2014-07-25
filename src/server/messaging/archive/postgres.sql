--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE messages (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    body text NOT NULL,
    "to" character varying(64) NOT NULL,
    "from" character varying(64) NOT NULL,
    read boolean DEFAULT false NOT NULL,
    local_id character varying(64) NOT NULL,
    "timestamp" timestamp with time zone
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY messages (id, body, "to", "from", read, local_id, "timestamp") FROM stdin;
f2c2cafb-0356-483d-a1bc-090b2ecc05d5		Alpha	Bravo	f	MC4wNjQwNDIwOTI1MzM3ODIxMg==	\N
4bc256ce-537b-4fe5-8b2f-123dc1b654c2	awreawer	Alpha	Bravo	f	MC4zOTk2MDg2NDU1ODgxNTk1Ng==	\N
9a8e6775-cf40-4212-876b-72415e82e901	Hello	Alpha	Bravo	f	MC40NTMyMjc3OTQwMzA2ODEyNQ==	\N
1a0959e3-d752-4e2f-a719-976fea81e022		Alpha	Bravo	f	MC44NjMxMzc4MjA5Njg0MDQ0	\N
f4e21c8b-2232-46d6-9dfe-86b5a815a8fb	juh	Alpha	Bravo	f	MC4wNzY0MDg0MjgxMzk5ODQ2MQ==	\N
efc5fd50-37a1-4b2d-aca5-6fcda114f09d	Hello	Alpha	Bravo	f	MC44MjU5MjM0NzQ1MDU1NDM3	\N
add26e73-f63c-4171-97f2-d4909d1ae799		Alpha	Bravo	f	MC4xMDkxOTUyNTMzNDYxMTUzNQ==	\N
16d4096d-6266-4308-9812-3e8a95b36bab	READ	Alpha	Bravo	f	MC40NzM3Nzc2NDQxMDMzOTI5Ng==	\N
10eb93e7-3595-4b15-ba47-57a99daa666c	Hello	Alpha	Bravo	t	MC40ODYxNzc0NTcwMzA4NjI1Nw==	\N
\.


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

