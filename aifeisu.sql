--
-- PostgreSQL database dump
--

\restrict da1n2rZ8o4g3PILNL95Jw1g7xrAZUp4czYb0jTo3dyocTWqgvZmQzPY9e71sYL7

-- Dumped from database version 18.2
-- Dumped by pg_dump version 18.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: aifeisu
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO aifeisu;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: aifeisu
--

CREATE TABLE public.sessions (
    sid character varying(255) NOT NULL,
    sess json NOT NULL,
    expire timestamp with time zone NOT NULL
);


ALTER TABLE public.sessions OWNER TO aifeisu;

--
-- Name: social_accounts; Type: TABLE; Schema: public; Owner: aifeisu
--

CREATE TABLE public.social_accounts (
    id integer NOT NULL,
    user_id integer,
    provider character varying(50) NOT NULL,
    provider_id character varying(255) NOT NULL,
    email character varying(255),
    name character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.social_accounts OWNER TO aifeisu;

--
-- Name: social_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: aifeisu
--

CREATE SEQUENCE public.social_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.social_accounts_id_seq OWNER TO aifeisu;

--
-- Name: social_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aifeisu
--

ALTER SEQUENCE public.social_accounts_id_seq OWNED BY public.social_accounts.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: aifeisu
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    avatar text,
    role character varying(20) DEFAULT 'user'::character varying,
    reset_password_token character varying(255),
    reset_password_expire timestamp with time zone,
    is_active boolean DEFAULT true,
    last_login timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO aifeisu;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: aifeisu
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO aifeisu;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aifeisu
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: social_accounts id; Type: DEFAULT; Schema: public; Owner: aifeisu
--

ALTER TABLE ONLY public.social_accounts ALTER COLUMN id SET DEFAULT nextval('public.social_accounts_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: aifeisu
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: aifeisu
--

COPY public.sessions (sid, sess, expire) FROM stdin;
\.


--
-- Data for Name: social_accounts; Type: TABLE DATA; Schema: public; Owner: aifeisu
--

COPY public.social_accounts (id, user_id, provider, provider_id, email, name, created_at, updated_at) FROM stdin;
1	1	google	google123456789	john@example.com	John Doe	2026-02-27 00:22:15.50374-05	2026-02-27 00:22:15.50374-05
2	3	google	116739758043890559513	swordzjy11@gmail.com	Sword	2026-02-27 00:23:31.280527-05	2026-02-27 00:23:31.280527-05
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: aifeisu
--

COPY public.users (id, name, email, password, avatar, role, reset_password_token, reset_password_expire, is_active, last_login, created_at, updated_at) FROM stdin;
1	John Doe	john@example.com	$2a$10$8K1p/aWxXoLtwS32cWMz/OJrPDWLn9QqH.sT/Q.KLmXQ3hCZ8VAy2	\N	user	\N	\N	t	\N	2026-02-27 00:22:15.501267-05	2026-02-27 00:22:15.501267-05
2	Admin User	admin@example.com	$2a$10$8K1p/aWxXoLtwS32cWMz/OJrPDWLn9QqH.sT/Q.KLmXQ3hCZ8VAy2	\N	admin	\N	\N	t	\N	2026-02-27 00:22:15.501267-05	2026-02-27 00:22:15.501267-05
4	abc	abc@aifeisu.cn	$2a$10$9fvqc9HzqIWwPCyMPCt7c.DSmpOL813iOXYOKIYCZScsHP63d9JX2	\N	user	\N	\N	t	\N	2026-02-27 02:18:13.255022-05	2026-02-27 02:18:13.255022-05
3	Sword	swordzjy11@gmail.com	$2a$10$Y2Hj1RWzxN9JRLZn5NXo0eQCqAU33z04SQVyVUGthMZhqvKHkOF5K	https://lh3.googleusercontent.com/a/ACg8ocK0HrWDlPZ4GGB2rfTpth_k0Rm8xANqCaQ9cTty4HFez76EKUU=s96-c	user	f1375ad6a33b523cf0c1460f196ed8ce3e94e3ca92a15ed3e3ce3fb71ed8ce5e	2026-02-27 04:12:09.69-05	t	\N	2026-02-27 00:23:31.27733-05	2026-02-27 04:02:09.69437-05
\.


--
-- Name: social_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aifeisu
--

SELECT pg_catalog.setval('public.social_accounts_id_seq', 2, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aifeisu
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: aifeisu
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (sid);


--
-- Name: social_accounts social_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: aifeisu
--

ALTER TABLE ONLY public.social_accounts
    ADD CONSTRAINT social_accounts_pkey PRIMARY KEY (id);


--
-- Name: social_accounts social_accounts_user_id_provider_provider_id_key; Type: CONSTRAINT; Schema: public; Owner: aifeisu
--

ALTER TABLE ONLY public.social_accounts
    ADD CONSTRAINT social_accounts_user_id_provider_provider_id_key UNIQUE (user_id, provider, provider_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: aifeisu
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: aifeisu
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_sessions_expire; Type: INDEX; Schema: public; Owner: aifeisu
--

CREATE INDEX idx_sessions_expire ON public.sessions USING btree (expire);


--
-- Name: idx_social_accounts_provider; Type: INDEX; Schema: public; Owner: aifeisu
--

CREATE INDEX idx_social_accounts_provider ON public.social_accounts USING btree (provider, provider_id);


--
-- Name: idx_social_accounts_user_id; Type: INDEX; Schema: public; Owner: aifeisu
--

CREATE INDEX idx_social_accounts_user_id ON public.social_accounts USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: aifeisu
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_reset_token; Type: INDEX; Schema: public; Owner: aifeisu
--

CREATE INDEX idx_users_reset_token ON public.users USING btree (reset_password_token);


--
-- Name: social_accounts update_social_accounts_updated_at; Type: TRIGGER; Schema: public; Owner: aifeisu
--

CREATE TRIGGER update_social_accounts_updated_at BEFORE UPDATE ON public.social_accounts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: aifeisu
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: social_accounts social_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aifeisu
--

ALTER TABLE ONLY public.social_accounts
    ADD CONSTRAINT social_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict da1n2rZ8o4g3PILNL95Jw1g7xrAZUp4czYb0jTo3dyocTWqgvZmQzPY9e71sYL7

