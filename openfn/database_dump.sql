--
-- PostgreSQL database dump
--

-- Dumped from database version 12.15 (Ubuntu 12.15-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.15 (Ubuntu 12.15-0ubuntu0.20.04.1)

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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


ALTER TYPE public.oban_job_state OWNER TO postgres;

--
-- Name: oban_jobs_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.oban_jobs_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  channel text;
  notice json;
BEGIN
  IF NEW.state = 'available' THEN
    channel = 'public.oban_insert';
    notice = json_build_object('queue', NEW.queue);

    PERFORM pg_notify(channel, notice::text);
  END IF;

  RETURN NULL;
END;
$$;


ALTER FUNCTION public.oban_jobs_notify() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attempt_runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attempt_runs (
    id uuid NOT NULL,
    attempt_id uuid NOT NULL,
    run_id uuid NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.attempt_runs OWNER TO postgres;

--
-- Name: attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attempts (
    id uuid NOT NULL,
    reason_id uuid NOT NULL,
    work_order_id uuid NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.attempts OWNER TO postgres;

--
-- Name: auth_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_providers (
    id uuid NOT NULL,
    name character varying(255),
    client_id character varying(255),
    client_secret character varying(255),
    discovery_url character varying(255),
    redirect_uri character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.auth_providers OWNER TO postgres;

--
-- Name: credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credentials (
    id uuid NOT NULL,
    name character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    user_id uuid,
    body bytea,
    production boolean DEFAULT false,
    schema character varying(40) DEFAULT 'raw'::character varying NOT NULL
);


ALTER TABLE public.credentials OWNER TO postgres;

--
-- Name: credentials_audit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credentials_audit (
    id uuid NOT NULL,
    event character varying(255) NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    row_id uuid NOT NULL,
    actor_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.credentials_audit OWNER TO postgres;

--
-- Name: dataclips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataclips (
    id uuid NOT NULL,
    body jsonb,
    type character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id uuid NOT NULL
);


ALTER TABLE public.dataclips OWNER TO postgres;

--
-- Name: invocation_reasons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invocation_reasons (
    id uuid NOT NULL,
    type character varying(20) NOT NULL,
    trigger_id uuid,
    user_id uuid,
    run_id uuid,
    dataclip_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.invocation_reasons OWNER TO postgres;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id uuid NOT NULL,
    name character varying(255),
    body text,
    enabled boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    adaptor character varying(255),
    project_credential_id uuid,
    workflow_id uuid NOT NULL,
    trigger_id uuid
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- Name: log_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_lines (
    id uuid NOT NULL,
    body character varying(255) NOT NULL,
    "timestamp" integer,
    run_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.log_lines OWNER TO postgres;

--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags character varying(255)[] DEFAULT ARRAY[]::character varying[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT priority_range CHECK (((priority >= 0) AND (priority <= 3))),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


ALTER TABLE public.oban_jobs OWNER TO postgres;

--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.oban_jobs IS '11';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oban_jobs_id_seq OWNER TO postgres;

--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE public.oban_peers OWNER TO postgres;

--
-- Name: project_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_credentials (
    id uuid NOT NULL,
    project_id uuid,
    credential_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.project_credentials OWNER TO postgres;

--
-- Name: project_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_users (
    id uuid NOT NULL,
    user_id uuid,
    project_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    role character varying(255) DEFAULT 'editor'::character varying NOT NULL,
    failure_alert boolean DEFAULT true,
    digest character varying(255) DEFAULT 'weekly'::character varying NOT NULL
);


ALTER TABLE public.project_users OWNER TO postgres;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    name character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    description character varying(255),
    scheduled_deletion timestamp(0) without time zone
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.runs (
    id uuid NOT NULL,
    exit_code integer,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    job_id uuid NOT NULL,
    input_dataclip_id uuid NOT NULL,
    output_dataclip_id uuid,
    previous_id uuid,
    credential_id uuid
);


ALTER TABLE public.runs OWNER TO postgres;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: triggers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.triggers (
    id uuid NOT NULL,
    comment character varying(255),
    custom_path character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    upstream_job_id uuid,
    type character varying(255) NOT NULL,
    cron_expression character varying(255) DEFAULT NULL::character varying,
    workflow_id uuid NOT NULL
);


ALTER TABLE public.triggers OWNER TO postgres;

--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    last_used_at timestamp without time zone
);


ALTER TABLE public.user_tokens OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    email public.citext NOT NULL,
    hashed_password character varying(255) NOT NULL,
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    role character varying(255) NOT NULL,
    disabled boolean DEFAULT false,
    scheduled_deletion timestamp(0) without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: work_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_orders (
    id uuid NOT NULL,
    workflow_id uuid NOT NULL,
    reason_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.work_orders OWNER TO postgres;

--
-- Name: workflow_edges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_edges (
    id uuid NOT NULL,
    workflow_id uuid NOT NULL,
    source_job_id uuid,
    source_trigger_id uuid,
    condition character varying(255),
    target_job_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.workflow_edges OWNER TO postgres;

--
-- Name: workflows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflows (
    id uuid NOT NULL,
    name character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    project_id uuid NOT NULL,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.workflows OWNER TO postgres;

--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Data for Name: attempt_runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attempt_runs (id, attempt_id, run_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attempts (id, reason_id, work_order_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: auth_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_providers (id, name, client_id, client_secret, discovery_url, redirect_uri, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credentials (id, name, inserted_at, updated_at, user_id, body, production, schema) FROM stdin;
\.


--
-- Data for Name: credentials_audit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credentials_audit (id, event, metadata, row_id, actor_id, inserted_at) FROM stdin;
\.


--
-- Data for Name: dataclips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataclips (id, body, type, inserted_at, updated_at, project_id) FROM stdin;
\.


--
-- Data for Name: invocation_reasons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invocation_reasons (id, type, trigger_id, user_id, run_id, dataclip_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, name, body, enabled, inserted_at, updated_at, adaptor, project_credential_id, workflow_id, trigger_id) FROM stdin;
\.


--
-- Data for Name: log_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_lines (id, body, "timestamp", run_id, inserted_at) FROM stdin;
\.


--
-- Data for Name: oban_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oban_jobs (id, state, queue, worker, args, errors, attempt, max_attempts, inserted_at, scheduled_at, attempted_at, completed_at, attempted_by, discarded_at, priority, tags, meta, cancelled_at) FROM stdin;
413	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:14:00.297779	2023-07-05 09:14:00.297779	2023-07-05 09:14:00.422249	2023-07-05 09:14:00.439089	{lightning@574faa93cf35}	\N	1	{}	{}	\N
412	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:14:00.297779	2023-07-05 09:14:00.297779	2023-07-05 09:14:00.422371	2023-07-05 09:14:00.441469	{lightning@574faa93cf35}	\N	1	{}	{}	\N
441	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:34:00.814078	2023-07-05 09:34:00.814078	2023-07-05 09:34:00.934607	2023-07-05 09:34:00.947831	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
440	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:34:00.814078	2023-07-05 09:34:00.814078	2023-07-05 09:34:00.934607	2023-07-05 09:34:00.949482	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
472	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:50:00.095272	2023-07-05 09:50:00.095272	2023-07-05 09:50:00.213878	2023-07-05 09:50:00.227119	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
473	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:50:00.095272	2023-07-05 09:50:00.095272	2023-07-05 09:50:00.213778	2023-07-05 09:50:00.227299	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
415	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:15:00.322851	2023-07-05 09:15:00.322851	2023-07-05 09:15:00.440151	2023-07-05 09:15:00.452617	{lightning@574faa93cf35}	\N	1	{}	{}	\N
414	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:15:00.322851	2023-07-05 09:15:00.322851	2023-07-05 09:15:00.440136	2023-07-05 09:15:00.4528	{lightning@574faa93cf35}	\N	1	{}	{}	\N
445	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:36:00.856021	2023-07-05 09:36:00.856021	2023-07-05 09:36:00.971678	2023-07-05 09:36:00.984319	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
444	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:36:00.856021	2023-07-05 09:36:00.856021	2023-07-05 09:36:00.971603	2023-07-05 09:36:00.986373	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
420	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:23:00.690964	2023-07-05 09:23:00.690964	2023-07-05 09:23:00.805628	2023-07-05 09:23:00.820258	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
421	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:23:00.690964	2023-07-05 09:23:00.690964	2023-07-05 09:23:00.805724	2023-07-05 09:23:00.819587	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
477	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:52:00.133338	2023-07-05 09:52:00.133338	2023-07-05 09:52:00.250719	2023-07-05 09:52:00.263506	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
425	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:25:00.728989	2023-07-05 09:25:00.728989	2023-07-05 09:25:00.85149	2023-07-05 09:25:00.86575	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
424	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:25:00.728989	2023-07-05 09:25:00.728989	2023-07-05 09:25:00.851614	2023-07-05 09:25:00.866768	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
446	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:37:00.872111	2023-07-05 09:37:00.872111	2023-07-05 09:37:00.988697	2023-07-05 09:37:01.000809	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
447	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:37:00.872111	2023-07-05 09:37:00.872111	2023-07-05 09:37:00.988697	2023-07-05 09:37:01.001658	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
429	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:28:00.705524	2023-07-05 09:28:00.705524	2023-07-05 09:28:00.825697	2023-07-05 09:28:00.842766	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
428	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:28:00.705524	2023-07-05 09:28:00.705524	2023-07-05 09:28:00.82563	2023-07-05 09:28:00.843673	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
451	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:39:00.909202	2023-07-05 09:39:00.909202	2023-07-05 09:39:01.025766	2023-07-05 09:39:01.037941	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
450	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:39:00.909202	2023-07-05 09:39:00.909202	2023-07-05 09:39:01.025688	2023-07-05 09:39:01.037978	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
433	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:30:00.739078	2023-07-05 09:30:00.739078	2023-07-05 09:30:00.858677	2023-07-05 09:30:00.871885	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
432	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:30:00.739078	2023-07-05 09:30:00.739078	2023-07-05 09:30:00.85858	2023-07-05 09:30:00.87431	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
437	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:32:00.778016	2023-07-05 09:32:00.778016	2023-07-05 09:32:00.89263	2023-07-05 09:32:00.904718	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
436	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:32:00.778016	2023-07-05 09:32:00.778016	2023-07-05 09:32:00.892609	2023-07-05 09:32:00.906485	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
455	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:41:00.947243	2023-07-05 09:41:00.947243	2023-07-05 09:41:01.063706	2023-07-05 09:41:01.074701	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
454	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:41:00.947243	2023-07-05 09:41:00.947243	2023-07-05 09:41:01.063597	2023-07-05 09:41:01.075039	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
438	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:33:00.793117	2023-07-05 09:33:00.793117	2023-07-05 09:33:00.913732	2023-07-05 09:33:00.925734	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
439	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:33:00.793117	2023-07-05 09:33:00.793117	2023-07-05 09:33:00.913818	2023-07-05 09:33:00.927157	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
462	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:45:00.016197	2023-07-05 09:45:00.016197	2023-07-05 09:45:00.131751	2023-07-05 09:45:00.143899	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
463	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:45:00.016197	2023-07-05 09:45:00.016197	2023-07-05 09:45:00.131956	2023-07-05 09:45:00.144253	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
466	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:47:00.043362	2023-07-05 09:47:00.043362	2023-07-05 09:47:00.159921	2023-07-05 09:47:00.165499	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
467	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:47:00.043362	2023-07-05 09:47:00.043362	2023-07-05 09:47:00.159815	2023-07-05 09:47:00.166935	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
471	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:49:00.079179	2023-07-05 09:49:00.079179	2023-07-05 09:49:00.19476	2023-07-05 09:49:00.208767	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
470	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:49:00.079179	2023-07-05 09:49:00.079179	2023-07-05 09:49:00.194639	2023-07-05 09:49:00.211415	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
417	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:21:00.65973	2023-07-05 09:21:00.65973	2023-07-05 09:21:00.773599	2023-07-05 09:21:00.788969	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
416	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:21:00.65973	2023-07-05 09:21:00.65973	2023-07-05 09:21:00.773685	2023-07-05 09:21:00.791366	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
442	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:35:00.835055	2023-07-05 09:35:00.835055	2023-07-05 09:35:00.955575	2023-07-05 09:35:00.967488	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
443	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:35:00.835055	2023-07-05 09:35:00.835055	2023-07-05 09:35:00.95567	2023-07-05 09:35:00.968577	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
475	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:51:00.114312	2023-07-05 09:51:00.114312	2023-07-05 09:51:00.232724	2023-07-05 09:51:00.24584	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
474	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:51:00.114312	2023-07-05 09:51:00.114312	2023-07-05 09:51:00.232725	2023-07-05 09:51:00.248197	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
419	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:22:00.674069	2023-07-05 09:22:00.674069	2023-07-05 09:22:00.790514	2023-07-05 09:22:00.804953	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
418	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:22:00.674069	2023-07-05 09:22:00.674069	2023-07-05 09:22:00.790619	2023-07-05 09:22:00.806464	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
476	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:52:00.133338	2023-07-05 09:52:00.133338	2023-07-05 09:52:00.250719	2023-07-05 09:52:00.263074	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
448	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:38:00.889225	2023-07-05 09:38:00.889225	2023-07-05 09:38:01.008682	2023-07-05 09:38:01.021621	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
449	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:38:00.889225	2023-07-05 09:38:00.889225	2023-07-05 09:38:01.008682	2023-07-05 09:38:01.022711	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
423	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:24:00.706223	2023-07-05 09:24:00.706223	2023-07-05 09:24:00.828552	2023-07-05 09:24:00.842563	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
422	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:24:00.706223	2023-07-05 09:24:00.706223	2023-07-05 09:24:00.828552	2023-07-05 09:24:00.843273	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
426	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:26:00.752234	2023-07-05 09:26:00.752234	2023-07-05 09:26:00.87266	2023-07-05 09:26:00.88577	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
427	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:26:00.752234	2023-07-05 09:26:00.752234	2023-07-05 09:26:00.872568	2023-07-05 09:26:00.886698	{lightning@c8cbd9dd9079}	\N	1	{}	{}	\N
452	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:40:00.926269	2023-07-05 09:40:00.926269	2023-07-05 09:40:01.046615	2023-07-05 09:40:01.05904	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
453	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:40:00.926269	2023-07-05 09:40:00.926269	2023-07-05 09:40:01.046708	2023-07-05 09:40:01.059225	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
478	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:53:00.150784	2023-07-05 09:53:00.150784	2023-07-05 09:53:00.256638	2023-07-05 09:53:00.26005	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
431	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:29:00.726146	2023-07-05 09:29:00.726146	2023-07-05 09:29:00.838566	2023-07-05 09:29:00.843775	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
430	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:29:00.726146	2023-07-05 09:29:00.726146	2023-07-05 09:29:00.838594	2023-07-05 09:29:00.846973	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
457	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:42:00.962999	2023-07-05 09:42:00.962999	2023-07-05 09:42:01.079743	2023-07-05 09:42:01.091493	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
456	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:42:00.962999	2023-07-05 09:42:00.962999	2023-07-05 09:42:01.079821	2023-07-05 09:42:01.091566	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
435	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:31:00.759079	2023-07-05 09:31:00.759079	2023-07-05 09:31:00.877609	2023-07-05 09:31:00.883458	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
434	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:31:00.759079	2023-07-05 09:31:00.759079	2023-07-05 09:31:00.877705	2023-07-05 09:31:00.885616	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
458	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:43:00.980293	2023-07-05 09:43:00.980293	2023-07-05 09:43:01.098759	2023-07-05 09:43:01.103669	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
459	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:43:00.980293	2023-07-05 09:43:00.980293	2023-07-05 09:43:01.09876	2023-07-05 09:43:01.104374	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
461	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:44:00.999396	2023-07-05 09:44:00.999396	2023-07-05 09:44:01.115744	2023-07-05 09:44:01.129939	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
460	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:44:00.999396	2023-07-05 09:44:00.999396	2023-07-05 09:44:01.115744	2023-07-05 09:44:01.131191	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
464	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:46:00.032341	2023-07-05 09:46:00.032341	2023-07-05 09:46:00.14271	2023-07-05 09:46:00.155756	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
465	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:46:00.032341	2023-07-05 09:46:00.032341	2023-07-05 09:46:00.142596	2023-07-05 09:46:00.155803	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
468	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:48:00.060292	2023-07-05 09:48:00.060292	2023-07-05 09:48:00.178752	2023-07-05 09:48:00.191482	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
469	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:48:00.060292	2023-07-05 09:48:00.060292	2023-07-05 09:48:00.178634	2023-07-05 09:48:00.19152	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
479	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:53:00.150784	2023-07-05 09:53:00.150784	2023-07-05 09:53:00.256586	2023-07-05 09:53:00.260121	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
480	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:54:00.157114	2023-07-05 09:54:00.157114	2023-07-05 09:54:00.267719	2023-07-05 09:54:00.278992	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
481	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:54:00.157114	2023-07-05 09:54:00.157114	2023-07-05 09:54:00.2678	2023-07-05 09:54:00.279448	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
482	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-05 09:55:00.167126	2023-07-05 09:55:00.167126	2023-07-05 09:55:00.282566	2023-07-05 09:55:00.294033	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
483	completed	background	ObanPruner	{}	{}	1	10	2023-07-05 09:55:00.167126	2023-07-05 09:55:00.167126	2023-07-05 09:55:00.2826	2023-07-05 09:55:00.294837	{lightning@23a41fdc0498}	\N	1	{}	{}	\N
\.


--
-- Data for Name: oban_peers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oban_peers (name, node, started_at, expires_at) FROM stdin;
Oban	lightning@23a41fdc0498	2023-07-05 09:27:15.722255	2023-07-05 09:56:06.902368
\.


--
-- Data for Name: project_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_credentials (id, project_id, credential_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_users (id, user_id, project_id, inserted_at, updated_at, role, failure_alert, digest) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, name, inserted_at, updated_at, description, scheduled_deletion) FROM stdin;
\.


--
-- Data for Name: runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.runs (id, exit_code, started_at, finished_at, inserted_at, updated_at, job_id, input_dataclip_id, output_dataclip_id, previous_id, credential_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20220131123309	2023-07-04 09:31:02
20220203064043	2023-07-04 09:31:02
20220203105048	2023-07-04 09:31:02
20220203113423	2023-07-04 09:31:02
20220203115038	2023-07-04 09:31:02
20220204132838	2023-07-04 09:31:02
20220318131809	2023-07-04 09:31:02
20220323142451	2023-07-04 09:31:02
20220330120109	2023-07-04 09:31:02
20220405135153	2023-07-04 09:31:02
20220406120829	2023-07-04 09:31:02
20220407083037	2023-07-04 09:31:02
20220421112130	2023-07-04 09:31:02
20220422070428	2023-07-04 09:31:02
20220425081355	2023-07-04 09:31:02
20220427134649	2023-07-04 09:31:02
20220511131955	2023-07-04 09:31:02
20220516085949	2023-07-04 09:31:02
20220517071211	2023-07-04 09:31:02
20220518153937	2023-07-04 09:31:02
20220523070944	2023-07-04 09:31:02
20220524130458	2023-07-04 09:31:02
20220525092539	2023-07-04 09:31:02
20220610084120	2023-07-04 09:31:02
20220713081331	2023-07-04 09:31:02
20220720082641	2023-07-04 09:31:02
20220725121505	2023-07-04 09:31:02
20220726111821	2023-07-04 09:31:02
20220804120532	2023-07-04 09:31:02
20220816091509	2023-07-04 09:31:02
20220817063920	2023-07-04 09:31:02
20220819100204	2023-07-04 09:31:02
20220823082452	2023-07-04 09:31:02
20220829103340	2023-07-04 09:31:02
20220829103843	2023-07-04 09:31:02
20220905153252	2023-07-04 09:31:02
20221007121156	2023-07-04 09:31:02
20221012121406	2023-07-04 09:31:02
20221013105320	2023-07-04 09:31:02
20221014123709	2023-07-04 09:31:02
20221017071302	2023-07-04 09:31:02
20221017071303	2023-07-04 09:31:02
20221017071603	2023-07-04 09:31:02
20221025102818	2023-07-04 09:31:02
20221025132735	2023-07-04 09:31:02
20221221042025	2023-07-04 09:31:02
20230105142554	2023-07-04 09:31:02
20230110173451	2023-07-04 09:31:02
20230113031058	2023-07-04 09:31:02
20230117125103	2023-07-04 09:31:02
20230131060317	2023-07-04 09:31:02
20230322155124	2023-07-04 09:31:02
20230418125059	2023-07-04 09:31:02
20230419234837	2023-07-04 09:31:02
20230424072332	2023-07-04 09:31:02
20230424145801	2023-07-04 09:31:02
20230601081429	2023-07-04 09:31:02
20230601081507	2023-07-04 09:31:02
20230611205332	2023-07-04 09:31:02
\.


--
-- Data for Name: triggers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.triggers (id, comment, custom_path, inserted_at, updated_at, upstream_job_id, type, cron_expression, workflow_id) FROM stdin;
\.


--
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tokens (id, user_id, token, context, sent_to, inserted_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, first_name, last_name, email, hashed_password, confirmed_at, inserted_at, updated_at, role, disabled, scheduled_deletion) FROM stdin;
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_orders (id, workflow_id, reason_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: workflow_edges; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_edges (id, workflow_id, source_job_id, source_trigger_id, condition, target_job_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: workflows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflows (id, name, inserted_at, updated_at, project_id, deleted_at) FROM stdin;
\.


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oban_jobs_id_seq', 483, true);


--
-- Name: attempt_runs attempt_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attempt_runs
    ADD CONSTRAINT attempt_runs_pkey PRIMARY KEY (id, attempt_id, run_id);


--
-- Name: attempts attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attempts
    ADD CONSTRAINT attempts_pkey PRIMARY KEY (id);


--
-- Name: auth_providers auth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_providers
    ADD CONSTRAINT auth_providers_pkey PRIMARY KEY (id);


--
-- Name: credentials_audit credentials_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credentials_audit
    ADD CONSTRAINT credentials_audit_pkey PRIMARY KEY (id);


--
-- Name: credentials credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_pkey PRIMARY KEY (id);


--
-- Name: dataclips dataclips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataclips
    ADD CONSTRAINT dataclips_pkey PRIMARY KEY (id);


--
-- Name: invocation_reasons invocation_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invocation_reasons
    ADD CONSTRAINT invocation_reasons_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: log_lines log_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_lines
    ADD CONSTRAINT log_lines_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: project_credentials project_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_credentials
    ADD CONSTRAINT project_credentials_pkey PRIMARY KEY (id);


--
-- Name: project_users project_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: runs runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: triggers triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT triggers_pkey PRIMARY KEY (id);


--
-- Name: user_tokens user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_pkey PRIMARY KEY (id);


--
-- Name: workflow_edges workflow_edges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_edges
    ADD CONSTRAINT workflow_edges_pkey PRIMARY KEY (id);


--
-- Name: workflows workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (id);


--
-- Name: attempts_work_order_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX attempts_work_order_id_index ON public.attempts USING btree (work_order_id);


--
-- Name: credentials_audit_row_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX credentials_audit_row_id_index ON public.credentials_audit USING btree (row_id);


--
-- Name: credentials_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX credentials_user_id_index ON public.credentials USING btree (user_id);


--
-- Name: dataclips_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataclips_project_id_index ON public.dataclips USING btree (project_id);


--
-- Name: invocation_reasons_dataclip_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invocation_reasons_dataclip_id_index ON public.invocation_reasons USING btree (dataclip_id);


--
-- Name: invocation_reasons_run_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invocation_reasons_run_id_index ON public.invocation_reasons USING btree (run_id);


--
-- Name: invocation_reasons_trigger_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invocation_reasons_trigger_id_index ON public.invocation_reasons USING btree (trigger_id);


--
-- Name: invocation_reasons_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invocation_reasons_user_id_index ON public.invocation_reasons USING btree (user_id);


--
-- Name: jobs_id_workflow_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX jobs_id_workflow_id_index ON public.jobs USING btree (id, workflow_id);


--
-- Name: jobs_workflow_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jobs_workflow_id_index ON public.jobs USING btree (workflow_id);


--
-- Name: log_lines_run_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX log_lines_run_id_index ON public.log_lines USING btree (run_id);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: project_credentials_credential_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_credentials_credential_id_index ON public.project_credentials USING btree (credential_id);


--
-- Name: project_credentials_project_id_credential_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX project_credentials_project_id_credential_id_index ON public.project_credentials USING btree (project_id, credential_id);


--
-- Name: project_credentials_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_credentials_project_id_index ON public.project_credentials USING btree (project_id);


--
-- Name: project_users_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_users_project_id_index ON public.project_users USING btree (project_id);


--
-- Name: project_users_project_id_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX project_users_project_id_user_id_index ON public.project_users USING btree (project_id, user_id);


--
-- Name: project_users_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_users_user_id_index ON public.project_users USING btree (user_id);


--
-- Name: runs_previous_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX runs_previous_id_index ON public.runs USING btree (previous_id);


--
-- Name: triggers_id_workflow_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX triggers_id_workflow_id_index ON public.triggers USING btree (id, workflow_id);


--
-- Name: triggers_upstream_job_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX triggers_upstream_job_id_index ON public.triggers USING btree (upstream_job_id);


--
-- Name: triggers_workflow_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX triggers_workflow_id_index ON public.triggers USING btree (workflow_id);


--
-- Name: user_tokens_context_token_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_tokens_context_token_index ON public.user_tokens USING btree (context, token);


--
-- Name: user_tokens_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_tokens_user_id_index ON public.user_tokens USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: work_orders_reason_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX work_orders_reason_id_index ON public.work_orders USING btree (reason_id);


--
-- Name: work_orders_workflow_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX work_orders_workflow_id_index ON public.work_orders USING btree (workflow_id);


--
-- Name: workflows_name_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX workflows_name_project_id_index ON public.workflows USING btree (name, project_id);


--
-- Name: oban_jobs oban_notify; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oban_notify AFTER INSERT ON public.oban_jobs FOR EACH ROW EXECUTE FUNCTION public.oban_jobs_notify();


--
-- Name: attempt_runs attempt_runs_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attempt_runs
    ADD CONSTRAINT attempt_runs_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.attempts(id) ON DELETE CASCADE;


--
-- Name: attempt_runs attempt_runs_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attempt_runs
    ADD CONSTRAINT attempt_runs_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.runs(id) ON DELETE CASCADE;


--
-- Name: attempts attempts_reason_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attempts
    ADD CONSTRAINT attempts_reason_id_fkey FOREIGN KEY (reason_id) REFERENCES public.invocation_reasons(id);


--
-- Name: attempts attempts_work_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attempts
    ADD CONSTRAINT attempts_work_order_id_fkey FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id) ON DELETE CASCADE;


--
-- Name: credentials_audit credentials_audit_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credentials_audit
    ADD CONSTRAINT credentials_audit_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: credentials credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: dataclips dataclips_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataclips
    ADD CONSTRAINT dataclips_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: invocation_reasons invocation_reasons_dataclip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invocation_reasons
    ADD CONSTRAINT invocation_reasons_dataclip_id_fkey FOREIGN KEY (dataclip_id) REFERENCES public.dataclips(id);


--
-- Name: invocation_reasons invocation_reasons_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invocation_reasons
    ADD CONSTRAINT invocation_reasons_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.runs(id);


--
-- Name: invocation_reasons invocation_reasons_trigger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invocation_reasons
    ADD CONSTRAINT invocation_reasons_trigger_id_fkey FOREIGN KEY (trigger_id) REFERENCES public.triggers(id);


--
-- Name: invocation_reasons invocation_reasons_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invocation_reasons
    ADD CONSTRAINT invocation_reasons_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: jobs jobs_project_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_project_credential_id_fkey FOREIGN KEY (project_credential_id) REFERENCES public.project_credentials(id) ON DELETE SET NULL;


--
-- Name: jobs jobs_trigger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_trigger_id_fkey FOREIGN KEY (trigger_id) REFERENCES public.triggers(id);


--
-- Name: jobs jobs_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: log_lines log_lines_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_lines
    ADD CONSTRAINT log_lines_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.runs(id) ON DELETE CASCADE;


--
-- Name: project_credentials project_credentials_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_credentials
    ADD CONSTRAINT project_credentials_credential_id_fkey FOREIGN KEY (credential_id) REFERENCES public.credentials(id) ON DELETE CASCADE;


--
-- Name: project_credentials project_credentials_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_credentials
    ADD CONSTRAINT project_credentials_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_users project_users_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_users project_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: runs runs_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_credential_id_fkey FOREIGN KEY (credential_id) REFERENCES public.credentials(id);


--
-- Name: runs runs_input_dataclip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_input_dataclip_id_fkey FOREIGN KEY (input_dataclip_id) REFERENCES public.dataclips(id) ON DELETE CASCADE;


--
-- Name: runs runs_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: runs runs_output_dataclip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_output_dataclip_id_fkey FOREIGN KEY (output_dataclip_id) REFERENCES public.dataclips(id) ON DELETE CASCADE;


--
-- Name: runs runs_previous_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_previous_id_fkey FOREIGN KEY (previous_id) REFERENCES public.runs(id) ON DELETE CASCADE;


--
-- Name: triggers triggers_upstream_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT triggers_upstream_job_id_fkey FOREIGN KEY (upstream_job_id) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: triggers triggers_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT triggers_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: user_tokens user_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: work_orders work_orders_reason_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_reason_id_fkey FOREIGN KEY (reason_id) REFERENCES public.invocation_reasons(id);


--
-- Name: work_orders work_orders_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: workflow_edges workflow_edges_source_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_edges
    ADD CONSTRAINT workflow_edges_source_job_id_fkey FOREIGN KEY (source_job_id, workflow_id) REFERENCES public.jobs(id, workflow_id) ON DELETE CASCADE;


--
-- Name: workflow_edges workflow_edges_source_trigger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_edges
    ADD CONSTRAINT workflow_edges_source_trigger_id_fkey FOREIGN KEY (source_trigger_id, workflow_id) REFERENCES public.triggers(id, workflow_id) ON DELETE CASCADE;


--
-- Name: workflow_edges workflow_edges_target_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_edges
    ADD CONSTRAINT workflow_edges_target_job_id_fkey FOREIGN KEY (target_job_id, workflow_id) REFERENCES public.jobs(id, workflow_id) ON DELETE CASCADE;


--
-- Name: workflow_edges workflow_edges_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_edges
    ADD CONSTRAINT workflow_edges_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: workflows workflows_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

