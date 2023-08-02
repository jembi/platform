--
-- PostgreSQL database dump
--

-- Dumped from database version 14.8
-- Dumped by pg_dump version 14.8

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
50fd4f98-f6aa-4af6-859f-58a87d46ffd2	e8d92984-cac4-42b3-90c9-aeadaa34a9b6	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:41.458315	2023-08-01 21:17:41.458315
a5130c55-c206-495e-8839-f796fcd7b2de	f4751ed4-fbbe-48d5-be4e-3aad136c48d5	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:09.540164	2023-08-01 21:18:09.540164
6d907268-f867-41f1-922f-727f17817a37	51ca5774-b45c-462b-aee3-53d153e5f04d	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:53.756942	2023-08-01 21:21:53.756942
ef2414fd-27f7-448e-9917-70c1779596d6	f4ff6a79-5eac-45f6-b0d4-03d53ca1a66a	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:45.17106	2023-08-01 21:27:45.17106
762246bd-b2a4-4831-9896-4e0086bf763e	576e75ee-a48a-4e0e-84f7-36c0f883c086	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:22.109322	2023-08-01 21:30:22.109322
bcfaf9d3-b26d-4b05-bb2a-dbce489c0180	0e4c5854-e15c-4d11-a64f-52c24bcabd0e	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:32.798309	2023-08-01 21:31:32.798309
d3f5ec58-9483-4a5a-8a00-a969d6fdaf81	be82a0b5-6742-45cf-96f9-ceed9345eba0	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:12.562442	2023-08-01 21:33:12.562442
91a1dbc9-c8bd-4846-9cd2-a61076b3bebf	01c42f93-aaa3-460a-8053-dc1888938f3e	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:33.381214	2023-08-01 21:35:33.381214
5d355b68-59f1-415a-95be-6058f9e8909c	37f7aa2d-2ef0-4114-94a6-73499b13e858	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:19.692019	2023-08-01 21:38:19.692019
dafc66d0-a0b0-430b-8268-41c1d6355f0a	d3e15ee2-a830-449a-a61d-074f250cfc68	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:18.38623	2023-08-01 21:44:18.38623
194043e6-d490-446e-9667-b8b964d9ab29	3f70ce29-cac1-4c58-a3e6-1b06dfeaf16a	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:24.215	2023-08-01 22:00:24.215
c04d0ea6-ab9b-4fab-afb3-821c88f2ec4e	c89458d0-0f1c-46c1-97b5-f66a5fe70d61	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:05.542199	2023-08-01 22:03:05.542199
514de2a5-1a83-4b01-843a-a687962fbc24	09b55c20-d015-4ccd-9730-85d5f49308b9	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:51.621604	2023-08-01 22:07:51.621604
8847e854-f9d7-4bc5-b165-505ae14223c5	e0fecd06-72b3-42b7-a50a-5eb395870fee	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:01.149458	2023-08-01 22:13:01.149458
1cf68d60-0015-4526-b13c-996e20583e3a	6ee5fede-ca95-4b1a-83ea-6bab4de983fb	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:26.973499	2023-08-01 22:14:26.973499
d1de9b18-e92d-4eda-a688-b569e443f625	4f038558-fcd6-4c9b-a41c-35aba8e5cb57	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:54.714804	2023-08-01 22:15:54.714804
12cb32cb-160a-4148-8bb9-8db4385b75dc	af462ae8-ee6d-4022-8432-8d2df07387eb	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:31.347107	2023-08-01 22:16:31.347107
538ed337-8ac4-4420-a4e9-6081f78c6617	3a8ba912-e276-4318-b7e4-f30d78b05281	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:50.478423	2023-08-01 22:17:50.478423
89a2a04f-359e-4c72-8a32-6d1ca016a03f	e622c0fd-2b19-4ce4-9bcd-cc5199430f0c	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:26.717279	2023-08-01 22:18:26.717279
af03693a-f255-403b-8326-e2d81ee409fb	6dd51a1f-6a3f-48eb-aece-6b22bb72a86f	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:28.929114	2023-08-01 22:18:28.929114
ea49af8c-7249-4038-a2f8-10d3b682548c	ae79002b-bf6f-436e-a5d6-73d203eb63e1	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:55.895599	2023-08-01 22:19:55.895599
7849b60b-4e45-40a3-9b98-acff4fbee0f8	271c5e6c-a511-4ba2-b3ac-a2a0cd0a13f7	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:33.057719	2023-08-01 22:20:33.057719
be332f13-797a-44b3-813c-e72eacb03ab4	cd728aa6-83dd-4d5b-994f-8036a43c003e	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:06.567595	2023-08-01 22:22:06.567595
f751bf30-72be-46ad-b683-c3de5455dbaa	1425c962-166b-4455-b116-24d415760d66	3fd4d22b-a7f5-40c5-b774-9e20fd96f57a	2023-08-01 22:23:41.953975	2023-08-01 22:23:41.953975
894f0c47-ec8f-4368-a9fe-ecf2e07cc58e	d6289627-a8dd-4de7-a38c-e8ea7ad06a64	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:17.515012	2023-08-01 22:24:17.515012
98c60f31-5537-4686-82de-41c1eb9da9b3	6d7436ae-ec1f-4de4-8509-81834385d284	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:27.368459	2023-08-01 22:25:27.368459
281e1992-3b3e-4bdc-bc0e-67b09f828987	bc768b00-1892-408b-b801-fc7a0cdffaf7	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:28.215221	2023-08-01 22:26:28.215221
3677379f-cfda-4d32-8480-983a07360e27	fd99f0a7-be27-4a30-b541-c72d38b34960	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:12.347735	2023-08-01 22:27:12.347735
1f265c9b-4c81-4774-823c-f894d86359b0	53d79ac5-aeaa-46be-ab5f-19e294400464	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:39.372545	2023-08-01 22:27:39.372545
1f1806e2-7391-4bc8-86fb-d57118fe2789	be570b27-40d9-44ad-b269-f9e7d75d4eab	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:27.174114	2023-08-01 22:28:27.174114
f10a711b-8274-4337-af1c-7adf51f4f77e	3fd998ca-2ad1-46b5-b509-3f34e7e944cc	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:44.423173	2023-08-01 22:30:44.423173
6a530398-792b-4ac7-9201-24bed9b86255	5e360e9b-a015-4c32-88e1-9a8d3e7520ba	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:47.140672	2023-08-01 22:33:47.140672
5db5d52e-e80f-4142-ab92-f0943f1daddf	8d1b6345-05a6-4d87-97e4-33a70e1552be	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:18.303512	2023-08-01 22:36:18.303512
c109730d-5cc5-4506-aac2-074fec487eb4	83c3becf-9443-464f-83d0-985970049e64	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:56.978166	2023-08-01 22:38:56.978166
2d9ca897-20c5-45df-9302-86b1dd13b5ea	cb7f80c3-c2aa-46a4-8253-4c58903713b4	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:26.476795	2023-08-01 22:39:26.476795
dcc8f3ec-a727-4d7f-9eb7-5a34ff874600	5d1278a3-e25f-4fb7-bb5e-40e4919bde2c	dc5c1447-c8e8-4122-9fa4-094ee70a4e45	2023-08-01 22:40:03.404771	2023-08-01 22:40:03.404771
0a8707dc-9060-49ff-9206-1e8f63c0dd9f	a56ba6b1-48d3-4862-9ac9-95aca265b5e6	2403a821-ec4f-42b9-b35e-12fe0ccff67b	2023-08-01 22:40:26.788464	2023-08-01 22:40:26.788464
5e000f9f-729a-4b7d-8652-6c3401e4c5db	669faf5e-580f-4efc-aa82-d11d049e9c67	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:00.527789	2023-08-01 22:42:00.527789
07ce63a2-9146-4ad0-9fa4-0f003cad21f8	a94f9d35-77b1-49a7-a2ca-4647ec3ed3ce	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:21.649149	2023-08-01 22:43:21.649149
ec908402-298e-4f69-b1fb-f1963676b0a1	fbe0ca7a-d1d9-4a4c-8d2d-620d8d73bb62	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:42.195395	2023-08-01 22:44:42.195395
0703cce3-7f32-4182-9c78-6060efdf9b83	3239e5f2-b93c-4c04-87e0-13a3adb5e0b3	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:20.319416	2023-08-01 22:49:20.319416
70ceccd7-e4c5-4f35-9c2b-f0305b8e1d9a	4bf5d4ea-0164-45e4-bd4e-ec92dc8ec662	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:17.149534	2023-08-01 22:50:17.149534
642d5388-3b4f-405e-b664-4043f2eb2ed4	62d549c1-4bcc-4d98-8277-bd69210cca79	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:33.120167	2023-08-01 22:51:33.120167
6df1120b-6c49-4b84-91fe-7db5d327052b	35d4486b-cdb9-46aa-898e-9f2e0c8b133c	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:51:59.576607	2023-08-01 22:51:59.576607
92b3cd5e-f48b-4821-bcdb-30048347ad89	422dac83-6297-486a-bdc2-f58935c93e69	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:26.289225	2023-08-01 22:54:26.289225
fc6238e8-b2e4-49ad-b167-c51ee3f8abcf	5e1ca93f-472c-4af8-b6b9-0ffa96fc4371	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:47.914007	2023-08-01 22:54:47.914007
6dcdae70-0149-49a3-8dc7-0896f5c881ad	b0147529-b964-4da0-877c-f1808d8934f2	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:36.285696	2023-08-01 22:55:36.285696
12291d3c-ccce-4069-8379-0ac7987acdd1	24d13a09-d31a-41af-9f73-51e22729f394	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:34.962452	2023-08-01 22:57:34.962452
4ce28c3f-3d8a-488c-8ee3-474d32e209a1	240a3ac9-9dba-4e5c-8de2-2c95f7a3b4eb	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:27.418179	2023-08-01 22:58:27.418179
94530f6d-97a2-49ae-9e3f-73315241cb3d	0445792e-9a7a-47ed-a033-367492b012cb	34e132ec-6e3c-40e0-9934-2078ae42e8ce	2023-08-01 22:59:00.049563	2023-08-01 22:59:00.049563
55b2f8c5-a4f0-42c7-b907-22d53276a2e8	437fb496-9e6e-4c58-894e-abcae6ddbf39	40145192-71bd-4a8e-9ebb-c6d3bf665be7	2023-08-01 22:59:13.342575	2023-08-01 22:59:13.342575
fecd075d-fa66-4fee-8e9b-fb9dacc66f27	147f794a-173f-40e2-973d-3c42f62be98e	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:53.858756	2023-08-01 22:59:53.858756
8306df8f-7b4b-4273-8c5b-d6f7dcebf940	30ea3b70-fd04-44ed-a802-603ec703d07c	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:51.707749	2023-08-01 23:00:51.707749
1d23f66c-2a0e-4cfe-aac2-dac7bcca53ae	51ee6015-9929-4f25-94d5-93e87e68335c	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:08.376533	2023-08-01 23:02:08.376533
6243a509-b1b0-4a87-909e-2f3848d3747d	73ff225d-22c7-46cc-9dde-4b259b02d732	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:54.471004	2023-08-01 23:02:54.471004
2318090d-f105-43db-bae0-ff34a9408191	ce3cb676-50a9-4d7d-9922-c4a69d4849df	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:54.057058	2023-08-01 23:03:54.057058
3e45accb-d341-489c-a187-c550e3339423	0b1c9981-7d0e-4944-af47-1f396150d531	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:46.510795	2023-08-01 23:04:46.510795
d71ee221-8030-41f5-84f8-beadbe80302e	88010a05-3656-4d23-b6dc-477f82b5fd2b	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:25.924229	2023-08-01 23:05:25.924229
06ea9fa9-3ef7-4d70-be2e-fce068d7a776	67676d9a-53de-4ca4-857c-1c9fe6ba1584	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:56.589815	2023-08-01 23:05:56.589815
049b879c-cb17-4182-b2b0-6a612ada8682	b2c41bf4-4d96-4309-8d23-b89b859b2329	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:28.195003	2023-08-01 23:06:28.195003
4111311d-368c-49ea-b78d-0ab3dbee2b56	e4163329-ca33-44d1-b602-37ecffb95add	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:28.51343	2023-08-01 23:07:28.51343
2b0bbdac-5789-480e-9c8c-e4b999a8176c	a3a74e7c-0760-49e8-b596-3d0b1b50982f	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:06.845789	2023-08-01 23:15:06.845789
695a4709-4abf-4eb7-bf5e-abfb9ecc2447	12b32f09-36eb-4a1b-94d2-2cb924e07b4a	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:43.171494	2023-08-01 23:15:43.171494
d752dd95-e0a5-4f4b-8e22-46c3e6de8b12	7c0bd04d-4adc-498c-a302-0a3477b20de8	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:18.637205	2023-08-01 23:16:18.637205
0c772e20-4349-47f4-9bcd-6a7cae7b88c2	93e68f75-e108-4a7d-942e-5001f3b6d106	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:08.139119	2023-08-01 23:17:08.139119
68e90ab0-694f-4503-b9f2-910b47b618db	e62398f5-b631-49f3-9686-58a2caf25789	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:50.215601	2023-08-01 23:17:50.215601
219b9608-80c5-479f-bfc4-fe32678ed22e	a50def6c-392d-494a-a744-ae53112d4b98	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:31.169002	2023-08-01 23:19:31.169002
e4f96d3b-626e-4931-a3a0-68d92bf5d054	72570cb9-e1d2-4322-87c7-fe024d144475	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:38.238572	2023-08-02 04:22:38.238572
92774e7f-9a25-4b0e-aa10-d0f3b09e4fee	eb776dc0-7494-467e-8101-4cceee4dc165	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:31.944484	2023-08-02 05:46:31.944484
306bc9bf-6492-4b7d-9bf3-1cf30e2e5fb7	928fc7e6-c47f-476c-a8be-1c0f657eaa2e	8546eaea-a47d-49da-ab40-e031598df335	2023-08-02 06:36:45.271737	2023-08-02 06:36:45.271737
a9e2c329-c282-44bb-be39-d115976b9f19	e3ba047d-7e0c-491e-81ba-566dc59a71bf	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:48.188967	2023-08-02 06:38:48.188967
a9ee54c5-c455-4ef2-a8c7-a2178e68016b	a86336b5-8678-4fa7-88e7-6153c97b7481	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:09.712502	2023-08-02 06:40:09.712502
2a532413-e607-4025-8f00-1a0fbc36a027	8b3d6def-4ce3-4c33-a223-e6f13c7af70f	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:03.70154	2023-08-02 06:41:03.70154
acd0063d-233a-4233-8f56-69625009e321	0aae4a87-f8ed-4c8e-ad62-81879792f269	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:01.679675	2023-08-02 06:43:01.679675
86aab911-b92e-430c-8743-e01a9d62d648	352e7f1b-6fcc-49dd-aeec-f549b1cd5b4d	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:37.700241	2023-08-02 06:44:37.700241
31fdc677-fbce-4764-9b4b-5eaee0d202fd	8d643630-7d31-42d0-bf21-2987896c1792	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:35.199141	2023-08-02 06:45:35.199141
c2dd3d81-ca46-448c-a84c-ee64b8e49d23	7a740a4c-ec6b-49eb-9c3f-43eb0ec90f78	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:06.699234	2023-08-02 06:47:06.699234
ac822cbf-ab06-4fd2-8ce0-ae90c49f17b8	47acd46d-03b4-4c70-b91e-bdf1ec3db909	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:14.472086	2023-08-02 06:48:14.472086
2d47fa94-ce22-4c33-8efc-8fd111e2a47b	24719cc3-4ea5-4c13-b01d-5fdcb8053ad5	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:14.888991	2023-08-02 09:05:14.888991
0c7f267d-1d3a-4951-ad2a-256920f7608e	3411c963-80a6-4098-8130-b5305417acd3	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:20.39196	2023-08-02 09:06:20.39196
\.


--
-- Data for Name: attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attempts (id, reason_id, work_order_id, inserted_at, updated_at) FROM stdin;
e8d92984-cac4-42b3-90c9-aeadaa34a9b6	4a7fe400-14cb-4f67-b033-b33c09fb346c	519920fd-67ef-45f6-b656-49e37a3889bf	2023-08-01 21:17:41.454928	2023-08-01 21:17:41.454928
f4751ed4-fbbe-48d5-be4e-3aad136c48d5	76ab8d78-7ba2-40bb-bf74-3ed14829d020	519920fd-67ef-45f6-b656-49e37a3889bf	2023-08-01 21:18:09.537152	2023-08-01 21:18:09.537152
51ca5774-b45c-462b-aee3-53d153e5f04d	16b6517f-d66a-47b4-8bf3-acbaa9c76207	df0c2170-0640-4bda-bb8e-2edb15d9a09c	2023-08-01 21:21:53.75285	2023-08-01 21:21:53.75285
f4ff6a79-5eac-45f6-b0d4-03d53ca1a66a	4ce075a8-cdb2-43b7-a716-427685282e7c	df0c2170-0640-4bda-bb8e-2edb15d9a09c	2023-08-01 21:27:45.169701	2023-08-01 21:27:45.169701
576e75ee-a48a-4e0e-84f7-36c0f883c086	2ef59eda-a0a4-4fd5-9350-94fb81baa32e	17513413-efc5-4d8d-be4c-7dde4a88f000	2023-08-01 21:30:22.106692	2023-08-01 21:30:22.106692
0e4c5854-e15c-4d11-a64f-52c24bcabd0e	2291c86c-6259-48b8-b412-fb435028e73a	49321e50-5938-48d5-be52-ad7197b16541	2023-08-01 21:31:32.796775	2023-08-01 21:31:32.796775
be82a0b5-6742-45cf-96f9-ceed9345eba0	8f449152-b7a1-40a6-9c52-35b2f1d938b4	0393404d-9f80-4df7-80c3-0950bda14ca2	2023-08-01 21:33:12.560764	2023-08-01 21:33:12.560764
01c42f93-aaa3-460a-8053-dc1888938f3e	f7cad00c-a5f8-425a-b2ea-57b80ce9c09a	97ba4eb4-b60d-46a1-b0a6-a01e723f19b3	2023-08-01 21:35:33.378225	2023-08-01 21:35:33.378225
37f7aa2d-2ef0-4114-94a6-73499b13e858	73db5a6b-47bc-4a47-a9bb-d8ffcbd89234	529ef426-5914-4ed0-9205-bfe3cc6c9f63	2023-08-01 21:38:19.689194	2023-08-01 21:38:19.689194
d3e15ee2-a830-449a-a61d-074f250cfc68	6b780db6-3896-4c09-88ad-dcb9f0a2669e	91ee6b79-a170-4dec-8df2-dc1bf1f95768	2023-08-01 21:44:18.384512	2023-08-01 21:44:18.384512
3f70ce29-cac1-4c58-a3e6-1b06dfeaf16a	47d8f301-306e-4034-bbd2-f67e3f2e1d3c	8d836362-c55e-4698-9f96-07ec25e76c3c	2023-08-01 22:00:24.213092	2023-08-01 22:00:24.213092
c89458d0-0f1c-46c1-97b5-f66a5fe70d61	7e5a7b1d-9e93-44c8-89a3-11e11ccc2676	e8af3b94-11aa-486d-8513-be8a0c56ed58	2023-08-01 22:03:05.540449	2023-08-01 22:03:05.540449
09b55c20-d015-4ccd-9730-85d5f49308b9	ce114942-0b8c-42a8-9997-a4aad0ed29eb	5c3c2207-150a-454c-818a-dc938149dbf4	2023-08-01 22:07:51.619105	2023-08-01 22:07:51.619105
e0fecd06-72b3-42b7-a50a-5eb395870fee	8a7787e6-66ca-4161-9ae2-8d7cd21403a8	acd9305e-e725-4d75-a5f6-1889d357ce98	2023-08-01 22:13:01.147612	2023-08-01 22:13:01.147612
6ee5fede-ca95-4b1a-83ea-6bab4de983fb	3ed5c31b-8c5f-41d4-a160-6379f28235c6	ec3568c1-1381-4fe3-a7f3-6871b6b6230c	2023-08-01 22:14:26.970502	2023-08-01 22:14:26.970502
4f038558-fcd6-4c9b-a41c-35aba8e5cb57	619771c2-9d7f-46cd-bc90-e7a68cc449f3	790a9309-f636-410c-b108-9ef908bbf9e9	2023-08-01 22:15:54.713516	2023-08-01 22:15:54.713516
af462ae8-ee6d-4022-8432-8d2df07387eb	50d56bd3-53cf-4a01-a2a4-fb19a0de5ed7	cfea3827-7ba2-4489-8b28-7b314f40b6df	2023-08-01 22:16:31.345753	2023-08-01 22:16:31.345753
3a8ba912-e276-4318-b7e4-f30d78b05281	b4f73299-1d34-4888-8e6b-75c2ccaaf673	17211470-67cc-4954-ace5-d2537cc5e67b	2023-08-01 22:17:50.476555	2023-08-01 22:17:50.476555
e622c0fd-2b19-4ce4-9bcd-cc5199430f0c	701753d8-3c35-48d0-9969-a3b9ba680726	17211470-67cc-4954-ace5-d2537cc5e67b	2023-08-01 22:18:26.715764	2023-08-01 22:18:26.715764
6dd51a1f-6a3f-48eb-aece-6b22bb72a86f	b5947e86-349e-4faa-8437-f05494a2a1ae	17211470-67cc-4954-ace5-d2537cc5e67b	2023-08-01 22:18:28.927235	2023-08-01 22:18:28.927235
ae79002b-bf6f-436e-a5d6-73d203eb63e1	1d8e9a42-e5c7-4218-a7bd-6717076780f5	17211470-67cc-4954-ace5-d2537cc5e67b	2023-08-01 22:19:55.89281	2023-08-01 22:19:55.89281
271c5e6c-a511-4ba2-b3ac-a2a0cd0a13f7	2fa9d35d-0610-4ae4-a2f6-8f781c1c817c	cfea3827-7ba2-4489-8b28-7b314f40b6df	2023-08-01 22:20:33.056255	2023-08-01 22:20:33.056255
cd728aa6-83dd-4d5b-994f-8036a43c003e	520566e9-3828-45ac-9090-bb1124f3fcb3	cfea3827-7ba2-4489-8b28-7b314f40b6df	2023-08-01 22:22:06.566	2023-08-01 22:22:06.566
1425c962-166b-4455-b116-24d415760d66	416b3ff8-3932-406e-83af-b442611e4bc7	eebf05d3-d4ea-4f11-bea7-69014b567db2	2023-08-01 22:23:41.953434	2023-08-01 22:23:41.953434
d6289627-a8dd-4de7-a38c-e8ea7ad06a64	580c5b7f-75c3-428f-933b-b78bd136d002	45b9fd37-b759-43ac-9213-5dba1065db9b	2023-08-01 22:24:17.514151	2023-08-01 22:24:17.514151
6d7436ae-ec1f-4de4-8509-81834385d284	e66cfd15-92a9-4a7b-962f-02d823f9728d	5f0ef69e-c8bf-4e54-a511-172d8a3b43fd	2023-08-01 22:25:27.367811	2023-08-01 22:25:27.367811
bc768b00-1892-408b-b801-fc7a0cdffaf7	d5d93784-b8d8-477d-bd47-0bd48816f6b6	6089918b-1069-4847-8ac4-05a293a35c4b	2023-08-01 22:26:28.21445	2023-08-01 22:26:28.21445
fd99f0a7-be27-4a30-b541-c72d38b34960	6ffad9e8-9a42-4fe6-b664-fc6cee6bc8b0	0e184114-b97b-488d-8e8e-130981e5686a	2023-08-01 22:27:12.347006	2023-08-01 22:27:12.347006
53d79ac5-aeaa-46be-ab5f-19e294400464	a2cd7244-eddd-4201-ad96-6aa3f834a6b1	95f70e1c-33fb-4a5d-9e79-40d737bfccc5	2023-08-01 22:27:39.372084	2023-08-01 22:27:39.372084
be570b27-40d9-44ad-b269-f9e7d75d4eab	9af4eda2-7916-4329-b5b5-3481ae8064ce	cfae280b-aaac-4340-b842-8a718aae2149	2023-08-01 22:28:27.173588	2023-08-01 22:28:27.173588
3fd998ca-2ad1-46b5-b509-3f34e7e944cc	b21bfb2c-f037-41ef-b29d-9f43f203aad5	53e590f5-21b6-42f1-8d8a-b97d759824a6	2023-08-01 22:30:44.422656	2023-08-01 22:30:44.422656
5e360e9b-a015-4c32-88e1-9a8d3e7520ba	d788da6b-aa5f-4947-bdb6-df81852cd276	196639a2-2974-4424-977a-7b57eb4b411a	2023-08-01 22:33:47.13999	2023-08-01 22:33:47.13999
8d1b6345-05a6-4d87-97e4-33a70e1552be	75d53acb-ff68-4ae5-b58b-51d75f574b61	ef3316a4-4aa5-4c0a-afe1-2cdc180e8005	2023-08-01 22:36:18.30308	2023-08-01 22:36:18.30308
83c3becf-9443-464f-83d0-985970049e64	cbdcc611-03a8-4df5-847f-79b1d66ba613	5bdf9bf8-d000-4589-8a72-b2b3d9393e43	2023-08-01 22:38:56.977515	2023-08-01 22:38:56.977515
cb7f80c3-c2aa-46a4-8253-4c58903713b4	18c384f3-6680-4bf5-bc18-d005f94f08fd	9db77487-be65-4c32-96ef-9965bd57ce5d	2023-08-01 22:39:26.476182	2023-08-01 22:39:26.476182
5d1278a3-e25f-4fb7-bb5e-40e4919bde2c	454577ff-661a-461e-9ad5-3c63397661fc	29863566-a821-41d0-b5fd-a42a6d5a0a08	2023-08-01 22:40:03.404248	2023-08-01 22:40:03.404248
a56ba6b1-48d3-4862-9ac9-95aca265b5e6	26d64f9c-5c62-42e6-97f9-eca6c71615d5	29863566-a821-41d0-b5fd-a42a6d5a0a08	2023-08-01 22:40:26.787419	2023-08-01 22:40:26.787419
669faf5e-580f-4efc-aa82-d11d049e9c67	ea0ca7f5-35f7-4a24-a95a-7ba67b75e107	1c748d14-4143-4e86-a9a2-9736b3d9c09d	2023-08-01 22:42:00.527167	2023-08-01 22:42:00.527167
a94f9d35-77b1-49a7-a2ca-4647ec3ed3ce	706af2b8-5a8d-46cd-ba2a-5a013566bb86	8fdd2596-98a3-4438-8d0a-894000bdb3a5	2023-08-01 22:43:21.648476	2023-08-01 22:43:21.648476
fbe0ca7a-d1d9-4a4c-8d2d-620d8d73bb62	b326ebb2-8d29-4f76-8c2d-5b78d5be5181	315fb81f-baa1-433e-a153-1c60fcb25289	2023-08-01 22:44:42.195021	2023-08-01 22:44:42.195021
3239e5f2-b93c-4c04-87e0-13a3adb5e0b3	490ac1d1-eb8c-46df-8c50-36d0e9656954	f3b5d856-ef89-4d61-bca9-c0b371669f9d	2023-08-01 22:49:20.317522	2023-08-01 22:49:20.317522
4bf5d4ea-0164-45e4-bd4e-ec92dc8ec662	f768e325-6f8b-4b04-a838-438f8c76dc3c	a663b782-43d5-4462-96e2-236be1e06a9c	2023-08-01 22:50:17.14755	2023-08-01 22:50:17.14755
62d549c1-4bcc-4d98-8277-bd69210cca79	32808be8-a53c-4c92-b8a2-f880821d1f3f	00b6391a-3d3d-4158-a667-f61b41b90770	2023-08-01 22:51:33.118746	2023-08-01 22:51:33.118746
35d4486b-cdb9-46aa-898e-9f2e0c8b133c	25b17c0a-8bd1-4705-9158-41f9a102ee6d	52be5d8f-4ce0-4558-b4c5-4e39edbc56a8	2023-08-01 22:51:59.575833	2023-08-01 22:51:59.575833
422dac83-6297-486a-bdc2-f58935c93e69	ac40b66d-6393-46ff-b3c4-4cdd905e7ee8	00b6391a-3d3d-4158-a667-f61b41b90770	2023-08-01 22:54:26.287636	2023-08-01 22:54:26.287636
5e1ca93f-472c-4af8-b6b9-0ffa96fc4371	fe0d3d39-ab8b-4eb8-85a6-2bb09bbb29f9	52be5d8f-4ce0-4558-b4c5-4e39edbc56a8	2023-08-01 22:54:47.911951	2023-08-01 22:54:47.911951
b0147529-b964-4da0-877c-f1808d8934f2	909f2f6a-6898-42bb-aad6-a2608e75df0c	52be5d8f-4ce0-4558-b4c5-4e39edbc56a8	2023-08-01 22:55:36.28448	2023-08-01 22:55:36.28448
24d13a09-d31a-41af-9f73-51e22729f394	623d9b0a-458c-4d87-a615-ab41f9050e69	003d5f12-8707-4786-a3af-8509c6081bd3	2023-08-01 22:57:34.961775	2023-08-01 22:57:34.961775
240a3ac9-9dba-4e5c-8de2-2c95f7a3b4eb	c11eda9e-343e-4857-b040-6331b2899e7f	2f4782c1-1f7b-4891-9a14-be8f7366115b	2023-08-01 22:58:27.41771	2023-08-01 22:58:27.41771
0445792e-9a7a-47ed-a033-367492b012cb	bee2d4bb-27d4-4c7e-b6d5-92685092cdc2	a613f440-a221-48a5-bf7b-05eae3202f29	2023-08-01 22:59:00.049133	2023-08-01 22:59:00.049133
437fb496-9e6e-4c58-894e-abcae6ddbf39	047f96c6-cda2-43bb-bbf4-9c63bc5d5cb1	7c2ca994-78cd-42a6-86fa-8189337615e0	2023-08-01 22:59:13.342067	2023-08-01 22:59:13.342067
147f794a-173f-40e2-973d-3c42f62be98e	54e4e31e-e679-4c11-b677-27549deda644	ba2f0d03-a8f6-49ea-a76f-9c8387317e73	2023-08-01 22:59:53.858217	2023-08-01 22:59:53.858217
30ea3b70-fd04-44ed-a802-603ec703d07c	7b08f6ec-adaf-4ff9-8152-2467620600a6	bf6bba42-9011-4c73-a5e7-9f0f1ea4c445	2023-08-01 23:00:51.707385	2023-08-01 23:00:51.707385
51ee6015-9929-4f25-94d5-93e87e68335c	2ff94940-223f-42da-9a9a-eb243257e8ad	56dd154d-75dd-42b5-a21c-1ef51c077527	2023-08-01 23:02:08.376089	2023-08-01 23:02:08.376089
73ff225d-22c7-46cc-9dde-4b259b02d732	99ad7f65-6ad0-462e-9610-68a960602949	7e7b7917-707a-45db-93bd-7c9d9de0cb05	2023-08-01 23:02:54.470299	2023-08-01 23:02:54.470299
ce3cb676-50a9-4d7d-9922-c4a69d4849df	932f61cf-30cb-464c-af7f-cefda253406f	7c85690f-0a01-4ac5-9487-6fd7b0be5192	2023-08-01 23:03:54.056189	2023-08-01 23:03:54.056189
0b1c9981-7d0e-4944-af47-1f396150d531	83e4718a-9485-4eb4-aa48-9af309ffe890	bf5b7026-f789-4b75-b763-81dcb72db48d	2023-08-01 23:04:46.510145	2023-08-01 23:04:46.510145
88010a05-3656-4d23-b6dc-477f82b5fd2b	9259accf-56a5-4dec-b3f2-4657a021fb98	6ace359e-08cf-471c-b8c1-e248ed123adf	2023-08-01 23:05:25.923643	2023-08-01 23:05:25.923643
67676d9a-53de-4ca4-857c-1c9fe6ba1584	cfcc1957-9c05-4f99-9f83-c27699ef6293	8b466378-1b26-480e-97e0-f8af9688e213	2023-08-01 23:05:56.58935	2023-08-01 23:05:56.58935
b2c41bf4-4d96-4309-8d23-b89b859b2329	d724d13a-2da8-4193-88fa-7867e340e5b0	192fe7ab-0026-4351-80c7-b8d19f68b961	2023-08-01 23:06:28.194309	2023-08-01 23:06:28.194309
e4163329-ca33-44d1-b602-37ecffb95add	e5147230-3941-4a18-8f38-5aec515d60f1	b4e16775-ec03-4ce2-b890-196f099a9cfd	2023-08-01 23:07:28.512456	2023-08-01 23:07:28.512456
a3a74e7c-0760-49e8-b596-3d0b1b50982f	69515fa1-5691-4dae-93f5-30badb0d0d4f	1256a187-7d1b-4965-a184-c7c0a82eff89	2023-08-01 23:15:06.845259	2023-08-01 23:15:06.845259
12b32f09-36eb-4a1b-94d2-2cb924e07b4a	e4f9c392-daec-473c-a413-bacf72cc4eaa	ab036835-3eca-47fc-9317-7d649fa41f3c	2023-08-01 23:15:43.170778	2023-08-01 23:15:43.170778
7c0bd04d-4adc-498c-a302-0a3477b20de8	5b4db964-e6cd-4ac4-a2d2-7ea2122ea67b	7ad7cd17-07ac-419e-8891-12fd4a7a0db6	2023-08-01 23:16:18.636661	2023-08-01 23:16:18.636661
93e68f75-e108-4a7d-942e-5001f3b6d106	6c289967-8bc4-436a-9f7a-a09f8fed3a15	3fdb8c9a-c112-4aa8-87c5-05fc7d17c6ef	2023-08-01 23:17:08.138238	2023-08-01 23:17:08.138238
e62398f5-b631-49f3-9686-58a2caf25789	8cd017e7-52d6-4025-bfe8-c80c36df6fbd	efce94b5-e3c5-4ac1-ab7f-f1e002d30877	2023-08-01 23:17:50.213218	2023-08-01 23:17:50.213218
a50def6c-392d-494a-a744-ae53112d4b98	aee4c692-77fc-44e5-a19c-5ccab4d9e000	d8366fec-8fa1-4d9f-81b4-0f44f9700ea7	2023-08-01 23:19:31.168354	2023-08-01 23:19:31.168354
72570cb9-e1d2-4322-87c7-fe024d144475	2d881d73-7aff-4c71-baa7-485b2cfe4bfd	401524e4-996b-4ea9-94e1-82efd422f08d	2023-08-02 04:22:38.238074	2023-08-02 04:22:38.238074
eb776dc0-7494-467e-8101-4cceee4dc165	fa66ce89-911c-4351-8cab-4c6863d09092	8d13900f-32d0-4ea3-a654-6e59929ab4b4	2023-08-02 05:46:31.943801	2023-08-02 05:46:31.943801
928fc7e6-c47f-476c-a8be-1c0f657eaa2e	5a3928ef-07b4-4dac-ad4e-a0fa6b78387e	4a269879-d5a8-44e6-927e-80b67ee54a30	2023-08-02 06:36:45.270585	2023-08-02 06:36:45.270585
e3ba047d-7e0c-491e-81ba-566dc59a71bf	d8e79cdc-514f-42be-9145-8843d2518884	ae81429a-d16e-4245-9b94-9959234c8e1d	2023-08-02 06:38:48.188124	2023-08-02 06:38:48.188124
a86336b5-8678-4fa7-88e7-6153c97b7481	e5cb5cef-73f2-47f4-a5c0-bad7a62458c4	f49ae113-7b24-483d-b6e9-fe201922b982	2023-08-02 06:40:09.711334	2023-08-02 06:40:09.711334
8b3d6def-4ce3-4c33-a223-e6f13c7af70f	79c53465-7947-4775-861d-55bb6e92a032	4ab8e233-709c-4fe3-b8b9-a3f5f74f5516	2023-08-02 06:41:03.700687	2023-08-02 06:41:03.700687
0aae4a87-f8ed-4c8e-ad62-81879792f269	dfbf5e3d-931a-40ed-af70-3128a94742c4	1ac5e706-1a14-4dc0-bd50-55eb288c43d3	2023-08-02 06:43:01.678851	2023-08-02 06:43:01.678851
352e7f1b-6fcc-49dd-aeec-f549b1cd5b4d	b7181f6f-c5c1-4ac9-a10d-e2d9b3cb99d4	515ce94a-a04d-45c9-8fa5-aa2fec7b045a	2023-08-02 06:44:37.6995	2023-08-02 06:44:37.6995
8d643630-7d31-42d0-bf21-2987896c1792	ca01abda-25b8-4071-bb41-dac89047a098	38d5bba7-4774-42a1-a657-1a27c7fe9853	2023-08-02 06:45:35.198325	2023-08-02 06:45:35.198325
7a740a4c-ec6b-49eb-9c3f-43eb0ec90f78	78843771-b0b7-4831-976b-ec6d4c5b0ff7	6d9cc4b9-8cff-45f8-b1d1-eb402fde3f5a	2023-08-02 06:47:06.69836	2023-08-02 06:47:06.69836
47acd46d-03b4-4c70-b91e-bdf1ec3db909	26e653b9-3de1-4e1d-8b13-60ff5dec60fa	79ca992a-1b3e-481e-8385-5f24c5118db3	2023-08-02 06:48:14.471071	2023-08-02 06:48:14.471071
24719cc3-4ea5-4c13-b01d-5fdcb8053ad5	96b7788b-cfe4-49ca-b5d8-91a238f8e321	c9f82b21-9851-4c13-b174-08e4e83aab86	2023-08-02 09:05:14.887897	2023-08-02 09:05:14.887897
3411c963-80a6-4098-8130-b5305417acd3	d2b1fd34-770b-4683-83c7-bac89219e985	cfcdfb40-4e8e-47ce-b775-65abee150ead	2023-08-02 09:06:20.391021	2023-08-02 09:06:20.391021
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
4e23ac68-efd8-4513-84d7-a7019fbd4a0b	dhis_connection	2023-08-01 20:41:55	2023-08-01 21:44:07	a8cce28e-8904-4970-999b-d9174fd6b92f	\\x010a4145532e47434d2e563192cc775285ed05cb33f291a149ad3d1de8815c1b119b75e5b0dfa039e4bd600f785bec4f9bebccd6b90514d56a9786ea56f48de20cc53ba20c70323d847fd865d7b5ccf53ed018ee9ea9c1a0c1a9828d6f2882594a84b0a00a2b8f55b80900ac9ecb9918dacb5df660b478304cef482a14c4f1a52772bddf3466cead0e9118bc	f	dhis2
\.


--
-- Data for Name: credentials_audit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credentials_audit (id, event, metadata, row_id, actor_id, inserted_at) FROM stdin;
212a133e-cbbd-4303-b3da-8bd62e5aa1e3	created	{"after": null, "before": null}	4e23ac68-efd8-4513-84d7-a7019fbd4a0b	a8cce28e-8904-4970-999b-d9174fd6b92f	2023-08-01 20:41:55
3c8abad1-a303-4118-999e-b923b025bbd6	updated	{"after": {"body": "AQpBRVMuR0NNLlYxdfDmtYHD5O0R8SyKtdxThkNSrt6DIR+zaIunl5IL3UGbSHUvNUFyy6dw31z65LibXw4YJvf8q1T/tZwvzCYpEZbu95oVSzb5HdNVdQClev2FHSjmrdH8CNEW1qHjUmTx3Z4gQ4fdsh7SE3W5R0zc2LzMkEWw9WPu/faLtbCHFlhk"}, "before": {"body": "AQpBRVMuR0NNLlYxVLrDJCQdDQunLOCmIq3+beh3hNgPYf8F3AZXv1xEu+F7G8NqRZpiEnI+ERUwTcMzobScv7DE/67tl9gIEj6E2AhrqYpSTuZrGxFiqCPgb7BjtV5FYWO0ZGMh31t3Ynxgh1ELrK+CdzxOrqSFnMaZchoEq9IUwBNQJsvdmLMVND4="}}	4e23ac68-efd8-4513-84d7-a7019fbd4a0b	a8cce28e-8904-4970-999b-d9174fd6b92f	2023-08-01 21:31:22
3eccd1af-b4cd-425d-9fda-a9ff9f38f93f	updated	{"after": {"body": "AQpBRVMuR0NNLlYxMxhII7nx0Gss6NQy/6DIcOrdbTFE856301A50CuovHkiSbOEQ2Bj4ypxXvYXVLHuceNMBfZBZDzxZGVM7rdkVsaHwnJdtsnvfmS/lr815WtVfS0oqOLg9DWxE1YFNxsu+MAY593EftvEdMZZ9uiB5yODNe9fZt+rkM9IW59kmtM="}, "before": {"body": "AQpBRVMuR0NNLlYxzLTCI7CLkt6NaTicwzYs7D6DOdnGVF+YKat8ceR2EhsTdMoKHzL0AgLsWiqQM/yWO5D5N404BfGTjoIzT6aP/FvljzTDq6GPjOqzfSMOAB3fqrLrY1jvuNRAGBhZ8IXjqo1XmIaODA4U45DZLfLmOKdNzF8TUR4HtYSxaIcc7TUC"}}	4e23ac68-efd8-4513-84d7-a7019fbd4a0b	a8cce28e-8904-4970-999b-d9174fd6b92f	2023-08-01 21:44:07
\.


--
-- Data for Name: dataclips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataclips (id, body, type, inserted_at, updated_at, project_id) FROM stdin;
4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	{}	run_result	2023-08-01 21:17:41.437695	2023-08-01 21:17:41.437695	fb227e5a-764d-4582-a629-6057155a0014
27ab613a-b62f-4aa2-9bc4-607ef7d21f30	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "strictDataSetLocking": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictDataSetApproval": false, "strictOrganisationUnits": false, "strictDataSetInputPeriods": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "https://play.dhis2.org/dev/api/trackedEntityInstances/rQMXWmJN5B8", "status": "SUCCESS", "conflicts": [], "reference": "rQMXWmJN5B8", "enrollments": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "strictDataSetLocking": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictDataSetApproval": false, "strictOrganisationUnits": false, "strictDataSetInputPeriods": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "rejectedIndexes": []}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [null]}	run_result	2023-08-01 21:31:35.758736	2023-08-01 21:31:35.758736	fb227e5a-764d-4582-a629-6057155a0014
7ebdc2be-af47-4f55-9c14-2c145e43c055	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/msrM0dODgs2", "status": "SUCCESS", "conflicts": [], "reference": "msrM0dODgs2", "enrollments": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [null]}	run_result	2023-08-01 21:44:19.868282	2023-08-01 21:44:19.868282	fb227e5a-764d-4582-a629-6057155a0014
3e2f2452-aef9-4cd9-85b3-b131ad66c2c5	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/hRuZJqQ41a7", "status": "SUCCESS", "conflicts": [], "reference": "hRuZJqQ41a7", "enrollments": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [null]}	run_result	2023-08-01 22:00:25.681326	2023-08-01 22:00:25.681326	fb227e5a-764d-4582-a629-6057155a0014
ce9a7c8c-ab0a-4fd0-adfb-eec5bca523f7	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/Vtz1sSNAn4n", "status": "SUCCESS", "conflicts": [], "reference": "Vtz1sSNAn4n", "enrollments": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [null]}	run_result	2023-08-01 22:03:06.979107	2023-08-01 22:03:06.979107	fb227e5a-764d-4582-a629-6057155a0014
862e85fd-2be5-460c-8910-81606d084827	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/NGcsjKjPaRR", "status": "SUCCESS", "conflicts": [], "reference": "NGcsjKjPaRR", "enrollments": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importSummaries": [{"events": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "status": "SUCCESS", "conflicts": [], "reference": "UtLI8F61qnP", "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary"}]}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [null]}	run_result	2023-08-01 22:07:53.119782	2023-08-01 22:07:53.119782	fb227e5a-764d-4582-a629-6057155a0014
4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	{"id": "example", "name": [{"use": "official", "given": ["John"], "family": "Smith", "prefix": ["Mr"]}], "gender": "male", "birthDate": "1974-12-25", "resourceType": "Patient"}	run_result	2023-08-01 22:13:01.133811	2023-08-01 22:13:01.133811	fb227e5a-764d-4582-a629-6057155a0014
4abc509c-2e01-4440-a6b7-6388da8df48a	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	run_result	2023-08-01 22:17:50.464342	2023-08-01 22:17:50.464342	fb227e5a-764d-4582-a629-6057155a0014
e4dc5662-8b7e-42bd-ac7f-4ca4480ad7ec	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	run_result	2023-08-01 22:19:56.953469	2023-08-01 22:19:56.953469	fb227e5a-764d-4582-a629-6057155a0014
c4f6d370-efdc-4ccd-b364-8f5b5a10fb82	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:23:41.952322	2023-08-01 22:23:41.952322	fb227e5a-764d-4582-a629-6057155a0014
bb538e5c-be1a-41f9-a87c-bda731a547d2	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:24:17.512462	2023-08-01 22:24:17.512462	fb227e5a-764d-4582-a629-6057155a0014
8d21532e-5dbd-4be7-8a3e-c339746a35de	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:24:18.523535	2023-08-01 22:24:18.523535	fb227e5a-764d-4582-a629-6057155a0014
ecfce58d-b526-4f7b-91d9-2de188c4522c	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:25:27.366359	2023-08-01 22:25:27.366359	fb227e5a-764d-4582-a629-6057155a0014
0819bf03-afcb-4639-98ad-748f5a7eff21	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:26:28.213161	2023-08-01 22:26:28.213161	fb227e5a-764d-4582-a629-6057155a0014
51e1f910-1c3d-44d6-849f-dd7b10545312	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:27:40.392309	2023-08-01 22:27:40.392309	fb227e5a-764d-4582-a629-6057155a0014
f1a60b31-cde7-4138-b8f3-d0ad31f12199	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:43:21.646693	2023-08-01 22:43:21.646693	fb227e5a-764d-4582-a629-6057155a0014
698ece00-4dd7-4913-9efa-730ed8577b66	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:44:42.193766	2023-08-01 22:44:42.193766	fb227e5a-764d-4582-a629-6057155a0014
5f983282-b9ee-4303-96d0-c77e807305ad	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:49:21.343464	2023-08-01 22:49:21.343464	fb227e5a-764d-4582-a629-6057155a0014
923c709c-f517-482b-82bf-c75a1a23b747	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:58:28.428148	2023-08-01 22:58:28.428148	fb227e5a-764d-4582-a629-6057155a0014
a148ea39-1aea-40f9-851a-ce3aa8c5dad8	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:27:12.345125	2023-08-01 22:27:12.345125	fb227e5a-764d-4582-a629-6057155a0014
843c291d-271d-445a-8adf-0580d359d18a	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:30:44.421501	2023-08-01 22:30:44.421501	fb227e5a-764d-4582-a629-6057155a0014
cdc11b6b-b4b0-40ac-9bb8-eb946b7b62d9	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:33:47.138685	2023-08-01 22:33:47.138685	fb227e5a-764d-4582-a629-6057155a0014
ef3b8748-7427-4868-89ab-d371c576a3c5	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:38:58.012274	2023-08-01 22:38:58.012274	fb227e5a-764d-4582-a629-6057155a0014
f01688b5-481e-449c-9726-bf6447f8be7a	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:50:18.215174	2023-08-01 22:50:18.215174	fb227e5a-764d-4582-a629-6057155a0014
7ed7fb32-85ab-46f0-8847-525f1764ef21	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:55:37.329528	2023-08-01 22:55:37.329528	fb227e5a-764d-4582-a629-6057155a0014
85c39700-0f2f-43c2-b6bd-b52523fcecd8	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:59:53.856998	2023-08-01 22:59:53.856998	fb227e5a-764d-4582-a629-6057155a0014
f1c24be5-f00c-497a-b242-091fcbe12049	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 23:00:51.706326	2023-08-01 23:00:51.706326	fb227e5a-764d-4582-a629-6057155a0014
e8354c82-2ea6-4482-a636-11c3328f134c	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:27:39.370779	2023-08-01 22:27:39.370779	fb227e5a-764d-4582-a629-6057155a0014
5d6c4af0-1007-49ba-af5a-1801378823b4	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:28:27.172196	2023-08-01 22:28:27.172196	fb227e5a-764d-4582-a629-6057155a0014
476975a8-0e3c-4446-8084-eeaa055ac7d2	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:38:56.9762	2023-08-01 22:38:56.9762	fb227e5a-764d-4582-a629-6057155a0014
3e279c6f-d72a-4c6e-8923-b9ce84be64bc	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:40:03.403135	2023-08-01 22:40:03.403135	fb227e5a-764d-4582-a629-6057155a0014
de98ba98-e104-4ffa-bee3-c23f9518ffd6	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:42:01.522114	2023-08-01 22:42:01.522114	fb227e5a-764d-4582-a629-6057155a0014
f9f8b187-ab9f-4f9f-b110-8cb1b940bd3f	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:44:43.270976	2023-08-01 22:44:43.270976	fb227e5a-764d-4582-a629-6057155a0014
bd48d573-f94f-46de-bce6-6599459bccf4	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:54:48.950682	2023-08-01 22:54:48.950682	fb227e5a-764d-4582-a629-6057155a0014
d95be9a4-911c-474c-ae3b-d6cd1c247111	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:57:35.981613	2023-08-01 22:57:35.981613	fb227e5a-764d-4582-a629-6057155a0014
7136cbb7-a575-4c88-9b86-616fdf6436bb	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:58:27.416705	2023-08-01 22:58:27.416705	fb227e5a-764d-4582-a629-6057155a0014
4d95c6cd-4797-439e-9716-557856b70a4a	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 23:02:08.37492	2023-08-01 23:02:08.37492	fb227e5a-764d-4582-a629-6057155a0014
84f70e6d-45de-4f46-a8d6-74211be91e6f	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:33:48.142035	2023-08-01 22:33:48.142035	fb227e5a-764d-4582-a629-6057155a0014
59a62b34-8af3-48ef-94ac-ba3e9fa20b77	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:36:18.301953	2023-08-01 22:36:18.301953	fb227e5a-764d-4582-a629-6057155a0014
8f2321c2-76f7-4290-a436-16731b2e305d	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:54:27.341769	2023-08-01 22:54:27.341769	fb227e5a-764d-4582-a629-6057155a0014
8170d795-be98-4dd2-a445-c66ef64e8e7b	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:59:54.868195	2023-08-01 22:59:54.868195	fb227e5a-764d-4582-a629-6057155a0014
9ca7e14b-325a-42ca-951e-063ded745af5	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:36:19.322665	2023-08-01 22:36:19.322665	fb227e5a-764d-4582-a629-6057155a0014
e8a2f33e-9a45-4258-8b20-350bcdab4a2e	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:39:26.474769	2023-08-01 22:39:26.474769	fb227e5a-764d-4582-a629-6057155a0014
11a03b36-9539-4ea3-a0c7-2a9a472ba6d7	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:42:00.525742	2023-08-01 22:42:00.525742	fb227e5a-764d-4582-a629-6057155a0014
d01973e8-eca3-4f6b-98fa-81626e8427c9	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:51:34.157997	2023-08-01 22:51:34.157997	fb227e5a-764d-4582-a629-6057155a0014
27183a08-d913-4aef-864a-1e695cbe36a1	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 22:52:00.610141	2023-08-01 22:52:00.610141	fb227e5a-764d-4582-a629-6057155a0014
4def2367-5223-45a2-a3f3-c657fa71a359	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:59:00.048014	2023-08-01 22:59:00.048014	fb227e5a-764d-4582-a629-6057155a0014
043971d1-a7ac-4057-a473-14563f171273	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:59:13.3407	2023-08-01 22:59:13.3407	fb227e5a-764d-4582-a629-6057155a0014
5ffdad4f-4f66-4cf8-839b-de7a46a5285a	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 23:00:52.691482	2023-08-01 23:00:52.691482	fb227e5a-764d-4582-a629-6057155a0014
d30450c1-4fcd-4692-bc3b-dc1fa2b120de	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 22:57:34.960522	2023-08-01 22:57:34.960522	fb227e5a-764d-4582-a629-6057155a0014
8c1e17cb-f5f0-4ca6-9818-6ee3f22072b0	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 23:02:09.409699	2023-08-01 23:02:09.409699	fb227e5a-764d-4582-a629-6057155a0014
a567da76-e110-44d0-a849-55066596a754	{"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}	http_request	2023-08-01 23:02:54.469033	2023-08-01 23:02:54.469033	fb227e5a-764d-4582-a629-6057155a0014
ca76ea73-074e-444f-9407-b0659a06a2de	{"data": {"code": {"text": "HIV Test Result", "coding": [{"code": "38372-9", "system": "http://loinc.org", "display": "HIV-1 and HIV-2 Ab SerPl Ql"}]}, "status": "final", "subject": {"reference": "Patient/example"}, "resourceType": "Observation", "valueCodeableConcept": {"coding": [{"code": "165889005", "system": "http://snomed.info/sct", "display": "Positive"}]}}}	run_result	2023-08-01 23:02:55.49409	2023-08-01 23:02:55.49409	fb227e5a-764d-4582-a629-6057155a0014
04823219-22fc-42bb-9bbf-69f495a919f4	{"Name": "Mahao", "Surname": "Molise"}	http_request	2023-08-01 23:03:54.054638	2023-08-01 23:03:54.054638	fb227e5a-764d-4582-a629-6057155a0014
38a32afc-8809-444c-818e-d4c90b5a5459	{"data": {"Name": "Mahao", "Surname": "Molise"}}	run_result	2023-08-01 23:03:55.071668	2023-08-01 23:03:55.071668	fb227e5a-764d-4582-a629-6057155a0014
3739f5ea-8bee-4e7f-a394-d6954c9d730a	{"Name": "Mahao", "Surname": "Molise"}	http_request	2023-08-01 23:04:46.509004	2023-08-01 23:04:46.509004	fb227e5a-764d-4582-a629-6057155a0014
02fa2778-e583-40c6-aee7-dfd911529756	{"data": {"Name": "Mahao", "Surname": "Molise"}}	run_result	2023-08-01 23:04:47.49029	2023-08-01 23:04:47.49029	fb227e5a-764d-4582-a629-6057155a0014
87fd1c00-ef4b-4800-a076-02115d4d197a	{"Name": "Mahao", "Surname": "Molise"}	http_request	2023-08-01 23:05:25.922373	2023-08-01 23:05:25.922373	fb227e5a-764d-4582-a629-6057155a0014
bc9abc10-7b45-4bc8-bb4b-ceef599275a1	{"Name": "Mahao", "Surname": "Molise"}	http_request	2023-08-01 23:05:56.587629	2023-08-01 23:05:56.587629	fb227e5a-764d-4582-a629-6057155a0014
cb467169-0ff9-4d04-8d85-8d575bd81e48	{"data": {"Name": "Mahao", "Surname": "Molise"}}	run_result	2023-08-01 23:05:57.614937	2023-08-01 23:05:57.614937	fb227e5a-764d-4582-a629-6057155a0014
fb70d5ae-77d4-4fa5-bd4e-2ea3528b2f9d	{"Name": "Mahao", "Surname": "Molise"}	http_request	2023-08-01 23:06:28.193265	2023-08-01 23:06:28.193265	fb227e5a-764d-4582-a629-6057155a0014
a7705bf6-5eee-49a9-85a9-34b449720382	{"data": {"Name": "Mahao", "Surname": "Molise"}}	run_result	2023-08-01 23:06:29.215806	2023-08-01 23:06:29.215806	fb227e5a-764d-4582-a629-6057155a0014
4c76b298-6b17-42f6-9a57-3707e47630df	{"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-01 23:07:28.511019	2023-08-01 23:07:28.511019	fb227e5a-764d-4582-a629-6057155a0014
bbbe96a1-9679-4abf-91e9-45ad210c7afa	{"data": {"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}}	run_result	2023-08-01 23:07:29.546203	2023-08-01 23:07:29.546203	fb227e5a-764d-4582-a629-6057155a0014
13c03072-5132-4102-946a-978d1c8bc39c	{"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-01 23:15:06.844305	2023-08-01 23:15:06.844305	fb227e5a-764d-4582-a629-6057155a0014
8add2b90-244f-4b7b-bd52-9989bf4a170b	{"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-01 23:15:43.169345	2023-08-01 23:15:43.169345	fb227e5a-764d-4582-a629-6057155a0014
ff93db11-5928-42e4-ba42-47e1b2edde61	{"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-01 23:16:18.635648	2023-08-01 23:16:18.635648	fb227e5a-764d-4582-a629-6057155a0014
78db8db2-b0e1-4b58-8125-eddd7e644a91	{"data": {"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}}	run_result	2023-08-01 23:16:19.666229	2023-08-01 23:16:19.666229	fb227e5a-764d-4582-a629-6057155a0014
ab8e10f2-c5de-4fd8-abcb-39fcd2dd16e8	{"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-01 23:17:08.136894	2023-08-01 23:17:08.136894	fb227e5a-764d-4582-a629-6057155a0014
685b5bc4-489b-421c-976d-702c56a7f673	{"data": {"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}}	run_result	2023-08-01 23:17:09.154335	2023-08-01 23:17:09.154335	fb227e5a-764d-4582-a629-6057155a0014
e8b06c80-2a7b-4a4b-9b92-a94f46b67a1a	{"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-01 23:17:50.210158	2023-08-01 23:17:50.210158	fb227e5a-764d-4582-a629-6057155a0014
45cb25d3-b63b-46e1-bb29-6d9baeae1079	{"data": {"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}}	run_result	2023-08-01 23:17:51.224803	2023-08-01 23:17:51.224803	fb227e5a-764d-4582-a629-6057155a0014
5fe0f833-07a8-4ad2-a350-a0a9727ce3f3	{"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-01 23:19:31.167133	2023-08-01 23:19:31.167133	fb227e5a-764d-4582-a629-6057155a0014
1c3b5ecc-2cdd-44a6-8c23-84bf91eed76c	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/fo3EfAwoOpD", "status": "SUCCESS", "conflicts": [], "reference": "fo3EfAwoOpD", "enrollments": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importSummaries": [{"events": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "status": "SUCCESS", "conflicts": [], "reference": "P0LVfue6VD3", "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary"}]}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"id": "example", "name": [{"given": ["John"], "family": "Doe"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}]}	run_result	2023-08-01 23:19:32.636408	2023-08-01 23:19:32.636408	fb227e5a-764d-4582-a629-6057155a0014
436b9eda-41c4-4211-b676-7d7ffc8f76bf	{"id": "example", "name": [{"given": ["Given"], "family": "Does"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-02 04:22:38.236966	2023-08-02 04:22:38.236966	fb227e5a-764d-4582-a629-6057155a0014
2fa31bb2-daa8-408c-95bb-b60683665e9b	{"id": "example", "name": [{"given": ["Two"], "family": "Test"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}	http_request	2023-08-02 05:46:31.942568	2023-08-02 05:46:31.942568	fb227e5a-764d-4582-a629-6057155a0014
13f8be10-2e5d-4ccf-98bb-d04137c43f4a	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/I4wshQnY2q0", "status": "SUCCESS", "conflicts": [], "reference": "I4wshQnY2q0", "enrollments": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importSummaries": [{"events": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "status": "SUCCESS", "conflicts": [], "reference": "BFIwdb0Yphy", "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary"}]}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"id": "example", "name": [{"given": ["Given"], "family": "Does"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}]}	run_result	2023-08-02 04:22:39.81034	2023-08-02 04:22:39.81034	fb227e5a-764d-4582-a629-6057155a0014
7fe4b289-5f08-4c2f-a8f8-44c05d13c9fd	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "0e6832f3-0174-4f9b-b5be-f45995c9b7b0", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9faf5d44320e0d2d6b0ed"}}	http_request	2023-08-02 06:43:01.677105	2023-08-02 06:43:01.677105	fb227e5a-764d-4582-a629-6057155a0014
1f7b0c5d-f066-421f-8555-c3b216785fcf	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "ca11c60d-c86b-4508-aa99-0e84c33cd9ec", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fb55d44320e0d2d6b22e"}}	http_request	2023-08-02 06:44:37.698271	2023-08-02 06:44:37.698271	fb227e5a-764d-4582-a629-6057155a0014
5f130dcf-933a-447d-bcc8-a2488c3914f2	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/u1UMcBla8xa", "status": "SUCCESS", "conflicts": [], "reference": "u1UMcBla8xa", "enrollments": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importSummaries": [{"events": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "status": "SUCCESS", "conflicts": [], "reference": "EVkRG41WXz6", "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary"}]}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"id": "example", "name": [{"given": ["Two"], "family": "Test"}], "gender": "male", "birthDate": "1980-01-01", "resourceType": "Patient"}]}	run_result	2023-08-02 05:46:33.455486	2023-08-02 05:46:33.455486	fb227e5a-764d-4582-a629-6057155a0014
4dda2b11-3e4e-4a46-ac0c-7b3f6ab72c7f	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "ca11c60d-c86b-4508-aa99-0e84c33cd9ec", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fb55d44320e0d2d6b22e"}}}	run_result	2023-08-02 06:44:38.744925	2023-08-02 06:44:38.744925	fb227e5a-764d-4582-a629-6057155a0014
639cec8a-c7e6-4afd-95fc-f3a51bb0f97f	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "049c4c34-1b8f-4e7f-9198-ffe7d086ed69", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fbead44320e0d2d6b44a"}}}	run_result	2023-08-02 06:47:07.714426	2023-08-02 06:47:07.714426	fb227e5a-764d-4582-a629-6057155a0014
78ed56af-f42f-449a-8cee-43d49d4a92b1	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "55d26451-113b-499b-a2df-088880cb883e", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9f97dd44320e0d2d6ab64"}}	http_request	2023-08-02 06:36:45.268449	2023-08-02 06:36:45.268449	fb227e5a-764d-4582-a629-6057155a0014
a83bb57b-b80b-4ef5-aba4-6e8a2969319a	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "0e6832f3-0174-4f9b-b5be-f45995c9b7b0", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9faf5d44320e0d2d6b0ed"}}}	run_result	2023-08-02 06:43:02.732141	2023-08-02 06:43:02.732141	fb227e5a-764d-4582-a629-6057155a0014
91648b5f-386d-4b60-8c7d-c1805f35174b	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "91db9b9c-36fd-4dee-9f27-df463cf92365", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9f9f8d44320e0d2d6ad61"}}	http_request	2023-08-02 06:38:48.186473	2023-08-02 06:38:48.186473	fb227e5a-764d-4582-a629-6057155a0014
30f6c716-0aaf-4c2d-a99d-54d894eacdc2	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "b693f7f8-607f-4e5c-838c-fc3a97be08a5", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fb8fd44320e0d2d6b303"}}	http_request	2023-08-02 06:45:35.197034	2023-08-02 06:45:35.197034	fb227e5a-764d-4582-a629-6057155a0014
3cc5c1a8-a539-430b-898c-4e74d71d0092	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "3417fa87-68da-4ec3-9d5d-2c4318b1eaf6", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fa49d44320e0d2d6ae83"}}	http_request	2023-08-02 06:40:09.709461	2023-08-02 06:40:09.709461	fb227e5a-764d-4582-a629-6057155a0014
c14155d9-2938-4ca3-804e-381cd4bb3769	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "b04c1f04-faef-4148-b60b-57ef061708d6", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fa7fd44320e0d2d6af51"}}	http_request	2023-08-02 06:41:03.699135	2023-08-02 06:41:03.699135	fb227e5a-764d-4582-a629-6057155a0014
bf9a387c-af0f-4527-bdc0-b94c462c15af	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Test\\",\\n      \\"given\\": [\\"Demo\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "0a032829-0c57-44c9-9351-686538ef6b6a", "content-length": "176", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64ca1c4ad44320e0d2d710b4"}}	http_request	2023-08-02 09:05:14.886035	2023-08-02 09:05:14.886035	fb227e5a-764d-4582-a629-6057155a0014
7a62536d-3f57-4adf-95cf-3991cc48f314	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "b04c1f04-faef-4148-b60b-57ef061708d6", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fa7fd44320e0d2d6af51"}}}	run_result	2023-08-02 06:41:04.750597	2023-08-02 06:41:04.750597	fb227e5a-764d-4582-a629-6057155a0014
f93aaf6e-62b6-4d6b-adce-e73493bae384	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/QDio09HCX6Y", "status": "SUCCESS", "conflicts": [], "reference": "QDio09HCX6Y", "enrollments": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importSummaries": [{"events": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "status": "SUCCESS", "conflicts": [], "reference": "OqNaXFZQNk0", "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary"}]}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Testing\\",\\n      \\"given\\": [\\"Wednsday\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"female\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "82053926-6aa8-478b-8777-ef87b7c5b317", "content-length": "185", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fc2ed44320e0d2d6b539"}}]}	run_result	2023-08-02 06:48:15.986086	2023-08-02 06:48:15.986086	fb227e5a-764d-4582-a629-6057155a0014
2675d97a-3205-44f0-9e80-9de89608a243	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "b693f7f8-607f-4e5c-838c-fc3a97be08a5", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fb8fd44320e0d2d6b303"}}}	run_result	2023-08-02 06:45:36.20656	2023-08-02 06:45:36.20656	fb227e5a-764d-4582-a629-6057155a0014
de87096f-debb-4ba5-84f8-bdcdbc12724f	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Does\\",\\n      \\"given\\": [\\"Given\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "049c4c34-1b8f-4e7f-9198-ffe7d086ed69", "content-length": "177", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fbead44320e0d2d6b44a"}}	http_request	2023-08-02 06:47:06.696961	2023-08-02 06:47:06.696961	fb227e5a-764d-4582-a629-6057155a0014
96fc7782-9ef7-44a5-b0de-691bf9fb4933	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Testing\\",\\n      \\"given\\": [\\"Wednsday\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"female\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "82053926-6aa8-478b-8777-ef87b7c5b317", "content-length": "185", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c9fc2ed44320e0d2d6b539"}}	http_request	2023-08-02 06:48:14.469193	2023-08-02 06:48:14.469193	fb227e5a-764d-4582-a629-6057155a0014
71c50553-968b-4201-8d1a-913d344b0d4e	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Test\\",\\n      \\"given\\": [\\"Demo\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "8359de2a-9b2e-4547-a3c7-c36f1926acd6", "content-length": "176", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64ca1c8cd44320e0d2d711d6"}}	http_request	2023-08-02 09:06:20.389363	2023-08-02 09:06:20.389363	fb227e5a-764d-4582-a629-6057155a0014
8bdbaa41-395f-4699-b523-f46ccf7928e6	{"data": {"status": "OK", "message": "Import was successful.", "response": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "importSummaries": [{"href": "http://192.168.0.195:8081/api/trackedEntityInstances/ozc98tcg6nz", "status": "SUCCESS", "conflicts": [], "reference": "ozc98tcg6nz", "enrollments": {"total": 1, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 1, "responseType": "ImportSummaries", "importSummaries": [{"events": {"total": 0, "status": "SUCCESS", "deleted": 0, "ignored": 0, "updated": 0, "imported": 0, "responseType": "ImportSummaries", "importSummaries": []}, "status": "SUCCESS", "conflicts": [], "reference": "RckugrV1psN", "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary"}]}, "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": true, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}}]}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"name\\": [\\n    {\\n      \\"family\\": \\"Test\\",\\n      \\"given\\": [\\"Demo\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-01\\"\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "8359de2a-9b2e-4547-a3c7-c36f1926acd6", "content-length": "176", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64ca1c8cd44320e0d2d711d6"}}]}	run_result	2023-08-02 09:06:22.263623	2023-08-02 09:06:22.263623	fb227e5a-764d-4582-a629-6057155a0014
\.


--
-- Data for Name: invocation_reasons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invocation_reasons (id, type, trigger_id, user_id, run_id, dataclip_id, inserted_at, updated_at) FROM stdin;
4a7fe400-14cb-4f67-b033-b33c09fb346c	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 21:17:41	2023-08-01 21:17:41
76ab8d78-7ba2-40bb-bf74-3ed14829d020	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	\N	2023-08-01 21:18:09	2023-08-01 21:18:09
16b6517f-d66a-47b4-8bf3-acbaa9c76207	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 21:21:53	2023-08-01 21:21:53
4ce075a8-cdb2-43b7-a716-427685282e7c	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	\N	2023-08-01 21:27:45	2023-08-01 21:27:45
2ef59eda-a0a4-4fd5-9350-94fb81baa32e	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 21:30:22	2023-08-01 21:30:22
2291c86c-6259-48b8-b412-fb435028e73a	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 21:31:32	2023-08-01 21:31:32
8f449152-b7a1-40a6-9c52-35b2f1d938b4	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 21:33:12	2023-08-01 21:33:12
f7cad00c-a5f8-425a-b2ea-57b80ce9c09a	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 21:35:33	2023-08-01 21:35:33
73db5a6b-47bc-4a47-a9bb-d8ffcbd89234	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 21:38:19	2023-08-01 21:38:19
6b780db6-3896-4c09-88ad-dcb9f0a2669e	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 21:44:18	2023-08-01 21:44:18
47d8f301-306e-4034-bbd2-f67e3f2e1d3c	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 22:00:24	2023-08-01 22:00:24
7e5a7b1d-9e93-44c8-89a3-11e11ccc2676	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 22:03:05	2023-08-01 22:03:05
ce114942-0b8c-42a8-9997-a4aad0ed29eb	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	2023-08-01 22:07:51	2023-08-01 22:07:51
8a7787e6-66ca-4161-9ae2-8d7cd21403a8	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	2023-08-01 22:13:01	2023-08-01 22:13:01
3ed5c31b-8c5f-41d4-a160-6379f28235c6	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	2023-08-01 22:14:26	2023-08-01 22:14:26
619771c2-9d7f-46cd-bc90-e7a68cc449f3	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	2023-08-01 22:15:54	2023-08-01 22:15:54
50d56bd3-53cf-4a01-a2a4-fb19a0de5ed7	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	2023-08-01 22:16:31	2023-08-01 22:16:31
b4f73299-1d34-4888-8e6b-75c2ccaaf673	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	4abc509c-2e01-4440-a6b7-6388da8df48a	2023-08-01 22:17:50	2023-08-01 22:17:50
701753d8-3c35-48d0-9969-a3b9ba680726	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	6d510da7-0fe2-4438-8430-0b5cddbc30ed	\N	2023-08-01 22:18:26	2023-08-01 22:18:26
b5947e86-349e-4faa-8437-f05494a2a1ae	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	1b20ade9-8076-4ea6-ba40-7d23f72b5923	\N	2023-08-01 22:18:28	2023-08-01 22:18:28
1d8e9a42-e5c7-4218-a7bd-6717076780f5	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	e150fe08-f701-4118-b1d7-59e50e9897a4	\N	2023-08-01 22:19:55	2023-08-01 22:19:55
2fa9d35d-0610-4ae4-a2f6-8f781c1c817c	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	dcb47cea-9525-4834-890c-b9dec6b1e1d3	\N	2023-08-01 22:20:33	2023-08-01 22:20:33
520566e9-3828-45ac-9090-bb1124f3fcb3	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	\N	2023-08-01 22:22:06	2023-08-01 22:22:06
416b3ff8-3932-406e-83af-b442611e4bc7	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	c4f6d370-efdc-4ccd-b364-8f5b5a10fb82	2023-08-01 22:23:41	2023-08-01 22:23:41
580c5b7f-75c3-428f-933b-b78bd136d002	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	bb538e5c-be1a-41f9-a87c-bda731a547d2	2023-08-01 22:24:17	2023-08-01 22:24:17
e66cfd15-92a9-4a7b-962f-02d823f9728d	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	ecfce58d-b526-4f7b-91d9-2de188c4522c	2023-08-01 22:25:27	2023-08-01 22:25:27
d5d93784-b8d8-477d-bd47-0bd48816f6b6	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	0819bf03-afcb-4639-98ad-748f5a7eff21	2023-08-01 22:26:28	2023-08-01 22:26:28
6ffad9e8-9a42-4fe6-b664-fc6cee6bc8b0	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	a148ea39-1aea-40f9-851a-ce3aa8c5dad8	2023-08-01 22:27:12	2023-08-01 22:27:12
a2cd7244-eddd-4201-ad96-6aa3f834a6b1	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	e8354c82-2ea6-4482-a636-11c3328f134c	2023-08-01 22:27:39	2023-08-01 22:27:39
9af4eda2-7916-4329-b5b5-3481ae8064ce	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	5d6c4af0-1007-49ba-af5a-1801378823b4	2023-08-01 22:28:27	2023-08-01 22:28:27
b21bfb2c-f037-41ef-b29d-9f43f203aad5	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	843c291d-271d-445a-8adf-0580d359d18a	2023-08-01 22:30:44	2023-08-01 22:30:44
d788da6b-aa5f-4947-bdb6-df81852cd276	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	cdc11b6b-b4b0-40ac-9bb8-eb946b7b62d9	2023-08-01 22:33:47	2023-08-01 22:33:47
75d53acb-ff68-4ae5-b58b-51d75f574b61	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	59a62b34-8af3-48ef-94ac-ba3e9fa20b77	2023-08-01 22:36:18	2023-08-01 22:36:18
cbdcc611-03a8-4df5-847f-79b1d66ba613	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	476975a8-0e3c-4446-8084-eeaa055ac7d2	2023-08-01 22:38:56	2023-08-01 22:38:56
18c384f3-6680-4bf5-bc18-d005f94f08fd	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	e8a2f33e-9a45-4258-8b20-350bcdab4a2e	2023-08-01 22:39:26	2023-08-01 22:39:26
454577ff-661a-461e-9ad5-3c63397661fc	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	3e279c6f-d72a-4c6e-8923-b9ce84be64bc	2023-08-01 22:40:03	2023-08-01 22:40:03
26d64f9c-5c62-42e6-97f9-eca6c71615d5	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	dc5c1447-c8e8-4122-9fa4-094ee70a4e45	\N	2023-08-01 22:40:26	2023-08-01 22:40:26
ea0ca7f5-35f7-4a24-a95a-7ba67b75e107	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	11a03b36-9539-4ea3-a0c7-2a9a472ba6d7	2023-08-01 22:42:00	2023-08-01 22:42:00
706af2b8-5a8d-46cd-ba2a-5a013566bb86	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	f1a60b31-cde7-4138-b8f3-d0ad31f12199	2023-08-01 22:43:21	2023-08-01 22:43:21
b326ebb2-8d29-4f76-8c2d-5b78d5be5181	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	698ece00-4dd7-4913-9efa-730ed8577b66	2023-08-01 22:44:42	2023-08-01 22:44:42
490ac1d1-eb8c-46df-8c50-36d0e9656954	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	698ece00-4dd7-4913-9efa-730ed8577b66	2023-08-01 22:49:20	2023-08-01 22:49:20
f768e325-6f8b-4b04-a838-438f8c76dc3c	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	698ece00-4dd7-4913-9efa-730ed8577b66	2023-08-01 22:50:17	2023-08-01 22:50:17
32808be8-a53c-4c92-b8a2-f880821d1f3f	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	698ece00-4dd7-4913-9efa-730ed8577b66	2023-08-01 22:51:33	2023-08-01 22:51:33
25b17c0a-8bd1-4705-9158-41f9a102ee6d	manual	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	\N	698ece00-4dd7-4913-9efa-730ed8577b66	2023-08-01 22:51:59	2023-08-01 22:51:59
ac40b66d-6393-46ff-b3c4-4cdd905e7ee8	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	\N	2023-08-01 22:54:26	2023-08-01 22:54:26
fe0d3d39-ab8b-4eb8-85a6-2bb09bbb29f9	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	0fd6b266-fe52-4660-a6a6-16363b9e47e4	\N	2023-08-01 22:54:47	2023-08-01 22:54:47
909f2f6a-6898-42bb-aad6-a2608e75df0c	retry	\N	a8cce28e-8904-4970-999b-d9174fd6b92f	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	\N	2023-08-01 22:55:36	2023-08-01 22:55:36
623d9b0a-458c-4d87-a615-ab41f9050e69	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	d30450c1-4fcd-4692-bc3b-dc1fa2b120de	2023-08-01 22:57:34	2023-08-01 22:57:34
c11eda9e-343e-4857-b040-6331b2899e7f	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	7136cbb7-a575-4c88-9b86-616fdf6436bb	2023-08-01 22:58:27	2023-08-01 22:58:27
bee2d4bb-27d4-4c7e-b6d5-92685092cdc2	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	4def2367-5223-45a2-a3f3-c657fa71a359	2023-08-01 22:59:00	2023-08-01 22:59:00
047f96c6-cda2-43bb-bbf4-9c63bc5d5cb1	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	043971d1-a7ac-4057-a473-14563f171273	2023-08-01 22:59:13	2023-08-01 22:59:13
54e4e31e-e679-4c11-b677-27549deda644	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	85c39700-0f2f-43c2-b6bd-b52523fcecd8	2023-08-01 22:59:53	2023-08-01 22:59:53
7b08f6ec-adaf-4ff9-8152-2467620600a6	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	f1c24be5-f00c-497a-b242-091fcbe12049	2023-08-01 23:00:51	2023-08-01 23:00:51
2ff94940-223f-42da-9a9a-eb243257e8ad	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	4d95c6cd-4797-439e-9716-557856b70a4a	2023-08-01 23:02:08	2023-08-01 23:02:08
99ad7f65-6ad0-462e-9610-68a960602949	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	a567da76-e110-44d0-a849-55066596a754	2023-08-01 23:02:54	2023-08-01 23:02:54
932f61cf-30cb-464c-af7f-cefda253406f	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	04823219-22fc-42bb-9bbf-69f495a919f4	2023-08-01 23:03:54	2023-08-01 23:03:54
83e4718a-9485-4eb4-aa48-9af309ffe890	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	3739f5ea-8bee-4e7f-a394-d6954c9d730a	2023-08-01 23:04:46	2023-08-01 23:04:46
9259accf-56a5-4dec-b3f2-4657a021fb98	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	87fd1c00-ef4b-4800-a076-02115d4d197a	2023-08-01 23:05:25	2023-08-01 23:05:25
cfcc1957-9c05-4f99-9f83-c27699ef6293	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	bc9abc10-7b45-4bc8-bb4b-ceef599275a1	2023-08-01 23:05:56	2023-08-01 23:05:56
d724d13a-2da8-4193-88fa-7867e340e5b0	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	fb70d5ae-77d4-4fa5-bd4e-2ea3528b2f9d	2023-08-01 23:06:28	2023-08-01 23:06:28
e5147230-3941-4a18-8f38-5aec515d60f1	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	4c76b298-6b17-42f6-9a57-3707e47630df	2023-08-01 23:07:28	2023-08-01 23:07:28
69515fa1-5691-4dae-93f5-30badb0d0d4f	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	13c03072-5132-4102-946a-978d1c8bc39c	2023-08-01 23:15:06	2023-08-01 23:15:06
e4f9c392-daec-473c-a413-bacf72cc4eaa	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	8add2b90-244f-4b7b-bd52-9989bf4a170b	2023-08-01 23:15:43	2023-08-01 23:15:43
5b4db964-e6cd-4ac4-a2d2-7ea2122ea67b	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	ff93db11-5928-42e4-ba42-47e1b2edde61	2023-08-01 23:16:18	2023-08-01 23:16:18
6c289967-8bc4-436a-9f7a-a09f8fed3a15	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	ab8e10f2-c5de-4fd8-abcb-39fcd2dd16e8	2023-08-01 23:17:08	2023-08-01 23:17:08
8cd017e7-52d6-4025-bfe8-c80c36df6fbd	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	e8b06c80-2a7b-4a4b-9b92-a94f46b67a1a	2023-08-01 23:17:50	2023-08-01 23:17:50
aee4c692-77fc-44e5-a19c-5ccab4d9e000	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	5fe0f833-07a8-4ad2-a350-a0a9727ce3f3	2023-08-01 23:19:31	2023-08-01 23:19:31
2d881d73-7aff-4c71-baa7-485b2cfe4bfd	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	436b9eda-41c4-4211-b676-7d7ffc8f76bf	2023-08-02 04:22:38	2023-08-02 04:22:38
fa66ce89-911c-4351-8cab-4c6863d09092	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	2fa31bb2-daa8-408c-95bb-b60683665e9b	2023-08-02 05:46:31	2023-08-02 05:46:31
5a3928ef-07b4-4dac-ad4e-a0fa6b78387e	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	78ed56af-f42f-449a-8cee-43d49d4a92b1	2023-08-02 06:36:45	2023-08-02 06:36:45
d8e79cdc-514f-42be-9145-8843d2518884	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	91648b5f-386d-4b60-8c7d-c1805f35174b	2023-08-02 06:38:48	2023-08-02 06:38:48
e5cb5cef-73f2-47f4-a5c0-bad7a62458c4	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	3cc5c1a8-a539-430b-898c-4e74d71d0092	2023-08-02 06:40:09	2023-08-02 06:40:09
79c53465-7947-4775-861d-55bb6e92a032	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	c14155d9-2938-4ca3-804e-381cd4bb3769	2023-08-02 06:41:03	2023-08-02 06:41:03
dfbf5e3d-931a-40ed-af70-3128a94742c4	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	7fe4b289-5f08-4c2f-a8f8-44c05d13c9fd	2023-08-02 06:43:01	2023-08-02 06:43:01
b7181f6f-c5c1-4ac9-a10d-e2d9b3cb99d4	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	1f7b0c5d-f066-421f-8555-c3b216785fcf	2023-08-02 06:44:37	2023-08-02 06:44:37
ca01abda-25b8-4071-bb41-dac89047a098	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	30f6c716-0aaf-4c2d-a99d-54d894eacdc2	2023-08-02 06:45:35	2023-08-02 06:45:35
78843771-b0b7-4831-976b-ec6d4c5b0ff7	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	de87096f-debb-4ba5-84f8-bdcdbc12724f	2023-08-02 06:47:06	2023-08-02 06:47:06
26e653b9-3de1-4e1d-8b13-60ff5dec60fa	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	96fc7782-9ef7-44a5-b0de-691bf9fb4933	2023-08-02 06:48:14	2023-08-02 06:48:14
96b7788b-cfe4-49ca-b5d8-91a238f8e321	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	bf9a387c-af0f-4527-bdc0-b94c462c15af	2023-08-02 09:05:14	2023-08-02 09:05:14
d2b1fd34-770b-4683-83c7-bac89219e985	webhook	49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	71c50553-968b-4201-8d1a-913d344b0d4e	2023-08-02 09:06:20	2023-08-02 09:06:20
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, name, body, enabled, inserted_at, updated_at, adaptor, project_credential_id, workflow_id, trigger_id) FROM stdin;
e436c7e5-46c1-4b4b-8bb8-33ed481c877f	dhis	\nconst fhirPatientResource = JSON.parse(state.data.body);\nconst birthDate = fhirPatientResource.birthDate;\nconst firstName = fhirPatientResource.name[0].given[0];\nconst lastName = fhirPatientResource.name[0].family;\n\nconsole.log("BirthDay: " + birthDate);\nconsole.log("firstName: " + firstName);\nconsole.log("Surname: " + lastName);\ncreate('trackedEntityInstances', {\norgUnit: 'i7Abqgp2YbE',\ntrackedEntityType: 'JVM5Uk0gCDI',\nattributes: [\n{\nattribute: 'a3ZFOlgcrZb',\nvalue: firstName,\n},\n{\nattribute: 'rFuwsxo7uGH',\nvalue: lastName,\n},\n],\n  enrollments: [\n    {\n      program: 'GYepvJVX21t',\n      orgUnit: 'i7Abqgp2YbE', \n      enrollmentDate: '2023-08-01', \n      incidentDate: '2023-08-01', \n      status: 'ACTIVE',\n    },\n  ],\n});	t	2023-08-01 20:42:15	2023-08-02 06:47:49	@openfn/language-dhis2@latest	5cfa5a70-63f1-4b00-8787-04bc2058cade	6f293a43-3f2b-46ef-ac47-8b7e67144172	49987767-ea8e-4b15-b5ec-11f97ac383a0
f5174adf-67e3-4093-a439-56678f09fc9e	test_http	// Get started by adding operations from your adaptor here	f	2023-08-01 22:47:01	2023-08-01 22:47:01	@openfn/language-http@latest	\N	28833745-532e-40df-99f8-ec59169f67b6	653c9553-1d5c-4095-b8ef-684868e24a0a
\.


--
-- Data for Name: log_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_lines (id, body, "timestamp", run_id, inserted_at) FROM stdin;
bd06483d-0a17-4111-ba70-5ffc1e834293	[CLI] ℹ Versions:	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
ac237800-82c4-4b5f-be32-92ea64cb38d8	         ▸ node.js                   18.12.0	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
69c63093-d27c-4ffb-8059-f139b16ffdd6	         ▸ cli                       0.0.35	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
bbcf4b99-bb1c-4eda-aa44-ad441912a8cb	         ▸ runtime                   0.0.21	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
7cfaee70-3a83-470e-ad60-5e7d98aeeb08	         ▸ compiler                  0.0.29	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
d6bbdefb-56b7-46e7-b0b8-fb9be2158b93	         ▸ @openfn/language-dhis2    4.0.2	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
bff49b13-074d-4faa-9179-ebee0ec7e0d3	[CLI] ✔ Loaded state from /tmp/state-1690924661-7-m78bum.json	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
43a78e55-8ff5-4861-b158-1729d4da32d1	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
d0472826-ec7f-45bb-a15e-e0668b5cb268	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
94bcc4ad-0ee8-457a-992e-5d00f127f3af	[CLI] ✔ Compiled job from /tmp/expression-1690924661-7-1rr11t4.js	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
7f54a069-5166-4d17-a19e-7cadfcdf3eeb	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
ccefdd13-975d-4105-b4d4-73b31e48288e	Preparing create operation...	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
8892a135-7c6b-4a58-81c2-5f54a54521e1	Using latest available version of the DHIS2 api on this server.	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
d7462b52-5cdf-4a2b-80db-234b75a480ce	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
bb56c78f-53cf-4386-81e6-1c4b154db7f1	{	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
7e81053c-3364-4f03-a0b5-d32c2ad79292	  "httpStatus": "Internal Server Error",	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
f2e6143e-7e02-4450-9ce0-a057473f40ad	  "httpStatusCode": 500,	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
b896fc79-a061-4e7c-baf9-089ac20c43d2	  "status": "ERROR",	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
085c79e3-ca48-4f34-8c1c-f9d2e1ad378b	  "message": "Transaction rolled back because it has been marked as rollback-only"	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
f4d7e006-909c-4fdf-b22e-b12e1a0506d4	}	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
73f55d49-c527-457c-88f5-230e5a7faba2	✗ Error at Tue Aug 01 2023 21:17:42 GMT+0000 (Coordinated Universal Time):	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
b1275a1b-9535-46db-b729-9cbbdbfb804b	∟ Request failed with status code 500	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
8c8d35bd-6435-463e-982f-34ac7702f434	[R/T] ✘ Error in runtime execution!	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
21e1117c-7ba2-4773-9e45-6f48268c90d3	[R/T] ✘ [object Object]	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
a93dbdae-aacb-44cd-a046-8b370afbdd5b	[CLI] ✘ Error: runtime exception	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
00c7788a-c84b-47c4-a12d-466ebeabbed8	[CLI] ✘ Took 616ms.	\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
f31c7544-2e3b-4c0e-9bf8-823a063115a1		\N	9c79c6fd-8952-41c8-9e0b-6c8f83df2766	2023-08-01 21:17:43
80e3de59-dd59-4f69-815b-34425977ceec	[CLI] ℹ Versions:	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
bd3d40f8-0823-45dc-beeb-92eeaeba117f	         ▸ node.js                   18.12.0	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
02cdea1e-cd0d-474e-8688-4655250ae43d	         ▸ cli                       0.0.35	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
52b24733-c668-42b0-9158-8e87892dbb53	         ▸ runtime                   0.0.21	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
bf644d0a-1eca-478a-996f-d6bc0feb5f1b	         ▸ compiler                  0.0.29	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
89b6ac10-cab2-4ff1-80b2-0d6cc94fbe4a	         ▸ @openfn/language-dhis2    4.0.2	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
2734067c-d58c-49bd-b359-065eb6ad73f3	[CLI] ✔ Loaded state from /tmp/state-1690924689-7-1btrr8m.json	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
1a0f6454-f61f-4594-b998-62044babd06e	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
2c4159c5-ffb3-4563-a01a-555337e8af25	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
44211da4-f92c-423c-a7f7-baea591d48a6	[CLI] ✔ Compiled job from /tmp/expression-1690924689-7-1ggka2y.js	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
eee48d5f-3d3e-48c3-a6fb-3d9270c0624c	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
1aeccf53-e484-40ac-99c1-41f2fd359de3	Preparing create operation...	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
4a93615c-b62b-44bd-b415-6c0fc2bd5e15	Using latest available version of the DHIS2 api on this server.	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
f0c7d7d8-4910-468e-832c-a338b07e5962	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
0a64bbb3-48ab-4f82-beb2-c49faf340d31	{	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
24399369-9a4b-4a50-b8d7-8c732b9fb2ac	  "httpStatus": "Internal Server Error",	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
b51c8beb-bb4d-4ffa-8df1-7acf71b91c08	  "httpStatusCode": 500,	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
b544fa99-3c20-4f22-8457-7bad88ada12c	  "status": "ERROR",	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
43c266c9-a4be-4883-b1d5-59c31c19b7c7	  "message": "Transaction rolled back because it has been marked as rollback-only"	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
bf3a46b9-9cbd-4dfc-8df1-a86a705e5673	}	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
794755da-ef77-445c-a6ee-cd319d4d98f3	✗ Error at Tue Aug 01 2023 21:18:10 GMT+0000 (Coordinated Universal Time):	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
c882084a-b6a6-4365-815c-01d2c05240a5	∟ Request failed with status code 500	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
09e7006f-3f47-4990-a546-561ab8f4c07e	[R/T] ✘ Error in runtime execution!	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
6a5f0248-f1fb-4865-a054-bd72340adc3a	[R/T] ✘ [object Object]	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
9567a740-3299-4118-a18c-af3a0db9eb40	[CLI] ✘ Error: runtime exception	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
93ad426d-b2b8-447c-b21d-d8bcaad89899	[CLI] ✘ Took 552ms.	\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
7f783e27-df1b-485a-8439-1568856923d9		\N	c9e20139-a5d5-4706-aaa4-1eb0941549dd	2023-08-01 21:18:11
e9d6dbe7-d39b-45c0-a240-a595ccd3b45c	[CLI] ℹ Versions:	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
82ae4e99-0018-47f8-b72c-546125e030aa	         ▸ node.js                   18.12.0	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
e4a19a62-4ced-4eea-8184-d95ec8924b9c	         ▸ cli                       0.0.35	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
94c2fa0e-ab75-4a3a-9055-0ddd13ab4c45	         ▸ runtime                   0.0.21	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
dc7e5510-381b-49d6-84ec-f4ffa20c2c1f	         ▸ compiler                  0.0.29	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
ba6f9723-afd1-4ca0-80bf-0281f3b407e8	         ▸ @openfn/language-dhis2    4.0.2	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
6b5a482b-1ce3-4e5e-9b10-6885cbe5295d	[CLI] ✔ Loaded state from /tmp/state-1690924913-7-16fkfuq.json	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
4effb937-db90-46fe-8871-d4849f79e79a	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
1ae6dd80-b2ec-4535-853e-46d7f4ed3541	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
fcdfc411-2bb7-4173-94c4-e071bb949993	[CLI] ✔ Compiled job from /tmp/expression-1690924913-7-1ppcvpx.js	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
ba4b39ba-63a3-49b7-a518-c6597557ce41	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
fcae4580-cef0-4ec5-97b2-32594c207633	Preparing create operation...	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
e4a156c9-aab7-4f7d-8a3b-84e1c766e879	Using latest available version of the DHIS2 api on this server.	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
71506723-97d0-4eea-a117-5fa9ac1a5d5f	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
d1a3dae0-0efb-4e1f-ac76-8763bf294145	{	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
c27bb433-d7aa-48b8-af5e-f5239a087512	  "httpStatus": "Internal Server Error",	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
3fdccc11-dd67-4d12-8f1f-7e19dd4670c5	  "httpStatusCode": 500,	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
ebb9d5c9-6e8e-43a7-a0b0-e557dbac6336	  "status": "ERROR",	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
ca7a49d2-1595-4406-be83-ee4848dbf208	  "message": "Transaction rolled back because it has been marked as rollback-only"	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
bfe94619-a630-4311-ab8a-ce1e596b522f	}	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
960bdc5b-16d5-44cb-8ad3-0cb66ef61da9	✗ Error at Tue Aug 01 2023 21:21:55 GMT+0000 (Coordinated Universal Time):	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
e684adaa-b3fc-41e9-a291-eeeeb4e7b505	∟ Request failed with status code 500	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
43b853e8-d4b3-448b-ab4e-f63cc5151a7a	[R/T] ✘ Error in runtime execution!	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
ce057461-fd5a-457d-a7f4-e84d29b8b7a9	[R/T] ✘ [object Object]	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
ece8fc14-87c1-4fd1-8b95-03e2a544ed32	[CLI] ✘ Error: runtime exception	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
e11b9d0b-ab56-40d1-be7c-b4ed453b43c1	[CLI] ✘ Took 567ms.	\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
5a103c24-95bd-4752-a28c-8cf970027bd9		\N	92fdb4c7-15d5-47de-aad7-3f8e1f491fac	2023-08-01 21:21:55
e4bfa12c-d6a9-418b-b4e4-5c5150cf73fc	[CLI] ℹ Versions:	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
c3fd2ca8-9565-4ba3-80fb-86536808d7b4	         ▸ node.js                   18.12.0	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
6d6df7df-08ff-4c0b-b33e-5199ff822d06	         ▸ cli                       0.0.35	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
81fdd9cc-184e-49f7-a367-f70179eecd14	         ▸ runtime                   0.0.21	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
ad7033ad-3f31-47a8-a220-d2a26d0e4776	         ▸ compiler                  0.0.29	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
6dc93100-c752-4181-a46f-3b46a8ad9a00	         ▸ @openfn/language-dhis2    4.0.2	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
028a6c76-da9f-44c8-9094-6ff595129df2	[CLI] ✔ Loaded state from /tmp/state-1690925265-7-1nayx3t.json	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
d8f29a8b-42e6-4ec0-b7ff-38ac064e6036	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
1bd5709a-6157-44c7-884d-c9525349741c	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
8ddfbc0d-528f-4470-b498-d9231d3f9d67	[CLI] ✔ Compiled job from /tmp/expression-1690925265-7-69npxz.js	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
c17aa876-ee08-40fa-a803-d0a79c8fea57	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
871528c3-c460-46ab-bdfd-e4720d03d596	Preparing create operation...	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
977979bb-b666-4e70-8f58-f92205e66ee5	Using latest available version of the DHIS2 api on this server.	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
27d09682-bc18-4c5a-b433-eb5a0d1ca787	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
df97b7d2-2ff9-4dc4-ab20-9252b0693873	{	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
1e5e395b-82ca-4cc3-9635-58efe0a9d0a2	  "httpStatus": "Internal Server Error",	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
c564bab0-e43c-4088-bb6f-8e8656829fbf	  "httpStatusCode": 500,	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
cc79f951-cc29-4ea5-a82e-5a5ca3d12d51	  "status": "ERROR",	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
acd85858-417f-482f-876e-56226609ba3b	  "message": "Transaction rolled back because it has been marked as rollback-only"	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
a690aba2-417b-46b5-8971-eb50abfe5101	}	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
2940dea4-83bd-46a2-b719-ee7ede84e73b	✗ Error at Tue Aug 01 2023 21:27:46 GMT+0000 (Coordinated Universal Time):	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
36815d6d-7580-41cd-a18f-55cb4fe9ada1	∟ Request failed with status code 500	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
5ee30e74-aef9-43d0-841b-aa4c9dbf60ba	[R/T] ✘ Error in runtime execution!	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
56607a53-ab6b-4304-a609-849f49ede313	[R/T] ✘ [object Object]	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
c338ca98-bca8-41fb-845d-6c9623e46e72	[CLI] ✘ Error: runtime exception	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
7a15dc9e-bcb2-41a1-9507-147dcb264163	[CLI] ✘ Took 607ms.	\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
8e567217-8f98-45aa-84ae-8c1ceef62acf		\N	75abaf93-551b-44b3-beb9-b01b7c3cb6b1	2023-08-01 21:27:47
79fa72c5-7ae6-474c-bdb8-30432f88c1b1	[CLI] ℹ Versions:	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
2001773f-e508-4911-b5eb-665f84046439	         ▸ node.js                   18.12.0	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
756f5380-df3a-4025-b2a4-9b7c9b3076df	         ▸ cli                       0.0.35	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ba5c15c7-7c6f-43dd-a7c8-da3529015fef	         ▸ runtime                   0.0.21	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
07bea930-cb01-4512-9414-9fbebd826d3d	         ▸ compiler                  0.0.29	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
255786af-e9ca-48c1-bba7-38d540e023ae	         ▸ @openfn/language-dhis2    4.0.2	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
8a6fba0c-9bde-49fd-b04c-bc659353de12	[CLI] ✔ Loaded state from /tmp/state-1690925422-7-1rnht4m.json	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
7f3740cf-fae7-4dc1-b10c-64e19d8d00c6	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
b39bb02b-5bf6-4893-bc7e-3e1788defc2e	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
84104c23-ee50-408e-a39c-1aff9aae30ed	[CLI] ✔ Compiled job from /tmp/expression-1690925422-7-pt8tkg.js	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
2bfe0009-33a6-478d-ba5a-b9b8e742e969	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
1f6bc8a4-1dff-43f8-a894-f57e891e3549	Preparing create operation...	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
3041e9c1-664d-42de-abf4-1c839be9265d	Using latest available version of the DHIS2 api on this server.	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
6a76585d-baed-4bff-9970-899080a317e4	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
0d748d1d-28ce-4da0-b655-e41a6d131ca6	{	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
bffae3d3-c00b-481d-bf38-07ad96a1d6fe	  "httpStatus": "Conflict",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
280cee3c-136b-4c5b-84f9-04878b27a99f	  "httpStatusCode": 409,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
2a3ed89b-a11a-406c-9ff9-1a560fb7a664	  "status": "ERROR",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
d7814ba4-f899-46d0-b7ee-2f740eb363e9	  "message": "An error occurred, please check import summary.",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ff5fc9a8-6d92-4f93-8a3c-efd42a859ac7	  "response": {	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
cb0ba0dd-6c23-4a12-a276-9f0b2db92bb9	    "responseType": "ImportSummaries",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
be4a6ef4-993b-4b50-a8e3-4f1dcbce4b26	    "status": "ERROR",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
7b6ac095-cb58-47bb-8649-1130b4d1461e	    "imported": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
3a6a4347-7a61-4af6-9909-0b4443369463	    "updated": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
7e5050df-0bee-45d9-a15d-3899b537f133	    "deleted": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
99c81032-bc11-41ee-a33d-9db32aa2d4a1	    "ignored": 1,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
a5a719fb-23b1-4c33-b98e-27f76ec59265	    "importOptions": {	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
24593354-8fa1-4dc4-a350-caf0223f5021	      "idSchemes": {},	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
b19e8500-fcbe-4a12-87ea-cdd983fbd30b	      "dryRun": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
09c31b4e-ad11-4658-bf4f-57be4385bf1b	      "async": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
0a803b21-9a47-4153-8c98-7d252f5caadf	      "importStrategy": "CREATE_AND_UPDATE",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
281f7f68-5dd0-4977-892e-879a69a83fee	      "mergeMode": "REPLACE",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
794ea102-c46d-446b-89cb-2de1a9b07eee	      "reportMode": "FULL",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
184e303c-a039-4996-b8fa-64934a03fbdc	      "skipExistingCheck": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ea0f03ea-03bd-4e1e-ba50-b34950bfdde4	      "sharing": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
d48ac8a1-dfe5-4d59-ac62-bb3e0d58c521	      "skipNotifications": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
70708287-9f4b-409e-b9fa-b9b769062834	      "skipAudit": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
4ffa9f45-f79e-40af-9365-701ed0b27a17	      "datasetAllowsPeriods": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
1de3a889-1a99-49f1-b224-d57d60b314fd	      "strictPeriods": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
d5699751-2cff-4acd-a798-6e281ad4d75e	      "strictDataElements": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
c4bf3a85-6e27-436b-8f40-6a2fda7391df	      "strictCategoryOptionCombos": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
363ad12a-d756-49ee-9b7d-fc59568e4a33	      "strictAttributeOptionCombos": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
d6bba7b3-564b-4da4-9a6f-5ac5a6ccd97e	      "strictOrganisationUnits": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
046ab0c7-0a15-4e43-b372-ac479d68def1	      "requireCategoryOptionCombo": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
fb98aab3-08f9-4a07-974c-f1d00df878a5	      "requireAttributeOptionCombo": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
4f32ad6d-ef5e-4632-9aa7-6623f1d534e1	      "skipPatternValidation": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
b4d88348-6701-47c3-97f1-69d8a27160de	      "ignoreEmptyCollection": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
6dd6f9b1-f995-460e-9e12-7456e9c93606	      "force": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
04025a17-d654-4f64-b4e7-66ab66354de7	      "firstRowIsHeader": true,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
2944497f-3ea9-47bc-86ef-14786dd475ac	      "skipLastUpdated": true,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
78dd60ff-a1ef-4ca6-ad23-6ab09547e0f9	      "mergeDataValues": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
3db10a08-b82e-4a5a-8def-adb1e0bfcaf2	      "skipCache": false	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
9e77bf06-c115-4d69-9632-49485800d0a4	    },	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
e27c6640-6917-439b-8911-bb7d83bfc670	    "importSummaries": [	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ebbaa775-1de1-4072-a23d-1f9bddbbf802	      {	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
b9345be6-3ab1-4d21-9c4b-9cf80eb346c2	        "responseType": "ImportSummary",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
90af3813-d6a5-4714-9f81-ec5f3239abf0	        "status": "ERROR",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
c0ac49d4-3a38-41b5-8623-0d9e79d2deb5	        "importOptions": {	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
dc36527b-8d2b-4819-b10f-f66d4734d3d3	          "idSchemes": {},	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
04f88c28-8c0d-4c12-ad0d-ebdfef8a66ae	          "dryRun": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
130e17d1-e4fd-4c63-ba3e-f0ad8e2b1158	          "async": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
3dd187d4-663b-46ab-896a-25e169eaf478	          "importStrategy": "CREATE_AND_UPDATE",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
7760803b-225f-4429-a02b-5d2aee83452c	          "mergeMode": "REPLACE",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
dd5e8c21-ec01-40c5-be88-467337cbd969	          "reportMode": "FULL",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
cacf5ea2-714a-4302-a86e-6ccf8e79c922	          "skipExistingCheck": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
cf492e8f-82d4-4e54-864a-6accd1cead49	          "sharing": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ab67b080-e71f-4864-a654-803fd843a864	          "skipNotifications": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
e95a800a-3455-45fa-85a9-7b2f324c3557	          "skipAudit": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
8a90d528-bf38-4df3-a536-befb1336b23d	          "datasetAllowsPeriods": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
4e5b97e4-ee5a-4bd2-aa6d-e03cba884f9f	          "strictPeriods": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
00084471-ed05-49ab-ab38-44379c07e6bb	          "strictDataElements": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
40d5d3a8-8849-444f-b16f-fb4cadaafc75	          "strictCategoryOptionCombos": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
e0b3cb03-371e-428f-9081-df084b8737fb	          "strictAttributeOptionCombos": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
d1b8244e-1e1d-4da7-86d8-bf89b69301c4	          "strictOrganisationUnits": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
50f58bab-7e8c-41f4-a4d5-8fb6c0c041e4	          "requireCategoryOptionCombo": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
666d5fa7-07aa-4868-880d-99ba823468c6	          "requireAttributeOptionCombo": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
e88219ce-c51d-4f78-9837-481fd58ed4f3	          "skipPatternValidation": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
5acfbedd-3f8e-448f-b90d-1df47f561cef	          "ignoreEmptyCollection": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
869a433a-683f-4e9a-93c6-a1fa4f5ae783	          "force": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
5c79d268-c0eb-49f2-8b5e-8f0544b8e525	          "firstRowIsHeader": true,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
b35c68ea-48fc-4e07-90a9-7c3909f31559	          "skipLastUpdated": true,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ddf17a0c-8235-4cb6-9ae9-19e6716e3a5e	          "mergeDataValues": false,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
fc30ca28-a09e-4482-902a-4f19533000d8	          "skipCache": false	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
32b7dd73-a548-43bc-8442-85e7e05fb9de	        },	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
0c14a08d-4016-40ab-bd92-19486b9186a2	        "importCount": {	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
a15abafd-e406-42fb-8d79-011e79ec1663	          "imported": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
692f8d78-cbcc-469a-96ff-009e75b6c58a	          "updated": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ca944802-b8b7-4745-a060-eb79d4849192	          "ignored": 1,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
37c1b4c2-d364-4bd9-8155-eb21c330aad5	          "deleted": 0	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
c19272dd-dc70-410e-826a-ea6dbf076713	        },	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
a12ce509-8df0-48a8-aba4-2a21fe4d048b	        "conflicts": [	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
7cc434cb-ebbe-4684-9fdc-7fdea0700ef8	          {	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
7729071d-6c8f-4b8d-a3fc-ae4b1d31cef6	            "object": "TrackedEntityInstance.trackedEntityType",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
380c65e2-246d-4068-9457-8a16cc675ce9	            "value": "Invalid trackedEntityType nEenWmSyUEp"	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
3ef41f22-16af-4948-acaa-8063d100d049	          },	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ddae6593-39d3-4ee2-92b3-b02632bfc3be	          {	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
0543471e-d5fe-40b5-9fbe-8cb76474f711	            "object": "Attribute.attribute",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
053c3ef2-eae5-41e8-b546-78f7f02e8a44	            "value": "Invalid attribute w75KJ2mc4zz"	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
caa64c86-c397-490d-8324-4401947aabb6	          }	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
81c32a15-af96-4f54-bca9-5c58d3c8f646	        ],	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
930048e8-163e-4125-a83a-583f3c6254ca	        "enrollments": {	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
48a68ac8-ccc2-4662-8d24-78bcb43e4a46	          "responseType": "ImportSummaries",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
3ace82d1-46cc-4d9a-b2a5-eb52e7c8aefc	          "status": "SUCCESS",	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
f019924d-58ad-4caa-8342-7844100c7869	          "imported": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
87a6e40b-126f-4064-8e1e-fb5d7a48b263	          "updated": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
78591664-9579-47ac-ae3f-f02c268137a2	          "deleted": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
b482210b-db63-4ec6-b44c-d31eb93bfe45	          "ignored": 0,	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
6d182156-d68f-435d-a8e4-855db20cc87e	          "importSummaries": [],	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
ada76270-f0c8-4841-8b67-8aaf27a3a9b5	          "total": 0	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
50362130-d227-4cbd-a884-935a73aa6e2b	        }	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
a0300e8a-d1aa-4d3c-9bcf-64aa60900ab4	      }	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
5d21c928-abd1-44a0-a34a-c04e61bc1340	    ],	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
cad093fc-0cd7-4840-b701-f7ec53857e7e	    "total": 1	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
374262ba-66a8-43b2-a76d-57007c145bc5	  }	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
be377a03-52f0-4e86-beb6-dc28f2911b2c	}	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
a1d8cc9a-1b63-4579-ab0d-8ba4c7052bff	✗ Error at Tue Aug 01 2023 21:30:23 GMT+0000 (Coordinated Universal Time):	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
2fe73a6a-70bd-4fad-a818-9b52bb31a467	∟ Request failed with status code 409	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
47f7ca7a-8af6-42d3-8d82-07132221f904	[R/T] ✘ Error in runtime execution!	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
43c1fdb8-8ce3-410c-84dd-8d80b71432ae	[R/T] ✘ [object Object]	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
b7e4049b-5ca3-41de-ab7c-d5d9f099cfcf	[CLI] ✘ Error: runtime exception	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
f2025dad-e01e-4048-abfb-b343edaa74db	[CLI] ✘ Took 616ms.	\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
28caf053-2db3-4108-a357-6b7916c2c418		\N	20e1fbeb-a42e-48e9-9d1d-f09220cace34	2023-08-01 21:30:24
0ea81375-5835-4bc9-90b1-2b6e98871727	[CLI] ℹ Versions:	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
9473371e-8007-47da-b860-ed6dd64d71a4	         ▸ node.js                   18.12.0	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
6595c182-4a37-4df4-8e8c-e80307dd87fc	         ▸ cli                       0.0.35	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
f3e2434e-0ae7-47a6-af20-501ca9f98e4e	         ▸ runtime                   0.0.21	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
7919fc2d-499f-4205-bb86-fbfa4f2a5d30	         ▸ compiler                  0.0.29	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
3df747ac-b0d2-4a2a-8379-6f4cf5dd7caf	         ▸ @openfn/language-dhis2    4.0.2	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
bb23ddf6-602f-4a22-8569-6b2474bff53f	[CLI] ✔ Loaded state from /tmp/state-1690925492-7-156kaz2.json	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
451cfd2b-8ef1-4de5-920f-9e2249afb135	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
7a930562-4167-4845-9719-d56d8c299c95	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
e6af2e5f-c621-4bea-8c8b-03b596fa0373	[CLI] ✔ Compiled job from /tmp/expression-1690925492-7-e1cj64.js	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
25968ada-f811-4e1d-a9ad-32d76a39067e	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
ebd39c99-2cf8-4a3d-a967-f6fb0e98ad4d	Preparing create operation...	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
72a55aac-40a3-4285-8acd-35ae8464d6ea	Using latest available version of the DHIS2 api on this server.	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
74735e1c-a083-438f-85db-a84f0d3d8c41	Sending post request to https://play.dhis2.org/dev/api/trackedEntityInstances	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
3da8a787-c78f-4ea2-ba92-ecced1e9b07c	✓ Success at Tue Aug 01 2023 21:31:35 GMT+0000 (Coordinated Universal Time):	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
b0b5ac00-d1b8-48c9-9637-56dade97ec45	∟ Created trackedEntityInstances with response {	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
b2d5affb-6400-4673-81c1-5167ec20aca8	  "httpStatus": "OK",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
f7d4264f-3d8d-4a2d-b9cf-11d4b30f3693	  "httpStatusCode": 200,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
82c7be8e-5058-4083-bc80-9e329e901db7	  "status": "OK",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
1250a569-c519-4a2a-af09-c8a92ddaeadd	  "message": "Import was successful.",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
32cd5365-6a25-442f-a1ae-823b763e9cc8	  "response": {	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
e8b88a86-85e5-4530-aa97-ad01757931b8	    "responseType": "ImportSummaries",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
2ddd5554-6a1f-41bb-8fb2-8831f64dcfb6	    "status": "SUCCESS",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
6436b1a2-63f5-4d54-9ce8-f716511d821e	    "imported": 1,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
3c8daf1e-1e3b-4706-bb8e-fb2211bc42fc	    "updated": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
ab2eb56b-df4d-462a-b755-fbd8196df9ea	    "deleted": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
61992152-071d-4032-bf47-943d8b2563e1	    "ignored": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
80fd70bf-f23b-4c83-a04e-3c7fd9d3ff9e	    "importOptions": {	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
67535dc4-14c3-45fb-9e54-99b74e76d499	      "idSchemes": {},	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
b4d1fdc0-137d-49a2-aa2d-1c08e5927daa	      "dryRun": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
918d1c20-e5eb-466c-982e-8ab518df0e5d	      "async": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
0d85bcfa-df86-4f16-a691-13a3e648b5c0	      "importStrategy": "CREATE_AND_UPDATE",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
3693e5d0-573c-4ded-ad94-5731dce74eb9	      "mergeMode": "REPLACE",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
d2be0c20-1bd0-4c5a-84a3-9d1837c1d627	      "reportMode": "FULL",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
25d723fa-0b58-46ab-aaf5-0667fba37515	      "skipExistingCheck": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
5339ca0a-2b91-401c-a16d-3c9700d963c6	      "sharing": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
ad7ceab5-9e6f-43d4-9cbe-2bca251f4832	      "skipNotifications": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
c4ea8621-3b3d-43fc-9142-a66fd21af56d	      "skipAudit": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
59b51601-5a6a-45d3-a241-2d665cdd7f57	      "datasetAllowsPeriods": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
deeb4e72-dde3-477d-b2bb-8b801c5f081f	      "strictPeriods": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
f0f0544c-5988-453b-9e12-e4cc73052c5c	      "strictDataElements": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
80a43ec5-3de9-490c-83f4-fedce7d1f379	      "strictCategoryOptionCombos": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
d5cd5464-725e-4e1b-9cd3-3555dae0d374	      "strictAttributeOptionCombos": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
afa805dd-8597-4342-b7ab-517baeeaed18	      "strictOrganisationUnits": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
00ee15ff-132e-470f-a75c-32f6b356618f	      "strictDataSetApproval": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
4a8fe0ec-a992-436c-8d1d-d2182e5d9db1	      "strictDataSetLocking": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
b1dc48e8-493d-441d-9954-9bff74a66f87	      "strictDataSetInputPeriods": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
0271a69f-c822-4ac4-8945-30e602f83d46	      "requireCategoryOptionCombo": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
91d925dd-0821-4e7d-b7f6-eee426f4d3b9	      "requireAttributeOptionCombo": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
a9f5f9ad-e9be-4e7c-b23c-dfb903e40915	      "skipPatternValidation": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
f8540e42-3ae7-4505-ac1c-7a7899aca51e	      "ignoreEmptyCollection": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
43a6fb8a-66a3-4960-9a71-b4dc6911d5a4	      "force": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
ca5b5b7b-0ac5-46ce-a2e2-cfa4a2a0dc3e	      "firstRowIsHeader": true,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
eb30f5cc-e2ef-4cf9-8b5d-57b4a16a04c5	      "skipLastUpdated": true,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
be6859db-efee-4d02-9b98-4ae7f02a85a0	      "mergeDataValues": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
30de4df8-d3ea-4269-89f8-3ede5607cf8c	      "skipCache": false	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
ab01591d-27ba-4e5a-9432-7f7305abd297	    },	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
a7005340-fef8-488d-8130-81c3f69598cb	    "importSummaries": [	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
3ec158ae-8530-490f-9b75-c6907333abe3	      {	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
5784d549-e03f-4528-adda-8c83d3b67452	        "responseType": "ImportSummary",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
a3f6f016-66ee-49cb-8499-d161209a1ec8	        "status": "SUCCESS",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
26112fcc-8953-4c45-a41f-5f9e3ea41b57	        "importOptions": {	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
b8fe5cbb-2b28-47ab-b435-56512a2ed027	          "idSchemes": {},	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
4683d1ab-5d64-4c4d-bb5b-683aba586e60	          "dryRun": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
6e69d5f9-8a6d-4ffe-bba0-4c8b331290c7	          "async": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
16376f64-f07e-4a6a-a607-9a19e22134c0	          "importStrategy": "CREATE_AND_UPDATE",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
35fb5ce2-6df6-4bd0-9303-5cd69ea67e88	          "mergeMode": "REPLACE",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
9067ba24-3ba7-494b-b24d-c10bfed96db4	          "reportMode": "FULL",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
eca90bfe-e33a-49fa-9916-1a8634bc7806	          "skipExistingCheck": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
e286ed33-16ca-4adc-8bc5-201d25957c5e	          "sharing": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
1b46941c-7c57-4f70-8595-381dacadf29e	          "skipNotifications": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
8940f6a6-9970-4731-af7f-a89529b80c52	          "skipAudit": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
50cd2490-5884-4fdc-98d7-77edb044c139	          "datasetAllowsPeriods": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
adf35427-e3bb-4d64-8aa5-5db1a66afd7b	          "strictPeriods": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
79e0ad0e-7c71-4b71-afc8-1dc34818231d	          "strictDataElements": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
3b193dee-55cc-45e1-8dad-a657ab9ac3d9	          "strictCategoryOptionCombos": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
1d0d6bf8-9a98-4aeb-89d3-ed8a9c17ff07	          "strictAttributeOptionCombos": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
af96649a-b3c1-4f54-a94f-ab4993ef9d65	          "strictOrganisationUnits": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
712900b6-aeae-44eb-b054-fc9e825b8553	          "strictDataSetApproval": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
a7a9c32e-9176-4b6c-a4f5-9ab886aac0b4	          "strictDataSetLocking": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
58776e30-b608-4dad-a04c-3d600508e956	          "strictDataSetInputPeriods": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
6b17364b-84dc-48e8-b5e5-98421abe444d	          "requireCategoryOptionCombo": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
ed8db949-3c15-4d1f-8d3a-c7fcacaf47c4	          "requireAttributeOptionCombo": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
1af277ad-03ca-49c1-92d3-515a16abb458	          "skipPatternValidation": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
dda3c560-1ee6-40d7-894c-5d392570ee74	          "ignoreEmptyCollection": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
a859bd23-6fd2-44da-a01c-deb46d8c2e08	          "force": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
b61e4cfa-b8ab-40c9-9d74-c834bdc97205	          "firstRowIsHeader": true,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
8578e9af-cd98-470e-9688-d2e7f9c1094f	          "skipLastUpdated": true,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
e291be61-1962-4437-a39f-770426704f22	          "mergeDataValues": false,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
66599e4f-ff0e-4d26-b856-d5417d859255	          "skipCache": false	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
77f28522-5401-430c-a620-b4cfb7e7bf73	        },	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
4c7f9bc1-50e5-49fc-a819-a97b10e55760	        "importCount": {	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
fde88be6-672b-4813-843d-370188e256fc	          "imported": 1,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
ff513d94-a272-47da-ad85-2d3248ad8391	          "updated": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
cf5ccfd4-17d6-4743-bf52-c161865c3605	          "ignored": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
f1865a20-9d7c-44c7-8d98-522f852089c3	          "deleted": 0	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
c506a0b0-7e78-4b8a-9f50-1f92933257f3	        },	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
602189a3-3f5b-49ed-80df-f74d65fd0d6b	        "conflicts": [],	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
e4a899e8-e6f9-4074-861d-a5e50d777afd	        "rejectedIndexes": [],	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
a0f44c71-fb98-4cb1-b4bf-40f7ec1753b7	        "reference": "rQMXWmJN5B8",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
2f19ac1e-804a-474b-9337-ce593621b3ea	        "href": "https://play.dhis2.org/dev/api/trackedEntityInstances/rQMXWmJN5B8",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
d8a546bc-1427-4435-89e9-518bdd90adf9	        "enrollments": {	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
ada3d7fe-3542-40bd-80b1-faec64758cab	          "responseType": "ImportSummaries",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
d69b6759-bcda-4add-b084-5b2502463311	          "status": "SUCCESS",	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
24498949-857d-47b3-bef3-b85c0cff960c	          "imported": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
fec8c44b-d328-4009-86a9-56f93f0f796b	          "updated": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
12f3c0f5-fb00-46a5-81dc-0873c16d9810	          "deleted": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
95304ed7-5aee-4726-86ed-d3adb14f130d	          "ignored": 0,	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
8a493759-81d2-4c94-a5c5-06c06c913a68	          "importSummaries": [],	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
24b259ed-4714-44a4-bbd4-73daf86f8dd1	          "total": 0	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
09c22299-3ed8-43b7-9dce-aa0ed2303366	        }	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
d246c64c-339a-4bc0-a492-cb9dfd6cb396	      }	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
8a456cc6-0305-4f6c-a878-61810a223530	    ],	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
55c34039-9730-474d-86de-fd9cd638aaa1	    "total": 1	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
59643ad0-d56d-4f97-aa03-10d89d688552	  }	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
161c8259-4038-472b-bba5-5a975b4a3358	}	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
4e743473-1dd3-42ea-8580-c2a5486299a3	Record available @ https://play.dhis2.org/dev/api/api/trackedEntityInstances/rQMXWmJN5B8	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
76681758-1cec-4583-8212-502b80ad79d0	[R/T] ✔ Operation 1 complete in 1.637s	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
1b058b86-17fb-4625-babd-e81d486d51b3	[CLI] ✔ Writing output to /tmp/output-1690925492-7-1qsvqo.json	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
bc5e837c-2cbf-458c-a217-d1c321630e76	[CLI] ✔ Done in 2.062s! ✨	\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
2d522f6f-8a65-4df5-bd2a-d62d0e0d74e2		\N	6c732f1d-9591-4074-bd3a-e8c529a43a22	2023-08-01 21:31:36
94c1d835-e147-4725-8273-d78ac7106829	[CLI] ℹ Versions:	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
cfb4d38b-079d-4117-bc1c-f9b5dca706ab	         ▸ node.js                   18.12.0	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
24de2d92-46a5-4502-a401-9294d9217ff8	         ▸ cli                       0.0.35	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
6750c143-9984-43ae-80b3-b1dcbac50117	         ▸ runtime                   0.0.21	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
45458707-a7ba-4e0d-ada2-e38ec20917e5	         ▸ compiler                  0.0.29	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
25b7a530-2a60-4a84-bdee-6700939e86c5	         ▸ @openfn/language-dhis2    4.0.2	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
95e27bcb-6117-4420-9ef8-29b305e996ea	[CLI] ✔ Loaded state from /tmp/state-1690925592-7-v2efis.json	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
a24cb55b-7639-42fa-8784-335263b1983d	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
c001494c-9670-4be2-a9c7-89140639ebf4	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0b066e54-a3c9-4ddf-bbd0-a81bf7ca5b2e	[CLI] ✔ Compiled job from /tmp/expression-1690925592-7-1vnnseg.js	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
4815dc14-a674-40c9-8d73-6442d4e461c1	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
21d62f39-20bd-4820-802f-763284381b35	Preparing create operation...	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
cc7f8f97-2aa2-42c1-b77a-306b54becde0	Using latest available version of the DHIS2 api on this server.	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
ff0b7123-2391-4d61-bd32-132117812b8d	Sending post request to https://play.dhis2.org/dev/api/trackedEntityInstances	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
65e72391-3c1b-4e11-8fa6-51a337647fd8	{	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
cd8578a6-6318-4242-a9ea-1238711409ab	  "httpStatus": "Conflict",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
062d918e-0c03-43ef-a159-5b8f8654b20c	  "httpStatusCode": 409,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
584efb16-0cec-4348-ac07-f6b7923949eb	  "status": "ERROR",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f75a0ed6-701f-4571-b08c-ba1b5745ac10	  "message": "An error occurred, please check import summary.",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
850eb04a-4fe6-4b17-929d-61fefec74b66	  "response": {	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
49e76f5e-4cd5-4164-8e0d-4d1b6f781521	    "responseType": "ImportSummaries",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f848fc61-748c-408e-96e2-d21707647d58	    "status": "ERROR",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
9f49ee5b-7748-4e53-a62e-3c4131490b5d	    "imported": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f4da85bc-85af-434f-b3ea-2084af3bb00d	    "updated": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
8811a3cc-ab1b-4012-94af-c464fe4cb28f	    "deleted": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
da2c43bc-e2b8-47bc-a8c8-8bae7994b375	    "ignored": 1,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
cc43ec43-730f-45c9-8473-411ebdabcbe6	    "importOptions": {	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
7414c773-5c43-4b75-a6fd-38e2b3782525	      "idSchemes": {},	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
3d2f4f06-0850-454a-ae81-c50a1bf52e40	      "dryRun": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f17e87ce-e955-4963-a79a-d36448488bc6	      "async": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
5ad93b0e-6319-4dbd-affa-c5075f0604b7	      "importStrategy": "CREATE_AND_UPDATE",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
dc20be59-6fc4-4450-bd53-cfaf6d2f5491	      "mergeMode": "REPLACE",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f83d168b-75e8-4075-8f19-cb7b8402917f	      "reportMode": "FULL",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
7b13ca4f-4291-4576-a976-7e9b85a50827	      "skipExistingCheck": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
bafed905-2096-4852-9823-4a586dd77a4c	      "sharing": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0b99a9b5-0bb9-4866-a091-ce4fbc229be5	      "skipNotifications": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0dbcac21-165d-4a9b-9317-2c2edde82f68	      "skipAudit": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
211a5f1b-5e40-4323-b069-1d598a4b8bdb	      "datasetAllowsPeriods": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
76659a3a-49fd-4d01-bf12-567298bb3a92	      "strictPeriods": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
8214ddf5-9888-4d41-9c43-ab457de3d00a	      "strictDataElements": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
92b2b1f0-d03f-4230-8b24-80c086483f3c	      "strictCategoryOptionCombos": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
489adfe5-21d7-4c3a-b59d-c31b913b18e4	      "strictAttributeOptionCombos": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
8f95e0ca-072e-4d72-88c3-5eda40bab046	      "strictOrganisationUnits": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0b336d98-d65e-4b28-8090-0acca8c10241	      "strictDataSetApproval": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
d0979607-b68d-419c-8b6e-8be0ced0bd16	      "strictDataSetLocking": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
b58dc516-3c3a-45b3-8d5b-8fb222a87dcd	      "strictDataSetInputPeriods": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
b435cb7d-8acb-4abb-b1c2-4c2ba6f818a0	      "requireCategoryOptionCombo": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0d0cd68a-a30d-4561-9d6c-2b480f0daba8	      "requireAttributeOptionCombo": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
d4423cbb-caa4-4ec3-ad34-997e34bd985a	      "skipPatternValidation": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
9625392a-6d4f-4d04-8b9d-5eb5bdf9d111	      "ignoreEmptyCollection": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
9dd746bd-7ce1-4997-ae4e-d6725b509989	      "force": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
a8740417-049b-4572-8447-f618c0c3bfd6	      "firstRowIsHeader": true,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
7d3afdab-0af8-484c-a94a-b5103805b5a7	      "skipLastUpdated": true,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
d8e4e708-0f9a-4c8e-a532-a58cc90265a5	      "mergeDataValues": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
5f6e8454-b8a1-4470-98e8-4b42aab80a92	      "skipCache": false	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
ee426207-242e-4724-9a1b-392aec726034	    },	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
962ca8bd-2b69-46ce-b377-9ca036f0246e	    "importSummaries": [	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
793cfa16-7834-4811-a8be-93613e71899b	      {	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
a12bf4da-5db5-4480-9b97-1a73369a2d3d	        "responseType": "ImportSummary",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
097cfbb9-b30b-4fa8-98d1-235283cca5b9	        "status": "ERROR",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
bc276afc-1cfb-40f6-b8da-e2dab4e50389	        "importOptions": {	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
b14917e6-466a-469b-982c-a6d45555b9da	          "idSchemes": {},	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
2b2a6e45-4975-4549-85e8-f2ae496ada52	          "dryRun": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
362ddabe-5852-4c65-b14d-dbaafc47f2dc	          "async": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
4c1c0a4e-ccab-4c3c-8f14-b9c803a0aa41	          "importStrategy": "CREATE_AND_UPDATE",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
9973f78e-2415-4627-88b5-fa845ca4a064	          "mergeMode": "REPLACE",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
99111444-0841-4c0e-87fb-98387424cb07	          "reportMode": "FULL",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0c9bba89-a7ad-4099-96d2-6602a78e8b93	          "skipExistingCheck": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
d905478e-8305-42c6-aadd-b4f787fcb31d	          "sharing": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f058b6c9-406f-4894-b7d9-534d04742993	          "skipNotifications": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
dc7729aa-bf2d-4e50-abe9-53d5051242a1	          "skipAudit": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
3a75bfbb-6874-4cff-9450-cc7dda3c64bc	          "datasetAllowsPeriods": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
35f59730-e282-4f47-9d57-d40b4370f938	          "strictPeriods": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0bc7106a-01a7-488a-accd-2deeb47eb6f8	          "strictDataElements": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
59e4ee0a-73b6-4738-bdc8-a43f32962a20	          "strictCategoryOptionCombos": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
98228d8f-560b-4ed1-88df-a567a473258e	          "strictAttributeOptionCombos": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
56907768-386a-4178-abec-6f870f3ba9e8	          "strictOrganisationUnits": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
7145c79c-34a7-489b-b8a4-7eecb098ef69	          "strictDataSetApproval": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0a1345a3-7ef2-4d15-9481-b4f6e82b9837	          "strictDataSetLocking": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
4f08a93b-4a0e-4cde-a2d0-1f9ec33d75f8	          "strictDataSetInputPeriods": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
0b2070bd-39c9-45c9-ba9d-5b94137e1c94	          "requireCategoryOptionCombo": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
a80f47c3-163c-4eea-a389-1425bfe24454	          "requireAttributeOptionCombo": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
cb967832-626b-4a27-8332-c8b48ab2584e	          "skipPatternValidation": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
882eb80b-5e7f-4715-a1a3-eaa92f1140db	          "ignoreEmptyCollection": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
6df563fd-9fcc-4a76-9607-824c3cb83508	          "force": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
3ad362cd-ed26-4450-8aab-993406a4fe60	          "firstRowIsHeader": true,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
d562ae68-b2fe-4384-a52a-034ecc5b866a	          "skipLastUpdated": true,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
483932ef-a9cf-4cdb-923f-877936517c8c	          "mergeDataValues": false,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
6e7db1d1-0cce-40d9-8836-dcd7d0ad81be	          "skipCache": false	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
3850482f-acc3-4b59-89dc-2e899f9c2976	        },	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
315bbbb5-d2a6-4c55-82db-65bfeb675b89	        "importCount": {	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
44a24641-1748-43af-adad-84a80522e9c7	          "imported": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
8a6046c7-9e9e-43c6-bb63-802dfbd4e27f	          "updated": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
59fc95cb-3ac8-4d9a-abc5-af9409188e55	          "ignored": 1,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
e1f08d6c-bd2b-4156-90e9-f9848bab2f5b	          "deleted": 0	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
3619750d-d58e-4548-8e38-a00171e948b2	        },	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
d3f941a3-1ef7-4a93-a49b-b9a50ed3a733	        "conflicts": [	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
e0e6ee5b-cc8b-45c3-a5e4-56d21b979fb6	          {	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f886f356-9102-4422-847e-5a150ff0ed48	            "object": "TrackedEntity.trackedEntityType",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
bb08a972-a0b6-4b90-959b-44224bbdd560	            "value": "Invalid trackedEntityType JVM5Uk0gCDI"	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
ba3b0c76-91b5-49e0-b848-e6a8dba09333	          }	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f93502df-8d35-4838-9d06-7151799b29b9	        ],	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
41740a9c-8f17-4562-9e4e-08f27edb7449	        "rejectedIndexes": [],	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
bea08bea-b8e8-482f-b3ac-6e48c0509194	        "enrollments": {	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
bdb0caa9-1c9f-40e1-90c6-0f8991712715	          "responseType": "ImportSummaries",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
72f36c7c-9137-415d-a161-76ee21da61b0	          "status": "SUCCESS",	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
40731a33-c845-4581-aef6-1e0a0307e199	          "imported": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
b0aab68f-bee1-4d29-885b-b71988743421	          "updated": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
f9154467-e662-4f94-a3c7-a5e2f17d82fc	          "deleted": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
596b4609-97b3-44ab-b1f1-77bc71f938fb	          "ignored": 0,	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
04f62834-679f-4c67-a45c-7a6f3c815adf	          "importSummaries": [],	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
d0cf2175-b6d4-45ad-83d5-12ce7d3f5b82	          "total": 0	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
1faf3a4a-efb5-4667-acd3-b63bc1993e7c	        }	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
fe9644cd-cb38-4ed5-a8a6-872b0ead4815	      }	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
3f6e2f51-58c9-400e-b0ff-4d5d93b64e24	    ],	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
705be6e8-1ae8-40a4-ba8b-0723c0fee075	    "total": 1	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
a5389ba3-933d-4d3e-9961-f384cf92b4c5	  }	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
05f1f43c-fec7-455a-8718-400ebbd159d7	}	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
227a9e2b-c927-42d6-b82b-b6eb68aa3484	✗ Error at Tue Aug 01 2023 21:33:16 GMT+0000 (Coordinated Universal Time):	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
75d0f072-b3f4-4c0e-8780-23ea7ac9671c	∟ Request failed with status code 409	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
6aa115c2-420a-4b78-aa8f-083bce343bb3	[R/T] ✘ Error in runtime execution!	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
1f7a0146-9f16-4c4b-853a-22d70eeb36fa	[R/T] ✘ [object Object]	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
d7c4b6b8-5299-421e-9477-3d9f2d57c19b	[CLI] ✘ Error: runtime exception	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
b1ed01df-c505-4186-81f8-ec0ace5132b4	[CLI] ✘ Took 2.938s.	\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
e0fbab70-cf70-4939-973a-e9252696aa5e		\N	87e74ebd-ef35-45aa-9832-381bb2285ebf	2023-08-01 21:33:16
34192493-3440-41a1-93f7-e7990e07aa38	[CLI] ℹ Versions:	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
3810345c-ebca-4571-bc0c-2ace1a6b40fc	         ▸ node.js                   18.12.0	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
0c2c87b6-22bc-4781-9647-9f0fcef2385f	         ▸ cli                       0.0.35	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
f0571e44-2e86-42cb-9ad5-83b2cdafb7d3	         ▸ runtime                   0.0.21	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
37459235-0235-47d7-81e8-10e5bb2b6f8f	         ▸ compiler                  0.0.29	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
35888380-fc1f-4ff4-a570-ba0f70ce5c8c	         ▸ @openfn/language-dhis2    4.0.2	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
21fb8844-6634-4b5e-a54e-17c97dd76842	[CLI] ✔ Loaded state from /tmp/state-1690925733-7-y1vbp6.json	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
0e2beb14-bee8-43ee-8e33-4f991d755b53	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
077b50b7-381b-44ab-8710-0d6d71d2e7de	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
625fd4ae-e6a1-4b5a-bfcc-d245b352c7cb	[CLI] ✔ Compiled job from /tmp/expression-1690925733-7-dsb7in.js	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
bc841b7f-fb8e-42d9-9057-167276b19688	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
a59c1cd6-cda1-41ed-acb2-2c38e90f19ee	Preparing create operation...	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
cc55327a-5597-4f51-86e2-ab4c5ae526a4	Using latest available version of the DHIS2 api on this server.	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
65c5c773-c5d3-4216-884e-b930d375f5c0	Sending post request to https://play.dhis2.org/dev/api/trackedEntityInstances	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
d1f4402c-69ff-4bf2-9a30-5fc80e3734e8	{	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
06fbb6bf-6cf7-45db-ba18-9dd24a35cb6a	  "httpStatus": "Conflict",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
601caa82-abf5-4ee3-b64e-e75032f423c0	  "httpStatusCode": 409,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
dac799ab-869a-4964-bcda-c9ad14d3bd01	  "status": "ERROR",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
6e8db31f-0464-4a92-86fe-96050ea32814	  "message": "An error occurred, please check import summary.",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
23fc5ac9-4413-4f95-a32a-fc2dbab99f74	  "response": {	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
3b945292-fe86-4a2a-854c-3ca96eb5d17d	    "responseType": "ImportSummaries",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
67b56574-0344-4383-bba3-edd5f3080bf5	    "status": "ERROR",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
04c5b006-83a1-47b5-94b3-7f39d041317a	    "imported": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
16bdc888-ae14-4a78-a100-8a805b1191e9	    "updated": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
304b45b0-ddb8-4db0-a011-5ac4586a7cde	    "deleted": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
dd0372d9-1043-4f4c-b5d0-da60ee8d7094	    "ignored": 1,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
5a5b4ddc-7ca5-4231-afe3-6beeb25c7e2e	    "importOptions": {	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
fe94541e-486d-4600-8496-026ed1c55c82	      "idSchemes": {},	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
5cea40fe-9a9c-4cf4-b047-e75d8a8f70c2	      "dryRun": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
632c552d-5071-486b-9323-90924c09107d	      "async": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
5e15c98f-dd77-404e-a9ec-153a99de2ce1	      "importStrategy": "CREATE_AND_UPDATE",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
a1e130e4-08f6-4af1-8bc1-dfecde7efc91	      "mergeMode": "REPLACE",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
5d0f6be7-470a-4b8b-8f0d-38ecd6886d19	      "reportMode": "FULL",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
204aa17c-7599-4127-970e-e383b5f94659	      "skipExistingCheck": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
3ae2827a-b305-4b25-8f71-ee320d447853	      "sharing": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
b6223ef8-af75-4786-827d-c0716da69e74	      "skipNotifications": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
839e2ba5-fcae-41a4-a870-d7211c2aeedc	      "skipAudit": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
50615904-a288-45ef-9b55-8f8e58445e14	      "datasetAllowsPeriods": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
7e54517f-4567-4862-8898-c2f1e14750bf	      "strictPeriods": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
559326dd-167f-4990-9043-65db54067648	      "strictDataElements": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
e1f5dd47-c469-4bf7-bff1-90d42dbe9c96	      "strictCategoryOptionCombos": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
10f69dae-30d7-4484-8f7e-00fb8acd621e	      "strictAttributeOptionCombos": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
5e2dabcb-89cb-4441-ba1b-c58252ae33fd	      "strictOrganisationUnits": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
dfb4399b-dd6e-42a6-bdbd-319efd53a747	      "strictDataSetApproval": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
40741bd6-4b47-4234-a17f-33aa884e1049	      "strictDataSetLocking": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
952b0984-190b-4aaa-b99a-ad181859f9b7	      "strictDataSetInputPeriods": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
99a6df36-399f-4c6e-ab1d-b7fada182324	      "requireCategoryOptionCombo": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
f053e421-673e-4c68-97ef-ac1f6fcaaa28	      "requireAttributeOptionCombo": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
3bab5e76-293c-4630-aab3-fb49687fc86a	      "skipPatternValidation": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
b4619c66-8365-4094-bb3e-4cbe7579cd78	      "ignoreEmptyCollection": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
00dedd2d-336c-488b-9d53-926b997d058c	      "force": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
46645df8-9d43-4882-95f1-44cbceb6c1ff	      "firstRowIsHeader": true,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
1b631631-efc1-4e3e-b589-6c310a1ca6c5	      "skipLastUpdated": true,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
78d003c6-f568-45a2-8d4a-9cce42290823	      "mergeDataValues": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
b0ba95cb-255e-46a6-973f-a58e1054f695	      "skipCache": false	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
2ddb2618-5a11-4b2e-8ba9-c5b98812c057	    },	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
da702a4e-8b1f-4d35-a468-8ac841852a5b	    "importSummaries": [	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
9039f1ba-3d26-432e-b802-8abaa1404179	      {	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
04fa61d3-c9c4-4ee1-9f85-8bf8f8682341	        "responseType": "ImportSummary",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
5e0a04d2-546d-4fe2-93d5-c14e29ab4993	        "status": "ERROR",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
0f546f43-dc88-46b4-9284-765e8bf19756	        "importOptions": {	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
cd2db1fc-cc51-4002-8f0b-c9955dd26b6e	          "idSchemes": {},	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
951e12b4-e813-4148-9baf-207e187a930d	          "dryRun": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
4902e21e-f9f6-4aff-a65a-2a3e2fe2cbd5	          "async": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
c3b8003e-32f2-4852-b060-145661d38359	          "importStrategy": "CREATE_AND_UPDATE",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
651f998b-6818-4469-88f0-fc31f134f85c	          "mergeMode": "REPLACE",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
3018e949-8c31-44ca-a21f-4c7ae314bf3d	          "reportMode": "FULL",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
b0b05c2e-4b91-49d6-ad49-cd67000659f6	          "skipExistingCheck": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
ce333d06-957a-44d2-9634-dabec8a18b19	          "sharing": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
8967446d-7ef8-4629-9be9-ff1701855677	          "skipNotifications": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
19c954ed-8926-4b3d-a08d-cafc49f27f7e	          "skipAudit": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
fd789bd1-5c26-4352-9b84-4a4be9275d13	          "datasetAllowsPeriods": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
23437eed-b90e-4aa1-888c-b2cf7a2cf606	          "strictPeriods": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
cdc91192-4169-4016-aff2-8b59ad5e99f6	          "strictDataElements": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
31dd5892-4adf-4822-bd06-4221ccd27ff8	          "strictCategoryOptionCombos": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
35d539c9-5d2c-423b-a1cc-e9ada0f5b6f2	          "strictAttributeOptionCombos": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
3b1b3ddf-ea82-410a-8635-decc3da95a25	          "strictOrganisationUnits": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
83de8d94-f3c2-4f70-bdd0-79157860c97b	          "strictDataSetApproval": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
7653aee1-5cc2-4297-8e9f-d7f4f57d4f29	          "strictDataSetLocking": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
425769ef-b942-48d5-8032-428a040b0606	          "strictDataSetInputPeriods": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
b971bc03-0756-4ded-a3f6-2a45666c6e0f	          "requireCategoryOptionCombo": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
df4fe90a-7081-4057-8785-03c56536d5e9	          "requireAttributeOptionCombo": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
dda8de08-42c8-4fca-9d46-06b60919a50b	          "skipPatternValidation": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
55158101-6483-49e6-94eb-e0587b3515ef	          "ignoreEmptyCollection": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
afd359e4-876d-494c-9420-e78aa0130183	          "force": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
56a1b207-7355-4b78-ba71-f10682a2e77a	          "firstRowIsHeader": true,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
394f26d7-0c24-4c14-9256-561972b83251	          "skipLastUpdated": true,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
c8e7cb19-a6ba-4f88-b723-043149ebd43b	          "mergeDataValues": false,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
93fc1f45-ffe4-477b-adf0-1d023df992af	          "skipCache": false	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
18156bb5-4f82-41e9-b389-a79c5f5c4629	        },	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
04047141-235a-4b26-b156-8cce44b42aa3	        "importCount": {	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
d728a09d-cab4-4fa4-9aaa-1050da2285ce	          "imported": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
2b654fd4-7fa6-4c84-a13c-a1d63ee561ce	          "updated": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
3e469978-ad36-4707-98cd-e34552ca77df	          "ignored": 1,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
ccb741a5-8beb-43e2-84b4-e12e0f91a00d	          "deleted": 0	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
c0faea10-19da-4b3f-a315-17a295ed11ef	        },	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
9c183812-0d23-4686-badc-e07834d7e058	        "conflicts": [	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
825cd74c-012d-47f6-adb4-8ecb0da59884	          {	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
9bc668d1-2aeb-465b-a60f-2752967bb636	            "object": "TrackedEntity.trackedEntityType",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
e4a56c23-c643-47cb-9ac0-323dc831b3db	            "value": "Invalid trackedEntityType JVM5Uk0gCDI"	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
ce5ec1df-1e22-4c08-8672-6d392a1fda65	          }	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
c7f0db78-b72b-4203-a8b8-c2293e5238f0	        ],	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
218a5e33-69a0-4aee-a0ef-d34f2e6b2701	        "rejectedIndexes": [],	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
cae0a801-6a37-447b-84c6-bb866d5935c4	        "enrollments": {	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
1390c412-1f28-4ff5-bd8d-b16a012b3004	          "responseType": "ImportSummaries",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
ff70ecbf-9081-4055-995a-6c1c932a0936	          "status": "SUCCESS",	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
3af4950a-dc05-43b2-904e-8a9b2ba14314	          "imported": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
97c5664d-a433-41d8-b894-bd7c178b6d3a	          "updated": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
b2371753-8dcd-4c87-97df-b086e0c27a29	          "deleted": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
c3d1cb5e-3c59-473b-adb7-f1a57a3d52ae	          "ignored": 0,	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
555bccc5-d3a0-4658-bc73-76eea9aca553	          "importSummaries": [],	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
89af4512-aaa1-48fd-98df-da0cb66bb335	          "total": 0	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
2a4017b9-b453-4eac-a4f1-e889b50c9a3e	        }	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
771129c8-8b52-49ec-85c8-8dcdf0f955e1	      }	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
feb4f21e-2544-4db1-b040-0ea483a41ca3	    ],	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
6e270e36-a777-49a9-a6dd-4768e84e53a8	    "total": 1	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
8ad2c7fe-9366-484a-8538-b9d1959432bb	  }	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
2ad62fec-88c5-42ab-a905-aab286dd131a	}	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
169458d5-b610-4d73-a4a5-83c8f71e6d45	✗ Error at Tue Aug 01 2023 21:35:35 GMT+0000 (Coordinated Universal Time):	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
bb8d33cd-b36e-48bc-8fde-7e717615149d	∟ Request failed with status code 409	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
8153abfc-5e33-440d-986d-976514f504d1	[R/T] ✘ Error in runtime execution!	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
06667209-e2f7-4d3a-b500-8da54e3f1bc5	[R/T] ✘ [object Object]	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
d2944edb-1cd5-4000-8b33-51193d33c255	[CLI] ✘ Error: runtime exception	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
aed09041-ca2c-43f3-b5fc-39fc2a538548	[CLI] ✘ Took 1.61s.	\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
e0122cee-6c0f-4b83-8915-e653deed1d36		\N	741ea16f-bc86-4e86-959f-8c8e88ab05d4	2023-08-01 21:35:36
c474710a-1c3b-4216-a7d2-1710ada281bb	[CLI] ℹ Versions:	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
b5ec9628-b268-4232-b2f9-246f8cca9a87	         ▸ node.js                   18.12.0	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
8a822271-7b83-4e11-992d-8c189c9cb642	         ▸ cli                       0.0.35	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
6fdda4af-6de7-46af-8615-07ca28332043	         ▸ runtime                   0.0.21	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
9178a897-b69e-47f5-9152-7c73923c6c3a	         ▸ compiler                  0.0.29	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
d574b766-c09f-4572-99aa-a976eb68a5e8	         ▸ @openfn/language-dhis2    4.0.2	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
9a761849-041e-41e6-9d15-b857418315a0	[CLI] ✔ Loaded state from /tmp/state-1690925899-7-17vrrfh.json	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
b309e6b4-a934-4964-8b77-12eb915134aa	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
500be10d-eb30-45e3-87a8-96eb5853bb98	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
5037170b-d1a9-496b-b1a9-06de6f71ae72	[CLI] ✔ Compiled job from /tmp/expression-1690925899-7-poju3k.js	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
d37094c0-322e-4d54-ba84-3aaecbea2392	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
8b3282f0-3021-452f-bd10-dcf765ace985	Preparing create operation...	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
b2cf00e9-0a36-42bd-b797-c0d5f437e9f8	Using latest available version of the DHIS2 api on this server.	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
54d75872-b4d0-4eca-b0d6-c97565c7e6ff	Sending post request to https://play.dhis2.org/dev/api/trackedEntityInstances	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
94412f00-afe3-4070-9312-d2f5478ffe50	{	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
b7b09794-6fe0-46d6-952f-7b3701f788aa	  "httpStatus": "Conflict",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
bd8e55a3-dba5-4d77-8dfb-94af2895e496	  "httpStatusCode": 409,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
3f3c3616-71e6-4b3f-8049-6c7cbb67a7ff	  "status": "ERROR",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
f987c7d3-899c-4218-bfd7-eabf83c0b713	  "message": "An error occurred, please check import summary.",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
6ed19bd1-191c-41d8-b22f-8e6febf1cfc2	  "response": {	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
4a197251-d8b5-49df-b74b-8fb575676e5d	    "responseType": "ImportSummaries",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
7dce1eaf-7227-4129-b207-9fa5f9965daf	    "status": "ERROR",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
124f5eaa-de21-46f4-9397-b6aabb215d06	    "imported": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
da045899-d7bc-4fbf-aae8-5ec238873d32	    "updated": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1ca30333-c170-4bc7-940c-dd3660d0974b	    "deleted": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
a99d6839-2288-4d7a-bb9e-50615190911a	    "ignored": 1,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
7224d79b-9d83-4785-81d3-2890018a0721	    "importOptions": {	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
8eacce19-20e8-4758-b53d-961f2eb3b36c	      "idSchemes": {},	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
ac922fdf-9329-4968-bf68-7815e1d1ae43	      "dryRun": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
f6aea248-929b-4bc5-963b-01028e56f407	      "async": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
0ebeea93-6120-4284-84f4-5ff52da19114	      "importStrategy": "CREATE_AND_UPDATE",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
b6d31776-5f30-43bb-b471-8ea4bc4dce87	      "mergeMode": "REPLACE",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
bbe0e92c-eeb4-46c2-ad8f-d94ebe731bb2	      "reportMode": "FULL",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
f385df7b-a7fd-41f5-b05d-bca7baf5de07	      "skipExistingCheck": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
909c2b2e-2bcc-4acf-a1fe-a3dac47bebb2	      "sharing": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
78d0b268-1cb6-4e7c-abb0-babd84bfbf3c	      "skipNotifications": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
4d45949e-0863-4b2e-b59a-85367089e05a	      "skipAudit": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
fb39e459-b1a1-4676-8247-cb88fe850ffc	      "datasetAllowsPeriods": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
d05ccd6c-4b61-4722-ad23-2b4858201ecc	      "strictPeriods": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
de471953-e2e5-4aa0-9374-4cbd96728e46	      "strictDataElements": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
b40fa28e-27b6-49f8-a6f7-6a6e0488e74a	      "strictCategoryOptionCombos": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
c6d5bbe4-9adb-4023-bdd4-40f1221bb7b3	      "strictAttributeOptionCombos": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
a5bc2b5c-fd70-461f-b19e-a4a82af3e416	      "strictOrganisationUnits": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
e798a524-5eeb-4924-8b58-ebeeba320242	      "strictDataSetApproval": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
60088440-3e7f-49bc-ac76-aae5a3df3851	      "strictDataSetLocking": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
da7bbef7-94af-4019-b19a-77f87b5d4464	      "strictDataSetInputPeriods": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1bfd6263-b591-4f4e-98b4-d99aa989bf89	      "requireCategoryOptionCombo": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
85296dbb-260f-4c67-ada7-05376b61e09e	      "requireAttributeOptionCombo": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
6faa5da1-91e3-4ea5-b60b-5225f6b4098b	      "skipPatternValidation": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
3e6e8f39-8531-4678-ad71-1fa1ceead2a8	      "ignoreEmptyCollection": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1af5f983-e72d-4bc8-8b31-f1e28dbe80e1	      "force": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
76f04ccd-1b39-4b05-8cc7-88570b1bd96b	      "firstRowIsHeader": true,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
7d31c589-fe14-4bb7-9e17-88594e6132f3	      "skipLastUpdated": true,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
20a264cd-821c-48dd-be51-e860a87d6aa5	      "mergeDataValues": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1ce063b7-bc5b-4377-a136-6b31cfc5d8a3	      "skipCache": false	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
49b4978e-0729-4552-bf1c-9bec11d25e31	    },	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
74ba215a-50cd-409e-9349-acb9b799497b	    "importSummaries": [	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
9eb7cbde-7e6c-484a-a49b-10fcab612dcb	      {	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
42a95345-40c5-4754-89e0-08d6601f63b5	        "responseType": "ImportSummary",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
21af49b0-99e4-415e-9679-c5337b43242b	        "status": "ERROR",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
23290f57-99c5-438f-b599-210d84add846	        "importOptions": {	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
72ce6dc8-9577-4c3a-92c7-b6d80c471261	          "idSchemes": {},	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
ffefe704-9e5f-4075-984a-a0e36fe8e0ef	          "dryRun": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
c7d67910-fdad-4cf8-93ba-80f6ca69dbe7	          "async": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1940782d-9b48-4c30-90dd-281aa03788ea	          "importStrategy": "CREATE_AND_UPDATE",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
b75d7a1b-f714-4d83-899b-7558763115bf	          "mergeMode": "REPLACE",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
32d25d76-bd9e-4e9b-9e97-846ac9cd2db8	          "reportMode": "FULL",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
ac6058b6-3fc3-49f3-86e1-b2336186441d	          "skipExistingCheck": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
fba6102f-1a1d-43c8-9fb4-96e009963d69	          "sharing": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
8325c711-242e-46dd-a0ef-ae7e43d7e76b	          "skipNotifications": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1649ed42-ca64-4a85-89c5-3d2cfcf2b180	          "skipAudit": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
3734e248-1535-420c-9fef-a5537aa7d551	          "datasetAllowsPeriods": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
9e1bcb12-d4dd-4b99-b755-372b5e9e6fc6	          "strictPeriods": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
e9c4faee-ee87-4ebf-baf2-f7988b1af802	          "strictDataElements": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
51acf951-fb74-4bc2-a29b-74dfe80ec7d8	          "strictCategoryOptionCombos": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
0d90e471-7994-4808-a8e7-c833d2e658b2	          "strictAttributeOptionCombos": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
0d62ec2a-4ac7-48e2-870a-3ac6fe87522d	          "strictOrganisationUnits": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
e52e31f8-5236-4525-864f-e94b7bfbfb29	          "strictDataSetApproval": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1b9ae4ed-c13d-44a0-ba7d-9550596bc15e	          "strictDataSetLocking": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
5d4bac4d-502d-4984-a3f6-b14abacdf698	          "strictDataSetInputPeriods": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
056ce3f4-daad-429b-97f7-036be1a8f936	          "requireCategoryOptionCombo": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
ff030f26-56df-4b8c-b708-927ba4fe6413	          "requireAttributeOptionCombo": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1100b7ea-269e-472c-88ed-109a6d68e215	          "skipPatternValidation": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
cbe75b41-9c65-42f0-a19c-f619cf0f5d50	          "ignoreEmptyCollection": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
5f4bde8b-b644-4494-8c0a-69e18a8dcb33	          "force": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
54cc60f5-fd52-4f1a-b4d9-389327d80544	          "firstRowIsHeader": true,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
3147c8f5-2c27-4463-89d7-93c066f53c9c	          "skipLastUpdated": true,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
c948b8d5-fc41-43b3-95a6-beb2bb327d91	          "mergeDataValues": false,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
818f0ab0-338c-44e1-afff-a25ed71526fc	          "skipCache": false	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
83f6154b-9a11-404f-860c-11fda57bb835	        },	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
d5a3ad29-03a0-4d63-b1eb-eae2842a5aa7	        "importCount": {	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1c4e49fe-064d-4ee7-98b2-499abadb8f4f	          "imported": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
c9146360-2f76-4b6a-addc-aa4eada4cb82	          "updated": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
af64af32-ab3e-4f6b-94a1-e672eaa04fe2	          "ignored": 1,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
1de45418-3d8b-4877-a44c-e6b37ea994a4	          "deleted": 0	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
4642bdf3-00c3-4e9b-a465-18027bb22b7c	        },	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
f7139fd1-c7ec-4bc8-940f-2ae4372a6910	        "conflicts": [	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
a6a12a8e-4c4b-463a-807d-8aa3732f26f2	          {	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
ee114313-37a5-43d9-9e63-4f312e641ce1	            "object": "TrackedEntity.trackedEntityType",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
55b62863-d6aa-4f2e-8b7e-d1de39813d31	            "value": "Invalid trackedEntityType JVM5Uk0gCDI"	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
d0413d56-fa52-4368-b316-a7a602d7ca70	          },	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
3364fa55-9944-4c10-93c3-2701c53122e5	          {	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
ccd7ade2-27f6-44e5-8d19-5efb352d405b	            "object": "Attribute.attribute",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
63ba13a4-4734-4b8d-ab51-a1debaefbd80	            "value": "Invalid attribute rFuwsxo7uGH"	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
e4d7c61f-6afb-4d0a-b871-d65fccdcf2ba	          }	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
0f3ba9f1-c9a9-4357-abd4-bae22eface7f	        ],	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
3eb0c897-0c49-40ba-998e-2f35b9a7a62a	        "rejectedIndexes": [],	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
57099934-e15d-4bdf-8f1f-4110bddeba90	        "enrollments": {	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
e46da616-b9c6-4834-a669-175bf55ecb1c	          "responseType": "ImportSummaries",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
ae88b411-c58e-45cf-bae1-14751fd0664b	          "status": "SUCCESS",	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
33f1628e-834c-494d-96d8-dff16132a8b6	          "imported": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
b261b5df-0762-4f11-a7ae-307819153549	          "updated": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
484edb49-5381-46d9-835e-3d70d1907ef4	          "deleted": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
809fb98c-f1fe-4504-925f-f6f5ea6e520e	          "ignored": 0,	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
707bf475-0dbb-400b-9b9d-e03bc9c3637e	          "importSummaries": [],	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
be4c31c3-50c1-42bc-892f-baaa57ceb315	          "total": 0	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
ad9d0479-a023-468b-b556-a8c3e6b4e674	        }	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
754a4392-3467-41f2-a6fc-a5a85da38e68	      }	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
0db42ab8-be40-4712-9310-df7142edd304	    ],	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
6428000e-cb8a-4544-9996-15ecef9afbff	    "total": 1	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
2e53adeb-ca15-4f23-8860-792f4e1df249	  }	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
733ecf3d-6635-4853-98cc-3e917dae54c3	}	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
aead74d9-0f6b-454e-b7ab-43e956cfade8	✗ Error at Tue Aug 01 2023 21:38:22 GMT+0000 (Coordinated Universal Time):	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
0d063a40-3e68-42e7-8dde-f37eb06c5ed6	∟ Request failed with status code 409	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
2304079b-fc2d-40b6-8cbe-4854c38364e8	[R/T] ✘ Error in runtime execution!	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
58fd4314-07b4-4ff8-954c-d9e7cd023702	[R/T] ✘ [object Object]	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
4508a980-3d84-474b-af9e-7a24e9cee143	[CLI] ✘ Error: runtime exception	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
21867e3c-901a-4d5c-96c7-d432fe12b285	[CLI] ✘ Took 2.044s.	\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
051a41e0-1bb6-4ac8-8cd3-0de172696eee		\N	3d80923e-fc7a-451d-9826-15c62375ec2f	2023-08-01 21:38:23
e9b6bbba-d28b-4f26-b21a-4c594e513563	[CLI] ℹ Versions:	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
d015adaa-21df-41ed-afaa-e0558740df34	         ▸ node.js                   18.12.0	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
ed573a0d-f945-4472-a8ff-053237b57b8b	         ▸ cli                       0.0.35	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
f8386780-92be-4388-bbbc-818c3f8f7937	         ▸ runtime                   0.0.21	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
3fc307f0-cbbe-4c99-a20d-8b4c522fe3e8	         ▸ compiler                  0.0.29	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
f728f26a-4dbd-49fd-8c1c-ab9efce9fb23	         ▸ @openfn/language-dhis2    4.0.2	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
543eb54f-8880-4e8a-90db-67194051a170	[CLI] ✔ Loaded state from /tmp/state-1690926258-7-4rxtop.json	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
3d351568-eea8-4892-89a7-8fc8fd9c749c	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
4c089460-b818-47ca-90b7-ec3934f7156a	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
9f4187d7-221d-4eec-b4ca-c2d5ebfe66c3	[CLI] ✔ Compiled job from /tmp/expression-1690926258-7-vashc8.js	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
3222a3ed-12a0-43c1-af5b-2c3248ecc057	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
ca31ebf7-65ea-4c72-8b38-49dffb070c0a	Preparing create operation...	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
f1b4f7f3-0412-45ae-89fb-b5fbd1d3facc	Using latest available version of the DHIS2 api on this server.	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
9dd16163-64ee-4b96-8dcc-70a6b163dba9	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
8c876059-5a2a-4fd3-ad59-0ef19e44a9fb	✓ Success at Tue Aug 01 2023 21:44:19 GMT+0000 (Coordinated Universal Time):	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
e0adc12e-1aa0-476d-a0a3-052efd06be6b	∟ Created trackedEntityInstances with response {	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
2af18b52-469d-455a-bb94-5d67e330f1c5	  "httpStatus": "OK",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
abc9bde1-5a29-4227-a187-f4be95653a62	  "httpStatusCode": 200,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
e090bedd-018e-4561-84ae-0db5d5bfad4a	  "status": "OK",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
5851ee16-ecb0-4308-9314-e4bab486ceb8	  "message": "Import was successful.",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
598a1840-1298-4466-8e8d-c963e0658101	  "response": {	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
2375a043-db92-4a32-b252-8aa309dd3edb	    "responseType": "ImportSummaries",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
19092098-4e26-4f26-a291-2cc101bc6cd0	    "status": "SUCCESS",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
ea0cd4f0-6f8a-4914-a50c-6205cabe333d	    "imported": 1,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
93198107-7f8a-4c4b-beb9-d141975b1e18	    "updated": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
656de0df-ee41-4b84-8190-674815e250fd	    "deleted": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
50c145f8-9eef-4f06-862f-eeaf157f7a6f	    "ignored": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
b27dee64-9ede-4a17-a75a-e91362098a78	    "importOptions": {	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
459a8bb1-8fd9-42ab-846c-e7aebf0bcd2c	      "idSchemes": {},	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
76b73ae9-b265-4c4a-bd83-8e5351e4d506	      "dryRun": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
7866510e-314c-4244-9773-4a775d9cd00f	      "async": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
c009a4c4-a7c2-4619-9640-85b8625f2546	      "importStrategy": "CREATE_AND_UPDATE",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
cbaf9835-7a6d-49f9-960c-908fe8db75f4	      "mergeMode": "REPLACE",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
d4505d5d-de4c-4f4e-91cf-3d5a76a4efa4	      "reportMode": "FULL",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
ccee1a19-7e6a-4300-a609-fb7513af89e1	      "skipExistingCheck": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
6ab69863-49ad-4c33-b8be-de5196106f4e	      "sharing": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
81fffb2c-ac5c-4b2e-abcc-82a18d92dbf7	      "skipNotifications": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
1268d923-696f-4604-a245-23941dc569df	      "skipAudit": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
09188f94-a728-416a-a8a3-e672e38cda98	      "datasetAllowsPeriods": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
fb171c95-73f3-4392-9308-4dca8117a1fd	      "strictPeriods": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
8e70b2c1-5716-429b-9833-4a9663fe55c5	      "strictDataElements": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
3c4acb12-bea9-4617-aa05-5f854b499dfa	      "strictCategoryOptionCombos": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
d84919d8-eaae-4894-b3e8-9f65f4ec747a	      "strictAttributeOptionCombos": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
e31c4da1-e7b1-4d79-b204-5b2201847ea8	      "strictOrganisationUnits": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
6f8d0bf6-2254-403e-8e0e-1e4d19530ca8	      "requireCategoryOptionCombo": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
06a9fffb-eeda-4ca7-b939-d0a628706473	      "requireAttributeOptionCombo": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
e6ce61f2-f220-454f-b156-73bfab4a57c7	      "skipPatternValidation": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
b51ad17a-54e5-4dd5-b336-293b4bb4225f	      "ignoreEmptyCollection": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
1c086fd3-98d9-45a2-a961-2c2a7fc2e1ab	      "force": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
ac5522d3-7c47-4784-92dd-72f8639b14c0	      "firstRowIsHeader": true,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
101cc4b7-1fb0-4610-b694-0f9c3db5eb60	      "skipLastUpdated": true,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
5f1ba2ac-54de-45cc-b8f5-879d6ea640b7	      "mergeDataValues": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
acc0a86b-09ad-4e5b-9c32-d3da692641eb	      "skipCache": false	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
13e9de7a-6376-465f-9a8a-6a42d635b74d	    },	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
90066074-c7ab-4c41-ae10-b319908750cc	    "importSummaries": [	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
ada04bd9-7d0f-456d-8266-16be809109f1	      {	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
7e0a084b-c787-4846-9096-0326faa74d63	        "responseType": "ImportSummary",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
a7aea5a4-c0be-46db-b002-86bc1856ac5c	        "status": "SUCCESS",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
0ddf2f62-321d-488e-925a-69218da3880c	        "importOptions": {	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
3efc34a2-148d-44a3-b8b3-8b350bee83e6	          "idSchemes": {},	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
42b390c2-69e4-479f-aba4-4463c18f0a53	          "dryRun": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
0d980a27-b2d9-44a6-adcb-2187155726d2	          "async": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
dc29fefd-649e-4075-9dd6-6bc979404d6f	          "importStrategy": "CREATE_AND_UPDATE",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
b5b1c89c-ba94-43e4-8a92-d839eaee282a	          "mergeMode": "REPLACE",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
cbabba47-b22a-4313-9e66-d1c3f2fa303d	          "reportMode": "FULL",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
4cc30031-286c-47ef-8061-36b507da7bfd	          "skipExistingCheck": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
dbe0985f-d66a-4199-a6b4-1c9624d504ab	          "sharing": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
3210b4fd-2cba-4aa3-8869-c905405c1569	          "skipNotifications": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
03a85459-7b19-4e03-a8c0-485d075a73bf	          "skipAudit": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
70ee95a4-5db1-4a7c-8076-30c49339f1a2	          "datasetAllowsPeriods": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
e4cce505-3736-4f34-a255-d230e12c7fc7	          "strictPeriods": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
7c68500b-0388-4c9d-b5b2-9cd29a861209	          "strictDataElements": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
7d06cc3c-dc3d-4055-96e5-4b4a72f25183	          "strictCategoryOptionCombos": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
c32e538b-12cd-44c1-9c1d-c1e9301a662e	          "strictAttributeOptionCombos": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
41c50866-ee6d-43f9-9827-c904423a6a58	          "strictOrganisationUnits": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
d010a48c-3e59-4875-ba02-d7987bd44522	          "requireCategoryOptionCombo": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
868d0f0b-b2a9-4c58-8203-e243d235d906	          "requireAttributeOptionCombo": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
2c601717-09c9-49b6-9e25-ebfe993fb288	          "skipPatternValidation": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
22234aca-f8dd-4b0d-a39c-d26f26195d22	          "ignoreEmptyCollection": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
b99b0904-8e26-4f4f-a832-25197480b08a	          "force": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
ef9a291b-9109-455b-9127-28c1388d778b	          "firstRowIsHeader": true,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
b772f788-e946-4823-bbdb-053c11997931	          "skipLastUpdated": true,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
68133a75-8f6e-4f9c-a7b5-accd55e205d3	          "mergeDataValues": false,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
2a1a7e4e-2d5d-426a-a065-4e6eb053cee2	          "skipCache": false	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
b49921e4-7685-4b3e-8986-53dfac955dea	        },	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
97620276-6dae-41ac-b1ec-99e4c88268be	        "importCount": {	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
aa7b7f83-c988-4808-ad94-a1ccdd4757c9	          "imported": 1,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
8cec4bcf-31d3-49cf-96f4-cb3e9a54c441	          "updated": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
958cb5f3-cc3e-4fc3-a996-403a0c66ed52	          "ignored": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
023f2012-daaa-453f-b955-21bb3d2ca7f9	          "deleted": 0	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
7c7031a4-4604-4c62-a5d6-66aea68a1bd7	        },	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
301c1735-3b15-4ad1-a305-76baef17ccb9	        "conflicts": [],	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
94758309-b907-4f2d-a2e1-69a9a83f5992	        "reference": "msrM0dODgs2",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
9ac71f34-3347-44da-852c-7a441981bb63	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/msrM0dODgs2",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
8da52420-7ed4-4baf-b482-03a359d74fb3	        "enrollments": {	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
d7787ab9-3da3-4f5d-838d-40819825bb55	          "responseType": "ImportSummaries",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
3fadde5a-e060-46f9-8404-d560c03b2e27	          "status": "SUCCESS",	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
04f859b9-c4b3-46c8-b2f0-9b988e7156fe	          "imported": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
94b7d012-1256-4981-9684-00133ef7c22e	          "updated": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
689cd980-5cfc-4e1f-bd71-5059d85c2921	          "deleted": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
10a4d0dc-bb41-4eea-ad2c-16ccfd06a2c3	          "ignored": 0,	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
cbd2b544-a8a3-4daf-b2aa-be761b2ba7fe	          "importSummaries": [],	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
77e88956-0740-4b68-a6f3-129ed32300a1	          "total": 0	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
1a9a1ba9-5deb-4726-989c-fa89f5b59ba1	        }	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
a147b6df-e50f-4bdf-8d96-2ebe918189f9	      }	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
ed4e1856-5956-43e0-94d0-80b0f0a163e1	    ],	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
82fbf167-3c6c-4d58-90aa-aa1d79698e8b	    "total": 1	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
4fd11a41-6177-40e0-8711-d511e1af3997	  }	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
183bde1f-6626-49f5-9409-d5f100538f56	}	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
e1b2a8c3-c0d5-446a-8159-e940f9c8a095	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/msrM0dODgs2	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
785c821d-c442-4013-8af6-0acace97c54d	[R/T] ✔ Operation 1 complete in 177ms	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
7d355080-cbc5-40e3-a7d1-1903812c3a57	[CLI] ✔ Writing output to /tmp/output-1690926258-7-m8mtwd.json	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
f051ab2f-323d-4adc-9f1d-64328206d738	[CLI] ✔ Done in 595ms! ✨	\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
e93281c2-4e61-42a7-9144-b428dd17aa03		\N	80bdd289-ff67-4d70-8c22-d968cf241201	2023-08-01 21:44:20
f591e8aa-bb55-43e6-9c0e-706e48f9daaa	[CLI] ℹ Versions:	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
dafa38c4-c451-44d2-8528-5e92cf0f81a8	         ▸ node.js                   18.12.0	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
64b43b1c-8136-4cb0-8c54-5115370b1947	         ▸ cli                       0.0.35	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
81e05240-f50a-4682-a8f9-a8a33c5357b8	         ▸ runtime                   0.0.21	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
b1a4e8a4-d1eb-46b8-ad37-5e9b633e2b81	         ▸ compiler                  0.0.29	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
2da1e9e1-9b4d-43be-b676-310a78946847	         ▸ @openfn/language-dhis2    4.0.2	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
a8ae183b-dfae-44b9-acd7-e8093f6eb76b	[CLI] ✔ Loaded state from /tmp/state-1690927224-7-9ytg1e.json	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
11c1c2fd-82ec-4aef-980d-a7d8d089c73e	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
e9d3480a-ec3b-4246-9764-0385a2bb0170	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
7ba38f45-fc8e-44db-b959-399db2e2b30c	[CLI] ✔ Compiled job from /tmp/expression-1690927224-7-15iw2l7.js	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
156c90e3-906e-4129-a6d9-997ff78f2781	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
a0f6a9a6-778d-4633-8383-42b874f10d14	Preparing create operation...	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
df28d6bf-4c39-4ca2-ae08-e2ea4892ae56	Using latest available version of the DHIS2 api on this server.	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
6ea191a1-d06b-4c55-81c0-7f4f1e635985	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
1435642e-d6a4-457f-ad9e-64d8c0688dda	✓ Success at Tue Aug 01 2023 22:00:25 GMT+0000 (Coordinated Universal Time):	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
50ba675c-fee6-4dc7-a1ef-0ee2bd2ce460	∟ Created trackedEntityInstances with response {	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
f3d24680-ba58-4028-a503-6d2b7aae5b95	  "httpStatus": "OK",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
820e5a02-64e8-4f7b-aade-a1be9a6f1373	  "httpStatusCode": 200,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
e957040e-3ff6-4c12-9241-123beef112f1	  "status": "OK",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
8e0ad9aa-c833-4d58-90e5-5ebceffbd941	  "message": "Import was successful.",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
fe1215a7-6f66-4c50-a492-82dc04e0addf	  "response": {	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
e89d0ad4-5e08-42fc-971f-6c148f684abc	    "responseType": "ImportSummaries",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
38ba9f95-07e7-4932-a5bd-f9e9081f1e1e	    "status": "SUCCESS",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
c6b1c9a8-f394-4ba0-8d3b-c2890aa53a7c	    "imported": 1,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
fe54c410-3263-43a8-a2ca-2164e8754319	    "updated": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
04f3af8f-a0c4-44e9-b040-d4a6fa0a78c2	    "deleted": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
f9fac1b3-0433-4e42-b3a7-335b34e28d3b	    "ignored": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
ecf9a7ea-7a21-4477-bd19-45b4bead931c	    "importOptions": {	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
7e6ff2e9-4f4d-4096-a113-4136cc44bd53	      "idSchemes": {},	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
d83bdaeb-6f81-4401-9e5e-bb618e072f5c	      "dryRun": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
f05d1cce-e688-47ed-bf2f-862628559942	      "async": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
be51e6ce-486a-46cf-9970-83979d07f8cc	      "importStrategy": "CREATE_AND_UPDATE",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
6680c04f-3afa-45f5-8fe2-5b2c8d195bca	      "mergeMode": "REPLACE",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
baae58bf-233e-4b3e-b10d-aaac955b166e	      "reportMode": "FULL",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
c9a771c7-660e-47c7-b5f0-2bc05d90a916	      "skipExistingCheck": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
952e11a9-ee06-4447-bfde-f3ee921a7024	      "sharing": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
cea4ac29-b7e8-4fc7-8993-42b13a2e3534	      "skipNotifications": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
5e569db3-4063-47b7-b004-b3967fa252ad	      "skipAudit": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
6bca66e4-ee53-47f0-be74-59c7611211d9	      "datasetAllowsPeriods": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
fb6cac0a-2889-4141-b2b1-3d6ba6989e53	      "strictPeriods": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
c43ae25a-bfad-44bf-adc6-526d0720e3d1	      "strictDataElements": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
b6591817-0e90-471d-983f-da9469ed4b02	      "strictCategoryOptionCombos": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
0405cadf-a973-42bf-a7e5-dea1f63b51c8	      "strictAttributeOptionCombos": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
69545151-7461-450c-a0af-77f9822b5b4f	      "strictOrganisationUnits": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
794c9f5e-c829-4371-860f-2bef96270178	      "requireCategoryOptionCombo": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
80ad7c8e-064f-43dc-a5fc-00e7305342d7	      "requireAttributeOptionCombo": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
992e9c5c-6055-4396-9cbc-8cd4ef9aac1a	      "skipPatternValidation": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
bef81bfc-eec9-409b-ae6d-254793d8e943	      "ignoreEmptyCollection": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
9e649c72-8181-4d36-a0cd-477e03b20fb0	      "force": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
2f4ee114-e2ac-405f-8aef-dd034c1e100f	      "firstRowIsHeader": true,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
89eba1a1-846b-46e1-b524-c4f000b59e79	      "skipLastUpdated": true,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
aa24a261-8b79-47aa-adc0-aaf641e34161	      "mergeDataValues": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
911c72ab-2bb0-413c-9cd2-6b3b5a091da1	      "skipCache": false	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
45cd40de-c292-4eaa-ba4e-d699e0b745ed	    },	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
b7ed4f36-6625-4b43-a884-9d1b402b3360	    "importSummaries": [	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
dce9e629-89e5-4def-965d-996dac39348d	      {	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
d07c3ec0-78e0-42c3-8a7e-dd301d1175e0	        "responseType": "ImportSummary",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
bf9aa930-c1e9-4212-9d61-1909cc10e5d1	        "status": "SUCCESS",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
654cafa4-7aac-400b-9ba5-1970451fb7bf	        "importOptions": {	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
6123741a-1c94-456c-a3df-dc2286390c76	          "idSchemes": {},	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
7e2ddb1d-39cd-4c6f-88d1-8d5965b05430	          "dryRun": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
332cd47a-75af-472b-a1c7-48323b1d6564	          "async": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
14341f56-a146-49cf-b0b8-c6897b8d5454	          "importStrategy": "CREATE_AND_UPDATE",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
0a95c571-638f-4b30-b8f8-3a7e23481aec	          "mergeMode": "REPLACE",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
620286fb-ce3b-4bfc-971f-a3627fee3d17	          "reportMode": "FULL",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
cc9fa300-a141-4a33-9587-378fd169a04a	          "skipExistingCheck": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
df31c130-ff36-4d93-999b-bde94cf1ef86	          "sharing": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
276ab6ca-b317-46ff-82ed-e9a64704cfb9	          "skipNotifications": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
0ab8bc9f-e698-4fb4-8d27-dc182bd94dcd	          "skipAudit": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
b1bc3573-9bc2-4a50-b802-9eea26daf4ee	          "datasetAllowsPeriods": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
0d6877fc-06f9-44d4-af3c-cae7c7a56203	          "strictPeriods": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
126bf8da-e617-4779-90ac-47cbe6bd9655	          "strictDataElements": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
e2285671-9e9c-468d-855b-4656a589948e	          "strictCategoryOptionCombos": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
7829a496-74fa-4a53-9321-8f826597d7c1	          "strictAttributeOptionCombos": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
baad777f-4c63-430d-9faa-bd13a4c96d4b	          "strictOrganisationUnits": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
1f5a5ff0-4f82-4ff9-98b5-ad603f47f8e5	          "requireCategoryOptionCombo": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
168fbadb-8e42-4dc6-bf67-7c91b9723d8d	      "strictPeriods": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
04fae8e0-214a-4f9c-baa2-42b87c717881	          "requireAttributeOptionCombo": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
ab471832-3f4f-499d-bd9e-ee1c08cff4a4	          "skipPatternValidation": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
d2997ddd-448e-4ec1-8608-34f82fb25061	          "ignoreEmptyCollection": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
cdb98a11-8d28-4d1c-bb95-8b15064d403d	          "force": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
050c5c2e-02a5-4347-b375-6254a266a0ea	          "firstRowIsHeader": true,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
5abfa367-fa9f-4796-8f13-ac28d7eef3dd	          "skipLastUpdated": true,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
6cc2f424-ce7e-42f9-8c87-a58365d6b118	          "mergeDataValues": false,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
7f8a756b-a3d5-4c1f-a291-41aa1ba66da6	          "skipCache": false	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
19e7308a-4ff2-47d3-ba1e-3f674b80aefd	        },	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
e484c9d6-745f-4a68-a520-5b1bfc10b09a	        "importCount": {	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
1dd100b1-eba1-4d06-9bf9-43be02a7c8af	          "imported": 1,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
788905b3-7944-4d57-a697-6983e8337cb3	          "updated": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
cead5202-b46e-42b1-8555-7067c4abc336	          "ignored": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
38912da8-6834-401f-a5eb-8c56cbf6156b	          "deleted": 0	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
7d1ca312-af72-49f9-b633-1a30bc355acd	        },	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
142d8044-3f19-441e-8f04-a7d06f8da708	        "conflicts": [],	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
bf0fb506-e394-4596-bb24-0920e536aa74	        "reference": "hRuZJqQ41a7",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
657676be-b271-4345-933d-a7ca8fb596eb	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/hRuZJqQ41a7",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
7a0afac8-dd23-4ed9-a6fd-73ed45dc78c9	        "enrollments": {	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
a994453a-7cf4-4987-a321-83170f1b2333	          "responseType": "ImportSummaries",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
70027291-945e-4abb-a2bb-f05f16368b42	          "status": "SUCCESS",	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
66c56d21-4add-42bb-af9f-98346663d809	          "imported": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
5845f468-8c8f-498f-815a-b06e681eddd4	          "updated": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
6fd914b2-d536-46a9-9240-ba8986af5863	          "deleted": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
1bc5a9ac-ee54-431a-a43b-9e40b0157ab8	          "ignored": 0,	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
e9aa452e-3169-4925-9617-0dde33c0668e	          "importSummaries": [],	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
a53127d3-4d7e-46d5-8ccf-ad0e5188b16b	          "total": 0	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
b1098eb7-cc55-454b-98fb-e0115702825a	        }	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
2ddb53a2-f553-4556-b28f-32a96030a09f	      }	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
0627a1f2-e2e5-4bd4-9e6b-859b641a554c	    ],	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
8d8d32d1-fb56-457c-a9d6-4f36715049c0	    "total": 1	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
f1b316d2-d4f5-4586-9da3-953fdea4c5c0	  }	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
7e421b3d-5152-4a41-b085-c1a08c23b6cc	}	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
46028225-69dc-406f-86d5-5de19ddff15e	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/hRuZJqQ41a7	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
26d67265-bca3-4df0-9740-adf5b4303550	[R/T] ✔ Operation 1 complete in 174ms	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
1280fe19-90fc-4aaf-87b8-f152bb5b895e	[CLI] ✔ Writing output to /tmp/output-1690927224-7-weo5m0.json	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
f78fbbfa-5918-4df1-96b1-7fa0cadfdaef	[CLI] ✔ Done in 586ms! ✨	\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
d3480dde-93f9-4f7c-8dc6-47cccb068019		\N	74bebfb0-9228-4bd8-a3e3-cc7f26382201	2023-08-01 22:00:26
02d27b04-d799-4662-9d66-c092e8c8fa5f	[CLI] ℹ Versions:	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
f431db9d-e26f-4baa-99b9-557e73448994	         ▸ node.js                   18.12.0	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
29487359-53bf-4e04-9a07-415eba373106	         ▸ cli                       0.0.35	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
bfd0b85c-56d1-46b6-8b34-b608008ecb01	         ▸ runtime                   0.0.21	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
c42d473a-aea8-460e-90f5-e1ad64c8f2e3	         ▸ compiler                  0.0.29	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
5bdab640-e15d-4fd0-be04-064b5d1b5b8e	         ▸ @openfn/language-dhis2    4.0.2	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
2c18ccb9-83bd-47e6-866e-01ce17e4003d	[CLI] ✔ Loaded state from /tmp/state-1690927385-7-7edviz.json	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
6de39c35-c3d3-42b6-9226-b4a6175ce87f	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
c06aa0e3-176f-4678-87e8-f1a8081a2a78	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
2a44059a-74c6-4adf-b428-c9af1f73f52a	[CLI] ✔ Compiled job from /tmp/expression-1690927385-7-5yn34p.js	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
bbad6714-3cea-4d98-a4d0-3899bf11c0ba	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
fb0b8708-2074-4a8d-a91d-734e06ce9620	Preparing create operation...	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
0727a2cf-49e5-4264-8277-b2f5e6a446b9	Using latest available version of the DHIS2 api on this server.	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
6e507b45-efab-4b08-bea2-abc8543d86b7	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
fe1aeab0-3bc8-405f-aaa6-11a6380a59c3	✓ Success at Tue Aug 01 2023 22:03:06 GMT+0000 (Coordinated Universal Time):	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
a8b019fe-c951-4852-afe5-a1fe9e104feb	∟ Created trackedEntityInstances with response {	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
d98a7dc2-3544-4d9f-87b6-a253066158f2	  "httpStatus": "OK",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
3997bce2-98e6-4fab-af87-0a37a26f29b0	  "httpStatusCode": 200,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
7df9cb3b-061c-4b25-8b08-3144fe71b925	  "status": "OK",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
2f69719b-133e-42ca-84cb-4a23d6dbadf1	  "message": "Import was successful.",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
4b46c3e1-cf06-498d-80f1-c7bf4e52df24	  "response": {	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
f4113501-7339-410c-ae0c-40cc0cb5887f	    "responseType": "ImportSummaries",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
10b605c8-57dd-4e67-bb56-37a58c476285	    "status": "SUCCESS",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
e5069bc2-e5c9-4031-a7cf-a89a6764a5d0	    "imported": 1,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
237000ce-8414-4ede-b75e-f4650a9f78e8	    "updated": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
aeaf485b-0cf0-4dfe-bf74-6a622cebc6bc	    "deleted": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
e49896b3-1e7b-49bd-ba01-0b24596e45ec	    "ignored": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
9be3e46d-6438-4972-a95b-0e0e5f8c5fb6	    "importOptions": {	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
6600aa14-0420-43f3-a121-3c06329f55a2	      "idSchemes": {},	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
398d1161-9c38-4f6a-8332-b5cf07cb9874	      "dryRun": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
8f8a87b2-1c82-4af5-a11d-3b79d427ef94	      "async": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
0779315c-0873-41ed-8149-8e90a9ed0933	      "importStrategy": "CREATE_AND_UPDATE",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
1fe49f38-ea7b-4d91-8585-f8ed2b6127f7	      "mergeMode": "REPLACE",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
e136856d-7e24-4c1f-9587-1a44d60559bb	      "reportMode": "FULL",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
3be1bfea-bef8-4d90-a15d-9bdb7938a950	      "skipExistingCheck": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
9a8adab1-9d66-4a56-bce5-034f531e49b6	      "sharing": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
f472e285-989f-4ad8-a380-3c27611517d1	      "skipNotifications": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
0c83db7f-d359-440f-8f2d-5ada77447bf7	      "skipAudit": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
aa7e22e6-8c98-4543-8b43-4370917ee324	      "datasetAllowsPeriods": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
2f124146-7ea8-4892-9d3b-16537671df24	      "strictDataElements": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
d85340ec-9aeb-45f8-8505-3d2a88e52809	      "strictCategoryOptionCombos": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
6f524cad-3209-402c-9932-e995f26e7882	      "strictAttributeOptionCombos": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
5bcf81f4-31f3-409b-8d50-831ea877659c	      "strictOrganisationUnits": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
33373847-9359-4bf3-a28c-c09113ca8f6d	      "requireCategoryOptionCombo": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
5c6918ce-90d7-4ece-b849-82c980590677	      "requireAttributeOptionCombo": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
111fbddf-990a-41d6-a796-6f7e3b535e9e	      "skipPatternValidation": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
9d05dc1c-7aa4-4332-8cbd-dc5686286388	      "ignoreEmptyCollection": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
4ea361a9-3813-4e0d-b4d4-e5113ef92ba0	      "force": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
787cdc1d-1bb5-4a0e-ae54-92bf7037e6cc	      "firstRowIsHeader": true,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
5ee990cf-dd2c-4489-ac67-a4e933b24d6f	      "skipLastUpdated": true,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
ba3a76a2-6aff-483e-b7d5-365176dabd32	      "mergeDataValues": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
c7a0361d-546b-46fe-b9f6-8180c8e3a4c7	      "skipCache": false	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
279228af-c2ea-44c6-8cf0-ca4dcb846a43	    },	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
d09b030c-f8ff-4340-9e18-1fd482c59e44	    "importSummaries": [	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
2e5fb1b8-8cb7-4b7d-ae07-f19cca1a031b	      {	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
0b78f5d1-6b98-4b5c-850d-c717f5b3a1a4	        "responseType": "ImportSummary",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
b470fd98-5074-40c4-aa7d-fa8e0f0bb6dc	        "status": "SUCCESS",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
6b24fa21-19bd-4c91-b430-4a18e9e333f6	        "importOptions": {	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
c45246e9-81cb-4f71-bf3f-c71307d742d9	          "idSchemes": {},	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
32d9b2b3-3a77-4b27-9de8-1cc3a6fa572b	          "dryRun": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
49349d54-dccf-440c-8807-74ee2aa4cb09	          "async": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
80f27b0f-74dc-4d5c-91df-dcdd86839d21	          "importStrategy": "CREATE_AND_UPDATE",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
c4f267cd-52b2-423c-a1e9-e8d3906b74b3	          "mergeMode": "REPLACE",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
9db3b1eb-019d-47bf-a359-ff0bf7f4fd06	          "reportMode": "FULL",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
38d3b71c-f5ea-408a-8002-978c673aea7a	          "skipExistingCheck": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
61995401-5fc2-42e0-816f-11352ca7bf36	          "sharing": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
95137edb-47e4-44ba-9f48-a3583a4e08f8	          "skipNotifications": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
3b9023d9-9c5e-41c9-b177-5632e1cd6b81	          "skipAudit": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
3f7a78a6-94a6-4fe1-aa85-399659c61418	          "datasetAllowsPeriods": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
a2fac534-fbd1-432e-8022-01771f667158	          "strictPeriods": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
82738ac9-fbc3-4fd7-a4da-ba70addeb413	          "strictDataElements": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
67fa2f12-f3e7-44f6-8c5c-e42965983911	          "strictCategoryOptionCombos": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
50ca90e1-43e5-4f68-b04b-1915048d9205	          "strictAttributeOptionCombos": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
2aca8685-3e8e-4b73-acc6-681d55ffd508	          "strictOrganisationUnits": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
3fae42b6-fa24-4d5c-a6e6-61a880be6c44	          "requireCategoryOptionCombo": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
cf0ff946-f725-419a-9f04-a60b15d6df2e	          "requireAttributeOptionCombo": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
e59716dc-cd9f-4691-9006-92b7281b2d52	          "skipPatternValidation": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
f1a68b36-cff2-4ea8-8c8a-09772a17ecfb	          "ignoreEmptyCollection": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
c5613a20-014f-44d5-9442-269fd15e4373	          "force": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
ccf06454-4397-4845-9d5e-a2020a8ccb63	          "firstRowIsHeader": true,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
82581157-05ec-49e5-9f86-9e1639f1b7ea	          "skipLastUpdated": true,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
aedd3f2d-af4c-4b29-b7f7-844b999aff4a	          "mergeDataValues": false,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
00d6e655-5bcd-40ef-a13c-006fb5ddb525	          "skipCache": false	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
15e3f86e-2efe-4ff4-9d52-925f64c880ba	        },	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
ed603313-0788-4cbe-bdbe-75fb452697f2	        "importCount": {	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
1c3f1724-8f98-4231-a56e-22f5c38d3ab1	          "imported": 1,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
ab134e39-978a-4e39-a192-3a9162f87065	          "updated": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
e38e475c-f129-4ae7-88e6-f167f5c7ecaa	          "ignored": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
188479b9-b65b-4de4-9a8c-b88498ab299d	          "deleted": 0	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
91f1ec68-4bc5-4181-bd4e-bb4cb1482a0a	        },	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
638ebde5-6ef8-4910-8606-2a44c7f6f518	        "conflicts": [],	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
5111b270-c6ac-45da-b098-1c0c3842642e	        "reference": "Vtz1sSNAn4n",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
02c0c518-168e-4d98-abc4-9db540519f74	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/Vtz1sSNAn4n",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
b5cb5207-799e-411c-975d-5cc640abb4bf	        "enrollments": {	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
c3ea1cc1-4658-47ad-b266-dc698d57705b	          "responseType": "ImportSummaries",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
922b5666-d8e0-4686-9d5d-96cd1bc7bfcd	          "status": "SUCCESS",	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
1c7a31d6-56be-442b-ba75-6180f677f97e	          "imported": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
837376ec-3218-414a-81b9-d80a256aeb01	          "updated": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
7743a0d2-8928-4609-8b1a-d867958a8605	          "deleted": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
fab7f006-8522-4c9c-9ce4-25e736f79a64	          "ignored": 0,	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
49d77367-1f89-4331-8809-dda98dc2582e	          "importSummaries": [],	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
13c7366c-490c-4ef9-892c-be30714e246c	          "total": 0	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
93fd695f-0ad2-42ad-ada4-23a9e8cb6c77	        }	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
619d6617-16bc-47d2-916c-a0e397328489	      }	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
26082713-7183-4113-96a1-a1d1c40fb95c	    ],	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
f6369178-e081-4f9b-8401-c96107e8908c	    "total": 1	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
c55ed18a-5d8d-4df9-ab6a-bafa522aa737	  }	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
612eb974-4f1f-49d0-99d3-e3137faa10de	}	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
dfcd02cb-8674-4448-8540-0ae694995c72	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/Vtz1sSNAn4n	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
3b24bacc-eb45-49a2-be17-0a3d8d917a06	[R/T] ✔ Operation 1 complete in 165ms	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
b0c6a084-243d-4f8b-8ce8-20b09a851c0d	[CLI] ✔ Writing output to /tmp/output-1690927385-7-1jekxi2.json	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
d720540c-b415-4847-87fb-974f5bba917d	[CLI] ✔ Done in 593ms! ✨	\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
63e25716-19b4-4560-ad11-7df6588b2617		\N	326d7022-b38d-4306-86b7-6a2a45335c66	2023-08-01 22:03:07
660a791e-384a-4cca-9774-009290b4e744	[CLI] ℹ Versions:	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
c3c3d9c6-c7ed-4e86-997d-123176c68ad3	         ▸ node.js                   18.12.0	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
d326a457-365d-43ab-9464-4dcff3cb4d29	         ▸ cli                       0.0.35	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
2fce9a19-d04d-42f5-a1b7-860fef627852	         ▸ runtime                   0.0.21	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
c121eb56-23d5-4b87-a070-3741ed3cfd09	[CLI] ℹ Versions:	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
576bba86-5e43-4992-9e5a-f4496f53ce5d	         ▸ compiler                  0.0.29	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
0afffba7-5d6f-4b4f-9631-b5da2a647716	         ▸ @openfn/language-dhis2    4.0.2	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
e26165b2-a4ff-4252-8c20-385285f1c507	[CLI] ✔ Loaded state from /tmp/state-1690927671-7-p5p9eo.json	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
65d22017-0154-4a65-a233-dbdf47acf855	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
e21fc938-d732-40d8-b146-ac738dfb5b9d	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
89f262f2-b094-40fa-b45b-4a39584dd103	[CLI] ✔ Compiled job from /tmp/expression-1690927671-7-p81e1e.js	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
193f8809-f489-4376-ae09-912d875924fe	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
c4c745f2-cccd-413a-b605-7eb41eb7fe6b	Preparing create operation...	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
0fbc7a18-e6cb-4f74-a5ad-b9c1a07410ce	Using latest available version of the DHIS2 api on this server.	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
9bf566e6-deaf-4582-9a1d-a851b5debc45	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
07356216-e801-494f-ab6f-afe7fed7798b	✓ Success at Tue Aug 01 2023 22:07:53 GMT+0000 (Coordinated Universal Time):	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
390f29aa-0ee6-4d59-adae-317ce00979cb	∟ Created trackedEntityInstances with response {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
4149d3ef-2e97-49b3-8437-c23cf9174331	  "httpStatus": "OK",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
6805edc4-3c45-4f93-bac4-bd123d940cd9	  "httpStatusCode": 200,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
3dc385a1-0989-4bdb-a8f3-840a8166733a	  "status": "OK",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
1b8372c5-c737-4978-84b5-d613076e214b	  "message": "Import was successful.",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
508b033a-da20-4f09-8cb1-0057d375204d	  "response": {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
1604d396-ba13-44c9-98a3-9931a27be304	    "responseType": "ImportSummaries",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
27e68eb1-c55f-408d-a4c4-8cbfc8b2c3b4	    "status": "SUCCESS",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
68df21e2-3aa7-4bac-87b3-2c02066f4cda	    "imported": 1,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
ecd47938-9eca-4fc5-9c17-55644b66ffc5	    "updated": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
5533eda1-8094-4abf-a6be-6f5ec4a30fd1	    "deleted": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
d505a04b-8aca-4de3-9308-7f3002060c39	    "ignored": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
bfe22afc-e844-4c48-a6ac-e74e3c60771e	    "importOptions": {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
496df1fd-0c40-40d5-b23e-74d9b3547163	      "idSchemes": {},	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
d37ffee9-5688-4a3c-9bd5-5543b0366091	      "dryRun": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
cd7e0982-61bc-47e6-86e8-cb2fd51e7c56	      "async": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
b20602e9-a4db-47c3-8aea-4100e9924eb4	      "importStrategy": "CREATE_AND_UPDATE",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
f9c288e0-a578-4dd0-91cf-1c12894e8f48	      "mergeMode": "REPLACE",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
8fb4518b-5c97-43ec-b008-a5024f0b9728	      "reportMode": "FULL",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
2089e3e5-cc9e-4ab5-a351-4c2b637435bd	      "skipExistingCheck": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
2227ce1a-95cd-4f85-9f9f-6744cd42cc3a	      "sharing": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
9d7e084c-6308-4242-9ca7-61c1d9161573	      "skipNotifications": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
9994691f-4fda-4349-98c3-0e643b7bc4ee	      "skipAudit": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
5d167f32-369f-489a-b901-df7658466251	      "datasetAllowsPeriods": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
448f443e-9889-4a9b-ab62-f91ffb0e3aca	      "strictPeriods": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
40b74417-ac28-4832-9186-2bd239b562a0	      "strictDataElements": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
4bfad9bb-caec-483a-8e1f-92b740fa1f4b	      "strictCategoryOptionCombos": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
1bbbf3f5-190c-480a-bc68-dcc8acb48dd9	      "strictAttributeOptionCombos": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
1972e001-ef9a-4106-96e2-4e4e10ed5794	      "strictOrganisationUnits": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
cb73aa77-5c10-44c7-b7a6-49ae272d8b79	      "requireCategoryOptionCombo": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
e1700b02-ebc2-44c7-ae6e-5c6ecebdfc9d	      "requireAttributeOptionCombo": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
506b5497-8f4b-4686-b59b-0f6fb31c8ce7	      "skipPatternValidation": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
babf151f-c53a-4b5d-9957-884e18316a3e	      "ignoreEmptyCollection": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
c18b030d-71ac-4a46-8964-b6322c187ce1	      "force": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
1a813f70-e500-4246-bf56-cb8af0808e5a	      "firstRowIsHeader": true,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
42ac2c2e-8c0b-4c07-a30b-19ee48c3ca9e	      "skipLastUpdated": true,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
9b2a965f-4308-4749-9c7e-ee97e06b46ea	      "mergeDataValues": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
9d12bdbf-0390-4523-a3cf-406cb89e6e34	      "skipCache": false	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
d046cde9-3d72-41de-afd4-4f424c44400d	    },	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
6521c51a-ea33-47ea-a1cf-e2e3f8333ade	    "importSummaries": [	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
4d422f0f-46a0-407d-995a-5be63df975c5	      {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
ca355a6d-5f83-45ce-89c3-92219eeeda46	        "responseType": "ImportSummary",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
4c88b48f-260e-4e4f-98ff-c82cc4c31871	        "status": "SUCCESS",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
01ffa7bc-94a0-4cbe-bddb-9b05ec9a39e1	        "importOptions": {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
e6d9b149-33ba-463d-b5f7-db0e74abe8a4	          "idSchemes": {},	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
ef5a0f18-2525-4fb3-ab27-c31a949c4224	          "dryRun": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
a0a61fd4-e1e9-4221-be1e-293d370a0255	          "async": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
5286d870-f976-4cd5-bf11-a12e6127b8db	          "importStrategy": "CREATE_AND_UPDATE",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
3258a1b5-6f66-45f4-8eda-e23c90f602c9	          "mergeMode": "REPLACE",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
c628bc59-cdb4-4486-831a-f7f28f1313b7	          "reportMode": "FULL",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
f4439154-9353-4f08-b18e-cde048a264e9	          "skipExistingCheck": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
7042fcc4-8fdf-4859-a99b-6a66c21a95c0	          "sharing": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
723bfac9-e188-48a9-903f-ff834cef1ede	          "skipNotifications": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
d28235ce-4c48-48fe-b179-31057507ef2f	          "skipAudit": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
69053593-c77b-4205-855d-88377e994dab	          "datasetAllowsPeriods": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
bec17680-325a-40b1-8f55-bdfd8c9feee3	          "strictPeriods": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
fcdf1ed0-b244-41f0-95d2-0ba6d8bf958e	          "strictDataElements": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
102fe089-d799-480a-b5a4-b16c727b3d89	          "strictCategoryOptionCombos": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
13c29aae-8c36-407f-a3f5-2c15497fce18	          "strictAttributeOptionCombos": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
3197bb79-5909-462e-8dff-99ca184645a6	          "strictOrganisationUnits": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
b4d7cb97-0957-4e8f-9b13-8fc6e5765fe2	          "requireCategoryOptionCombo": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
0fd8816c-65f2-4b4e-81d5-9349e9f05f52	          "requireAttributeOptionCombo": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
b287b5fb-53da-4f85-9333-2382efa9ad24	          "skipPatternValidation": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
fdc4418f-544c-4888-ab0e-5c5a1a8e4924	          "ignoreEmptyCollection": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
99cbf44c-d62c-4d6d-9746-98d964d527a9	          "force": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
d5797dc9-cfcc-42aa-ba8a-324f4d82030a	          "firstRowIsHeader": true,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
03e3649d-b851-493d-895a-6eb2e662f4a7	          "skipLastUpdated": true,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
99ec28f6-1151-4079-b16c-88e1cb9b7769	          "mergeDataValues": false,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
53661445-a3d9-41b2-a239-5a182ced7895	          "skipCache": false	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
22fa7d74-789e-4731-af72-5b3279e579cf	        },	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
b8fa0107-b3fe-47b2-a025-fa471c3e246b	        "importCount": {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
4250a623-41e0-4e06-9ae9-f03075358f94	          "imported": 1,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
06590ce4-7624-43a0-a615-96739725b34f	          "updated": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
d235c6c0-705e-4013-9589-c17915fdeb07	          "ignored": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
284dd7d1-15c6-4b2e-bbc5-61dfbc19fbd3	          "deleted": 0	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
f511ff73-9310-4034-a3eb-11d2c5f7a72c	        },	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
998e195d-42a3-460c-b281-22ba927b0f4b	        "conflicts": [],	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
a04372e4-2b5b-4081-8bac-4d7d1958da4b	        "reference": "NGcsjKjPaRR",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
cc88ba8b-21d7-4d3e-a794-8e267b9f9b10	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/NGcsjKjPaRR",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
abc5e17a-ac53-445c-986c-9c74a51c0c4e	        "enrollments": {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
142e25fc-9aec-4239-a9b6-a20b179bb2c3	          "responseType": "ImportSummaries",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
3610fcea-ed85-44a6-ac5e-d47201f98768	          "status": "SUCCESS",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
a3ff1688-4f40-4ec3-aa54-7be9a9f09047	          "imported": 1,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
b4857d7e-1265-49a0-9939-94f023805bfd	          "updated": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
12a552c0-55f5-4884-9416-aeef7582b74c	          "deleted": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
dfd8e51c-5764-44e7-98f4-7af62ca413a2	          "ignored": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
a9063d9b-6bc5-4ec1-8f37-4709bb388539	          "importSummaries": [	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
2cab85a8-156c-4b53-abd2-d61ed8f56395	            {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
c77a8a34-5e53-449c-9704-e837900a0bb0	              "responseType": "ImportSummary",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
92aa7bf1-7a8a-4e20-98bc-d8e3f45cfba2	              "status": "SUCCESS",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
07d37bef-9912-4147-b34a-bbe89ff36053	              "importCount": {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
a55a2a16-1d05-43b8-9a96-6606b62fb120	                "imported": 1,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
cb4afccf-5ca2-454e-8887-6bbaef21bb60	                "updated": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
cf37395f-34e5-48f3-8cb7-bd7e2b690e00	                "ignored": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
757a24c3-1e6d-4d2d-8507-1120114889ed	                "deleted": 0	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
69c282af-ebed-4501-a8d2-c6535cee8176	              },	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
b3df179c-7acb-42e4-845e-4ff2f5f3c856	              "conflicts": [],	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
3fd42997-deaf-45d6-b179-9d1e0b70f31c	              "reference": "UtLI8F61qnP",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
b95cebf3-6ea4-4122-9370-936b68478e09	              "events": {	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
b4f4b3e4-b322-4d92-a18b-2835df9366c5	                "responseType": "ImportSummaries",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
9075e7b7-0413-42da-bccd-e3f61ab3229f	                "status": "SUCCESS",	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
359e6bd3-d068-4575-9699-d69f41d0b8a5	                "imported": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
397f6e23-b84b-4257-ab48-59a25ae4fbf2	                "updated": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
fa55449b-894d-4913-8c02-ab634a0c00ed	                "deleted": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
32abbce5-5c9c-4a1f-85ac-9fe473b0b041	                "ignored": 0,	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
eeaf2dc3-7d69-4532-b000-849dfa934f43	                "importSummaries": [],	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
a62aafcf-bf0c-40bb-b738-669a985df0f4	                "total": 0	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
3e4c807e-8363-493c-800e-1ddd33bdf5ad	              }	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
d1f503a3-01d3-4b38-a859-403cb274e568	            }	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
e88ed099-c36d-402c-b85f-e09072d49003	          ],	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
c0f35369-8c98-4884-a126-d38f4647b5f4	          "total": 1	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
92f4ed82-ca11-4408-8bf9-8d6242ea6ff5	        }	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
942a35f0-6647-4b86-976c-3400c93ec1b6	      }	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
babacee8-1537-4a41-9672-d15fb927a043	    ],	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
f07c5531-191b-4ee3-b14f-716280c5e9e6	    "total": 1	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
854a8168-2334-4480-b692-ca766928e564	  }	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
ac74b449-32d8-4d73-95d4-26cecd6459db	}	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
684c8cb1-2a3e-4957-9edc-dab28e378010	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/NGcsjKjPaRR	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
813ef777-f223-4461-a7e4-bb7099ad5aaf	[R/T] ✔ Operation 1 complete in 184ms	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
4082eb7c-1895-4cb6-b2ed-720c9c3b8770	[CLI] ✔ Writing output to /tmp/output-1690927671-7-1nrqdnl.json	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
668959fe-4d88-40e2-a413-0b457a12b0f8	[CLI] ✔ Done in 612ms! ✨	\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
a306ba90-67e6-44bf-a602-3f4a423dafea		\N	f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	2023-08-01 22:07:53
393b2bf9-7e64-41d3-bac3-57ceedbb898a	         ▸ node.js                   18.12.0	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
0aa32907-92a5-413a-b0e9-59840befcd7c	         ▸ cli                       0.0.35	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
b7a43612-31aa-407b-a386-8956f9659151	         ▸ runtime                   0.0.21	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
1e5cc244-ad95-4625-919f-1f1880dadbce	         ▸ compiler                  0.0.29	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
8ba2ddb2-4c8f-44cf-9b10-e27416234bd0	         ▸ @openfn/language-dhis2    4.0.2	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
c77118ac-bf6c-4720-9808-3bb742cb9824	[CLI] ✔ Loaded state from /tmp/state-1690927981-7-le9oug.json	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
116709c9-949f-4dbc-b836-ee8ce3cd6fd8	[CLI] ✔ Compiled job from /tmp/expression-1690927981-7-umoxi9.js	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
01e7bb5e-303e-494a-ac1f-2fcedb74c06a	vm:module(0):1	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
7c60c334-74d0-4d14-b4c2-9c7dee14f23c	const fhirPatientResource = JSON.parse(state.data.body);	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
d67c4d31-7e88-40c8-9d46-1ef36ee42e3f	                                                  ^	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
02e44f3f-314b-4d42-a7d4-622180e549f3		\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
cc52781b-7dc9-447c-8743-f2cf42c928c9	TypeError: Cannot read properties of undefined (reading 'body')	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
582080a5-5e6e-48c3-a2e7-d4e1779d58cb	    at vm:module(0):1:51	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
73e0773c-3d66-478b-9e3e-5bd9e1c1de8f	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
52a2d8de-3d12-476e-abbf-842431dd9b69	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
469317a0-74e8-433a-a153-a7875e9da944	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
4947dc07-7452-4ce6-a1c2-ebbdc39957ad	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
fa3f1107-d520-4fe7-ab29-21567b16af7b		\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
24bccfb9-a09f-4338-8711-7d5770b65068	Node.js v18.12.0	\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
a21a4da3-41d3-41e7-89fe-f70c819ba293		\N	e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	2023-08-01 22:13:02
3bbdd46b-af56-476a-9c54-d664e83e000b	[CLI] ℹ Versions:	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
f59efdac-163b-4032-b196-f8cc35e51813	         ▸ node.js                   18.12.0	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
12b76205-2ee9-4ef4-bf45-65a8f94276dd	         ▸ cli                       0.0.35	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
41e084bc-a88b-42a0-9555-a14e2d990876	         ▸ runtime                   0.0.21	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
d3b2027f-c4fa-4bc7-a487-dfd6e3e21152	         ▸ compiler                  0.0.29	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
80908185-a607-485b-948e-c3ab335d343c	         ▸ @openfn/language-dhis2    4.0.2	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
6531e125-5438-43d4-9c06-289b9db5dfac	[CLI] ✔ Loaded state from /tmp/state-1690928067-7-4tuuox.json	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
c7a16510-6227-48d6-91bb-e84fa919e037	[CLI] ✔ Compiled job from /tmp/expression-1690928067-7-1qujxbd.js	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
f2978bca-40df-45ac-bb86-310485766d55	undefined:1	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
461f644e-c532-4834-b855-a9f7b2b1bca1	[object Object]	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
f7fef11d-2b5e-4521-af93-33639c1710ba	 ^	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
1bcd3741-942e-4fd3-b358-843076fe921c		\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
17b340bd-f3cf-46a3-aa8b-05a9c5db5c86	SyntaxError: Unexpected token o in JSON at position 1	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
7a6f1357-ceab-47be-a6a7-a5ceb1e60fda	    at JSON.parse (<anonymous>)	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
7e51e0bb-29c2-467d-96bb-594b177723bd	    at vm:module(0):1:34	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
c967b659-d0c1-4b77-9e96-97f25ee5b90a	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
cdf20829-573c-4728-bb17-27ffa889f5b1	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
8fea5b99-9d85-43dd-be24-c61776935da0	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
dbb2979d-29b1-411b-8345-83915d3e78d2	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
17add346-529f-4eea-a18f-b26a38779c80		\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
538759fa-cf7c-4ddb-9e55-7af192e35615	Node.js v18.12.0	\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
b4f3b3b5-3117-4d8e-b2aa-1ce88a60ca25		\N	eb443fb5-d089-48ef-8bc6-f2a8485542e4	2023-08-01 22:14:28
2988d34d-fd43-4173-98fc-85bfa4b4a07f	[CLI] ℹ Versions:	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
986da89b-7178-4f45-b7cf-3d08c94118c4	         ▸ node.js                   18.12.0	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
36ca10db-9fef-4a87-b778-236750bbb5b5	         ▸ cli                       0.0.35	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
6f8b521a-af04-418c-a4ff-0136ffa97f2d	         ▸ runtime                   0.0.21	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
6d073b15-50eb-4020-bf94-93deeaf1e21b	         ▸ compiler                  0.0.29	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
628f63d4-a712-4de5-b2d1-d80dd7bfecb7	         ▸ @openfn/language-dhis2    4.0.2	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
883d7e6e-9697-4c2c-9db3-736741e9a387	[CLI] ✔ Loaded state from /tmp/state-1690928154-7-18aqwhn.json	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
5e408ae4-d16a-414c-8b91-cbdc0b26db11	[CLI] ✔ Compiled job from /tmp/expression-1690928154-7-yfwruy.js	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
25cefd6a-29be-4a0f-9836-8921a2376fdc	undefined:1	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
cabf2706-1637-4b66-bebf-09bd1ce63f80	[object Object]	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
3c33a7d0-edfa-4055-bb44-c6252c8f58c7	 ^	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
41704aa1-f2f5-4411-b58b-b1a791904cc8		\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
f93ee779-d35d-4f93-ba9a-23454f312eff	SyntaxError: Unexpected token o in JSON at position 1	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
d7a40613-3a78-4282-b40a-0189e6dd2a54	    at JSON.parse (<anonymous>)	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
66e803ac-51ea-486c-b820-9eac608c1e4e	    at vm:module(0):1:34	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
c25b174f-8b82-48ec-9706-38f015c6dec6	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
b78f6db4-e53a-4ba7-b029-f3c131819ae6	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
6b041630-8325-4416-9e21-7e27697c2b79	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
5a6994d1-9ac0-4e0e-8e69-1f3b526ebc48	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
e2b3f5e8-5394-4659-850d-da1cae7aee08		\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
324cc998-271a-493a-bb87-13f0bfe5a87d	Node.js v18.12.0	\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
c6b84302-7ff0-4a2a-95c6-71e11aec4fd3		\N	d421e41a-ed0f-4241-9f59-4bd50590917a	2023-08-01 22:15:56
66cbae52-57cd-4537-8d90-56e07cedb636	[CLI] ℹ Versions:	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
2b7393f4-d3fd-4ae0-8177-1bc31d791be7	         ▸ node.js                   18.12.0	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
6cfa264a-5dc2-46d0-b9e4-476dd3b42ea2	         ▸ cli                       0.0.35	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
f58d44dc-41b8-4a92-8341-0d4cb8e8f9bc	         ▸ runtime                   0.0.21	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
2a8a697c-9131-48ec-9246-f803d9eb82e1	         ▸ compiler                  0.0.29	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
715f7ec0-53fb-49c1-8f5b-2585f50ab0a5	         ▸ @openfn/language-dhis2    4.0.2	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
e910d385-edb8-45f1-ac7a-5f9c9543abdc	[CLI] ✔ Loaded state from /tmp/state-1690928191-7-da47m.json	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
e8b74796-011e-4f34-8178-6af899370364	[CLI] ✔ Compiled job from /tmp/expression-1690928191-7-1pffio8.js	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
a867078a-e4f7-4597-834b-8688cc73569c	undefined:1	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
e6b6ef2c-5f5a-44c3-919c-f9453dc74a4b	[object Object]	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
d45b7b91-0fc3-4554-950f-92e035c8dbdd	 ^	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
9c976a12-501c-47cb-a03b-f56ca9c54ad9		\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
aa2ecafa-3842-4e14-97d7-2f0977ac857c	SyntaxError: Unexpected token o in JSON at position 1	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
1725298d-056d-4a2f-a8e5-16ed8e014459	    at JSON.parse (<anonymous>)	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
d36abda3-0459-4802-95d5-3a8d029cc5e4	    at vm:module(0):1:34	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
70240f90-61c2-42b7-b5dc-d8974c7c845d	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
36612ed1-6e83-4db5-896a-7b906d0d01bf	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
6787e05c-aab4-4011-af1d-5eebe00e843b	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
baa5f9f2-907b-4565-a819-7fc27bbfa2b7	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
c5d5139b-54c4-4de3-82dd-84acb1583918		\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
21f7efc8-9dff-401b-acc2-55a444986d98	Node.js v18.12.0	\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
3f91435e-6278-41af-9a1e-b08f8705cfa0		\N	dcb47cea-9525-4834-890c-b9dec6b1e1d3	2023-08-01 22:16:32
3429d304-8fc8-4ab4-b296-d204750f19d9	[CLI] ℹ Versions:	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
6dd8547b-c5f0-47a4-bdda-86642efef720	         ▸ node.js                   18.12.0	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
04b9f332-21c6-49d5-9a23-8d54f88f25a2	         ▸ cli                       0.0.35	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
43890ecd-e06f-4a05-8cec-83e218f3408b	[CLI] ℹ Versions:	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
cac4c0f2-a36b-4060-ae7a-8d23c1a3edc0	         ▸ runtime                   0.0.21	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
3fcd7fc2-3110-453b-aeb4-2c58acd0ac47	         ▸ compiler                  0.0.29	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
f915a9de-b49d-4fcf-9e57-7fd1a988843e	         ▸ @openfn/language-dhis2    4.0.2	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
a386baff-be6b-44ae-926e-2a456df4fd68	[CLI] ✔ Loaded state from /tmp/state-1690928270-7-1yfc9ks.json	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
6a21046f-b21b-4b9c-b4bb-350208a0d0c7	[CLI] ✔ Compiled job from /tmp/expression-1690928270-7-1j8opy9.js	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
da4b09f7-0b7f-40d3-8da9-2d916622ad57	vm:module(0):1	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
bd162cf0-c83b-415a-9b70-a7df37ddbfc1	const fhirPatientResource = JSON.parse(state.data.body);	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
f8d418fd-f9bf-4afe-a8d8-c53510e8cd81	                                                  ^	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
7f03a7e1-b3a2-4227-8976-5984cae46127		\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
0a7407fa-386c-4499-97e4-7b7181002d1b	TypeError: Cannot read properties of undefined (reading 'body')	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
b7a8ef83-f5f7-4cdf-b402-90a9495e740d	    at vm:module(0):1:51	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
e962cbd4-c011-4ceb-a999-325e69308bd7	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
9bcfc9aa-8a50-47b7-9063-91e2f9801235	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
a3d0bbaf-c513-4b19-acd8-a915af3b2dc1	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
843ef492-fba5-434e-b9ad-343904024243	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
69fa33ac-d17e-4b1c-8e8f-85e99326bec1		\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
528282db-b1d2-4618-95c9-410f53d9dbd8	Node.js v18.12.0	\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
442f37d9-94cc-4c55-982f-07f38fb97e53		\N	6d510da7-0fe2-4438-8430-0b5cddbc30ed	2023-08-01 22:17:51
a777a036-8105-4185-aafc-ba4b9ab93d80	[CLI] ℹ Versions:	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
d0d93b01-e43b-4f35-b4c1-5ae8d7fc2013	         ▸ node.js                   18.12.0	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
71260186-2bad-4d52-ab2c-671afdbfdbbf	         ▸ cli                       0.0.35	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
1b274080-428d-4fb5-9e7c-e529f9cf10a3	         ▸ runtime                   0.0.21	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
4c31868f-35cd-4fd2-b898-b5eb7a1aa486	         ▸ compiler                  0.0.29	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
9628a0d2-acbf-462a-a38f-50578aa3d8b9	         ▸ @openfn/language-dhis2    4.0.2	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
c438f699-55a6-498a-91ad-b8802e96432e	[CLI] ✔ Loaded state from /tmp/state-1690928306-7-1n1f9h8.json	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
480e66e0-873b-45bf-94af-52392db8cfc7	[CLI] ✔ Compiled job from /tmp/expression-1690928306-7-p0kbhm.js	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
dc568af4-67a4-4446-8380-8f7a7eba0e05	vm:module(0):1	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
1b6fd2eb-0b72-47c5-8d75-715b97dcbd37	const fhirPatientResource = JSON.parse(state.data.body);	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
3acf99be-7ef5-4fb5-b179-142fd1a60004	                                                  ^	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
83f01641-51e1-4976-b4fe-fee33e5a65ae		\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
d418a71e-0629-4ff6-b3b2-4181e57becb5	TypeError: Cannot read properties of undefined (reading 'body')	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
c447715a-abb9-40bc-a743-b8e2fb38ac44	    at vm:module(0):1:51	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
3cf7aa30-fb7e-4ac1-9d9a-86901a8121ac	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
4ee9613d-5936-41f4-b97b-f09865bf8d2a	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
8aafef5c-12be-420a-93b4-17d51b848772	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
dfdbcee0-9ad8-447f-b0d5-d819f754028e	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
945587ee-01d9-4f24-83bd-aa34a3a66863		\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
892d09ba-cdac-44b3-869c-cec24cbddb08	Node.js v18.12.0	\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
e4563b17-45b8-4d0c-b2ba-37e3ef125f98		\N	1b20ade9-8076-4ea6-ba40-7d23f72b5923	2023-08-01 22:18:28
33277fd5-68db-4212-ae00-db04161ad6ec	[CLI] ℹ Versions:	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
c3bcd5e7-cf47-4bff-94e3-8f51abe4e00c	         ▸ node.js                   18.12.0	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
a762de0f-e92a-4d4d-83f7-5e7f0c157084	         ▸ cli                       0.0.35	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
19582dd3-4f11-4662-b8cb-978402e2a6ce	         ▸ runtime                   0.0.21	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
770696e4-4d4c-4afd-91e5-bf8d47924dbe	         ▸ compiler                  0.0.29	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
071ab1dc-12a9-419f-b504-129b32a23f59	         ▸ @openfn/language-dhis2    4.0.2	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
8c064b70-489f-4a1c-ad24-2b70a412b9d7	[CLI] ✔ Loaded state from /tmp/state-1690928309-7-1v51bdx.json	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
dd685ad1-c86c-4584-9bad-c29ef81fad25	[CLI] ✔ Compiled job from /tmp/expression-1690928309-7-13v9el4.js	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
51481890-9101-474b-903d-3de6033bc9a3	vm:module(0):1	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
7f314efe-4021-4299-a9f8-fc35b6d7ccc7	const fhirPatientResource = JSON.parse(state.data.body);	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
8a0bb70b-ba6d-4d14-b536-3ff8840bbb5c	                                                  ^	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
c719ca06-72a8-4f0b-a2cc-3a4a28183273		\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
66dcc5a4-a9e3-464a-9cf1-874f5d691323	TypeError: Cannot read properties of undefined (reading 'body')	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
40386252-2e2b-4842-9c0f-905090f27175	    at vm:module(0):1:51	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
888664ee-c310-472c-acf5-79a596878bd0	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
78bd5824-51e3-4611-ae81-32fc65aea2d4	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
9df67459-3582-497f-8326-d0e0989e60c9	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
7b4b5c41-b207-46a8-b1c5-944ac9ed78c6	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
c6c1f7f4-3339-47cc-b8e2-c1f9e1c08b5b		\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
ef287bc8-6c15-4a48-83dd-7127c68f8218	Node.js v18.12.0	\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
c99d79a1-8391-4e0b-8719-6934c600eae7		\N	e150fe08-f701-4118-b1d7-59e50e9897a4	2023-08-01 22:18:30
913b0217-3932-44a1-a4ed-4667324d7b7c	[CLI] ℹ Versions:	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
3805bba8-fa11-42b2-b5bf-d03670c0c56f	         ▸ node.js                   18.12.0	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
526fde49-86ab-4c8a-8578-2fa14962bfd4	         ▸ cli                       0.0.35	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
0a6aadef-144f-4450-9d38-a8398c001510	         ▸ runtime                   0.0.21	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
9b07de1f-ecdf-4ba3-805f-731e2ebe8a52	         ▸ compiler                  0.0.29	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
890a9581-3bd9-41db-a3a5-4ed5e30ed9d9	         ▸ @openfn/language-dhis2    4.0.2	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
c6252bbf-2907-445b-b7a9-84a7dd685893	         ▸ node.js                   18.12.0	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
f2f1430e-ee7c-4c61-ac81-5456d5cb22c6	         ▸ cli                       0.0.35	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
781e3d6c-2f5f-47c3-adbc-d26815dcd5a9	         ▸ runtime                   0.0.21	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
3ef10716-71c0-4be5-902f-703782c51537	         ▸ compiler                  0.0.29	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
8e0b5def-641d-425e-b137-39311b27969b	         ▸ @openfn/language-dhis2    4.0.2	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
b49bd5e8-a6f7-4e5a-a533-abda8f4d0c90	[CLI] ✔ Loaded state from /tmp/state-1690928396-7-13lq3xt.json	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
05788cc8-0d1b-4746-9433-6c24b698d90b	[CLI] ✔ Compiled job from /tmp/expression-1690928396-7-1nmmpgk.js	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
58e6da3b-ab35-48bb-9077-4d1cff402127	[JOB] ℹ state	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
7c476a22-d198-4455-8581-958ec158f5b5	[CLI] ✔ Writing output to /tmp/output-1690928396-7-141loek.json	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
2774a710-fa5b-41cb-aa6e-ab3a70725571	[CLI] ✔ Done in 161ms! ✨	\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
3ed6cea3-777d-4f93-b0d0-8e6da129da91		\N	6afbaf69-4166-45c5-ba5e-df8531ad44ff	2023-08-01 22:19:57
eacdd208-fa5a-43b6-b49d-8fe3b5ff5af8	[CLI] ℹ Versions:	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
6d15ab12-0800-452a-9765-8990180ea34c	         ▸ node.js                   18.12.0	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
36e1ebee-e413-4683-9235-185b526ec03c	         ▸ cli                       0.0.35	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
105e07a1-100c-4fbc-b549-b5872aa571d3	         ▸ runtime                   0.0.21	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
5626c95a-7c6a-4e3a-a3f5-a550ab1f7b07	         ▸ compiler                  0.0.29	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
4b9d49a9-7fca-49e3-9adc-fdf41ab6e863	         ▸ @openfn/language-dhis2    4.0.2	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
b8f34b02-c9d3-4b0d-8276-3031d8f8d900	[CLI] ✔ Loaded state from /tmp/state-1690967114-7-1ku396v.json	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
589da3f4-332f-43b6-8b79-023a4db22851	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
a9a57e60-6ec9-40f8-ac5b-7f713e024248	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
956daf6c-32c1-490b-a715-5cc381658af1	[CLI] ✔ Compiled job from /tmp/expression-1690967115-7-zi24yz.js	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
accd4bd2-7e7a-4013-909c-2cfc289d4062	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
47e5a233-416c-4e67-a10d-329bc5cc5489	[JOB] ℹ BirthDay: 1980-01-01	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
542e51dd-256d-465c-af01-3bc5d0d82d23	[JOB] ℹ firstName: Demo	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
0af2306c-1dd7-48af-b898-c9b61f2a7f0f	[JOB] ℹ Surname: Test	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
b98949ea-9b55-4a14-a41f-f86712c18929	Preparing create operation...	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
3103baeb-5f9f-44f4-a33c-9fffe35242a9	Using latest available version of the DHIS2 api on this server.	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
5e13286c-5ef6-491d-ab40-78c226b4e5b3	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
464b4fde-7256-4b5e-bc95-a15494a4e1e4	{	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
c688282f-e18c-4763-b8f7-e36a3cfb986e	  "httpStatus": "Unauthorized",	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
76d7e37c-4af7-4c42-9438-8e2e7d53b120	  "httpStatusCode": 401,	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
53b38491-39cb-45a9-aa27-db4502cf4dec	  "status": "ERROR",	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
e7b9112e-6f81-4e71-aefb-b8adb829fe33	  "message": "Unauthorized"	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
191b7aed-0848-44cc-9eb9-6d0012d7a015	}	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
fd8b337f-c0a6-4507-bfbe-457fa4a94e68	✗ Error at Wed Aug 02 2023 09:05:16 GMT+0000 (Coordinated Universal Time):	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
b97502f6-cebd-4d6c-92ac-713559c775ee	∟ Request failed with status code 401	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
4894978a-e640-4ca5-9bb3-f5469bf24798	[R/T] ✘ Error in runtime execution!	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
1a44c509-6eff-4824-b65a-64247e28314b	[R/T] ✘ [object Object]	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
c2c9eac8-f0b4-463f-babb-7f6e1d7d381c	[CLI] ✘ Error: runtime exception	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
5da52c70-6bd7-4279-86b4-f646bd9760c7	[CLI] ✘ Took 614ms.	\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
5d92deda-1fed-4888-8a5b-c17bca4eca4d		\N	22b35b22-fd53-4bd8-9b33-d8671033fef8	2023-08-02 09:05:16
22e8b194-2919-4554-afe8-c6508f02d24b	[CLI] ✔ Loaded state from /tmp/state-1690928433-7-16f7lye.json	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
017cef2b-d4c5-419a-8329-c002ce08693a	[CLI] ✔ Compiled job from /tmp/expression-1690928433-7-1mo9mhf.js	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
968174a5-32ce-45dd-9881-8cfe09f53eb1	vm:module(0):1	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
97ef1e0e-4713-4adc-9c12-579d829ad039	console.log(json.parse(state));	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
a7f71f47-8846-4e71-88f5-5d59f32f4d9c	            ^	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
f5e5eae8-ab30-4ef9-a7d8-88e9e3a6a509		\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
85ea1b27-b6b3-4b83-b7dd-20fae9ef3dd3	ReferenceError: json is not defined	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
3a09c4b0-4d92-4574-8111-6ee9eb8a0e06	    at vm:module(0):1:13	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
41a0d7e6-d6e2-41eb-bf21-65c475301421	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
080f4a97-7f40-42dd-bdbb-2871cff6d783	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
fa09a9b8-7702-4dde-8205-7049c9ae39eb	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
eb41fc36-a967-4dbb-b3e4-9827d349ab64	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
b1819f96-d014-4a66-915e-a352a6c54ddf		\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
896f772b-b31e-4b2b-a952-759a2f177cc1	Node.js v18.12.0	\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
f3a22f6a-3570-4d4d-9dc5-92a871a86ea0		\N	4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	2023-08-01 22:20:34
5a7750ac-ad22-4b1d-a64b-7927533482d5	[CLI] ℹ Versions:	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
561dbc9b-bd2f-483d-a033-8d44ccd29d5e	         ▸ node.js                   18.12.0	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
94b03fcf-c911-4ffa-afca-7f389e59dd02	         ▸ cli                       0.0.35	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
fe5c5a73-f78b-4ed6-b062-e2e82bf9e7d8	         ▸ runtime                   0.0.21	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
38746c1a-1da7-4086-a28d-d839498926e7	         ▸ compiler                  0.0.29	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
35eac3a6-125f-4e22-a159-85564c156439	         ▸ @openfn/language-dhis2    4.0.2	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
d24ad6fa-e890-45da-abfa-5804638cb82c	[CLI] ✔ Loaded state from /tmp/state-1690928526-7-f4kc0t.json	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
273074d3-d80b-49ed-84a8-3fdee9eaf74f	[CLI] ✔ Compiled job from /tmp/expression-1690928526-7-1graagk.js	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
65c6887e-9a0e-46c0-a570-0492c205444b	undefined:1	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
0126197d-aacb-4b72-934e-98312d86712b	[object Object]	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
53e1c8bf-e6ce-46fc-8b59-c287c30774b4	 ^	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
a31a3193-9f6d-44fc-81a9-df031bdf8cd3		\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
896e35eb-9c85-4300-8b92-347e060a7c91	SyntaxError: Unexpected token o in JSON at position 1	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
41349723-a12b-4096-abbb-5ed210166f42	    at JSON.parse (<anonymous>)	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
932e4176-ac39-477c-ad39-9c08d101c4e8	    at vm:module(0):1:18	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
f8a47605-f1bb-43c8-a0b3-cc7a46ea1c21	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
8d2a927f-1da8-4898-830e-aa6cdec13213	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
042ef512-5013-4291-8eeb-bf9c2baa4db0	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
8f3c0898-b498-4639-8f20-d7dd8e9f3a48	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
aef4b319-aec5-48b1-bace-6deb635a7aa9		\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
74faf3ea-0903-4802-958b-3b76b1c83c17	Node.js v18.12.0	\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
b5cd0cac-c7a3-4ecd-babd-e2ee2c4050d4		\N	adbbda6f-3bc1-4b7a-b613-9085c00184a5	2023-08-01 22:22:08
35faeaf6-bb34-479e-b59a-59bc75dc6690	[CLI] ℹ Versions:	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
33c96c1e-964b-45b0-928f-a61e1a200ad5	         ▸ node.js                   18.12.0	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
33fa253a-500a-45a8-9186-7528b56c1ec1	         ▸ cli                       0.0.35	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
d330d3d6-9e76-4988-8bea-7b392e488880	         ▸ runtime                   0.0.21	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
43e14588-d008-4656-bbbd-99fe211bd676	         ▸ compiler                  0.0.29	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
8b3eaca9-880a-43e0-a4f6-8b3d025ec09b	         ▸ @openfn/language-dhis2    4.0.2	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
c32b1b80-87d9-4dc3-8cfa-e4d082f1c9c2	[CLI] ✔ Loaded state from /tmp/state-1690967180-7-vafpwh.json	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
a7c10148-f8b1-459c-9b17-f3bc208c5317	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
dd49da3b-d628-4c2d-9610-c3ba849b9742	[CLI] ℹ Versions:	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
e1f57519-548e-4cfa-b9f9-8e4c6af8017b	         ▸ node.js                   18.12.0	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
99201d62-213c-4c50-a2cf-074b107a5560	         ▸ cli                       0.0.35	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
304ba07b-07ac-4426-94a3-066728a4b085	         ▸ runtime                   0.0.21	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
258ad9fa-5ace-4960-815e-0e6f426efa9e	         ▸ compiler                  0.0.29	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
93f47679-0b17-4aca-9c69-959d2f9272d3	         ▸ @openfn/language-dhis2    4.0.2	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
53246d90-e5ed-4692-8bb3-1c131ce41fdf	[CLI] ✔ Loaded state from /tmp/state-1690928657-7-mqnut4.json	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
7d31c9cf-dd21-4b45-a2f9-4db99106b478	[CLI] ✔ Compiled job from /tmp/expression-1690928657-7-ao2a7e.js	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
37517b95-e017-4b66-a096-4e4376126d7d	[JOB] ℹ undefined	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
7d3581ff-d2ab-4b7b-8770-bdac0ab80126	[CLI] ✔ Writing output to /tmp/output-1690928657-7-yevvcl.json	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
8af6cc05-025f-4593-92c5-cf378ee0ccb8	[CLI] ✔ Done in 163ms! ✨	\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
059fce52-8c8c-4c79-a0f4-309bcedb4f92		\N	b3655c91-56bb-443d-92c2-291c7026708c	2023-08-01 22:24:19
d50c4310-d1a2-45af-bfd5-0b93f773a9a1	[CLI] ℹ Versions:	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
9654b077-4ac4-489a-a1ad-01aef4f79025	         ▸ node.js                   18.12.0	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
1ec1673b-e0a7-4d62-87b3-83dc7877bb74	         ▸ cli                       0.0.35	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
65ce6a4a-6e24-43fd-992f-d034b102546e	         ▸ runtime                   0.0.21	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
8b2b1e59-d9cc-4276-83f1-589aaa817305	         ▸ compiler                  0.0.29	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
5dd03a38-f104-4713-a3c4-d1d792809545	         ▸ @openfn/language-dhis2    4.0.2	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
61349401-d360-402b-9eb7-2137b75f90f8	[CLI] ✔ Loaded state from /tmp/state-1690928727-7-1321s9t.json	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
f95d7a01-5983-456d-963b-038efebf73ae	[CLI] ✔ Compiled job from /tmp/expression-1690928727-7-z3phun.js	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
f504bb31-7c67-4a3f-a70f-c25fdced3824	undefined:1	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
ea7151f1-0dbc-43f0-b6e6-3cb19f7752cd	undefined	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
c689caaf-053a-4ffb-a328-6e12b321532c	^	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
35a36753-f5f3-4350-978e-fbab542ee102		\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
7ef4f6d7-6853-4d3e-b38c-2525ab1c8f8d	SyntaxError: Unexpected token u in JSON at position 0	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
ce47d655-bbbc-4f49-9ac7-8778e5649b81	    at JSON.parse (<anonymous>)	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
8607b246-5d42-49eb-a4be-80615bf9b602	    at vm:module(0):1:34	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
b1260775-bbb7-4579-8b29-fa1c333c078e	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
47f4083a-7b41-4534-809c-970bae0ea581	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
810ae047-67dc-44de-afd1-a2eb94e7b910	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
57125cff-6eb9-47dd-8032-2488bc65abdc	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
7aabb4a4-9b80-4909-a5a5-999032dad153		\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
98b62dcd-158a-4426-9bd7-c1541a088617	Node.js v18.12.0	\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
52a719a9-7cd6-4b7c-ab36-95b3ec370b6b		\N	65425974-461f-4e92-be1b-4501f22c3d4b	2023-08-01 22:25:28
1486fdfe-5504-49fa-a403-cb29645d2104	[CLI] ℹ Versions:	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
e2b8d342-c0f1-4725-9893-65cc41662bda	         ▸ node.js                   18.12.0	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
93c41d43-0d88-4e30-bccc-b00ef3b66868	         ▸ cli                       0.0.35	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
c9431d66-7ce6-4f38-9050-3152bb179517	         ▸ runtime                   0.0.21	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
03f4b150-4c6a-4f98-b613-788716b810ae	         ▸ compiler                  0.0.29	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
005a4b26-2222-4f23-8508-06f3fdab340b	         ▸ @openfn/language-dhis2    4.0.2	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
f6cab28f-82ae-455e-83d3-8b2780bb27a6	[CLI] ✔ Loaded state from /tmp/state-1690928788-7-72t4ab.json	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
98d74c2d-cf2a-4b2d-8d8e-54a4344a9624	[CLI] ✔ Compiled job from /tmp/expression-1690928788-7-1k8tbzy.js	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
5836a536-d6c2-4ea0-b541-d7db9f11d6a0	undefined:1	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
f145a450-16c3-4e20-8907-5b7185267421	undefined	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
b6846525-6635-4d35-b0df-1cfc67a0fe21	^	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
35848e64-6a46-4c5c-a2eb-d808b11e17a8		\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
5859926e-068d-491c-b70e-323674f0e4fc	SyntaxError: Unexpected token u in JSON at position 0	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
a3f944ba-cb1c-44d1-b328-f9e8d50a537c	    at JSON.parse (<anonymous>)	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
323c022a-fefd-4f62-a5e8-b7414b96f679	    at vm:module(0):1:34	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
304226fd-a807-4112-a0a2-8448266a36df	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
2059c4ef-c233-4e27-9f74-32a071a3a44a	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
45c2cdff-6dfd-43a7-b7ef-14fe3a3497f6	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
d3de8607-9b2e-47c1-a24e-7a5569e3bf95	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
8074981a-5106-4761-ab73-5dcb1f2d8c79		\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
80afb3bc-fca0-46e4-970e-d0a7b41b7980	Node.js v18.12.0	\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
0bca8259-5d32-4c2b-a3d8-5deb9dac7964		\N	c633ab0e-2f64-475e-982e-f4ff2bb90239	2023-08-01 22:26:29
c2cb537e-b72e-46ab-ace7-5c01145c1fdb	[CLI] ℹ Versions:	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
792628c8-8a84-491d-b943-06478ba9b2be	         ▸ node.js                   18.12.0	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
f4a4e8b2-657f-480b-9397-18278307a00d	         ▸ cli                       0.0.35	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
4c605689-322b-4c48-9ee5-ac73e3ed7ab2	         ▸ runtime                   0.0.21	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
5dc1421f-46cb-4a40-afc5-f25893765863	         ▸ compiler                  0.0.29	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
1ab1fb3d-fde2-4e99-a426-e6e3f2536419	         ▸ @openfn/language-dhis2    4.0.2	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
159dad41-a58e-4fe8-8c99-b9142792b40e	[CLI] ✔ Loaded state from /tmp/state-1690928832-7-evsvpx.json	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
54e427bc-e8ee-4ed8-93ce-7c80bba49705	[CLI] ✔ Compiled job from /tmp/expression-1690928832-7-17o4x1i.js	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
00b71436-dabb-47a2-a84d-0f5316d424ab	undefined:1	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
15194cc0-eded-4c79-88bd-f5de1d642ba9	undefined	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
87f4e39c-6df4-4d4e-a138-f3af87dfc06e	^	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
fe63f6f2-c901-466e-a298-42d952ee7405		\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
821228cf-c351-43ca-854f-0c8638fead37	SyntaxError: Unexpected token u in JSON at position 0	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
68a47a89-5cc8-48a0-9727-692f6894de83	    at JSON.parse (<anonymous>)	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
ae291761-a484-46bc-b213-2d32c9464669	    at vm:module(0):1:34	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
d0d11367-6ffe-4bc9-9c20-8c6b31c9520f	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
ef3b2386-f3aa-4078-97e5-640877654c8f	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
13af99ec-cf69-4ea8-a010-96bab72fadf1	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
bb66a753-d744-4015-84d2-075bcd19e4c1	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
3485a233-c36a-4900-a2c8-332f8ce250a2		\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
028ed6b1-7e4e-4ad2-bce4-ebdb14903d37	Node.js v18.12.0	\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
90ad0bce-2869-4788-8ce5-5e65c74cf398		\N	6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	2023-08-01 22:27:13
6084f4da-14d5-44a6-b427-f58fe67e7a03	[CLI] ℹ Versions:	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
ed543d5c-f7ad-403b-9d5d-0d299fb24347	         ▸ node.js                   18.12.0	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
530db22b-b8f2-46bd-97a2-05c86653a244	         ▸ cli                       0.0.35	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
b40bdd85-c5fd-4648-a377-01a36115f914	         ▸ runtime                   0.0.21	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
702c2d72-3a2b-40e4-bbb5-bddc477c30ae	         ▸ compiler                  0.0.29	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
65a79b03-086e-45d7-abf2-a825405f52f1	         ▸ @openfn/language-dhis2    4.0.2	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
b625ff8e-f701-47fe-97b2-9d5722211879	[CLI] ✔ Loaded state from /tmp/state-1690928859-7-7d2dj5.json	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
9cd6bd9e-8936-47e3-abe0-edc9d668cc36	[CLI] ✔ Compiled job from /tmp/expression-1690928859-7-1f9zghi.js	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
4efec910-4d42-4859-905b-56f6c9c75e2a	[JOB] ℹ undefined	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
6097e450-e32b-47b7-81c3-5b6c06dcf75a	[CLI] ✔ Writing output to /tmp/output-1690928859-7-fvr6oc.json	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
0df368d7-0a39-44cd-bdb4-82fa46cb6874	[CLI] ✔ Done in 176ms! ✨	\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
13480dac-e94d-48ae-a543-273a7eb61fd9		\N	aca8d8c0-cd31-4fb3-8814-a23545009e69	2023-08-01 22:27:40
45667dbe-f87b-4593-8c28-0701302265f0	[CLI] ℹ Versions:	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
1949c417-fcb5-4801-bea2-dc1be1372e74	         ▸ node.js                   18.12.0	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
971bf3d1-3387-40c2-b955-1710477249d7	         ▸ cli                       0.0.35	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
fcab050e-7b47-4c2e-ba8a-69768ebf3e0d	         ▸ runtime                   0.0.21	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
caffa2fc-1764-4c4f-b4f8-ecf58a38dbe3	         ▸ compiler                  0.0.29	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
6b2caf10-156d-4157-b2b4-67777c072d20	         ▸ @openfn/language-dhis2    4.0.2	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
dbbbe076-8b22-455d-8af2-3f8afeb608be	[CLI] ✔ Loaded state from /tmp/state-1690928907-7-1usmq06.json	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
3677fd1a-5094-42dd-9f3f-19228f35f805	[CLI] ✔ Compiled job from /tmp/expression-1690928907-7-10xeo6p.js	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
7cbbdd28-51e2-41d8-9309-a764007729fd	undefined:1	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
1751b398-1b66-4f67-91f6-e5c5e1879ad0	undefined	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
9cf090d8-e9a5-4a04-b443-9222cd393cba	^	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
508b6854-4043-42d7-a22c-ebccabddac51		\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
118ea312-9b1a-4b60-b97d-ab827d05d565	SyntaxError: Unexpected token u in JSON at position 0	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
a7e97d13-6928-4df1-b67c-e2a4e3fe477d	    at JSON.parse (<anonymous>)	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
f57acf55-bae4-4785-b1cb-18a5652c7bb1	    at vm:module(0):1:18	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
630976f7-5142-441d-8b24-38526e5f00db	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
0a8d91ba-113d-4248-af7c-0176ea928243	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
e91023ae-18bf-4c5a-8057-1f74ef09fbe2	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
71e484c5-bda5-4eb4-85e5-eef95915ddee	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
0414af8d-100c-47c8-8b83-f9a995605396		\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
ebc9d219-6d3a-4b67-a730-da2f8cc49a15	Node.js v18.12.0	\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
8ce34dd8-f0d2-4221-892d-f14eeec157dd		\N	8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	2023-08-01 22:28:28
e1b665fb-f402-472f-8c6b-488d81199296	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
28f287a8-1d02-49d2-a96b-81b42b2d3bdf	[CLI] ✔ Compiled job from /tmp/expression-1690967180-7-1cvcs88.js	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
0a92be8d-018d-473e-b075-1e5dfbd40f0c	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
7999ddc5-696c-4761-8cc0-f5997ed2dffd	[JOB] ℹ BirthDay: 1980-01-01	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
89bcc105-8abb-40f2-8050-bab4cd63cc02	[JOB] ℹ firstName: Demo	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
4bba645e-6327-4fd5-bf27-f41000d8f889	[JOB] ℹ Surname: Test	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
c2fb8ec0-da83-4ad1-9446-d1b2b75b45b2	Preparing create operation...	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
61e09d4a-7c76-43c6-a930-bcbb836c1070	Using latest available version of the DHIS2 api on this server.	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
3828f42a-ce35-4136-b4f6-57b098fcd1f6	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
4c87aa74-ccc5-4035-b4b4-35684324d00b	✓ Success at Wed Aug 02 2023 09:06:22 GMT+0000 (Coordinated Universal Time):	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
eb9c25f2-b9db-47ab-ae08-734d9a447baf	∟ Created trackedEntityInstances with response {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
5c2a25f1-1453-487a-a2dc-51e2aee74797	  "httpStatus": "OK",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
396fb36e-4db9-4f2f-aaae-19835c678daf	  "httpStatusCode": 200,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
e94a001a-ed2a-4a87-82b4-931fed72adf7	  "status": "OK",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
f2357abf-a146-42a5-a17a-2d04a0ae40b5	  "message": "Import was successful.",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
2fe33bad-eedf-45a8-9fbe-d7305bd1044f	  "response": {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
1d1170f8-4ce9-477c-b0fc-964c2455975b	    "responseType": "ImportSummaries",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
310de138-475e-42a8-95aa-5da0ea429cf2	    "status": "SUCCESS",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
f3a5df5e-e0f5-4d90-801e-f26ab2ea37db	    "imported": 1,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
3631fdd1-469b-467a-b282-59fea44d26cc	    "updated": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
e906a36b-210d-4d31-9fb0-d728d01dcd4b	    "deleted": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
dc7dbe7f-815f-42d0-8c7f-8b0ce61b90e1	    "ignored": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
779a00d5-a690-4d53-ad79-f3668a082fd6	    "importOptions": {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
ab70753c-21e5-4d45-b1b9-e478cf23a18a	      "idSchemes": {},	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
480b5a5f-8afc-4f4e-be4c-589edcda9885	      "dryRun": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
6bdedb29-d531-4b8f-bfd2-962c21aaadba	      "async": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
8e303646-4101-4da7-8bf1-1ab7558ed277	      "importStrategy": "CREATE_AND_UPDATE",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
a524bf2f-06a8-436f-bd47-369dbeafed73	      "mergeMode": "REPLACE",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
e39acae1-fa30-472c-a5ca-bca20b4e430c	      "reportMode": "FULL",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
1c873c6b-ba35-45a4-a28d-7d50afb77ed5	      "skipExistingCheck": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
da8dab58-282f-4161-8afe-e6c98223bce6	      "sharing": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
7409cb0b-5735-4c46-a82e-649a914032e3	      "skipNotifications": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
d87e04f1-dfed-4445-8a80-5ff5aad39ede	      "skipAudit": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
25076c80-a14a-4565-8f2a-8730672c3e22	      "datasetAllowsPeriods": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
113abdd6-eafc-4627-82c0-a393fc46f312	      "strictPeriods": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
219e22e3-5faa-40be-8206-23e7a57544bf	      "strictDataElements": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
d1333443-2462-4d1c-9cd3-829d022585d2	      "strictCategoryOptionCombos": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
1649d3d0-6332-4af3-aba1-545d9c80f2aa	      "strictAttributeOptionCombos": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
90ac071e-f53c-4c7b-b08d-f5878e94ec39	      "strictOrganisationUnits": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
e490e2e8-d611-4f9f-acca-8a3cc9e65109	      "requireCategoryOptionCombo": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
96be6f32-a51c-41f6-8804-8ee9e84a8f49	      "requireAttributeOptionCombo": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
7214cc12-b853-426b-9e63-19f31f4da3f3	      "skipPatternValidation": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
3afabdda-356a-437c-8aff-1843785401f5	      "ignoreEmptyCollection": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
6bc18ab3-f6f1-40e6-86c4-4060305d5529	      "force": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
8cb2b8de-e016-4d97-b319-bd073fc1f1a1	      "firstRowIsHeader": true,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
71b6655f-e60a-4347-8933-e6963f42e15b	      "skipLastUpdated": true,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
edea24ed-36a4-486c-95a9-c8cab8dad4e4	      "mergeDataValues": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
93af588b-c384-419c-a773-2a352832ce95	      "skipCache": false	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
fc12145c-9867-4e3e-a5c3-5e6792e730e0	    },	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
00b2fca4-c5c1-4717-8ff9-3846739ae142	    "importSummaries": [	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
16b36ebc-0265-4b34-b4bc-35cc94768fa9	      {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
a302e443-7bc6-4b67-a52e-90db4deb914d	        "responseType": "ImportSummary",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
20ae1b03-6b04-49b4-9063-20fc56a8253d	        "status": "SUCCESS",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
5f715199-4af7-416f-a735-b1d795efc409	        "importOptions": {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
60c16116-db5c-45de-85e4-5242f4382f70	          "idSchemes": {},	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
3009527a-93b4-4edc-93db-6a721984338e	          "dryRun": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
104b79e0-d89e-4c7e-83cb-cc29363b89ab	          "async": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
ac4da72a-499f-4388-812e-69668749c2c7	[CLI] ℹ Versions:	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
0c984944-5dea-494d-ac32-25e9b44a58a9	         ▸ node.js                   18.12.0	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
62e6eab4-ab88-4d3d-847d-6324aa5e0eea	         ▸ cli                       0.0.35	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
c537dd54-d9d2-4bc7-b7a5-3926f593f2e9	         ▸ runtime                   0.0.21	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
a8ba670f-fc35-4104-90ae-cbe96e52ca8b	         ▸ compiler                  0.0.29	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
33e8b1b8-2575-43d6-8ec7-427e1d71bdd0	         ▸ @openfn/language-dhis2    4.0.2	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
e05778f1-2a47-43b8-8f11-41454e993d88	[CLI] ✔ Loaded state from /tmp/state-1690929044-7-1xv9xyu.json	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
102b7dd7-c2c9-402d-b601-93130766ca6e	[CLI] ✔ Compiled job from /tmp/expression-1690929044-7-1rj7bxr.js	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
4aed19ee-83fc-4f44-a157-1c29b455ad2e	undefined:1	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
3895cff0-1019-4538-ac80-c9f151e06953	undefined	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
c1360cdb-32ad-472c-a82a-0b604279cc85	^	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
19693e23-33e3-4ab5-992b-d0fef216f396		\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
ab1ed115-d77e-4d0b-a6a0-c802bb91053f	SyntaxError: Unexpected token u in JSON at position 0	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
ceadefb4-fe26-4349-b334-933dced4ee4b	    at JSON.parse (<anonymous>)	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
1013d55d-e68a-45ee-b718-792b7bf0f88b	    at vm:module(0):1:34	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
b8f2048d-4dc2-41b0-8309-ff34eed70887	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
85b87562-979b-4a5a-bb83-d8f6e31f66fd	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
e1ca0734-7724-4f18-9d21-b4ff36d7aef7	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
3712f5c3-ebb5-4e6c-9a7c-b980c6f7f3fc	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
d3885e49-6a6a-49d9-9591-423c539d9982		\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
9a1f7f48-6190-438d-a310-85ffb862e32f	Node.js v18.12.0	\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
0caadb67-4271-4453-b8ce-c7badb02ab02		\N	0a2695aa-d3a2-46e7-94c6-57945786accb	2023-08-01 22:30:45
35ac65af-691b-47e7-a70a-ae4895b70c74	[CLI] ℹ Versions:	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
3dcff2d7-45a4-4b12-af28-645371da4a5d	         ▸ node.js                   18.12.0	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
79d87758-495d-46f3-b7e9-e6600a3c7714	         ▸ cli                       0.0.35	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
97d3e42f-83c7-45ba-95a1-3ebc3330f282	         ▸ runtime                   0.0.21	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
4500c442-a655-43b9-894e-d3bb0d6f06fc	         ▸ compiler                  0.0.29	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
4df38916-1e3d-4b91-aff0-f160e70c6c0a	         ▸ @openfn/language-dhis2    4.0.2	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
d7434dcf-b90e-40e6-a6b6-84bb2c2c8a92	[CLI] ✔ Loaded state from /tmp/state-1690929227-7-1elfm5w.json	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
70498340-9718-4887-a5c7-2c10b02d6ccf	[CLI] ✔ Compiled job from /tmp/expression-1690929227-7-1avf1m8.js	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
3d4e22ae-e930-43c2-aa99-ace42103072d	[CLI] ✔ Writing output to /tmp/output-1690929227-7-1e4hppe.json	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
3140275e-2530-4e2e-8a5f-87ebdedd70cc	[CLI] ✔ Done in 185ms! ✨	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
87ce0ab2-cae5-407f-a101-d7861553223b	[JOB] ✘ Error parsing JSON data: {}	\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
29c5d38c-ff64-44e0-abef-8acc5430f261		\N	9279935c-5d1d-4522-8170-780cd005ff9f	2023-08-01 22:33:48
1ab7cace-34e9-4ebb-bdf4-22bbc6159cf1	[CLI] ℹ Versions:	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
0b1c24fb-d6ed-4cbd-8216-00444ded069d	         ▸ node.js                   18.12.0	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
d7b71393-29eb-44fc-9715-e1f8bacc9755	         ▸ cli                       0.0.35	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
2795c41d-e6c7-45c8-9e88-d8759662d039	         ▸ runtime                   0.0.21	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
5223e5e3-3af4-436e-8d53-0f56c6a8be30	         ▸ compiler                  0.0.29	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
db74e583-e1f7-464a-8d54-8e2bbbf4ea44	         ▸ @openfn/language-dhis2    4.0.2	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
46089180-2f15-4210-8431-8bb28e6d34bd	[CLI] ✔ Loaded state from /tmp/state-1690929378-7-av8o9t.json	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
7b27b90b-bff3-476c-a600-067ae4c9ca99	[CLI] ✔ Compiled job from /tmp/expression-1690929378-7-8qk1qr.js	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
5c4e2d32-6805-430a-9fc1-f3359a08d73f	[JOB] ℹ state.data.body: undefined	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
afd03b76-2d09-4e32-a009-5fac5911654b	[CLI] ✔ Writing output to /tmp/output-1690929378-7-1q6psdi.json	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
5c8c158c-baac-4015-bdc3-475c45dd6ac0	[CLI] ✔ Done in 179ms! ✨	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
d6022312-9c78-4b98-9688-15310002a12c	[JOB] ✘ Error parsing JSON data: {}	\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
c74351ff-2803-4966-8852-c06906aa0b16		\N	1dc183df-6429-4fdf-8eaa-767f9edaba58	2023-08-01 22:36:19
2db69344-7e62-4253-9e3e-c5d03f49751a	[CLI] ℹ Versions:	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
48e1dd51-c561-43ad-82f1-82de2d6905b2	         ▸ node.js                   18.12.0	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
8469490b-7b1f-4f53-a367-f9adac88b0bf	         ▸ cli                       0.0.35	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
180f1335-f63c-4c3e-9e9d-45459ee5f80f	         ▸ runtime                   0.0.21	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
e286f59e-5300-4221-8be8-e35e06189d89	         ▸ compiler                  0.0.29	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
87e8c94c-4726-4562-8254-9f3e61b3f895	         ▸ @openfn/language-dhis2    4.0.2	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
ba62bad5-f2c9-47c5-a57b-307f2403cf20	[CLI] ✔ Loaded state from /tmp/state-1690929537-7-1b7o8p5.json	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
d33497b4-da69-412f-aeee-c4dcc9d58c79	[CLI] ✔ Compiled job from /tmp/expression-1690929537-7-1jsxee9.js	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
b33b41d5-5042-4064-a9ba-87bbd0b4f89f	[JOB] ℹ state.data.body: undefined	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
11f0cee3-7fc5-4408-98fb-9607323141f5	[CLI] ✔ Writing output to /tmp/output-1690929537-7-rb2arv.json	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
d53afbbc-2ae6-44f3-8526-23d742b69c25	[CLI] ✔ Done in 184ms! ✨	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
dce35534-57c6-4313-a5dd-465428853974	[JOB] ✘ Error parsing JSON data: {}	\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
136e31a2-23f0-4c31-9e64-2b14cc58315f		\N	d037a10f-f4a2-47d4-ac45-d64ed6502c0d	2023-08-01 22:38:58
4c7f70d2-e699-480a-a162-319f131b55c6	[CLI] ℹ Versions:	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
8b960674-0bd9-48d3-8d8a-3931a6218dfc	         ▸ node.js                   18.12.0	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
76e6ebe7-0d55-42c3-98ed-f6bbf4470d68	         ▸ cli                       0.0.35	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
bc740003-9a80-46f5-93e6-13d1d1e295b2	         ▸ runtime                   0.0.21	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
9ce3a4b4-d06a-4155-90ce-86b0983ec495	         ▸ compiler                  0.0.29	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
b846180f-dae2-400b-9ffe-02ebfe077a6f	         ▸ @openfn/language-dhis2    4.0.2	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
acf7c82f-6445-4a9f-a8e0-8c6d436d9922	[CLI] ✔ Loaded state from /tmp/state-1690929566-7-t06613.json	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
f19c73d5-9b51-48bf-b85e-b3ed10a4196b	[CLI] ✔ Compiled job from /tmp/expression-1690929566-7-139tbft.js	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
9c9dbf1a-e247-4a10-9a81-417af625f79c	vm:module(0):1	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
9a109cb4-6a86-4045-8e5f-dd359edfdc03	console.log("state.data.body:", state.data.body());	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
b3c2d75d-4fbb-4f4f-b961-a7d95b4b31af	                                           ^	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
ca96655d-2189-4374-8e81-d860eba51a99		\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
467ebaef-5dec-47f6-bbd8-8b48cbac3b54	TypeError: state.data.body is not a function	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
8f4ffb8b-23f3-4dec-bec1-3bc62258248d	    at vm:module(0):1:44	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
c01be86b-9cf7-4833-8d1f-939ffc679485	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
2123293b-08de-4e9e-8658-5669b69da953	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
f220c426-36ee-4dd7-9c9a-a16e201781f4	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
a7a2c2d3-2f3c-4e0e-ae5e-a3b2580668b4	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
c48b4f70-0dae-4874-bc8f-c1da142db0dc		\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
d94ec90a-e351-4ddf-a0ca-1458625d253f	Node.js v18.12.0	\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
3b0cc022-7560-4c4f-96f8-ecbe3b66a745		\N	a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	2023-08-01 22:39:28
b16172e2-e5e8-46f2-a52e-493a937fc5bf	          "importStrategy": "CREATE_AND_UPDATE",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
1a02cbff-32e7-4da8-9b17-3ebf5209e233	          "mergeMode": "REPLACE",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
2e51d27e-c290-427c-a70e-9c71a25ae3bc	          "reportMode": "FULL",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
5f5c2325-3392-4ecf-b952-448fb9c64d3e	          "skipExistingCheck": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
07f71fea-f3cd-493f-81a2-882c1ccaff25	          "sharing": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
fb5f6acd-dde8-4f6b-b77e-196efd76cbc4	          "skipNotifications": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
af3cfb76-71af-455d-9897-6dd5d2c7a70f	          "skipAudit": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
f18186af-72dc-4fbb-ad7d-9c19640cf452	          "datasetAllowsPeriods": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
332e63f5-a7f1-449f-b749-5270ac06ab8e	          "strictPeriods": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
83e10784-4e9b-49ec-b244-077cc7f7a04c	          "strictDataElements": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
fd00b2ee-5490-44de-8a02-6c4d1a22e659	          "strictCategoryOptionCombos": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
83f4d8c5-23f1-4874-8300-0ab32d7f3ae5	          "strictAttributeOptionCombos": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
ebe6a3c3-06f5-409f-831c-c07a57a2d21f	          "strictOrganisationUnits": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
22812507-c0f9-4a60-b9b6-b1deca3d76f8	          "requireCategoryOptionCombo": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
9667dba9-50b6-4cac-9346-64e902a1dc2c	          "requireAttributeOptionCombo": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
ed1a9783-8b73-4b1f-b26a-5d01a7a86dcd	          "skipPatternValidation": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
14c32836-565a-4aac-a4e7-22adcd2f4f3c	[CLI] ℹ Versions:	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
e6b2dd0b-1cc6-4c91-b354-8ab1acb56ced	         ▸ node.js                   18.12.0	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
659b179c-ff57-4739-8a16-acd454e9b553	         ▸ cli                       0.0.35	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
167ccc46-4004-47f6-b3da-c91637d4f252	         ▸ runtime                   0.0.21	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
24101a75-9830-436f-9a16-c95ea5666b82	         ▸ compiler                  0.0.29	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
19d19055-d51a-4600-b6a7-7269330178bf	         ▸ @openfn/language-dhis2    4.0.2	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
aa9cfbc0-1d7e-4948-84d2-0cb508c64a4c	[CLI] ✔ Loaded state from /tmp/state-1690929720-7-wweamy.json	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
e9712d72-0506-4a12-938a-eb623b0b9c38	[CLI] ✔ Compiled job from /tmp/expression-1690929720-7-kldcng.js	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
0ec972b4-873a-4fa0-9e48-50d3d7529ac2	[CLI] ✔ Writing output to /tmp/output-1690929720-7-5edfnf.json	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
3807ccc6-c234-404e-a941-89246d704d24	[CLI] ✔ Done in 168ms! ✨	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
569833c2-0a45-4358-a327-a4c903f004bf	[JOB] ✘ Error parsing JSON data: {}	\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
bee96ede-ee9d-44a8-8379-8bf2169aa250		\N	3cd86d96-2098-4dcb-ae71-35fc242001fa	2023-08-01 22:42:02
2d61e235-8f56-46b1-ad16-af7e0797ba55	[CLI] ℹ Versions:	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
8e4a0260-7a33-42e1-8c4e-910517d149b2	         ▸ node.js                   18.12.0	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
2f73a5c4-b751-4814-86cb-ee276734aa09	         ▸ cli                       0.0.35	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
0174c7ba-2934-4803-b5b0-12f30b17a751	         ▸ runtime                   0.0.21	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
3538bb67-4488-4822-b5c4-5146235cc2d7	         ▸ compiler                  0.0.29	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
d989afdd-4580-4d6b-a396-fdc9d2724868	         ▸ @openfn/language-dhis2    4.0.2	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
9f10ec20-f6ba-486f-91f9-ddc2ace490de	[CLI] ✔ Loaded state from /tmp/state-1690929801-7-9k4y8w.json	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
d3bde5fb-4397-44d8-bc0c-8f1f4e7b10e9	[CLI] ✔ Compiled job from /tmp/expression-1690929801-7-j4l40w.js	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
edce8466-d9eb-4f48-946f-92adde291584	undefined:1	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
f1b123c4-863b-4ef3-927c-d811d552cd95	undefined	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
6dd65532-09ee-4c51-ac49-9c16a4856696	^	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
87be3ff3-7249-4ccd-be3a-8a033acd33ef		\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
f9ef8371-b4ad-43d8-9e97-e80d1cc4d6cb	SyntaxError: Unexpected token u in JSON at position 0	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
08379041-868a-42a8-a37f-0513a4ed6e2b	    at JSON.parse (<anonymous>)	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
fe45a1e5-9bca-4b73-82ba-bdc2237c0103	    at vm:module(0):1:34	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
294b253f-9ea0-48d5-b658-7f18e35bee74	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
77e69c2b-4084-43a2-b4ce-a22e8c5dbc82	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
136a76c2-0921-4796-8b95-2628bcda8ef4	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
e4988833-e342-4789-96db-5bf69b0b2d42	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
f213340b-09ce-46c0-ae7b-8a4dd7f87d7a		\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
f1265112-2097-4635-9bfd-deda454b1646	Node.js v18.12.0	\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
3f53c745-c7c7-424c-a214-c70dedab23f4		\N	a6ec600a-a29d-4b86-b9c5-471d1f5c629e	2023-08-01 22:43:23
e7f0266c-506d-422e-9bac-930bacdc3b9b	[CLI] ℹ Versions:	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
dc13669d-3d74-4448-81da-e0ed5025d907	         ▸ node.js                   18.12.0	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
98b46b04-282b-4b81-93c1-55035e9d84e7	         ▸ cli                       0.0.35	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
6c3ad173-f868-45bc-aa4b-7aade4c8e6e3	         ▸ runtime                   0.0.21	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
c6552b37-440e-4cfb-8ec3-1674bf8eb0ed	         ▸ compiler                  0.0.29	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
efc22d53-a7d0-4b5b-9d82-11c456cec263	         ▸ @openfn/language-dhis2    4.0.2	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
fd5d10fa-8016-4406-92e9-121d49c380df	[CLI] ✔ Loaded state from /tmp/state-1690929882-7-52zbnl.json	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
26ad1421-b59f-48f1-a8af-f043504217d7	[CLI] ℹ Versions:	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
fe62f80f-7195-4f53-bbde-bf861bc1979f	          "ignoreEmptyCollection": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
b16d5178-8ada-4196-9c04-c72dc2675d75	[CLI] ✔ Compiled job from /tmp/expression-1690929882-7-59ueiv.js	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
53641d60-bb5f-4aec-aec7-ffe4105cd466	[CLI] ✔ Writing output to /tmp/output-1690929882-7-6v8aak.json	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
2e6a233c-204a-44c3-a698-462b96e35160	[CLI] ✔ Done in 219ms! ✨	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
9a6aa64b-8a80-41fa-88c4-c8171080f971	[JOB] ✘ state.data.body is undefined or empty	\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
70726308-62ba-4077-918b-27c054ce4f0f		\N	bab0c7b6-2142-439f-ba83-1fd3f0dfd615	2023-08-01 22:44:43
c52fbc76-9ea7-4472-ab75-a0cdd90f7b9f	[CLI] ℹ Versions:	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
a34dd2bc-0989-44a5-88e0-c350d536520a	         ▸ node.js                   18.12.0	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
1573bd03-7b99-4f76-823b-70ea5b6e7c95	         ▸ cli                       0.0.35	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
7623bd9c-3a42-465a-8b08-da822e21e541	         ▸ runtime                   0.0.21	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
bce075ea-f8ba-4165-a33e-2ec65f69808b	         ▸ compiler                  0.0.29	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
a2b3a12c-7f76-4059-83dc-12bc84e44410	         ▸ @openfn/language-dhis2    4.0.2	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
65b0e926-51b1-4dfa-becc-58c2ada6d67c	[CLI] ✔ Loaded state from /tmp/state-1690930466-7-rguhef.json	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
d457d722-a3a7-46de-8cc6-3ca6a44a8e1d	[CLI] ✔ Compiled job from /tmp/expression-1690930466-7-l6ueil.js	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
e7e777ea-0ccd-46f8-b021-49417c9efc68	[JOB] ℹ Hel Mahao	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
00e6d1b3-7543-40f2-91dc-52db01570c20	[CLI] ✔ Writing output to /tmp/output-1690930466-7-1atzy2l.json	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
a0605cc0-55c2-43fb-9a74-5309828300ee	[CLI] ✔ Done in 185ms! ✨	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
8b8ba1b5-eee8-48b8-9da8-c92ca5956d7e	[JOB] ✘ Error parsing JSON data: {}	\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
b266e9a3-b406-4bb6-b2e7-cb01fd3ec3f2		\N	8cee7e50-7229-404c-8b5f-bc40bcc6229c	2023-08-01 22:54:27
441d132a-1f28-4d03-b1bb-2e8592e6ef1d	          "force": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
0db94be1-8284-45b4-9fa1-3e48ef17f60a	          "firstRowIsHeader": true,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
ae9e1e02-94fa-487f-9da7-dafa1e30e4cf	          "skipLastUpdated": true,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
ea3400b3-1609-4b87-b44f-e42042c22b79	          "mergeDataValues": false,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
14432ff0-9a63-4db3-b19a-ba1594543d66	          "skipCache": false	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
65e9413e-7415-4183-8cfb-c1512d133846	        },	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
e7089542-e708-4cd2-a940-fc15f2af87b7	        "importCount": {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
db408cfb-79af-4cf2-bdee-8808a5a2cdcc	          "imported": 1,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
cd1e2166-78b8-41de-9421-a69cda87e571	          "updated": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
977168fb-e5e6-41e6-94e0-bbfd5f11cf98	          "ignored": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
9a838d44-12c7-4719-b214-28d8a114bc7e	          "deleted": 0	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
b7f7bed8-881a-4241-90af-a9bbb7b13e08	        },	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
16a84ad5-035e-4b0f-aacf-d0c5320c95b8	        "conflicts": [],	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
f3769403-da28-4fb5-8f95-8458a727970b	        "reference": "ozc98tcg6nz",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
8686c603-a500-476f-9a24-d08cc98c0295	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/ozc98tcg6nz",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
48c4dc2d-f3d4-4d48-a437-6df7b7a4e18d	        "enrollments": {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
d52cae3f-2ccf-4bcf-a809-21c80293a484	          "responseType": "ImportSummaries",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
84380e46-1913-460f-ba0f-32a3d7664a2a	          "status": "SUCCESS",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
daf5a706-e433-46a8-892b-fe6519ef2ad6	          "imported": 1,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
f2201ca5-4697-4f34-8374-7c251b42a8ee	          "updated": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
94059a1e-cda3-4173-b8a1-593c18b5b722	          "deleted": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
9657856f-a16c-46cd-80df-0b9422542709	          "ignored": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
6050a5c4-3c2c-487f-aaab-94fbe6d7cbcc	          "importSummaries": [	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
786d7af8-a389-4c19-9d4a-127bfe313880	            {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
6475b1ac-f1fb-47a2-b6bf-8ed74e5cf98a	              "responseType": "ImportSummary",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
8817d4b3-b55f-4421-b9e9-d1f0a6d484d3	              "status": "SUCCESS",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
e0091957-cf8d-4c37-819d-75c4f505091a	              "importCount": {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
f899947b-485f-4246-b139-31e24664cb3a	                "imported": 1,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
883be391-ab5a-4ea5-b99b-77cf4456d1d5	                "updated": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
fd4c78d0-15ac-4f82-bc4a-3d71ebdffeda	                "ignored": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
791eda5d-fafe-467e-abc3-68a996c83ec5	                "deleted": 0	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
56f6ad72-58e5-4148-a699-8f8741c597e3	              },	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
74d21229-56f2-4b99-a7ed-5b451597bf9c	              "conflicts": [],	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
67caf052-9d3f-4fd4-9e63-ef77e1d710bb	              "reference": "RckugrV1psN",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
de7581f5-982a-4b54-a248-a82c3e4d56c4	              "events": {	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
1ca5f476-855b-47f1-9cd1-5d1fa89976b7	                "responseType": "ImportSummaries",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
4fbd2eb4-0c38-429d-9572-081ca6376d9f	                "status": "SUCCESS",	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
4231c0f4-09f1-4bf7-b7c3-f704fd3789e6	                "imported": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
f1987553-c7e5-4bb7-956f-66a1ea8ffe87	                "updated": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
8a868249-b755-4afc-bc38-994d8dd5aeb9	                "deleted": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
627d3fa1-3254-4dd8-86e8-94fd1c679442	                "ignored": 0,	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
b8e39079-ab2b-4256-a62c-553289031565	                "importSummaries": [],	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
1cf8e93a-dff8-49e5-a156-6af6104e61ce	                "total": 0	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
b884e6b5-c677-4ab0-8f5a-8ef00baeac11	              }	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
ac0ecaa6-be4d-49c1-a8c6-cd283b72155b	            }	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
813e75d1-688c-49a4-a445-1dfe8035c441	          ],	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
744836ae-892f-48d6-a884-c1cb749ec161	          "total": 1	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
36e485b2-a64e-4d50-8c06-32ee028f0f1e	        }	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
a89d2b58-d134-481e-95cb-ca4765a1be41	      }	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
5e0138b6-85bd-400a-87b0-abaa1379a6cb	    ],	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
4a3d1dc6-328f-4f90-87b2-c17b1d61ab06	    "total": 1	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
609cd769-f0f1-40aa-b3dc-262091092b75	  }	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
27ff587b-d0d7-479f-bfa3-cefac700cc0b	}	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
c567de9e-3515-4eb3-a429-5b2d21b42530	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/ozc98tcg6nz	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
13539d4c-3c78-4027-8f16-68a0f8991823	[R/T] ✔ Operation 1 complete in 261ms	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
b64caf82-d87f-4bb6-ab6d-d18d3fa05fd6	[CLI] ✔ Writing output to /tmp/output-1690967180-7-nrrkq1.json	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
6c2d7cda-3bd1-4d18-830d-c1f25b24d94a	[CLI] ✔ Done in 825ms! ✨	\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
198556b4-c2f3-4cc0-bb9f-151504d81692		\N	8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	2023-08-02 09:06:22
91ca5386-114f-4e54-aff6-fda2b4b383b6	         ▸ node.js                   18.12.0	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
230dc506-a47b-47a7-a840-0de40eba9a10	         ▸ cli                       0.0.35	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
41d917fb-9b56-4ad5-bedf-16380a116a2f	         ▸ runtime                   0.0.21	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
aa5271b4-1cdb-4a84-a842-f9a857e8a424	         ▸ compiler                  0.0.29	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
7e4211e3-d789-4a28-9037-ff4919248679	         ▸ @openfn/language-dhis2    4.0.2	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
a3a474bd-6bdd-4003-a673-e23fb9c2f270	[CLI] ✔ Loaded state from /tmp/state-1690930160-7-u1dof5.json	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
22551054-a0c4-4a20-9274-75a155cf6608	[CLI] ✔ Compiled job from /tmp/expression-1690930160-7-15wgxmj.js	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
3da96fbb-0e26-4cf7-8635-65e74809169f	[CLI] ✔ Writing output to /tmp/output-1690930160-7-e6lnoj.json	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
9bdcdcce-315b-4f9a-873e-6925348c6174	[CLI] ✔ Done in 179ms! ✨	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
4a666d00-cbdc-4591-b21a-4937a9c90a9e	[JOB] ✘ state.data.body is undefined or empty	\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
4fa81d14-1f36-4dea-97ed-7b50427ea24d		\N	d3425662-8dc5-4a41-9cf8-c0255e3ea903	2023-08-01 22:49:21
28dc21bd-3b48-420a-b53c-8fb600fa2545	[CLI] ℹ Versions:	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
1ec35de5-0041-4192-b42a-906b7abf312f	         ▸ node.js                   18.12.0	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
892a183d-8d7c-4f64-a16d-3efa5bad3dce	         ▸ cli                       0.0.35	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
ea19abbf-3277-4f90-bb03-e70aaec09b35	         ▸ runtime                   0.0.21	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
016a40b0-116a-4066-9bf2-07333f071854	         ▸ compiler                  0.0.29	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
41c3d3eb-1ea2-4a13-95e9-45fc066ea9dc	         ▸ @openfn/language-dhis2    4.0.2	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
6d45f79a-d2db-41ce-83e4-4185473cae3a	[CLI] ✔ Loaded state from /tmp/state-1690930217-7-njeprz.json	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
75f606b2-4975-4833-9658-88b9f4e50542	[CLI] ✔ Compiled job from /tmp/expression-1690930217-7-1c0n68s.js	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
ee56734a-cdb0-4278-ab48-93b5ab85f65d	[JOB] ℹ Hel Mahao	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
1b1b2edd-594a-4ebc-bdec-5f24a479e4f7	[CLI] ✔ Writing output to /tmp/output-1690930217-7-fkuzii.json	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
c9f98b60-ed3d-4360-9c4d-f6b1803359f7	[CLI] ✔ Done in 205ms! ✨	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
e7e5c39d-1bde-4142-ab5a-9bfcc587ce9a	[JOB] ✘ Error parsing JSON data: {}	\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
24d97555-168d-4812-89c0-a14c956769a2		\N	fce3d6b9-f39d-454f-a529-411d6ca18e98	2023-08-01 22:50:18
46a95682-4d3b-47a8-9cb4-d30a2e3e98f0	[CLI] ℹ Versions:	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
991ba0d8-0d4a-4391-9f0d-970ea865b0e4	         ▸ node.js                   18.12.0	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
94b1914f-75ae-4f2f-b6bf-4c0132ac22da	         ▸ cli                       0.0.35	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
07ee7ffb-1515-4e81-8158-04f210d374ee	         ▸ runtime                   0.0.21	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
6d180652-5e51-4c2b-8ddc-c6d0ba45bb82	         ▸ compiler                  0.0.29	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
dcc2d0c7-4c22-4a4c-ad9c-76293a92c855	         ▸ @openfn/language-dhis2    4.0.2	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
3cdfebf5-6d41-463f-8057-8cb551ff0f15	[CLI] ✔ Loaded state from /tmp/state-1690930293-7-1nm8mai.json	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
65e3fd9c-4dc9-4fff-84c0-438b6430c0ee	[CLI] ✔ Compiled job from /tmp/expression-1690930293-7-92eq79.js	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
0e4d536a-2c61-42f8-adb0-8f6494442b84	[JOB] ℹ Hel Mahao[object Object]	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
7d13359e-c6d5-4162-8efa-f5fb45092609	[CLI] ✔ Writing output to /tmp/output-1690930293-7-1g73oad.json	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
369d1260-dfc7-4675-9e1c-f4f4e3597cc4	[CLI] ✔ Done in 172ms! ✨	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
4356b38c-ac9c-469d-87a9-1469111251bb	[JOB] ✘ Error parsing JSON data: {}	\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
b6860635-0523-494e-9b0b-8267e52c4229		\N	3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	2023-08-01 22:51:34
12476cd6-d642-4fc7-8a61-e8c6c2854803	[CLI] ℹ Versions:	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
458b23fc-085a-47e9-8684-6c39679eedb2	         ▸ node.js                   18.12.0	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
f353cb5d-c64d-43a8-b11a-42b0223dde91	         ▸ cli                       0.0.35	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
e4153871-c0a7-409a-82ee-de34250da1b7	         ▸ runtime                   0.0.21	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
7f9c84d6-a824-4f5c-a6d9-510c49d73a85	         ▸ compiler                  0.0.29	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
cae50f25-7d20-4db6-8e21-d63c4afd60d9	         ▸ @openfn/language-dhis2    4.0.2	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
eded2bd9-bc11-4686-9648-62404abe6c59	[CLI] ✔ Loaded state from /tmp/state-1690930319-7-zor4rx.json	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
bea2279f-a01c-4605-961f-599fdfcafcf6	[CLI] ✔ Compiled job from /tmp/expression-1690930319-7-x98jel.js	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
6d4990ef-6590-4c09-beef-e856e339e068	[JOB] ℹ Hel Mahao	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
4bec4985-d5a6-4943-86fd-62b7d6572105	[CLI] ✔ Writing output to /tmp/output-1690930319-7-12vy8vf.json	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
4bc20b2e-788f-49d0-8a2a-b3378103a3ef	[CLI] ✔ Done in 174ms! ✨	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
69572154-99e8-444d-9bd0-399f264fb52e	[JOB] ✘ Error parsing JSON data: {}	\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
07572d25-47e9-4e9a-94ed-bd85c63c7762		\N	0fd6b266-fe52-4660-a6a6-16363b9e47e4	2023-08-01 22:52:01
06ba0f89-89b1-4566-b73f-2b173c194bd9	[CLI] ℹ Versions:	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
4f159ba5-2497-44fa-ac78-6b9051d9f29c	         ▸ node.js                   18.12.0	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
4c57d13a-c018-4267-857d-8f0c17c53042	         ▸ cli                       0.0.35	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
c6754ccf-2a7f-4387-baf5-492e2f095d34	         ▸ runtime                   0.0.21	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
2f37294d-84aa-43ad-b242-5efb00fb2978	         ▸ compiler                  0.0.29	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
404aa628-b18a-4e87-ad9a-651c89aa5b67	         ▸ @openfn/language-dhis2    4.0.2	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
c9edf015-8c1f-4fc9-b68f-7939052b49b2	[CLI] ✔ Loaded state from /tmp/state-1690930488-7-1uuwq0p.json	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
b99f6268-db80-4bf4-8363-d5fdcb51e7cb	[CLI] ✔ Compiled job from /tmp/expression-1690930488-7-rspx7b.js	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
5f3b2a56-ac79-4c0d-a180-dd4086c2b073	[JOB] ℹ Hel Mahao	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
a834e07e-d1d3-4981-b08c-d2d35e30cb6b	[CLI] ✔ Writing output to /tmp/output-1690930488-7-epcxg9.json	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
d6cf4dd1-44b6-4d8e-adda-7153aca2c042	[CLI] ✔ Done in 172ms! ✨	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
5cf989ac-63f4-41df-b7f4-b08403f912b3	[JOB] ✘ Error parsing JSON data: {}	\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
85f1b228-1cb2-40ce-9917-83b8d141325a		\N	cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	2023-08-01 22:54:49
d3e36f5a-b2af-4daa-926a-cdbb376b99ed	[CLI] ℹ Versions:	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
662532c0-f8bd-4196-aa66-03c04d80b932	         ▸ node.js                   18.12.0	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
62be9533-881e-4067-99cf-c7d9848f71e5	         ▸ cli                       0.0.35	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
2c5db71f-5f9a-487b-845a-713ab777fa01	         ▸ runtime                   0.0.21	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
0d1a2664-222e-4183-ab6d-7a765858add8	         ▸ compiler                  0.0.29	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
2e47b5fa-e05b-48c6-a94f-73b783d897c7	         ▸ @openfn/language-dhis2    4.0.2	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
d28ab69e-9fff-4e25-903d-f359f7d54011	[CLI] ✔ Loaded state from /tmp/state-1690930707-7-1f4mchv.json	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
78c29094-f22a-47d1-a558-9450e8b18e98	[CLI] ✔ Compiled job from /tmp/expression-1690930707-7-1qweil.js	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
605df3cf-5991-434a-b2e3-cf92c2e24564	[CLI] ℹ Versions:	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
40fb643e-28be-41fc-a692-4717aeaeac10	         ▸ node.js                   18.12.0	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
42792f3f-ec15-4265-8e52-9ac9f54a3a1a	         ▸ cli                       0.0.35	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
d4cfd413-f82d-479a-ba32-ff2244d9e1be	         ▸ runtime                   0.0.21	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
a7ce4b8a-283c-46fd-8ab9-4de72edfe33d	         ▸ compiler                  0.0.29	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
7d263ff8-3d49-4721-94f6-829e1cc25e5d	         ▸ @openfn/language-dhis2    4.0.2	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
8c217fd2-52a4-45b1-8e6e-cd98527d4cc3	[CLI] ✔ Loaded state from /tmp/state-1690930536-7-4q5lih.json	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
8f23ddb0-dbef-481d-bfb9-80dafb030e19	[CLI] ✔ Compiled job from /tmp/expression-1690930536-7-1tfpw3g.js	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
e3eb9460-9d67-49dd-8a05-70c911587847	[JOB] ℹ Hel Mahao	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
8ef80c1a-d292-4f02-9d13-7a40cf4763c0	[CLI] ✔ Writing output to /tmp/output-1690930536-7-1z0ktw0.json	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
dc60cc10-a204-468e-a881-3f857415ddfb	[CLI] ✔ Done in 193ms! ✨	\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
41ab3c53-476b-4da3-a54a-04edb6aeb249		\N	0c87d039-ea99-44ec-bf48-300aa05dddc4	2023-08-01 22:55:37
8e351dd3-014e-4b2f-b6b2-4df928fcf4db	[CLI] ℹ Versions:	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
d7bc7333-0e7f-46c6-84ae-ed0c4406eada	         ▸ node.js                   18.12.0	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
084f670d-8da0-478e-a1e5-57d6fc46a07c	         ▸ cli                       0.0.35	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
a15d96af-b586-4162-bcae-622e3f27a3f1	         ▸ runtime                   0.0.21	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
22bf41cb-e013-4150-b528-4e5e2e5e3a39	         ▸ compiler                  0.0.29	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
2a5fe6a2-ec9a-471f-9412-f64d15becffa	         ▸ @openfn/language-dhis2    4.0.2	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
60fd798f-7f45-4996-a399-c7193472bbcf	[CLI] ✔ Loaded state from /tmp/state-1690930655-7-ubo1hy.json	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
dd3c5e54-6a30-407c-b65b-d6420c0f5e18	[CLI] ✔ Compiled job from /tmp/expression-1690930655-7-lybzsn.js	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
5de726ec-35c0-40c6-a373-21fa049b216b	[JOB] ℹ Hel Mahao	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
aba29247-1493-4f44-b43f-ae968b8bd314	[CLI] ✔ Writing output to /tmp/output-1690930655-7-1uapvy9.json	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
2ffe5b0f-4a2a-4035-bf95-1e7d28be818a	[CLI] ✔ Done in 172ms! ✨	\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
345f8dea-e135-44a4-b1c4-f1d00b444801		\N	e6f27751-a345-448c-aa3d-66410f4207ca	2023-08-01 22:57:36
3c0b0e8c-6d1f-4103-8cec-a28c660147f6	[JOB] ℹ Hel Mahao	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
1ad62215-9cd1-45f9-8b88-08c17488af0d	[JOB] ℹ undefined	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
9ba24dc8-57b5-4052-8f47-02f793c79acf	[CLI] ✔ Writing output to /tmp/output-1690930707-7-vj4o35.json	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
a60e439d-baf6-440f-ae54-7130dfa452fb	[CLI] ✔ Done in 171ms! ✨	\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
785eafba-c724-4e9c-8f3f-3af317ad799a		\N	a6c886fa-4630-420c-9814-bed97ee41d81	2023-08-01 22:58:28
004b899f-07b4-41dd-ae13-b7a4850e69eb	[CLI] ℹ Versions:	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
31134669-1eae-4bc2-8709-699128d9d590	         ▸ node.js                   18.12.0	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
20ce5d8b-2804-439a-b288-cd334fb1891b	         ▸ cli                       0.0.35	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
3cdba87f-8870-42de-a417-562f39d7c726	         ▸ runtime                   0.0.21	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
435e948f-eb36-43c1-aa06-195cacff1eb5	         ▸ compiler                  0.0.29	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
a124566f-a95a-4af5-892a-76d20c5e8363	         ▸ @openfn/language-dhis2    4.0.2	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
67823d67-fc32-4816-8c60-218df76d03b1	[CLI] ✔ Loaded state from /tmp/state-1690930793-7-w70ubm.json	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
cc979dec-6f5f-4f2d-8bc1-d8ab441ebce7	[CLI] ✔ Compiled job from /tmp/expression-1690930793-7-1ozk7oh.js	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
287fc3ff-52fa-4a61-94eb-a6ab90a6f737	[JOB] ℹ Hel Mahao	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
827fabe6-02fb-421b-aa20-dcca5ca79357	[CLI] ✔ Writing output to /tmp/output-1690930793-7-h46f85.json	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
76c303ab-43d7-4ca9-b773-612e85681d9d	[CLI] ✔ Done in 180ms! ✨	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
2d7275e3-dc5d-410a-8422-b307e0ce33cb	[JOB] ✘ Error parsing JSON data: {}	\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
4c13d0e1-c9a0-4e5c-8e7d-b45c37c802dc		\N	0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	2023-08-01 22:59:55
c9affc81-3f8a-45da-ad5d-e6e6ee84fb41	[CLI] ℹ Versions:	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
16afcd5f-7c9a-4625-a2b5-312afd97b344	         ▸ node.js                   18.12.0	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
3a043cc0-64c3-4fb9-bdd2-631e356cec84	         ▸ cli                       0.0.35	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
c054a22c-b82d-489e-8371-4c6b006a5cf9	         ▸ runtime                   0.0.21	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
d3ab4042-4ec1-49a2-9e18-f6dc54914dd3	         ▸ compiler                  0.0.29	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
eea93578-9660-4499-9544-4033cd48886d	         ▸ @openfn/language-dhis2    4.0.2	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
df5ea81d-dc19-482b-98fd-1ac6a9d09c6e	[CLI] ✔ Loaded state from /tmp/state-1690930851-7-1o9n0gj.json	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
88831188-9a24-44fc-8101-f9ef115e55fa	[CLI] ✔ Compiled job from /tmp/expression-1690930851-7-k7tpf5.js	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
b74aac15-f20a-412f-93b3-fda515ad9952	[JOB] ℹ Hel Mahao	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
6834692d-bb53-4fa3-8282-9778a066e563	[CLI] ✔ Writing output to /tmp/output-1690930851-7-1v00cin.json	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
739b7748-ffd5-425a-a015-e7b6a2307328	[CLI] ✔ Done in 170ms! ✨	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
c3ca4ac1-7cfe-484f-b9bd-5aea82ef8bae	[JOB] ✘ Error parsing JSON data: {}	\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
2f9d00b9-900a-4166-84d0-c93fd278c19c		\N	3ca52d84-2b6e-4cec-97a8-b1690a38d262	2023-08-01 23:00:53
e1216fbd-5ab9-4476-a323-be30819718f3	[CLI] ℹ Versions:	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
71083658-d360-46aa-914a-e68d5c4f3d7f	         ▸ node.js                   18.12.0	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
bca6693e-4e9c-47ea-90a4-23f660a008e1	         ▸ cli                       0.0.35	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
d054aaad-1e07-4a68-8dd1-ebfd3e2c7350	         ▸ runtime                   0.0.21	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
56981e81-0c4d-45ab-ace0-6d2ba71a594b	         ▸ compiler                  0.0.29	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
f306ef45-f7b0-4fe6-8e1a-549db9918337	         ▸ @openfn/language-dhis2    4.0.2	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
ac4b9e8d-ec37-4d7d-85fb-719154ab5340	[CLI] ✔ Loaded state from /tmp/state-1690930928-7-186gh9.json	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
49865fb5-8a1f-4fe9-b2db-37f5786d78cc	[CLI] ✔ Compiled job from /tmp/expression-1690930928-7-y42pw1.js	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
6d9d54c3-758d-4b65-82df-5763ce954fe9	[JOB] ℹ Hel Mahao	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
9187af1e-acc7-4a59-8415-cd8465a66b12	[CLI] ✔ Writing output to /tmp/output-1690930928-7-16p1rf9.json	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
74fff14e-075f-4fb9-a7ce-96f08532f0e4	[CLI] ✔ Done in 179ms! ✨	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
802b7ea0-8f10-4d0e-b46c-60c71fe91d85	[JOB] ✘ Error parsing JSON data: {}	\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
62d26ab5-8a7f-4f09-9b5f-8ae0035ba9e1		\N	d3da036e-ab99-4bef-b80c-39460c771c94	2023-08-01 23:02:09
44e67e21-b9f9-456a-9314-f6ac9bd81ea2	[CLI] ℹ Versions:	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
b2a62048-661d-4cf9-8331-51f52a5edebb	         ▸ node.js                   18.12.0	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
c90c88a7-58ab-4a93-8f18-1dfcf2653bbc	         ▸ cli                       0.0.35	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
d9b0d68e-1c4f-44d7-b8aa-8077ac010f4e	         ▸ runtime                   0.0.21	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
d2bd1c77-5093-4ce8-bd58-a540d74eb4c6	         ▸ compiler                  0.0.29	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
0ffc73ea-c17d-44da-a7c9-49b76342ad76	         ▸ @openfn/language-dhis2    4.0.2	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
b91e850b-6307-4808-b1c7-6420214069cd	[CLI] ✔ Loaded state from /tmp/state-1690930974-7-r87nji.json	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
fa65446a-b8a9-4be0-b255-2d5caae06641	[CLI] ✔ Compiled job from /tmp/expression-1690930974-7-1cqpy47.js	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
0184276b-7c0b-4032-a253-c3fb6d4ebcb7	[JOB] ℹ Hel Mahao	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
870f12eb-5b4a-4213-9453-1a952d7444d7	[CLI] ✔ Writing output to /tmp/output-1690930974-7-11cuk2o.json	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
788f544b-d6d9-48dc-a003-8fae73f66523	[CLI] ✔ Done in 180ms! ✨	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
93dac173-8de2-472d-a1fa-f9118dc458bf	[JOB] ✘ Error parsing JSON data: {}	\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
0feeb413-9286-4f3c-8caf-cffb35537f69		\N	3c473faa-1ea2-4d59-91fe-2815703dd70d	2023-08-01 23:02:55
cf9c45f0-cf85-49c1-b9d2-0dbfc74f75dc	[CLI] ℹ Versions:	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
206aa6eb-a540-4e02-90c0-400937514709	         ▸ node.js                   18.12.0	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
af55310f-cf38-43f7-a672-c551bf2761c1	         ▸ cli                       0.0.35	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
cc962a22-04e6-445b-b44d-a2d66d7d5e82	         ▸ runtime                   0.0.21	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
048c572e-5014-4a5c-a878-d7af873ee456	         ▸ compiler                  0.0.29	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
02964988-2e79-4b18-ab55-4c06699d1e16	         ▸ @openfn/language-dhis2    4.0.2	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
ecc6c4f1-b172-4c44-a136-185277174102	[CLI] ✔ Loaded state from /tmp/state-1690931034-7-1k9xu1z.json	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
746518d0-2f32-483b-be3e-c19527f3df7f	[CLI] ✔ Compiled job from /tmp/expression-1690931034-7-1qwqlqb.js	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
5559b5e9-5eeb-42a6-8696-f1b5e7611b96	[JOB] ℹ Hel Mahao	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
93d10048-c920-43cd-889a-bb590be2ec17	[CLI] ✔ Writing output to /tmp/output-1690931034-7-17n5bao.json	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
98a2132f-039f-4018-a3de-4a5c4354a139	[CLI] ✔ Done in 178ms! ✨	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
6a861444-55ac-4f2a-a616-e49643a4234e	[JOB] ✘ Error parsing JSON data: {}	\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
50a11a5b-1db8-45f5-bb4f-8bf1bba2e58c		\N	a1fcb414-837e-46d2-b5e9-6deb72c6ea13	2023-08-01 23:03:55
6a654ab8-1991-44c5-bace-e0f3903fa9e2	[CLI] ℹ Versions:	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
9c340100-49c4-46a0-8585-3fc3b08d40d3	         ▸ node.js                   18.12.0	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
67f2f81b-36b9-4469-8366-b92ffdb86ca7	         ▸ cli                       0.0.35	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
4805d34e-2f49-4ffd-b93e-955bc6da7529	         ▸ runtime                   0.0.21	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
640b440d-4d39-4519-948f-5af725cb5845	         ▸ compiler                  0.0.29	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
dee5e26e-9ee1-4e32-af9e-3751785bdede	         ▸ @openfn/language-dhis2    4.0.2	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
2f63f4a7-2326-4a67-ac18-37f050ab17ca	[CLI] ✔ Loaded state from /tmp/state-1690931086-7-1xuhl7s.json	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
36b7c00f-b7d1-44fc-889e-d7b66aa09e7a	[CLI] ✔ Compiled job from /tmp/expression-1690931086-7-z06yje.js	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
8901313f-e4fb-401d-8f0b-2defab934332	[JOB] ℹ Hel Mahao	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
be268182-9df2-4075-a0fd-837e92dc3abb	[CLI] ✔ Writing output to /tmp/output-1690931086-7-x0wpaf.json	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
e145e87b-4bec-49d5-9cf7-035b8b72bf5a	[CLI] ✔ Done in 174ms! ✨	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
d379068c-259f-428a-9c38-ebdea3e6e014	[JOB] ✘ Error parsing JSON data: {}	\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
f485e1a6-d4fa-4629-be15-eb89b91470e7		\N	66494af5-3763-42ba-add1-88e1a8a5fd98	2023-08-01 23:04:47
9676502b-8b9f-473a-8dff-5b626f00752b	[CLI] ℹ Versions:	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
1053223c-d2ca-483c-b3c7-339c812bed7e	         ▸ node.js                   18.12.0	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
9902feff-d188-44f9-ac0b-1a6a47d07837	         ▸ cli                       0.0.35	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
568de453-6d35-48ef-beaa-82a6ea2753ef	         ▸ runtime                   0.0.21	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
f1c13ee0-34e7-4445-a8fe-0258245b0faa	         ▸ compiler                  0.0.29	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
3d9e6e9a-6f92-4ae0-99b4-a692c04e120e	         ▸ @openfn/language-dhis2    4.0.2	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
3c46b75b-a5e0-4f72-bb52-3cb0ece380c7	[CLI] ✔ Loaded state from /tmp/state-1690931126-7-1j4xtkq.json	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
88b3467f-8109-49aa-a1d9-162c9b320ad0	[CLI] ✔ Compiled job from /tmp/expression-1690931126-7-1o23muw.js	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
bd6e0743-a6a2-4f83-9c33-31580862f775	vm:module(0):1	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
7a0cfea4-5279-4fff-a71d-7b5d969291e5	console.log(State);	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
c0b9c357-acac-4ead-815e-de6e9084f134	            ^	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
359a6163-39cc-4c57-bdbd-126e3d911d34		\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
f2bda125-96a2-4483-93c3-8731a5e68b89	ReferenceError: State is not defined	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
8bdfd016-7dc7-4031-b1ce-c7a97ca4a3ac	    at vm:module(0):1:13	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
4b67261b-85e8-4e85-8793-3e71b1159fe2	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
753bcb91-23f1-4b0a-b549-f90720a716db	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
e176592b-cf1f-460d-adce-dcf573194153	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
2ab6d416-35d8-482d-82cb-0f43536c81e6	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
cdf8be4d-5a29-4b3f-b63f-ff0fba25f12c		\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
457febcc-4f05-4c47-b698-c5170030514a	Node.js v18.12.0	\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
0db643ab-9c59-4973-9a98-076cdf3f0cb8		\N	5bddade5-de14-457c-8257-b1c3384bcf40	2023-08-01 23:05:27
4eb9ab27-ed47-4851-a7b3-44a1fa737986	[CLI] ℹ Versions:	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
b2813349-634c-4e5c-94bf-5b9d1b9ea67e	         ▸ node.js                   18.12.0	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
63a627ff-9694-456e-8cc8-84d7f41a985a	         ▸ cli                       0.0.35	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
df7b6daf-28d8-465b-bc77-c1cb7ee0e161	         ▸ runtime                   0.0.21	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
6fe1ff8b-0846-4244-9c7f-dff6de4d9fee	         ▸ compiler                  0.0.29	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
ba6c272b-c8dc-4da3-9405-384de48d2c2b	         ▸ @openfn/language-dhis2    4.0.2	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
be3e57ce-8d24-4f53-8b0d-5496bbc56fce	[CLI] ✔ Loaded state from /tmp/state-1690931156-7-13yx7ak.json	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
ca56d1db-4321-480f-8f68-8fb48524e7d2	[CLI] ✔ Compiled job from /tmp/expression-1690931156-7-ps1vds.js	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
8b49ccb4-6323-4be4-8366-96e6692d1852	[JOB] ℹ {"data":{"Name":"Mahao","Surname":"Molise"},"configuration":{"apiVersion":"****","hostUrl":"****","password":"****","username":"****"}}	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
692ab3ca-adcb-4e3d-8cca-de1df99fb527	[CLI] ✔ Writing output to /tmp/output-1690931156-7-1yyyoij.json	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
f8306f26-872a-4c7f-8e05-4f774a936beb	[CLI] ✔ Done in 180ms! ✨	\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
1e36fa78-7d38-41a2-81b0-fea63290a334		\N	e9bc32df-9acf-4108-b922-8e3d9c85be23	2023-08-01 23:05:58
eaeed3a1-40ac-4a79-813a-201b81df8725	[CLI] ℹ Versions:	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
10ed56df-4a3b-4adf-ade3-ba05d9da37fa	         ▸ node.js                   18.12.0	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
7db9bd20-756d-4caf-8bd0-68990263a876	         ▸ cli                       0.0.35	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
d9b6177e-ddc3-434d-97ea-d3f192ae0473	         ▸ runtime                   0.0.21	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
07b4c83f-a171-4d98-b455-58e9cf893850	         ▸ compiler                  0.0.29	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
eb268705-4e32-4551-8bab-64ea1e8f57bf	         ▸ @openfn/language-dhis2    4.0.2	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
b48b9084-5517-4221-8e77-e23df167c6eb	[CLI] ✔ Loaded state from /tmp/state-1690931188-7-ixdcla.json	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
f6373f76-3cd3-41e7-89bd-7eb3c9ce7b27	[CLI] ✔ Compiled job from /tmp/expression-1690931188-7-2avtm8.js	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
2200f8de-266f-4c29-8b08-19597f817fa4	[JOB] ℹ {"Name":"Mahao","Surname":"Molise"}	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
b3c8d453-442f-47bb-8bf9-91fb638d4342	[CLI] ✔ Writing output to /tmp/output-1690931188-7-1ta76nr.json	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
66c1071a-4959-4ec7-8dd4-22bd26ee11c9	[CLI] ✔ Done in 172ms! ✨	\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
ca383c5d-638e-454f-9a05-8ab04ac77279		\N	b45206da-3b44-4879-a51a-9a560b308189	2023-08-01 23:06:29
67e13160-4644-462c-8b07-e8e1940378f1	[CLI] ℹ Versions:	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
34fb0110-9997-411f-91e4-b79b6147a7d3	         ▸ node.js                   18.12.0	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
b55415f0-4a17-4309-a2a5-c1c03820054f	         ▸ cli                       0.0.35	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
95a13f07-82f5-4cb3-b9ad-e0acd471aaba	         ▸ runtime                   0.0.21	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
0f45ff41-a119-4fb5-9aa6-35804ee58955	         ▸ compiler                  0.0.29	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
879a2471-061b-4993-807e-eb664e771193	         ▸ @openfn/language-dhis2    4.0.2	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
f063370f-642a-4c0a-b15f-0fd17d45dde0	[CLI] ✔ Loaded state from /tmp/state-1690931248-7-1vn7nix.json	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
7710f198-e598-43e1-81ba-2b7f78172359	[CLI] ✔ Compiled job from /tmp/expression-1690931248-7-1279qav.js	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
bf30c2d4-d424-4234-b48f-345b673ddc57	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Doe","given":["John"]}],"resourceType":"Patient"}	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
c6844923-5bdc-4819-8435-7d1507fc298a	[CLI] ✔ Writing output to /tmp/output-1690931248-7-12t1wyp.json	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
5da747a5-4222-44a8-a4cd-7cd23cadf6af	[CLI] ✔ Done in 162ms! ✨	\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
3c7716c0-212b-4f50-82b7-9a1294a0bf4a		\N	b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	2023-08-01 23:07:30
e08a7598-8dd7-436d-89c1-7aae3dda5774	[CLI] ℹ Versions:	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
7184a38e-0066-4518-8a79-11466acd40e5	         ▸ node.js                   18.12.0	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
f778d13c-d1df-486a-9ed6-8437bffd1644	         ▸ cli                       0.0.35	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
0c5b0ad5-50d7-489b-9863-4697c1d5e3aa	         ▸ runtime                   0.0.21	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
6197d15a-1d15-468e-a3bd-609030c833a0	         ▸ compiler                  0.0.29	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
70327edd-6c19-4614-8771-010b4d46b3e0	         ▸ @openfn/language-dhis2    4.0.2	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
313a6327-b074-4318-9726-b8a96464138d	[CLI] ✔ Loaded state from /tmp/state-1690931706-7-2dxpf3.json	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
43cda48c-ef10-4beb-a6cf-407edfd6c5b0	[CLI] ✔ Compiled job from /tmp/expression-1690931706-7-oq1kvy.js	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
27bada50-e74c-49d3-aaec-e43ae043a222	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Doe","given":["John"]}],"resourceType":"Patient"}	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
59083faa-fe3d-4cbf-95b5-123ad99682c2	vm:module(0):3	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
c4f6bdfa-89ce-42ac-9e55-9fd5a71393ce	const firstName = state.data.name.given[0];	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
5b617026-f3ea-40fd-a8ad-d326408457f2	                                       ^	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
7b20bb40-baa9-4d69-a338-10ccea3c0898		\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
bf88cd72-0c85-43fb-a0de-bd3dbba495b8	TypeError: Cannot read properties of undefined (reading '0')	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
e7754295-3e9f-4e57-a8dc-2f1f264632e2	    at vm:module(0):3:40	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
1e65fedc-be1d-4096-8b44-c1fe8d6ebc4b	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
01c0c1b0-cd5f-4ab2-a691-6b4248e959e0	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
8cc1492b-55c3-494c-9a0c-ddd21e663d9a	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
9a640aed-b4b7-4b37-a220-22658aedb271	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
86132dea-006f-4578-b791-8d904276e412		\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
6cdb03e8-bd91-4f3c-888e-fdcecbc0f11b	Node.js v18.12.0	\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
6d42dd91-6c6a-4b9c-9494-cc6eebeaabe1		\N	6c2a6868-3376-4819-8f8c-808774ff53d5	2023-08-01 23:15:08
545f10c0-f39f-4b6a-8e61-6685ecd826aa	[CLI] ℹ Versions:	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
ed4f441e-d388-4f26-a5de-759f0e64b883	         ▸ node.js                   18.12.0	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
1f7e1a06-8ae5-479a-b409-799d36dc0c43	         ▸ cli                       0.0.35	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
1d369ae3-d93a-45d3-9b3d-9b510ab0076b	         ▸ runtime                   0.0.21	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
6c4e707b-cfe9-4793-bb1c-2976f48a8582	         ▸ compiler                  0.0.29	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
d49c4861-2b77-4073-8ce0-e8c2fda237f2	         ▸ @openfn/language-dhis2    4.0.2	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
d5057731-24ef-46bd-b72e-5c16d93bf994	[CLI] ✔ Loaded state from /tmp/state-1690931743-7-ffga01.json	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
3557b6a2-62eb-4100-8a3e-bd5fdb60ec6b	[CLI] ✔ Compiled job from /tmp/expression-1690931743-7-ghztnn.js	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
3f969aeb-eab6-43aa-a584-c821afb5535d	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Doe","given":["John"]}],"resourceType":"Patient"}	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
d13b9cd8-613e-4364-9368-3951062f8f1e	[JOB] ℹ BirthDay: 1980-01-01	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
3a6b6aeb-f0ae-41aa-87f8-bac49e3e24f0	vm:module(0):6	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
bedb5815-db28-472d-a770-3bb2de30759c	console.log("firstName: " + firstName);	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
7839f918-09c0-4cd9-b1c9-59a27aad09df	                            ^	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
a3666bdc-89ec-4df5-b54c-6a7c14788e56		\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
a4f3391f-5ab4-4c66-b95d-8d62848037cd	ReferenceError: firstName is not defined	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
dd60d199-d85d-4735-8dbb-865897cdbe4e	    at vm:module(0):6:29	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
4238b3ce-af06-4cf8-8b14-bf002daa4d7e	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
52f508bd-3eae-475d-b59c-0256d14fa528	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
e21c3b4b-decf-4669-8916-ab5ded4a2f73	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
efedeb2e-e48a-426b-9dec-5bd3c7315553	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
df92b708-8d39-4bad-baf5-90ae98ac5e5b		\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
3615fc6d-b19a-4464-bc30-c5d0ba3c81d8	Node.js v18.12.0	\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
5b81f091-8dc8-4524-90d9-a0e6e2604d80		\N	294c65f6-d174-4df1-8e69-f57230af0e11	2023-08-01 23:15:44
bac393cc-6954-455a-badd-9a7f0ba21765	[CLI] ℹ Versions:	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
a04a2969-0e71-4bc9-bc51-26c5f2146c24	         ▸ node.js                   18.12.0	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
0e6dc6d9-9008-4ef7-b338-bdaaef8fc952	         ▸ cli                       0.0.35	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
5f8879b9-196a-47b0-89d3-7611af9aea6a	         ▸ runtime                   0.0.21	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
7c548336-d107-46e6-b035-5d15d547b5b1	         ▸ compiler                  0.0.29	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
f1ec321c-4d1c-4fa8-a0cf-d50995843a29	         ▸ @openfn/language-dhis2    4.0.2	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
ef459992-7098-47ff-9484-c1b02c5089cb	[CLI] ✔ Loaded state from /tmp/state-1690931778-7-1lgv6dq.json	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
06411bfe-3ce8-42fa-b784-ad36da7b8f0a	[CLI] ✔ Compiled job from /tmp/expression-1690931778-7-1jstkj7.js	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
a7b20586-b96c-4a00-b59f-e7dcf416ca82	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Doe","given":["John"]}],"resourceType":"Patient"}	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
56dbfe8a-5a8d-4e9d-9f48-e6dbe36e4966	[JOB] ℹ BirthDay: 1980-01-01	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
f92fbc91-9b1a-4fee-81b6-b2669a9942f8	[JOB] ℹ Surname: undefined	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
1a1a7098-68d3-4015-a690-70ce43ddde6f	[CLI] ✔ Writing output to /tmp/output-1690931778-7-1wcnhr6.json	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
988084df-b5c0-4f47-901f-8883a06a0b84	[CLI] ✔ Done in 172ms! ✨	\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
df0bca3c-82d7-4e89-a9f5-e950d21ea664		\N	c9202151-effb-4ceb-92f4-a5f57c663dad	2023-08-01 23:16:20
0d18e82d-4e6b-4f28-8f2d-83a66cbb90d0	[CLI] ℹ Versions:	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
f5b6d47b-500d-46d8-b3e9-edaa51643fe9	         ▸ node.js                   18.12.0	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
a6aea12f-e229-45b1-9314-098d35fe78af	         ▸ cli                       0.0.35	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
1e0223b1-9b9f-48d3-b91b-292bd8629db5	         ▸ runtime                   0.0.21	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
11c5a247-3b93-4bd3-8821-e72c41ba10a9	         ▸ compiler                  0.0.29	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
a71ab137-01eb-44c0-b71a-9d99a7e0d709	         ▸ @openfn/language-dhis2    4.0.2	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
3d5b7a1e-7080-4a48-9a18-066ff1b30ba8	[CLI] ✔ Loaded state from /tmp/state-1690931828-7-1npjpj6.json	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
e25355ae-e026-4502-aa0f-2637011f0c8a	[CLI] ✔ Compiled job from /tmp/expression-1690931828-7-195tinf.js	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
0fa22a5e-db64-4461-acfd-d6bc8279c173	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Doe","given":["John"]}],"resourceType":"Patient"}	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
2e4b3a82-28c9-4142-8dee-716f6798fd11	[JOB] ℹ BirthDay: 1980-01-01	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
e2e842ff-04dc-4423-b9c2-cb05d3d2d127	[JOB] ℹ Surname: Doe	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
19f835d6-6d64-484c-bf33-53687a5ad4eb	[CLI] ✔ Writing output to /tmp/output-1690931828-7-1io1y96.json	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
684fc609-b347-4be7-9c4c-8905a41b4680	[CLI] ✔ Done in 173ms! ✨	\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
9810c96c-3a20-4705-9435-e4da2884d362		\N	42a29fb1-aaba-4858-b68e-ce1ff9050af3	2023-08-01 23:17:09
20bc8a45-6e14-4113-b225-7c3530ddc3be	[CLI] ℹ Versions:	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
394138f2-7189-4d4a-87c6-0c83d4c18aca	         ▸ node.js                   18.12.0	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
28ca8814-b18f-483b-8474-c8d5030c6b41	         ▸ cli                       0.0.35	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
1deca9ac-b91a-4947-b470-5f6d39fb510b	         ▸ runtime                   0.0.21	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
0568ef86-67b2-49fd-88f4-9c92e3db97f7	         ▸ compiler                  0.0.29	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
e360e63b-b381-4aec-989f-f601bd1137aa	         ▸ @openfn/language-dhis2    4.0.2	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
c84633bc-bffa-4d67-ae14-ab29bbdf6221	[CLI] ✔ Loaded state from /tmp/state-1690931971-7-1fseh0e.json	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
e2d5656c-a6e6-4f25-863f-b061a403fba6	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
00b6c775-8928-4b0d-a174-cf999f90f753	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
62ca8c62-bb84-494a-aa01-384bf5e7d6df	[CLI] ✔ Compiled job from /tmp/expression-1690931971-7-4x66pt.js	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
272fabd8-426a-40ab-9281-837fbfdf2b88	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
3ce5afa5-995f-4165-9e09-882959f8d783	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Doe","given":["John"]}],"resourceType":"Patient"}	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
8ca1eb25-898f-4f59-a6ae-9723a3c818b0	[JOB] ℹ BirthDay: 1980-01-01	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
cbbd3f81-d80a-4375-b7ad-b10da2b5597a	[JOB] ℹ firstName: John	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ff980698-e845-4bbd-b561-fa03d1b97823	[JOB] ℹ Surname: Doe	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
2dddaa8a-f9ea-4c85-b59a-267f170dc578	Preparing create operation...	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
471cab8c-f9d4-4917-bfdc-7d23cdfec3f3	Using latest available version of the DHIS2 api on this server.	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
4d26aff5-3b02-4c18-9969-8720a44631d9	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ec800303-b5a8-4931-b75a-5f8313e2a57f	✓ Success at Tue Aug 01 2023 23:19:32 GMT+0000 (Coordinated Universal Time):	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
206f38aa-7500-4707-a59e-dfb631f6be3d	∟ Created trackedEntityInstances with response {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
1e9592fa-90a9-4cf1-b0d1-92971b54279b	  "httpStatus": "OK",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
c2c30078-699d-49e0-ae63-65d075a022c6	  "httpStatusCode": 200,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
94b09ddd-2d9b-4390-9bd2-31faa876f887	  "status": "OK",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
bd9d82f7-9843-4d44-bc82-a7b47ce18129	  "message": "Import was successful.",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
75b6b706-72bc-4ea7-a9bd-766e1c7c7cf4	  "response": {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a447f395-a972-4f57-af1a-22675547706b	    "responseType": "ImportSummaries",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
441264a8-b68e-4025-809b-43669ad5275e	    "status": "SUCCESS",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
d702bc6f-b4e0-4630-a7c7-2d3fe5ec7142	    "imported": 1,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
f18dc52f-6954-4dc6-84d4-c3699617a4a2	    "updated": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a660e5ab-06fd-4c61-8057-3aafe9dda694	    "deleted": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
0c23dac7-5909-4a9e-b3f3-a5031ca766f6	    "ignored": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a9858719-68ae-46d8-9f7e-26f4e1e3a22a	    "importOptions": {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
dccab7b0-246b-46ed-9761-faf8ee2bb67e	      "idSchemes": {},	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
88558d5c-5522-4454-aa63-932f68aabc3c	      "dryRun": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
70a3aae8-c50f-4097-8d5d-7d785709816c	      "async": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
f55eeff2-8829-402b-be9c-f9fad4f8d240	      "importStrategy": "CREATE_AND_UPDATE",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
89b47df0-4def-4ae3-ae84-099a16696274	      "mergeMode": "REPLACE",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
14cae9ce-68cb-4136-bad7-0ae1a7642c81	      "reportMode": "FULL",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
786bbcfa-501e-4404-9e81-7d4a388e4448	      "skipExistingCheck": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
82524acc-483f-4d41-913b-7331b6f46bb6	      "sharing": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
32564c67-3991-4cbb-8b45-87157d1c070f	      "skipNotifications": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
5f84b633-7c72-4c2c-ab96-d76ff92c9519	      "skipAudit": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
5f12cfe3-0cc8-4c79-bb81-9996bbfcccdb	      "datasetAllowsPeriods": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
b0ca6e63-953a-416c-a586-8e3c89b00587	      "strictPeriods": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a3aa9594-aaf7-4c5c-b1ea-98f32c06762b	      "strictDataElements": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
f8691950-f245-440e-8257-8fb373dcac06	      "strictCategoryOptionCombos": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
e50c84f7-1fab-475e-a274-373e41e7e08c	      "strictAttributeOptionCombos": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
0ba33ee9-d534-47e9-bc88-5b7b1028d324	      "strictOrganisationUnits": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
287de574-9c2c-48d4-b5c0-2f695d9c6e95	      "requireCategoryOptionCombo": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
5ad30c66-2ece-4e55-ac2d-457ce7168b18	      "requireAttributeOptionCombo": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
e55d17e4-1fa3-4ea2-9c75-150c013cff8a	      "skipPatternValidation": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
c77d21ea-7913-45c8-9c96-756b21c22cf1	      "ignoreEmptyCollection": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
7eb92c98-196e-4e47-9d51-ab679fff28a6	      "force": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
f4d1822f-447c-415f-bea4-5203d27a377d	      "firstRowIsHeader": true,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
2961f19f-f280-4de2-9fbc-8e785b4e86e5	      "skipLastUpdated": true,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a66e39d0-6394-431f-8d29-7dd43ee1972f	      "mergeDataValues": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
0561e3a2-32c0-4f17-8ec1-3ff7e9d793d9	      "skipCache": false	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a5b8362b-a65b-479d-be31-55788edd0b57	    },	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a7346dca-5c36-441d-a161-8a40324eb967	    "importSummaries": [	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ba51d8ed-2bac-4d50-98f9-1429390f7a4f	[CLI] ℹ Versions:	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
0ef01f0c-f915-44d9-910d-56b768b980b6	         ▸ node.js                   18.12.0	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
4ce4b20f-d3e6-4c9a-93ff-16d120459574	         ▸ cli                       0.0.35	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
ef0058b0-252b-4566-989f-305675f5f10e	         ▸ runtime                   0.0.21	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
efe4af2f-89b9-42d5-93df-cac7a8390eea	         ▸ compiler                  0.0.29	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
5fae3ee1-044a-4fdf-b67a-0c5d87fe9369	         ▸ @openfn/language-dhis2    4.0.2	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
b607d843-e974-4177-9547-5e93d5a1c4cc	[CLI] ✔ Loaded state from /tmp/state-1690931870-7-4th2bm.json	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
458b6c3e-f135-4fee-b5f5-d3e2bc399676	[CLI] ✔ Compiled job from /tmp/expression-1690931870-7-cmok34.js	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
8bd837c7-a7d5-4fbb-9765-fd7689ad7eac	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Doe","given":["John"]}],"resourceType":"Patient"}	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
462ea2ca-273e-4613-9478-785efd946155	[JOB] ℹ BirthDay: 1980-01-01	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
45c39397-52ee-4b3b-b352-071d28731857	[JOB] ℹ firstName: John	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
f31a52d4-e5cf-4a91-acb6-05bc62fd6c5c	[JOB] ℹ Surname: Doe	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
db293219-299b-47ea-a489-f85cea5c9ddd	[CLI] ✔ Writing output to /tmp/output-1690931870-7-1hjddyd.json	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
b25ca19b-99ba-4e5c-abdf-5d5179d4a898	[CLI] ✔ Done in 176ms! ✨	\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
fad625e7-080f-4b11-9f80-70c5ed89ab9e		\N	652ad855-0391-46d9-9673-e645cad6c859	2023-08-01 23:17:51
0884f561-f0e5-487d-b28f-e5e81b18dedd	      {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
64d3f9a6-0a36-4242-89b6-7976a76be56a	        "responseType": "ImportSummary",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
87697615-a067-4d58-b5ad-72a19638c484	        "status": "SUCCESS",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
45990c5c-b99d-464d-b535-58f117399993	        "importOptions": {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
45b612a0-11a7-4b6f-b391-076045dfa3fe	          "idSchemes": {},	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
df06f84e-7ae1-4bed-a066-81eb915ee7f4	          "dryRun": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
dc3b1e50-7ed3-4272-a06d-1f2ce9bd6985	          "async": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a982857d-d134-44ed-be31-ff0df7b0306e	          "importStrategy": "CREATE_AND_UPDATE",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ef26a01d-9814-46e3-ad04-f613137f70de	          "mergeMode": "REPLACE",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
2fbc642b-8432-4891-96e0-86548aa8c8a3	          "reportMode": "FULL",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
865440b8-76a6-441c-9992-07f574d28b53	          "skipExistingCheck": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ffe5afea-4f93-40a2-b15e-adaf8fa76ec6	          "sharing": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
16cb31ae-311a-4e33-950d-12afab0de9d1	          "skipNotifications": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
4390ce15-afa2-4dc0-a838-50d0621deb47	          "skipAudit": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ee597c0a-558d-4375-a376-571b19e524ac	          "datasetAllowsPeriods": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
c86afe44-3c3c-43b8-8919-b690f6a80eca	          "strictPeriods": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
9d972ac9-3228-483a-b8eb-73e964d310d4	          "strictDataElements": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
35466d5c-dd61-4f8c-9487-c6088dce17f0	          "strictCategoryOptionCombos": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
912e7e09-53c4-4ec1-84cc-540043d43600	          "strictAttributeOptionCombos": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
29fea693-5c9a-423d-ae6b-3a59068b6546	          "strictOrganisationUnits": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
e1f2edd5-80f1-4bd0-b682-ed141ee2a043	          "requireCategoryOptionCombo": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
d947e234-da09-4274-9139-e3cb8a0192da	          "requireAttributeOptionCombo": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
038169e3-0352-4f75-b5a3-f348820e2d1d	          "skipPatternValidation": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
f158ce20-4d1d-4083-8415-7e7444819d91	          "ignoreEmptyCollection": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
7303ad37-1ed5-4977-adb0-2e2921bad4e3	          "force": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
44102846-de71-4bc7-ab5e-9f51b6e2490c	          "firstRowIsHeader": true,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
bbf90df5-a701-48b2-8d80-2ac698029554	          "skipLastUpdated": true,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
b1612864-ff13-4320-bed8-f8f3e6de77ad	          "mergeDataValues": false,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a7e828b5-4065-4375-9193-7e89074dab06	          "skipCache": false	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
d30feb8c-1f6a-4f2b-a98a-a4b5fea67a80	        },	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
bf6fee7e-b156-4909-a411-da0f1e187029	        "importCount": {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
b042127d-cb3e-450b-985d-949f47bb2490	          "imported": 1,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
8a8f3e51-248c-48f7-90da-b724df92c889	          "updated": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
6f1708e1-a434-4dce-81c2-05abaf05a60b	          "ignored": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
3a94eb9e-d4ea-4b7a-8726-0d9ba08a9cc9	          "deleted": 0	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
448f7a4c-3703-4e33-a3e4-cc20c919ef18	        },	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
06518e6f-27b4-47a9-9472-8d8bd424663f	        "conflicts": [],	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
8b62f785-a428-4da8-8e13-710c9ba6e8a8	        "reference": "fo3EfAwoOpD",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
d9bc9b47-497d-4eae-8e10-dcbfe26f2499	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/fo3EfAwoOpD",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
bad81b93-ae15-49e7-b05d-72c0485e1355	        "enrollments": {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
0f3e666b-fe0e-4384-91b4-d91d722788f0	          "responseType": "ImportSummaries",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
81219b9e-9cf6-4470-990b-567a000f30ab	          "status": "SUCCESS",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
5edf5aa6-63a1-4362-a84f-c062e404867b	          "imported": 1,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
7bf33643-8c1b-4677-9c85-f8d13f593d00	          "updated": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
b147b662-191d-4a94-9ee1-5bbff55f25ef	          "deleted": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
8c8d3543-00b0-40bc-9687-190f19186e2d	          "ignored": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
72475345-3b1c-4df5-b748-a46edd50170e	          "importSummaries": [	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ddda6e52-865c-4ef7-9bda-d16b3dc1fa18	            {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
bfeb2d5b-9410-415b-ac0a-52952925159e	              "responseType": "ImportSummary",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
08c0d23d-bbb7-45b5-8111-ae548e226765	              "status": "SUCCESS",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
8c8c97df-e36c-4edb-954a-ab58f0b6557d	              "importCount": {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
41a4e363-6991-47fa-b498-c279bffa291a	                "imported": 1,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
f9d316d0-8567-42fb-9975-72c7741c0a2b	                "updated": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
3ce9c9a9-2a13-439f-a7e0-ecdfd5ee0b88	                "ignored": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
3578c0f9-f8af-4598-80ea-b405e544df89	                "deleted": 0	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
70f6639a-5eb4-4acc-998c-fd96520f74c9	              },	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
2f206028-86ff-492a-9765-99240beacf16	              "conflicts": [],	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
7e6f221f-b3e4-44b8-92c6-eda443876758	              "reference": "P0LVfue6VD3",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
668cc0e4-e55e-408c-91e2-c5fddcb04e6d	              "events": {	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ad82d4f1-f9fa-49b8-abe3-0baacc032244	                "responseType": "ImportSummaries",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
026a0a24-3c1e-4b91-9b8d-d21958e5b89a	                "status": "SUCCESS",	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
4813a76c-6c19-491e-bb89-6fb9e325e814	                "imported": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
436e0565-8b83-4108-9160-a7a19ecab7a8	                "updated": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
9e86539b-d2b6-4367-a754-2d13e76990aa	                "deleted": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
cf9211af-61b1-4319-afb8-6639e28e905f	                "ignored": 0,	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
7a85037b-10c3-4754-af6d-f6d73a4d77f5	                "importSummaries": [],	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a682975c-ade7-4551-bc4d-698ea34c98e6	                "total": 0	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
bff3818b-8dbf-4a3b-85cf-c67997112314	              }	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
db307893-606c-4ede-b6c7-1ffbaf10fb0f	            }	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
b4a48e34-3d39-422c-b8f4-3ccfff426e01	          ],	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
c62b7d98-2c74-49a0-822a-020b898a9973	          "total": 1	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
d19143e6-81a0-49c1-a1d2-170e80cfddb1	        }	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
3c4c7e96-78c8-438b-90a2-9e1f8b42ee50	      }	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
1fc71b34-e0a6-4a61-a401-d56d1e4439cd	    ],	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
57701975-0bb3-4c30-a2d8-dd750fa67fb4	    "total": 1	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a97d8eba-5cd2-4929-ac1f-6b98dfb4c06b	  }	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
a0741915-0a30-41c2-a133-cd5ed8b4e0d2	}	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
8c34aa9d-16d2-4906-b647-2142d2e8c83d	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/fo3EfAwoOpD	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
985ee399-638f-42fe-8c6c-96b8b89a5ede	[R/T] ✔ Operation 1 complete in 207ms	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
5083716e-97ad-4923-b047-6ce7bb1ec65d	          "skipAudit": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
90bf71be-c38d-45ad-b45d-4f9c8f0866f3	[CLI] ✔ Writing output to /tmp/output-1690931971-7-guto6y.json	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
cfca4073-781e-4327-8274-eac7e9c8dfe3	[CLI] ✔ Done in 615ms! ✨	\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
ef61cd46-dedc-43c7-9d60-66fa248ce3f1		\N	64dfe032-cbf0-4790-b296-1f42991e9ed9	2023-08-01 23:19:33
872fa1ee-9b06-40b1-b799-f864f28c5710	[CLI] ℹ Versions:	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
ea6735d6-97aa-457a-b951-1c61f46cc342	         ▸ node.js                   18.12.0	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
30a22b94-e0b2-46ac-be3f-d902db5aeb56	         ▸ cli                       0.0.35	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b5d9ecef-dfb5-44c5-b09c-6038ab0e6cb8	         ▸ runtime                   0.0.21	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
1786bcae-abc4-40a7-bc77-702daea32868	         ▸ compiler                  0.0.29	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
1b24f5c2-a858-4c83-a55d-2605943fa999	         ▸ @openfn/language-dhis2    4.0.2	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
d71ebc47-255b-4fe3-a6ef-dcac1bbb92f1	[CLI] ✔ Loaded state from /tmp/state-1690950158-7-1c9op7o.json	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
bd9a4a31-739c-40a9-8f68-83acdb414f9a	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
1bda0bf0-3629-480b-a5a3-33332adea0c0	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
076a3807-efee-4598-939d-62ae755853fc	[CLI] ✔ Compiled job from /tmp/expression-1690950158-7-j8sgh1.js	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
30be9c81-0e79-4d58-b71d-7a24a2e35c98	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
7575774f-c232-410f-96fa-31fbc77cfe3f	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Does","given":["Given"]}],"resourceType":"Patient"}	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
0958cdd4-2112-4fc1-a693-cf903efe1491	[JOB] ℹ BirthDay: 1980-01-01	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
5d598c05-4af0-4d45-8863-370cb21b03d4	[JOB] ℹ firstName: Given	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
bbec9e66-f5fb-454d-89d9-d193cf85bfc7	[JOB] ℹ Surname: Does	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
5e71fdb2-d69f-416a-9d55-83b1a1f6d210	Preparing create operation...	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
a2f1b582-547d-4a1e-ae49-7dec84a33abd	Using latest available version of the DHIS2 api on this server.	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
a52ae432-7651-4012-b97b-c73db41b69cb	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
4c327e10-8abf-4309-b431-ead385724155	✓ Success at Wed Aug 02 2023 04:22:39 GMT+0000 (Coordinated Universal Time):	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
4d59fa92-e5ce-400c-81cb-0210e4ec9c1b	∟ Created trackedEntityInstances with response {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
479d6a4d-edc7-4f1a-90b7-1e4b338e9ae8	  "httpStatus": "OK",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
870e8bc2-f521-4bad-9dea-afaf0ff89b39	  "httpStatusCode": 200,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
48765380-cfa7-46c0-becd-29ba6c2b4ad1	  "status": "OK",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
4ae92edf-8b67-40a3-a6ec-405189237905	  "message": "Import was successful.",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
2b219181-2339-4273-80a8-683e4ba96803	  "response": {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
bae17341-4e37-4015-88d9-b4f373d87e54	    "responseType": "ImportSummaries",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
9031006a-82ca-4d56-b860-1bb1f03cd847	    "status": "SUCCESS",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
1beab801-d8e5-41a8-a3da-69a2ddd207b6	    "imported": 1,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
41887bee-86a8-4be7-acfc-7c10cd4f7c9c	    "updated": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b95d22ff-114f-40d3-a56c-5bd1dca022bb	    "deleted": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b2ae85e7-c20e-4087-89eb-921f92b98630	    "ignored": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
48cc35ff-e49b-4812-9540-d71c75fc1dca	    "importOptions": {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
be5f993d-f8a0-42db-8ce8-0f21ac431423	      "idSchemes": {},	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
7d3baa97-9e2b-449f-86b5-483be7fd53e0	      "dryRun": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
5cc447fb-e62b-4fcf-8273-012403023903	      "async": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
6970a12a-b9f2-4d3f-a818-74e7735afa2d	      "importStrategy": "CREATE_AND_UPDATE",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
401e301a-3136-4e13-831b-912aca0baa48	      "mergeMode": "REPLACE",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
02202ea0-abe3-456b-934c-9789e52f89e5	      "reportMode": "FULL",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
4391dd02-5259-4107-b7eb-3bf95f92ca59	      "skipExistingCheck": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
ad4f67dd-ef8e-4e5f-9c99-58220f9d3d43	      "sharing": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b627216c-25f1-4698-8993-a9c286175fc8	      "skipNotifications": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
3d463490-d2a0-46bb-828c-c9a92e6d9484	      "skipAudit": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
7c218f0d-8c54-416e-97ba-177e9d369fb9	      "datasetAllowsPeriods": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b40ebf89-9cbf-4d1b-993d-608e2b99db5c	      "strictPeriods": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
fb4888c0-0e65-4c0d-ae0a-f7fff962495a	      "strictDataElements": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
820d27ff-dc62-422c-8d2a-501dd869e50f	      "strictCategoryOptionCombos": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
3d596780-3aec-47a3-8117-8c054b3042a8	      "strictAttributeOptionCombos": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
c64e9741-1696-44d6-8bc1-7ce3490b99ed	      "strictOrganisationUnits": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
e856c45c-36c1-408d-aa43-51587705ae59	      "requireCategoryOptionCombo": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
44461640-7801-4b4c-b171-b468f6a2677d	      "requireAttributeOptionCombo": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
d3d834cd-8f80-4d92-a82e-a3b734bcc459	      "skipPatternValidation": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b58a92f1-042b-4486-b07c-50fcf2fb9901	      "ignoreEmptyCollection": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
73b61c1d-f8fb-43e1-a1b2-48b2d368f1a3	      "force": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
865ac737-d86f-4e6e-82d8-7122dd840f8d	      "firstRowIsHeader": true,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
170639a4-aae0-4555-80b1-06f02b55ba23	      "skipLastUpdated": true,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
d37fc693-d3ae-4498-ab37-111667a7437d	      "mergeDataValues": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
74030aa6-9ff7-43cd-9fc0-84bc8ec09990	      "skipCache": false	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
0e6961c7-a65e-4d6d-a20c-820a2782c014	    },	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
bef71630-0178-4b23-851e-c9b2b3ab27f5	    "importSummaries": [	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
c8ffd9da-08b0-4b7d-92e1-ca72d2166f8d	      {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
3af37380-75ac-4dcd-a184-a2a6615a19a9	        "responseType": "ImportSummary",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
9a855681-794a-4f68-b4be-9797f2613919	        "status": "SUCCESS",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
5acf2390-40e6-458b-afd8-00755680d0e7	        "importOptions": {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
244eebba-3273-4c48-a5cd-1e317714ad90	          "idSchemes": {},	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b59b34bf-86d3-43c9-bf50-b0f0a787fdf6	          "dryRun": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
99c00458-e593-4dc9-8876-f65e61d36501	          "async": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
6dc86fb1-9869-49b3-9882-f903b54d0a0d	          "importStrategy": "CREATE_AND_UPDATE",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
5efa4566-40be-4b8a-aef3-0f956987a28e	          "mergeMode": "REPLACE",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
be474b5e-08f9-4909-b470-16d32f789270	          "reportMode": "FULL",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
f360e8e9-6180-43d8-a80c-07c2c0264d17	          "skipExistingCheck": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
4d667c15-7bab-43e3-b3dc-aeb415628925	          "sharing": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
3a1a8802-4427-4763-ba8c-4a0572564767	          "skipNotifications": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
1b75accc-fd11-4696-a7f0-fb828a12fe32	          "datasetAllowsPeriods": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
22686493-9c9a-44c0-a712-84dbe894a48a	          "strictPeriods": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
9806bef9-0138-47c9-a4a3-e0172bc9eaf0	          "strictDataElements": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
2462abc0-2d7e-4cc4-9b24-7cd4b9bc4518	          "strictCategoryOptionCombos": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
0478a2ef-5c3a-451c-b748-7a64be59af5d	          "strictAttributeOptionCombos": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
315f9810-822d-40f0-bc76-610eb6866889	          "strictOrganisationUnits": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
ec648acd-4e77-492d-9af2-87dab9576015	          "requireCategoryOptionCombo": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
95f6f6c9-e72f-42ae-88f8-857964153d41	          "requireAttributeOptionCombo": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
417e5c04-682e-4cba-abef-c679609695bb	          "skipPatternValidation": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
9aa7c88a-0a2c-4c57-b46c-495c6eaf3c9e	          "ignoreEmptyCollection": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
8e564ecb-b4bd-4750-8290-90ea80a643a1	          "force": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
eb9ae9da-8c46-44b5-80be-13e241d36aea	          "firstRowIsHeader": true,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
cbf7f89e-add2-4406-aa91-f2be8790303c	          "skipLastUpdated": true,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
ba358d64-89f4-40c4-8b3e-13d622dee471	          "mergeDataValues": false,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
c6e048c8-1161-42fb-92f0-4ebadef63ba4	          "skipCache": false	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
5721d7b2-5149-4dcb-ae40-8143daf36070	        },	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
6e975b1e-ae30-44a4-9b57-c98108d46f6e	        "importCount": {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
217e9ef1-cd73-4b2d-aeea-ce718413a3e9	          "imported": 1,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
491fdd99-e362-44f3-b8d7-35a3870c1289	          "updated": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
f11d46f3-94c0-4e68-83ec-93927efc32c5	          "ignored": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
6ff55364-1b49-4420-a89c-dc3f9efad3a2	          "deleted": 0	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
12bbe5d7-5da6-4fbe-962d-5b65d7e5674a	        },	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
90ea5427-114a-44fd-9cbd-3f465c53da4c	        "conflicts": [],	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
d8188e21-eb70-4ae3-a7cc-a1cc8e479d65	        "reference": "I4wshQnY2q0",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
c97fcb63-6bbf-49c5-8f4f-759abd1903d9	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/I4wshQnY2q0",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
a5ba5c5d-1f61-468a-9719-a19c86bcb894	        "enrollments": {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
34a9a8bc-aa03-4fde-9609-3c8f5e88e139	          "responseType": "ImportSummaries",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
ea05b15a-d913-4046-8e00-2384e2fb9b1f	          "status": "SUCCESS",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
06858f6f-e1bd-46c5-afa3-f3cbd2e38406	          "imported": 1,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
e6065e1b-55b4-4687-87ff-bdbdf0a0adac	          "updated": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
bed82770-ebe8-49fd-a9cc-36fed86d5eaf	          "deleted": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
e8ba5c18-a502-4364-afb5-9c94f03e75ad	          "ignored": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
f88a0b0b-995f-4a89-ad2d-b109a94cea80	          "importSummaries": [	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
e0567aec-6d2c-4a19-830c-78617100a3f7	            {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
4ac5b2f3-09f5-4013-9d13-83536dcd9d52	              "responseType": "ImportSummary",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
09bd31b4-40a2-47f7-93d7-fe5b0c4ecf83	              "status": "SUCCESS",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
901fc945-cae4-427c-8d13-3c223698c73b	              "importCount": {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
45a664b4-98be-43d0-850b-b35f583fd62d	                "imported": 1,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b303c116-4c6e-40c2-822e-a42ddab18748	                "updated": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
cd47b815-29b3-4cba-a19d-c47bc11c8fc5	                "ignored": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
e51d805e-9afc-4265-9baa-c1fe6cbf91c1	                "deleted": 0	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
0985459e-9940-4eb5-b4d0-44c919ae9a36	              },	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
d82b51f2-3e1c-450b-8b2c-2a4d4d865ab2	              "conflicts": [],	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
bf0f28b5-4fcd-4d34-b9ab-f9bd8877a9a6	              "reference": "BFIwdb0Yphy",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
affa90fd-dbf0-4955-a0e9-6dcd157fa6cd	              "events": {	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
dabb10e4-590b-41a9-9c0f-166e94739bf0	                "responseType": "ImportSummaries",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
f07bd70a-8b94-473c-b3b3-a8155909f5f5	                "status": "SUCCESS",	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
15d462ab-4b99-4209-a13c-d916b5f4bedf	                "imported": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
6c1ac492-72f4-4ef1-ae91-cce274271b50	                "updated": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
8b59657a-863d-4316-96f9-bff0decd1c4a	                "deleted": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
2ec92632-131c-47c9-bf21-5b3999459a56	                "ignored": 0,	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
db50dd9b-918d-4c4f-a660-d8f23325988e	                "importSummaries": [],	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
a7c48607-c2f6-4cb2-9207-7f2157111c03	                "total": 0	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b57096b9-867f-492b-957d-46833d101c30	              }	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
6018b790-c850-43b8-8664-f0fc305eaeda	            }	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
67184b54-24a6-4c55-9586-9e31d2eb1943	          ],	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
53729687-37b2-45de-a4ad-ed3ae5a66c6f	          "total": 1	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
b2c0224c-2e00-4453-bad1-1dee1327a2aa	        }	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
aa0ec4f8-6a8e-4a69-b146-c45e3f96cde5	      }	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
54c94387-c592-4c45-9f2c-029e5625f554	    ],	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
cbed1573-f5f2-4892-8563-838d1814daaa	    "total": 1	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
d98d767d-64d4-4e96-b27e-dea006b2b13e	  }	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
91a11d23-1bcb-4899-aa90-13b030d8f6fa	}	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
5f35c8b8-a121-449b-97d1-d59954340503	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/I4wshQnY2q0	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
d129dade-656a-43bd-8972-42ee205e7613	[R/T] ✔ Operation 1 complete in 304ms	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
73bede5c-156f-4cc8-b91f-3982982e8bf4	[CLI] ✔ Writing output to /tmp/output-1690950158-7-dmkv6x.json	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
8a3401f1-6f29-4502-a3fa-86d34f29669f	[CLI] ✔ Done in 732ms! ✨	\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
f8477dcb-cb02-4074-aec9-4cfcc2e2001e		\N	349424dd-e236-43b4-9975-ba948d79b1a0	2023-08-02 04:22:40
1087726f-ae78-42a4-bcf6-51ee41bc96d1	[CLI] ℹ Versions:	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
fb2df30d-e235-4ddf-a695-a8f57bdc23ec	         ▸ node.js                   18.12.0	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
0cdc6c70-0a4c-4a32-b663-796c58e03f78	         ▸ cli                       0.0.35	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
e2f0c21a-3176-48db-b668-8e629ec91922	         ▸ runtime                   0.0.21	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b5585bc3-0ad7-4137-b245-ab4cc014719b	         ▸ compiler                  0.0.29	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
87a644a9-2949-40a8-ab12-cd643fad2ecb	         ▸ @openfn/language-dhis2    4.0.2	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
980faaa9-43b3-4d5c-978f-8e5029600b51	[CLI] ✔ Loaded state from /tmp/state-1690955192-7-62dupz.json	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
8f897c8b-2c52-470f-b356-a14cf24196fe	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
10fc4d36-0694-45b5-a890-456725906c28	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
3c788ac0-c995-4894-94d9-3c048cb36aaa	[CLI] ✔ Compiled job from /tmp/expression-1690955192-7-1wagweb.js	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
c1a9493b-fa13-4b05-80b6-587292b87048	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
0aef680c-1c91-4c61-b785-9dfddce2eedc	[JOB] ℹ {"birthDate":"1980-01-01","gender":"male","id":"example","name":[{"family":"Test","given":["Two"]}],"resourceType":"Patient"}	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
4f3d8f65-099e-49ea-82a6-f8fe3368b874	[JOB] ℹ BirthDay: 1980-01-01	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
a7cb8ed6-dbcb-430e-b629-04c5458d6735	[JOB] ℹ firstName: Two	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
f5c93d10-7f28-4ae4-bbf4-ee394522f6ba	[JOB] ℹ Surname: Test	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
a52348dc-6240-42c3-978c-84c78f77637a	Preparing create operation...	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
4a22cf7b-6e6a-4d50-ad37-7b950ce32f86	Using latest available version of the DHIS2 api on this server.	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
2d9ca371-bc5a-4a68-bcdc-5b4c90659485	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
029792da-0e04-498a-bb22-f53703661322	✓ Success at Wed Aug 02 2023 05:46:33 GMT+0000 (Coordinated Universal Time):	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
8b9bda92-1e5a-4d5f-aaa2-fd4c9b16f9aa	∟ Created trackedEntityInstances with response {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
294728de-93f9-4926-b97e-d0adf8ef04d9	  "httpStatus": "OK",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
d171ac6e-1b7f-4366-aa78-23d6d56f1aa4	  "httpStatusCode": 200,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
74619533-77e6-4f1f-9b6e-cdc98917f20a	  "status": "OK",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
3937fa68-6e34-4ce8-9a63-601532f7ed17	  "message": "Import was successful.",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
e60160d4-2864-43a4-8efd-7ce87612dba2	  "response": {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
a3b29f54-a082-494a-a9d6-f473e91419ef	    "responseType": "ImportSummaries",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
3e2712f0-7a7b-4d39-b45a-7a9f2f544572	    "status": "SUCCESS",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
abc8848d-77ba-4958-b48b-6e97e798986a	    "imported": 1,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
0acab0e0-60d1-447c-8fcf-b879a9342dde	    "updated": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
778a77ed-cf38-4150-8419-86fae2f4cf1f	    "deleted": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
11db6b23-efd4-411c-bdb5-c46fc3d8760b	    "ignored": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
3ce5be90-050b-4a3b-8aa3-9e50c10832f7	    "importOptions": {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
4acc8a3e-03b6-4441-a466-99589473613c	      "idSchemes": {},	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b4183d76-57e8-4072-80b1-07a57d972111	      "dryRun": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
1a8b5468-9d11-45e3-a2df-9f38e79bd2d6	      "async": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
87beb40b-7bae-45e9-ac9c-65cb8e33d3ef	      "importStrategy": "CREATE_AND_UPDATE",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
55fddf8e-e215-4292-b913-e5bc91451cb3	      "mergeMode": "REPLACE",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
c73894eb-b07a-4031-82de-374cb8f93d68	      "reportMode": "FULL",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
ad323dbc-47b3-47f3-a352-4e941c72a82b	      "skipExistingCheck": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b608e307-80b5-46d8-9cd3-65ca48b1ad18	      "sharing": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
e1bec763-3fef-4f8a-a8c8-f4b8dd72900e	      "skipNotifications": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
604165fd-ff43-4b09-a71d-39e4b3649f35	      "skipAudit": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
c4ca57bf-c855-4091-8dc2-b8e92a38d9fc	      "datasetAllowsPeriods": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
9d1e538e-1d00-41ea-8252-c78484e84b59	      "strictPeriods": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
df68032d-5983-41cc-826c-e4e631c4bc48	      "strictDataElements": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
7fa9dcd8-7264-4681-bb84-a4408248b3eb	      "strictCategoryOptionCombos": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
80109a88-28a4-4f24-b353-0216b74630c0	      "strictAttributeOptionCombos": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
e0bcec81-f7c3-4b74-a6f5-879d8fee3c10	      "strictOrganisationUnits": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
ac64fd3d-e6d0-48be-9760-3b42e3b6cdda	      "requireCategoryOptionCombo": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
0299edca-f2e2-4e22-b2aa-038aa535448f	      "requireAttributeOptionCombo": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
c2787a61-1b89-45ae-857f-11655ed39823	      "skipPatternValidation": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b647b020-e6f7-40d2-8f71-d0631064462a	      "ignoreEmptyCollection": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b805fdfa-1321-4ca1-b723-8ba15bfc3c20	      "force": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
25762cc6-bff9-42bc-8c06-d7ab2a719682	      "firstRowIsHeader": true,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
79eabf68-8986-4345-9291-e0c0f98823aa	      "skipLastUpdated": true,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
6c133c4f-61fb-4561-8baf-0eaf17b393d3	      "mergeDataValues": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
f046f9e2-6416-4c9c-9f40-d95f60078536	      "skipCache": false	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
c2ff3b0b-9d4b-41e9-b37d-2c6839c96883	    },	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
06d165b2-1021-44b2-b865-b61a6beee548	    "importSummaries": [	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
412649bd-1a78-4e19-b39b-f72989584e6d	      {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
37cec241-b7bf-490e-b607-5bcfa674a310	        "responseType": "ImportSummary",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
ede4e757-cc48-4c3c-9a03-277c3bdb59b9	        "status": "SUCCESS",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
7943453f-0f72-4bce-a9ff-b1a6075478ff	        "importOptions": {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b64299c2-a133-4eaf-adf6-079398f8ec98	          "idSchemes": {},	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
6c865a75-ec47-41a4-a401-54550ebbd9b7	          "dryRun": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
cfe3e070-84ad-45dd-b041-98ed09f0be2a	          "async": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
d9809dd4-6d63-43f3-ae02-692a64798909	          "importStrategy": "CREATE_AND_UPDATE",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
3e355726-e6d6-4079-8bb1-d3b5e04af591	          "mergeMode": "REPLACE",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
dcb9c9de-856e-4895-b1d9-c8dccf847671	          "reportMode": "FULL",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
d17cdc04-4080-441a-a713-83ff30c28a2b	          "skipExistingCheck": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
a8bc27b6-361d-4fa1-9a23-77c76f354342	          "sharing": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
a7e82f5b-569a-4ff6-bcf9-4e544c285b3b	          "skipNotifications": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
26a8539c-47db-459f-a0f6-dac3a12494e8	          "skipAudit": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
635e4bc1-28cb-4f1d-83c4-f659a7761129	          "datasetAllowsPeriods": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
69ed8ee7-3ddc-4b0f-8ff9-8ca87e60790a	          "strictPeriods": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
26b1556e-b003-48be-92f0-7aeadb1db1fa	          "strictDataElements": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
357fe4ce-7ba4-46a3-a9a1-9bac5b6051e3	          "strictCategoryOptionCombos": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
f181f16e-9fbf-4f2e-8bf0-bf5cca0f0593	          "strictAttributeOptionCombos": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
36166e49-caef-4338-9563-994e7b72fe60	          "strictOrganisationUnits": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
26b10e06-4fe8-452a-b125-dc66468369cb	          "requireCategoryOptionCombo": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
08573e94-695b-409b-8088-d64fe2213503	          "requireAttributeOptionCombo": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b5ae2e2a-7905-4dea-9195-35770070dfcc	          "skipPatternValidation": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b85ef63a-64dd-4789-a284-f83ab10a1c92	          "ignoreEmptyCollection": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
1a3d6d69-255b-4087-b7b4-ac22cc347b54	          "force": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
4750e288-28f3-44c6-a80d-de8995b5e851	          "firstRowIsHeader": true,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
42cf142a-a88e-4362-a071-4ad509b7f9a9	          "skipLastUpdated": true,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
82a5b57e-f036-4228-9233-3c9c7300d0ea	          "mergeDataValues": false,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
7e7662a1-194d-4ee5-8392-f9a471a91b19	          "skipCache": false	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
06661be9-4de9-4995-ab46-fb7900181349	        },	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
8629b400-2396-4084-a08d-1ee196f73c58	        "importCount": {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
84b114db-b5ac-4d92-9da1-c899ac2a2c21	          "imported": 1,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
3b8ceeaf-5813-4172-8aac-9943e7051169	          "updated": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
532b3271-b88a-4a7e-a746-2ae0ba583bbb	          "ignored": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
3fc04de2-9f2d-434c-977f-a2227634772d	          "deleted": 0	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
ca30386f-4d00-4713-8579-e9d907f977bb	        },	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
42caa18e-a5c1-4706-91fd-3fabb6b519e4	        "conflicts": [],	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
023477be-5245-460c-b8fc-fe467ee5d82a	        "reference": "u1UMcBla8xa",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
57c2f5f8-c14a-4375-af13-734ab0d31d1d	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/u1UMcBla8xa",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
3dc4bb9a-43d9-42e7-9388-1a1ee431b278	        "enrollments": {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b0501ff1-7f3f-4a28-aca9-d4d71e1cb6c0	          "responseType": "ImportSummaries",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
a299b653-3b7d-41d5-ae70-03568f6d9024	          "status": "SUCCESS",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
e0c4ffd0-5ac8-4a56-a4d8-b586df7117bc	          "imported": 1,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
e70d05fb-122c-4b8a-bba4-ca09f1df800e	          "updated": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
6ca3be05-1b45-490f-8c03-075d0f283aaa	          "deleted": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
94a27481-aa40-4e17-855e-2994124968a4	          "ignored": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
01206949-e6e0-41a0-bb6e-8de5a52c4821	          "importSummaries": [	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
e2bf6672-5110-43d7-b199-388ce0e2f7bf	            {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
06773ba2-4b97-4454-a0f3-a5c3166af96d	              "responseType": "ImportSummary",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
11f40509-5def-4cd0-a014-31f214758017	              "status": "SUCCESS",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
75899f85-c5fa-44f8-acbe-ab7540e5bdb8	              "importCount": {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
256c9858-7989-4263-8a60-e1fe36731741	                "imported": 1,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
d2f91bcc-269a-40bf-8be0-6b9789f60012	                "updated": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
14ef0f7d-bd95-4c63-8926-56668b8a90dd	                "ignored": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
2a46679d-b68a-4569-891c-15ce50bae3c9	                "deleted": 0	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b31c6534-650b-42d6-94b8-d6cb2b83350a	              },	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
92d41293-181e-4432-8ad7-8bc75e5d8aa1	              "conflicts": [],	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
582fef47-7496-42f6-b02b-c884e9d787ff	              "reference": "EVkRG41WXz6",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
bf0dc756-bb13-43a8-9fa5-7f7685ad8fde	              "events": {	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
700a5723-5d75-4211-9658-e0b274bb131c	                "responseType": "ImportSummaries",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
438a19c4-8c77-4326-a907-d10cedc1832b	                "status": "SUCCESS",	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
2e658283-7660-40fc-b170-2453e0844d7b	                "imported": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
b7922782-69a7-435b-82bf-c0007420aec5	                "updated": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
5549b95a-eb68-445d-bd5b-6bb7c75baf15	                "deleted": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
15533b7e-3fdb-472c-9f73-b7860d1c839a	                "ignored": 0,	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
360de5a3-045b-4a3e-81f2-02a1844e4176	                "importSummaries": [],	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
6f25e812-f083-4bd3-b592-ad440de0fe4c	                "total": 0	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
dc0047dc-391b-4d92-9e46-f7dfcb1f1201	              }	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
41632314-b969-4e89-a295-de31d67e6757	            }	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
7249e588-17f6-4940-b860-52ce015d9f9b	          ],	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
6f2e24cf-a3ad-42aa-bda1-c33542d9183d	          "total": 1	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
784ed239-1680-4fad-a696-088cd1649ecc	        }	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
672be3b6-abb1-4410-b1b5-5afb17766f82	      }	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
91a1f53b-82ee-4843-b1d5-841addd8371c	    ],	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
82982c68-b80b-4f82-8e6d-10b7d20d2a9e	    "total": 1	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
76233b23-9508-408d-989d-0c0284dafd0e	  }	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
5d598052-c199-447e-9acd-b523ae171f74	}	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
cc267cc0-9012-45a5-a2cf-e889d82c84d2	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/u1UMcBla8xa	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
74d7228f-637a-4287-a764-7c8b8453c7d6	[R/T] ✔ Operation 1 complete in 238ms	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
ba4a9a1d-b017-46a2-b9d7-7ad8c19fa4d8	[CLI] ✔ Writing output to /tmp/output-1690955192-7-toq40p.json	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
8a1221e8-f9c1-4545-b455-0b01fb1debdc	[CLI] ✔ Done in 668ms! ✨	\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
382c4de2-eea0-41da-985b-b908868a28b9		\N	658e1cc5-e02c-41dc-bd5d-1204d71e3c17	2023-08-02 05:46:33
f6f9d16f-9bc4-499c-ba8b-6dc5bd77f224	[CLI] ℹ Versions:	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
c0d89083-386f-4e08-9b45-30a4b1f5430e	         ▸ node.js                   18.12.0	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
d630790a-40d2-4ab6-ab14-d36688e8841d	         ▸ cli                       0.0.35	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
ff3ea931-5378-41e6-b30a-af596cfcd220	         ▸ runtime                   0.0.21	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
66aaa746-8519-4327-b63c-1c5428e58075	         ▸ compiler                  0.0.29	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
e6b10bcb-65df-4e13-8cfe-da8db05cba0f	         ▸ @openfn/language-dhis2    4.0.2	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
1ae8ba32-2639-4121-8536-a0097b5b015e	[CLI] ✔ Loaded state from /tmp/state-1690958328-7-1mtmw93.json	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
738ae435-e310-4da7-a82a-3a39de2ea14c	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
6bc62c55-41bc-4f1b-8877-59f01febdbb2	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
bedb5e1c-d334-4e33-82c9-ce157654c52b	[CLI] ✔ Compiled job from /tmp/expression-1690958328-7-17pmqt.js	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
28ef88d7-5525-4e8b-9aab-3343c293d68d	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
6acb3c4c-4453-452b-999f-2b85a184ab12	[JOB] ℹ {	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
ac49dde8-05cf-4ded-8c62-6a6e6f23ab64	  "resourceType": "Patient",	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
b9c0683a-fee3-4014-bca3-eff156e570c3	  "id": "example",	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
94502e4b-bd24-4d96-84ae-a6544ee07ab5	  "name": [	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
857c89fe-952e-422f-9bb3-e9f5ddec2ad7	    {	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
b52c854a-30cc-4290-983b-f59a482d9026	      "family": "Does",	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
6abe3c70-c627-4d78-aba7-8461a337e651	      "given": ["Given"]	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
a3ad0c23-1172-48bd-a294-8622e5180b43	    }	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
0d398848-4220-42b9-88a2-6cfa00db35b1	  ],	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
b1611c97-9785-4d6c-ae49-f067e790d0ee	  "gender": "male",	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
49d8775d-9e35-4e6f-b8cb-3b7c5c3b4b1f	  "birthDate": "1980-01-01"	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
eb915269-ef25-42b9-826d-84b7b89b7aa9	}	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
cfad436b-449b-4704-a264-21fab23d55a0	vm:module(0):5	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
9f0b436b-10b8-44ca-bede-429f16cca415	const firstName = state.data.body.name[0].given[0];	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
6b5d1e85-e7fe-482c-9a08-d1107b9c114a	                                      ^	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
679cf28f-9d61-402e-bfff-13045164c9a9		\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
08e37ee7-2dc0-43ee-a960-9c3d8603520a	TypeError: Cannot read properties of undefined (reading '0')	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
c9be284e-16a9-477c-afd3-e680009e0ffd	    at vm:module(0):5:39	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
cbe8325b-961f-4f30-bd30-93b277cea659	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
1d6ca730-5d2a-4c60-8540-63031aac1861	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
adf64637-a6c7-4205-ae81-7a586731f5a5	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
d46d606a-55c2-417a-81b4-3bc5678d0cbb	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
f2ba6b59-455f-428e-a0bf-280ec51fad02		\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
4efdfebd-ed31-449b-b074-b314996d4391	Node.js v18.12.0	\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
f36f6e43-717b-43c0-b57b-fbdfb495afcd		\N	69ffadf0-ec20-404c-8ecf-2509be615806	2023-08-02 06:38:49
046275ea-9c08-441e-b121-28829b14dd4f	[CLI] ℹ Versions:	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
e7d82952-6141-482f-b13e-c5c535e98551	         ▸ node.js                   18.12.0	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
ed865af4-8789-42b6-9304-2f2ae278a3eb	         ▸ cli                       0.0.35	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
5a62d32d-7c2e-46ea-aecf-f7a2578cc129	         ▸ runtime                   0.0.21	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
bf33ce99-98bf-4f47-9f62-3364c126c080	         ▸ compiler                  0.0.29	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
672664bd-6022-4be2-9615-0fde12478867	         ▸ @openfn/language-dhis2    4.0.2	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
938bada7-e227-4c75-9a49-ea4e0dab4b33	[CLI] ✔ Loaded state from /tmp/state-1690958409-7-1w82on0.json	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
3422ac0d-36ff-4cb5-bd27-8ebe6498a7da	[CLI] ✔ Compiled job from /tmp/expression-1690958409-7-13df2qi.js	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
dd4069f6-c418-4969-af2a-1d15a8dea1bc	[JOB] ℹ {	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
525608da-5912-481a-a897-8397eb8e1702	  "resourceType": "Patient",	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
1b584fc5-5530-4005-af3a-e1f901ab143d	  "id": "example",	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
be36fc1d-75b5-406c-8633-73c621da7372	  "name": [	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
70d81cf6-2859-4f15-8efd-c16946aa1a04	    {	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
51390f8c-0dd8-4298-92e1-1743c8cb52cc	      "family": "Does",	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
10b06be2-eee8-44a6-b04e-a0368649a313	      "given": ["Given"]	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
3adae579-edb7-4026-aae8-54b65001f5c6	    }	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
da928a5c-f3c9-4d4d-9733-dfee055395b4	  ],	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
bb442201-b0f5-4121-b74e-6ae60a389cb7	  "gender": "male",	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
6a6ab1d7-6c92-4071-aef5-6bb788aea338	  "birthDate": "1980-01-01"	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
f8603fa1-944d-47e7-974d-02400aef0f72	}	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
1df6177f-e43c-43cf-8860-5d605eb211c4	vm:module(0):3	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
e3241414-188b-4da1-b5bd-120c514e9018	const firstName = state.data.body.name[0].given[0];	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
a461dc6b-5edd-4647-bfea-e9d2b505623f	                                      ^	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
b9571218-147a-4706-9e77-8c687e55afae		\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
943837a2-d86c-4b85-b455-02ae3d827e93	TypeError: Cannot read properties of undefined (reading '0')	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
dbd9d195-61d4-438d-8388-86f2c8f7b2a3	    at vm:module(0):3:39	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
d5c8c6f8-500a-4b4f-8881-59bb11c6482b	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
246bc9b0-9106-46e1-b317-01f16ecef15f	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
83f27378-29da-434f-8d8b-bdf30e1955cb	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
e84dbccf-f7ba-4431-b762-9d4939065606	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
0d9c8814-cfab-4e12-936c-1c15d902d0cf		\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
f50440c6-8282-430b-a700-4f601983c4e3	Node.js v18.12.0	\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
a4f8c0da-95fd-4393-9e09-5974447de897		\N	3de46714-2122-4b29-a4da-00d416093d3a	2023-08-02 06:40:11
3e08861f-2fb5-4344-aaf0-9cd2542a0be3	[CLI] ℹ Versions:	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
5c957242-2b9e-4c98-904b-2b486d7275a1	         ▸ node.js                   18.12.0	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
57a5a591-7f25-41b9-83d2-aa4a5b7764b4	         ▸ cli                       0.0.35	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
ed91319c-60fc-4f0d-a17a-80c526beb380	         ▸ runtime                   0.0.21	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
878bf327-54b2-4df0-9137-ecea38506f1d	         ▸ compiler                  0.0.29	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
dc412375-c369-4c1b-af77-9e938d2c6e80	         ▸ @openfn/language-dhis2    4.0.2	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
6b016d0b-061a-432e-9db0-23a6e77c2ca4	[CLI] ✔ Loaded state from /tmp/state-1690958581-7-mgso54.json	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
d92a27e3-d8d9-4dfe-9160-a51f2a0b851f	[CLI] ✔ Compiled job from /tmp/expression-1690958581-7-gwxsir.js	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
00fcecd5-9700-4d37-bdb3-5d769a2faaa5	[JOB] ℹ undefined	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
62bba358-9f06-491e-9566-c2b1dce1b74b	[JOB] ℹ BirthDay: undefined	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
35333039-de90-4532-bae7-88a2d356703b	[JOB] ℹ firstName: undefined	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
7e5037a2-fc89-4fc1-b7bc-03b19790c881	[CLI] ✔ Writing output to /tmp/output-1690958581-7-c4t520.json	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
4731b97f-f01f-4c10-ae6d-1181d637122e	[CLI] ✔ Done in 181ms! ✨	\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
6d33c861-c3bd-4c66-b260-caa4378b5527		\N	1f0c094b-5b20-4541-9985-b57f8e92e4d4	2023-08-02 06:43:03
b9a1be47-7f64-4f08-a6ff-fb4b342939c8	[CLI] ℹ Versions:	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
6ca0426f-d185-44da-afdb-552e526cf8dc	         ▸ node.js                   18.12.0	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
0b0baacc-07fc-4a99-92e6-d27151252494	         ▸ cli                       0.0.35	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
52b87a0c-d7da-4dd2-9bd0-14f391ccb8d6	         ▸ runtime                   0.0.21	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
d4084d5f-d3da-4945-b696-b5d90e8b7bbf	         ▸ compiler                  0.0.29	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
e6a1b85b-d9b9-41e4-9726-27503c978673	         ▸ @openfn/language-dhis2    4.0.2	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
6e7f4cfe-dea6-48c0-8a1b-c6498b9292d3	[CLI] ✔ Loaded state from /tmp/state-1690958463-7-mvjik5.json	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
736cea60-a4f5-4d1f-810d-7f5c68e9c5c5	[CLI] ✔ Compiled job from /tmp/expression-1690958463-7-erx4hk.js	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
98ccc86b-5c57-4012-a074-efc58d05ef7f	[JOB] ℹ {	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
943ef203-4713-441e-a327-ba50b0352d54	  "resourceType": "Patient",	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
763d6f18-0fe8-437d-8876-be276653cbb5	  "id": "example",	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
1f2afd9b-baef-47e8-9ffd-1f51098c787e	  "name": [	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
e4d61c92-0355-455e-b264-286198873770	    {	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
6e42a223-e0e1-4370-b867-779d94043f03	      "family": "Does",	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
772a7476-ab0b-4146-bd24-6c7b26704d79	      "given": ["Given"]	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
6ee9d910-6a3d-4256-bd5b-d44f866d726b	    }	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
588897c3-d86d-40c4-b7b8-1c58a31491dc	  ],	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
12a22692-b800-4074-af72-8ed2a9f9cb5b	  "gender": "male",	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
fbf4b279-6cce-4d44-a0cb-b7f7d5b6b4b8	  "birthDate": "1980-01-01"	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
9dcbe799-a88c-497e-a1c5-d432b0463c10	}	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
e64b07d8-1d13-43f3-87ba-d7f0518a86e0	[JOB] ℹ BirthDay: undefined	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
ff90536e-6a44-44e2-958c-951f3c3749e7	[JOB] ℹ firstName: undefined	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
3c90cc9a-ed48-42bc-91ed-d826ad4a3772	[CLI] ✔ Writing output to /tmp/output-1690958463-7-faqx7g.json	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
1a03b668-f58b-409b-9f54-801fab4e52d4	[CLI] ✔ Done in 186ms! ✨	\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
616a8282-5f7b-44c2-bba3-5d8036067525		\N	60641858-bd17-4bd0-b837-3432475a12ea	2023-08-02 06:41:05
d88ee934-6788-4fc6-89c8-f56b679e2883	[CLI] ℹ Versions:	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
18571f93-056c-4c5a-88db-a8ce10dc36e1	         ▸ node.js                   18.12.0	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
43c4194c-1471-40e2-b778-e6dab125eb36	         ▸ cli                       0.0.35	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
283a89e0-ef58-4c4c-8726-acec6cc2d045	         ▸ runtime                   0.0.21	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
6e2646f2-6eb1-4b03-af50-3045b63f47d1	         ▸ compiler                  0.0.29	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
759687cf-b28c-4f03-bbbd-3b9e960d8578	         ▸ @openfn/language-dhis2    4.0.2	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
6503495b-2deb-4975-bc6d-3ec845138155	[CLI] ✔ Loaded state from /tmp/state-1690958677-7-vlqa6b.json	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
9d00fbf2-04f1-4ad1-9aea-552d696fbfd3	[CLI] ✔ Compiled job from /tmp/expression-1690958677-7-15xv0eg.js	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
660885b7-ab2b-4e08-8b7e-55e323952b67	[JOB] ℹ undefined	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
b33cc38a-0e21-46e5-9b87-01df537418a7	[JOB] ℹ male	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
3fc637cf-5336-4927-a9c7-c9347c934a40	[JOB] ℹ BirthDay: undefined	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
c897a709-0810-4c4d-a640-93c21f77d3ee	[JOB] ℹ firstName: undefined	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
9ff862fe-ec58-43c1-b42f-2d788f283a98	[CLI] ✔ Writing output to /tmp/output-1690958677-7-15ft9aj.json	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
fe162aad-1fd9-4ef5-a41d-f46d92f631fe	[CLI] ✔ Done in 183ms! ✨	\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
833d8699-7f8c-4606-8d05-f08ca5897f9b		\N	e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	2023-08-02 06:44:39
a37e372f-ce7b-435c-98b3-e243f48c76f4	[CLI] ℹ Versions:	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
8bfe0de8-1fbe-4fab-bc96-0967a0274a20	         ▸ node.js                   18.12.0	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
dae588bf-97e2-4527-9bd0-b41b152b3f65	         ▸ cli                       0.0.35	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
6c2def73-1b9c-45fe-a61d-9045004c65dc	         ▸ runtime                   0.0.21	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
980bc5f1-3774-4fd7-afe4-ff2bb23e3821	         ▸ compiler                  0.0.29	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
bd0fd90e-191f-467f-affc-3d5b0ee1da75	         ▸ @openfn/language-dhis2    4.0.2	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
ef672abd-d182-4ffa-94a5-65569209cdcf	[CLI] ✔ Loaded state from /tmp/state-1690958735-7-w6lsh7.json	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
e96fd0bd-bfc9-48e0-a204-27eea561b91b	[CLI] ✔ Compiled job from /tmp/expression-1690958735-7-uy7ans.js	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
33df0264-fdc3-462c-b203-d849627f5329	[JOB] ℹ undefined	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
d520efa9-903c-4f1d-bb02-790427649401	[JOB] ℹ male	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
e38cb5a7-790c-43d7-b3cb-ab6c842360c4	[JOB] ℹ BirthDay: 1980-01-01	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
dc50d10f-7ff0-46eb-8367-ca5736eab3c8	[JOB] ℹ firstName: [object Object]	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
35438a12-724d-4b4c-be07-1626ff337465	[CLI] ✔ Writing output to /tmp/output-1690958735-7-lv4c2w.json	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
0e239036-4501-4164-aedb-f1952e590dc7	[CLI] ✔ Done in 179ms! ✨	\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
13d79baa-c254-468c-9e9d-56fdd1c75e76		\N	7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	2023-08-02 06:45:36
4965f397-805f-4bc1-a5e8-54606da4919f	[CLI] ℹ Versions:	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
3c798b6a-f125-46c9-bd46-e94889f93dc2	         ▸ node.js                   18.12.0	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
e24a3216-b587-4dae-8579-9d21e7a7878f	         ▸ cli                       0.0.35	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
1d1a4b20-956f-498e-b203-8d8cd3a07820	         ▸ runtime                   0.0.21	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
ffd212a3-d715-4eab-98e2-1b164d2be869	         ▸ compiler                  0.0.29	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
8e52e458-cf92-4927-b9df-72a9e4dfa5d1	         ▸ @openfn/language-dhis2    4.0.2	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
adfb301a-2de1-4f79-9046-00ad693d7e04	[CLI] ✔ Loaded state from /tmp/state-1690958826-7-l99pqg.json	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
d027dfbb-29bf-409c-b69d-49f0121cd7f5	[CLI] ✔ Compiled job from /tmp/expression-1690958826-7-ne2dep.js	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
4bfb1380-8fc7-4750-baed-d4814faddafb	[JOB] ℹ undefined	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
1f236411-455d-48c9-82a9-96d9fbafe6e4	[JOB] ℹ BirthDay: 1980-01-01	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
e1070648-a0aa-4f4b-9855-20017a13884c	[JOB] ℹ firstName: Given	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
2ba11cb5-7223-4571-b890-e8664c9aac08	[JOB] ℹ Surname: Does	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
a3542bcb-ce37-426b-9b4f-913a47aa3960	[CLI] ✔ Writing output to /tmp/output-1690958826-7-8u7199.json	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
88fcf417-bdfc-4cc3-b4eb-a09c276c4ff9	[CLI] ✔ Done in 192ms! ✨	\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
568be0a6-e50f-46b9-98ba-a1d2641ead5a		\N	a60795f1-a685-4c29-b23f-e36802128ec6	2023-08-02 06:47:08
eba0900a-b4a1-4196-b7f7-39b4a87c6ffd	[CLI] ℹ Versions:	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
70789bea-b6b4-4441-9f13-faaab4516cd0	         ▸ node.js                   18.12.0	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
ab43b1fe-3437-46e7-9c55-bde674902e69	         ▸ cli                       0.0.35	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
8bdabb24-523e-44cf-acf7-0c1f1cf098d4	         ▸ runtime                   0.0.21	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
8885fd57-d901-4e04-b01b-ef8a6bdcaca0	         ▸ compiler                  0.0.29	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
dd1eb34a-54a8-4943-9f8f-442d837b7e06	         ▸ @openfn/language-dhis2    4.0.2	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
6ab5093d-2b56-4b3b-82bf-f4f98739f515	[CLI] ✔ Loaded state from /tmp/state-1690958894-7-18zl3nh.json	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
0e102c78-a845-4db0-827d-4b4271f78007	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
0c63bdea-92d8-42c6-b0c3-2ffb490905b7	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
761b9a18-b8ad-46a2-86dd-a65c9de41eba	[CLI] ✔ Compiled job from /tmp/expression-1690958894-7-1grj6uw.js	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
b36b96f8-85bd-49f8-975b-92f4851e1a15	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
31900c54-6398-46dc-a925-934321fac493	[JOB] ℹ BirthDay: 1980-01-01	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
d72f2e90-8c3f-4733-ae32-03e32f9cde4c	[JOB] ℹ firstName: Wednsday	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
b7eba0b7-657a-4dcb-9492-cb28498386d5	[JOB] ℹ Surname: Testing	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
715c8724-beca-4a51-ab0f-702361c8eda0	Preparing create operation...	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
3bfd64ef-f980-4e03-9498-7ece1e96608f	Using latest available version of the DHIS2 api on this server.	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
50b7a9db-af6f-40ec-a891-ff4db8eebd8d	Sending post request to http://192.168.0.195:8081/api/trackedEntityInstances	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
27dab3b7-1156-4570-97ce-d1617dd211f1	✓ Success at Wed Aug 02 2023 06:48:15 GMT+0000 (Coordinated Universal Time):	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e0fe1699-3344-4f4d-b9fb-a37d65bfb638	∟ Created trackedEntityInstances with response {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
db02605a-0373-43c7-bbff-6655a3e45fc0	  "httpStatus": "OK",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
c52053dc-7714-4fae-b0d9-589673e80285	  "httpStatusCode": 200,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
437e4ad3-ff73-417a-8f6e-90d40215538b	  "status": "OK",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
1e818634-47b2-452e-88de-80c5fa16d583	  "message": "Import was successful.",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
a6945b50-8b87-4772-b9c1-e4f9267f4c41	  "response": {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
863d3066-1abe-4379-a240-f2eaa940fb95	    "responseType": "ImportSummaries",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
f48ce26b-f61e-4b20-bc22-88958192f76f	    "status": "SUCCESS",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
4227c9f3-f0b8-482e-aa1a-8c64077a492c	    "imported": 1,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
dda40f9c-96b8-4ea9-9634-d12b00796a85	    "updated": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
78336398-5c54-4353-88a7-316f6c37c2ca	    "deleted": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
8a01d29b-1188-41cf-9158-34da88601e2a	    "ignored": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
75f5eaf6-0131-4c65-a3c3-b875c1c6ffff	    "importOptions": {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e4bc6901-d3bb-4687-9f5a-47af1ff23c15	      "idSchemes": {},	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
74bb18a3-f2d7-455e-adc9-21dc9a4a0f7c	      "dryRun": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
09337cf4-9acf-498c-9db1-62c8cc235669	      "async": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
8049de0f-74c6-4ff8-8ddf-f485c132c0cf	      "importStrategy": "CREATE_AND_UPDATE",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
d5b99f3d-2196-423d-bfa9-3c0b0bbe4b23	      "mergeMode": "REPLACE",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
ebe43fcb-66b9-4ecd-a264-ac277d441d77	      "reportMode": "FULL",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
aca931f1-a326-4f7a-81ca-dbdf06bbc5d2	      "skipExistingCheck": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
17afaff1-bd99-420d-922e-34dcae7b82f3	      "sharing": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e4e46d40-d1dc-449a-82c9-5b7fb6e47e2b	      "skipNotifications": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
19135cae-d442-4544-adf4-5e92e8c8c388	      "skipAudit": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
fbca7b14-c18f-4a27-9380-68a9c2df51eb	      "datasetAllowsPeriods": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
60202698-9cc8-4e22-b037-30473b008442	      "strictPeriods": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
29994ec9-d863-43c8-86a0-fe7580376228	      "strictDataElements": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
0e71ea25-a091-46fc-b3a9-e87fb68da93f	      "strictCategoryOptionCombos": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
9512ca82-f4a3-49e3-8ce5-599c007374ac	      "strictAttributeOptionCombos": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
60d576c4-734c-4ad2-adde-e0211aac261d	      "strictOrganisationUnits": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
1f2e35a9-0100-4c00-b01d-7e779fd88420	      "requireCategoryOptionCombo": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e3c8623f-7f97-4bc1-875d-5ed2c8403cea	      "requireAttributeOptionCombo": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
270221eb-ca26-4f9f-8fd7-2d4c43e13313	      "skipPatternValidation": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
57fa2c2d-f627-44bd-8ca8-e03660730747	      "ignoreEmptyCollection": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
7cda405c-3a1c-4582-a9e3-5b97cc845845	      "force": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
4d290a03-3582-4c17-8f23-6c6b9dc936e7	      "firstRowIsHeader": true,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
7c23158a-9e53-43a1-9779-8395ff2a6b0b	      "skipLastUpdated": true,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
ea3f2d9c-b3cf-4dea-b970-a6dd0d83b33b	      "mergeDataValues": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
9eaa5fa4-4e76-4b22-9dcc-6af3ac75d19a	      "skipCache": false	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
db0600cb-74c2-4b3a-8a19-40358ae33bd8	    },	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
f6cc871c-3a8b-4d0e-9d06-aa424398ded4	    "importSummaries": [	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
bd27e046-6074-465a-a149-f6a98c0231fc	      {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
b5a28635-432d-43c8-ac87-f14d167efb06	        "responseType": "ImportSummary",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
a13f54d1-ec4a-46ed-a81c-70ee008d7be7	        "status": "SUCCESS",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
f853fd5e-e157-4323-bed2-4967222fd53a	        "importOptions": {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
d9a758a0-1228-4bd4-94f6-6fdff3c94ab9	          "idSchemes": {},	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
d1ebb071-7fab-48bb-b75e-706c83cea2d5	          "dryRun": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
59bbb0b6-a1e8-4ca8-bf99-e6d5ae56a155	          "async": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
c4eae8df-2797-4c53-8a8e-cccb1fd628fa	          "importStrategy": "CREATE_AND_UPDATE",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
a8e11396-701e-4ad3-b75a-5f7aaee870c8	          "mergeMode": "REPLACE",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
ebf78d36-7357-4e50-94fc-7f9e16918211	          "reportMode": "FULL",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
42febc1c-8caa-4118-b900-91aca06971db	          "skipExistingCheck": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
f2674dbe-4b27-417a-a842-d05c97153d5f	          "sharing": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
1e92f3c0-50f3-4f9a-aae1-cf1641fdb809	          "skipNotifications": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
27c102b2-4648-4751-b5e1-faf44d86a82d	          "skipAudit": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
6e2ac7c3-a068-4d54-a9c3-c85b1905bc21	          "datasetAllowsPeriods": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
87b4905c-6ec6-498e-a97f-4cd6e15b2d20	          "strictPeriods": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
f86f7a58-496d-4ad3-884e-92f947913262	          "strictDataElements": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e300ccc9-773a-48a6-81e9-b78b01f445e4	          "strictCategoryOptionCombos": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
84d89712-6000-4ec6-9c96-d84dd4bce7f4	          "strictAttributeOptionCombos": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
bc038e8b-4e64-4150-b8ec-3404217687c9	          "strictOrganisationUnits": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
821fa557-7f64-46b4-9637-aabfb239794e	          "requireCategoryOptionCombo": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
240751b7-0221-4c84-88ce-15edc5fbaf55	          "requireAttributeOptionCombo": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
bf3303c1-7d2b-4e8b-9c8a-a42090a20144	          "skipPatternValidation": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
ba24cdc7-11fe-44e8-9b91-247cb4f97903	          "ignoreEmptyCollection": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
8c17becb-9b7b-4aac-b6d0-8df84c7add54	          "force": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e2cc3f44-6b53-4424-8fa5-cfd175e3c2d8	          "firstRowIsHeader": true,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
19e21dd6-9012-4ae8-9812-82060c902b91	          "skipLastUpdated": true,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
40fb2464-9486-4d56-bc1f-61aa3d2c3448	          "mergeDataValues": false,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
3e57c4f1-5c92-4dde-8cd6-587e8e72ed21	          "skipCache": false	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
7a161b6b-21e4-44eb-a965-fcd51647591a	        },	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
a664cb20-27ed-4df4-abb0-c4bf6896a0d5	        "importCount": {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
c6205942-469a-4628-b0f5-d12183a4e347	          "imported": 1,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e1b4bb57-ed42-4d46-993d-14532eac9763	          "updated": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
9143d28b-3929-4e32-a4a7-bddcad8e0a19	          "ignored": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e2a7b005-606a-4c28-a103-3ca6cb32e69e	          "deleted": 0	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
7ee6ee71-4545-4d0a-9411-083583f5c319	        },	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
7bcc9234-b938-46ad-9bbd-3897d676c9f2	        "conflicts": [],	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
734a60ed-9683-4279-a6fe-e074d8e378f2	        "reference": "QDio09HCX6Y",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
787d14a8-0c47-470a-8867-ccb3a422bbbd	        "href": "http://192.168.0.195:8081/api/trackedEntityInstances/QDio09HCX6Y",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
c65ed3df-5732-486b-a523-eb82b9b229e6	        "enrollments": {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
1df4738f-06fd-4a6e-8e13-136d55a18363	          "responseType": "ImportSummaries",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e9977d9b-1632-430d-8ca8-c091ca748de6	          "status": "SUCCESS",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
d1b5cd56-5922-4cfb-a241-6c1093bbb275	          "imported": 1,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
0aca9496-f221-4c12-aa11-e8e366e14661	          "updated": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
bc5d23d0-28d6-4ece-90d7-c9b32d7d2e47	          "deleted": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
202785da-37a3-49ae-94fb-3b72ac81810f	          "ignored": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
01a3d95c-f4bb-4eb3-8b80-bb3a4b9f123d	          "importSummaries": [	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
690a780e-2978-4a17-ae80-4b7aedb815b2	            {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
a5d1980a-64db-4635-b3d3-829af9ccc757	              "responseType": "ImportSummary",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
5dbc3549-86b3-430a-a756-0d3782a0cda0	              "status": "SUCCESS",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
0009da92-e6af-4f57-b1d2-18e6979eb176	              "importCount": {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
a60eb594-fc5a-456b-9cf5-109ccfd244f1	                "imported": 1,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
8a33320c-5907-4330-8cc6-d2d042450303	                "updated": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
b4c37c79-45d4-4a1a-b300-43bca6f5cfec	                "ignored": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
7e25293f-a1ca-4951-9e29-b53839b74435	                "deleted": 0	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
797d5180-be05-4eac-89e1-a29e1404952e	              },	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
ff661bc1-2536-40ef-80a4-0795a95b8221	              "conflicts": [],	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
905c57a6-d665-4ef5-89cf-19b22b64010e	              "reference": "OqNaXFZQNk0",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
920f195b-325b-42e8-8b1b-2c9c124674f9	              "events": {	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
c468795b-d608-48cc-81dc-ad54b65eae72	                "responseType": "ImportSummaries",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
90e5b242-1a85-469a-bdc9-b6b83162872e	                "status": "SUCCESS",	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
1a40c482-613b-4db8-bdcd-1b763e121aa8	                "imported": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
00aef9b7-f8d0-46c2-81af-6119ba1c5e48	                "updated": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
6415bcc9-c7ed-4556-9069-2079125e6039	                "deleted": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
155a6df0-056a-4cbe-b310-f20258f89482	                "ignored": 0,	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
900c6eaf-a02f-4ccc-85f9-e3960e4977a9	                "importSummaries": [],	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
c1a63afc-ed76-40ae-9c81-e00435e509ba	                "total": 0	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
c381a83f-4610-4d9d-a34c-4f587ad4480e	              }	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
c35a7624-e232-498f-b44a-a99b9587bf4a	            }	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
9fb815ba-71aa-4562-ac87-899bc0241a37	          ],	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
b4c7cc06-a7fb-4eb0-94a3-e99602b2f523	          "total": 1	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
3034dd3d-4a44-402f-809c-dd1f162415e9	        }	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
66251af8-233f-45dd-b0e7-ef53bc8bb449	      }	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
6d207ade-bd3c-4764-a7bf-c44dcd8a05c0	    ],	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
e08764bf-a27c-427b-860e-4b01cacc6703	    "total": 1	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
7562fa51-6568-44eb-80dd-4b93a0a87efb	  }	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
bb5db712-87bf-492c-8526-fc5c64dd79d6	}	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
f1a72079-f5e8-4b95-afea-b99ad3773fd1	Record available @ http://192.168.0.195:8081/api/api/trackedEntityInstances/QDio09HCX6Y	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
f8c64613-0293-4cd1-9ca6-4eb8db53bc41	[R/T] ✔ Operation 1 complete in 210ms	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
cf3cf06c-12eb-4f86-a62b-cf7143cca448	[CLI] ✔ Writing output to /tmp/output-1690958894-7-e1pbn2.json	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
230e76ec-a9b1-425f-8974-4590bf95da65	[CLI] ✔ Done in 646ms! ✨	\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
deee9e65-3f52-4702-bf37-6952dc5e9a42		\N	09475541-2e1c-4267-857c-1bbc07b1b413	2023-08-02 06:48:16
\.


--
-- Data for Name: oban_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oban_jobs (id, state, queue, worker, args, errors, attempt, max_attempts, inserted_at, scheduled_at, attempted_at, completed_at, attempted_by, discarded_at, priority, tags, meta, cancelled_at) FROM stdin;
2050	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:02:00.954455	2023-08-02 09:02:00.954455	2023-08-02 09:02:01.065064	2023-08-02 09:02:01.072459	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2051	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:02:00.954455	2023-08-02 09:02:00.954455	2023-08-02 09:02:01.065156	2023-08-02 09:02:01.074867	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2078	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:15:00.039247	2023-08-02 09:15:00.039247	2023-08-02 09:15:00.143105	2023-08-02 09:15:00.146875	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1998	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:36:00.620266	2023-08-02 08:36:00.620266	2023-08-02 08:36:00.726027	2023-08-02 08:36:00.728905	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1999	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:36:00.620266	2023-08-02 08:36:00.620266	2023-08-02 08:36:00.726075	2023-08-02 08:36:00.729124	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2024	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:49:00.796502	2023-08-02 08:49:00.796502	2023-08-02 08:49:00.910049	2023-08-02 08:49:00.913759	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2025	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:49:00.796502	2023-08-02 08:49:00.796502	2023-08-02 08:49:00.910133	2023-08-02 08:49:00.915403	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2079	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:15:00.039247	2023-08-02 09:15:00.039247	2023-08-02 09:15:00.143035	2023-08-02 09:15:00.148125	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
717	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "f751bf30-72be-46ad-b683-c3de5455dbaa"}	{"{\\"at\\": \\"2023-08-01T22:23:42.980924Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.6) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-08-01 22:23:41.961373	2023-08-01 22:23:41.961373	2023-08-01 22:23:42.064987	\N	{lightning@e2458d3c9aef}	2023-08-01 22:23:42.980403	1	{}	{}	\N
2064	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:08:00.991204	2023-08-02 09:08:00.991204	2023-08-02 09:08:01.096061	2023-08-02 09:08:01.10004	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2065	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:08:00.991204	2023-08-02 09:08:00.991204	2023-08-02 09:08:01.095983	2023-08-02 09:08:01.100345	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2080	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:16:00.043205	2023-08-02 09:16:00.043205	2023-08-02 09:16:00.150122	2023-08-02 09:16:00.161637	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1992	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:33:00.582481	2023-08-02 08:33:00.582481	2023-08-02 08:33:00.690063	2023-08-02 08:33:00.694628	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2040	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:57:00.903517	2023-08-02 08:57:00.903517	2023-08-02 08:57:01.017144	2023-08-02 08:57:01.021791	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2081	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:16:00.043205	2023-08-02 09:16:00.043205	2023-08-02 09:16:00.150195	2023-08-02 09:16:00.162418	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1993	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:33:00.582481	2023-08-02 08:33:00.582481	2023-08-02 08:33:00.690145	2023-08-02 08:33:00.695788	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2041	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:57:00.903517	2023-08-02 08:57:00.903517	2023-08-02 08:57:01.017062	2023-08-02 08:57:01.022156	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2006	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:40:00.671414	2023-08-02 08:40:00.671414	2023-08-02 08:40:00.78615	2023-08-02 08:40:00.797841	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2007	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:40:00.671414	2023-08-02 08:40:00.671414	2023-08-02 08:40:00.78607	2023-08-02 08:40:00.798687	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2022	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:48:00.786207	2023-08-02 08:48:00.786207	2023-08-02 08:48:00.89615	2023-08-02 08:48:00.907749	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2023	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:48:00.786207	2023-08-02 08:48:00.786207	2023-08-02 08:48:00.896063	2023-08-02 08:48:00.908735	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2083	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:17:00.050378	2023-08-02 09:17:00.050378	2023-08-02 09:17:00.158181	2023-08-02 09:17:00.162069	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2026	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:50:00.810314	2023-08-02 08:50:00.810314	2023-08-02 08:50:00.926188	2023-08-02 08:50:00.931468	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2000	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:37:00.626689	2023-08-02 08:37:00.626689	2023-08-02 08:37:00.743098	2023-08-02 08:37:00.74734	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2001	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:37:00.626689	2023-08-02 08:37:00.626689	2023-08-02 08:37:00.743186	2023-08-02 08:37:00.747852	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2053	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:03:00.965233	2023-08-02 09:03:00.965233	2023-08-02 09:03:01.069144	2023-08-02 09:03:01.073488	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2052	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:03:00.965233	2023-08-02 09:03:00.965233	2023-08-02 09:03:01.069055	2023-08-02 09:03:01.073863	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2027	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:50:00.810314	2023-08-02 08:50:00.810314	2023-08-02 08:50:00.926374	2023-08-02 08:50:00.931644	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2098	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:25:00.123446	2023-08-02 09:25:00.123446	2023-08-02 09:25:00.23606	2023-08-02 09:25:00.239821	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2099	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:25:00.123446	2023-08-02 09:25:00.123446	2023-08-02 09:25:00.236147	2023-08-02 09:25:00.240513	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2036	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:55:00.880445	2023-08-02 08:55:00.880445	2023-08-02 08:55:00.989933	2023-08-02 08:55:00.992651	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2037	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:55:00.880445	2023-08-02 08:55:00.880445	2023-08-02 08:55:00.989097	2023-08-02 08:55:00.99273	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2066	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:09:00.996474	2023-08-02 09:09:00.996474	2023-08-02 09:09:01.105105	2023-08-02 09:09:01.111075	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1994	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:34:00.590467	2023-08-02 08:34:00.590467	2023-08-02 08:34:00.705141	2023-08-02 08:34:00.717411	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2067	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:09:00.996474	2023-08-02 09:09:00.996474	2023-08-02 09:09:01.105197	2023-08-02 09:09:01.112148	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1995	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:34:00.590467	2023-08-02 08:34:00.590467	2023-08-02 08:34:00.705054	2023-08-02 08:34:00.7177	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2042	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:58:00.917375	2023-08-02 08:58:00.917375	2023-08-02 08:58:01.032082	2023-08-02 08:58:01.036172	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2043	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:58:00.917375	2023-08-02 08:58:00.917375	2023-08-02 08:58:01.03213	2023-08-02 08:58:01.036405	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1996	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:35:00.605369	2023-08-02 08:35:00.605369	2023-08-02 08:35:00.720147	2023-08-02 08:35:00.723927	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1997	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:35:00.605369	2023-08-02 08:35:00.605369	2023-08-02 08:35:00.720067	2023-08-02 08:35:00.724194	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
763	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "dcc8f3ec-a727-4d7f-9eb7-5a34ff874600"}	{"{\\"at\\": \\"2023-08-01T22:40:04.396111Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.6) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-08-01 22:40:03.411881	2023-08-01 22:40:03.411881	2023-08-01 22:40:03.514009	\N	{lightning@e2458d3c9aef}	2023-08-01 22:40:04.395501	1	{}	{}	\N
2082	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:17:00.050378	2023-08-02 09:17:00.050378	2023-08-02 09:17:00.158084	2023-08-02 09:17:00.162122	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2028	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:51:00.827395	2023-08-02 08:51:00.827395	2023-08-02 08:51:00.941008	2023-08-02 08:51:00.945002	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2054	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:04:00.969258	2023-08-02 09:04:00.969258	2023-08-02 09:04:01.074009	2023-08-02 09:04:01.077515	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2055	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:04:00.969258	2023-08-02 09:04:00.969258	2023-08-02 09:04:01.074017	2023-08-02 09:04:01.078028	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2002	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:38:00.642494	2023-08-02 08:38:00.642494	2023-08-02 08:38:00.757154	2023-08-02 08:38:00.761812	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2003	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:38:00.642494	2023-08-02 08:38:00.642494	2023-08-02 08:38:00.757067	2023-08-02 08:38:00.762025	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1751	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "306bc9bf-6492-4b7d-9bf3-1cf30e2e5fb7"}	{"{\\"at\\": \\"2023-08-02T06:36:46.531480Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.6) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-08-02 06:36:45.272837	2023-08-02 06:36:45.272837	2023-08-02 06:36:45.375007	\N	{lightning@e2458d3c9aef}	2023-08-02 06:36:46.530839	1	{}	{}	\N
2029	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:51:00.827395	2023-08-02 08:51:00.827395	2023-08-02 08:51:00.941059	2023-08-02 08:51:00.94623	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2084	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:18:00.058337	2023-08-02 09:18:00.058337	2023-08-02 09:18:00.167057	2023-08-02 09:18:00.178719	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2085	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:18:00.058337	2023-08-02 09:18:00.058337	2023-08-02 09:18:00.167057	2023-08-02 09:18:00.179274	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1984	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:29:00.529422	2023-08-02 08:29:00.529422	2023-08-02 08:29:00.644147	2023-08-02 08:29:00.648225	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2004	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:39:00.65735	2023-08-02 08:39:00.65735	2023-08-02 08:39:00.77221	2023-08-02 08:39:00.776322	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2005	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:39:00.65735	2023-08-02 08:39:00.65735	2023-08-02 08:39:00.772077	2023-08-02 08:39:00.776879	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1985	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:29:00.529422	2023-08-02 08:29:00.529422	2023-08-02 08:29:00.644062	2023-08-02 08:29:00.649026	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2072	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:12:00.016549	2023-08-02 09:12:00.016549	2023-08-02 09:12:00.127039	2023-08-02 09:12:00.131359	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2073	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:12:00.016549	2023-08-02 09:12:00.016549	2023-08-02 09:12:00.127122	2023-08-02 09:12:00.132057	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2044	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:59:00.932282	2023-08-02 08:59:00.932282	2023-08-02 08:59:01.044052	2023-08-02 08:59:01.048738	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2045	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:59:00.932282	2023-08-02 08:59:00.932282	2023-08-02 08:59:01.044129	2023-08-02 08:59:01.049977	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2088	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:20:00.076483	2023-08-02 09:20:00.076483	2023-08-02 09:20:00.184095	2023-08-02 09:20:00.187642	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2089	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:20:00.076483	2023-08-02 09:20:00.076483	2023-08-02 09:20:00.18403	2023-08-02 09:20:00.187924	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
764	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "0a8707dc-9060-49ff-9206-1e8f63c0dd9f"}	{"{\\"at\\": \\"2023-08-01T22:40:27.841168Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.6) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-08-01 22:40:26.796603	2023-08-01 22:40:26.796603	2023-08-01 22:40:26.900001	\N	{lightning@e2458d3c9aef}	2023-08-01 22:40:27.840165	1	{}	{}	\N
2030	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:52:00.841444	2023-08-02 08:52:00.841444	2023-08-02 08:52:00.955141	2023-08-02 08:52:00.958729	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2086	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:19:00.067367	2023-08-02 09:19:00.067367	2023-08-02 09:19:00.176069	2023-08-02 09:19:00.180691	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2087	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:19:00.067367	2023-08-02 09:19:00.067367	2023-08-02 09:19:00.176196	2023-08-02 09:19:00.181843	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1978	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:26:00.494464	2023-08-02 08:26:00.494464	2023-08-02 08:26:00.604072	2023-08-02 08:26:00.616459	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1979	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:26:00.494464	2023-08-02 08:26:00.494464	2023-08-02 08:26:00.604158	2023-08-02 08:26:00.61681	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2056	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:05:00.974303	2023-08-02 09:05:00.974303	2023-08-02 09:05:01.082146	2023-08-02 09:05:01.093804	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2031	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:52:00.841444	2023-08-02 08:52:00.841444	2023-08-02 08:52:00.955062	2023-08-02 08:52:00.960085	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2057	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:05:00.974303	2023-08-02 09:05:00.974303	2023-08-02 09:05:01.082058	2023-08-02 09:05:01.095501	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2008	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:41:00.686488	2023-08-02 08:41:00.686488	2023-08-02 08:41:00.801038	2023-08-02 08:41:00.803228	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2009	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:41:00.686488	2023-08-02 08:41:00.686488	2023-08-02 08:41:00.801084	2023-08-02 08:41:00.803697	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2062	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:07:00.986267	2023-08-02 09:07:00.986267	2023-08-02 09:07:01.09108	2023-08-02 09:07:01.095676	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2063	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:07:00.986267	2023-08-02 09:07:00.986267	2023-08-02 09:07:01.091219	2023-08-02 09:07:01.096816	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2046	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:00:00.944219	2023-08-02 09:00:00.944219	2023-08-02 09:00:01.050166	2023-08-02 09:00:01.055074	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2010	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:42:00.701386	2023-08-02 08:42:00.701386	2023-08-02 08:42:00.816122	2023-08-02 08:42:00.828526	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2011	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:42:00.701386	2023-08-02 08:42:00.701386	2023-08-02 08:42:00.816026	2023-08-02 08:42:00.828953	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2047	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:00:00.944219	2023-08-02 09:00:00.944219	2023-08-02 09:00:01.050062	2023-08-02 09:00:01.05623	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2074	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:13:00.027248	2023-08-02 09:13:00.027248	2023-08-02 09:13:00.131071	2023-08-02 09:13:00.135371	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2021	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:47:00.772461	2023-08-02 08:47:00.772461	2023-08-02 08:47:00.886011	2023-08-02 08:47:00.888137	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2020	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:47:00.772461	2023-08-02 08:47:00.772461	2023-08-02 08:47:00.886011	2023-08-02 08:47:00.888148	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2075	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:13:00.027248	2023-08-02 09:13:00.027248	2023-08-02 09:13:00.131016	2023-08-02 09:13:00.135779	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2049	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:01:00.950226	2023-08-02 09:01:00.950226	2023-08-02 09:01:01.054207	2023-08-02 09:01:01.057826	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2048	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:01:00.950226	2023-08-02 09:01:00.950226	2023-08-02 09:01:01.054125	2023-08-02 09:01:01.058038	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2058	completed	runs	Lightning.Pipeline	{"attempt_run_id": "2d47fa94-ce22-4c33-8efc-8fd111e2a47b"}	{}	1	1	2023-08-02 09:05:14.890495	2023-08-02 09:05:14.890495	2023-08-02 09:05:14.993024	2023-08-02 09:05:16.396205	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2032	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:53:00.855388	2023-08-02 08:53:00.855388	2023-08-02 08:53:00.969049	2023-08-02 08:53:00.972215	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2033	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:53:00.855388	2023-08-02 08:53:00.855388	2023-08-02 08:53:00.97	2023-08-02 08:53:00.973828	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2012	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:43:00.716495	2023-08-02 08:43:00.716495	2023-08-02 08:43:00.832163	2023-08-02 08:43:00.844202	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2013	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:43:00.716495	2023-08-02 08:43:00.716495	2023-08-02 08:43:00.832074	2023-08-02 08:43:00.844882	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2090	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:21:00.084401	2023-08-02 09:21:00.084401	2023-08-02 09:21:00.191125	2023-08-02 09:21:00.195863	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1980	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:27:00.50353	2023-08-02 08:27:00.50353	2023-08-02 08:27:00.613047	2023-08-02 08:27:00.617218	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1981	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:27:00.50353	2023-08-02 08:27:00.50353	2023-08-02 08:27:00.613133	2023-08-02 08:27:00.617455	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2091	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:21:00.084401	2023-08-02 09:21:00.084401	2023-08-02 09:21:00.191048	2023-08-02 09:21:00.195944	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2076	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:14:00.031363	2023-08-02 09:14:00.031363	2023-08-02 09:14:00.139064	2023-08-02 09:14:00.143335	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2077	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:14:00.031363	2023-08-02 09:14:00.031363	2023-08-02 09:14:00.139064	2023-08-02 09:14:00.143602	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2096	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:24:00.109454	2023-08-02 09:24:00.109454	2023-08-02 09:24:00.223024	2023-08-02 09:24:00.228127	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2097	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:24:00.109454	2023-08-02 09:24:00.109454	2023-08-02 09:24:00.223131	2023-08-02 09:24:00.228377	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1986	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:30:00.544398	2023-08-02 08:30:00.544398	2023-08-02 08:30:00.65828	2023-08-02 08:30:00.670194	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1987	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:30:00.544398	2023-08-02 08:30:00.544398	2023-08-02 08:30:00.658192	2023-08-02 08:30:00.671243	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
813	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "94530f6d-97a2-49ae-9e3f-73315241cb3d"}	{"{\\"at\\": \\"2023-08-01T22:59:01.039596Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.6) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-08-01 22:59:00.050435	2023-08-01 22:59:00.050435	2023-08-01 22:59:00.152036	\N	{lightning@e2458d3c9aef}	2023-08-01 22:59:01.038963	1	{}	{}	\N
2014	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:44:00.732363	2023-08-02 08:44:00.732363	2023-08-02 08:44:00.844068	2023-08-02 08:44:00.848511	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2015	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:44:00.732363	2023-08-02 08:44:00.732363	2023-08-02 08:44:00.844156	2023-08-02 08:44:00.84882	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2100	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:26:00.136433	2023-08-02 09:26:00.136433	2023-08-02 09:26:00.250151	2023-08-02 09:26:00.253308	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2101	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:26:00.136433	2023-08-02 09:26:00.136433	2023-08-02 09:26:00.250042	2023-08-02 09:26:00.254108	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2059	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:06:00.982248	2023-08-02 09:06:00.982248	2023-08-02 09:06:01.086196	2023-08-02 09:06:01.091111	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2092	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:22:00.091374	2023-08-02 09:22:00.091374	2023-08-02 09:22:00.200152	2023-08-02 09:22:00.203411	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2093	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:22:00.091374	2023-08-02 09:22:00.091374	2023-08-02 09:22:00.200222	2023-08-02 09:22:00.20416	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2034	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:54:00.870337	2023-08-02 08:54:00.870337	2023-08-02 08:54:00.98022	2023-08-02 08:54:00.984109	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1982	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:28:00.513484	2023-08-02 08:28:00.513484	2023-08-02 08:28:00.629164	2023-08-02 08:28:00.632682	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1983	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:28:00.513484	2023-08-02 08:28:00.513484	2023-08-02 08:28:00.629063	2023-08-02 08:28:00.633803	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2016	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:45:00.744399	2023-08-02 08:45:00.744399	2023-08-02 08:45:00.85805	2023-08-02 08:45:00.859881	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2017	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:45:00.744399	2023-08-02 08:45:00.744399	2023-08-02 08:45:00.858004	2023-08-02 08:45:00.860324	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2035	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:54:00.870337	2023-08-02 08:54:00.870337	2023-08-02 08:54:00.980106	2023-08-02 08:54:00.985097	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2060	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:06:00.982248	2023-08-02 09:06:00.982248	2023-08-02 09:06:01.086072	2023-08-02 09:06:01.091781	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1988	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:31:00.558517	2023-08-02 08:31:00.558517	2023-08-02 08:31:00.667092	2023-08-02 08:31:00.670723	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1989	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:31:00.558517	2023-08-02 08:31:00.558517	2023-08-02 08:31:00.667168	2023-08-02 08:31:00.671492	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2061	completed	runs	Lightning.Pipeline	{"attempt_run_id": "0c7f267d-1d3a-4951-ad2a-256920f7608e"}	{}	1	1	2023-08-02 09:06:20.393036	2023-08-02 09:06:20.393036	2023-08-02 09:06:20.495029	2023-08-02 09:06:22.266735	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2038	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:56:00.889379	2023-08-02 08:56:00.889379	2023-08-02 08:56:01.003051	2023-08-02 08:56:01.006374	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1990	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:32:00.567425	2023-08-02 08:32:00.567425	2023-08-02 08:32:00.682181	2023-08-02 08:32:00.694104	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2094	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:23:00.099391	2023-08-02 09:23:00.099391	2023-08-02 09:23:00.209152	2023-08-02 09:23:00.213735	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2095	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:23:00.099391	2023-08-02 09:23:00.099391	2023-08-02 09:23:00.209238	2023-08-02 09:23:00.215223	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
1991	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:32:00.567425	2023-08-02 08:32:00.567425	2023-08-02 08:32:00.682058	2023-08-02 08:32:00.695242	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
816	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "55b2f8c5-a4f0-42c7-b907-22d53276a2e8"}	{"{\\"at\\": \\"2023-08-01T22:59:14.348004Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.6) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-08-01 22:59:13.343474	2023-08-01 22:59:13.343474	2023-08-01 22:59:13.444988	\N	{lightning@e2458d3c9aef}	2023-08-01 22:59:14.347269	1	{}	{}	\N
2018	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 08:46:00.758412	2023-08-02 08:46:00.758412	2023-08-02 08:46:00.872087	2023-08-02 08:46:00.875091	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2039	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:56:00.889379	2023-08-02 08:56:00.889379	2023-08-02 08:56:01.003052	2023-08-02 08:56:01.007289	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2019	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 08:46:00.758412	2023-08-02 08:46:00.758412	2023-08-02 08:46:00.872064	2023-08-02 08:46:00.875673	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2069	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:10:00.005338	2023-08-02 09:10:00.005338	2023-08-02 09:10:00.109145	2023-08-02 09:10:00.113001	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2068	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:10:00.005338	2023-08-02 09:10:00.005338	2023-08-02 09:10:00.109053	2023-08-02 09:10:00.113231	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2070	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-08-02 09:11:00.00952	2023-08-02 09:11:00.00952	2023-08-02 09:11:00.11713	2023-08-02 09:11:00.123915	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
2071	completed	background	ObanPruner	{}	{}	1	10	2023-08-02 09:11:00.00952	2023-08-02 09:11:00.00952	2023-08-02 09:11:00.117249	2023-08-02 09:11:00.124649	{lightning@e2458d3c9aef}	\N	1	{}	{}	\N
\.


--
-- Data for Name: oban_peers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oban_peers (name, node, started_at, expires_at) FROM stdin;
Oban	lightning@e2458d3c9aef	2023-08-01 20:38:03.254776	2023-08-02 09:27:19.606228
\.


--
-- Data for Name: project_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_credentials (id, project_id, credential_id, inserted_at, updated_at) FROM stdin;
5cfa5a70-63f1-4b00-8787-04bc2058cade	fb227e5a-764d-4582-a629-6057155a0014	4e23ac68-efd8-4513-84d7-a7019fbd4a0b	2023-08-01 20:41:55	2023-08-01 20:41:55
\.


--
-- Data for Name: project_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_users (id, user_id, project_id, inserted_at, updated_at, role, failure_alert, digest) FROM stdin;
02681a0b-c5f1-49e1-86a5-9246da8a7640	a8cce28e-8904-4970-999b-d9174fd6b92f	fb227e5a-764d-4582-a629-6057155a0014	2023-08-01 20:40:05	2023-08-01 20:40:05	admin	t	weekly
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, name, inserted_at, updated_at, description, scheduled_deletion) FROM stdin;
fb227e5a-764d-4582-a629-6057155a0014	test	2023-08-01 20:40:05	2023-08-01 20:40:05	\N	\N
\.


--
-- Data for Name: runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.runs (id, exit_code, started_at, finished_at, inserted_at, updated_at, job_id, input_dataclip_id, output_dataclip_id, previous_id, credential_id) FROM stdin;
8438d9ef-ff6b-4b24-a52d-fb72b5f5b367	1	2023-08-01 22:28:27.283011	2023-08-01 22:28:28.178062	2023-08-01 22:28:27.17385	2023-08-01 22:28:28.178093	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	5d6c4af0-1007-49ba-af5a-1801378823b4	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
9c79c6fd-8952-41c8-9e0b-6c8f83df2766	1	2023-08-01 21:17:41.589352	2023-08-01 21:17:42.958472	2023-08-01 21:17:41.456764	2023-08-01 21:17:42.958516	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
1b20ade9-8076-4ea6-ba40-7d23f72b5923	1	2023-08-01 22:18:26.839137	2023-08-01 22:18:27.80197	2023-08-01 22:18:26.716616	2023-08-01 22:18:27.802008	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4abc509c-2e01-4440-a6b7-6388da8df48a	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
c9e20139-a5d5-4706-aaa4-1eb0941549dd	1	2023-08-01 21:18:09.658857	2023-08-01 21:18:10.96695	2023-08-01 21:18:09.538741	2023-08-01 21:18:10.966992	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
92fdb4c7-15d5-47de-aad7-3f8e1f491fac	1	2023-08-01 21:21:53.875954	2023-08-01 21:21:55.205931	2023-08-01 21:21:53.755883	2023-08-01 21:21:55.205965	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
75abaf93-551b-44b3-beb9-b01b7c3cb6b1	1	2023-08-01 21:27:45.292998	2023-08-01 21:27:46.656623	2023-08-01 21:27:45.170453	2023-08-01 21:27:46.656667	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
e150fe08-f701-4118-b1d7-59e50e9897a4	1	2023-08-01 22:18:29.046801	2023-08-01 22:18:29.992332	2023-08-01 22:18:28.928281	2023-08-01 22:18:29.992372	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4abc509c-2e01-4440-a6b7-6388da8df48a	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
20e1fbeb-a42e-48e9-9d1d-f09220cace34	1	2023-08-01 21:30:22.243167	2023-08-01 21:30:23.615328	2023-08-01 21:30:22.108017	2023-08-01 21:30:23.615361	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
2403a821-ec4f-42b9-b35e-12fe0ccff67b	\N	2023-08-01 22:40:26.919524	2023-08-01 22:40:27.843409	2023-08-01 22:40:26.788027	2023-08-01 22:40:27.843467	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	3e279c6f-d72a-4c6e-8923-b9ce84be64bc	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
6c732f1d-9591-4074-bd3a-e8c529a43a22	0	2023-08-01 21:31:32.920924	2023-08-01 21:31:35.75653	2023-08-01 21:31:32.79759	2023-08-01 21:31:35.759421	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	27ab613a-b62f-4aa2-9bc4-607ef7d21f30	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
0a2695aa-d3a2-46e7-94c6-57945786accb	1	2023-08-01 22:30:44.538159	2023-08-01 22:30:45.404379	2023-08-01 22:30:44.422933	2023-08-01 22:30:45.404421	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	843c291d-271d-445a-8adf-0580d359d18a	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
87e74ebd-ef35-45aa-9832-381bb2285ebf	1	2023-08-01 21:33:12.695303	2023-08-01 21:33:16.40742	2023-08-01 21:33:12.561717	2023-08-01 21:33:16.407453	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
6afbaf69-4166-45c5-ba5e-df8531ad44ff	0	2023-08-01 22:19:56.013624	2023-08-01 22:19:56.95158	2023-08-01 22:19:55.894278	2023-08-01 22:19:56.953839	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4abc509c-2e01-4440-a6b7-6388da8df48a	e4dc5662-8b7e-42bd-ac7f-4ca4480ad7ec	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
741ea16f-bc86-4e86-959f-8c8e88ab05d4	1	2023-08-01 21:35:33.497776	2023-08-01 21:35:35.915317	2023-08-01 21:35:33.379892	2023-08-01 21:35:35.915353	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
3d80923e-fc7a-451d-9826-15c62375ec2f	1	2023-08-01 21:38:19.815133	2023-08-01 21:38:22.666606	2023-08-01 21:38:19.69072	2023-08-01 21:38:22.666698	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
4e01840f-49ad-4b6b-b459-aeb0d8e8dab9	1	2023-08-01 22:20:33.181451	2023-08-01 22:20:34.089097	2023-08-01 22:20:33.057042	2023-08-01 22:20:34.089133	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
80bdd289-ff67-4d70-8c22-d968cf241201	0	2023-08-01 21:44:18.509901	2023-08-01 21:44:19.865923	2023-08-01 21:44:18.385505	2023-08-01 21:44:19.868775	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	7ebdc2be-af47-4f55-9c14-2c145e43c055	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
74bebfb0-9228-4bd8-a3e3-cc7f26382201	0	2023-08-01 22:00:24.331913	2023-08-01 22:00:25.679575	2023-08-01 22:00:24.214086	2023-08-01 22:00:25.682035	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	3e2f2452-aef9-4cd9-85b3-b131ad66c2c5	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
adbbda6f-3bc1-4b7a-b613-9085c00184a5	1	2023-08-01 22:22:06.690523	2023-08-01 22:22:07.578763	2023-08-01 22:22:06.566837	2023-08-01 22:22:07.578809	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
326d7022-b38d-4306-86b7-6a2a45335c66	0	2023-08-01 22:03:05.660142	2023-08-01 22:03:06.977254	2023-08-01 22:03:05.541326	2023-08-01 22:03:06.979769	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	ce9a7c8c-ab0a-4fd0-adfb-eec5bca523f7	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
d3425662-8dc5-4a41-9cf8-c0255e3ea903	0	2023-08-01 22:49:20.435044	2023-08-01 22:49:21.341496	2023-08-01 22:49:20.318278	2023-08-01 22:49:21.343909	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	698ece00-4dd7-4913-9efa-730ed8577b66	5f983282-b9ee-4303-96d0-c77e807305ad	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
3fd4d22b-a7f5-40c5-b774-9e20fd96f57a	\N	2023-08-01 22:23:42.070361	2023-08-01 22:23:42.982371	2023-08-01 22:23:41.953711	2023-08-01 22:23:42.982414	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	c4f6d370-efdc-4ccd-b364-8f5b5a10fb82	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
f5f06cb9-f228-4df9-acf2-bfd2b7d8cea5	0	2023-08-01 22:07:51.739193	2023-08-01 22:07:53.117094	2023-08-01 22:07:51.620423	2023-08-01 22:07:53.120573	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d92b7eb-bd1a-4b1b-896d-3249ca938ab3	862e85fd-2be5-460c-8910-81606d084827	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
e3371a8e-91e4-4ba4-8e78-6aa82b63ce4a	1	2023-08-01 22:13:01.265951	2023-08-01 22:13:02.176176	2023-08-01 22:13:01.148459	2023-08-01 22:13:02.176209	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
9279935c-5d1d-4522-8170-780cd005ff9f	0	2023-08-01 22:33:47.255701	2023-08-01 22:33:48.140133	2023-08-01 22:33:47.140355	2023-08-01 22:33:48.142635	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	cdc11b6b-b4b0-40ac-9bb8-eb946b7b62d9	84f70e6d-45de-4f46-a8d6-74211be91e6f	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
eb443fb5-d089-48ef-8bc6-f2a8485542e4	1	2023-08-01 22:14:27.09736	2023-08-01 22:14:27.974584	2023-08-01 22:14:26.972045	2023-08-01 22:14:27.974622	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
d421e41a-ed0f-4241-9f59-4bd50590917a	1	2023-08-01 22:15:54.830886	2023-08-01 22:15:55.75333	2023-08-01 22:15:54.714217	2023-08-01 22:15:55.753364	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
b3655c91-56bb-443d-92c2-291c7026708c	0	2023-08-01 22:24:17.625049	2023-08-01 22:24:18.521436	2023-08-01 22:24:17.51461	2023-08-01 22:24:18.524109	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	bb538e5c-be1a-41f9-a87c-bda731a547d2	8d21532e-5dbd-4be7-8a3e-c339746a35de	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
dcb47cea-9525-4834-890c-b9dec6b1e1d3	1	2023-08-01 22:16:31.466514	2023-08-01 22:16:32.393063	2023-08-01 22:16:31.346406	2023-08-01 22:16:32.393101	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4cd38bba-2d11-4c88-bd6f-7e0abe2e7ce3	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
6d510da7-0fe2-4438-8430-0b5cddbc30ed	1	2023-08-01 22:17:50.595078	2023-08-01 22:17:51.499635	2023-08-01 22:17:50.477392	2023-08-01 22:17:51.499671	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4abc509c-2e01-4440-a6b7-6388da8df48a	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
65425974-461f-4e92-be1b-4501f22c3d4b	1	2023-08-01 22:25:27.480731	2023-08-01 22:25:28.389326	2023-08-01 22:25:27.368132	2023-08-01 22:25:28.38936	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	ecfce58d-b526-4f7b-91d9-2de188c4522c	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
3cd86d96-2098-4dcb-ae71-35fc242001fa	0	2023-08-01 22:42:00.650041	2023-08-01 22:42:01.520309	2023-08-01 22:42:00.527476	2023-08-01 22:42:01.52247	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	11a03b36-9539-4ea3-a0c7-2a9a472ba6d7	de98ba98-e104-4ffa-bee3-c23f9518ffd6	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
c633ab0e-2f64-475e-982e-f4ff2bb90239	1	2023-08-01 22:26:28.329561	2023-08-01 22:26:29.243874	2023-08-01 22:26:28.214929	2023-08-01 22:26:29.243908	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	0819bf03-afcb-4639-98ad-748f5a7eff21	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
1dc183df-6429-4fdf-8eaa-767f9edaba58	0	2023-08-01 22:36:18.418502	2023-08-01 22:36:19.320677	2023-08-01 22:36:18.303311	2023-08-01 22:36:19.323095	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	59a62b34-8af3-48ef-94ac-ba3e9fa20b77	9ca7e14b-325a-42ca-951e-063ded745af5	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
6deedf2a-3d15-4f6e-ab67-c96eacd3f4a0	1	2023-08-01 22:27:12.465178	2023-08-01 22:27:13.37446	2023-08-01 22:27:12.34737	2023-08-01 22:27:13.374492	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	a148ea39-1aea-40f9-851a-ce3aa8c5dad8	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
aca8d8c0-cd31-4fb3-8814-a23545009e69	0	2023-08-01 22:27:39.486071	2023-08-01 22:27:40.390369	2023-08-01 22:27:39.372315	2023-08-01 22:27:40.392595	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	e8354c82-2ea6-4482-a636-11c3328f134c	51e1f910-1c3d-44d6-849f-dd7b10545312	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
a6ec600a-a29d-4b86-b9c5-471d1f5c629e	1	2023-08-01 22:43:21.760864	2023-08-01 22:43:22.681351	2023-08-01 22:43:21.648808	2023-08-01 22:43:22.681384	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	f1a60b31-cde7-4138-b8f3-d0ad31f12199	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
d037a10f-f4a2-47d4-ac45-d64ed6502c0d	0	2023-08-01 22:38:57.093886	2023-08-01 22:38:58.010295	2023-08-01 22:38:56.977793	2023-08-01 22:38:58.012696	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	476975a8-0e3c-4446-8084-eeaa055ac7d2	ef3b8748-7427-4868-89ab-d371c576a3c5	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
a10ae53b-cc8a-42ed-8ea1-c7db0fc08440	1	2023-08-01 22:39:26.591715	2023-08-01 22:39:27.510273	2023-08-01 22:39:26.476468	2023-08-01 22:39:27.510312	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	e8a2f33e-9a45-4258-8b20-350bcdab4a2e	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
dc5c1447-c8e8-4122-9fa4-094ee70a4e45	\N	2023-08-01 22:40:03.519669	2023-08-01 22:40:04.397922	2023-08-01 22:40:03.404505	2023-08-01 22:40:04.397976	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	3e279c6f-d72a-4c6e-8923-b9ce84be64bc	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
fce3d6b9-f39d-454f-a529-411d6ca18e98	0	2023-08-01 22:50:17.271807	2023-08-01 22:50:18.213321	2023-08-01 22:50:17.148644	2023-08-01 22:50:18.215474	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	698ece00-4dd7-4913-9efa-730ed8577b66	f01688b5-481e-449c-9726-bf6447f8be7a	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
bab0c7b6-2142-439f-ba83-1fd3f0dfd615	0	2023-08-01 22:44:42.310006	2023-08-01 22:44:43.269099	2023-08-01 22:44:42.195213	2023-08-01 22:44:43.271485	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	698ece00-4dd7-4913-9efa-730ed8577b66	f9f8b187-ab9f-4f9f-b110-8cb1b940bd3f	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
0fd6b266-fe52-4660-a6a6-16363b9e47e4	0	2023-08-01 22:51:59.698852	2023-08-01 22:52:00.608432	2023-08-01 22:51:59.576236	2023-08-01 22:52:00.61058	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	698ece00-4dd7-4913-9efa-730ed8577b66	27183a08-d913-4aef-864a-1e695cbe36a1	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
e6f27751-a345-448c-aa3d-66410f4207ca	0	2023-08-01 22:57:35.070344	2023-08-01 22:57:35.979669	2023-08-01 22:57:34.962127	2023-08-01 22:57:35.982021	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	d30450c1-4fcd-4692-bc3b-dc1fa2b120de	d95be9a4-911c-474c-ae3b-d6cd1c247111	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
3a4f617e-ccb0-48fc-b3cf-9b52a9f2e522	0	2023-08-01 22:51:33.244428	2023-08-01 22:51:34.156103	2023-08-01 22:51:33.119469	2023-08-01 22:51:34.158491	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	698ece00-4dd7-4913-9efa-730ed8577b66	d01973e8-eca3-4f6b-98fa-81626e8427c9	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
cd732cb6-ce1d-44e6-aa66-7c13cb550ce4	0	2023-08-01 22:54:48.0298	2023-08-01 22:54:48.948688	2023-08-01 22:54:47.913225	2023-08-01 22:54:48.95103	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	698ece00-4dd7-4913-9efa-730ed8577b66	bd48d573-f94f-46de-bce6-6599459bccf4	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
8cee7e50-7229-404c-8b5f-bc40bcc6229c	0	2023-08-01 22:54:26.412673	2023-08-01 22:54:27.339682	2023-08-01 22:54:26.288546	2023-08-01 22:54:27.342306	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	698ece00-4dd7-4913-9efa-730ed8577b66	8f2321c2-76f7-4290-a436-16731b2e305d	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
0c87d039-ea99-44ec-bf48-300aa05dddc4	0	2023-08-01 22:55:36.399958	2023-08-01 22:55:37.327497	2023-08-01 22:55:36.285191	2023-08-01 22:55:37.329859	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	698ece00-4dd7-4913-9efa-730ed8577b66	7ed7fb32-85ab-46f0-8847-525f1764ef21	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
a6c886fa-4630-420c-9814-bed97ee41d81	0	2023-08-01 22:58:27.532378	2023-08-01 22:58:28.426262	2023-08-01 22:58:27.417964	2023-08-01 22:58:28.428713	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	7136cbb7-a575-4c88-9b86-616fdf6436bb	923c709c-f517-482b-82bf-c75a1a23b747	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
34e132ec-6e3c-40e0-9934-2078ae42e8ce	\N	2023-08-01 22:59:00.158274	2023-08-01 22:59:01.041497	2023-08-01 22:59:00.049333	2023-08-01 22:59:01.041535	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4def2367-5223-45a2-a3f3-c657fa71a359	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
40145192-71bd-4a8e-9ebb-c6d3bf665be7	\N	2023-08-01 22:59:13.455251	2023-08-01 22:59:14.349723	2023-08-01 22:59:13.342304	2023-08-01 22:59:14.349774	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	043971d1-a7ac-4057-a473-14563f171273	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
0cddaf4c-909d-4fda-b0e0-d85c0edb67dc	0	2023-08-01 22:59:53.974289	2023-08-01 22:59:54.866027	2023-08-01 22:59:53.858557	2023-08-01 22:59:54.868526	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	85c39700-0f2f-43c2-b6bd-b52523fcecd8	8170d795-be98-4dd2-a445-c66ef64e8e7b	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
3ca52d84-2b6e-4cec-97a8-b1690a38d262	0	2023-08-01 23:00:51.823106	2023-08-01 23:00:52.6888	2023-08-01 23:00:51.707608	2023-08-01 23:00:52.691894	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	f1c24be5-f00c-497a-b242-091fcbe12049	5ffdad4f-4f66-4cf8-839b-de7a46a5285a	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
d3da036e-ab99-4bef-b80c-39460c771c94	0	2023-08-01 23:02:08.49707	2023-08-01 23:02:09.40753	2023-08-01 23:02:08.37635	2023-08-01 23:02:09.410169	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4d95c6cd-4797-439e-9716-557856b70a4a	8c1e17cb-f5f0-4ca6-9818-6ee3f22072b0	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
a60795f1-a685-4c29-b23f-e36802128ec6	0	2023-08-02 06:47:06.811986	2023-08-02 06:47:07.712356	2023-08-02 06:47:06.698845	2023-08-02 06:47:07.714769	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	de87096f-debb-4ba5-84f8-bdcdbc12724f	639cec8a-c7e6-4afd-95fc-f3a51bb0f97f	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
b45206da-3b44-4879-a51a-9a560b308189	0	2023-08-01 23:06:28.313271	2023-08-01 23:06:29.214027	2023-08-01 23:06:28.194604	2023-08-01 23:06:29.216077	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	fb70d5ae-77d4-4fa5-bd4e-2ea3528b2f9d	a7705bf6-5eee-49a9-85a9-34b449720382	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
3c473faa-1ea2-4d59-91fe-2815703dd70d	0	2023-08-01 23:02:54.581227	2023-08-01 23:02:55.492017	2023-08-01 23:02:54.470739	2023-08-01 23:02:55.494739	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	a567da76-e110-44d0-a849-55066596a754	ca76ea73-074e-444f-9407-b0659a06a2de	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
a1fcb414-837e-46d2-b5e9-6deb72c6ea13	0	2023-08-01 23:03:54.166875	2023-08-01 23:03:55.069711	2023-08-01 23:03:54.056615	2023-08-01 23:03:55.072184	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	04823219-22fc-42bb-9bbf-69f495a919f4	38a32afc-8809-444c-818e-d4c90b5a5459	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
09475541-2e1c-4267-857c-1bbc07b1b413	0	2023-08-02 06:48:14.58446	2023-08-02 06:48:15.983957	2023-08-02 06:48:14.471537	2023-08-02 06:48:15.986789	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	96fc7782-9ef7-44a5-b0de-691bf9fb4933	f93aaf6e-62b6-4d6b-adce-e73493bae384	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
66494af5-3763-42ba-add1-88e1a8a5fd98	0	2023-08-01 23:04:46.619551	2023-08-01 23:04:47.488258	2023-08-01 23:04:46.510455	2023-08-01 23:04:47.490769	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	3739f5ea-8bee-4e7f-a394-d6954c9d730a	02fa2778-e583-40c6-aee7-dfd911529756	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
5bddade5-de14-457c-8257-b1c3384bcf40	1	2023-08-01 23:05:26.034649	2023-08-01 23:05:26.939707	2023-08-01 23:05:25.923944	2023-08-01 23:05:26.939739	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	87fd1c00-ef4b-4800-a076-02115d4d197a	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
8c4a37c3-5eb2-487e-ba7b-6c252d97c02b	0	2023-08-02 09:06:20.504045	2023-08-02 09:06:22.261099	2023-08-02 09:06:20.391523	2023-08-02 09:06:22.26441	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	71c50553-968b-4201-8d1a-913d344b0d4e	8bdbaa41-395f-4699-b523-f46ccf7928e6	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
e9bc32df-9acf-4108-b922-8e3d9c85be23	0	2023-08-01 23:05:56.702998	2023-08-01 23:05:57.613107	2023-08-01 23:05:56.589606	2023-08-01 23:05:57.615431	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	bc9abc10-7b45-4bc8-bb4b-ceef599275a1	cb467169-0ff9-4d04-8d85-8d575bd81e48	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
6c2a6868-3376-4819-8f8c-808774ff53d5	1	2023-08-01 23:15:06.956963	2023-08-01 23:15:07.873717	2023-08-01 23:15:06.84551	2023-08-01 23:15:07.873751	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	13c03072-5132-4102-946a-978d1c8bc39c	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
b5e60653-ce7a-4a4f-9fc3-2496cb1536e7	0	2023-08-01 23:07:28.627745	2023-08-01 23:07:29.544298	2023-08-01 23:07:28.512822	2023-08-01 23:07:29.546552	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	4c76b298-6b17-42f6-9a57-3707e47630df	bbbe96a1-9679-4abf-91e9-45ad210c7afa	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
294c65f6-d174-4df1-8e69-f57230af0e11	1	2023-08-01 23:15:43.287384	2023-08-01 23:15:44.198352	2023-08-01 23:15:43.171144	2023-08-01 23:15:44.198388	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	8add2b90-244f-4b7b-bd52-9989bf4a170b	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
22b35b22-fd53-4bd8-9b33-d8671033fef8	1	2023-08-02 09:05:15.000247	2023-08-02 09:05:16.38721	2023-08-02 09:05:14.888396	2023-08-02 09:05:16.387275	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	bf9a387c-af0f-4527-bdc0-b94c462c15af	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
c9202151-effb-4ceb-92f4-a5f57c663dad	0	2023-08-01 23:16:18.752595	2023-08-01 23:16:19.664367	2023-08-01 23:16:18.636972	2023-08-01 23:16:19.666742	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	ff93db11-5928-42e4-ba42-47e1b2edde61	78db8db2-b0e1-4b58-8125-eddd7e644a91	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
42a29fb1-aaba-4858-b68e-ce1ff9050af3	0	2023-08-01 23:17:08.254943	2023-08-01 23:17:09.15256	2023-08-01 23:17:08.138699	2023-08-01 23:17:09.154814	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	ab8e10f2-c5de-4fd8-abcb-39fcd2dd16e8	685b5bc4-489b-421c-976d-702c56a7f673	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
652ad855-0391-46d9-9673-e645cad6c859	0	2023-08-01 23:17:50.332423	2023-08-01 23:17:51.222343	2023-08-01 23:17:50.214413	2023-08-01 23:17:51.225212	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	e8b06c80-2a7b-4a4b-9b92-a94f46b67a1a	45cb25d3-b63b-46e1-bb29-6d9baeae1079	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
64dfe032-cbf0-4790-b296-1f42991e9ed9	0	2023-08-01 23:19:31.283898	2023-08-01 23:19:32.633944	2023-08-01 23:19:31.16873	2023-08-01 23:19:32.637144	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	5fe0f833-07a8-4ad2-a350-a0a9727ce3f3	1c3b5ecc-2cdd-44a6-8c23-84bf91eed76c	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
349424dd-e236-43b4-9975-ba948d79b1a0	0	2023-08-02 04:22:38.349211	2023-08-02 04:22:39.807856	2023-08-02 04:22:38.238327	2023-08-02 04:22:39.811074	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	436b9eda-41c4-4211-b676-7d7ffc8f76bf	13f8be10-2e5d-4ccf-98bb-d04137c43f4a	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
658e1cc5-e02c-41dc-bd5d-1204d71e3c17	0	2023-08-02 05:46:32.05192	2023-08-02 05:46:33.453528	2023-08-02 05:46:31.944167	2023-08-02 05:46:33.456141	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	2fa31bb2-daa8-408c-95bb-b60683665e9b	5f130dcf-933a-447d-bcc8-a2488c3914f2	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
8546eaea-a47d-49da-ab40-e031598df335	\N	2023-08-02 06:36:45.381574	2023-08-02 06:36:46.538588	2023-08-02 06:36:45.271214	2023-08-02 06:36:46.538644	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	78ed56af-f42f-449a-8cee-43d49d4a92b1	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
69ffadf0-ec20-404c-8ecf-2509be615806	1	2023-08-02 06:38:48.301554	2023-08-02 06:38:49.44782	2023-08-02 06:38:48.188564	2023-08-02 06:38:49.447854	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	91648b5f-386d-4b60-8c7d-c1805f35174b	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
3de46714-2122-4b29-a4da-00d416093d3a	1	2023-08-02 06:40:09.826945	2023-08-02 06:40:10.74507	2023-08-02 06:40:09.711865	2023-08-02 06:40:10.745114	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	3cc5c1a8-a539-430b-898c-4e74d71d0092	\N	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
60641858-bd17-4bd0-b837-3432475a12ea	0	2023-08-02 06:41:03.813348	2023-08-02 06:41:04.748599	2023-08-02 06:41:03.701126	2023-08-02 06:41:04.750964	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	c14155d9-2938-4ca3-804e-381cd4bb3769	7a62536d-3f57-4adf-95cf-3991cc48f314	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
1f0c094b-5b20-4541-9985-b57f8e92e4d4	0	2023-08-02 06:43:01.789185	2023-08-02 06:43:02.728956	2023-08-02 06:43:01.679285	2023-08-02 06:43:02.732922	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	7fe4b289-5f08-4c2f-a8f8-44c05d13c9fd	a83bb57b-b80b-4ef5-aba4-6e8a2969319a	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
e63ee8de-27f2-4b3d-9d7e-ca0f77101c51	0	2023-08-02 06:44:37.812701	2023-08-02 06:44:38.743013	2023-08-02 06:44:37.699869	2023-08-02 06:44:38.74523	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	1f7b0c5d-f066-421f-8555-c3b216785fcf	4dda2b11-3e4e-4a46-ac0c-7b3f6ab72c7f	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
7f2f5d57-f36c-48f9-a8b1-a793be4bf25e	0	2023-08-02 06:45:35.309297	2023-08-02 06:45:36.204704	2023-08-02 06:45:35.198785	2023-08-02 06:45:36.20706	e436c7e5-46c1-4b4b-8bb8-33ed481c877f	30f6c716-0aaf-4c2d-a99d-54d894eacdc2	2675d97a-3205-44f0-9e80-9de89608a243	\N	4e23ac68-efd8-4513-84d7-a7019fbd4a0b
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
49987767-ea8e-4b15-b5ec-11f97ac383a0	\N	\N	2023-08-01 20:42:15	2023-08-01 20:42:15	\N	webhook	\N	6f293a43-3f2b-46ef-ac47-8b7e67144172
653c9553-1d5c-4095-b8ef-684868e24a0a	\N	\N	2023-08-01 22:47:01	2023-08-01 22:47:01	\N	webhook	\N	28833745-532e-40df-99f8-ec59169f67b6
\.


--
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tokens (id, user_id, token, context, sent_to, inserted_at, last_used_at) FROM stdin;
30bad055-0a97-4e86-9f9c-9ba352224025	a8cce28e-8904-4970-999b-d9174fd6b92f	\\xf4bd2f2ebea212b429ffd86f2d5a0d2e85220d66b0b638de4c66ee39da04c73a	session	\N	2023-08-01 20:39:42	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, first_name, last_name, email, hashed_password, confirmed_at, inserted_at, updated_at, role, disabled, scheduled_deletion) FROM stdin;
a8cce28e-8904-4970-999b-d9174fd6b92f	Mahao	Molise	test@mail.com	$2b$12$kM4Tnf7.wb9pF1pXVCVb3uE/zaiXJWcZQwlz84sjmRwgfHILSHiVa	\N	2023-08-01 20:39:42	2023-08-01 20:39:42	superuser	f	\N
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_orders (id, workflow_id, reason_id, inserted_at, updated_at) FROM stdin;
519920fd-67ef-45f6-b656-49e37a3889bf	6f293a43-3f2b-46ef-ac47-8b7e67144172	4a7fe400-14cb-4f67-b033-b33c09fb346c	2023-08-01 21:17:41	2023-08-01 21:17:41
df0c2170-0640-4bda-bb8e-2edb15d9a09c	6f293a43-3f2b-46ef-ac47-8b7e67144172	16b6517f-d66a-47b4-8bf3-acbaa9c76207	2023-08-01 21:21:54	2023-08-01 21:21:54
17513413-efc5-4d8d-be4c-7dde4a88f000	6f293a43-3f2b-46ef-ac47-8b7e67144172	2ef59eda-a0a4-4fd5-9350-94fb81baa32e	2023-08-01 21:30:22	2023-08-01 21:30:22
49321e50-5938-48d5-be52-ad7197b16541	6f293a43-3f2b-46ef-ac47-8b7e67144172	2291c86c-6259-48b8-b412-fb435028e73a	2023-08-01 21:31:33	2023-08-01 21:31:33
0393404d-9f80-4df7-80c3-0950bda14ca2	6f293a43-3f2b-46ef-ac47-8b7e67144172	8f449152-b7a1-40a6-9c52-35b2f1d938b4	2023-08-01 21:33:13	2023-08-01 21:33:13
97ba4eb4-b60d-46a1-b0a6-a01e723f19b3	6f293a43-3f2b-46ef-ac47-8b7e67144172	f7cad00c-a5f8-425a-b2ea-57b80ce9c09a	2023-08-01 21:35:33	2023-08-01 21:35:33
529ef426-5914-4ed0-9205-bfe3cc6c9f63	6f293a43-3f2b-46ef-ac47-8b7e67144172	73db5a6b-47bc-4a47-a9bb-d8ffcbd89234	2023-08-01 21:38:20	2023-08-01 21:38:20
91ee6b79-a170-4dec-8df2-dc1bf1f95768	6f293a43-3f2b-46ef-ac47-8b7e67144172	6b780db6-3896-4c09-88ad-dcb9f0a2669e	2023-08-01 21:44:18	2023-08-01 21:44:18
8d836362-c55e-4698-9f96-07ec25e76c3c	6f293a43-3f2b-46ef-ac47-8b7e67144172	47d8f301-306e-4034-bbd2-f67e3f2e1d3c	2023-08-01 22:00:24	2023-08-01 22:00:24
e8af3b94-11aa-486d-8513-be8a0c56ed58	6f293a43-3f2b-46ef-ac47-8b7e67144172	7e5a7b1d-9e93-44c8-89a3-11e11ccc2676	2023-08-01 22:03:06	2023-08-01 22:03:06
5c3c2207-150a-454c-818a-dc938149dbf4	6f293a43-3f2b-46ef-ac47-8b7e67144172	ce114942-0b8c-42a8-9997-a4aad0ed29eb	2023-08-01 22:07:52	2023-08-01 22:07:52
acd9305e-e725-4d75-a5f6-1889d357ce98	6f293a43-3f2b-46ef-ac47-8b7e67144172	8a7787e6-66ca-4161-9ae2-8d7cd21403a8	2023-08-01 22:13:01	2023-08-01 22:13:01
ec3568c1-1381-4fe3-a7f3-6871b6b6230c	6f293a43-3f2b-46ef-ac47-8b7e67144172	3ed5c31b-8c5f-41d4-a160-6379f28235c6	2023-08-01 22:14:27	2023-08-01 22:14:27
790a9309-f636-410c-b108-9ef908bbf9e9	6f293a43-3f2b-46ef-ac47-8b7e67144172	619771c2-9d7f-46cd-bc90-e7a68cc449f3	2023-08-01 22:15:55	2023-08-01 22:15:55
cfea3827-7ba2-4489-8b28-7b314f40b6df	6f293a43-3f2b-46ef-ac47-8b7e67144172	50d56bd3-53cf-4a01-a2a4-fb19a0de5ed7	2023-08-01 22:16:31	2023-08-01 22:16:31
17211470-67cc-4954-ace5-d2537cc5e67b	6f293a43-3f2b-46ef-ac47-8b7e67144172	b4f73299-1d34-4888-8e6b-75c2ccaaf673	2023-08-01 22:17:50	2023-08-01 22:17:50
eebf05d3-d4ea-4f11-bea7-69014b567db2	6f293a43-3f2b-46ef-ac47-8b7e67144172	416b3ff8-3932-406e-83af-b442611e4bc7	2023-08-01 22:23:42	2023-08-01 22:23:42
45b9fd37-b759-43ac-9213-5dba1065db9b	6f293a43-3f2b-46ef-ac47-8b7e67144172	580c5b7f-75c3-428f-933b-b78bd136d002	2023-08-01 22:24:18	2023-08-01 22:24:18
5f0ef69e-c8bf-4e54-a511-172d8a3b43fd	6f293a43-3f2b-46ef-ac47-8b7e67144172	e66cfd15-92a9-4a7b-962f-02d823f9728d	2023-08-01 22:25:27	2023-08-01 22:25:27
6089918b-1069-4847-8ac4-05a293a35c4b	6f293a43-3f2b-46ef-ac47-8b7e67144172	d5d93784-b8d8-477d-bd47-0bd48816f6b6	2023-08-01 22:26:28	2023-08-01 22:26:28
0e184114-b97b-488d-8e8e-130981e5686a	6f293a43-3f2b-46ef-ac47-8b7e67144172	6ffad9e8-9a42-4fe6-b664-fc6cee6bc8b0	2023-08-01 22:27:12	2023-08-01 22:27:12
95f70e1c-33fb-4a5d-9e79-40d737bfccc5	6f293a43-3f2b-46ef-ac47-8b7e67144172	a2cd7244-eddd-4201-ad96-6aa3f834a6b1	2023-08-01 22:27:39	2023-08-01 22:27:39
cfae280b-aaac-4340-b842-8a718aae2149	6f293a43-3f2b-46ef-ac47-8b7e67144172	9af4eda2-7916-4329-b5b5-3481ae8064ce	2023-08-01 22:28:27	2023-08-01 22:28:27
53e590f5-21b6-42f1-8d8a-b97d759824a6	6f293a43-3f2b-46ef-ac47-8b7e67144172	b21bfb2c-f037-41ef-b29d-9f43f203aad5	2023-08-01 22:30:44	2023-08-01 22:30:44
196639a2-2974-4424-977a-7b57eb4b411a	6f293a43-3f2b-46ef-ac47-8b7e67144172	d788da6b-aa5f-4947-bdb6-df81852cd276	2023-08-01 22:33:47	2023-08-01 22:33:47
ef3316a4-4aa5-4c0a-afe1-2cdc180e8005	6f293a43-3f2b-46ef-ac47-8b7e67144172	75d53acb-ff68-4ae5-b58b-51d75f574b61	2023-08-01 22:36:18	2023-08-01 22:36:18
5bdf9bf8-d000-4589-8a72-b2b3d9393e43	6f293a43-3f2b-46ef-ac47-8b7e67144172	cbdcc611-03a8-4df5-847f-79b1d66ba613	2023-08-01 22:38:57	2023-08-01 22:38:57
9db77487-be65-4c32-96ef-9965bd57ce5d	6f293a43-3f2b-46ef-ac47-8b7e67144172	18c384f3-6680-4bf5-bc18-d005f94f08fd	2023-08-01 22:39:26	2023-08-01 22:39:26
29863566-a821-41d0-b5fd-a42a6d5a0a08	6f293a43-3f2b-46ef-ac47-8b7e67144172	454577ff-661a-461e-9ad5-3c63397661fc	2023-08-01 22:40:03	2023-08-01 22:40:03
1c748d14-4143-4e86-a9a2-9736b3d9c09d	6f293a43-3f2b-46ef-ac47-8b7e67144172	ea0ca7f5-35f7-4a24-a95a-7ba67b75e107	2023-08-01 22:42:01	2023-08-01 22:42:01
8fdd2596-98a3-4438-8d0a-894000bdb3a5	6f293a43-3f2b-46ef-ac47-8b7e67144172	706af2b8-5a8d-46cd-ba2a-5a013566bb86	2023-08-01 22:43:22	2023-08-01 22:43:22
315fb81f-baa1-433e-a153-1c60fcb25289	6f293a43-3f2b-46ef-ac47-8b7e67144172	b326ebb2-8d29-4f76-8c2d-5b78d5be5181	2023-08-01 22:44:42	2023-08-01 22:44:42
f3b5d856-ef89-4d61-bca9-c0b371669f9d	6f293a43-3f2b-46ef-ac47-8b7e67144172	490ac1d1-eb8c-46df-8c50-36d0e9656954	2023-08-01 22:49:20	2023-08-01 22:49:20
a663b782-43d5-4462-96e2-236be1e06a9c	6f293a43-3f2b-46ef-ac47-8b7e67144172	f768e325-6f8b-4b04-a838-438f8c76dc3c	2023-08-01 22:50:17	2023-08-01 22:50:17
00b6391a-3d3d-4158-a667-f61b41b90770	6f293a43-3f2b-46ef-ac47-8b7e67144172	32808be8-a53c-4c92-b8a2-f880821d1f3f	2023-08-01 22:51:33	2023-08-01 22:51:33
52be5d8f-4ce0-4558-b4c5-4e39edbc56a8	6f293a43-3f2b-46ef-ac47-8b7e67144172	25b17c0a-8bd1-4705-9158-41f9a102ee6d	2023-08-01 22:52:00	2023-08-01 22:52:00
003d5f12-8707-4786-a3af-8509c6081bd3	6f293a43-3f2b-46ef-ac47-8b7e67144172	623d9b0a-458c-4d87-a615-ab41f9050e69	2023-08-01 22:57:35	2023-08-01 22:57:35
2f4782c1-1f7b-4891-9a14-be8f7366115b	6f293a43-3f2b-46ef-ac47-8b7e67144172	c11eda9e-343e-4857-b040-6331b2899e7f	2023-08-01 22:58:27	2023-08-01 22:58:27
a613f440-a221-48a5-bf7b-05eae3202f29	6f293a43-3f2b-46ef-ac47-8b7e67144172	bee2d4bb-27d4-4c7e-b6d5-92685092cdc2	2023-08-01 22:59:00	2023-08-01 22:59:00
7c2ca994-78cd-42a6-86fa-8189337615e0	6f293a43-3f2b-46ef-ac47-8b7e67144172	047f96c6-cda2-43bb-bbf4-9c63bc5d5cb1	2023-08-01 22:59:13	2023-08-01 22:59:13
ba2f0d03-a8f6-49ea-a76f-9c8387317e73	6f293a43-3f2b-46ef-ac47-8b7e67144172	54e4e31e-e679-4c11-b677-27549deda644	2023-08-01 22:59:54	2023-08-01 22:59:54
bf6bba42-9011-4c73-a5e7-9f0f1ea4c445	6f293a43-3f2b-46ef-ac47-8b7e67144172	7b08f6ec-adaf-4ff9-8152-2467620600a6	2023-08-01 23:00:52	2023-08-01 23:00:52
56dd154d-75dd-42b5-a21c-1ef51c077527	6f293a43-3f2b-46ef-ac47-8b7e67144172	2ff94940-223f-42da-9a9a-eb243257e8ad	2023-08-01 23:02:08	2023-08-01 23:02:08
7e7b7917-707a-45db-93bd-7c9d9de0cb05	6f293a43-3f2b-46ef-ac47-8b7e67144172	99ad7f65-6ad0-462e-9610-68a960602949	2023-08-01 23:02:54	2023-08-01 23:02:54
7c85690f-0a01-4ac5-9487-6fd7b0be5192	6f293a43-3f2b-46ef-ac47-8b7e67144172	932f61cf-30cb-464c-af7f-cefda253406f	2023-08-01 23:03:54	2023-08-01 23:03:54
bf5b7026-f789-4b75-b763-81dcb72db48d	6f293a43-3f2b-46ef-ac47-8b7e67144172	83e4718a-9485-4eb4-aa48-9af309ffe890	2023-08-01 23:04:47	2023-08-01 23:04:47
6ace359e-08cf-471c-b8c1-e248ed123adf	6f293a43-3f2b-46ef-ac47-8b7e67144172	9259accf-56a5-4dec-b3f2-4657a021fb98	2023-08-01 23:05:26	2023-08-01 23:05:26
8b466378-1b26-480e-97e0-f8af9688e213	6f293a43-3f2b-46ef-ac47-8b7e67144172	cfcc1957-9c05-4f99-9f83-c27699ef6293	2023-08-01 23:05:57	2023-08-01 23:05:57
192fe7ab-0026-4351-80c7-b8d19f68b961	6f293a43-3f2b-46ef-ac47-8b7e67144172	d724d13a-2da8-4193-88fa-7867e340e5b0	2023-08-01 23:06:28	2023-08-01 23:06:28
b4e16775-ec03-4ce2-b890-196f099a9cfd	6f293a43-3f2b-46ef-ac47-8b7e67144172	e5147230-3941-4a18-8f38-5aec515d60f1	2023-08-01 23:07:29	2023-08-01 23:07:29
1256a187-7d1b-4965-a184-c7c0a82eff89	6f293a43-3f2b-46ef-ac47-8b7e67144172	69515fa1-5691-4dae-93f5-30badb0d0d4f	2023-08-01 23:15:07	2023-08-01 23:15:07
ab036835-3eca-47fc-9317-7d649fa41f3c	6f293a43-3f2b-46ef-ac47-8b7e67144172	e4f9c392-daec-473c-a413-bacf72cc4eaa	2023-08-01 23:15:43	2023-08-01 23:15:43
7ad7cd17-07ac-419e-8891-12fd4a7a0db6	6f293a43-3f2b-46ef-ac47-8b7e67144172	5b4db964-e6cd-4ac4-a2d2-7ea2122ea67b	2023-08-01 23:16:19	2023-08-01 23:16:19
3fdb8c9a-c112-4aa8-87c5-05fc7d17c6ef	6f293a43-3f2b-46ef-ac47-8b7e67144172	6c289967-8bc4-436a-9f7a-a09f8fed3a15	2023-08-01 23:17:08	2023-08-01 23:17:08
efce94b5-e3c5-4ac1-ab7f-f1e002d30877	6f293a43-3f2b-46ef-ac47-8b7e67144172	8cd017e7-52d6-4025-bfe8-c80c36df6fbd	2023-08-01 23:17:50	2023-08-01 23:17:50
d8366fec-8fa1-4d9f-81b4-0f44f9700ea7	6f293a43-3f2b-46ef-ac47-8b7e67144172	aee4c692-77fc-44e5-a19c-5ccab4d9e000	2023-08-01 23:19:31	2023-08-01 23:19:31
401524e4-996b-4ea9-94e1-82efd422f08d	6f293a43-3f2b-46ef-ac47-8b7e67144172	2d881d73-7aff-4c71-baa7-485b2cfe4bfd	2023-08-02 04:22:38	2023-08-02 04:22:38
8d13900f-32d0-4ea3-a654-6e59929ab4b4	6f293a43-3f2b-46ef-ac47-8b7e67144172	fa66ce89-911c-4351-8cab-4c6863d09092	2023-08-02 05:46:32	2023-08-02 05:46:32
4a269879-d5a8-44e6-927e-80b67ee54a30	6f293a43-3f2b-46ef-ac47-8b7e67144172	5a3928ef-07b4-4dac-ad4e-a0fa6b78387e	2023-08-02 06:36:45	2023-08-02 06:36:45
ae81429a-d16e-4245-9b94-9959234c8e1d	6f293a43-3f2b-46ef-ac47-8b7e67144172	d8e79cdc-514f-42be-9145-8843d2518884	2023-08-02 06:38:48	2023-08-02 06:38:48
f49ae113-7b24-483d-b6e9-fe201922b982	6f293a43-3f2b-46ef-ac47-8b7e67144172	e5cb5cef-73f2-47f4-a5c0-bad7a62458c4	2023-08-02 06:40:10	2023-08-02 06:40:10
4ab8e233-709c-4fe3-b8b9-a3f5f74f5516	6f293a43-3f2b-46ef-ac47-8b7e67144172	79c53465-7947-4775-861d-55bb6e92a032	2023-08-02 06:41:04	2023-08-02 06:41:04
1ac5e706-1a14-4dc0-bd50-55eb288c43d3	6f293a43-3f2b-46ef-ac47-8b7e67144172	dfbf5e3d-931a-40ed-af70-3128a94742c4	2023-08-02 06:43:02	2023-08-02 06:43:02
515ce94a-a04d-45c9-8fa5-aa2fec7b045a	6f293a43-3f2b-46ef-ac47-8b7e67144172	b7181f6f-c5c1-4ac9-a10d-e2d9b3cb99d4	2023-08-02 06:44:38	2023-08-02 06:44:38
38d5bba7-4774-42a1-a657-1a27c7fe9853	6f293a43-3f2b-46ef-ac47-8b7e67144172	ca01abda-25b8-4071-bb41-dac89047a098	2023-08-02 06:45:35	2023-08-02 06:45:35
6d9cc4b9-8cff-45f8-b1d1-eb402fde3f5a	6f293a43-3f2b-46ef-ac47-8b7e67144172	78843771-b0b7-4831-976b-ec6d4c5b0ff7	2023-08-02 06:47:07	2023-08-02 06:47:07
79ca992a-1b3e-481e-8385-5f24c5118db3	6f293a43-3f2b-46ef-ac47-8b7e67144172	26e653b9-3de1-4e1d-8b13-60ff5dec60fa	2023-08-02 06:48:14	2023-08-02 06:48:14
c9f82b21-9851-4c13-b174-08e4e83aab86	6f293a43-3f2b-46ef-ac47-8b7e67144172	96b7788b-cfe4-49ca-b5d8-91a238f8e321	2023-08-02 09:05:15	2023-08-02 09:05:15
cfcdfb40-4e8e-47ce-b775-65abee150ead	6f293a43-3f2b-46ef-ac47-8b7e67144172	d2b1fd34-770b-4683-83c7-bac89219e985	2023-08-02 09:06:20	2023-08-02 09:06:20
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
6f293a43-3f2b-46ef-ac47-8b7e67144172	dhis2	2023-08-01 20:40:24	2023-08-01 21:21:11	fb227e5a-764d-4582-a629-6057155a0014	\N
28833745-532e-40df-99f8-ec59169f67b6	little-fog-414	2023-08-01 22:45:53	2023-08-01 22:48:41	fb227e5a-764d-4582-a629-6057155a0014	2023-08-01 22:48:41
\.


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oban_jobs_id_seq', 2101, true);


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

