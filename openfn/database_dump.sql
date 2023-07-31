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
18755669-ae95-4689-b1bc-74fb037ce676	79f165fc-ccbd-4c35-a48c-a3960a44a2e5	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:24.684354	2023-07-25 06:29:24.684354
1405e3b7-b350-4edf-ae8e-cb5ce3d67353	3a36543d-6f53-415b-92d7-4c512cfd1a57	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:08.241235	2023-07-25 06:30:08.241235
d4dfb51c-7e7d-4e93-b4dd-34b538deb409	de598d4b-9edc-44a5-be79-c332df1edaf3	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:00.868585	2023-07-26 05:46:00.868585
6922749e-586d-443c-bef4-a2e991177ab8	ada87ae0-864f-4297-9bf1-fefa7c2530ad	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:04.82887	2023-07-26 05:48:04.82887
f5ab7615-3f51-4055-b791-a6f091943220	121726a9-622f-42b1-8492-a2150e503821	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:21.116816	2023-07-26 05:49:21.116816
14585cbc-95a2-486e-a5a5-dd7cdd65e555	d992f183-a8a1-474b-b9cb-b63a8b36a99b	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:32.170019	2023-07-26 05:49:32.170019
337313e5-7cd3-4378-949d-8c03617f7cbf	c1fd175c-50bd-40f7-8378-e910cca8ae1b	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:33.998475	2023-07-26 05:51:33.998475
0d1f6598-f414-4a74-957e-091716b48e26	3409b05b-8310-4c20-b224-b26d854813b7	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:54.699415	2023-07-26 05:53:54.699415
065a27a7-c085-440f-a244-e20d8626351e	765b8aa2-0188-49bb-b214-f1898738a005	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:53.406743	2023-07-26 05:56:53.406743
49a25122-876d-473f-86a8-a29739049e36	434adc65-b0b4-4d66-82e5-c4edcfe586d4	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:49.707703	2023-07-26 07:58:49.707703
141d7fc9-33b0-45ae-a439-cac35a12271f	2b58add6-436f-469f-92cd-b8ae019709c4	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:25.270094	2023-07-26 09:07:25.270094
3cb189c1-2759-4a34-ac1f-7f239f685dcf	ca6eb8cb-edfa-4ce5-a780-c9e3711ffa21	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:25.297071	2023-07-26 09:07:25.297071
693acdf3-8fdf-4af6-b629-be19e535f72e	d2f48001-b71f-4212-ab27-fef1cc13d543	b5bca0d7-bf92-46d7-bf70-6c4972a54952	2023-07-26 09:07:25.299006	2023-07-26 09:07:25.299006
4499d876-b604-45a9-a7a4-220f6902c44e	e07b4aca-daf5-46e7-88a3-db7ae3251879	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:25.300171	2023-07-26 09:07:25.300171
a3a0772a-a964-4625-adcd-28712409882d	9860f471-4238-4b54-b469-783335a5b847	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:25.315761	2023-07-26 09:07:25.315761
4f7a23b1-af93-4ab1-82ee-2e8ffb09aa3a	c7058ffe-166f-4c90-bdb7-d3ecab44e8e1	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:41.911952	2023-07-26 09:07:41.911952
6ef75ddf-8272-46a2-8fde-4d2585aab0e9	d5a94818-0b0a-4089-9049-93c880789c8a	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:56.705874	2023-07-26 09:26:56.705874
fb922e38-4de6-4937-a4d9-897f2ef00e9d	75ed1b30-85e7-43c6-a8a8-2c6b492ed4f9	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:48.340287	2023-07-26 09:34:48.340287
34985f55-9369-4ce2-8e19-e8dcb38d0b5f	613b122d-ecd0-4921-ab86-2ca90589f742	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:03.250507	2023-07-26 09:46:03.250507
ec8cea33-dcb7-4d5e-9be1-3905d309bc53	c32b399b-0cd6-4caf-895b-44ee0e68e298	0837b50c-acea-4b77-a387-2080a1d75385	2023-07-26 15:07:50.014949	2023-07-26 15:07:50.014949
2540adaa-96c5-431c-9784-a0d3a1e4e1e9	fad4a7e0-1a30-4230-9d5f-be457fd120b8	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:08.451681	2023-07-26 15:14:08.451681
5a91d5e6-409e-4695-9f3c-bbc646dc8c9a	3ddd0e4d-b04f-40fd-821f-1366097cdd37	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:47.557884	2023-07-26 15:17:47.557884
29a79a36-f66f-4118-aeb8-a39fba494483	c8278b3b-29a6-480e-83d0-75e469963e2e	ff72b382-602a-45b0-b132-86aee9525bc9	2023-07-27 06:18:05.415996	2023-07-27 06:18:05.415996
8b1529f5-f7cb-4f42-b8c2-e2f27184a4a5	0bf3c2d5-95a0-4d9e-89e0-6bcf1f48b33a	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:13.84523	2023-07-27 06:18:13.84523
6325c26d-e203-4b65-847a-9dde811cae23	69beee32-fe80-421a-9f3c-becab676d277	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:46.709634	2023-07-27 06:18:46.709634
73210e65-1ead-4f55-a892-67250622ff58	5d362df5-5cfa-4450-8308-7faed210e7dd	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:08.455177	2023-07-27 06:27:08.455177
c3c9f62a-d666-4127-b81c-ad2c268acffe	cf7e6686-996e-45f3-92dc-fbe87c8aa5da	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:04.952572	2023-07-27 06:28:04.952572
6724f15d-e1c3-486a-acf0-539e2fe22c07	98c6f834-493c-43d3-a591-6e52941ee013	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:09.108181	2023-07-27 06:29:09.108181
0b8b3529-4341-44b6-8ef0-f9d406379124	b38f370c-226e-4e74-9b24-d4190da5b545	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:07.023351	2023-07-27 06:31:07.023351
c942a04c-2005-4281-8103-bdb896da9800	c7c769cd-88f0-4a9a-b65b-b9170b7e8fdd	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:05.518824	2023-07-27 06:32:05.518824
649ce4e1-1dda-4cd8-81bf-f6f1e6de3341	40229b74-2fea-4df7-9cb7-341516fcf67f	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:05.918888	2023-07-27 06:35:05.918888
7e9bc795-5533-4f3b-b1f6-155a24fe93c3	f52ad7f7-91de-43bd-bcbc-0fe39d23c26a	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:49.161837	2023-07-27 06:36:49.161837
85635843-9ee3-4f92-b501-e9e85308d8be	80198631-8779-4f00-a5a4-c91bbfecbaaa	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:00.386789	2023-07-27 06:39:00.386789
fa9df57e-5340-4946-ab36-001f1a8ca704	f62eea46-8c76-4632-bd46-a42e9c60fd86	9168922c-29b0-46e5-9294-61b6224d581b	2023-07-27 06:40:18.158781	2023-07-27 06:40:18.158781
ed6012ba-b48a-4929-989c-dc59f18d9d76	86c46ccc-2972-4e90-83ac-6c379b30225f	16b6bd09-1021-4c04-80cd-48ec60a79296	2023-07-27 06:40:29.247624	2023-07-27 06:40:29.247624
f88920d3-1ce2-4356-8f2e-ea71463f2b02	c990a6d4-c06e-499d-8938-175071921008	af5a1459-282d-457f-ae73-d3cc13835212	2023-07-27 06:40:48.030449	2023-07-27 06:40:48.030449
227baba7-97c8-4610-9368-0f94209ef770	d4637985-f9c6-4911-abeb-46f25c6bef25	c645bcc4-bca9-4de3-9834-c6f4339e606b	2023-07-27 06:41:04.906114	2023-07-27 06:41:04.906114
f49a9404-20cd-4463-9370-662300972805	06356212-2ed5-4d0e-a66a-c8d7257adfad	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:40.269509	2023-07-27 06:41:40.269509
df2e1df2-3252-4c50-bfe4-80df199cd135	0310e66c-e870-4b80-b75e-f3ac7d3e1143	29e754db-4ad3-4a31-9a60-cb34fb7dd84f	2023-07-27 06:42:50.001369	2023-07-27 06:42:50.001369
42c6a61b-7e9e-47d3-b5b5-99d017d22a4c	4ad48256-2c2a-46c3-9414-c63afb49a97e	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:43:59.760671	2023-07-27 06:43:59.760671
e994de02-7e3d-4cc3-87f7-5e96462e56e4	ebb50785-f179-4eb1-a6db-6257d0098107	ebeb3d1d-e4cf-4205-9a34-dc823623aad5	2023-07-27 06:44:30.540403	2023-07-27 06:44:30.540403
43c1a9e4-0575-4402-b579-e9a18d50882a	531f9a3f-5b49-4af5-adbe-ddf3bd90d855	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:04.227135	2023-07-27 06:46:04.227135
449ab78d-8ad7-4fe1-b587-8c0a038d702d	913a59f5-4161-4477-97db-a1f164b91eb3	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:07.28128	2023-07-27 06:47:07.28128
6244780d-9e0c-4dc7-8e67-16487e9ba30b	5208da2a-98e2-40e2-a2e5-5fcb51650568	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:34.546394	2023-07-27 06:47:34.546394
9d815575-034c-4328-befa-467be5a2f686	d85186f3-2291-4dff-a405-4ba3e2627c86	aa29dbe8-e943-483b-99c7-1a9adbfeb323	2023-07-27 06:48:10.825094	2023-07-27 06:48:10.825094
fbbd6af3-67d7-401b-a7be-bd337cf26bb5	6f6fcb9d-618e-474a-a43c-8ff6f183db3a	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:28.452884	2023-07-27 06:48:28.452884
f65b9dad-436b-44a3-97c7-0661599e1ec3	3907473f-030c-4748-8787-c7eefcf88f75	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:00.607957	2023-07-27 06:50:00.607957
f890a6b5-2435-4357-a1cf-1c99e7202cb0	ca0dc861-e49f-4566-81ec-87b0d6c5dd1a	a2b3cd73-7b1a-45cc-a0cc-23006cc88c09	2023-07-27 06:50:21.533817	2023-07-27 06:50:21.533817
91856a2b-0ee1-4eb5-beba-3a23e3dbfc58	a60d0c99-a15c-47da-8eb1-8fe2623144e5	44c8e46b-79f6-47f0-834f-7e2866a83783	2023-07-27 06:51:28.249986	2023-07-27 06:51:28.249986
e5e839ea-6aa1-46a5-a245-d598df6f412a	a4022f81-6dee-4c08-9510-2e3eb0fc11f1	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:53.417482	2023-07-27 06:54:53.417482
65748622-44d0-4c14-85cd-798e5c8386ce	4e47d65e-76df-41c1-a9be-2f040dc7da7b	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:03.127181	2023-07-27 06:57:03.127181
05bb4955-2fce-49d6-8b5e-1e1ba8a422ae	edca66f8-6388-40eb-857b-165c068f85d6	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:40.616223	2023-07-27 06:58:40.616223
61ae787f-59d0-4555-a4cc-6bc02293e290	70cca130-c3e5-45fc-bdfa-9bc2c4d4ee18	6de864c8-2183-4c39-acb6-85ff285a7321	2023-07-27 07:13:49.227994	2023-07-27 07:13:49.227994
286f5f96-9aae-4e52-9db7-f4c937ee44cd	adc8bace-ec06-495e-bdcb-27479501e7d0	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:33.4962	2023-07-27 07:14:33.4962
d4055622-a0c5-43ee-b508-2d22c0432cd2	cfcc8f07-0f6a-489d-bf8b-85e45668455e	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:04.862263	2023-07-27 07:15:04.862263
21746f43-f710-4487-bfa5-889723a63f7c	d3b7f5ad-bcd2-4074-9eb5-ad52f86b2338	347f3570-09ef-4be5-b2df-ff08a8995417	2023-07-27 07:15:40.034266	2023-07-27 07:15:40.034266
1301de26-6b21-4d02-9342-839d53eafb27	8d1e7f30-c145-4482-8595-40c5b9e658ad	0f8be2e3-f7f5-45c8-8afb-92feb5d346f6	2023-07-27 07:15:58.177058	2023-07-27 07:15:58.177058
c6530bb5-0965-42fc-b759-6cb99b2a9fa3	ef98ffad-d9a3-4a04-b75a-754945b2070b	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:17.377263	2023-07-27 07:16:17.377263
fd592b9e-090f-4b5d-ae37-dd8c4cf245e0	384ee1b8-72bb-4b7e-a4ef-0694c32e1f43	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:56.974401	2023-07-27 07:18:56.974401
2aca759e-461c-4d81-902b-e609fb17df49	0d927ce8-d745-4af1-a611-136b72c0351a	48a9eb7e-9295-4e3d-9db4-189a8e5ddd59	2023-07-27 07:19:37.067558	2023-07-27 07:19:37.067558
49fe8abd-e1b9-40a9-8d4b-65e042301057	f0f9ddf0-5d42-4dec-ab52-05f489e28290	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:43.151133	2023-07-27 07:25:43.151133
a72347c1-4b18-4d34-ab06-c6c2f6cea33c	799621c7-5494-417f-85de-4d667117b1ac	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:57.079619	2023-07-27 07:25:57.079619
18076951-9b0b-43d7-9a1a-cd1e891c9e3a	9ab61f6f-089a-4a9c-8e61-2e95ef66982f	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:57.359259	2023-07-27 07:26:57.359259
95178718-8553-4d5a-8527-114c4f4646f2	e4bab9f6-49b1-4625-bbab-c0e5e0dba602	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:18.521022	2023-07-27 07:27:18.521022
8c64f348-95b0-4fe8-8b85-6b63e8b15c4f	23ee712e-aa87-4f75-9e07-4975dc9b9425	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:20.071873	2023-07-27 07:27:20.071873
44114fda-1d25-4662-8f7b-77bb69c1fe17	a0d46558-14d9-40ae-9a83-26aa6deae820	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:10.042033	2023-07-27 07:28:10.042033
cb1638af-bc20-41a9-8f51-3e34af09b534	8e1a4a01-917e-4c37-bf27-a36f527fb6bb	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:38.963061	2023-07-27 07:28:38.963061
b2c79b3f-6341-4009-ac09-bd5a91b7ee19	97438ba1-d8a6-43e5-9b85-c925b87ed0f3	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:56.34736	2023-07-27 07:28:56.34736
eb24726b-056e-45bb-8601-c5bad9a0d148	5b5741ca-dc97-4dd0-9b92-210ca57d9266	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:21.599701	2023-07-27 07:30:21.599701
63b226af-ebbb-45f7-b1ec-e14bd5c563ee	b172f37e-c531-4a85-8be8-c8159f57297d	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:39.141593	2023-07-27 07:30:39.141593
9cebae41-358a-47db-a3a1-9bb7d0eb3895	3b5f6efe-8f0d-4fb7-b663-db76d0e63b1c	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:08.062317	2023-07-27 07:31:08.062317
1e5f1345-e139-49fa-a617-8fc640b86c8a	0f0b8aaf-95a3-406b-bf10-2f188737066d	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:49.174502	2023-07-27 07:33:49.174502
347d3430-1552-4ff7-8c4c-66f373ad9d17	25300970-7ee3-4915-a2c6-dbd15bf0ff70	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:19.193516	2023-07-27 07:34:19.193516
3f89c705-909a-4d6b-877f-9477d1355b5a	d56b31e6-5197-420c-adc2-79ee5bc41d4e	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:21.43172	2023-07-27 07:38:21.43172
0b095f28-44bf-4d8b-aabc-1532667be760	f7502757-dc12-423a-bb09-d6eb79fa00e5	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:51.228126	2023-07-27 07:38:51.228126
612e0db2-c89c-4656-9aea-3f3068e496a5	8b604f8e-1368-4920-b7f5-be8269a9f26b	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:03.621983	2023-07-27 07:47:03.621983
df385b8c-2ee9-43a5-8de5-bafe9d468c35	f2caaed9-b7f1-4e62-ba0d-7b6bb6339bd7	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:15.872837	2023-07-27 07:48:15.872837
b1f29e49-65a1-4ad3-b9da-4fba45e17dff	53c92238-9c40-4d6c-926f-1f84205b2dea	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:09.466226	2023-07-27 07:49:09.466226
01b68d14-c91d-46ab-8c2e-329d30108b55	d97a200e-4373-4d99-bef8-c7c1b606340b	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:35.304529	2023-07-27 07:51:35.304529
542b611e-69a6-447b-bee6-ab5cb9ae5edc	c4247886-0ef3-4677-b104-4a2b3209a5d3	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:03.483506	2023-07-27 08:08:03.483506
971ffe94-0fa9-40a6-80b4-33690e9e7ff6	dd5dc627-42bc-46bc-bf9d-d5086e8a1992	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:22.563851	2023-07-27 08:12:22.563851
e54dc6cc-c27e-4658-83bc-42ef8e9e576b	cc3a37af-85cb-4d18-a2d0-11fa19b1bb0c	4998acfe-f9a9-490f-8156-6072366471db	2023-07-27 08:13:25.032133	2023-07-27 08:13:25.032133
a0813d28-fe6d-45bc-8e0c-36dd607879f0	8a459931-1b2b-4fb1-ae8d-766982989620	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:45.596317	2023-07-27 08:14:45.596317
d5b10206-0858-4a0f-ad82-98577cbdd294	7293a315-e5d1-44cb-8ce4-4f0fa37dc145	ea2a4f7d-e4d3-4625-a787-26dc9618c349	2023-07-27 08:15:23.046451	2023-07-27 08:15:23.046451
66399de9-c08a-4497-b562-716adb7b4e8f	3a46b059-2402-41ab-b9a9-230f2ca615a1	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:38.090106	2023-07-27 08:17:38.090106
0497eacf-4f5d-4246-9ca2-703c4c4f2088	9658d951-74c2-4b65-b247-4aef811560d2	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:21.919108	2023-07-27 08:18:21.919108
c24753d6-e24e-48af-802c-2c41d188bf2c	e6696545-c9ee-4820-a5d8-c306a59adfb1	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:01.417138	2023-07-27 08:22:01.417138
67bea864-5a4c-4aa8-8423-60b0d541b35a	36b8e64b-3a3c-4de5-95bc-ca8970230b69	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:22.878628	2023-07-27 08:24:22.878628
042fbffe-5676-483f-a8e6-ed7af14d909c	b9a5d989-0c87-458e-8ac6-fce3ff34d401	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:46.396438	2023-07-27 08:24:46.396438
233b9e87-0269-4b48-9867-87040229b849	7b0c4263-b2b4-4897-8eea-1b321e2c285b	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:08.722083	2023-07-27 08:49:08.722083
62d5e66f-ab5a-45f1-9356-c7b7ab743f4f	0fc019a9-f389-43d6-9d96-1b105286343b	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:46.670409	2023-07-27 08:26:46.670409
e12b9fc9-72d4-440e-8343-affdc7e36c43	febb4b4f-579c-4659-9d58-f92de92762de	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:04.842509	2023-07-27 08:31:04.842509
037f42d5-faaa-401a-8a31-8cd975b93ef3	91e4ec63-90a4-437c-9d5a-6730ab268cc8	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:43.651635	2023-07-27 08:31:43.651635
0533fc35-f471-4710-a50f-9c30abb63fac	589df1f5-69f0-4a47-a8ee-63a2afeb44e8	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:07.54954	2023-07-27 08:34:07.54954
3944ae67-9909-4a9d-a377-cd062185c1d5	bea76689-6800-4541-ae31-3877a40aefc0	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:49.806484	2023-07-27 08:49:49.806484
5609c389-0101-4c33-ac6f-b7792495f900	6ecfa424-4c2d-4b14-bfec-614deaea7c39	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:00.608879	2023-07-27 08:53:00.608879
\.


--
-- Data for Name: attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attempts (id, reason_id, work_order_id, inserted_at, updated_at) FROM stdin;
79f165fc-ccbd-4c35-a48c-a3960a44a2e5	0d742fec-f283-47c9-9dec-e86e47ea8304	b5ecbcc2-db15-40cd-a9d8-00bedbb26b82	2023-07-25 06:29:24.683407	2023-07-25 06:29:24.683407
3a36543d-6f53-415b-92d7-4c512cfd1a57	c2bc616a-322c-4a29-899b-ed523ad90ed2	6dc5422e-17ec-4012-9325-8b3ee68ad38b	2023-07-25 06:30:08.240051	2023-07-25 06:30:08.240051
de598d4b-9edc-44a5-be79-c332df1edaf3	d8fcbd5d-296f-4618-96bd-158935cf37b6	4740b990-10b8-4391-8239-9356c242e4da	2023-07-26 05:46:00.868139	2023-07-26 05:46:00.868139
ada87ae0-864f-4297-9bf1-fefa7c2530ad	a12c0063-2a0d-4d7b-b52f-f0dee3f0686f	9fad25ce-f782-4de2-92bf-1824f5975a72	2023-07-26 05:48:04.828037	2023-07-26 05:48:04.828037
121726a9-622f-42b1-8492-a2150e503821	91de8e96-8078-4845-a851-e8e9d7bcc544	be100a28-bdac-4e71-b0e5-8d6e20ef69e2	2023-07-26 05:49:21.115006	2023-07-26 05:49:21.115006
d992f183-a8a1-474b-b9cb-b63a8b36a99b	9d7566f3-ad99-454d-8d64-dac4200b9ffc	1a859c19-7fee-450d-aa58-40606812a50e	2023-07-26 05:49:32.169025	2023-07-26 05:49:32.169025
c1fd175c-50bd-40f7-8378-e910cca8ae1b	d5edcdbc-bd45-4223-888f-0f85050ec715	514e6562-55c3-4d79-b190-0592affc6bdb	2023-07-26 05:51:33.997995	2023-07-26 05:51:33.997995
3409b05b-8310-4c20-b224-b26d854813b7	9a14a552-f11d-49fc-b4a2-5cde676ba923	d65ef4cc-e871-401b-8a3b-f1a2789e46c7	2023-07-26 05:53:54.69898	2023-07-26 05:53:54.69898
765b8aa2-0188-49bb-b214-f1898738a005	ff067f1b-b872-4d7e-b7b7-557817261136	93a89fb7-3d08-49fb-b8c6-0d7604a57720	2023-07-26 05:56:53.405744	2023-07-26 05:56:53.405744
434adc65-b0b4-4d66-82e5-c4edcfe586d4	7f7ded00-a8e0-48e0-aba8-cbfc00a303f5	b8caeff0-269e-495e-8f27-35e6d2fe63e8	2023-07-26 07:58:49.706928	2023-07-26 07:58:49.706928
2b58add6-436f-469f-92cd-b8ae019709c4	54baccef-78d8-465b-8380-2d4df0ab4792	785d8286-35ad-44a5-85cb-f6385bde997d	2023-07-26 09:07:25.269395	2023-07-26 09:07:25.269395
ca6eb8cb-edfa-4ce5-a780-c9e3711ffa21	50ccca0c-b31c-40c1-a60d-679940aeb7a1	80ae92f2-ba40-4de5-a603-8a69b5ebd5ea	2023-07-26 09:07:25.296184	2023-07-26 09:07:25.296184
d2f48001-b71f-4212-ab27-fef1cc13d543	7f986400-f591-4d7d-aed7-2690713eb5a5	cc05cd0f-7fc0-417b-ae89-d32f696ccd7b	2023-07-26 09:07:25.298144	2023-07-26 09:07:25.298144
e07b4aca-daf5-46e7-88a3-db7ae3251879	8e8cbeda-b641-4ab6-94a5-7199a271ad00	553d3ffb-0f27-4f7f-9667-dcee8c28597e	2023-07-26 09:07:25.298547	2023-07-26 09:07:25.298547
9860f471-4238-4b54-b469-783335a5b847	8d968629-62b2-4b2d-9a75-881bc08e356d	3b5a3fb7-233b-41da-980d-aeb6f9da6cf3	2023-07-26 09:07:25.314799	2023-07-26 09:07:25.314799
c7058ffe-166f-4c90-bdb7-d3ecab44e8e1	3096e234-b162-4cd9-b392-5949d7c1789d	8e69461d-774a-4494-984a-5c4f66b1110d	2023-07-26 09:07:41.91073	2023-07-26 09:07:41.91073
d5a94818-0b0a-4089-9049-93c880789c8a	17c29e50-4a3b-42f1-a5a5-8c6aa73d404d	2929b30a-486f-4a54-85f2-eb67e7138b65	2023-07-26 09:26:56.705365	2023-07-26 09:26:56.705365
75ed1b30-85e7-43c6-a8a8-2c6b492ed4f9	c4a4b565-0c45-4a67-bff8-dd55828f5405	466a6217-f8ec-4e08-9108-9d458a91c1fe	2023-07-26 09:34:48.339119	2023-07-26 09:34:48.339119
613b122d-ecd0-4921-ab86-2ca90589f742	bd528715-5e26-4402-91d8-3dd227269bbe	1d5d5db6-d3e4-4087-bc4a-dfcdd288c0f4	2023-07-26 09:46:03.249873	2023-07-26 09:46:03.249873
c32b399b-0cd6-4caf-895b-44ee0e68e298	3c61d981-bf45-4914-9830-9bdedfdf6d28	bea7762c-0307-4875-8842-491d33d4fdaa	2023-07-26 15:07:50.014091	2023-07-26 15:07:50.014091
fad4a7e0-1a30-4230-9d5f-be457fd120b8	96940490-ca82-45e8-b498-21248beb0d0c	5bb0f21f-2795-457d-a76c-0a9461004d8d	2023-07-26 15:14:08.450654	2023-07-26 15:14:08.450654
3ddd0e4d-b04f-40fd-821f-1366097cdd37	5afd3365-e738-4d02-a1d5-c7882e557102	a522af9f-bd5f-48ab-8c57-45d46d9f529b	2023-07-26 15:17:47.557141	2023-07-26 15:17:47.557141
c8278b3b-29a6-480e-83d0-75e469963e2e	c9565fc7-c042-4bd7-bce8-b9a9f465ed10	b4486eb4-27ce-40c2-b539-071d5bffd294	2023-07-27 06:18:05.415519	2023-07-27 06:18:05.415519
0bf3c2d5-95a0-4d9e-89e0-6bcf1f48b33a	20e6552c-0fee-4b0d-8bd0-beaeb2db0c2d	cd272489-0778-4b70-aae5-9f54d5a70bbc	2023-07-27 06:18:13.844783	2023-07-27 06:18:13.844783
69beee32-fe80-421a-9f3c-becab676d277	e5bb532b-04c1-4c73-8640-309903a73238	6bc87d27-b7e0-4124-a9d7-e23edc55908e	2023-07-27 06:18:46.708849	2023-07-27 06:18:46.708849
5d362df5-5cfa-4450-8308-7faed210e7dd	4815ea2a-ed65-4d06-a634-3e8d990b50ff	9dd205f1-664f-4c66-997f-5b172740f0e9	2023-07-27 06:27:08.454623	2023-07-27 06:27:08.454623
cf7e6686-996e-45f3-92dc-fbe87c8aa5da	2c8609f4-899e-4ace-b6c9-d781fbe30f59	ff44234e-2b15-4216-9caf-5ee576027546	2023-07-27 06:28:04.952275	2023-07-27 06:28:04.952275
98c6f834-493c-43d3-a591-6e52941ee013	80acfc3f-064b-4049-bcea-faaab2619c52	6ceb7e92-d070-4c22-90a4-8380bf5ed7f4	2023-07-27 06:29:09.107534	2023-07-27 06:29:09.107534
b38f370c-226e-4e74-9b24-d4190da5b545	56f48551-d13c-4e7a-8dcf-423678717324	68f647f9-606b-4f4c-9d4a-1b1b4630ab04	2023-07-27 06:31:07.022619	2023-07-27 06:31:07.022619
c7c769cd-88f0-4a9a-b65b-b9170b7e8fdd	ff7e2ee3-fa46-4546-a0af-7117fa450d78	adf216af-660b-4f60-a217-87f24138496e	2023-07-27 06:32:05.518203	2023-07-27 06:32:05.518203
40229b74-2fea-4df7-9cb7-341516fcf67f	de07949a-55a6-4074-ba30-6b2d8e8523cc	89b3472e-22dc-4565-b48d-e1ff50bffc57	2023-07-27 06:35:05.918463	2023-07-27 06:35:05.918463
f52ad7f7-91de-43bd-bcbc-0fe39d23c26a	6868d4a6-c868-4598-9f08-6cebc5a0fa77	3319debb-0dad-4c13-bb60-1ba311076764	2023-07-27 06:36:49.161165	2023-07-27 06:36:49.161165
80198631-8779-4f00-a5a4-c91bbfecbaaa	63202682-62b3-48d1-a932-26b843cfafbb	5dd0192b-83c0-4779-a2e1-4ba4c0a44cdf	2023-07-27 06:39:00.386045	2023-07-27 06:39:00.386045
f62eea46-8c76-4632-bd46-a42e9c60fd86	9628f4da-c079-4944-a86e-7a98bb9f9a4a	d52cfafe-ecdc-45b0-bb4f-f6b4a2be8931	2023-07-27 06:40:18.157796	2023-07-27 06:40:18.157796
86c46ccc-2972-4e90-83ac-6c379b30225f	16ead63c-a0d8-4049-af34-68e1d160e4da	97c499e1-3fe4-4ea0-93dc-8543560b4775	2023-07-27 06:40:29.247	2023-07-27 06:40:29.247
c990a6d4-c06e-499d-8938-175071921008	98ed0ae8-70de-4a7b-8fc0-f6c5feca99c7	e8ed8347-67f1-4a4b-97b6-2c7933fb314d	2023-07-27 06:40:48.029922	2023-07-27 06:40:48.029922
d4637985-f9c6-4911-abeb-46f25c6bef25	5b7443bf-699a-4213-808c-4e763ad3fb03	4c1d2de2-51e0-41fe-aa43-9f4fd06b8037	2023-07-27 06:41:04.905077	2023-07-27 06:41:04.905077
06356212-2ed5-4d0e-a66a-c8d7257adfad	89d9eb26-c82e-433d-8443-1deb8b019235	252bf34c-fb4d-4f5a-ac13-98f6e8734080	2023-07-27 06:41:40.268597	2023-07-27 06:41:40.268597
0310e66c-e870-4b80-b75e-f3ac7d3e1143	f8969fda-9ff4-4729-929f-3c6463b8e15d	2bd0feaa-8981-4163-9821-f02e56eff6d4	2023-07-27 06:42:50.000731	2023-07-27 06:42:50.000731
4ad48256-2c2a-46c3-9414-c63afb49a97e	b3640cc8-3e38-453d-9731-2e05f15a5a8d	5478f70b-5c15-4505-b89f-90a0fd5a4e25	2023-07-27 06:43:59.760045	2023-07-27 06:43:59.760045
ebb50785-f179-4eb1-a6db-6257d0098107	7995e693-b4e1-4e4d-aed5-94b271a2f2cc	fa4d8616-5285-4b2d-943c-5bb4f73b162b	2023-07-27 06:44:30.539948	2023-07-27 06:44:30.539948
531f9a3f-5b49-4af5-adbe-ddf3bd90d855	0d5f7ec8-d510-40c7-95e4-8f71b0a5170c	e3f0a6a9-ca62-4460-bea5-33ba13cee562	2023-07-27 06:46:04.226491	2023-07-27 06:46:04.226491
913a59f5-4161-4477-97db-a1f164b91eb3	fec9a645-1767-4e12-8da2-41a0b7e4e20c	90d1ecc3-21be-4896-9d7a-4683dc43494b	2023-07-27 06:47:07.280751	2023-07-27 06:47:07.280751
5208da2a-98e2-40e2-a2e5-5fcb51650568	25f0ef3f-65df-417d-bce4-36f68ac2ac7d	71123b87-b8e4-4d45-96ae-2e1be433eb01	2023-07-27 06:47:34.545787	2023-07-27 06:47:34.545787
d85186f3-2291-4dff-a405-4ba3e2627c86	cb5c0d84-2862-4d8c-aab9-f8d23606ea98	08afc029-9579-4806-83f6-b67d8c78ce20	2023-07-27 06:48:10.824353	2023-07-27 06:48:10.824353
6f6fcb9d-618e-474a-a43c-8ff6f183db3a	e4a5933e-a677-4a68-9875-9ae16c4f2f1d	ecd74208-83a5-4580-87cb-d8d2cb2e1a53	2023-07-27 06:48:28.452301	2023-07-27 06:48:28.452301
3907473f-030c-4748-8787-c7eefcf88f75	0601a2c2-cf25-4b66-a310-4afa23ef387b	d15318fe-7aa3-4f8e-9196-392b359c8ac3	2023-07-27 06:50:00.607411	2023-07-27 06:50:00.607411
ca0dc861-e49f-4566-81ec-87b0d6c5dd1a	2e6ccc64-848b-47d3-a5e3-f830fe151b10	63685fbd-0a68-4a70-aa6e-6e55ec1e24a9	2023-07-27 06:50:21.53284	2023-07-27 06:50:21.53284
a60d0c99-a15c-47da-8eb1-8fe2623144e5	8b774587-0575-4491-b802-ff7a0ab5f727	d29c9269-e564-4771-b2bb-6cccbac8c433	2023-07-27 06:51:28.249419	2023-07-27 06:51:28.249419
a4022f81-6dee-4c08-9510-2e3eb0fc11f1	e2384c72-ca1f-4a5f-af77-d38af9673b9b	27a5cce9-8899-4836-b665-fd02a59749ca	2023-07-27 06:54:53.416937	2023-07-27 06:54:53.416937
4e47d65e-76df-41c1-a9be-2f040dc7da7b	7c717808-a649-4b7e-9396-7c1405b379c8	c3fec4e2-8a9a-4f5a-bf1b-3c240f701cf9	2023-07-27 06:57:03.126451	2023-07-27 06:57:03.126451
edca66f8-6388-40eb-857b-165c068f85d6	809c2742-63c6-493f-99be-a5dd064ca6af	cc90f1c6-f8a7-4f96-a073-ad4e2efe3c1f	2023-07-27 06:58:40.615455	2023-07-27 06:58:40.615455
70cca130-c3e5-45fc-bdfa-9bc2c4d4ee18	81a17849-a495-4207-8c27-460a5c48dd6f	41ac5d16-70ab-441e-a03c-3f570e145baa	2023-07-27 07:13:49.227011	2023-07-27 07:13:49.227011
adc8bace-ec06-495e-bdcb-27479501e7d0	60c41762-c480-4d4b-a223-533457a8c8e4	f69540de-ea59-49cd-9fa2-0787b2faa16c	2023-07-27 07:14:33.495597	2023-07-27 07:14:33.495597
cfcc8f07-0f6a-489d-bf8b-85e45668455e	0669320d-eed4-4d55-b087-7dd61eab4c2f	5c7557c8-439f-43fa-a8c2-b615fe65a578	2023-07-27 07:15:04.861675	2023-07-27 07:15:04.861675
d3b7f5ad-bcd2-4074-9eb5-ad52f86b2338	3cdf8a5f-6e51-4e2c-b2bc-e2881b277c29	a60a30c4-161d-4374-a9e2-55427b27c71b	2023-07-27 07:15:40.033721	2023-07-27 07:15:40.033721
8d1e7f30-c145-4482-8595-40c5b9e658ad	e7894ee8-1b76-4b13-aa20-4a6196ee4840	42ed8878-bbde-4870-aff1-c73f0b038861	2023-07-27 07:15:58.176446	2023-07-27 07:15:58.176446
ef98ffad-d9a3-4a04-b75a-754945b2070b	d6a39721-b2ea-4be2-8426-273543bb450a	cb3bc7f5-968a-430f-8aff-bd9545c40179	2023-07-27 07:16:17.376821	2023-07-27 07:16:17.376821
384ee1b8-72bb-4b7e-a4ef-0694c32e1f43	127e2de4-9300-442a-a42e-2a2afb079322	f65aad6a-350b-4f8a-9097-1c0132be1f73	2023-07-27 07:18:56.97372	2023-07-27 07:18:56.97372
0d927ce8-d745-4af1-a611-136b72c0351a	79d5918c-904f-48d0-8abb-9001a07f6183	39f7166f-1bb0-43c0-bc53-1ad38ba4785e	2023-07-27 07:19:37.066734	2023-07-27 07:19:37.066734
f0f9ddf0-5d42-4dec-ab52-05f489e28290	98e79e63-d8d6-41e3-83e6-8f6b76cf7c57	b97f3034-9d62-435b-942f-4d782c55d248	2023-07-27 07:25:43.150566	2023-07-27 07:25:43.150566
799621c7-5494-417f-85de-4d667117b1ac	9d7b421b-50e8-4201-8e91-580b89540a85	d3ce0d7b-9490-4136-be55-1403fc30e9d2	2023-07-27 07:25:57.079142	2023-07-27 07:25:57.079142
9ab61f6f-089a-4a9c-8e61-2e95ef66982f	86b6b3e6-17dc-4ec9-bcf3-55a6f3b6c49e	08f96169-82dc-4954-925e-6dfecccf9478	2023-07-27 07:26:57.358364	2023-07-27 07:26:57.358364
e4bab9f6-49b1-4625-bbab-c0e5e0dba602	1a25ba43-6b01-4688-8b16-195a8e9f9859	8f8de3b0-8d4f-4735-b826-afa105f4f655	2023-07-27 07:27:18.520573	2023-07-27 07:27:18.520573
23ee712e-aa87-4f75-9e07-4975dc9b9425	b548218b-7d2f-46d3-8186-552ca71a2a0d	35ba402c-8bcb-4dd3-a269-b2e14be0adc9	2023-07-27 07:27:20.071038	2023-07-27 07:27:20.071038
a0d46558-14d9-40ae-9a83-26aa6deae820	ac878ac0-d635-442d-9000-ea4fce52a8a6	7547c2a3-09b7-4235-a30d-e99598700b5b	2023-07-27 07:28:10.041426	2023-07-27 07:28:10.041426
8e1a4a01-917e-4c37-bf27-a36f527fb6bb	7ea1a6ec-082d-4204-b90c-0d01c381848b	3dba995b-a6a5-4015-a89c-002f0e6ad87d	2023-07-27 07:28:38.962582	2023-07-27 07:28:38.962582
97438ba1-d8a6-43e5-9b85-c925b87ed0f3	917e750d-1690-45c1-9f22-fefddbb4c4fb	99975691-d77b-4784-8759-4e0cfaf92b20	2023-07-27 07:28:56.346675	2023-07-27 07:28:56.346675
5b5741ca-dc97-4dd0-9b92-210ca57d9266	94d64584-6429-41a5-b81f-aeb75742385b	219c6068-7156-447b-a117-281fb8066ce2	2023-07-27 07:30:21.598811	2023-07-27 07:30:21.598811
b172f37e-c531-4a85-8be8-c8159f57297d	05a73236-0da6-4f4f-82a1-d8d1890e8a24	c667ea3b-8a9a-4bb8-a6d5-68a0dc73d799	2023-07-27 07:30:39.140883	2023-07-27 07:30:39.140883
3b5f6efe-8f0d-4fb7-b663-db76d0e63b1c	c48ce525-aebd-4438-a3f5-0b0bc21c3f04	2b85f8df-31cc-45e2-bc4c-7c1bdd6b8656	2023-07-27 07:31:08.060815	2023-07-27 07:31:08.060815
0f0b8aaf-95a3-406b-bf10-2f188737066d	638a0a5b-c37b-4e69-be99-63e3615120d1	f256071d-54a0-4b9c-8561-0f39f47e45b0	2023-07-27 07:33:49.173812	2023-07-27 07:33:49.173812
25300970-7ee3-4915-a2c6-dbd15bf0ff70	171022ac-75ab-4d23-84aa-4b0dbb189d9c	b4ec2bc1-ecf8-40c5-a328-58df83ece7e1	2023-07-27 07:34:19.192657	2023-07-27 07:34:19.192657
d56b31e6-5197-420c-adc2-79ee5bc41d4e	b9cc5901-8ab7-4eb8-9c3d-be0da796c56f	92b3dcc4-18cd-4339-8d0b-01ec63a9e4e9	2023-07-27 07:38:21.431062	2023-07-27 07:38:21.431062
f7502757-dc12-423a-bb09-d6eb79fa00e5	6dc5cb0d-f98f-4bff-b64d-4bb74bf29e57	2dcd0769-9d15-45ea-83ce-9c99ab608700	2023-07-27 07:38:51.227374	2023-07-27 07:38:51.227374
8b604f8e-1368-4920-b7f5-be8269a9f26b	c533b930-1723-4594-8cac-dfb1184e64eb	681f06e8-4d32-4cb5-92bb-1eb9515ffe1d	2023-07-27 07:47:03.621245	2023-07-27 07:47:03.621245
f2caaed9-b7f1-4e62-ba0d-7b6bb6339bd7	002b5b51-0633-4cd2-b299-2cd315995079	3c07392b-86af-4323-97a5-6a8dcc85e62d	2023-07-27 07:48:15.871928	2023-07-27 07:48:15.871928
53c92238-9c40-4d6c-926f-1f84205b2dea	682b2a61-46d5-46bd-81cd-84fe943d8e89	344e63b8-c3ca-4e7e-bd82-1e68f880c110	2023-07-27 07:49:09.465193	2023-07-27 07:49:09.465193
d97a200e-4373-4d99-bef8-c7c1b606340b	6b08a7cf-3611-44b6-9f3d-8ee6095f9d83	d6a23fcd-33b1-4d8f-9f8b-e0ef21ed231c	2023-07-27 07:51:35.303911	2023-07-27 07:51:35.303911
c4247886-0ef3-4677-b104-4a2b3209a5d3	dc28c6e0-688f-4f8e-ad61-1ff73bede2af	7aada6e3-e354-4c26-b912-f8770d9a7972	2023-07-27 08:08:03.482763	2023-07-27 08:08:03.482763
dd5dc627-42bc-46bc-bf9d-d5086e8a1992	156ad6c3-bfe5-4184-92dc-0ad76929e7e0	4bf4f273-361f-48ba-99eb-c9e3dbb9010f	2023-07-27 08:12:22.563084	2023-07-27 08:12:22.563084
cc3a37af-85cb-4d18-a2d0-11fa19b1bb0c	656db25b-99fa-4102-8713-a4fa9d058a4b	972a50da-40a8-4037-bdb2-0f78cf2458b7	2023-07-27 08:13:25.03114	2023-07-27 08:13:25.03114
8a459931-1b2b-4fb1-ae8d-766982989620	c5b9e474-f4bc-4c9d-95b1-30c7aa905c2e	eb61b56b-1449-4f75-9e29-385b9fa8d240	2023-07-27 08:14:45.595381	2023-07-27 08:14:45.595381
7293a315-e5d1-44cb-8ce4-4f0fa37dc145	a583b766-4d3f-4250-8948-27903ff374c1	817310ae-32ce-46e0-82f5-ba7eb4d13f23	2023-07-27 08:15:23.04548	2023-07-27 08:15:23.04548
3a46b059-2402-41ab-b9a9-230f2ca615a1	79ba2b37-8a90-418f-87f3-c7bcd4b0df46	04e4d0cf-d8ff-4aa3-96ae-8c83ca3d3ce4	2023-07-27 08:17:38.089533	2023-07-27 08:17:38.089533
9658d951-74c2-4b65-b247-4aef811560d2	c41b5eca-57e8-4804-ab4d-8eae7b875ab1	71afb63c-03a1-4aeb-adf0-fba0879e459b	2023-07-27 08:18:21.918194	2023-07-27 08:18:21.918194
e6696545-c9ee-4820-a5d8-c306a59adfb1	d2162ad8-4d5e-4a5c-9c39-d97a2f6996ba	a8a2a87c-219e-4d9d-8c00-e2de303c998f	2023-07-27 08:22:01.416459	2023-07-27 08:22:01.416459
36b8e64b-3a3c-4de5-95bc-ca8970230b69	18c01c13-6093-49ff-9eaa-70a394715255	86867801-592d-4632-a8d2-77c8f1c1fd6d	2023-07-27 08:24:22.877908	2023-07-27 08:24:22.877908
b9a5d989-0c87-458e-8ac6-fce3ff34d401	0bcd3348-356b-4058-8f8c-ad28967dce5b	d849e9cf-dd46-425c-b8d2-bda32374367f	2023-07-27 08:24:46.395729	2023-07-27 08:24:46.395729
7b0c4263-b2b4-4897-8eea-1b321e2c285b	6e8ccdf6-a8b6-41d7-b0f3-7c665ce0eeed	d3483d43-612c-42a3-bfc9-fdbc621d3ebe	2023-07-27 08:49:08.721434	2023-07-27 08:49:08.721434
0fc019a9-f389-43d6-9d96-1b105286343b	1ec13a34-9c1d-47c0-84d0-0a4bf2c533ce	a9614879-5f35-44cc-b392-8c73a8ab8ead	2023-07-27 08:26:46.669617	2023-07-27 08:26:46.669617
febb4b4f-579c-4659-9d58-f92de92762de	d387dd89-e5a8-4b5d-ba61-b4c12d7aed76	78a1bcf6-e08d-4a50-869f-a062405eb465	2023-07-27 08:31:04.841622	2023-07-27 08:31:04.841622
91e4ec63-90a4-437c-9d5a-6730ab268cc8	baea932d-db62-46f6-ac73-baf03907011c	9f82c0e7-3d7d-4ec5-9cc5-f13961aaf8bd	2023-07-27 08:31:43.651027	2023-07-27 08:31:43.651027
589df1f5-69f0-4a47-a8ee-63a2afeb44e8	6f69396b-f947-45dc-9309-9f1af2743af5	333fcb7c-1ae2-44ff-aadd-866d48430f14	2023-07-27 08:34:07.548769	2023-07-27 08:34:07.548769
bea76689-6800-4541-ae31-3877a40aefc0	e3ec3fcc-b838-4899-be38-d55a34736de0	d7041627-a98d-4b3c-8945-23831c072f0d	2023-07-27 08:49:49.805526	2023-07-27 08:49:49.805526
6ecfa424-4c2d-4b14-bfec-614deaea7c39	11d0d2bb-b50a-415e-92d3-525fdd3cd41e	df32fa60-f53a-4b44-a8e9-2f12e7f8c0f7	2023-07-27 08:53:00.607984	2023-07-27 08:53:00.607984
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
5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384	test	2023-07-25 06:22:07	2023-07-26 05:53:37	3476f7a9-e02f-4a3d-bc1f-ae3374a882ac	\\x010a4145532e47434d2e5631d4dc55b272ec58d9c53fdf39040fe6aa41570320f1b53cf01b91939e5911f56a802727608bf363df5105055dafff1bfb7f2ce0e7219e4f7f16851f186de669906d24e545fa5c823e17df2e9988bebf8554af4d223ab4e6303f4c85e0ce507dfe7ec4d275d28c1a48643b81ab31abead8f09ba590f0bd53b64bfd33c70e71429600b6cba522860ba25f4bbbb4e0	f	dhis2
\.


--
-- Data for Name: credentials_audit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credentials_audit (id, event, metadata, row_id, actor_id, inserted_at) FROM stdin;
fc8e53dc-bede-4f93-a7d6-db7cc2515515	created	{"after": null, "before": null}	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384	3476f7a9-e02f-4a3d-bc1f-ae3374a882ac	2023-07-25 06:22:07
7b07581b-00d8-4a21-8007-3c9acaba9c98	updated	{"after": {"body": "AQpBRVMuR0NNLlYxXqXLUtbd2cHwCe8yfLQ27MgjfnG4vvO+eQTTIWeKwCJgYaegVufulZt30buPX4Z8CdaHe3MiCcVRkvDujVzGd+V1F5wGl0HJUYVyJv2wv79+HC6xgpaMiTnV6Xax8xFBw7FCTpSPGImTImXrywo6451IYrESoT+E/7+2Mk/PboHKYcamhdIQZU3A+nr2"}, "before": {"body": "AQpBRVMuR0NNLlYx28Jb069yjyGt2nWqrqSEMosRyHfxDu62YWnVz6bFSZ1kSLAaHkPUHNO3oTta83Bd+LSvc2q1NGc8kq6fF/aV9lVH5ZHheeR3uvLJbCZ3aI3irQ/JLhKFGQCy8lbl6tqX286gCXRQJ5p7r1i1sbT7RfwGQRay/DlenP+xEJtOy1Q1"}}	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384	3476f7a9-e02f-4a3d-bc1f-ae3374a882ac	2023-07-26 05:53:37
\.


--
-- Data for Name: dataclips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataclips (id, body, type, inserted_at, updated_at, project_id) FROM stdin;
78f75edc-8704-4e66-ba72-287e2bc5707a	{"name": "Jane", "address": {"town": "Cape Town", "country": "South Africa", "street_address": "389 Main Road, Tokai"}, "surname": "Doe"}	http_request	2023-07-25 06:29:24.681524	2023-07-25 06:29:24.681524	87ea20f1-7d81-4959-bdba-279147713fb8
9e770dfb-c0f4-43d6-bccc-0643c6f2180e	{"data": {"status": "OK", "response": {"uid": "of85yxFyU1x", "klass": "org.hisp.dhis.dataelement.DataElement", "errorReports": [], "responseType": "ObjectReport"}, "httpStatus": "Created", "httpStatusCode": 201}, "references": [{"name": "Jane", "address": {"town": "Cape Town", "country": "South Africa", "street_address": "389 Main Road, Tokai"}, "surname": "Doe"}]}	run_result	2023-07-25 06:29:27.847671	2023-07-25 06:29:27.847671	87ea20f1-7d81-4959-bdba-279147713fb8
b986bc53-d08c-45d0-b967-84ca470529e9	{"name": "Jane", "address": {"town": "Cape Town", "country": "South Africa", "street_address": "389 Main Road, Tokai"}, "surname": "Doe"}	http_request	2023-07-25 06:30:08.237898	2023-07-25 06:30:08.237898	87ea20f1-7d81-4959-bdba-279147713fb8
b9f3e2b7-ae82-46a3-aa82-036a6a03a12b	{"ou": "Fol6EnJEekY", "value": 1800, "period": "202212", "dataElement": "KLAPbURUf70"}	http_request	2023-07-26 05:46:00.867132	2023-07-26 05:46:00.867132	87ea20f1-7d81-4959-bdba-279147713fb8
0dbeefd9-f2ed-4e13-bf4e-a7d44fa54d58	{"data": {"status": "OK", "response": {"uid": "DJjX70H7lQ1", "klass": "org.hisp.dhis.dataelement.DataElement", "errorReports": [], "responseType": "ObjectReport"}, "httpStatus": "Created", "httpStatusCode": 201}, "references": [{"ou": "Fol6EnJEekY", "value": 1800, "period": "202212", "dataElement": "KLAPbURUf70"}]}	run_result	2023-07-26 05:46:04.312836	2023-07-26 05:46:04.312836	87ea20f1-7d81-4959-bdba-279147713fb8
e67fadbe-1892-4fed-95e8-0771966a9eb0	{"ou": "Fol6EnJEekY", "value": 4080, "period": "202306", "dataElement": "KLAPbURUf70"}	http_request	2023-07-26 05:48:04.826163	2023-07-26 05:48:04.826163	87ea20f1-7d81-4959-bdba-279147713fb8
e17eb0f6-829d-4c88-99df-7c14d6f0b9fd	{"ou": "Fol6EnJEekY", "value": 4080, "period": "202306", "dataElement": "KLAPbURUf70"}	http_request	2023-07-26 05:49:21.112642	2023-07-26 05:49:21.112642	87ea20f1-7d81-4959-bdba-279147713fb8
43272d2a-e361-43fe-b603-ab67fa7f8a50	{"ou": "Fol6EnJEekY", "value": 4080, "period": "202306", "dataElement": "KLAPbURUf70"}	http_request	2023-07-26 05:49:32.167471	2023-07-26 05:49:32.167471	87ea20f1-7d81-4959-bdba-279147713fb8
4edeaf5f-02b0-491e-9e7d-80ad9a58cc74	{"ou": "Fol6EnJEekY", "value": 4080, "period": "202306", "dataElement": "KLAPbURUf70"}	http_request	2023-07-26 05:51:33.997042	2023-07-26 05:51:33.997042	87ea20f1-7d81-4959-bdba-279147713fb8
dd809311-24eb-45c5-8443-70782066bd44	{"ou": "Fol6EnJEekY", "value": 4080, "period": "202306", "dataElement": "KLAPbURUf70"}	http_request	2023-07-26 05:53:54.698016	2023-07-26 05:53:54.698016	87ea20f1-7d81-4959-bdba-279147713fb8
06ed4489-82ef-471b-b5a2-4af563392b4c	{"ou": "Fol6EnJEekY", "value": 4080, "period": "202306", "dataElement": "KLAPbURUf70"}	http_request	2023-07-26 05:56:53.403716	2023-07-26 05:56:53.403716	87ea20f1-7d81-4959-bdba-279147713fb8
ebf662f7-9ca5-4a63-82b1-56b23fad5ecc	{"data": {"status": "OK", "response": {"uid": "JlqsHhqMUVT", "klass": "org.hisp.dhis.dataelement.DataElement", "errorReports": [], "responseType": "ObjectReport"}, "httpStatus": "Created", "httpStatusCode": 201}, "references": [{"ou": "Fol6EnJEekY", "value": 4080, "period": "202306", "dataElement": "KLAPbURUf70"}]}	run_result	2023-07-26 05:56:55.722233	2023-07-26 05:56:55.722233	87ea20f1-7d81-4959-bdba-279147713fb8
4d736514-5a33-4381-bc50-52bdb73a4349	{"ou": "Fol6EnJEekY", "value": 4080, "period": "202306", "dataElement": "KLAPbURUf70"}	http_request	2023-07-26 07:58:49.70422	2023-07-26 07:58:49.70422	87ea20f1-7d81-4959-bdba-279147713fb8
c7af9ab3-bf59-4a19-956f-beb50572f1bc	{"body": "{\\n    \\"ou\\": \\"Fol6EnJEekY\\",\\n    \\"period\\": \\"202212\\",\\n    \\"dataElement\\": \\"KLAPbURUf70\\",\\n    \\"value\\": 1800\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "8e771573-08ac-4d78-9822-00f6281df46a", "content-length": "104", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c0b1b7fe2d4e25be1dfe62"}}	http_request	2023-07-26 09:07:25.267927	2023-07-26 09:07:25.267927	87ea20f1-7d81-4959-bdba-279147713fb8
e31a57a3-8428-4fc8-9184-c3be2aa43284	{"body": "{\\n    \\"ou\\": \\"Fol6EnJEekY\\",\\n    \\"period\\": \\"202212\\",\\n    \\"dataElement\\": \\"KLAPbURUf70\\",\\n    \\"value\\": 1800\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "da7a11d6-b8f5-4a3a-88f5-4c0dcece82f0", "content-length": "104", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c0b25afe2d4e25be1e008b"}}	http_request	2023-07-26 09:07:25.293714	2023-07-26 09:07:25.293714	87ea20f1-7d81-4959-bdba-279147713fb8
381fae4c-3492-4a50-b4b0-355fbb36342d	{"body": "{\\n    \\"ou\\": \\"Fol6EnJEekY\\",\\n    \\"period\\": \\"202306\\",\\n    \\"dataElement\\": \\"KLAPbURUf70\\",\\n    \\"value\\": 4080\\n}", "path": "/Patient-one", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "a690d46f-2aa6-451a-8c6b-d083f6e290c4", "content-length": "104", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c0d157fe2d4e25be1e5bcc"}}	http_request	2023-07-26 09:07:25.296152	2023-07-26 09:07:25.296152	87ea20f1-7d81-4959-bdba-279147713fb8
d9350252-0814-4d82-8a73-1d6cd92fae2a	{"body": "{\\n    \\"ou\\": \\"Fol6EnJEekY\\",\\n    \\"period\\": \\"202306\\",\\n    \\"dataElement\\": \\"KLAPbURUf70\\",\\n    \\"value\\": 8787\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "e8b0a8b8-dd3d-4a21-84d0-ad75fa81bb27", "content-length": "104", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c0d844fe2d4e25be1e71ad"}}	http_request	2023-07-26 09:07:25.296847	2023-07-26 09:07:25.296847	87ea20f1-7d81-4959-bdba-279147713fb8
a6e95482-b34c-4e44-a8af-e5cdce431233	{"body": "{\\n  \\"name\\": \\"Mahao\\",\\n  \\"surname\\": \\"Molise\\",\\n  \\"address\\": {\\n    \\"street_address\\": \\"389 Main Road, Tokai\\",\\n    \\"town\\": \\"Cape Town\\",\\n    \\"country\\": \\"South Africa\\"\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "07f56a34-66c3-4ec3-9ddc-bb224080a4d4", "content-length": "165", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64bff389a560268cf90ac8a9"}}	http_request	2023-07-26 09:07:25.309001	2023-07-26 09:07:25.309001	87ea20f1-7d81-4959-bdba-279147713fb8
246db237-4a7b-40e9-aa6f-6329e3205a93	{"body": "{\\n    \\"ou\\": \\"Fol6EnJEekY\\",\\n    \\"period\\": \\"202306\\",\\n    \\"dataElement\\": \\"KLAPbURUf70\\",\\n    \\"value\\": 8787\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "7e5cce25-74a0-4789-9c9a-0045cb659f65", "content-length": "104", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c0e25d02a9bbc9ecd48d00"}}	http_request	2023-07-26 09:07:41.90875	2023-07-26 09:07:41.90875	87ea20f1-7d81-4959-bdba-279147713fb8
968f9b3d-b816-4b78-840a-32be384931fe	{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}	http_request	2023-07-27 06:29:09.106426	2023-07-27 06:29:09.106426	87ea20f1-7d81-4959-bdba-279147713fb8
788e3ec2-6525-48e1-ab49-74c30d3a1372	{}	http_request	2023-07-27 07:15:04.860192	2023-07-27 07:15:04.860192	87ea20f1-7d81-4959-bdba-279147713fb8
fb222e36-ea28-403b-aa78-0424354d2582	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST"}	http_request	2023-07-27 07:15:40.032648	2023-07-27 07:15:40.032648	87ea20f1-7d81-4959-bdba-279147713fb8
4657f833-23d0-4d81-92ba-d60aee942b19	{"body": "{\\n    \\"ou\\": \\"Fol6EnJEekY\\",\\n    \\"period\\": \\"202306\\",\\n    \\"dataElement\\": \\"KLAPbURUf70\\",\\n    \\"value\\": 8932\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "d8614e57-dd86-45f3-b99e-fb02a7b54748", "content-length": "104", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c0e6e002a9bbc9ecd49e29"}}	http_request	2023-07-26 09:26:56.703922	2023-07-26 09:26:56.703922	87ea20f1-7d81-4959-bdba-279147713fb8
e4081bbc-e64f-44f7-8117-46b91ebed1be	{"body": "{\\n    \\"ou\\": \\"Fol6EnJEekY\\",\\n    \\"period\\": \\"202306\\",\\n    \\"dataElement\\": \\"KLAPbURUf70\\",\\n    \\"value\\": 8932\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "c28e2684-3625-4f50-8300-2e1e5abe4ebb", "content-length": "104", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c0e8b802a9bbc9ecd4a3d1"}}	http_request	2023-07-26 09:34:48.336912	2023-07-26 09:34:48.336912	87ea20f1-7d81-4959-bdba-279147713fb8
f96a8cea-c818-4e6d-bf37-777b9fd386d6	{"juneValue": 453, "dataElementId": "4647383", "organizationUnitId": "ye638299273646yeu"}	http_request	2023-07-27 06:18:05.414474	2023-07-27 06:18:05.414474	87ea20f1-7d81-4959-bdba-279147713fb8
23f855e1-770a-41f7-a33c-e85e102cf913	{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}	http_request	2023-07-27 06:27:08.453461	2023-07-27 06:27:08.453461	87ea20f1-7d81-4959-bdba-279147713fb8
c0c11afd-5975-4feb-9f96-8417035608e6	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "6f60168f-b149-4cff-91f5-f48509c1a19d", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2101902a9bbc9ecd77a3d"}}	http_request	2023-07-27 06:35:05.917188	2023-07-27 06:35:05.917188	87ea20f1-7d81-4959-bdba-279147713fb8
661cae58-607e-4c9d-9da1-9ea117915ca5	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9127e6a9-bee2-492d-8ace-0744090f4236", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2108102a9bbc9ecd77b67"}}	http_request	2023-07-27 06:36:49.15965	2023-07-27 06:36:49.15965	87ea20f1-7d81-4959-bdba-279147713fb8
111402fe-0f83-4665-8ff4-c8ffbd16e072	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "4c380942-bb0b-40b6-b671-29b0db9336f0", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2110402a9bbc9ecd77cd6"}}	http_request	2023-07-27 06:39:00.384716	2023-07-27 06:39:00.384716	87ea20f1-7d81-4959-bdba-279147713fb8
837e02bd-483f-48ce-adef-2d285f667606	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "24a67f85-250b-43c1-a076-429176f798e2", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c211e902a9bbc9ecd77fbb"}}	http_request	2023-07-27 06:42:49.999362	2023-07-27 06:42:49.999362	87ea20f1-7d81-4959-bdba-279147713fb8
15f9abfc-e10a-42b8-b658-65d92187e68c	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "5e744410-647e-49ec-a913-469cb317e287", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2122f02a9bbc9ecd78088"}}	http_request	2023-07-27 06:43:59.758807	2023-07-27 06:43:59.758807	87ea20f1-7d81-4959-bdba-279147713fb8
e8301efc-2c3d-4e82-bd0e-1df2fd5d56f4	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "1dd75180-5e35-4f76-847b-95b3d1f2b188", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2124e02a9bbc9ecd780e9"}}	http_request	2023-07-27 06:44:30.538877	2023-07-27 06:44:30.538877	87ea20f1-7d81-4959-bdba-279147713fb8
1281f619-965e-46c9-bbea-fd9f152687e7	{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}	http_request	2023-07-27 06:46:04.225198	2023-07-27 06:46:04.225198	87ea20f1-7d81-4959-bdba-279147713fb8
25545201-992f-4163-b937-635918c2bb97	{"body": "{\\n  \\"name\\": \\"Mahao\\",\\n  \\"surname\\": \\"Molise\\",\\n  \\"address\\": {\\n    \\"street_address\\": \\"389 Main Road, Tokai\\",\\n    \\"town\\": \\"Cape Town\\",\\n    \\"country\\": \\"South Africa\\"\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "348c0af0-58a8-4631-930b-d10d1a8448db", "content-length": "165", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c0eb5b02a9bbc9ecd4ab19"}}	http_request	2023-07-26 09:46:03.248621	2023-07-26 09:46:03.248621	87ea20f1-7d81-4959-bdba-279147713fb8
0112f43d-47af-4914-8d47-e32a26bb751e	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "875bf02c-9dfc-4ec6-bbf7-e0c3a853261f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2115202a9bbc9ecd77dbc"}}	http_request	2023-07-27 06:40:18.156004	2023-07-27 06:40:18.156004	87ea20f1-7d81-4959-bdba-279147713fb8
6a78b60f-fc3d-43b4-be6d-334a3de33069	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "a3e985f9-732d-4337-9c21-16082047fe31", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2115d02a9bbc9ecd77dea"}}	http_request	2023-07-27 06:40:29.245209	2023-07-27 06:40:29.245209	87ea20f1-7d81-4959-bdba-279147713fb8
ebd700e5-3d10-42ef-8bfd-1b2431311cff	{"data": {"status": "OK", "message": "Import was successful.", "response": {"status": "SUCCESS", "conflicts": [], "description": "Import process completed successfully", "importCount": {"deleted": 0, "ignored": 0, "updated": 1, "imported": 0}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": false, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "dataSetComplete": "false"}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}]}	run_result	2023-07-27 06:46:05.628925	2023-07-27 06:46:05.628925	87ea20f1-7d81-4959-bdba-279147713fb8
e46fec2d-63c1-44b4-a879-2b44ab16ffd0	{"body": "{\\n  \\"name\\": \\"Mahao\\",\\n  \\"surname\\": \\"Molise\\",\\n  \\"address\\": {\\n    \\"street_address\\": \\"389 Main Road, Tokai\\",\\n    \\"town\\": \\"Cape Town\\",\\n    \\"country\\": \\"South Africa\\"\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "45a15937-8a93-4fd4-8ae9-60f8f8c9cc09", "content-length": "165", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c136c502a9bbc9ecd5362c"}}	http_request	2023-07-26 15:07:50.012284	2023-07-26 15:07:50.012284	87ea20f1-7d81-4959-bdba-279147713fb8
9f85cc9b-e0e4-49c9-8542-86c72ea9cfe6	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "011a1e6c-2941-46a7-be97-e912a3b1e349", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c211a402a9bbc9ecd77eed"}}}	run_result	2023-07-27 06:41:41.292329	2023-07-27 06:41:41.292329	87ea20f1-7d81-4959-bdba-279147713fb8
278fdf91-cef2-41b6-a2db-04848b813787	{"body": "{\\n  \\"name\\": \\"Mahao\\",\\n  \\"surname\\": \\"Molise\\",\\n  \\"address\\": {\\n    \\"street_address\\": \\"389 Main Road, Tokai\\",\\n    \\"town\\": \\"Cape Town\\",\\n    \\"country\\": \\"South Africa\\"\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "50414381-2c9d-44f7-b5b9-089f17cea68c", "content-length": "165", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c1384002a9bbc9ecd53a28"}}	http_request	2023-07-26 15:14:08.446843	2023-07-26 15:14:08.446843	87ea20f1-7d81-4959-bdba-279147713fb8
32d51554-c05b-4d67-8d1e-0690ef2c264b	{"juneValue": 453, "dataElementId": "4647383", "organizationUnitId": "ye638299273646yeu"}	http_request	2023-07-27 06:18:46.707093	2023-07-27 06:18:46.707093	87ea20f1-7d81-4959-bdba-279147713fb8
63d31d49-944d-4629-8d74-3fc71b2d33b4	{"body": "{\\n  \\"name\\": \\"Mahao\\",\\n  \\"surname\\": \\"Molise\\",\\n  \\"address\\": {\\n    \\"street_address\\": \\"389 Main Road, Tokai\\",\\n    \\"town\\": \\"Cape Town\\",\\n    \\"country\\": \\"South Africa\\"\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "86b5609d-959f-4b2c-a28b-5f29bf344235", "content-length": "165", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c20f2a02a9bbc9ecd77794"}}	http_request	2023-07-27 06:31:07.021267	2023-07-27 06:31:07.021267	87ea20f1-7d81-4959-bdba-279147713fb8
5858e087-3514-4986-98b9-74bd2bf3e73d	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "4c380942-bb0b-40b6-b671-29b0db9336f0", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2110402a9bbc9ecd77cd6"}}, "references": []}	run_result	2023-07-27 06:39:01.66962	2023-07-27 06:39:01.66962	87ea20f1-7d81-4959-bdba-279147713fb8
99605d45-04b4-447d-84d8-e71267e6d6bb	{"body": "{\\n  \\"name\\": \\"Mahao\\",\\n  \\"surname\\": \\"Molise\\",\\n  \\"address\\": {\\n    \\"street_address\\": \\"389 Main Road, Tokai\\",\\n    \\"town\\": \\"Cape Town\\",\\n    \\"country\\": \\"South Africa\\"\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "ea6ee6a4-ef6a-449b-b684-c4570972cd52", "content-length": "165", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c1391b02a9bbc9ecd53c8b"}}	http_request	2023-07-26 15:17:47.555435	2023-07-26 15:17:47.555435	87ea20f1-7d81-4959-bdba-279147713fb8
72ef3078-6fd5-4e37-91d3-97ddc2069dab	{"juneValue": 453, "dataElementId": "4647383", "organizationUnitId": "ye638299273646yeu"}	http_request	2023-07-27 06:18:13.843722	2023-07-27 06:18:13.843722	87ea20f1-7d81-4959-bdba-279147713fb8
1d58ddbe-d555-426b-8e3d-9009fd041b9d	{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}	http_request	2023-07-27 06:28:04.951456	2023-07-27 06:28:04.951456	87ea20f1-7d81-4959-bdba-279147713fb8
0ae8cf42-f074-4a77-b3f6-ccd6b7056026	{"data": {"status": "OK", "message": "Import was successful.", "response": {"status": "SUCCESS", "conflicts": [], "description": "Import process completed successfully", "importCount": {"deleted": 0, "ignored": 0, "updated": 0, "imported": 1}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": false, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "dataSetComplete": "false"}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}]}	run_result	2023-07-27 06:29:10.589627	2023-07-27 06:29:10.589627	87ea20f1-7d81-4959-bdba-279147713fb8
fc97f298-cecd-48e3-a61e-647409de18b4	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "52596842-ccff-4f59-b5f3-8de9236752d8", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2117002a9bbc9ecd77e3b"}}	http_request	2023-07-27 06:40:48.028825	2023-07-27 06:40:48.028825	87ea20f1-7d81-4959-bdba-279147713fb8
ab157d1f-4488-4e3e-8019-5cd77423c4fd	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "84d669ac-4ede-463b-b0f5-7e70bf06eb7c", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2118002a9bbc9ecd77e7b"}}	http_request	2023-07-27 06:41:04.903889	2023-07-27 06:41:04.903889	87ea20f1-7d81-4959-bdba-279147713fb8
56831b4c-4cd6-4381-ac4a-93dd34904ee6	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "011a1e6c-2941-46a7-be97-e912a3b1e349", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c211a402a9bbc9ecd77eed"}}	http_request	2023-07-27 06:41:40.266678	2023-07-27 06:41:40.266678	87ea20f1-7d81-4959-bdba-279147713fb8
97a4fce1-faae-471e-acd7-9b60fd07d53c	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "232954a7-bf75-400f-99f5-a1a5e9abef35", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c20f6502a9bbc9ecd77848"}}	http_request	2023-07-27 06:32:05.516731	2023-07-27 06:32:05.516731	87ea20f1-7d81-4959-bdba-279147713fb8
c3cfa184-f7e4-47bc-a3c0-4128d779abde	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9127e6a9-bee2-492d-8ace-0744090f4236", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2108102a9bbc9ecd77b67"}}, "references": []}	run_result	2023-07-27 06:36:50.40195	2023-07-27 06:36:50.40195	87ea20f1-7d81-4959-bdba-279147713fb8
5bccbdeb-5ac6-487b-af79-5479b64110a9	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "5e744410-647e-49ec-a913-469cb317e287", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2122f02a9bbc9ecd78088"}}}	run_result	2023-07-27 06:44:00.757336	2023-07-27 06:44:00.757336	87ea20f1-7d81-4959-bdba-279147713fb8
cad9851c-c7fe-488f-afc9-2b1b78f71f83	{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}	http_request	2023-07-27 06:47:07.27935	2023-07-27 06:47:07.27935	87ea20f1-7d81-4959-bdba-279147713fb8
98b338af-605d-4773-84fb-76a79580c6e8	{"data": {"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}}	run_result	2023-07-27 06:47:08.284151	2023-07-27 06:47:08.284151	87ea20f1-7d81-4959-bdba-279147713fb8
e7f80ab2-5de4-4492-9855-ec7dd7203aea	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "c12dc8b0-2b37-4b49-8d19-5fe6c1eb9d06", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2130602a9bbc9ecd782f3"}}	http_request	2023-07-27 06:47:34.543528	2023-07-27 06:47:34.543528	87ea20f1-7d81-4959-bdba-279147713fb8
bbc387ef-e036-4a1f-b669-aaffad714992	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "c12dc8b0-2b37-4b49-8d19-5fe6c1eb9d06", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2130602a9bbc9ecd782f3"}}}	run_result	2023-07-27 06:47:35.631843	2023-07-27 06:47:35.631843	87ea20f1-7d81-4959-bdba-279147713fb8
78294e48-1d12-4306-87a9-20c077476fbb	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "4dc1340b-9b17-434f-a71b-b4b23377b8a0", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2132a02a9bbc9ecd78365"}}	http_request	2023-07-27 06:48:10.8229	2023-07-27 06:48:10.8229	87ea20f1-7d81-4959-bdba-279147713fb8
422f0483-3183-45fa-ac6f-b03cb4429545	{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}	http_request	2023-07-27 06:48:28.451023	2023-07-27 06:48:28.451023	87ea20f1-7d81-4959-bdba-279147713fb8
61d9d605-ff0b-4bb0-a015-fe8d3d2a006a	{"data": {"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}}	run_result	2023-07-27 06:48:29.452093	2023-07-27 06:48:29.452093	87ea20f1-7d81-4959-bdba-279147713fb8
d3242a13-2739-47bc-9a9d-f81d62e0083d	{"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}	http_request	2023-07-27 06:50:00.606278	2023-07-27 06:50:00.606278	87ea20f1-7d81-4959-bdba-279147713fb8
04d6a1ec-de01-4e94-92a8-48ea01ee1438	{"data": {"juneValue": 453, "dataElementId": "katOVrpL1eJ", "organizationUnitId": "BnVfkK2iFFH"}}	run_result	2023-07-27 06:50:01.630611	2023-07-27 06:50:01.630611	87ea20f1-7d81-4959-bdba-279147713fb8
2f786c50-b7f4-40b1-82b3-a76e91b3f4ac	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fdc91e26-fcbb-4662-a13a-cc630d60307f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c213ad02a9bbc9ecd784d3"}}	http_request	2023-07-27 06:50:21.531645	2023-07-27 06:50:21.531645	87ea20f1-7d81-4959-bdba-279147713fb8
f4f57b0c-0a7e-4297-ab5a-79ae08143807	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fdc91e26-fcbb-4662-a13a-cc630d60307f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c213ad02a9bbc9ecd784d3"}}	http_request	2023-07-27 06:51:28.248238	2023-07-27 06:51:28.248238	87ea20f1-7d81-4959-bdba-279147713fb8
f44ea5b5-a40d-4e3a-8766-46648b221154	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fdc91e26-fcbb-4662-a13a-cc630d60307f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c213ad02a9bbc9ecd784d3"}}	http_request	2023-07-27 06:54:53.415779	2023-07-27 06:54:53.415779	87ea20f1-7d81-4959-bdba-279147713fb8
9499a0c0-00e1-45fa-928c-475288dd8d30	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fdc91e26-fcbb-4662-a13a-cc630d60307f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c213ad02a9bbc9ecd784d3"}}	http_request	2023-07-27 06:57:03.12504	2023-07-27 06:57:03.12504	87ea20f1-7d81-4959-bdba-279147713fb8
71a37a73-4c59-42fc-9224-a53ca4fa967b	{}	http_request	2023-07-27 07:14:33.49445	2023-07-27 07:14:33.49445	87ea20f1-7d81-4959-bdba-279147713fb8
4b298224-cd02-45e1-84c8-5bef751f322f	{"data": {}}	run_result	2023-07-27 07:14:34.527749	2023-07-27 07:14:34.527749	87ea20f1-7d81-4959-bdba-279147713fb8
3ac52328-b3d8-482a-a3f8-cef102b98aea	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fdc91e26-fcbb-4662-a13a-cc630d60307f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c213ad02a9bbc9ecd784d3"}}	http_request	2023-07-27 06:58:40.613896	2023-07-27 06:58:40.613896	87ea20f1-7d81-4959-bdba-279147713fb8
843a372f-7368-4e0c-802d-dcdd0da5d66c	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fdc91e26-fcbb-4662-a13a-cc630d60307f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c213ad02a9bbc9ecd784d3"}}}	run_result	2023-07-27 06:58:41.644341	2023-07-27 06:58:41.644341	87ea20f1-7d81-4959-bdba-279147713fb8
faf77639-afef-4c77-899e-d6903bcbd2d7	{"data": {}}	run_result	2023-07-27 07:15:05.85258	2023-07-27 07:15:05.85258	87ea20f1-7d81-4959-bdba-279147713fb8
4fe82e58-1836-41d7-becd-adad581bab31	{"path": "/Patient", "method": "POST"}	http_request	2023-07-27 07:16:17.375746	2023-07-27 07:16:17.375746	87ea20f1-7d81-4959-bdba-279147713fb8
b4a2cd35-30f3-4069-a51e-445476d11016	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}}	run_result	2023-07-27 07:27:21.080958	2023-07-27 07:27:21.080958	87ea20f1-7d81-4959-bdba-279147713fb8
ea8c1518-3f21-4f59-a3db-a1853bbc40eb	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}}	run_result	2023-07-27 07:28:11.083747	2023-07-27 07:28:11.083747	87ea20f1-7d81-4959-bdba-279147713fb8
62341c84-c6ed-4fbc-879c-8b1371ef84b0	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9127e6a9-bee2-492d-8ace-0744090f4236", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2108102a9bbc9ecd77b67"}}	http_request	2023-07-27 07:30:21.597431	2023-07-27 07:30:21.597431	87ea20f1-7d81-4959-bdba-279147713fb8
677766cb-edcb-4aa7-880e-4d3cac3662f8	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "213c217f-9847-4c76-b6cf-c38d8b7533d0", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21dfb02a9bbc9ecd7a0a9"}}	http_request	2023-07-27 07:34:19.190831	2023-07-27 07:34:19.190831	87ea20f1-7d81-4959-bdba-279147713fb8
79718ba4-be63-4b29-95e2-82bb11d3ec26	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fd8a805b-6992-4d6a-9355-08456e6a20a4", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c220f702a9bbc9ecd7a8ec"}}}	run_result	2023-07-27 07:47:04.616834	2023-07-27 07:47:04.616834	87ea20f1-7d81-4959-bdba-279147713fb8
f2f3aede-5f82-4648-a417-b1dbbc12fae6	{"path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fdc91e26-fcbb-4662-a13a-cc630d60307f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c213ad02a9bbc9ecd784d3"}}	http_request	2023-07-27 07:15:58.175096	2023-07-27 07:15:58.175096	87ea20f1-7d81-4959-bdba-279147713fb8
a7beabd5-643f-42b7-9fb6-58e2e40e45e9	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}}	run_result	2023-07-27 07:18:57.994912	2023-07-27 07:18:57.994912	87ea20f1-7d81-4959-bdba-279147713fb8
6df209ce-7a4c-4611-a9b6-c6528f77f19d	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST"}}	run_result	2023-07-27 07:25:44.143461	2023-07-27 07:25:44.143461	87ea20f1-7d81-4959-bdba-279147713fb8
d95bbcab-f155-41ed-abcb-d10dc54155b1	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}	http_request	2023-07-27 07:27:18.519543	2023-07-27 07:27:18.519543	87ea20f1-7d81-4959-bdba-279147713fb8
e488206a-ff3e-441a-845a-13a5aafcb7da	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "bb722dee-b3d7-457a-9883-b5b9cbe26789", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21f0b02a9bbc9ecd7a3a9"}}	http_request	2023-07-27 07:38:51.226079	2023-07-27 07:38:51.226079	87ea20f1-7d81-4959-bdba-279147713fb8
6f3fe41f-d35a-4c62-8263-c17be96af394	{"data": {"path": "/Patient", "method": "POST"}}	run_result	2023-07-27 07:16:18.393321	2023-07-27 07:16:18.393321	87ea20f1-7d81-4959-bdba-279147713fb8
ad0c2f39-4df0-4ab8-a372-870eec8d5115	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST"}	http_request	2023-07-27 07:19:37.065226	2023-07-27 07:19:37.065226	87ea20f1-7d81-4959-bdba-279147713fb8
7ed4af85-7e73-4862-9a51-cb90e91ab804	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "971ede86-5772-48f4-ba07-f22538e22768", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21d3c02a9bbc9ecd79e81"}}}	run_result	2023-07-27 07:31:09.060455	2023-07-27 07:31:09.060455	87ea20f1-7d81-4959-bdba-279147713fb8
0eddd5e2-6879-45d8-ae8f-30d05208063c	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "a4d8e851-ee52-488b-aa39-2b920478c15f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21eed02a9bbc9ecd7a340"}}	http_request	2023-07-27 07:38:21.429645	2023-07-27 07:38:21.429645	87ea20f1-7d81-4959-bdba-279147713fb8
1261f8ef-2969-4f3b-8a2b-7a75ad7b6f49	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}	http_request	2023-07-27 07:18:56.972328	2023-07-27 07:18:56.972328	87ea20f1-7d81-4959-bdba-279147713fb8
4cde9edf-64a3-462b-968e-f95a5c4e1421	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST"}	http_request	2023-07-27 07:25:43.149374	2023-07-27 07:25:43.149374	87ea20f1-7d81-4959-bdba-279147713fb8
9f90f92b-4fb0-44e5-9525-7eb7fd02c745	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}}	run_result	2023-07-27 07:26:58.373051	2023-07-27 07:26:58.373051	87ea20f1-7d81-4959-bdba-279147713fb8
124c9a6c-4597-459c-8b66-bf7f427e1efb	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "method": "POST"}}	run_result	2023-07-27 07:28:40.000692	2023-07-27 07:28:40.000692	87ea20f1-7d81-4959-bdba-279147713fb8
7397ea77-b144-431a-93cd-04a662f084ae	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST"}	http_request	2023-07-27 07:28:56.345363	2023-07-27 07:28:56.345363	87ea20f1-7d81-4959-bdba-279147713fb8
7ef76446-c1c7-4c36-81cf-1747157b3ce2	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "db2d0034-e2a2-48d4-b9d9-5164046308b2", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21d1f02a9bbc9ecd79e1e"}}}	run_result	2023-07-27 07:30:40.140118	2023-07-27 07:30:40.140118	87ea20f1-7d81-4959-bdba-279147713fb8
43ca4f8b-7530-4279-aaf8-b6df3a184965	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "2513b540-fbd7-4246-a7de-3ee12369c27f", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21ddd02a9bbc9ecd7a049"}}	http_request	2023-07-27 07:33:49.172079	2023-07-27 07:33:49.172079	87ea20f1-7d81-4959-bdba-279147713fb8
46036534-820d-4570-acfe-7c72654f1c84	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST"}	http_request	2023-07-27 07:25:57.07818	2023-07-27 07:25:57.07818	87ea20f1-7d81-4959-bdba-279147713fb8
f5732cb8-ac08-485b-938d-862c865bd04d	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}}	run_result	2023-07-27 07:27:19.544606	2023-07-27 07:27:19.544606	87ea20f1-7d81-4959-bdba-279147713fb8
c3c0ac32-57be-4403-9870-6f6132c51431	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "method": "POST"}	http_request	2023-07-27 07:28:38.961494	2023-07-27 07:28:38.961494	87ea20f1-7d81-4959-bdba-279147713fb8
16b6f3df-e115-41a3-b855-3e557a902ac4	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST"}}	run_result	2023-07-27 07:28:57.345157	2023-07-27 07:28:57.345157	87ea20f1-7d81-4959-bdba-279147713fb8
5b1380ec-c18f-4787-9ce8-d19ea4ec1e4c	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9127e6a9-bee2-492d-8ace-0744090f4236", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2108102a9bbc9ecd77b67"}}}	run_result	2023-07-27 07:30:22.653847	2023-07-27 07:30:22.653847	87ea20f1-7d81-4959-bdba-279147713fb8
f43fd26f-3788-4384-844c-684882b9e930	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "db2d0034-e2a2-48d4-b9d9-5164046308b2", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21d1f02a9bbc9ecd79e1e"}}	http_request	2023-07-27 07:30:39.139498	2023-07-27 07:30:39.139498	87ea20f1-7d81-4959-bdba-279147713fb8
7ce59dd0-2126-4f99-9300-9ec81799c099	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "bb722dee-b3d7-457a-9883-b5b9cbe26789", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21f0b02a9bbc9ecd7a3a9"}}}	run_result	2023-07-27 07:38:52.262037	2023-07-27 07:38:52.262037	87ea20f1-7d81-4959-bdba-279147713fb8
597ce2d2-b80c-4c38-92de-89bc7ca4739b	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}", "path": "/Patient", "method": "POST"}}	run_result	2023-07-27 07:25:58.063868	2023-07-27 07:25:58.063868	87ea20f1-7d81-4959-bdba-279147713fb8
627f535f-58b8-4ef4-92f3-b2e3fc48ff73	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}	http_request	2023-07-27 07:26:57.356679	2023-07-27 07:26:57.356679	87ea20f1-7d81-4959-bdba-279147713fb8
f7d23a77-8e7c-42f8-941d-b42c57820b9a	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}	http_request	2023-07-27 07:28:10.040546	2023-07-27 07:28:10.040546	87ea20f1-7d81-4959-bdba-279147713fb8
182320ba-34ab-445e-b431-73e7ee0c1d1e	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "971ede86-5772-48f4-ba07-f22538e22768", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21d3c02a9bbc9ecd79e81"}}	http_request	2023-07-27 07:31:08.0579	2023-07-27 07:31:08.0579	87ea20f1-7d81-4959-bdba-279147713fb8
ecdf414f-ce82-4f16-8b7e-3db130c3c060	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fd8a805b-6992-4d6a-9355-08456e6a20a4", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c220f702a9bbc9ecd7a8ec"}}	http_request	2023-07-27 07:47:03.619965	2023-07-27 07:47:03.619965	87ea20f1-7d81-4959-bdba-279147713fb8
ab8a90f7-354d-4954-a28f-8941ff01be1c	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}	http_request	2023-07-27 07:27:20.069425	2023-07-27 07:27:20.069425	87ea20f1-7d81-4959-bdba-279147713fb8
62d66898-70e2-4434-a50c-51bffc9fad87	{"data": {"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "213c217f-9847-4c76-b6cf-c38d8b7533d0", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c21dfb02a9bbc9ecd7a0a9"}}}	run_result	2023-07-27 07:34:20.241706	2023-07-27 07:34:20.241706	87ea20f1-7d81-4959-bdba-279147713fb8
ab3d146b-3f6d-4848-ab15-bdd78564ebe7	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 400\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "31672a0a-82ad-42b4-91b8-4d11133eea33", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2213f02a9bbc9ecd7a9bb"}}	http_request	2023-07-27 07:48:15.870402	2023-07-27 07:48:15.870402	87ea20f1-7d81-4959-bdba-279147713fb8
9b3779e6-16ef-4205-89ef-7ffc63033e8d	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 400\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "3c40b113-3000-4245-ba44-b7988f3d7daf", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2217502a9bbc9ecd7aa5e"}}	http_request	2023-07-27 07:49:09.463375	2023-07-27 07:49:09.463375	87ea20f1-7d81-4959-bdba-279147713fb8
d446ff6f-28a2-4286-aa3c-1ed5a0b027d5	{"data": {"status": "OK", "message": "Import was successful.", "response": {"status": "SUCCESS", "conflicts": [], "description": "Import process completed successfully", "importCount": {"deleted": 0, "ignored": 0, "updated": 1, "imported": 0}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": false, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "dataSetComplete": "false"}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 400\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "3c40b113-3000-4245-ba44-b7988f3d7daf", "content-length": "101", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2217502a9bbc9ecd7aa5e"}}]}	run_result	2023-07-27 07:49:10.937459	2023-07-27 07:49:10.937459	87ea20f1-7d81-4959-bdba-279147713fb8
f52f7b3c-73cb-4b78-84c2-365f90567525	{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 40000\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "15e127c8-3717-4a51-90e6-63e4fccb7147", "content-length": "103", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2220702a9bbc9ecd7abf6"}}	http_request	2023-07-27 07:51:35.302836	2023-07-27 07:51:35.302836	87ea20f1-7d81-4959-bdba-279147713fb8
99dada66-0667-4bce-b3c4-5b34c590657b	{"data": {"status": "OK", "message": "Import was successful.", "response": {"status": "SUCCESS", "conflicts": [], "description": "Import process completed successfully", "importCount": {"deleted": 0, "ignored": 0, "updated": 1, "imported": 0}, "responseType": "ImportSummary", "importOptions": {"async": false, "force": false, "dryRun": false, "sharing": false, "idSchemes": {}, "mergeMode": "REPLACE", "skipAudit": false, "skipCache": false, "reportMode": "FULL", "strictPeriods": false, "importStrategy": "CREATE_AND_UPDATE", "mergeDataValues": false, "skipLastUpdated": false, "firstRowIsHeader": true, "skipExistingCheck": false, "skipNotifications": false, "strictDataElements": false, "datasetAllowsPeriods": false, "ignoreEmptyCollection": false, "skipPatternValidation": false, "strictOrganisationUnits": false, "requireCategoryOptionCombo": false, "strictCategoryOptionCombos": false, "requireAttributeOptionCombo": false, "strictAttributeOptionCombos": false}, "dataSetComplete": "false"}, "httpStatus": "OK", "httpStatusCode": 200}, "references": [{"body": "{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 40000\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "15e127c8-3717-4a51-90e6-63e4fccb7147", "content-length": "103", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2220702a9bbc9ecd7abf6"}}]}	run_result	2023-07-27 07:51:36.764174	2023-07-27 07:51:36.764174	87ea20f1-7d81-4959-bdba-279147713fb8
50ab367f-e516-4660-9a49-e990a857055f	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "3832b7bf-9596-49eb-832b-d39a609708ac", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c225e302a9bbc9ecd7b65f"}}	http_request	2023-07-27 08:08:03.481251	2023-07-27 08:08:03.481251	87ea20f1-7d81-4959-bdba-279147713fb8
abb0bff1-8c35-4245-8795-dd7ce3064f85	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "921bcf1a-0156-431d-9fa5-9888930fd05e", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c226e602a9bbc9ecd7b921"}}	http_request	2023-07-27 08:12:22.560784	2023-07-27 08:12:22.560784	87ea20f1-7d81-4959-bdba-279147713fb8
117101fa-ab8c-4cc2-8d39-0b9d91940db0	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "408dd607-baa6-43b7-b573-ee9c7b9515e5", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22b4802a9bbc9ecd7c5a7"}}}	run_result	2023-07-27 08:31:05.850263	2023-07-27 08:31:05.850263	87ea20f1-7d81-4959-bdba-279147713fb8
ed99ad91-c235-4b26-9cbb-dcea146d1f57	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "16866b93-3a42-47df-bac5-50560dce446a", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22b6f02a9bbc9ecd7c629"}}}	run_result	2023-07-27 08:31:44.663568	2023-07-27 08:31:44.663568	87ea20f1-7d81-4959-bdba-279147713fb8
79bc61d7-e699-4959-9a31-12d8680e448b	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9be3eb21-f00e-420f-8e7f-1d77280b621b", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2272502a9bbc9ecd7b9dc"}}	http_request	2023-07-27 08:13:25.029246	2023-07-27 08:13:25.029246	87ea20f1-7d81-4959-bdba-279147713fb8
8e78c335-4d8e-41c1-a534-dc3312c019af	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "e02a174c-7deb-4265-9fe5-bbe733bb7eb6", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2277502a9bbc9ecd7bacd"}}	http_request	2023-07-27 08:14:45.593473	2023-07-27 08:14:45.593473	87ea20f1-7d81-4959-bdba-279147713fb8
84cbe25b-fba6-4475-8372-06ccda9fb247	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "e02a174c-7deb-4265-9fe5-bbe733bb7eb6", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2277502a9bbc9ecd7bacd"}}}	run_result	2023-07-27 08:14:46.57443	2023-07-27 08:14:46.57443	87ea20f1-7d81-4959-bdba-279147713fb8
1296f035-ac2a-46e8-8227-1189603d077a	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "1b1f683f-3a51-4410-82a6-1611c9472952", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2279b02a9bbc9ecd7bb40"}}	http_request	2023-07-27 08:15:23.043447	2023-07-27 08:15:23.043447	87ea20f1-7d81-4959-bdba-279147713fb8
4d6e9237-8519-4226-8a65-435e933fc8d8	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fa10956e-0855-46d9-b404-66fa42fc9fa2", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2284d02a9bbc9ecd7bd4a"}}}	run_result	2023-07-27 08:18:22.906391	2023-07-27 08:18:22.906391	87ea20f1-7d81-4959-bdba-279147713fb8
93254576-e038-4872-8289-74d6dcff2f6f	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9434fe44-3b99-463c-9891-8fef6f90ca4c", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c229ce02a9bbc9ecd7c18c"}}}	run_result	2023-07-27 08:24:47.42117	2023-07-27 08:24:47.42117	87ea20f1-7d81-4959-bdba-279147713fb8
112b53b4-eff6-4bd0-9fd6-6cfff76edc6c	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "77915e4f-a247-44cc-901d-d43bcc07bcfc", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22a4602a9bbc9ecd7c2e1"}}	http_request	2023-07-27 08:26:46.668179	2023-07-27 08:26:46.668179	87ea20f1-7d81-4959-bdba-279147713fb8
ee7af87d-a24a-4282-a63d-b31efc420805	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "38e145fb-7776-46bf-8205-2452662834f8", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2282202a9bbc9ecd7bcb6"}}	http_request	2023-07-27 08:17:38.088083	2023-07-27 08:17:38.088083	87ea20f1-7d81-4959-bdba-279147713fb8
a87add1a-422b-44d7-90bd-a31949386114	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "38e145fb-7776-46bf-8205-2452662834f8", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2282202a9bbc9ecd7bcb6"}}}	run_result	2023-07-27 08:17:39.130339	2023-07-27 08:17:39.130339	87ea20f1-7d81-4959-bdba-279147713fb8
7aaf0128-e73e-4b89-9b0e-60e31c47ccad	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "fa10956e-0855-46d9-b404-66fa42fc9fa2", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2284d02a9bbc9ecd7bd4a"}}	http_request	2023-07-27 08:18:21.916322	2023-07-27 08:18:21.916322	87ea20f1-7d81-4959-bdba-279147713fb8
5686b70e-5dca-46f5-af6f-f5d62d68554b	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "3f87ad91-35a1-4ad2-bde7-c18cc6611fc8", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2292902a9bbc9ecd7bfa2"}}	http_request	2023-07-27 08:22:01.414608	2023-07-27 08:22:01.414608	87ea20f1-7d81-4959-bdba-279147713fb8
86f00d0e-5a27-4c8e-9102-d40ad934b138	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9434fe44-3b99-463c-9891-8fef6f90ca4c", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c229ce02a9bbc9ecd7c18c"}}	http_request	2023-07-27 08:24:46.394247	2023-07-27 08:24:46.394247	87ea20f1-7d81-4959-bdba-279147713fb8
fd9b7303-05cd-42a4-8fab-c9c0697646d3	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "408dd607-baa6-43b7-b573-ee9c7b9515e5", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22b4802a9bbc9ecd7c5a7"}}	http_request	2023-07-27 08:31:04.840177	2023-07-27 08:31:04.840177	87ea20f1-7d81-4959-bdba-279147713fb8
6333afdc-ed9f-410e-947d-78eff17cd202	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "16866b93-3a42-47df-bac5-50560dce446a", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22b6f02a9bbc9ecd7c629"}}	http_request	2023-07-27 08:31:43.649798	2023-07-27 08:31:43.649798	87ea20f1-7d81-4959-bdba-279147713fb8
73258b70-d859-4076-9e27-720dd66e0f97	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "09e21ec6-4fbb-497e-afe9-e9817c29afa6", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c229b602a9bbc9ecd7c134"}}	http_request	2023-07-27 08:24:22.873803	2023-07-27 08:24:22.873803	87ea20f1-7d81-4959-bdba-279147713fb8
0238eb16-6646-4617-8c0c-4465d4d220e6	{"body": "{\\n  \\"resourceType\\": \\"Observation\\",\\n  \\"status\\": \\"final\\",\\n  \\"code\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://loinc.org\\",\\n        \\"code\\": \\"38372-9\\",\\n        \\"display\\": \\"HIV-1 and HIV-2 Ab SerPl Ql\\"\\n      }\\n    ],\\n    \\"text\\": \\"HIV Test Result\\"\\n  },\\n  \\"subject\\": {\\n    \\"reference\\": \\"Patient/example\\"\\n  },\\n  \\"valueCodeableConcept\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://snomed.info/sct\\",\\n        \\"code\\": \\"165889005\\",\\n        \\"display\\": \\"Positive\\"\\n      }\\n    ]\\n  }\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "37dd94b3-a976-4ca1-8c8a-d51852f3f0d9", "content-length": "486", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2306c02a9bbc9ecd7d3c3"}}	http_request	2023-07-27 08:53:00.605956	2023-07-27 08:53:00.605956	87ea20f1-7d81-4959-bdba-279147713fb8
fdf727bc-42db-42ac-8fdb-7f3b73e85ff5	{"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9eb28867-c2b9-41d5-8e3b-9da5e055c805", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22bff02a9bbc9ecd7c7b2"}}	http_request	2023-07-27 08:34:07.546943	2023-07-27 08:34:07.546943	87ea20f1-7d81-4959-bdba-279147713fb8
7dd1fced-6b00-4e02-9b82-577ae7e2794d	{"data": {"body": "{\\n  \\"resourceType\\": \\"Patient\\",\\n  \\"id\\": \\"example\\",\\n  \\"identifier\\": [\\n    {\\n      \\"system\\": \\"http://example.com/patient-ids\\",\\n      \\"value\\": \\"12345\\"\\n    }\\n  ],\\n  \\"name\\": [\\n    {\\n      \\"use\\": \\"official\\",\\n      \\"family\\": \\"Smith\\",\\n      \\"given\\": [\\"John\\"]\\n    }\\n  ],\\n  \\"gender\\": \\"male\\",\\n  \\"birthDate\\": \\"1980-01-15\\",\\n  \\"address\\": [\\n    {\\n      \\"use\\": \\"home\\",\\n      \\"line\\": [\\"123 Main Street\\"],\\n      \\"city\\": \\"Anytown\\",\\n      \\"state\\": \\"NY\\",\\n      \\"postalCode\\": \\"12345\\",\\n      \\"country\\": \\"USA\\"\\n    }\\n  ]\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "9eb28867-c2b9-41d5-8e3b-9da5e055c805", "content-length": "497", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22bff02a9bbc9ecd7c7b2"}}}	run_result	2023-07-27 08:34:08.55776	2023-07-27 08:34:08.55776	87ea20f1-7d81-4959-bdba-279147713fb8
4d64e972-c47e-429c-8341-68857626f583	{"body": "{\\n  \\"resourceType\\": \\"Observation\\",\\n  \\"status\\": \\"final\\",\\n  \\"code\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://loinc.org\\",\\n        \\"code\\": \\"38372-9\\",\\n        \\"display\\": \\"HIV-1 and HIV-2 Ab SerPl Ql\\"\\n      }\\n    ],\\n    \\"text\\": \\"HIV Test Result\\"\\n  },\\n  \\"subject\\": {\\n    \\"reference\\": \\"Patient/example\\"\\n  },\\n  \\"valueCodeableConcept\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://snomed.info/sct\\",\\n        \\"code\\": \\"260385009\\",\\n        \\"display\\": \\"Negative\\"\\n      }\\n    ]\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "40072e15-0ab5-401f-8d55-d2fd1ee72bda", "content-length": "485", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22f8402a9bbc9ecd7d131"}}	http_request	2023-07-27 08:49:08.719722	2023-07-27 08:49:08.719722	87ea20f1-7d81-4959-bdba-279147713fb8
6269d2c0-b4ee-4600-94d2-bec0fa157e95	{"body": "{\\n  \\"resourceType\\": \\"Observation\\",\\n  \\"status\\": \\"final\\",\\n  \\"code\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://loinc.org\\",\\n        \\"code\\": \\"38372-9\\",\\n        \\"display\\": \\"HIV-1 and HIV-2 Ab SerPl Ql\\"\\n      }\\n    ],\\n    \\"text\\": \\"HIV Test Result\\"\\n  },\\n  \\"subject\\": {\\n    \\"reference\\": \\"Patient/example\\"\\n  },\\n  \\"valueCodeableConcept\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://snomed.info/sct\\",\\n        \\"code\\": \\"260385009\\",\\n        \\"display\\": \\"Negative\\"\\n      }\\n    ]\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "7500641a-da09-4005-9024-9919e6fcf9fa", "content-length": "485", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22fad02a9bbc9ecd7d1b4"}}	http_request	2023-07-27 08:49:49.804197	2023-07-27 08:49:49.804197	87ea20f1-7d81-4959-bdba-279147713fb8
f1f938c6-6d46-4273-afbc-6183e28b3836	{"data": {"body": "{\\n  \\"resourceType\\": \\"Observation\\",\\n  \\"status\\": \\"final\\",\\n  \\"code\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://loinc.org\\",\\n        \\"code\\": \\"38372-9\\",\\n        \\"display\\": \\"HIV-1 and HIV-2 Ab SerPl Ql\\"\\n      }\\n    ],\\n    \\"text\\": \\"HIV Test Result\\"\\n  },\\n  \\"subject\\": {\\n    \\"reference\\": \\"Patient/example\\"\\n  },\\n  \\"valueCodeableConcept\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://snomed.info/sct\\",\\n        \\"code\\": \\"260385009\\",\\n        \\"display\\": \\"Negative\\"\\n      }\\n    ]\\n  }\\n}", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "7500641a-da09-4005-9024-9919e6fcf9fa", "content-length": "485", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c22fad02a9bbc9ecd7d1b4"}}}	run_result	2023-07-27 08:49:50.820351	2023-07-27 08:49:50.820351	87ea20f1-7d81-4959-bdba-279147713fb8
c6f846f6-7188-4e70-8464-4122dec45e21	{"data": {"body": "{\\n  \\"resourceType\\": \\"Observation\\",\\n  \\"status\\": \\"final\\",\\n  \\"code\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://loinc.org\\",\\n        \\"code\\": \\"38372-9\\",\\n        \\"display\\": \\"HIV-1 and HIV-2 Ab SerPl Ql\\"\\n      }\\n    ],\\n    \\"text\\": \\"HIV Test Result\\"\\n  },\\n  \\"subject\\": {\\n    \\"reference\\": \\"Patient/example\\"\\n  },\\n  \\"valueCodeableConcept\\": {\\n    \\"coding\\": [\\n      {\\n        \\"system\\": \\"http://snomed.info/sct\\",\\n        \\"code\\": \\"165889005\\",\\n        \\"display\\": \\"Positive\\"\\n      }\\n    ]\\n  }\\n}\\n", "path": "/Patient", "method": "POST", "headers": {"accept": "*/*", "cookie": "Cookie_1=value", "connection": "keep-alive", "user-agent": "PostmanRuntime/7.29.3", "content-type": "application/json", "postman-token": "37dd94b3-a976-4ca1-8c8a-d51852f3f0d9", "content-length": "486", "X-Forwarded-For": "172.18.0.1", "accept-encoding": "gzip, deflate, br", "X-Forwarded-Host": "localhost:5001", "X-OpenHIM-TransactionID": "64c2306c02a9bbc9ecd7d3c3"}}}	run_result	2023-07-27 08:53:01.609391	2023-07-27 08:53:01.609391	87ea20f1-7d81-4959-bdba-279147713fb8
\.


--
-- Data for Name: invocation_reasons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invocation_reasons (id, type, trigger_id, user_id, run_id, dataclip_id, inserted_at, updated_at) FROM stdin;
0d742fec-f283-47c9-9dec-e86e47ea8304	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	78f75edc-8704-4e66-ba72-287e2bc5707a	2023-07-25 06:29:24	2023-07-25 06:29:24
c2bc616a-322c-4a29-899b-ed523ad90ed2	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	b986bc53-d08c-45d0-b967-84ca470529e9	2023-07-25 06:30:08	2023-07-25 06:30:08
d8fcbd5d-296f-4618-96bd-158935cf37b6	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	b9f3e2b7-ae82-46a3-aa82-036a6a03a12b	2023-07-26 05:46:00	2023-07-26 05:46:00
a12c0063-2a0d-4d7b-b52f-f0dee3f0686f	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	e67fadbe-1892-4fed-95e8-0771966a9eb0	2023-07-26 05:48:04	2023-07-26 05:48:04
91de8e96-8078-4845-a851-e8e9d7bcc544	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	e17eb0f6-829d-4c88-99df-7c14d6f0b9fd	2023-07-26 05:49:21	2023-07-26 05:49:21
9d7566f3-ad99-454d-8d64-dac4200b9ffc	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	43272d2a-e361-43fe-b603-ab67fa7f8a50	2023-07-26 05:49:32	2023-07-26 05:49:32
d5edcdbc-bd45-4223-888f-0f85050ec715	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	4edeaf5f-02b0-491e-9e7d-80ad9a58cc74	2023-07-26 05:51:33	2023-07-26 05:51:33
9a14a552-f11d-49fc-b4a2-5cde676ba923	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	dd809311-24eb-45c5-8443-70782066bd44	2023-07-26 05:53:54	2023-07-26 05:53:54
ff067f1b-b872-4d7e-b7b7-557817261136	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	06ed4489-82ef-471b-b5a2-4af563392b4c	2023-07-26 05:56:53	2023-07-26 05:56:53
7f7ded00-a8e0-48e0-aba8-cbfc00a303f5	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	4d736514-5a33-4381-bc50-52bdb73a4349	2023-07-26 07:58:49	2023-07-26 07:58:49
54baccef-78d8-465b-8380-2d4df0ab4792	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	c7af9ab3-bf59-4a19-956f-beb50572f1bc	2023-07-26 09:07:25	2023-07-26 09:07:25
50ccca0c-b31c-40c1-a60d-679940aeb7a1	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	e31a57a3-8428-4fc8-9184-c3be2aa43284	2023-07-26 09:07:25	2023-07-26 09:07:25
8e8cbeda-b641-4ab6-94a5-7199a271ad00	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	381fae4c-3492-4a50-b4b0-355fbb36342d	2023-07-26 09:07:25	2023-07-26 09:07:25
7f986400-f591-4d7d-aed7-2690713eb5a5	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	d9350252-0814-4d82-8a73-1d6cd92fae2a	2023-07-26 09:07:25	2023-07-26 09:07:25
8d968629-62b2-4b2d-9a75-881bc08e356d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	a6e95482-b34c-4e44-a8af-e5cdce431233	2023-07-26 09:07:25	2023-07-26 09:07:25
3096e234-b162-4cd9-b392-5949d7c1789d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	246db237-4a7b-40e9-aa6f-6329e3205a93	2023-07-26 09:07:41	2023-07-26 09:07:41
17c29e50-4a3b-42f1-a5a5-8c6aa73d404d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	4657f833-23d0-4d81-92ba-d60aee942b19	2023-07-26 09:26:56	2023-07-26 09:26:56
c4a4b565-0c45-4a67-bff8-dd55828f5405	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	e4081bbc-e64f-44f7-8117-46b91ebed1be	2023-07-26 09:34:48	2023-07-26 09:34:48
bd528715-5e26-4402-91d8-3dd227269bbe	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	25545201-992f-4163-b937-635918c2bb97	2023-07-26 09:46:03	2023-07-26 09:46:03
3c61d981-bf45-4914-9830-9bdedfdf6d28	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	e46fec2d-63c1-44b4-a879-2b44ab16ffd0	2023-07-26 15:07:50	2023-07-26 15:07:50
96940490-ca82-45e8-b498-21248beb0d0c	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	278fdf91-cef2-41b6-a2db-04848b813787	2023-07-26 15:14:08	2023-07-26 15:14:08
5afd3365-e738-4d02-a1d5-c7882e557102	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	99605d45-04b4-447d-84d8-e71267e6d6bb	2023-07-26 15:17:47	2023-07-26 15:17:47
c9565fc7-c042-4bd7-bce8-b9a9f465ed10	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	f96a8cea-c818-4e6d-bf37-777b9fd386d6	2023-07-27 06:18:05	2023-07-27 06:18:05
20e6552c-0fee-4b0d-8bd0-beaeb2db0c2d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	72ef3078-6fd5-4e37-91d3-97ddc2069dab	2023-07-27 06:18:13	2023-07-27 06:18:13
e5bb532b-04c1-4c73-8640-309903a73238	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	32d51554-c05b-4d67-8d1e-0690ef2c264b	2023-07-27 06:18:46	2023-07-27 06:18:46
4815ea2a-ed65-4d06-a634-3e8d990b50ff	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	23f855e1-770a-41f7-a33c-e85e102cf913	2023-07-27 06:27:08	2023-07-27 06:27:08
2c8609f4-899e-4ace-b6c9-d781fbe30f59	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	1d58ddbe-d555-426b-8e3d-9009fd041b9d	2023-07-27 06:28:04	2023-07-27 06:28:04
80acfc3f-064b-4049-bcea-faaab2619c52	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	968f9b3d-b816-4b78-840a-32be384931fe	2023-07-27 06:29:09	2023-07-27 06:29:09
56f48551-d13c-4e7a-8dcf-423678717324	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	63d31d49-944d-4629-8d74-3fc71b2d33b4	2023-07-27 06:31:07	2023-07-27 06:31:07
ff7e2ee3-fa46-4546-a0af-7117fa450d78	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	97a4fce1-faae-471e-acd7-9b60fd07d53c	2023-07-27 06:32:05	2023-07-27 06:32:05
de07949a-55a6-4074-ba30-6b2d8e8523cc	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	c0c11afd-5975-4feb-9f96-8417035608e6	2023-07-27 06:35:05	2023-07-27 06:35:05
6868d4a6-c868-4598-9f08-6cebc5a0fa77	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	661cae58-607e-4c9d-9da1-9ea117915ca5	2023-07-27 06:36:49	2023-07-27 06:36:49
63202682-62b3-48d1-a932-26b843cfafbb	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	111402fe-0f83-4665-8ff4-c8ffbd16e072	2023-07-27 06:39:00	2023-07-27 06:39:00
9628f4da-c079-4944-a86e-7a98bb9f9a4a	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	0112f43d-47af-4914-8d47-e32a26bb751e	2023-07-27 06:40:18	2023-07-27 06:40:18
16ead63c-a0d8-4049-af34-68e1d160e4da	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	6a78b60f-fc3d-43b4-be6d-334a3de33069	2023-07-27 06:40:29	2023-07-27 06:40:29
98ed0ae8-70de-4a7b-8fc0-f6c5feca99c7	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	fc97f298-cecd-48e3-a61e-647409de18b4	2023-07-27 06:40:48	2023-07-27 06:40:48
5b7443bf-699a-4213-808c-4e763ad3fb03	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	ab157d1f-4488-4e3e-8019-5cd77423c4fd	2023-07-27 06:41:04	2023-07-27 06:41:04
89d9eb26-c82e-433d-8443-1deb8b019235	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	56831b4c-4cd6-4381-ac4a-93dd34904ee6	2023-07-27 06:41:40	2023-07-27 06:41:40
f8969fda-9ff4-4729-929f-3c6463b8e15d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	837e02bd-483f-48ce-adef-2d285f667606	2023-07-27 06:42:49	2023-07-27 06:42:49
b3640cc8-3e38-453d-9731-2e05f15a5a8d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	15f9abfc-e10a-42b8-b658-65d92187e68c	2023-07-27 06:43:59	2023-07-27 06:43:59
7995e693-b4e1-4e4d-aed5-94b271a2f2cc	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	e8301efc-2c3d-4e82-bd0e-1df2fd5d56f4	2023-07-27 06:44:30	2023-07-27 06:44:30
0d5f7ec8-d510-40c7-95e4-8f71b0a5170c	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	1281f619-965e-46c9-bbea-fd9f152687e7	2023-07-27 06:46:04	2023-07-27 06:46:04
fec9a645-1767-4e12-8da2-41a0b7e4e20c	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	cad9851c-c7fe-488f-afc9-2b1b78f71f83	2023-07-27 06:47:07	2023-07-27 06:47:07
25f0ef3f-65df-417d-bce4-36f68ac2ac7d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	e7f80ab2-5de4-4492-9855-ec7dd7203aea	2023-07-27 06:47:34	2023-07-27 06:47:34
cb5c0d84-2862-4d8c-aab9-f8d23606ea98	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	78294e48-1d12-4306-87a9-20c077476fbb	2023-07-27 06:48:10	2023-07-27 06:48:10
e4a5933e-a677-4a68-9875-9ae16c4f2f1d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	422f0483-3183-45fa-ac6f-b03cb4429545	2023-07-27 06:48:28	2023-07-27 06:48:28
0601a2c2-cf25-4b66-a310-4afa23ef387b	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	d3242a13-2739-47bc-9a9d-f81d62e0083d	2023-07-27 06:50:00	2023-07-27 06:50:00
2e6ccc64-848b-47d3-a5e3-f830fe151b10	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	2f786c50-b7f4-40b1-82b3-a76e91b3f4ac	2023-07-27 06:50:21	2023-07-27 06:50:21
8b774587-0575-4491-b802-ff7a0ab5f727	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	f4f57b0c-0a7e-4297-ab5a-79ae08143807	2023-07-27 06:51:28	2023-07-27 06:51:28
e2384c72-ca1f-4a5f-af77-d38af9673b9b	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	f44ea5b5-a40d-4e3a-8766-46648b221154	2023-07-27 06:54:53	2023-07-27 06:54:53
7c717808-a649-4b7e-9396-7c1405b379c8	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	9499a0c0-00e1-45fa-928c-475288dd8d30	2023-07-27 06:57:03	2023-07-27 06:57:03
809c2742-63c6-493f-99be-a5dd064ca6af	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	3ac52328-b3d8-482a-a3f8-cef102b98aea	2023-07-27 06:58:40	2023-07-27 06:58:40
81a17849-a495-4207-8c27-460a5c48dd6f	manual	\N	3476f7a9-e02f-4a3d-bc1f-ae3374a882ac	\N	3ac52328-b3d8-482a-a3f8-cef102b98aea	2023-07-27 07:13:49	2023-07-27 07:13:49
60c41762-c480-4d4b-a223-533457a8c8e4	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	71a37a73-4c59-42fc-9224-a53ca4fa967b	2023-07-27 07:14:33	2023-07-27 07:14:33
0669320d-eed4-4d55-b087-7dd61eab4c2f	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	788e3ec2-6525-48e1-ab49-74c30d3a1372	2023-07-27 07:15:04	2023-07-27 07:15:04
3cdf8a5f-6e51-4e2c-b2bc-e2881b277c29	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	fb222e36-ea28-403b-aa78-0424354d2582	2023-07-27 07:15:40	2023-07-27 07:15:40
e7894ee8-1b76-4b13-aa20-4a6196ee4840	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	f2f3aede-5f82-4648-a417-b1dbbc12fae6	2023-07-27 07:15:58	2023-07-27 07:15:58
d6a39721-b2ea-4be2-8426-273543bb450a	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	4fe82e58-1836-41d7-becd-adad581bab31	2023-07-27 07:16:17	2023-07-27 07:16:17
127e2de4-9300-442a-a42e-2a2afb079322	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	1261f8ef-2969-4f3b-8a2b-7a75ad7b6f49	2023-07-27 07:18:56	2023-07-27 07:18:56
79d5918c-904f-48d0-8abb-9001a07f6183	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	ad0c2f39-4df0-4ab8-a372-870eec8d5115	2023-07-27 07:19:37	2023-07-27 07:19:37
98e79e63-d8d6-41e3-83e6-8f6b76cf7c57	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	4cde9edf-64a3-462b-968e-f95a5c4e1421	2023-07-27 07:25:43	2023-07-27 07:25:43
9d7b421b-50e8-4201-8e91-580b89540a85	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	46036534-820d-4570-acfe-7c72654f1c84	2023-07-27 07:25:57	2023-07-27 07:25:57
86b6b3e6-17dc-4ec9-bcf3-55a6f3b6c49e	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	627f535f-58b8-4ef4-92f3-b2e3fc48ff73	2023-07-27 07:26:57	2023-07-27 07:26:57
1a25ba43-6b01-4688-8b16-195a8e9f9859	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	d95bbcab-f155-41ed-abcb-d10dc54155b1	2023-07-27 07:27:18	2023-07-27 07:27:18
b548218b-7d2f-46d3-8186-552ca71a2a0d	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	ab8a90f7-354d-4954-a28f-8941ff01be1c	2023-07-27 07:27:20	2023-07-27 07:27:20
ac878ac0-d635-442d-9000-ea4fce52a8a6	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	f7d23a77-8e7c-42f8-941d-b42c57820b9a	2023-07-27 07:28:10	2023-07-27 07:28:10
7ea1a6ec-082d-4204-b90c-0d01c381848b	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	c3c0ac32-57be-4403-9870-6f6132c51431	2023-07-27 07:28:38	2023-07-27 07:28:38
917e750d-1690-45c1-9f22-fefddbb4c4fb	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	7397ea77-b144-431a-93cd-04a662f084ae	2023-07-27 07:28:56	2023-07-27 07:28:56
94d64584-6429-41a5-b81f-aeb75742385b	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	62341c84-c6ed-4fbc-879c-8b1371ef84b0	2023-07-27 07:30:21	2023-07-27 07:30:21
05a73236-0da6-4f4f-82a1-d8d1890e8a24	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	f43fd26f-3788-4384-844c-684882b9e930	2023-07-27 07:30:39	2023-07-27 07:30:39
c48ce525-aebd-4438-a3f5-0b0bc21c3f04	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	182320ba-34ab-445e-b431-73e7ee0c1d1e	2023-07-27 07:31:08	2023-07-27 07:31:08
638a0a5b-c37b-4e69-be99-63e3615120d1	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	43ca4f8b-7530-4279-aaf8-b6df3a184965	2023-07-27 07:33:49	2023-07-27 07:33:49
171022ac-75ab-4d23-84aa-4b0dbb189d9c	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	677766cb-edcb-4aa7-880e-4d3cac3662f8	2023-07-27 07:34:19	2023-07-27 07:34:19
b9cc5901-8ab7-4eb8-9c3d-be0da796c56f	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	0eddd5e2-6879-45d8-ae8f-30d05208063c	2023-07-27 07:38:21	2023-07-27 07:38:21
6dc5cb0d-f98f-4bff-b64d-4bb74bf29e57	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	e488206a-ff3e-441a-845a-13a5aafcb7da	2023-07-27 07:38:51	2023-07-27 07:38:51
c533b930-1723-4594-8cac-dfb1184e64eb	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	ecdf414f-ce82-4f16-8b7e-3db130c3c060	2023-07-27 07:47:03	2023-07-27 07:47:03
002b5b51-0633-4cd2-b299-2cd315995079	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	ab3d146b-3f6d-4848-ab15-bdd78564ebe7	2023-07-27 07:48:15	2023-07-27 07:48:15
682b2a61-46d5-46bd-81cd-84fe943d8e89	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	9b3779e6-16ef-4205-89ef-7ffc63033e8d	2023-07-27 07:49:09	2023-07-27 07:49:09
6b08a7cf-3611-44b6-9f3d-8ee6095f9d83	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	f52f7b3c-73cb-4b78-84c2-365f90567525	2023-07-27 07:51:35	2023-07-27 07:51:35
dc28c6e0-688f-4f8e-ad61-1ff73bede2af	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	50ab367f-e516-4660-9a49-e990a857055f	2023-07-27 08:08:03	2023-07-27 08:08:03
156ad6c3-bfe5-4184-92dc-0ad76929e7e0	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	abb0bff1-8c35-4245-8795-dd7ce3064f85	2023-07-27 08:12:22	2023-07-27 08:12:22
656db25b-99fa-4102-8713-a4fa9d058a4b	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	79bc61d7-e699-4959-9a31-12d8680e448b	2023-07-27 08:13:25	2023-07-27 08:13:25
c5b9e474-f4bc-4c9d-95b1-30c7aa905c2e	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	8e78c335-4d8e-41c1-a534-dc3312c019af	2023-07-27 08:14:45	2023-07-27 08:14:45
a583b766-4d3f-4250-8948-27903ff374c1	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	1296f035-ac2a-46e8-8227-1189603d077a	2023-07-27 08:15:23	2023-07-27 08:15:23
1ec13a34-9c1d-47c0-84d0-0a4bf2c533ce	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	112b53b4-eff6-4bd0-9fd6-6cfff76edc6c	2023-07-27 08:26:46	2023-07-27 08:26:46
79ba2b37-8a90-418f-87f3-c7bcd4b0df46	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	ee7af87d-a24a-4282-a63d-b31efc420805	2023-07-27 08:17:38	2023-07-27 08:17:38
0bcd3348-356b-4058-8f8c-ad28967dce5b	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	86f00d0e-5a27-4c8e-9102-d40ad934b138	2023-07-27 08:24:46	2023-07-27 08:24:46
6e8ccdf6-a8b6-41d7-b0f3-7c665ce0eeed	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	4d64e972-c47e-429c-8341-68857626f583	2023-07-27 08:49:08	2023-07-27 08:49:08
c41b5eca-57e8-4804-ab4d-8eae7b875ab1	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	7aaf0128-e73e-4b89-9b0e-60e31c47ccad	2023-07-27 08:18:21	2023-07-27 08:18:21
d387dd89-e5a8-4b5d-ba61-b4c12d7aed76	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	fd9b7303-05cd-42a4-8fab-c9c0697646d3	2023-07-27 08:31:04	2023-07-27 08:31:04
baea932d-db62-46f6-ac73-baf03907011c	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	6333afdc-ed9f-410e-947d-78eff17cd202	2023-07-27 08:31:43	2023-07-27 08:31:43
d2162ad8-4d5e-4a5c-9c39-d97a2f6996ba	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	5686b70e-5dca-46f5-af6f-f5d62d68554b	2023-07-27 08:22:01	2023-07-27 08:22:01
18c01c13-6093-49ff-9eaa-70a394715255	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	73258b70-d859-4076-9e27-720dd66e0f97	2023-07-27 08:24:22	2023-07-27 08:24:22
11d0d2bb-b50a-415e-92d3-525fdd3cd41e	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	0238eb16-6646-4617-8c0c-4465d4d220e6	2023-07-27 08:53:00	2023-07-27 08:53:00
6f69396b-f947-45dc-9309-9f1af2743af5	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	fdf727bc-42db-42ac-8fdb-7f3b73e85ff5	2023-07-27 08:34:07	2023-07-27 08:34:07
e3ec3fcc-b838-4899-be38-d55a34736de0	webhook	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	6269d2c0-b4ee-4600-94d2-bec0fa157e95	2023-07-27 08:49:49	2023-07-27 08:49:49
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, name, body, enabled, inserted_at, updated_at, adaptor, project_credential_id, workflow_id, trigger_id) FROM stdin;
7d95a11a-0c96-461b-8991-f20b6bbbb56b	test	// Parse the incoming FHIR Patient resource\nconst fhirPatientResource = JSON.parse(state.data.body);\nconst testResult = fhirPatientResource.valueCodeableConcept.coding[0].display\nconsole.log(testResult);\nconsole.log(state.data.body);\ncreate('dataValueSets', {\n  dataValues: [\n    {\n      dataElement: dataElementId,\n      period: junePeriodId,\n      orgUnit: organizationUnitId,\n      value: dataValueForJune\n    }\n  ]\n});	t	2023-07-25 06:22:31	2023-07-31 06:27:52	@openfn/language-dhis2@latest	0bac4af3-f4bf-4418-b9b2-1f0bf6c1222e	4a22a2f6-06ff-4035-96f9-5f607b371b99	ee8127a3-0d1c-43f1-9cbd-a7b74ff33582
\.


--
-- Data for Name: log_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_lines (id, body, "timestamp", run_id, inserted_at) FROM stdin;
5663fe88-433d-4d28-85b4-44327aefb59e	[CLI] ℹ Versions:	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
67ac6009-0135-4bb0-9f56-b5ff939e6bc8	         ▸ node.js                   18.12.0	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
7640bbc7-fab5-4bff-9779-f5285a47981c	         ▸ cli                       0.0.35	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
e08cc4f1-2b67-4e71-882b-e8960e35504c	         ▸ runtime                   0.0.21	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
619fca47-9724-460e-8763-dbd8eee0ee87	         ▸ compiler                  0.0.29	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
2ab857fd-53c7-4d5d-ad5e-65adff39a691	         ▸ @openfn/language-dhis2    4.0.2	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
4e3fbd8f-2d65-4bbe-9bb8-89277e2739b6	[CLI] ✔ Loaded state from /tmp/state-1690266564-7-7kw9e4.json	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
33caed21-a406-4d82-ae11-226f322718d7	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
2f0b0b11-26f1-4421-9893-d4f2aa131e73	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
050cb388-3181-4b53-a7ba-a618f258eca0	[CLI] ✔ Compiled job from /tmp/expression-1690266564-7-o75tz1.js	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
488cf0ef-057f-45ee-9065-6640982d9361	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
53ecbbfb-036f-46f3-8423-5a5c3257047d	Preparing create operation...	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
653b788e-f74f-4caf-9597-d6e408461e49	Using latest available version of the DHIS2 api on this server.	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
3fe76a58-ed55-46b6-afb0-e657fb0a6fa9	Sending post request to https://play.dhis2.org/dev/api/dataElements	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
2b416b28-bce1-4764-8c92-fc85ad28cbcf	✓ Success at Tue Jul 25 2023 06:29:27 GMT+0000 (Coordinated Universal Time):	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
ca376188-6f1d-4573-a672-d3f86e775466	∟ Created dataElements with response {	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
aacf5024-48aa-4fba-b080-bcbe05aeba85	  "httpStatus": "Created",	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
a7975491-eadb-4a20-a6bf-2e44215af093	  "httpStatusCode": 201,	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
2ad2ebc5-d06d-40c3-acfa-d8a938fd6c98	  "status": "OK",	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
751b929c-65d9-4cc3-8c6a-49a0c3a878e0	  "response": {	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
c8f6e86d-c4c1-4525-84b6-c080a1c329f8	    "responseType": "ObjectReport",	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
ee4a73c6-d9e2-411e-b565-27f0f1891ed3	    "uid": "of85yxFyU1x",	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
ec3b69e7-3d0b-488d-b067-2076290360df	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
baacd1b2-1a0e-4c8e-9690-241977e6cce5	    "errorReports": []	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
6f723a12-7d74-4e79-8076-f52d1d1f1213	  }	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
e244bfaf-24c8-4fc9-b338-7893d2a6a951	}	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
48410d9e-71c1-41de-ba26-c3969019b39c	Record available @ https://play.dhis2.org/dev/api/dataElements/of85yxFyU1x	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
10562705-f8bb-4bf9-ac61-11e364bb0523	[R/T] ✔ Operation 1 complete in 1.883s	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
e0667aef-b5a7-438b-a573-f0f25b5c1229	[CLI] ✔ Writing output to /tmp/output-1690266564-7-9oxp2r.json	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
da2add60-fddf-4a36-a4fe-5ba7be395213	[CLI] ✔ Done in 2.3s! ✨	\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
74d286a8-cbce-4e1d-a728-57db808de2de		\N	974b75fa-f614-4fba-b83d-6f33333907a4	2023-07-25 06:29:28
c02404a1-dd4f-4588-a92b-0469048eb688	[CLI] ℹ Versions:	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
3300c453-f563-4296-a7ba-5d2457301c74	         ▸ node.js                   18.12.0	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
c09ac4d1-4124-48fb-9593-c343a47d0103	         ▸ cli                       0.0.35	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
7f1329da-c53f-43a9-b98c-63b43bba500c	         ▸ runtime                   0.0.21	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
c803ffb8-9e1e-498b-8098-1059402b53d1	         ▸ compiler                  0.0.29	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
01dd355c-665f-44fe-89b9-c9197a3136b2	         ▸ @openfn/language-dhis2    4.0.2	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
a1a84642-1cb2-4e63-a4c5-0f8dbbe8b390	[CLI] ✔ Loaded state from /tmp/state-1690266608-7-1l5b9ap.json	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
12e7dda8-1469-4683-aa92-f3fe3b2120c7	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
894571b0-ddb1-41f2-bf76-839e2bd3e7a6	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
951f384e-497b-4f26-987e-16f45a13a182	[CLI] ✔ Compiled job from /tmp/expression-1690266608-7-11yeyny.js	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
20bbb75e-0b6e-4423-a515-eb394a6c65b6	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
fcdc4a8d-c28f-4a0e-adde-f95dd7fe9543	Preparing create operation...	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
77711771-5ebd-416c-bc2e-823389da1d62	Using latest available version of the DHIS2 api on this server.	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
fd5139e3-c66a-44d6-917f-1e8b72414df0	Sending post request to https://play.dhis2.org/dev/api/dataElements	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
7064522e-907a-4888-9245-5fd206476205	{	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
33d6235b-6af3-4f23-b25d-58d69d90191f	  "httpStatus": "Conflict",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
04bf3b33-27f3-4938-9c70-7c7bb16f15ad	  "httpStatusCode": 409,	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
406ce9d1-c623-4053-ac5d-d688d3e265a1	  "status": "ERROR",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
b0e71a3d-0234-41a8-bd5f-6807c7dd2dab	  "message": "One or more errors occurred, please see full details in import report.",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
08f9618f-3be0-40d3-8050-309700dff832	  "response": {	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
aa736b18-dd89-49c6-8a94-734b753ddac6	    "responseType": "ObjectReport",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
0a729ca2-0173-4a21-a8ee-c9536eec80e4	    "uid": "Eh9Y4mL3Dvw",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
969567e9-efc9-4ee6-919d-f648c361bc5f	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
98e829a9-5558-4929-a9ff-3d0642c818f0	    "errorReports": [	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
2a7289d9-538b-4f1c-8144-6378f901a88e	      {	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
b1076c27-9e4e-4ca2-9d81-8dcb5c2736a6	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [Eh9Y4mL3Dvw] (DataElement) already exists on object of85yxFyU1x",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
3b462656-81d2-4e26-a460-c68ffb0a5561	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
45a91aed-8bbb-417e-8334-90d7046220ab	        "errorCode": "E5003",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
6e040f6e-678b-4284-a954-faa5abd9c93c	        "mainId": "of85yxFyU1x",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
6de668ee-f2b1-46ea-b7d0-c83f7b93c192	        "errorProperty": "name",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
279e4f5e-a530-454c-800d-2c11f3a5be10	        "errorProperties": [	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
8e93ce4a-4533-463d-bd43-4d88a6e3ea10	          "name",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
b5d2261b-6690-4919-ba6e-ec98c52546dc	          "Paracetamol",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
36b5eb78-897b-486a-ad7b-ba7f22de5e6f	          "Paracetamol [Eh9Y4mL3Dvw] (DataElement)",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
253d5dd3-d981-4d62-ae86-229063c4be77	          "of85yxFyU1x"	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
fa61d264-c048-4ff0-ab00-e5a2570c64da	        ]	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
88d21cde-8186-4b62-8e70-644fb20e0b1b	      },	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
a0cfe1f4-64d0-458e-a571-16af6ed3afdd	      {	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
59de1c05-ab45-47c5-bd37-5ee4f8aff655	        "message": "Property `shortName` with value `Para` on object Paracetamol [Eh9Y4mL3Dvw] (DataElement) already exists on object of85yxFyU1x",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
4fb7b0e8-4eb9-4473-a74e-daab94b5ac6c	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
d6bc8e8e-579e-4e78-9c54-a25de6cfe7c0	        "errorCode": "E5003",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
4f58da48-f88e-4ad8-b2f8-1745ab40c87f	        "mainId": "of85yxFyU1x",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
ea1a4bb3-87bc-45db-9852-9a4298d76948	        "errorProperty": "shortName",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
1bca1dfa-f108-4436-ae88-c3d64f9bb923	        "errorProperties": [	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
721aa2e8-bfe8-4143-b265-86e419e4c90c	          "shortName",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
779dd31d-df1c-4844-bd26-15b20a78adc3	          "Para",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
14266b1e-de9b-4c06-a389-1bd6b80863ca	          "Paracetamol [Eh9Y4mL3Dvw] (DataElement)",	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
9a31410b-efa7-4b12-9746-2de5c885a1bd	          "of85yxFyU1x"	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
2fc7ffce-3593-4e1f-8232-d8c68a2bed0e	        ]	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
406dc57f-361a-4c30-9530-c061d67dd7b8	      }	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
68a288c6-5246-44b4-998e-91cf59db56a7	    ]	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
8a2bd5d2-5d98-44e0-b2ef-faf6ea67b48e	  }	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
0e86fc76-729f-4613-a18b-b44120e17a41	}	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
2d161cdb-bc5d-47e6-afa0-cba33d3d0b3d	✗ Error at Tue Jul 25 2023 06:30:10 GMT+0000 (Coordinated Universal Time):	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
1ad1d3e2-323c-41d1-8ae7-af2e5efcc572	∟ Request failed with status code 409	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
d7c596b0-fbab-487a-9cf7-13e5406d78c2	[R/T] ✘ Error in runtime execution!	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
ec1faeb4-eb85-412d-8940-40f482df23d6	[R/T] ✘ [object Object]	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
e580b83b-9dfa-45a4-b6f4-14813d9d03f9	[CLI] ✘ Error: runtime exception	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
11cd8223-d650-4cd9-b71d-43c55541913c	[CLI] ✘ Took 1.819s.	\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
aac34a3f-5ee1-4328-b3e7-f400ef71fddd		\N	8431f3de-3a80-4e8e-88dc-f17a581c76f2	2023-07-25 06:30:11
0fae58b1-4b61-440b-8df2-cf13b497e895	[CLI] ℹ Versions:	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
315a77d5-87f6-46ff-a107-ffe7bf22fd72	         ▸ node.js                   18.12.0	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
9858c9f9-9138-4638-b5ab-105365773737	         ▸ cli                       0.0.35	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
62077779-a2b2-4218-aa10-f0f94256bd48	         ▸ runtime                   0.0.21	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
d6d9df4f-21b3-4674-8083-3e659c573d0b	         ▸ compiler                  0.0.29	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
351768f1-9d55-4542-9539-6f423255fe23	         ▸ @openfn/language-dhis2    4.0.2	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
b0bbbdeb-fd0e-49af-b32f-3db9e7b72bcf	[CLI] ✔ Loaded state from /tmp/state-1690350360-7-y1whio.json	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
01a09259-a2b7-4b7c-8305-e724a3f89599	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
d196d14f-85db-4387-ba31-b5f4e05b65fb	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
447e85d1-8c7c-4e6d-990f-3a39c3fde3c3	[CLI] ✔ Compiled job from /tmp/expression-1690350360-7-1u4ysl1.js	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
8e55cd1a-4cff-47f4-a782-df75c0a6efee	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
c65ee00a-842b-4abe-9cb8-7bd8968df54b	Preparing create operation...	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
04e62843-efbb-417b-b7dc-8031f0213074	Using latest available version of the DHIS2 api on this server.	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
a67263e0-3fb7-44e3-9fdd-f5d50c3884e9	Sending post request to https://play.dhis2.org/dev/api/dataElements	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
bc96364f-e77f-44d5-942b-7542fcd81856	✓ Success at Wed Jul 26 2023 05:46:04 GMT+0000 (Coordinated Universal Time):	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
b4ae3d2f-1f3a-46c3-ab1b-f85a09b6a875	∟ Created dataElements with response {	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
365b4775-46a9-4bb1-a941-4032e809c41d	  "httpStatus": "Created",	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
05f8f8f0-450b-4208-a6f2-6cd6bd0f1eaf	  "httpStatusCode": 201,	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
79354477-d541-4e34-832d-6f4d69db6d09	  "status": "OK",	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
4fa01544-cf18-4383-826f-a8e971180eb7	  "response": {	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
b5ec1a54-c2b2-4f61-8acb-4042e67908d7	    "responseType": "ObjectReport",	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
827f966c-c23a-4dcd-a269-fef9c6238fe2	    "uid": "DJjX70H7lQ1",	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
0aa58276-9a3b-4f81-927a-f5c553032a78	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
493c15fa-1c60-41a0-a7de-e26f6ac1256d	    "errorReports": []	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
4db6b5d0-0e39-48c2-9777-b24b83e1554c	  }	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
78cfa341-e7ff-4c65-9b06-4b54706dd432	}	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
c29b2f5f-bd45-4e60-91e6-2d674a618e1f	Record available @ https://play.dhis2.org/dev/api/dataElements/DJjX70H7lQ1	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
151ea4de-2ea4-4545-8eb4-fa0b784a4962	[R/T] ✔ Operation 1 complete in 2.178s	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
a9e85c7f-ba3e-4cd1-943e-8c414f95d0a3	[CLI] ✔ Writing output to /tmp/output-1690350360-7-h7kep6.json	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
a7a62e6e-401b-458f-9c93-60002ec39f68	[CLI] ✔ Done in 2.583s! ✨	\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
f2ceaca3-0d13-45e2-aa6a-226725b6f1f3		\N	f093aeef-e2ac-4f80-b057-76456c21e269	2023-07-26 05:46:04
a1fd945a-ad2a-48a4-8a4c-f69e870c1e83	[CLI] ℹ Versions:	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
690699e7-39f4-4f4c-9635-daa8536a8aa6	         ▸ node.js                   18.12.0	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
44f3113b-1023-408b-8a0a-3604c2b86d7e	         ▸ cli                       0.0.35	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
dfce392d-ca84-42e8-ab15-682b4c2a5d12	         ▸ runtime                   0.0.21	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
f90fa460-9f83-4bc8-8004-f94cc3e29e76	         ▸ compiler                  0.0.29	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
5ca0b485-4160-4486-99a7-a8e10c20e6e0	         ▸ @openfn/language-dhis2    4.0.2	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
5d3e2c01-a960-4a7a-a10d-f33c1eb45347	[CLI] ✔ Loaded state from /tmp/state-1690350484-7-1mcqwlv.json	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
d618acd1-95fd-424f-a498-5b127636cd5c	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
f2ebc555-e5f8-4ff0-ac84-836f2b8f2ea1	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
a3b92e50-70fe-40f9-844c-7a7353ea60d2	[CLI] ✔ Compiled job from /tmp/expression-1690350484-7-1br4ijk.js	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
71288b0e-2585-4996-bf9b-bfd3af1fa007	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
660d8448-4526-4525-a04a-c4720a9944fd	Preparing create operation...	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
500471d6-93e3-49fc-83e3-5a913d5ed4ca	Using latest available version of the DHIS2 api on this server.	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
2e158046-bc52-47f6-a3f2-f58da00dd99c	Sending post request to https://play.dhis2.org/dev/api/dataElements	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
168ee2f0-81d5-487c-b4a2-34eb5cce3438	{	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
c2a98874-3729-4849-94a9-2a6ecbf2cf7d	  "httpStatus": "Conflict",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
d065d0af-7a9d-48cf-a890-25c3ba28d5a9	  "httpStatusCode": 409,	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
33a0695a-1f35-4a64-a1d5-dca5213f83c6	  "status": "ERROR",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
49c80d4b-94c3-47f7-a1ef-8844553b0ce5	  "message": "One or more errors occurred, please see full details in import report.",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
96f95182-3f0f-496e-9f6b-439ebebef918	  "response": {	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
3e83059e-6576-4e96-b7dc-ff54230f36d4	    "responseType": "ObjectReport",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
9c3193e4-c426-4985-bf00-192701374635	    "uid": "g6OuuwgV29V",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
12939da1-86c5-4c8a-ab45-324dfa6f4b0f	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
f53d2977-0afd-417d-b5ae-fa7dfacf88e5	    "errorReports": [	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
5532540c-ec22-4c05-be9b-7f8188d555e0	      {	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
c23b2005-ba43-4e5e-8e29-b0c9d4d28620	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [g6OuuwgV29V] (DataElement) already exists on object DJjX70H7lQ1",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
2159e6eb-8718-458d-b7eb-33a88b66f516	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
75f49f28-3dd7-40a0-b25d-2ddc5a0b4f6c	        "errorCode": "E5003",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
9a3ea2b9-5015-4a81-9499-25a4e0f117f7	        "mainId": "DJjX70H7lQ1",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
c617e655-0112-43d7-a66b-59ae5bcee579	        "errorProperty": "name",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
f28b35ca-d3c1-45f7-afc7-d09990519caf	        "errorProperties": [	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
c97706fb-3ce6-4bc4-9038-ccc1d3539cf1	          "name",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
88845bbc-1319-422d-ac56-5fb0489d54c7	          "Paracetamol",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
25781fc3-6480-4964-9e8b-873f6074670e	          "Paracetamol [g6OuuwgV29V] (DataElement)",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
612b79d3-4e55-42b4-9768-bcb85cfda1df	          "DJjX70H7lQ1"	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
97b98ac7-a68b-4a46-87f6-37c0fdc035fb	        ]	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
a2ec988c-7ecd-4b16-8679-bc3fc0a4a5ab	      },	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
a564fd8f-62d5-467f-bddb-fc5ca156a1c0	      {	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
68884e65-6c0f-4cb1-abf5-a9b20fc92c8a	        "message": "Property `shortName` with value `Para` on object Paracetamol [g6OuuwgV29V] (DataElement) already exists on object DJjX70H7lQ1",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
80083697-8564-468f-b2a6-ef36ab524250	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
c670f14d-a86f-4544-ac46-1ab45e26c052	        "errorCode": "E5003",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
0bd9efb1-6e17-4f72-a33a-65430c260e75	        "mainId": "DJjX70H7lQ1",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
590bfcb5-cdf5-4ad0-899e-be8e917df296	        "errorProperty": "shortName",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
5db919b1-3aa2-4e1e-80a1-a0b274c9d12e	        "errorProperties": [	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
ab4df6b2-3aa7-4ae4-b8b4-ea14cd6deed5	          "shortName",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
e9f0b8ab-7959-4eda-8401-8bba88b9055e	          "Para",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
0c9f2584-dba5-4940-9e20-9818d9f04a80	          "Paracetamol [g6OuuwgV29V] (DataElement)",	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
1a707c15-6ac3-4786-bd38-c56811bd421b	          "DJjX70H7lQ1"	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
9dddb104-7510-4df7-9a18-12586d9d8586	        ]	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
2ae59dd5-9fa5-4a4b-a033-09c00f1191b3	      }	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
453a1673-d44c-417d-92cc-ee27a5b5f7fc	    ]	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
27be577a-b107-49aa-9a9c-dc2d0ef6871f	  }	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
b1cf9bec-d5f8-435a-b1d5-fec0f9286e08	}	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
4a964662-91c4-41f1-8cab-2e431ea193b8	✗ Error at Wed Jul 26 2023 05:48:07 GMT+0000 (Coordinated Universal Time):	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
0adc1129-3e68-4d0e-9b63-3ae1eabd060e	∟ Request failed with status code 409	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
eab4bcdb-5c72-475f-815e-259a6e9a2d33	[R/T] ✘ Error in runtime execution!	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
d94435e6-6b39-49b8-90bb-7e6a2ed765f5	[R/T] ✘ [object Object]	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
df912c0f-2248-49fc-8122-583bdfbffb0c	[CLI] ✘ Error: runtime exception	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
3b70a24f-9627-4118-b27f-619393fff2c9	[CLI] ✘ Took 1.824s.	\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
9b704202-d116-4111-aea6-7e846fd89cae		\N	1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	2023-07-26 05:48:07
5a323cfe-939b-48ca-8738-f96833cfda63	[CLI] ℹ Versions:	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
87839ee1-d70c-4743-bfbf-63f05b003182	         ▸ node.js                   18.12.0	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
bd1b69d0-2409-4382-a17b-8caf4706fd03	         ▸ cli                       0.0.35	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
ac49c810-648e-4888-91e1-15e964c8f4d6	         ▸ runtime                   0.0.21	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
489f7bc1-c4d4-4dd0-85ca-36389daa497d	         ▸ compiler                  0.0.29	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
3af4ac80-4984-4127-a079-ceb4223e2769	         ▸ @openfn/language-dhis2    4.0.2	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
12c2c7f1-b37c-4345-9830-f5ab8cfb4606	[CLI] ✔ Loaded state from /tmp/state-1690350561-7-1mzxjop.json	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
7e1dcc96-67b1-4a4f-943a-b634b5826bd0	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
9d1fad8f-0315-4d9c-8713-7adec6637c6e	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
054bec93-035f-4c28-932b-178715206757	[CLI] ✔ Compiled job from /tmp/expression-1690350561-7-1pc5kes.js	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
0b103ec1-ca90-48e2-92f6-0fb16a166ff5	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
522dac29-9052-48cb-8715-7c740027fab9	Preparing create operation...	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
978fcdeb-4626-44c0-81ff-8c3acdf16d43	Using latest available version of the DHIS2 api on this server.	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
1db75e88-773a-40ea-b4c0-05813efe7164	Sending post request to https://play.dhis2.org/dev/api/dataElements	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
307e73e1-377d-4567-85bd-6e814b422b95	{	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
7eec619a-a9fa-454f-af71-d989dd6adab9	  "httpStatus": "Conflict",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
38a68c61-a7fc-4276-a632-490702313b0b	  "httpStatusCode": 409,	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
3f132b3f-b192-4d28-8c4b-129e672efbf8	  "status": "ERROR",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
d9916318-5e22-4ffa-a43f-27914029bf4d	  "message": "One or more errors occurred, please see full details in import report.",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
1a98a911-e1d5-4782-a7a9-40192c1af635	  "response": {	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
6db785fa-257d-4386-a266-37aa4bd664e6	    "responseType": "ObjectReport",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
a6bf1ecb-5e65-4282-88d9-42872d7f407a	    "uid": "JoHqLxF9BmN",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
fe2e7d93-0892-4fb1-8e9b-4e970250861b	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
1e5973f8-218d-44c2-a65e-a5283086c5d9	    "errorReports": [	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
264c609a-fe89-428b-ac52-7054f57aa9e6	      {	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
c3141ef1-6b1c-4a69-a96f-5eaac86ba1b1	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [JoHqLxF9BmN] (DataElement) already exists on object DJjX70H7lQ1",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
eb285cf3-3e19-4d59-aaee-5ac9e3dac89d	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
b78b1185-f1a1-47fd-90e5-170e91da9e6c	        "errorCode": "E5003",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
fe6ab7cb-6dd2-4f5c-ac70-15bddff810ff	        "mainId": "DJjX70H7lQ1",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
86422285-4e1d-4430-aba6-0775ddd73d1b	        "errorProperty": "name",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
08e990db-9339-431b-8ec6-20263b8860f8	        "errorProperties": [	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
c603b7a1-4ef9-45ab-b080-eba45b0f2770	          "name",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
f908dfcd-14ff-4a97-b430-bc49859b51f0	          "Paracetamol",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
e50b3a4d-55a8-4529-82a7-96d6d7df9e98	          "Paracetamol [JoHqLxF9BmN] (DataElement)",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
b4be7961-b98c-43a4-8d66-c7150fefce72	          "DJjX70H7lQ1"	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
5b1d1285-6af2-4b72-9cbd-c37e17c28c73	        ]	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
f332f939-6f1a-42fe-bf88-da9b06d8185a	      },	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
65db99b3-3a28-4d55-94d0-7988cee9bb49	      {	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
b9b60289-484f-4144-8838-68a179125557	        "message": "Property `shortName` with value `Para` on object Paracetamol [JoHqLxF9BmN] (DataElement) already exists on object DJjX70H7lQ1",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
22459dfc-b698-4582-a230-69bc0199a03b	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
dc4b218d-bf59-4f09-884d-5d04e47025f9	        "errorCode": "E5003",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
aacd5bf9-31b7-4409-9028-27bfe5db5375	        "mainId": "DJjX70H7lQ1",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
8953cef1-1daf-4c7e-96cf-bc7a077dd78c	        "errorProperty": "shortName",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
6a69644c-e51e-49d6-9471-e3d0949f0ee7	        "errorProperties": [	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
6cbc4bc6-b97a-4df0-9d03-09e94a6aaa21	          "shortName",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
b98fe60a-0555-47b6-92f4-e556ed8ae63b	          "Para",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
95229c3c-46c0-4d6a-b9da-8a941c0b6c55	          "Paracetamol [JoHqLxF9BmN] (DataElement)",	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
3b3dfd56-081c-4caf-a210-b58ec5ec4b1b	          "DJjX70H7lQ1"	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
6fc98c6d-a04c-436a-aa3d-67f5d74a93e0	        ]	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
caf9e57d-9db4-49c8-ad46-d65c7b0c10c7	      }	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
9a1b33e6-1c5f-44aa-88ca-6012850a73c8	    ]	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
3caba0ae-2032-4a5d-81a1-97901f377d06	  }	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
6dbe0b96-728e-413d-be04-4badfcfef02e	}	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
efc805f3-4718-4ef7-b0c7-388896c14c5f	✗ Error at Wed Jul 26 2023 05:49:23 GMT+0000 (Coordinated Universal Time):	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
9e9b3991-8e8a-4de5-bc2c-03e93e42e956	∟ Request failed with status code 409	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
f7ff16ae-e1d0-4025-864c-ff469312f4ad	[R/T] ✘ Error in runtime execution!	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
af761651-24f6-4991-8f12-bdd15d36a9a4	[R/T] ✘ [object Object]	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
14569c4f-f1f2-4ad7-9fd3-409d72be00ac	[CLI] ✘ Error: runtime exception	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
03222836-136a-4111-9528-9df8f7277bf2	[CLI] ✘ Took 1.649s.	\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
88eef94e-5140-41fa-9576-536b84a8c1ea		\N	a59e598b-7b62-4a9c-bd43-9b90b30d869c	2023-07-26 05:49:24
8ff11d2e-adc5-4cfe-98e3-b89064efacb2	[CLI] ℹ Versions:	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
d5e3f46e-380e-4fe6-adc7-b0240d5b3492	         ▸ node.js                   18.12.0	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
74dc5195-9f52-4d89-8525-36b087bee2da	         ▸ cli                       0.0.35	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
263b3226-f12f-4022-a3a1-54b2e2720049	         ▸ runtime                   0.0.21	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
c56c6d76-3a44-43e6-9475-8d1735bf6352	         ▸ compiler                  0.0.29	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
41d02505-7c23-4082-ae46-e9bf14738ea8	         ▸ @openfn/language-dhis2    4.0.2	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
591af089-259f-4a71-8577-f39ab3141d26	[CLI] ✔ Loaded state from /tmp/state-1690350572-7-12a6mrq.json	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
2fa539d2-83ec-48c7-bb61-5c530c1b8d9d	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
526d0141-63f1-40c2-9fe6-00c57f795ea9	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
8c2233d6-17fa-440f-b71f-59a6e6036c03	[CLI] ✔ Compiled job from /tmp/expression-1690350572-7-1r2hfgt.js	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
69c6b425-9aab-44c2-be4c-20c4e79d3913	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
236515a0-2921-4365-80d9-47cdfba843f8	Preparing create operation...	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
aae4780d-8f50-4988-9203-55404ee8fa1e	Using latest available version of the DHIS2 api on this server.	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
05275d66-5bd9-4edc-a56b-a62110f55b6a	Sending post request to https://play.dhis2.org/dev/api/dataElements	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
1dadaf15-3f16-41ec-9531-c9726f4f74b6	{	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
1a6c6532-0e11-4f10-b4a5-3c2ef7ed2a4b	  "httpStatus": "Conflict",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
eb32770a-7544-4b84-91af-227dc3b2854b	  "httpStatusCode": 409,	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
9a170034-2a93-4fa3-8fe3-30da640c5fc7	  "status": "ERROR",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
a096152f-d8d2-4bd3-8d6c-b55e125bf262	  "message": "One or more errors occurred, please see full details in import report.",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
de312b8b-cacd-4d8a-9f4e-f4e1c9344934	  "response": {	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
213866b2-e079-40b8-a688-8b7fc5bd3bed	    "responseType": "ObjectReport",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
bbc0adcc-a07f-450f-8d59-d22fcc372a22	    "uid": "gn3htS4PVoJ",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
cdc1856f-25d6-4633-b72c-284474a0147d	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
9c4501c1-f780-4d5f-a605-852da3b099e8	    "errorReports": [	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
bc85a833-e343-4c38-bebf-273e61f8ff16	      {	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
8e46443b-6558-49c4-9a5e-885fe8908f88	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [gn3htS4PVoJ] (DataElement) already exists on object DJjX70H7lQ1",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
affaef6d-fda9-415a-8334-0dc837f96163	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
f3b8ea46-8a1f-4bae-bf65-a7f11067d2b3	        "errorCode": "E5003",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
9530994b-021e-481a-b276-5f19aafb72ce	        "mainId": "DJjX70H7lQ1",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
2ab7dd53-dc68-4ca9-a148-f70a9065a67a	        "errorProperty": "name",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
8487d7fd-6716-4c7c-9434-7a4126df00fc	        "errorProperties": [	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
da0b57cc-7467-4d04-84d6-3c270b3d5c4b	          "name",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
f63728d1-1cdd-4acf-9b7c-a528c74b48d2	          "Paracetamol",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
0ee4a3c6-5f19-4ebb-b258-511164c6441d	          "Paracetamol [gn3htS4PVoJ] (DataElement)",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
441c2925-4ee0-43b0-877e-ce8ef43fd66a	          "DJjX70H7lQ1"	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
8f475a73-688e-4b73-9825-465a9e15b7d9	        ]	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
469154e7-9c50-45ce-bf1e-128e41a7486d	      },	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
ccba2e29-1b53-498d-918a-a2582d53e5b4	      {	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
beebeaf3-78a9-44c7-86ba-b9afbc2581f2	        "message": "Property `shortName` with value `Para` on object Paracetamol [gn3htS4PVoJ] (DataElement) already exists on object DJjX70H7lQ1",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
c1ce2ad5-4797-4a25-b160-400e0482a539	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
d5f1e897-cfda-412c-86e1-453021034f4b	        "errorCode": "E5003",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
1f636e3f-05ae-4372-9bcb-bf8420efe309	        "mainId": "DJjX70H7lQ1",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
74f966d2-2b92-4ca2-a8b7-7808af87bac5	        "errorProperty": "shortName",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
e02305a8-b746-46c4-9921-56e45b5f3987	        "errorProperties": [	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
2c529001-664b-4152-a279-d95bc0753f7d	          "shortName",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
ad84fc92-df3f-4be1-8e7e-43c9796673a2	          "Para",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
3c07f016-9a4e-4a85-b71b-16fa1c110458	          "Paracetamol [gn3htS4PVoJ] (DataElement)",	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
e7fdb9e1-fbcd-4c80-910a-d2186ffc1aff	          "DJjX70H7lQ1"	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
eb6c3b5f-ca37-4d16-a0f5-ce53d6b5c96d	        ]	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
c3a1f1ef-dd61-4133-a015-77f2ab37cf2e	      }	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
b5edd764-97b8-4790-9b5d-5fed932a4443	    ]	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
37d4af2f-a4fe-48e8-a919-7b9e6c145309	  }	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
6237070b-7f73-44b7-8fa8-f871ca629b45	}	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
2d4eb2cf-c598-48ec-be02-33b3e6995853	✗ Error at Wed Jul 26 2023 05:49:34 GMT+0000 (Coordinated Universal Time):	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
3d7ccd3d-a455-4aee-8678-9a116bdbc0a8	∟ Request failed with status code 409	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
b19bd21c-3eaf-4624-b589-336af7260790	[R/T] ✘ Error in runtime execution!	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
e12fbfad-eaad-4974-b490-c1719346ad7d	[R/T] ✘ [object Object]	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
cfe178d5-4a38-4fe6-8d3e-0b58fcc2468b	[CLI] ✘ Error: runtime exception	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
a70ae389-b8ce-4298-a709-20eeded3af54	[CLI] ✘ Took 1.909s.	\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
1fe7cc38-2e5c-47d3-bec4-e9cffbcd140b		\N	f6893628-7602-43ac-b0be-5289ca211fec	2023-07-26 05:49:35
eb3d0f75-722d-4229-877a-9506a1ec785b	[CLI] ℹ Versions:	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
81289f80-283c-46ce-a79e-4ea4db475b58	         ▸ node.js                   18.12.0	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
f2780d0c-7832-4a25-af6b-397f845a36f1	         ▸ cli                       0.0.35	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
6ef41d55-6bfa-4953-ba5a-132eae1c13e1	         ▸ runtime                   0.0.21	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
f7515baf-e23e-4c7b-bc90-552028b8b131	         ▸ compiler                  0.0.29	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
e81e2f52-19ba-40ec-9fc2-8857342afd15	         ▸ @openfn/language-dhis2    4.0.2	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
0ba66538-5dca-4b01-9886-ae2f07005084	[CLI] ✔ Loaded state from /tmp/state-1690350694-7-onj93o.json	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
7c7d3354-ec0e-414d-b47e-c7cb56791862	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
b4f4cb9d-179a-4e7b-ae3e-3001f885beb9	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
181dbbe3-8bf2-44ed-8df0-f8af17312e66	[CLI] ✔ Compiled job from /tmp/expression-1690350694-7-j7mvqg.js	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
172e34f7-db2b-4dbb-9ac1-3ac7ee07289d	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
6760425d-532d-4f99-8d4c-bb0b3efedf97	Preparing create operation...	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
6c67f88f-9199-4953-bddd-357c89c8f0ba	Using latest available version of the DHIS2 api on this server.	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
6b0dd84d-1633-4cbf-aa7f-0ecc02603236	Sending post request to https://play.dhis2.org/dev/api/dataElements	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
f5161f52-1723-4981-909f-8ad224de9bbb	{	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
252a1776-c77c-4c50-bf30-88581f00c7bf	  "httpStatus": "Conflict",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
1e7bb5d5-a59d-436a-8d23-3bcf455ccaed	  "httpStatusCode": 409,	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
b8cedb3b-0c03-402c-9be6-e55e5f3057f8	  "status": "ERROR",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
5da48fc1-a08d-40c6-b6a0-45ae821e6edb	  "message": "One or more errors occurred, please see full details in import report.",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
dc303637-db85-4d94-80a3-c9abcc7e6504	  "response": {	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
6f7b17f1-d82c-40d7-baf9-da07fea6262e	    "responseType": "ObjectReport",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
99428b32-9ffb-4bbe-af17-7f3d0587f3e1	    "uid": "PXaGr8OzdJN",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
7c8e622f-16b6-42dd-8959-8aaae693cebd	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
a9450f32-7a32-4a2c-aca5-2eaed95f562a	    "errorReports": [	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
355930d6-979a-4167-bd66-f3fff95908c6	      {	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
4cadbd98-eb21-4364-b79f-f9467cbd4e5a	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [PXaGr8OzdJN] (DataElement) already exists on object DJjX70H7lQ1",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
d97f8cfe-2873-4546-a0ef-cae6a0d161a5	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
3dfa6465-c5a2-4340-ab91-57841d3cdda3	        "errorCode": "E5003",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
f6218b04-babd-4a82-a432-3bf754e4e7e1	        "mainId": "DJjX70H7lQ1",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
e7b7b079-d3dd-4ae3-812c-177cfa123191	        "errorProperty": "name",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
5d30a369-3adc-4ed7-b797-cf4715aea2fa	        "errorProperties": [	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
a8b39309-8612-438b-9f63-221f680fc860	          "name",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
0e57d4c1-5184-40e3-b5bb-4dbb3a631e36	          "Paracetamol",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
4ee5abce-a227-4fdb-a1ce-07a0b28be20c	          "Paracetamol [PXaGr8OzdJN] (DataElement)",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
edbb0c87-dc8a-46b5-a724-1696d618f187	          "DJjX70H7lQ1"	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
183e2ca7-dc30-4a63-8522-0d393b45b614	        ]	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
d184e227-0c02-410f-a4ab-b2dc153a0029	      },	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
fc5a9490-90a8-4e7d-8133-f5e3b8a03172	      {	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
381f346a-45b7-45e8-8d9c-f323a6fc7261	        "message": "Property `shortName` with value `Para` on object Paracetamol [PXaGr8OzdJN] (DataElement) already exists on object DJjX70H7lQ1",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
f1ca3951-f5fe-4980-ae85-5921e70c405a	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
d5e4c4c7-cbbd-4be8-81f1-3bbbbe297504	        "errorCode": "E5003",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
7fb8b8a3-eac7-4dc5-9270-55879b350c0a	        "mainId": "DJjX70H7lQ1",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
50f0832f-7ec0-4dfe-b9f5-f916a86b91f3	        "errorProperty": "shortName",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
955c8be7-7f01-4cae-a794-20927befaebc	        "errorProperties": [	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
a3c2c351-4b9e-4eb7-8e61-ff334beac2e0	          "shortName",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
256aac39-3d28-451f-8137-0fb18b6b5467	          "Para",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
1156a336-05d8-4e57-a24b-3d9dcbc551b7	          "Paracetamol [PXaGr8OzdJN] (DataElement)",	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
412949e3-c378-4c67-b7ff-8da7d482cd51	          "DJjX70H7lQ1"	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
eb04dbde-ab11-4f39-ada4-a05ceb93ba84	        ]	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
1ae0ec9f-0a68-4cea-9d1a-010ebd6bfdf4	      }	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
08ac4c17-1adb-4823-a58d-ddaa6e198bf7	    ]	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:36
831eedb5-8c36-4811-9fe4-9ca61c194717	  }	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
6b2cffea-91a1-41fe-818f-ba931a6cf563	}	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
32a94227-9b78-4fa3-aebc-d5cbb1710739	✗ Error at Wed Jul 26 2023 05:51:36 GMT+0000 (Coordinated Universal Time):	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
4deb19f3-6540-4226-b50e-7a1669eff5f4	∟ Request failed with status code 409	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
5029a8dc-9217-4659-be22-6936c843daa8	[R/T] ✘ Error in runtime execution!	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
93da419e-b7b4-47f3-957b-719e1d1e121e	[R/T] ✘ [object Object]	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
fda7339a-37f1-462e-a872-8b21d51e880d	[CLI] ✘ Error: runtime exception	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
ad7ecf92-7eb1-45ee-bca7-3fe6b9f6fa2f	[CLI] ✘ Took 1.656s.	\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
e081b71c-8734-4f48-9744-0222395335bf		\N	d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	2023-07-26 05:51:37
52d33a2b-f137-45dd-b47f-4f0246986a25	[CLI] ℹ Versions:	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
51410f59-ac6e-4360-b5a2-d7cf5f681617	         ▸ node.js                   18.12.0	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
666970fd-1402-4c18-bee6-2cf6fe932be4	         ▸ cli                       0.0.35	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
da634e47-3be6-4d67-a529-69f279ea373c	         ▸ runtime                   0.0.21	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
197df02e-2c4f-4bf7-bc14-c8c7d8726e57	         ▸ compiler                  0.0.29	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
4ad2b8e3-b3a7-4114-bb12-c11c25f49a8b	         ▸ @openfn/language-dhis2    4.0.2	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
09a2d0c1-a02e-4537-8188-962cfe0b493a	[CLI] ✔ Loaded state from /tmp/state-1690350834-7-1hegy1.json	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
3b0276e4-6c26-4036-9eb4-bd4e74bd7658	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
8ed1eb56-41b1-49a9-b4bc-d3067e1fc6fd	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
b8a221ab-714d-4020-bd2c-b1e4e680cb1d	[CLI] ✔ Compiled job from /tmp/expression-1690350834-7-w4g9er.js	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
f4c7ed7f-25cc-4802-a070-84df69fb1127	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
a8354748-6193-4cee-badb-0aab95dae9d4	Preparing create operation...	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
a64f58e1-1c3f-4feb-94da-f0663e1f3be0	Using latest available version of the DHIS2 api on this server.	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
be857994-9c57-42a4-8db3-c626c33c5bf6	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
f5c0d8f0-38de-4c4f-97f4-ea06ffb74a51	✗ Error at Wed Jul 26 2023 05:53:55 GMT+0000 (Coordinated Universal Time):	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
e9cb131c-418f-4a7e-b39a-5d9f188cf373	∟ getaddrinfo ENOTFOUND dashboard-visualiser-dhis2	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
fb35e8f6-1890-4987-bbae-5cc455fd37fa	[R/T] ✘ Error in runtime execution!	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
d9c32531-c173-48b3-a211-dfb48bdba8d7	[R/T] ✘ [object Object]	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
62923b84-808b-4bba-bd1c-a4cdeee1ae4a	[CLI] ✘ Error: runtime exception	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
7e11f8ef-29a0-4ebd-8fc0-5fe75a44e29a	[CLI] ✘ Took 451ms.	\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
4a9817ea-1c32-42d3-81ae-005b51f1f3d0		\N	beb959da-b5bb-462a-885e-b32c3c693282	2023-07-26 05:53:56
25a72f44-1abf-4d29-97ea-73ee12df9f86	[CLI] ℹ Versions:	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
7d6ac52c-b8d5-4679-98c9-7fe340b07c56	         ▸ node.js                   18.12.0	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
15071d23-4bdc-4e72-a0c7-46e435a42e96	         ▸ cli                       0.0.35	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
5074e3a3-b606-474f-a9dc-83f0971b9f25	         ▸ runtime                   0.0.21	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
8a5d76b7-9bc3-4e3a-99cd-ec979c0c242f	         ▸ compiler                  0.0.29	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
163be513-5bcc-4af7-86c6-cd4f2040d7a1	         ▸ @openfn/language-dhis2    4.0.2	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
29052a13-5691-4f86-8732-fc717ac19225	[CLI] ✔ Loaded state from /tmp/state-1690351013-7-1x729qh.json	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
631829d0-d828-43a1-b341-f5663d630d19	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
2d60836f-ddfd-49d1-a553-5c3d5a296f7a	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
d40b617c-baf5-428a-8376-706fb6762970	[CLI] ✔ Compiled job from /tmp/expression-1690351013-7-azmncg.js	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
9a509345-3be2-40a4-896b-66ba74b5cabd	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
4d6ed781-00bd-46fc-9c5c-364e7dd78144	Preparing create operation...	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
801fde0f-00be-4729-9af5-62e66d6c7fde	Using latest available version of the DHIS2 api on this server.	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
e400bccb-f4c9-4bb8-a818-41ed2684c0e8	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
a6175944-53ec-4cb6-bbf7-ad3abe3c6e3f	✓ Success at Wed Jul 26 2023 05:56:55 GMT+0000 (Coordinated Universal Time):	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
774f8838-660d-4fc3-8eac-18db34f7dc6b	∟ Created dataElements with response {	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
f105cd4b-f840-4950-bf5b-8e57341ea526	  "httpStatus": "Created",	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
b80cb824-b49a-4df1-8ce3-7530da119ecb	  "httpStatusCode": 201,	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
ca6c60a7-4346-4630-bd79-cb59028ae512	  "status": "OK",	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
0e6b237d-0521-4d34-8d3f-f71913f685e9	  "response": {	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
f78e17c0-9d7f-430b-a1cb-fefb6aab9202	    "responseType": "ObjectReport",	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
4a63ad5c-c80c-4150-91f3-ea067b81af10	    "uid": "JlqsHhqMUVT",	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
94d4765b-78ae-47aa-bdee-0234f1eabd8f	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
41d4a398-ecba-4c56-876b-d7f6c3ec9d9a	    "errorReports": []	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
f89c23f2-3c08-403d-ab75-4cb9682811ed	  }	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
ba4625ae-c12c-4a04-a7e3-b262ba03991f	}	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
5f75e3bf-3c61-40e9-ace3-25959a099c7c	Record available @ http://dashboard-visualiser-dhis2:8080/api/dataElements/JlqsHhqMUVT	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
7bc91a5d-cce1-43e9-bfe7-ec8d6eed658e	[R/T] ✔ Operation 1 complete in 1.064s	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
870719d9-e018-4b85-ab27-2bff0e35931d	[CLI] ✔ Writing output to /tmp/output-1690351013-7-1eozmh.json	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
b4406e3e-6123-4b2c-84bb-a31eae257b31	[CLI] ✔ Done in 1.499s! ✨	\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
7ebffb46-1b18-46c8-a79c-1e4bc39d2d59		\N	b24125cf-23ac-40bd-b401-64a361bd421a	2023-07-26 05:56:56
3ffdabd7-5a49-4537-ac72-81e771e96f63	[CLI] ℹ Versions:	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
2df7cb72-fa61-4f10-930e-ce0792cb22e0	         ▸ node.js                   18.12.0	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
4d101e48-25d6-4d75-8a94-31a2d6b6fefc	         ▸ cli                       0.0.35	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
48637e68-8e2b-4173-8375-0b45e7cc3194	         ▸ runtime                   0.0.21	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
dc5b3c6a-8a28-44ee-9c04-ca7de25e6bc2	         ▸ compiler                  0.0.29	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
7ff351b3-6538-469a-be2c-408e7d1b6ed8	         ▸ @openfn/language-dhis2    4.0.2	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
0358916e-8ff4-45b0-9c39-fa58754ac079	[CLI] ✔ Loaded state from /tmp/state-1690358329-7-15ilncd.json	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
a2b32abe-6327-42fe-9f9e-512e6691e906	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
3096864f-35d6-4c37-acb4-ca3a199c6027	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
058a5bac-d532-46fe-9f76-caf8dec127bd	[CLI] ✔ Compiled job from /tmp/expression-1690358329-7-e9dbm4.js	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
2b020536-d61b-4023-8fec-51af7127fbff	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
b3cdedf2-9c7e-4557-bb5c-372fad4f6009	Preparing create operation...	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
786e84ef-05c2-45dd-84d0-459dabed0dc6	Using latest available version of the DHIS2 api on this server.	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
205327bf-d523-4352-9e6b-d421fe60cb7a	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
4ac68f8a-47d3-41bb-b969-93519879c9c0	{	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
c1b99c5e-a4a3-428b-a52d-391f804b422e	  "httpStatus": "Conflict",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
4628c96f-e114-4660-888c-9a38b5026e0c	  "httpStatusCode": 409,	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
e750c769-8f00-4857-b224-2129ba88789f	  "status": "ERROR",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
08dab13d-d7af-403c-a63e-c2441608a778	  "message": "One or more errors occurred, please see full details in import report.",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
72365c58-0808-4a89-acd3-57256552c83d	  "response": {	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
ab78aaa8-33e7-49a9-946d-2545573ccbc9	    "responseType": "ObjectReport",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
43e4eb26-d634-4bc1-a9bf-703e58f2bb37	    "uid": "BAY6hDu6rJL",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
3a379d17-f909-4c16-bd45-1b44dd7aea37	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
d8cc27c8-7579-4b92-9644-ce4553f9bff8	    "errorReports": [	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
3cf15fe4-1d24-42c5-927e-083f9c659782	      {	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
87f12fbc-d45c-46b1-bdc0-35f1b75bd0aa	      {	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
68acc225-b209-47e5-b5bf-e87281b817cc	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [BAY6hDu6rJL] (DataElement) already exists on object JlqsHhqMUVT.",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
741a1d7c-25f1-4810-bf58-1f2058d5a64b	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
9657523d-3bf6-4e38-ad27-cdcfefb01833	        "errorCode": "E5003",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
3f8a09db-15cc-4c1a-b625-10d10b932c1c	        "mainId": "JlqsHhqMUVT",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
e6e97d48-5506-415d-b976-5feb1aa6fc57	        "errorProperty": "name",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
95a30c63-ba81-4cbe-894e-72ea897d48ec	        "errorProperties": [	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
a4ae33dd-2570-44d1-8f70-92d6a5de59c6	          "name",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
2879f1e8-c8fa-4f75-950c-d27dcb9e9ada	          "Paracetamol",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
1c80e532-8294-4d5f-9f23-a3ae55b79b33	          "Paracetamol [BAY6hDu6rJL] (DataElement)",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
77f718b6-48e6-4084-824d-4d65fc97bcb4	          "JlqsHhqMUVT"	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
7d55da6d-0c48-4936-8f04-59ff96a41b34	        ]	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
c9581b9e-6f1b-4384-90eb-c11bd454fc53	      },	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
19ec77e6-82b4-49e1-9755-ca45fdfda37b	      {	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
064f8ef3-0cfb-48bf-847c-9942257d8299	        "message": "Property `shortName` with value `Para` on object Paracetamol [BAY6hDu6rJL] (DataElement) already exists on object JlqsHhqMUVT.",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
c29dd4a2-3203-42bd-90dc-4d04b353efed	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
eb2271ee-fcda-45a7-aa24-46b79d0d8de8	        "errorCode": "E5003",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
3ad2bbac-900b-4dcc-8e89-3fe0065b73c4	        "mainId": "JlqsHhqMUVT",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
a7be0836-6a0a-4c62-87c3-8737730a09aa	        "errorProperty": "shortName",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
c5a95a6d-b9e1-4b29-839b-7ffe8cdaef71	        "errorProperties": [	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
1cb54b19-acef-4e68-b88a-68183fe77f56	          "shortName",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
1ceac002-4d11-421c-a33c-7304c8668e4c	          "Para",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
fe6bcbfb-16a7-45f5-b50c-00b27ab9ea54	          "Paracetamol [BAY6hDu6rJL] (DataElement)",	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
596003de-fba4-4978-970f-a9e6ff34abd3	          "JlqsHhqMUVT"	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
fed3ab4c-2500-4ad9-891e-42c145d44964	        ]	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
fc830776-9ea2-4e1b-8a86-c2d79f4c93a7	      }	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
41728ce4-0886-406f-9b56-c686665aed11	    ]	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
1bff209d-f769-440b-91cf-78035fbceaee	  }	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
7de4b7b0-33d4-4e6b-8314-bba43ade6f94	}	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
9bbda38c-835a-44dd-8356-b47dd976967e	✗ Error at Wed Jul 26 2023 07:58:51 GMT+0000 (Coordinated Universal Time):	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
4748cc1d-6280-4efa-b8bb-3c7b30bf79a2	∟ Request failed with status code 409	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
fdb31c9d-642f-4d70-8d63-302f91b5bf7d	[R/T] ✘ Error in runtime execution!	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
c4ca4916-c268-4954-bbc6-d79ddd37cd2d	[R/T] ✘ [object Object]	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
271da1db-e2a9-4237-8f88-63b05b26d45f	[CLI] ✘ Error: runtime exception	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
67389351-c0f0-4a0b-86bb-347352bfb5ce	[CLI] ✘ Took 731ms.	\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
dc4b7858-0ca0-4a66-a18e-9351e5999ff3		\N	31cf94cb-e574-4ef6-b825-fd2c2214cf6e	2023-07-26 07:58:51
9b8fcc8e-aaef-45a6-b093-e3bb9b104358	[CLI] ℹ Versions:	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
30681554-749f-4ccd-a5e6-70862b9f8176	         ▸ node.js                   18.12.0	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
8fb8252d-366a-4d13-a384-8b5e483c135e	         ▸ cli                       0.0.35	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
6377b498-a5f1-471d-895a-85effd477fff	         ▸ runtime                   0.0.21	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
2e29e30e-938f-4dae-8ce6-adc81d56c00e	         ▸ compiler                  0.0.29	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
853aac38-a9ef-431d-a746-3f11652c8e85	         ▸ @openfn/language-dhis2    4.0.2	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
5271a205-4792-4dac-8bfd-94cc6b719a64	[CLI] ✔ Loaded state from /tmp/state-1690362445-7-1aacml5.json	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
319ea968-2754-40cd-8565-e3467135f983	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
a1d17118-7cd9-470c-beff-a1606516ac3e	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
7bf33825-39ff-45d8-a876-9d0f3a55b05c	[CLI] ✔ Compiled job from /tmp/expression-1690362445-7-lz25vj.js	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
eee6ce15-39b9-4ac3-9f8d-0fe392473ae3	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
5742b714-b4a6-4a4f-ba87-a853193c6b0e	Preparing create operation...	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
94894253-f21a-477e-b64a-9f05bffaae97	Using latest available version of the DHIS2 api on this server.	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
2acc53f8-36c2-4709-b9ca-10433b8c9fe9	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
bc315fbb-e185-4c0d-ad30-486aac115ce3	{	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
de3b8e40-8575-402b-9126-68a805cbcbb2	  "httpStatus": "Conflict",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
2c84ad80-355c-4673-ae91-3cccd86bb618	  "httpStatusCode": 409,	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
46ca2a1b-3335-4856-996b-1a85bdbefb42	  "status": "ERROR",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
fa1f009c-dcf1-49bc-b0bc-d916176ca63e	  "message": "One or more errors occurred, please see full details in import report.",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
bfe46a02-c2b4-4b5c-b1b2-b08f16e44438	  "response": {	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
96896e6f-fdb5-4703-8419-c08334385c4b	    "responseType": "ObjectReport",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
4dc03169-71cd-4106-a22f-fd55806d6a7d	    "uid": "OydV0ltCgPJ",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
d4e93098-d681-4bd5-a0f4-d5d5cd908828	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
b4227289-afa4-4409-b7ea-b5101d9ba8e9	    "errorReports": [	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
951d468b-d189-4f2c-ac0f-caca6b53b922	      {	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
45b26978-9dc6-4004-ac67-4845551ec2fe	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [OydV0ltCgPJ] (DataElement) already exists on object JlqsHhqMUVT.",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
8831fef9-e929-4a34-bd17-5fd42cf1a0f4	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
275357e5-2ac2-41a3-a238-a08801378147	        "errorCode": "E5003",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
b1c7c697-0d7b-4352-829b-e3e5c0162390	        "mainId": "JlqsHhqMUVT",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
ba7fb6c0-fa64-4b6f-8e53-9759b6bba9f8	        "errorProperty": "name",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
0f7b0bef-451a-43cf-81a3-994a6cb6e58d	        "errorProperties": [	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
6392d89e-c322-4073-bc85-8cb434702187	          "name",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
3f7d8207-1da2-4f68-bc6e-414eb8e09bf7	          "Paracetamol",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
d0e9fdf2-bdf2-4d68-8c4e-82770325f58b	          "Paracetamol [OydV0ltCgPJ] (DataElement)",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
54e3b7ae-ac01-4e35-b907-928b3f328e83	[CLI] ℹ Versions:	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
d84ab614-023e-4545-b1ac-29aa9f3e7c38	          "JlqsHhqMUVT"	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
a24e57da-84f3-4f6d-a41e-22bd74400d4a	        ]	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
8376a75f-e584-45c4-8925-b658342370d4	         ▸ node.js                   18.12.0	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
c35f4025-5cc5-4fbc-81e0-586795c7a393	      },	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
46c5a5f4-5d21-4693-9e83-7dae3d89aea2	         ▸ cli                       0.0.35	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
38f941ac-0635-4426-a4dd-345787ba31d5	         ▸ runtime                   0.0.21	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
72646e99-8f3f-4b54-b3a6-d00bc9df941f	         ▸ compiler                  0.0.29	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
69777dc3-f7b5-45dc-8e7c-f6ca91f4a31b	         ▸ @openfn/language-dhis2    4.0.2	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
3b737782-2f2a-4e43-99a1-ec5e4a24a1cd	[CLI] ✔ Loaded state from /tmp/state-1690362445-7-16eey9l.json	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
28b42c59-501b-4774-8772-5c5b4c488c44	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
b341bd17-0d0e-4993-bda3-3ce1dffce474	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
750506b1-4af2-41ca-baf1-3f7cb0534622	[CLI] ✔ Compiled job from /tmp/expression-1690362445-7-1i4qmnl.js	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
13477be7-feb4-4b70-ac59-8c9ac6bd6bef	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
3f85c183-0f82-44a4-a7a3-6137001369c9	Preparing create operation...	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
a74d02a3-69c2-48e4-8d64-0c60c3921c9e	Using latest available version of the DHIS2 api on this server.	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
b4b867d1-e935-438b-970a-e3b8a440d9fa	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
1f57ef34-e6bb-4acc-ac3a-362281709e43	{	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
1254e63a-d926-4479-8bac-2d1c68252aa2	  "httpStatus": "Conflict",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
eb98262a-519a-48ae-b192-7addd81668f8	  "httpStatusCode": 409,	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
6eac8581-d832-48d3-bd8d-d36227e36582	  "status": "ERROR",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
606b7f82-faff-48a9-9e2c-8c101f8fafe4	  "message": "One or more errors occurred, please see full details in import report.",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
6c04b31b-bc29-4be2-8013-4e74fd75e658	  "response": {	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
b37c7227-23ab-404e-9fca-b8336e9db42b	    "responseType": "ObjectReport",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
b3352190-a4ce-46de-9bfa-96ca5ce2a623	    "uid": "OJ1o42iSWbq",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
c1942017-938b-4d54-b812-7f922e7614ca	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
9165d664-7288-48e3-8dfe-141aba9b314e	    "errorReports": [	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
a697102d-a56a-4d38-b3d3-4ae8b5e6c97e	      {	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
6f8e12ff-f6ed-4a1b-9ae7-9807c661d12d	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [OJ1o42iSWbq] (DataElement) already exists on object JlqsHhqMUVT.",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
ddd18742-4229-4e18-b028-48d075cd8e31	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
310acaee-e20d-4d81-bc2f-569825bc3f8a	        "errorCode": "E5003",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
931a5f58-3109-4f7e-b0e5-7102ef3e0740	        "mainId": "JlqsHhqMUVT",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
72a0e0a5-c6b4-4d62-9a46-e4e109691e35	        "errorProperty": "name",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
b642c2dc-ea93-4a5e-aa2c-19b5a818ffc3	        "errorProperties": [	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
6854ba04-b2b0-4274-9d38-090a2b603114	          "name",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
6b2d9617-8211-4e82-abf5-cd9ebe0c3d75	          "Paracetamol",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
6acf4390-93e9-4ad4-a88f-717b21bd84ad	          "Paracetamol [OJ1o42iSWbq] (DataElement)",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
b079522c-563d-4cfb-939b-3cced5f5e320	          "JlqsHhqMUVT"	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
dfcf0030-f14c-4cbc-aada-9a44152bc15d	        ]	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
bcf83b31-47cb-4c58-bc2b-454bb31cb78d	      },	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
5e9488a9-1538-49d0-a63b-354268ea78d6	      {	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
84369440-9c1d-4743-805c-9b12e13dcb35	        "message": "Property `shortName` with value `Para` on object Paracetamol [OJ1o42iSWbq] (DataElement) already exists on object JlqsHhqMUVT.",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
f4be1d0e-86e0-42c2-b2f6-cb3dd4563fae	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
23517ba6-e509-4da4-9342-e05e9bcdfbaa	        "errorCode": "E5003",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
b84cc62c-b425-45cb-b267-ad4cdc487f6f	        "mainId": "JlqsHhqMUVT",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
ce04ae6d-7af8-41a7-a0d5-e5ed85bd6af0	        "errorProperty": "shortName",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
3ff447ab-24da-4490-bc19-93978fb8cf6e	        "errorProperties": [	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
4b29d72f-09f3-4091-9bf2-91e7fc930304	          "shortName",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
d3757943-906a-4902-8250-e82a77c10383	          "Para",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
d5b01e5e-eb8c-44f5-9bf5-b62fa214293a	          "Paracetamol [OJ1o42iSWbq] (DataElement)",	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
b1395de2-3878-4225-a1b7-c1f63f2ea62e	          "JlqsHhqMUVT"	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
e0400b9c-c3ef-484e-b057-cc96ee993cbc	        ]	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
6da31711-5c99-4f16-be4c-3ef60532f504	      }	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
4f58994a-fa8c-4b94-9fb0-65445b279edc	    ]	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
6d8c3f57-6c0f-4def-a56e-8ee879090ffd	  }	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
f339e452-899d-40bd-8031-1d85e04d9aa5	}	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
1024eaaf-93cb-4fee-a0ae-8e7085c4090b	✗ Error at Wed Jul 26 2023 09:07:27 GMT+0000 (Coordinated Universal Time):	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
21388dda-74b5-4bcb-ae11-d0da275150b0	∟ Request failed with status code 409	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
7951a6e1-22b0-4081-98a9-903bd8e17f7a	[R/T] ✘ Error in runtime execution!	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
3b95e3ac-9697-444f-9d2a-2eb59da13ab7	[R/T] ✘ [object Object]	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
34d417fd-2162-4cc4-957d-ebaacc4484df	[CLI] ✘ Error: runtime exception	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
ccbb4208-adb8-4626-982c-4f8d67433773	[CLI] ✘ Took 938ms.	\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
7684f9e5-7bf3-4cad-a570-964820c52c25		\N	fc6ce658-02a5-4d15-b54a-9d9557b3a137	2023-07-26 09:07:27
2150ef9b-5cfd-4ccd-9f0b-70889263e247	[CLI] ℹ Versions:	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4589a956-d7a5-4f5a-b03a-0ecfad36b92f	         ▸ node.js                   18.12.0	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
c4a636fb-646a-4bcb-a5d7-5d7d28c13e24	         ▸ cli                       0.0.35	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
ad7656d2-3f71-49f9-80cb-fd2cc6fb4ad3	         ▸ runtime                   0.0.21	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
b25c2170-efe2-48f7-96e4-37e014e49056	         ▸ compiler                  0.0.29	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
47ee54b1-fead-4484-b80c-c1a2951282bc	         ▸ @openfn/language-dhis2    4.0.2	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
2a9f1622-7e85-4d80-8737-3d234d867191	[CLI] ✔ Loaded state from /tmp/state-1690439228-7-10nnugl.json	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
bebd6821-8f00-45d1-8f64-d0a10b01962d	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
92882b91-6ff1-4516-9ef5-45b009787925	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
abc727bf-7bb3-4c1f-a2f5-88c61cd9d0cb	[CLI] ✔ Compiled job from /tmp/expression-1690439228-7-1d3ah5a.js	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
18abedc6-2f64-4a73-8ef9-83849c08c80d	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
cacddcad-0c92-4e5d-94ed-6fb88b45dee7	Preparing create operation...	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
88376b2e-6cf9-47e9-8fe7-56a2160e15f0	Using latest available version of the DHIS2 api on this server.	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
797298cb-d7f3-41bb-8daa-3197ecf7ea8b	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
90122989-f8b3-4057-ba92-3ac8f7c69839	        "message": "Property `shortName` with value `Para` on object Paracetamol [OydV0ltCgPJ] (DataElement) already exists on object JlqsHhqMUVT.",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
83beae5f-2110-44e8-902b-28b830401f12	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
d790573f-2ad1-4467-b010-bc6c13cf267b	        "errorCode": "E5003",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
bf4e1daf-3ac8-4142-afb9-188e642bab4f	        "mainId": "JlqsHhqMUVT",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
b9de78d9-65bf-4824-852a-4b0d899f0283	        "errorProperty": "shortName",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
1646ffe7-f496-4887-8a9c-ef9cf1cae792	        "errorProperties": [	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
1aed93e2-c318-4c3d-841e-c9c3fe207069	          "shortName",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
7414f841-0631-47fc-8d2f-ddb4e0f2f610	          "Para",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
7547ecaa-187d-499c-83a0-73f5ae246999	          "Paracetamol [OydV0ltCgPJ] (DataElement)",	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
a7c9708c-3285-4dc5-b22e-b3fbbb71cfe0	          "JlqsHhqMUVT"	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
c26c2081-32e5-493e-abee-de74cad212da	        ]	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
57cdf757-1d86-4704-8e9c-13cffbd0e955	      }	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
0545f7bf-2316-4add-9f36-9aab41bc13f4	    ]	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
e59929bf-5ccc-4e8b-b071-0d06b9f9d02b	  }	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
ebedc6dc-b25b-40c7-a7d5-6252908876b8	}	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
26531e1a-e97e-45de-8d36-77fb03d1bd60	✗ Error at Wed Jul 26 2023 09:07:27 GMT+0000 (Coordinated Universal Time):	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
05752719-a884-49d6-9b5c-ad8ff9505cb1	∟ Request failed with status code 409	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
c16e77fe-ca8f-4a4e-97fb-eadf0dcce2f6	[R/T] ✘ Error in runtime execution!	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
ebcfa81a-f02d-40dc-be91-3f96fb9154b1	[R/T] ✘ [object Object]	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
d703612c-fe7c-480a-98e4-b8cd03abd7ce	[CLI] ✘ Error: runtime exception	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
e6c9696b-809b-44ea-a8d8-8e0bbbf33a90	[CLI] ✘ Took 924ms.	\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
302be478-a4f0-4be4-a058-fbf0dd610b95		\N	b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	2023-07-26 09:07:27
ad9702a1-424a-42ed-9089-bc1c259655e2	{	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
f9d43aa4-8a96-4b4e-b1b7-61f1458e99ea	  "httpStatus": "Conflict",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
46ee26f7-91ad-48f6-805c-20b4acff52ad	  "httpStatusCode": 409,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
df81bcd7-5a2e-4ae4-b8d9-6386faf01088	  "status": "WARNING",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
18e05ee7-09f3-4279-a9bd-82c9ecbc0bfa	  "message": "One more conflicts encountered, please check import summary.",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
98fadf27-64a4-4135-ba59-b93044be5642	  "response": {	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
a23330e7-88af-42ee-b813-cfebed1fc9ca	    "responseType": "ImportSummary",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4fe4b5f9-84d2-4ef8-a455-573cd2355a7c	    "status": "WARNING",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
a85f3ea2-c0a1-424e-a826-63af07f2c564	    "importOptions": {	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
463bcb97-ad7b-48ee-b7be-787dc54d251d	      "idSchemes": {},	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4edd03f9-f951-433b-9515-02fc4ce5aecc	      "dryRun": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
db29dd56-e4b0-4409-bab7-267c6443d862	      "async": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
b9fd00a4-ec3e-41c6-a32b-25233661bea0	      "importStrategy": "CREATE_AND_UPDATE",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
eb6681fc-8846-40a3-b76e-8f41776d5ace	      "mergeMode": "REPLACE",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4352eb7d-4c7c-4d1a-adb0-6566adcccadc	[CLI] ℹ Versions:	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
5e9353fd-f4dd-4299-9203-a26e45dec92b	         ▸ node.js                   18.12.0	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
9671ba3d-f231-4910-baf8-0c2b28f9f800	         ▸ cli                       0.0.35	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
94f687be-322f-4604-8fdf-fb0b919e8dca	         ▸ runtime                   0.0.21	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
4528e11b-b33a-41be-b597-47cff644d4a4	         ▸ compiler                  0.0.29	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
b8eb0ba9-596e-44d7-a463-549945935465	         ▸ @openfn/language-dhis2    4.0.2	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
1a27d008-4514-42b8-bd67-d1767f8d98c7	[CLI] ✔ Loaded state from /tmp/state-1690362445-7-ofhkkt.json	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
e9b41a69-688f-44c8-ac69-f50d780bf95d	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
f38b7afd-3ead-42c3-bac1-1b455c92e878	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
e2470707-8623-438b-b00e-6a76b836c450	[CLI] ✔ Compiled job from /tmp/expression-1690362445-7-9d2xwj.js	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
0a700bfb-d962-4d89-aa37-960b17b135ce	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
a938078a-8df4-47ae-8812-f0529d0c8ba1	Preparing create operation...	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
cc412922-7f13-4756-9518-687d6a1229e7	Using latest available version of the DHIS2 api on this server.	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
346b15e4-64e4-410f-b0e8-0aab64b1029d	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
5a709365-1134-44ab-857f-4cdab0b95ca1	{	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
3ebeb45e-2a46-407c-be79-6e2cd53c60e4	  "httpStatus": "Conflict",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
788281df-5629-44bc-8889-8263afb48921	  "httpStatusCode": 409,	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
474945e1-8f7b-4f79-86eb-68f466c56246	  "status": "ERROR",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
e63821c6-8e3d-4959-8455-84a413ee18d0	  "message": "One or more errors occurred, please see full details in import report.",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
b247cb77-ed4c-46e7-b673-a4445e5c29b6	  "response": {	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
777105d7-30db-4f63-bea9-782195d89d8e	    "responseType": "ObjectReport",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
a2544352-c575-4a1b-9aab-7be5c12a2e3e	    "uid": "OoPJUhHIVfq",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
a854dda2-11ca-44e0-a1b4-6b005dcfbdba	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
5f8df141-b8aa-4b96-91f1-08b4cf4de6aa	    "errorReports": [	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
3d50b6aa-10e1-466e-88ac-34799aefed5c	      {	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
6931defe-c950-4ca2-b701-31129f7a8226	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [OoPJUhHIVfq] (DataElement) already exists on object JlqsHhqMUVT.",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
0fdb9cca-bc32-4eb2-b045-54ca3ffec39e	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
950019eb-c04d-4577-8f30-b6509a170305	        "errorCode": "E5003",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
18fa9334-a58a-4c86-a14f-48739a9da37a	        "mainId": "JlqsHhqMUVT",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
c203e612-e763-423e-ab87-77cb3b823bb4	        "errorProperty": "name",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
129bbd82-4ec4-4eb0-89d9-28beb9920591	        "errorProperties": [	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
b14e0b45-584e-4de8-91de-91f507af3684	          "name",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
ba52565b-a867-4de3-a850-309c2aa91914	          "Paracetamol",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
3b620892-3501-4c24-8210-8547fd90ba33	          "Paracetamol [OoPJUhHIVfq] (DataElement)",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
34acb947-6b7e-4aee-aad8-410fa9625d9d	          "JlqsHhqMUVT"	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
3236a6ce-938d-48c0-8a3a-8b1c97cfd56c	        ]	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
bdd2abe6-283f-4665-972d-3e47d4980a04	      "reportMode": "FULL",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
ff66788c-0b2e-4dd7-a29d-94ebc7b43f6b	      "skipExistingCheck": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
0188446b-a192-4289-b819-52233eb41895	      "sharing": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
39d392a8-45ea-4f98-8501-2e6ade25b2ca	      },	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
0eba4814-265c-449e-98c8-2ebdacdf7f72	      {	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
e1273a02-79a1-4531-a9f6-488f729f0059	        "message": "Property `shortName` with value `Para` on object Paracetamol [OoPJUhHIVfq] (DataElement) already exists on object JlqsHhqMUVT.",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
3840a882-43f1-4905-92d0-46f111359d89	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
15431a58-ecec-4e0d-bd8c-9c749ad7205f	        "errorCode": "E5003",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
504c5ab7-5d58-40fe-9cb6-3a9eb46f484c	        "mainId": "JlqsHhqMUVT",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
97b716ea-b758-4974-8b68-b2a2b332a407	        "errorProperty": "shortName",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
bdce3848-5382-48d7-a209-5b7e11052204	        "errorProperties": [	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
3abb8e56-124d-4a03-8a54-ef6b80e8c2c0	          "shortName",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
7462b05d-9513-4d8b-b2a9-ac367f81d62a	          "Para",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
517e812b-ec83-4038-8b02-c6a784fb5c6f	          "Paracetamol [OoPJUhHIVfq] (DataElement)",	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
fd37ad6c-57e1-4ea1-835a-62e64628bafe	          "JlqsHhqMUVT"	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
332d336b-0cae-443c-bd25-b3a7568e2e93	        ]	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
c55210ce-9f34-4ac9-9b50-0a7701eb135f	      }	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
f0e8cf9a-2f7c-4de6-a8bb-ddc68eb3a955	    ]	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
c531a0bc-a337-4b0b-8d17-57bb762960e9	  }	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
a26e33d6-5c8e-4070-ad44-293ba5ad94b4	}	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
abb1bf2f-68be-403b-a2d9-caccd8e580b4	✗ Error at Wed Jul 26 2023 09:07:27 GMT+0000 (Coordinated Universal Time):	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
c71d452f-810c-4c94-9323-3f23e1146632	∟ Request failed with status code 409	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
c8ceb108-1167-4f40-86e1-0dc3f268ff0f	[R/T] ✘ Error in runtime execution!	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
061e4ccd-ed58-4b6e-949b-dac86fc27782	[R/T] ✘ [object Object]	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
9bfc37d3-6829-4b28-aa19-92486a925084	[CLI] ✘ Error: runtime exception	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
79d7dd12-e039-40af-a704-1fc1665d70b4	[CLI] ✘ Took 978ms.	\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
b0d10ce7-c661-417f-83cf-532d648e70a1		\N	e31e68b8-e35b-4c71-8db6-3d5771213484	2023-07-26 09:07:27
ef076fb7-36aa-4479-9d5b-b6a70e3e5737	[CLI] ℹ Versions:	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
b8bcae6d-5d3d-4915-b8dc-10c53ea375d6	         ▸ node.js                   18.12.0	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
76276f70-a5f0-4689-9e17-baab6775b5ce	         ▸ cli                       0.0.35	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
75cd4b58-f7cb-49ba-9f47-508c8a609219	         ▸ runtime                   0.0.21	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
d08bca9d-ba8e-4b71-9ea1-9bb6c8ecabda	         ▸ compiler                  0.0.29	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
9a972f5d-a9d7-4221-bb03-db29347a57ac	         ▸ @openfn/language-dhis2    4.0.2	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
4cc77d82-42a6-44a9-a10a-a025cc5c0255	[CLI] ✔ Loaded state from /tmp/state-1690362445-7-m4yjoo.json	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
2cddd617-8c28-43b4-a104-eacedb1161c0	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
a35fc75c-a5d4-4d6c-a404-c720c7769bcd	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
4b2d6a94-6e92-432a-aa6c-783b59161642	[CLI] ✔ Compiled job from /tmp/expression-1690362445-7-1ewvunp.js	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
55b7b0ca-5861-44c4-907d-426a6b998c4e	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
dbfc9644-37ca-48ee-9149-90c2c8c62e12	Preparing create operation...	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
ea587f12-a7fd-46c8-a9ca-7f035edf71cc	Using latest available version of the DHIS2 api on this server.	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
53c614c0-1dd8-456a-8526-074a3c4f79c7	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
197d8289-2ce1-412e-886c-fa48b4b3d4dd	{	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
fd248f7b-3b01-4895-8d97-5ddfb363fd80	  "httpStatus": "Conflict",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
94400d13-681d-4644-861b-56eaca4affdb	  "httpStatusCode": 409,	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
de1b7f43-222a-42b9-9ab6-c75a845d92fa	  "status": "ERROR",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
f3c3ae1a-d8b8-4c9d-b07c-5dc04ac17d78	  "message": "One or more errors occurred, please see full details in import report.",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
4a4cb5c7-47c0-4289-8df6-381e632ccaa7	  "response": {	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
7a1089b7-f862-45ab-bb4a-ef50afa2ecd9	    "responseType": "ObjectReport",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
8bab7a11-f192-4e64-bde2-95f2bcfb1508	    "uid": "XjbyPtSZt9E",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
e5b1e4e4-04cb-4529-8a47-53afcf00617f	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
7ecc51be-de3e-447a-ac61-eb0c280632fd	    "errorReports": [	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
b673f713-fd7c-4fdc-bd32-d5c75d66ae3d	      {	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
b11b9cd3-d40e-4f96-ba48-0252d392c2c8	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [XjbyPtSZt9E] (DataElement) already exists on object JlqsHhqMUVT.",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
e692effd-fdb9-4797-843e-f82c150a522d	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
c35ac01e-4089-4373-9309-0d515cd8f05d	        "errorCode": "E5003",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
99f7dac9-16c5-4932-b76f-9154da99ac08	        "mainId": "JlqsHhqMUVT",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
2d74be1c-c589-43e5-bca7-8c39b968099f	        "errorProperty": "name",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
887a4106-a026-4f7b-8e6f-8fecef83fcd5	        "errorProperties": [	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
23be67a4-b91b-45e6-9afb-81cde0881c7e	          "name",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
9fbfa956-23fc-43a6-b370-a4200834f321	          "Paracetamol",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
bb5ba6e5-0b1a-4661-a2a8-95917b303958	          "Paracetamol [XjbyPtSZt9E] (DataElement)",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
6a0997ea-389f-4d64-be56-2420393814b7	          "JlqsHhqMUVT"	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
8eb2b381-0aa4-43ba-8ee3-09157b3ac184	        ]	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
619a5f9c-87a2-478a-8f74-e8bdd2a8e5fe	      },	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
439f921f-c1d9-4407-b22b-1bf1ee27bb3e	      {	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
42433e9a-6819-4278-b43c-189a2681f5f7	        "message": "Property `shortName` with value `Para` on object Paracetamol [XjbyPtSZt9E] (DataElement) already exists on object JlqsHhqMUVT.",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
ee95c565-a728-45fa-a9a0-666ffebb5354	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
f40787bd-6b56-4955-acb6-1f6e091b7d60	        "errorCode": "E5003",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
3beb80bf-9dc1-4e5e-8101-eb2773d4b364	        "mainId": "JlqsHhqMUVT",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
346605f5-ff5a-4c67-a617-7525ab67e76a	        "errorProperty": "shortName",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
32e30338-a5ee-4b59-bf59-b0208dc53a6c	        "errorProperties": [	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
92c2c183-3ca3-4ee7-bb48-e13f165785ee	          "shortName",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
662ddddf-7e57-40d4-8611-ec44d34aa4fe	          "Para",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
c2f2bc67-3f73-4f90-b5d1-8e6d296299ab	          "Paracetamol [XjbyPtSZt9E] (DataElement)",	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
4b6d8bbd-949e-4b4c-a015-2cd9140d4d80	          "JlqsHhqMUVT"	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
66ead099-a424-49b9-8568-38f481d8bc3d	        ]	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
a7e503d6-f7f8-45c1-bd78-75094b7abe59	      }	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
7cb2e9f3-aa45-4e4e-85b5-118fac46e714	    ]	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
d970aefe-20bf-4fe7-becd-33aa73ed74ac	  }	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
09205c92-dbd0-42d6-a71b-3c2da518d929	}	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
9746a69e-9327-4b5e-82a2-2fba1c83cb8d	✗ Error at Wed Jul 26 2023 09:07:27 GMT+0000 (Coordinated Universal Time):	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
4491a9c9-5fe0-485f-854d-f36191e6b889	∟ Request failed with status code 409	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
7074ee11-c4f2-42bd-8277-9ed85abb52ce	[R/T] ✘ Error in runtime execution!	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
f061f7ba-9bef-4a2a-9f45-2fd12db592ee	[R/T] ✘ [object Object]	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
8e488025-cbe9-4840-ac27-cc4915bf8e06	[CLI] ✘ Error: runtime exception	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
c97d329b-e74e-49c9-927d-8860ffef85dd	[CLI] ✘ Took 957ms.	\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
242aff81-b182-4e88-a454-8e0729db0f2e		\N	cf0da9f9-ae74-455a-a211-bc76f0681b89	2023-07-26 09:07:27
cc64b5b3-f1f8-4ec0-8f7c-a84db6175c55	[CLI] ℹ Versions:	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
2d9a0672-c384-48d3-9da1-15e946a7ae45	         ▸ node.js                   18.12.0	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
6bb47501-e365-4707-a4d5-06764928f224	         ▸ cli                       0.0.35	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
038368ba-eef1-499e-9f71-7b2ab095302a	         ▸ runtime                   0.0.21	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
91c04c5c-2d0b-42e2-b5d2-c2b46ee9e5e8	         ▸ compiler                  0.0.29	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
7c1c111c-6fa2-406b-8491-6776581cd7dd	         ▸ @openfn/language-dhis2    4.0.2	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
7433551a-cdf3-46b0-ba0b-f2ca5dd2b534	[CLI] ✔ Loaded state from /tmp/state-1690362462-7-xqxvnl.json	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
27510af3-1051-4cc6-9888-a674a958370b	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
bc12e20f-5296-4738-b481-4b510b65f241	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
69fb5f60-5571-4c9d-a983-0787923c1474	[CLI] ✔ Compiled job from /tmp/expression-1690362462-7-dlgjer.js	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
bd7d8f81-27b4-4d89-bbbc-79101adf91eb	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
cc7ebff2-688d-491b-b578-eb8abd9c4926	Preparing create operation...	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
2a63e12c-c26e-4bbd-90a3-8f2b860f5c7f	Using latest available version of the DHIS2 api on this server.	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
16447022-781b-403b-a426-58fef6ffd627	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
fa7d4747-e735-4225-8b6c-197eb1fb5634	{	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
089e60eb-aed2-49f0-9bd8-dfbf132407f4	  "httpStatus": "Conflict",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
e02eb52b-3630-4772-9e4c-d27dd48694b0	  "httpStatusCode": 409,	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
24825eaa-e3a9-4a39-9c6d-7a6e4a9733f9	  "status": "ERROR",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
f13228ff-333a-4a16-a47f-50b614d755fa	  "message": "One or more errors occurred, please see full details in import report.",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
b1ae1649-ddce-4036-92a9-424d4676436c	  "response": {	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
4eb17093-28a5-4d39-9bba-7939c12c43d8	    "responseType": "ObjectReport",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
3b71d2cb-aa79-4444-b0c7-6670debbf68d	    "uid": "YqT1cQ9x7e5",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
8ec25ee6-63b9-4ccb-b2f6-8e6b2be8a204	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
f1f01377-a4b7-4fb5-8db0-b05e706600ec	    "errorReports": [	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
bacffbd9-3d15-491a-9ba9-da998b785d79	      {	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
b897fb55-bed6-4e1e-a375-1eff1b981201	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [YqT1cQ9x7e5] (DataElement) already exists on object JlqsHhqMUVT.",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
552adeea-0bbe-4cd4-8f04-66e6951195da	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
d173f745-d0eb-45f3-94fa-045a999cb253	        "errorCode": "E5003",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
80874e2d-e0d7-406e-9835-88abe470e230	        "mainId": "JlqsHhqMUVT",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
52274d7d-1b62-4f81-a6c2-5c7831eb1b5d	        "errorProperty": "name",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
cccaf920-f946-45a2-b4f9-12c7647ea2c4	        "errorProperties": [	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
b6e77a3e-36fa-4fcf-b223-da5bad453b10	          "name",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
84983c2a-df31-4911-b08f-13d93d20b400	          "Paracetamol",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
98ed0398-5e12-42e5-98c7-039551c0e21b	          "Paracetamol [YqT1cQ9x7e5] (DataElement)",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
5fc321b5-c7f8-4784-9f25-3c243c712b83	          "JlqsHhqMUVT"	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
24fdf3e2-d38f-4fa2-85b8-b6a227481a82	        ]	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
0ad5c711-e16c-40d7-9660-fa69df324901	      },	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
df0d63cd-717a-4a84-8268-f8736681b4e5	      {	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
900c8177-002e-4555-beab-8c8c69a374ed	        "message": "Property `shortName` with value `Para` on object Paracetamol [YqT1cQ9x7e5] (DataElement) already exists on object JlqsHhqMUVT.",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
060aab5b-87fa-441c-8368-daf671e67afe	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
52b1d96a-112e-4327-8bff-491a1beabe47	        "errorCode": "E5003",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
b64c59a4-209b-4425-a075-2ce9281e1a68	        "mainId": "JlqsHhqMUVT",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
5301d937-89c4-44fc-a001-dbd1bb7c3416	        "errorProperty": "shortName",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
9a5f7e65-5a4a-4de7-8efc-61e6adb66429	        "errorProperties": [	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
6e9eb168-30cb-421f-8c15-4868d4029eca	          "shortName",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
3bd93a39-4247-4a4a-b6f3-9ac4f2d00b56	          "Para",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
4dd8d60a-e025-4f9b-afd2-0a73cadcc212	          "Paracetamol [YqT1cQ9x7e5] (DataElement)",	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
c32bc420-6b26-4b59-98ac-df47c7f9b4e1	          "JlqsHhqMUVT"	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
4ead2d42-7920-4d33-987d-f6e4741e10b9	        ]	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
305d9846-39d1-4e0d-b9b8-4fce886514e3	      }	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
ca93de09-3603-429c-9952-e435ba2db3e4	    ]	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
ec506088-a058-4b88-99f9-f0dae2cd7cb8	  }	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
c77a0635-934e-48a5-9e0d-d1a4d0d11901	}	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
8b766251-3652-4e66-96ad-04d890487be3	✗ Error at Wed Jul 26 2023 09:07:43 GMT+0000 (Coordinated Universal Time):	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
38d87ceb-6b79-4379-8489-ea1cce671fee	∟ Request failed with status code 409	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
b45b29f0-db55-4f92-88d8-026a56dd31e6	[R/T] ✘ Error in runtime execution!	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
bb45a421-5d46-43fb-9a0d-7252eda61e79	[R/T] ✘ [object Object]	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
0d0242fd-2d58-4737-8e38-44ce1e37ebe0	[CLI] ✘ Error: runtime exception	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
09bb48c4-d44e-4d5b-8c4f-ab128de31d47	[CLI] ✘ Took 594ms.	\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
c53138dc-8702-48b8-860e-6e0076deb301		\N	f95d4a4d-f69c-4be9-8953-472d77aeb963	2023-07-26 09:07:43
2aaba334-17dc-44a3-9d1b-986c028e020c	[CLI] ℹ Versions:	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
15937001-3069-4506-a2f6-c9e8592e7cdb	         ▸ node.js                   18.12.0	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
6b3e0981-6728-402d-b82d-2b5739879225	         ▸ cli                       0.0.35	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
2c8dba40-5023-49fa-837e-a379a3d371d2	         ▸ runtime                   0.0.21	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
e6516473-6eb6-43fa-b0a9-e68d14488e21	         ▸ compiler                  0.0.29	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
b2d09ec2-77b2-4f19-9310-2ddd39e584e7	         ▸ @openfn/language-dhis2    4.0.2	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
e8a701ed-26d7-4d88-aea1-1d149ce4b43f	[CLI] ✔ Loaded state from /tmp/state-1690363616-7-1dxf1x8.json	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
3e501ddd-65b0-436b-a08e-93b894585652	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
4c63d821-3649-42fe-a01b-6b7e1a854c91	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
5590f32d-b9ab-4149-93ec-e1d06111f6e5	[CLI] ✔ Compiled job from /tmp/expression-1690363616-7-i85gv3.js	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
f2b3d39f-33ca-460d-bed3-fb1199274a98	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
f1455a44-ece2-4dea-8fc0-d3c0fdc9e7f3	Preparing create operation...	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
45e802d0-73d0-4763-bb37-790dc7d5d6e2	Using latest available version of the DHIS2 api on this server.	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
f157ad7f-4c46-4dce-86ed-0707317e740c	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
29d0b634-b633-445b-9f9a-aa6c1519c804	{	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
81277be2-2aa3-4fcd-ba54-fd348714da48	  "httpStatus": "Conflict",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
299ac058-e63c-4331-9142-f634a387109f	  "httpStatusCode": 409,	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
bb915794-6b63-4c47-a762-818b1fd1febf	  "status": "ERROR",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
6f8a4176-2d74-4649-82b2-f761ebb3bb16	  "message": "One or more errors occurred, please see full details in import report.",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
a9b9d6ac-fbea-4b6f-b947-3b1ffb1f0acd	  "response": {	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
126e51d0-4732-45b8-9a9f-0eb922a7f686	    "responseType": "ObjectReport",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
7276a027-103b-4b90-9043-1eb7e07275a3	    "uid": "U4UN2j1cjL1",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
a5dfb7ec-1512-44c3-940a-716b1b798cc4	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
9af059b7-ad5e-4872-8e11-fb40feffe9b1	    "errorReports": [	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
d8a26774-dc7b-4c71-8fad-61e1af9b9ad3	      {	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
7dc67925-8ab5-4ee5-9947-f4cadd32e94e	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [U4UN2j1cjL1] (DataElement) already exists on object JlqsHhqMUVT.",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
6fd909ea-cf83-4b3b-86b3-c683e39af145	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
13998546-1df5-4bea-aebe-81cc87097eae	        "errorCode": "E5003",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
e6e19203-4409-4452-89a0-dfca193bfc9f	        "mainId": "JlqsHhqMUVT",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
5da98555-962d-45f1-b3ce-5659735197ed	        "errorProperty": "name",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
95e0b8c5-6fc2-461f-9bc6-01e377af6a0e	        "errorProperties": [	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
f84465c6-555d-462e-be89-374deddc141e	          "name",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
8a2e1a04-f894-4f61-8c73-bdbb7fb186c8	          "Paracetamol",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
6ddcec6e-8377-47e2-b0f8-662325e9724f	          "Paracetamol [U4UN2j1cjL1] (DataElement)",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
7399bd04-c034-4819-8ce2-848fb306b74e	          "JlqsHhqMUVT"	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
a0260b11-e2d2-412a-b1d4-c2a54734e718	        ]	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
51d26878-5302-49b3-acd0-fe3ed79191b5	      },	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
39fa5d69-f073-4871-8518-74da5a2dc991	      {	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
5a308261-cdff-4f37-9fcd-78e43341683b	        "message": "Property `shortName` with value `Para` on object Paracetamol [U4UN2j1cjL1] (DataElement) already exists on object JlqsHhqMUVT.",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
eab321e6-5192-4647-8b0a-3a199f9244e2	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
fbe5645a-203b-480b-a94e-bb60687a58f0	        "errorCode": "E5003",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
b4952f81-cb45-4192-9011-86da0d4340b8	        "mainId": "JlqsHhqMUVT",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
0dfca419-467b-4ea9-98e1-6816c1668650	        "errorProperty": "shortName",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
5dac3e64-c75b-4d6a-af83-54389ede6a57	        "errorProperties": [	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
0e4d222d-8dfd-477c-ad5e-618a8370338b	          "shortName",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
290bf23f-8013-429a-8365-b13e03a62564	          "Para",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
9f878044-19c2-469c-b473-db8e6e86560e	          "Paracetamol [U4UN2j1cjL1] (DataElement)",	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
d25b646c-f262-4496-b0d3-37f55bcee974	          "JlqsHhqMUVT"	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
06b225f0-a604-47b9-9af6-eebfe9076361	        ]	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
b200307d-9544-40a1-b657-2654fe8c18fd	      }	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
b0cabbfc-7354-4896-a750-08e8617d9c62	    ]	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
60e55cb9-0c16-47aa-a377-c6eba65faf67	  }	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
8296431d-1ef9-4351-ad1a-0666a568a08d	}	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
f9087715-57fc-4bac-bb76-12a17373195b	✗ Error at Wed Jul 26 2023 09:26:58 GMT+0000 (Coordinated Universal Time):	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
2142295c-b8b8-4c2a-9ad2-0d740bfa48e1	∟ Request failed with status code 409	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
27ff6455-f3dd-4370-8f8d-96232cd58d57	[R/T] ✘ Error in runtime execution!	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
3f88b251-80c0-49bc-85c0-6b3b24fb01e8	[R/T] ✘ [object Object]	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
8e5824d2-c4eb-440c-a01e-0e018b9fd868	[CLI] ✘ Error: runtime exception	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
ddd07a21-849e-4c26-9225-2f443d663c9c	[CLI] ✘ Took 583ms.	\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
816479bb-d420-42fd-b822-0332f8c00c7d		\N	5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	2023-07-26 09:26:58
91695db7-6a80-40da-92d7-06cef0bb231e	[CLI] ℹ Versions:	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
61726105-8d54-47e3-acea-0b8dd5564abc	         ▸ node.js                   18.12.0	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
a31598c0-0795-4c62-8a10-6bb236b51cb2	         ▸ cli                       0.0.35	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
5de2f430-cdf9-42db-be3c-c6b945e990f6	         ▸ runtime                   0.0.21	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
600f1bba-9c04-466e-8f90-9bfad3bf1949	         ▸ compiler                  0.0.29	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
bd8e03d3-8164-4000-badd-77aaeb5a68db	         ▸ @openfn/language-dhis2    4.0.2	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
6a56fc70-72d7-4336-a3c6-867eacb83374	[CLI] ✔ Loaded state from /tmp/state-1690364088-7-a5x7uu.json	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
6e8461e1-410e-45e1-8c89-da129e201fb4	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
7b365974-bd44-4850-9572-2aa60853352c	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
109e7433-301b-4025-bce2-5c4739f7d22a	[CLI] ✔ Compiled job from /tmp/expression-1690364088-7-fnj78o.js	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
b13d7c26-10c7-46a1-a6a4-5e724b0886a4	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
0b7fbce7-39bf-4a41-95de-426d84633452	Preparing create operation...	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
65172380-8df1-4c5d-af99-71633995a51a	Using latest available version of the DHIS2 api on this server.	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
8c960f5e-25a8-443a-99d2-eada069dfd85	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
1394201d-6a09-4d59-9efb-1dcdb47a9d22	{	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
3efebaf7-c299-45f6-b3ab-ec2511bb4da0	  "httpStatus": "Conflict",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
173df77a-b317-4ed4-814c-5e93d4544216	  "httpStatusCode": 409,	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
a351afaa-45e3-4510-97cd-a9f7a1195dfc	  "status": "ERROR",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
b51dc9eb-443a-4d7a-bc2c-28dd15e1cacf	  "message": "One or more errors occurred, please see full details in import report.",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
33358675-a081-474c-b0c1-ef76e8044912	  "response": {	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
e9ad9362-d040-4aa2-9b4e-1402a72b6fe3	    "responseType": "ObjectReport",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
a9d9a75f-c3d2-4fc3-bbba-5f80ff8b99a6	    "uid": "QUZNQD5Otju",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
a20bdc13-0d1a-4fc0-b995-a1f9185041c0	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
4cd2b294-b966-4465-9ffb-0a217897d77a	    "errorReports": [	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
24d668dc-0c35-4c13-ac80-2b726c8e6c3e	      {	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
66e4c635-1a80-4447-b32c-c20f8e3f1f64	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [QUZNQD5Otju] (DataElement) already exists on object JlqsHhqMUVT.",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
ef3472dc-3569-40e6-9cff-ab3c44101389	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
d130dd15-ea47-4430-9b1f-5e210494f487	        "errorCode": "E5003",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
7c70741c-8719-4e4f-b301-6ef83495be5d	        "mainId": "JlqsHhqMUVT",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
6087c48d-b2d9-4b35-8243-9da6f2469868	        "errorProperty": "name",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
16140b88-9dba-4886-86da-eb328abdce44	        "errorProperties": [	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
1ddb8780-9856-48a9-a23e-8e74abb8e52c	          "name",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
4d4e0ac0-c9cc-49f2-8c25-ab07a1ce46b9	          "Paracetamol",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
302b0d98-6f30-4c6b-8ad7-b7c3e71f6801	          "Paracetamol [QUZNQD5Otju] (DataElement)",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
e8441b2e-bfe6-4f34-a9b1-045d787cffa6	          "JlqsHhqMUVT"	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
374abfde-4522-42ed-9b22-9116ca7c384e	        ]	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
2c0a1895-c3c5-4e1e-bded-dce73d3ebae0	      },	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
24636cb1-c673-44a1-ab5e-4ff21ba9930a	      {	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
6556104d-3e08-49ac-afa2-c2e8e60ebe46	        "message": "Property `shortName` with value `Para` on object Paracetamol [QUZNQD5Otju] (DataElement) already exists on object JlqsHhqMUVT.",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
c4dbb57f-0c26-426d-aa55-439efe8989a5	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
0e4ce287-00f1-4a26-a331-3bf02379c79b	        "errorCode": "E5003",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
b716c6b0-c235-4f59-863e-6da26b9896ea	        "mainId": "JlqsHhqMUVT",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
c6039724-fa9d-4b1c-b4e6-2a87beb048d7	        "errorProperty": "shortName",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
7b0e6b99-43c3-4f68-a1e4-d46783cfff45	        "errorProperties": [	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
4e5c78aa-7b35-45a2-8e3c-d0c300eb0ce2	          "shortName",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
a76ef946-0dd5-4c3e-b885-04555b08a370	          "Para",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
50a8ed1d-c65f-4957-bf27-03f637b86e50	          "Paracetamol [QUZNQD5Otju] (DataElement)",	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
12e44d5a-eaf5-4cea-a098-f38fddaf535c	          "JlqsHhqMUVT"	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
753f713a-0df8-42bf-8670-8fb8e32e0f1f	        ]	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
fb4d6119-3493-4b8a-ba2f-860471d973ce	      }	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
780bdcef-386c-440d-b8fb-1da68929132d	    ]	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
64a89158-f6ff-46e6-80d1-5ee320bfae1b	  }	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
ac16ab75-ea51-43f4-97a5-db55cc1ebb0b	}	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
d568ad41-de87-45d8-9d34-2db4b28f2169	✗ Error at Wed Jul 26 2023 09:34:49 GMT+0000 (Coordinated Universal Time):	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
7cc320d3-2546-4af9-92c1-3babc2b2e29a	∟ Request failed with status code 409	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
02b985c4-f8bd-4c05-9d61-a89e3dafe3a7	[R/T] ✘ Error in runtime execution!	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
ff24d952-f267-4903-85e8-fa81e39bf78b	[R/T] ✘ [object Object]	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
d7ab2638-3991-4192-9a80-6cd8536e26c0	[CLI] ✘ Error: runtime exception	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
b91bdb9f-27a8-467d-b7fd-4ff60764c1e9	[CLI] ✘ Took 599ms.	\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
a5a3f101-fdc4-4bb0-9abd-eeefa31d5439		\N	f96de5b0-b415-43b5-89aa-8c24cee39b35	2023-07-26 09:34:50
99bc3b25-9e73-4597-bec6-4a42f7979b0a	[CLI] ℹ Versions:	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
cdf31b07-2629-4761-b54f-14e1d715df5b	         ▸ node.js                   18.12.0	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
fc09d997-ace4-45b7-adc3-7f723e58430f	         ▸ cli                       0.0.35	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
083ccbce-da0c-41c3-8cdb-37b97de0c941	         ▸ runtime                   0.0.21	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
3111795b-f792-416c-b2a7-c9e128da160e	         ▸ compiler                  0.0.29	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
40b1adf3-7464-485c-bbfb-007a11a1c668	         ▸ @openfn/language-dhis2    4.0.2	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
dd235aab-5e06-4a26-a0bd-7f0acf60b67d	[CLI] ✔ Loaded state from /tmp/state-1690364763-7-11qkama.json	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
bcea51ac-16ee-4c94-b741-589e79ced11a	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
37ef9998-2e28-4210-99a9-9f9f33966a8e	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
2cd0068f-2c17-43b3-bf38-a7a106a543e2	[CLI] ✔ Compiled job from /tmp/expression-1690364763-7-1rhsmpl.js	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
18ddbc51-2bd0-4309-a146-193ea6668744	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
16a00792-21e2-4e36-96d5-601c10553b69	Preparing create operation...	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
6b647ea8-a6cc-4fa7-87f2-9af3d052fd23	Using latest available version of the DHIS2 api on this server.	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
6ede216f-cfa3-4ba6-b4de-8bdfe4ab6dff	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataElements	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
89c18979-487c-492f-aa75-1b8e460df0ed	{	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
df55ef5d-ad6c-4b58-a71f-f28f80e33902	  "httpStatus": "Conflict",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
d81e43a0-dffb-4032-a119-54f531d73cc0	  "httpStatusCode": 409,	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
d0f77964-78e6-4a4d-94b7-e28d494d0e50	  "status": "ERROR",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
96fa4d8e-1ad4-4c73-bbe1-ad8b5862393b	  "message": "One or more errors occurred, please see full details in import report.",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
7c940cfb-ae28-4b00-8f2d-654b93a0191f	  "response": {	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
3509c3f5-8111-4a7a-88f0-7070cd306ce9	    "responseType": "ObjectReport",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
bd74e15c-7e97-4196-89f9-1d37fa7134f6	    "uid": "zJ3IM8gyLRQ",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
4ecbc85f-613d-482a-aa75-59a09c1cd13f	    "klass": "org.hisp.dhis.dataelement.DataElement",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
7ff7311a-e7c2-46f7-8805-c4e92bae09c6	    "errorReports": [	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
0a3b5a9f-b896-4be8-967b-57037bc6be76	      {	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
3c9edb17-c54d-4cf2-9a66-a3956bbd4ef1	        "message": "Property `name` with value `Paracetamol` on object Paracetamol [zJ3IM8gyLRQ] (DataElement) already exists on object JlqsHhqMUVT.",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
8c5512cc-a59e-4161-adfd-3f88db73d65d	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
8c1e4850-5cc4-437a-afde-454c05c594fe	        "errorCode": "E5003",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
d18c9dab-ccec-4957-b699-f3d264492e0c	        "mainId": "JlqsHhqMUVT",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
69e38da4-cace-4f58-a7b5-7793c774fa5e	        "errorProperty": "name",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
5299730f-0470-479e-846a-065d508f7562	        "errorProperties": [	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
d25a0490-4ef2-475c-8ed2-acfef12ec585	          "name",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
6f3f8cbe-da1d-49d8-9d49-059336cd34a1	          "Paracetamol",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
4ba12864-1989-4624-af11-3e8ff5ec8650	          "Paracetamol [zJ3IM8gyLRQ] (DataElement)",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
04b93533-b167-4234-907c-4b3da205d533	          "JlqsHhqMUVT"	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
7fe9e5e0-1b94-4f3f-ac4f-4134fd6fc44c	        ]	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
d43572bb-5a27-4082-99f0-b8d36c019b97	      },	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
c6eb368d-a77a-476d-94ca-de9fec71eb6a	      {	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
52314745-92e2-403a-806e-338e07d691c4	        "message": "Property `shortName` with value `Para` on object Paracetamol [zJ3IM8gyLRQ] (DataElement) already exists on object JlqsHhqMUVT.",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
60fe9e74-6df0-4c7d-809e-2cb601335537	        "mainKlass": "org.hisp.dhis.dataelement.DataElement",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
dfe4474d-d876-44a7-8810-dcea7051b70b	        "errorCode": "E5003",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
0ab74216-4032-498e-94b6-b428008bcc3f	        "mainId": "JlqsHhqMUVT",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
e7d8b573-920b-4872-8751-086486af8c7a	        "errorProperty": "shortName",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
55fcc86e-41e7-4728-b618-e967c12138bd	        "errorProperties": [	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
a2b880fe-de07-47e5-9030-ea6ae89cd86d	          "shortName",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
19a7adcc-4057-4b83-961b-515b93128550	          "Para",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
cc1d974f-ee50-4bd9-9fe9-f916120ec645	          "Paracetamol [zJ3IM8gyLRQ] (DataElement)",	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
36c1dbd6-6a20-470d-857a-337a7c08a043	          "JlqsHhqMUVT"	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
956f661d-2545-4cb7-8ac2-b104654a7f6f	        ]	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
2dc0f9b1-4a6e-49c6-b6f6-095606a4add4	      }	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
6a59666b-98e1-487e-94ca-ccc9658e795d	    ]	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
bf23803d-e1bb-4f86-a956-63edfb496109	  }	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
bf7c75d0-1ed3-49fe-9253-1bb22e9f795b	}	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
e70d4a4c-2144-4033-ba56-ae9770e5ee40	✗ Error at Wed Jul 26 2023 09:46:04 GMT+0000 (Coordinated Universal Time):	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
cd0e9a07-2b4a-4778-b770-309d8f3e6f47	∟ Request failed with status code 409	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
f5435335-640c-4ca0-83a3-a595a06fdda4	[R/T] ✘ Error in runtime execution!	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
cf803679-00d1-45b0-a031-ce53e54870fb	[R/T] ✘ [object Object]	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
1f44b698-0d3a-4baf-be71-f5506bf10b2a	[CLI] ✘ Error: runtime exception	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
7d50d0d7-509f-4575-b000-1c7f9c6824f9	[CLI] ✘ Took 568ms.	\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
5017904d-bc3b-4a21-9037-086dd73e22ea		\N	ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	2023-07-26 09:46:05
c91a1f25-7970-4a31-bea0-5f0cd11414d9	      "skipNotifications": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
657aeb75-09af-4a04-b8fb-8ade4a8f21cb	      "skipAudit": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
10393934-c049-4c96-9f57-52613a408596	      "datasetAllowsPeriods": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
1a76a82d-bb04-4d1f-9294-e08f076c4e1d	      "strictPeriods": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
57e624a6-f26b-4b1c-b09e-05da449ae451	      "strictDataElements": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
5072cf0b-4e0c-4da3-86c4-56f8f31739a4	      "strictCategoryOptionCombos": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
04ae8197-20ff-4168-9e6a-6a53b1e14c77	      "strictAttributeOptionCombos": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4b8bcc51-4930-4393-b7c0-e1a155e0baa0	      "strictOrganisationUnits": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
88464ff9-237c-471b-8895-e4f1f8d3a421	      "requireCategoryOptionCombo": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
54ac5475-9d6d-45af-a024-42f6730a7240	      "requireAttributeOptionCombo": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
7acb3cd1-ded9-4003-a342-7629fc36eadb	      "skipPatternValidation": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
d95cd9cc-0294-464e-8b0c-73bc259b8f0b	      "ignoreEmptyCollection": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
fca4476d-5ce8-4a8e-bdb2-b0ba91a8fe62	      "force": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
dc351cab-7e51-40c4-9199-f3bcbc24884a	      "firstRowIsHeader": true,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
0950897c-dde0-4f6c-b3da-723418a03335	[CLI] ℹ Versions:	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
a0542527-b37c-4794-988a-6a590916956d	         ▸ node.js                   18.12.0	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
c7eab558-a597-4dbe-a62d-27cd5d8d20ce	         ▸ cli                       0.0.35	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
7654162e-c107-4377-9d9b-e590312bb928	         ▸ runtime                   0.0.21	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
69f3f443-9279-49b3-9db4-2286866aa3fa	         ▸ compiler                  0.0.29	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
a5642859-4580-4427-82bb-9808f47e7aa2	         ▸ @openfn/language-dhis2    4.0.2	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
87d3e9e7-96fc-4dfc-bc8b-ee01bd2df2b6	[CLI] ✔ Loaded state from /tmp/state-1690384448-7-ci66vf.json	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
aeee41fc-b219-4a55-b41a-e9bdfc381696	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
e9361b5d-33be-4d3e-a974-32bc808c5c3f	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
ba3465b1-4e68-4331-9703-fbe4716de777	[CLI] ✔ Compiled job from /tmp/expression-1690384448-7-1kgyzba.js	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
60eb5257-e50a-45fc-944a-3bdac8223d6a	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
d8b0ce64-a5af-4078-b7b0-09de62492fca	Preparing create operation...	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
f1690d9d-a6a6-4b60-8aa7-ad5f8ed57ca9	Using latest available version of the DHIS2 api on this server.	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
2f586fd4-f75c-4c7d-9fb7-8c97ff3f472f	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
56065b48-c96c-4ab4-843a-6112b5788d0e	{	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
20647ef9-7eb4-4048-9d68-77fb67a46585	  "httpStatus": "Conflict",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
37dfe12e-2cb5-446b-9474-2388520e5eae	  "httpStatusCode": 409,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
f45b6885-2119-49c1-806f-6eff9aac1d90	  "status": "WARNING",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
9f8ef8c7-219b-4259-8166-26acb0fbe796	  "message": "One more conflicts encountered, please check import summary.",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
0eabdab8-c319-4274-9efa-b133b0bdd2d9	  "response": {	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
de34b94e-5258-4f14-89f8-8b99754170a2	    "responseType": "ImportSummary",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
392950a9-2865-4374-8b5a-4672e853b626	    "status": "WARNING",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
5663de3b-43a0-4721-b65d-52e5d3b34e50	    "importOptions": {	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
873188cc-8b27-4fff-b07d-1b62d5c0ab78	      "idSchemes": {},	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
527cbc69-f208-48b5-a088-816235e6c9c3	      "dryRun": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
812689f6-f301-44d0-ba0e-161507ce54c4	      "async": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
2876e22e-b0da-4c2b-bd77-89796efdb2ec	      "importStrategy": "CREATE_AND_UPDATE",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
2e5c4b70-8cdf-411b-94c6-60eae6c6ab64	      "mergeMode": "REPLACE",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
858aa5a9-c1a5-4412-8242-55981c1023ed	      "reportMode": "FULL",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
49eb1db2-1d60-4f26-9cc0-2e0949fccbce	      "skipExistingCheck": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
5d257ea5-be36-4f56-9f63-2e43fa1c755c	      "sharing": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
59792932-2971-429c-8267-eccc2ce91aab	      "skipNotifications": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
e2e629a6-aec4-44b2-972e-ad1e0fbcbfc2	      "skipAudit": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
ad626caa-e702-4aee-a3ff-f448a9a0cfea	      "skipLastUpdated": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
7aec9408-40a4-4acd-af4e-a4fd1a98f72f	      "mergeDataValues": false,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4b3e2846-a2b8-41d7-9df7-c6c86d6a84ac	      "datasetAllowsPeriods": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
710b4b45-be9e-44d2-900b-56fa7632dee5	      "strictPeriods": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
08b0b409-721b-46a0-a5f5-7065ee465adf	      "strictDataElements": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
3b911ae9-aea9-4e0d-befc-ef7168fa2434	      "strictCategoryOptionCombos": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
628eb5d2-90a2-4ba6-9271-62dc53cbcd88	      "strictAttributeOptionCombos": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
421d8d9e-6625-4c9d-9fb0-98a9e0193cc9	      "strictOrganisationUnits": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
80a1f9cc-e9ce-4ed0-b9db-6b629a0e47af	      "requireCategoryOptionCombo": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
0eb24f3c-d8dc-448b-8a87-a5941be96253	      "requireAttributeOptionCombo": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
4b8b9880-8d7f-4b12-beda-361c00f49c2b	      "skipPatternValidation": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
2d9a0262-c6b3-4e22-88b5-b7198045f63e	      "ignoreEmptyCollection": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
7ac7794d-da0c-4acb-831f-2a65342f0687	      "force": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
a75bc895-8557-49f5-b3cb-8d40481799b9	      "firstRowIsHeader": true,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
dae2fe88-19d6-4799-a471-5cb924fc0245	      "skipLastUpdated": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
54ec4060-d6d8-471a-b5b9-20a805cb2af0	      "mergeDataValues": false,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
64fd81bc-0ed2-4cc1-b752-4d07cacba72f	      "skipCache": false	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
76f95e3d-bf27-4ddb-b0c3-e26cc83a42cc	    },	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
9509af3a-82c0-44e8-8fcd-586cbe34e7d5	    "description": "Import process completed successfully",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
65a61917-b298-4169-87ad-d2ac27fca467	    "importCount": {	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
a48f3de4-b155-4c05-bcee-9598b02bf22f	      "imported": 0,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
00eb9842-da04-4197-b802-f2336a27f1e5	      "updated": 0,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
9ab4a7b3-34ed-4330-9915-34cd1d3cee6f	      "ignored": 1,	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
8991bc15-4eee-4d00-898a-6ce3a8ae52b4	      "deleted": 0	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
fff3517c-6a74-479c-8ae8-fc852cdf33a8	    },	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
2ce05875-30d5-408b-94ac-28efb76b0cfb	    "conflicts": [	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
e0440725-5c36-4228-afac-e13fd04aea04	      {	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
7b5a106a-9396-4e7c-afa6-77b7d90c0c8b	        "object": "Gmq3mzyN1MQ",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
01a35ea8-47bc-4fda-9a6c-a9e63b550a02	        "objects": {	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
935cca72-5342-4771-b2b9-c651f8505e65	          "dataElement": "Gmq3mzyN1MQ"	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
02068d05-1de3-4910-b3c9-1e69665d568e	        },	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
2bf6e2b2-7e26-4dc6-abf2-2ad92f2d546e	        "value": "Data element not found or not accessible: `Gmq3mzyN1MQ`",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
42880030-1fc1-4d45-9eb7-5b72c4003ed8	        "errorCode": "E7610",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
bdb9e65f-a80e-4f55-9275-0bec3745f198	        "property": "dataElement",	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
eee2376d-7b96-45d2-ad0f-46da0c68b624	        "indexes": [	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
e9076e4f-d726-42cb-8432-46e02c859a02	          0	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
9febd205-6f23-4ca1-8f29-6120b593591e	        ]	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
0942ed81-a739-4495-8494-ae5691688d2b	      }	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
8364e4a9-3e2e-456f-9955-78b30c8ac12e	    ],	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
1c40b878-cec3-45c6-82a8-ef90d3e7eade	    "dataSetComplete": "false"	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
5a4a93e3-1e1b-405b-8024-ee8714e4c45b	  }	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
c0243a7e-7088-4074-ad59-03779d1f9b3f	}	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
95f99bd1-e4ca-45ab-b0ab-89fe22e7e4b5	✗ Error at Wed Jul 26 2023 15:14:10 GMT+0000 (Coordinated Universal Time):	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
e784b877-16ba-4c78-8c6f-4e5371991473	∟ Request failed with status code 409	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
cdaa1035-92e9-4517-b213-660b82b7e0e8	[R/T] ✘ Error in runtime execution!	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
2ab25ccb-450d-4d0e-8ec3-a13383dc057e	[R/T] ✘ [object Object]	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
78097919-0bf0-402c-8c6b-6d1090f9c148	[CLI] ✘ Error: runtime exception	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
0df14f74-a705-4f7f-8b83-2671818ab1d1	[CLI] ✘ Took 752ms.	\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
fccdfe1c-4e2e-46c7-bba7-79ec2306494e		\N	461d2ea6-ed8a-4e36-8c28-60166d243eaf	2023-07-26 15:14:10
9b6dfbd1-21e0-452b-beed-35f162f06284	[CLI] ℹ Versions:	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
0cd3db9d-2bb6-4cbb-ab98-75407b4d4d81	         ▸ node.js                   18.12.0	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
49ce68ef-1af2-4a53-b85d-196d027dd5cc	         ▸ cli                       0.0.35	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
7a689781-c044-4bfb-9a83-911279d32147	         ▸ runtime                   0.0.21	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
65cbc344-2e13-4f9a-b65a-669b976e47a8	         ▸ compiler                  0.0.29	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
9ca28d9d-1018-4fdf-8264-a84adf065584	         ▸ @openfn/language-dhis2    4.0.2	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
e4d0adff-2ac9-48af-a27b-1de7ec16c75d	[CLI] ✔ Loaded state from /tmp/state-1690384667-7-1sidj27.json	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
c9cf6c5d-cc1b-4c1a-b0a8-6c5a8f290635	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
22e12ed3-5341-4f37-ae4f-acb462b6707e	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
cf19d6d0-3c5d-4dcd-b0da-e54d02181d30	[CLI] ✔ Compiled job from /tmp/expression-1690384667-7-pnm865.js	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
f982bc46-c1ec-463f-aee1-4caa14caacd0	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
79a3102d-4e0f-4aa0-8a33-c0326298273e	Preparing create operation...	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
44452f2e-38ce-4af6-a2fc-c1e59fb38ade	Using latest available version of the DHIS2 api on this server.	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
eb631e12-cdd5-4b15-93b5-aeeead9c7b3d	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
b87de0bd-5eeb-4318-91ba-b52aae59ed74	{	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
93feeb4e-0ed6-4785-81a0-7cf30c0998cd	  "httpStatus": "Conflict",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
a6dce858-e315-4bc3-9b80-ac5b09dbe689	  "httpStatusCode": 409,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
9ce39f72-984b-4f07-88d3-d43bfeff2728	  "status": "WARNING",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
3f7a5c99-b79d-4f28-855e-1d6436f7c347	  "message": "One more conflicts encountered, please check import summary.",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
1dbced66-3a7b-4274-8226-9ad50fe3b58b	  "response": {	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
8a8bebea-84fc-4d1e-bd58-344ef30c2924	    "responseType": "ImportSummary",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
8bc2aa50-d6ec-467a-b67a-5618b98878a2	    "status": "WARNING",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
350d3cea-8ec5-48c1-8c70-86ce5894833f	    "importOptions": {	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
ceaf4fbd-aaea-41a9-a360-a0566008bc9a	      "idSchemes": {},	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
3ee8c5b9-0bb7-4f50-a46c-48056315f6d4	      "dryRun": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
6b031423-95a7-4449-96ff-f7fb1fd33a25	      "async": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
670428bc-819a-4101-b353-13e41f6e6078	      "importStrategy": "CREATE_AND_UPDATE",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
61c683a1-52eb-47f1-b186-5f2cf5d7d9df	      "mergeMode": "REPLACE",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
60a72389-1fd7-4b58-a1ce-0121819206a2	      "reportMode": "FULL",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
83465574-daf9-4e95-9b6b-d0bcaf33b513	      "skipExistingCheck": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
386b0231-4c79-4ea1-acbe-5fde904299b4	      "sharing": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
7dbde6e7-dd08-4389-ba01-4861846d281b	      "skipNotifications": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
b07a9e08-5b3a-4e09-99a8-8a660d52828c	      "skipAudit": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
3b9a4575-dcdd-4882-ad93-6bd3b88a983f	      "datasetAllowsPeriods": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
332069da-da8f-41f4-9860-ca441e80691c	      "strictPeriods": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
4d240a5b-048f-4848-af1c-ba9e40199ee5	      "strictDataElements": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
d42531ef-9ebb-4b2d-81e3-68314741dbf9	      "strictCategoryOptionCombos": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
2307bf40-e09c-4562-9cd0-992e77e77317	      "strictAttributeOptionCombos": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
45c62bf9-3d73-4fbb-9381-48e0ae8d1360	      "strictOrganisationUnits": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
4db51ac3-0f0b-4cb0-8aa1-c52a5b32465f	      "requireCategoryOptionCombo": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
961ad062-afb8-47fa-8f97-a6318e362ec6	      "requireAttributeOptionCombo": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
8ba219fe-48f0-4f1f-83e8-c464695410a2	      "skipPatternValidation": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
1c5f5776-cb22-4091-8d2e-2e5d8d77b656	      "ignoreEmptyCollection": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
aba9b41f-8186-4015-a642-f1ac4f7069ea	      "force": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
fbae9594-9343-4547-ba05-e0ac4e20edb1	      "firstRowIsHeader": true,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
b6cca503-9645-42ea-b25a-d9c9991d61a8	      "skipLastUpdated": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
b1cd10c8-9d2f-41d3-b70c-5cff1187b891	      "mergeDataValues": false,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
eef3967b-fd06-4384-82d8-6f92f744f98d	      "skipCache": false	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
c6108c8f-0797-4687-813f-e7b4f921d66c	    },	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
2ded0327-8a95-4783-a8ba-2524995e612a	    "description": "Import process completed successfully",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
f24fc826-c88b-4fbb-bd9c-664c916b8fae	    "importCount": {	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
9df636e9-92c0-4482-b07a-99cfb7c3279f	      "imported": 0,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
d4053955-11fc-40e3-aa44-b35707855a4c	      "updated": 0,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
3ff18e76-dae8-417e-805e-adec50d59dbb	      "ignored": 1,	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
b22bafef-bbb6-4e78-b278-76ca430d4b46	      "deleted": 0	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
ea278737-67ce-4a54-bc53-f611f0304133	    },	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
6e6bc577-2ac8-4b73-9e59-ca16beeb443b	    "conflicts": [	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
759fc389-c2d8-4c1b-b51a-8ff344aa0c30	      {	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
294a2903-140a-488e-ad15-54703ddadf66	        "object": "Gmq3mzyN1MQ",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
42dadaa6-541c-4a57-ab06-41a615fbc7d3	        "objects": {	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
135d6f26-ba54-4a41-976c-4ce6cb4859c2	          "dataElement": "Gmq3mzyN1MQ"	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
c3f36a48-c08c-471b-bd90-e33afdf13352	        },	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
b6289741-04ca-4817-833a-5fbb06657acc	        "value": "Data element not found or not accessible: `Gmq3mzyN1MQ`",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
c46ee6e9-5ab1-466c-bb98-ef6687383ea8	        "errorCode": "E7610",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
8d0dcbc5-962c-4f4f-add7-9c5d39298e44	        "property": "dataElement",	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
2c8141da-4ded-433d-9aa6-efa3386e9c75	        "indexes": [	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
52fe3e89-8a73-4067-b237-7fc68b7319be	          0	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
f756fe1b-6274-4776-8acc-31e5de9d2829	        ]	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
f4162188-f279-4821-ade0-d1da404078e2	      }	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
93dfede9-8439-41a4-89cf-918c4ecbaef0	    ],	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
53d39560-32bf-4e31-8371-838793f80ddb	    "dataSetComplete": "false"	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
78cb687a-dd59-44f4-bb21-7a00ab919341	  }	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
6597e265-7c54-4006-b7f8-9b61aeb553e1	}	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
67f3be13-7a03-4267-a868-449281dde776	✗ Error at Wed Jul 26 2023 15:17:48 GMT+0000 (Coordinated Universal Time):	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
4557d5bc-d3bf-42dc-b644-9b08f4039cf6	∟ Request failed with status code 409	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
c1ed744a-dba7-44fa-b219-f128b82aca76	[R/T] ✘ Error in runtime execution!	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
efa47756-35fa-4bfe-8d02-97c8d3ea40a8	[R/T] ✘ [object Object]	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
f86e20ed-660f-4eda-9582-51a2041a0ece	[CLI] ✘ Error: runtime exception	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
d8055e31-2c87-4ba4-a653-056266f77308	[CLI] ✘ Took 599ms.	\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
a6dbbe79-90ed-4c5a-ac4e-6ad6156d3092		\N	c6b434da-281e-438f-bd02-e6d2df807b69	2023-07-26 15:17:49
b6fb9176-7133-450a-8801-8a3b8188a776	      "skipCache": false	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
9b4673d0-00bc-4c08-a753-d41b54d2332b	    },	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
e5bd9fe6-aad9-4e71-8878-518efe7b5e9c	    "description": "Import process completed successfully",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
aa568bad-0fcb-4a9e-97e6-f2238a1ca9ce	    "importCount": {	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
c5864df2-c9be-4b40-9d22-efaa7a635e60	      "imported": 0,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
ffc1d20d-0a2c-4590-82cf-efed64c9f45a	      "updated": 0,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4d7a9dfd-01dc-4ee3-911c-50d70792702b	      "ignored": 1,	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
1d6d61c4-4f44-41aa-af49-3d3b14f3f032	      "deleted": 0	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
cd4cb4c9-00f7-45ef-9a7d-c1e9e0519498	    },	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
fdb961ec-66e7-459e-8842-bc53ab193b75	    "conflicts": [	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
964924c1-aff2-490b-9fa0-caaa72ea7963	      {	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
86ff0f0d-751c-450d-a38d-6796f1906315	        "object": "Gmq3mzyN1MQ",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
b8785988-5256-4ded-a24c-80d9fb0ba44d	        "objects": {	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
18eda7f7-70c2-4b43-a3b2-509535009d15	          "dataElement": "Gmq3mzyN1MQ"	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
94050a5c-087f-4f55-b3ab-6066ac7028b0	[CLI] ℹ Versions:	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
308b8e58-81fb-4fe6-8f80-70c9a6f54aac	         ▸ node.js                   18.12.0	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
b231c77f-afd8-4ec1-9ed5-a82d8781140d	         ▸ cli                       0.0.35	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
9dd9918e-3540-45bb-a1a0-55ae67e0e4fd	         ▸ runtime                   0.0.21	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
c7905110-2d6c-483e-ac49-ab029660c26c	         ▸ compiler                  0.0.29	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
9b9ba3c3-1dc6-49bb-8f5f-d495a16316b2	         ▸ @openfn/language-dhis2    4.0.2	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
9ad1f31a-25bb-4722-bf11-f08cc8186adc	[CLI] ✔ Loaded state from /tmp/state-1690438693-7-t4t3jw.json	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
3beb1582-b713-45a6-bc71-eb143e5f4777	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
dc5c7733-7bc8-4c06-a377-ba2b14cded58	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
803018fe-510a-4a0c-a20a-9f7ede2ef145	[CLI] ✔ Compiled job from /tmp/expression-1690438693-7-1izr8g5.js	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
27148113-1531-4f81-bcb7-0e46f7e5467b	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
5cce18c7-f9e8-439b-9ef7-82aece2e38c7	Preparing create operation...	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
55032507-459b-4def-8690-cd43cdd8225c	        },	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
d9184044-afb0-49b4-87c2-9278ae5d2766	        "value": "Data element not found or not accessible: `Gmq3mzyN1MQ`",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
6c651734-29da-47a9-8d57-6234b76dabc0	        "errorCode": "E7610",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
98c1f89e-94ed-4ffd-8c51-2b12a7f44ef3	        "property": "dataElement",	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4fcee2b6-5e37-46ea-99b0-c08e5245814c	        "indexes": [	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
4829600f-26a6-407c-9e5c-03b60f3f65ff	Using latest available version of the DHIS2 api on this server.	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
2012dee5-2601-45aa-9c00-3a0e9cd61699	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
9771006e-a020-42b0-9c44-d07138513a43	{	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
c00c505c-a1b8-449a-81d6-25a636300303	  "httpStatus": "Unauthorized",	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
e3767e05-e2d0-4649-827a-d177e3a30e14	  "httpStatusCode": 401,	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
f86a6920-1888-413b-985a-246242ebc6eb	  "status": "ERROR",	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
af3ccc1f-4659-4e72-9608-c68029d7d26f	  "message": "Unauthorized"	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
9fa50e5d-c57b-43b8-ac3c-be836950356a	}	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
3dd2fffc-629a-439c-a666-6ab7021e5a71	✗ Error at Thu Jul 27 2023 06:18:15 GMT+0000 (Coordinated Universal Time):	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
4cd5e8ed-283d-445e-b0a8-be4297dbe231	∟ Request failed with status code 401	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
bbc03424-79fd-4dc0-91f1-7989fc7a73d1	[R/T] ✘ Error in runtime execution!	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
e5573a5d-ee0c-4429-a4b7-1c5d84265e7f	[R/T] ✘ [object Object]	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
0db7e822-0d95-44aa-a7ca-8786c94cea89	[CLI] ✘ Error: runtime exception	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
edcbbbc5-202c-4c1e-ad8d-9457a7324d7a	[CLI] ✘ Took 517ms.	\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
4ea54bdd-7624-455e-b694-c549f23fb007		\N	07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	2023-07-27 06:18:15
7493ab07-778c-4e70-a5f4-646394b7a965	[CLI] ℹ Versions:	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
61057f57-96de-4d4f-abb2-800ddab47a66	         ▸ node.js                   18.12.0	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
a017a17a-dac7-4123-aecf-547acdeb9646	         ▸ cli                       0.0.35	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
e41b8f5e-5707-47d1-a085-ef74b093429d	         ▸ runtime                   0.0.21	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
1dc963e2-e643-4a45-8ed5-130ef4d6b4c4	         ▸ compiler                  0.0.29	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
e1edffe1-759a-4181-b215-57eef6040d7a	         ▸ @openfn/language-dhis2    4.0.2	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
b13a00db-1465-4218-80e7-b734babcc488	[CLI] ✔ Loaded state from /tmp/state-1690438726-7-snczh3.json	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
5aa60f44-807a-4a4c-b7c7-142383befa0e	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
b0b5afac-171d-431d-9369-6b7a86b3603b	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
ab72f411-0dee-42bc-992e-c17285eacb70	[CLI] ✔ Compiled job from /tmp/expression-1690438726-7-yei3ua.js	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
bffb1e63-2cd9-4a8f-96a2-754d7a41ac1b	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
02a0ee2d-e78f-4602-8f13-22a0a28ddbc1	Preparing create operation...	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
15236531-f1a9-42ae-aef1-b96f2b5cabd1	Using latest available version of the DHIS2 api on this server.	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
7d3ffe5d-d951-4069-a1f1-a6448071f313	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
ef769d45-6895-4632-8d88-903dff561138	{	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
35b20e21-3347-49d8-9e51-66c7ba1416ee	  "httpStatus": "Conflict",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
30822abb-2788-40ea-a733-d0d5e93a2847	  "httpStatusCode": 409,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
27322b50-d6f1-428d-80bc-0b4970470f98	  "status": "WARNING",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
48457b7f-e056-423b-bd86-5049ea81a737	  "message": "One more conflicts encountered, please check import summary.",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
80143944-7acd-49e4-b967-6c046c179ef1	  "response": {	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
f33b3134-fea3-4764-9beb-a77d8bb05c37	    "responseType": "ImportSummary",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
489c4781-7570-4463-a12a-9fc3a69cd5bd	    "status": "WARNING",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
605f9229-a18b-4801-a188-44aa19d4d9b3	    "importOptions": {	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
7d24cedb-1b66-4617-a09c-62cf2fd8e8ef	      "idSchemes": {},	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
0fbcfb76-eeeb-457b-9f22-da2863f3e931	      "dryRun": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
eea0741f-0b3b-4b2d-bba3-d2ff4101970d	      "async": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
301514c6-0c3c-4f4c-8a9c-d05fb874468a	      "importStrategy": "CREATE_AND_UPDATE",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
4d8a2f28-ef64-44e4-b6ef-c8a64acc98fa	      "mergeMode": "REPLACE",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
2d79d242-a742-451c-aaea-1b097a1efa84	      "reportMode": "FULL",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
46212c54-7ff9-4add-a2af-5f4826e0ceee	      "skipExistingCheck": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
5e31d19d-0d98-4a42-88f6-ebb96913dd43	      "sharing": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
8e1de3d3-e743-453f-ba1b-f90d0582fdb6	      "skipNotifications": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
7d6b40a9-61f0-41ee-a0a9-3b116d5e380b	      "skipAudit": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
877516b0-5fce-4709-a40b-61dda8273212	      "datasetAllowsPeriods": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
975624a9-85e6-4e17-a600-16e7071d24c4	      "strictPeriods": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
a080042a-2653-4f10-beca-cef2ac5e2818	      "strictDataElements": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
c02ea568-d9c5-4b9e-a8f5-b8315b0a1fa7	      "strictCategoryOptionCombos": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
aba11e60-0554-4706-b4c1-54510732abbe	      "strictAttributeOptionCombos": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
2fcd5f31-4e52-42f9-935d-871fc6b28ed9	      "strictOrganisationUnits": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
9095a03b-75ab-4261-a7ce-27eb55d3f789	      "requireCategoryOptionCombo": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
6f2f8ce8-4e1b-4355-b248-7d005ec7bb45	      "requireAttributeOptionCombo": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
100ba174-a5ea-4f49-af7e-32ac76452b81	      "skipPatternValidation": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
c9c8d98b-307b-4758-a498-2fe25685b29d	      "ignoreEmptyCollection": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
9345245f-9306-4e31-9be5-0aade5eeb026	      "force": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
9f822da4-8622-4ea5-a1c7-62e7f8614abc	      "firstRowIsHeader": true,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
471ca6cc-865c-41b9-a0f1-a59e44dcb3a2	      "skipLastUpdated": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
ab2636fe-fbf5-459e-a1ae-bd519eafe5e6	      "mergeDataValues": false,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
86d15e36-9abc-498a-ac8f-17c3ec3d1a60	      "skipCache": false	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
29063a50-29f2-4ee6-a61d-49718927ff19	    },	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
d8e82bf9-732b-4218-8b19-4824fea088ca	    "description": "Import process completed successfully",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
147e8913-960e-4821-a838-0c6401e6bb07	    "importCount": {	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
909352e2-4cec-4857-b2c2-049b717016e4	      "imported": 0,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
7362cb7b-a1e4-40be-83ea-043d4fe3e830	      "updated": 0,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
654859a7-7b9e-48dc-88b0-a859285aa6d8	      "ignored": 1,	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
7867b3c3-9ca9-495d-aaf6-aab7f288bdb7	      "deleted": 0	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
782011c5-fe44-4f5c-af17-89e4177b71cc	    },	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
f5b1f87e-2a8a-41e9-9d42-cb63b0756232	    "conflicts": [	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
ffb54447-3977-47d8-9824-ebc047502b86	      {	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
b8d01ef4-38a1-4d56-acb7-d85d4db812c8	        "object": "Gmq3mzyN1MQ",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
136759b9-eeec-465c-8dc1-a5df722cdb17	        "objects": {	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
f38dc409-b206-4c89-bb49-09174fe60f81	          "dataElement": "Gmq3mzyN1MQ"	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
5b2991ea-8241-401c-8703-5e10adf38516	        },	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
0f06d09d-adc9-4549-837d-33eb80c03393	        "value": "Data element not found or not accessible: `Gmq3mzyN1MQ`",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
bc3dfb4f-e0b1-49c8-9fc7-1fb86d953cbe	        "errorCode": "E7610",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
2be801e8-73da-450b-8ab1-1b546da64bda	        "property": "dataElement",	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
b52d4241-01e3-46df-b7d3-07219cccbf10	        "indexes": [	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
da87f787-7c97-4093-bf24-c3a63479b12a	          0	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
a163b354-70ed-4efa-bf5e-d360f8205f92	        ]	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
31b2a1e0-b69c-45a4-ab4d-4534201fbe20	      }	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
b28a5f85-b1a5-4a62-a69d-6b53abcaada3	    ],	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
64d00de5-7ddb-49f8-9aa5-ad5db192c986	    "dataSetComplete": "false"	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
1bcaeecd-b7b4-43b1-a4f8-47779b49b87a	  }	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
de190b09-88c6-47b1-ad05-bc751e259aa2	}	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
b2f770e5-980c-4f52-9d21-81f66ea6ea3b	✗ Error at Thu Jul 27 2023 06:18:48 GMT+0000 (Coordinated Universal Time):	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
d41868ef-6242-466a-9999-9cb8e0f1f165	∟ Request failed with status code 409	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
c375b1b6-65a8-46f0-ad32-ad2a81770a76	[R/T] ✘ Error in runtime execution!	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
d671d67b-dad8-4db3-b893-4866b0404703	[R/T] ✘ [object Object]	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
798c26c0-854a-4e4f-8d6f-e1e53634ee12	[CLI] ✘ Error: runtime exception	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
d4a9bae2-975e-4af3-8434-2b14f6ff60ea	[CLI] ✘ Took 688ms.	\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
94360ec6-c0d1-492a-8843-d04e25da9518		\N	d0b92099-5ae9-4863-bb61-733bbec92552	2023-07-27 06:18:48
7671823d-1a99-4bf3-a4a5-5fe47abb7a17	          0	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
d88ce446-4f07-4376-b202-3e2f69920173	        ]	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
b6743d47-899f-4ec0-96b2-07b3adab230f	      }	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
bc5f72e6-77d2-42b1-acd1-9f2c64d8657e	    ],	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
43e9b744-0470-4a94-8bba-6270dbf8617b	    "dataSetComplete": "false"	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
0d4adec6-29db-4755-a90f-8ef4025caf1c	  }	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
0e6c1788-8380-4c40-9032-7f9894cd05be	}	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
2097e01f-a7bf-49dd-a82a-0e5fd8ffcccc	✗ Error at Thu Jul 27 2023 06:27:09 GMT+0000 (Coordinated Universal Time):	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
6d8258f1-cd4b-46ff-8705-d05e5ede70e5	∟ Request failed with status code 409	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
bc1e6481-ae37-4e17-8f9c-5af650023dca	[R/T] ✘ Error in runtime execution!	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
6f4df7d7-a516-4b79-8536-cf3670b091ac	[R/T] ✘ [object Object]	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
22ebe4e3-9830-4888-bead-fdbef76b2e6d	[CLI] ✘ Error: runtime exception	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
1723793e-af9d-40f2-9565-82044131b890	[CLI] ✘ Took 578ms.	\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
550a26f8-8b57-4f51-9885-aedaac227a83		\N	616a5f9c-f573-48d0-b8a4-1cdd987f4310	2023-07-27 06:27:10
7114fdd9-7d14-41d9-bc60-83bc56d07508	[CLI] ℹ Versions:	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
432a6b03-f9d2-4d2d-a732-6f8b56504717	         ▸ node.js                   18.12.0	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
cd1002d9-dc3a-4c9e-bb11-4db0ce26ae2a	         ▸ cli                       0.0.35	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
a895d531-3570-41ff-939e-c2c9b27dc98c	         ▸ runtime                   0.0.21	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
dd63f1ed-39c4-43c3-9a78-354ca334d036	         ▸ compiler                  0.0.29	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
976eadc0-9509-41b4-9bb1-152c1ec45293	         ▸ @openfn/language-dhis2    4.0.2	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
440374a8-ab3a-4447-8997-335d94921532	[CLI] ✔ Loaded state from /tmp/state-1690439285-7-xm6fk3.json	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
d7dafa97-5366-4252-858f-509f074771d6	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
dd642285-342c-4564-b0bd-8893f8dbf32a	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
61fbc74a-7b8b-44d2-897d-e8926651635e	[CLI] ✔ Compiled job from /tmp/expression-1690439285-7-1shnzbi.js	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
839e3129-9a43-48d0-adc3-b949aaf4220c	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
f3a85247-4db1-4428-b8d4-d2ba9bd6043a	Preparing create operation...	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
d994d0b0-90d6-4421-a74d-374845bac251	Using latest available version of the DHIS2 api on this server.	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
c23d2e8e-0088-4011-8cd1-9c188a25644b	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
ad11986a-a2ad-4853-b9b4-cd5ea34dc8fa	{	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
92c9e21c-2305-43d5-8f7d-dade19c3f033	  "httpStatus": "Conflict",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
1f1a1db6-3970-4c1d-b8cf-43c5c4c365c2	  "httpStatusCode": 409,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
687ffe93-d668-4bce-9ea6-8ce5cf42a735	  "status": "WARNING",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
acfbbea0-4619-4450-bede-1d287e1e9f36	  "message": "One more conflicts encountered, please check import summary.",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
b71ed9e6-ada4-4736-85ae-808607c2f5a9	  "response": {	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
058af416-6b5d-45ce-9917-1eb3874c8c3d	    "responseType": "ImportSummary",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
9eeae59b-c79f-49c3-becb-d50bf116118d	    "status": "WARNING",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
516f7106-6588-4bdf-aff1-ab812d5364b8	    "importOptions": {	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
5a2a6bc2-2a14-4430-b3b6-e450cd3e99a8	      "idSchemes": {},	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
6b9ba8ea-babe-47d3-84e3-1ca1630a1fc8	      "dryRun": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
3d24d2e3-2327-4635-a6eb-86122d5e93b8	      "async": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
04bc4fe6-73d4-42c3-87af-3b827736dcb7	      "importStrategy": "CREATE_AND_UPDATE",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
5cfc06c4-1c2c-4e8d-993c-b1f01205b8e5	      "mergeMode": "REPLACE",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
3b7c4657-807b-4593-82bb-d1b8180b2031	      "reportMode": "FULL",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
438c3cb4-c47a-439e-a185-93db8cff7bc4	      "skipExistingCheck": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
7b46098d-314c-425b-aa87-2475ae0ad289	      "sharing": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
139a97a1-79d6-4398-a956-492e01d05153	      "skipNotifications": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
e68840a0-85fc-4fb8-8490-b6bb4c15d86e	      "skipAudit": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
28715afd-0a99-4fe3-b3f6-916086d5045e	      "datasetAllowsPeriods": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
8cae4ef3-ed29-46f2-9641-9b74b8cd6019	      "strictPeriods": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
27436b67-7a3f-4f3c-9ff8-3831df9ba61f	      "strictDataElements": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
99555259-2de5-4536-bb60-5bdbc7b1e7a7	      "strictCategoryOptionCombos": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
82385afb-25b6-4cc3-843d-77285063959d	      "strictAttributeOptionCombos": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
3b23c197-d28a-43bb-bd3b-c8c53e653885	      "strictOrganisationUnits": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
61685753-66d3-463d-93b4-1ba10fc2e3a2	      "requireCategoryOptionCombo": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
1c6849eb-80f8-487a-88b4-d11a4d02719a	      "requireAttributeOptionCombo": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
07cdbc11-f4e1-4d62-8442-de8944882dd7	      "skipPatternValidation": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
656502a5-2113-4e4d-be58-608dfef94669	      "ignoreEmptyCollection": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
1e463714-8720-4ae9-8d35-1d92ff799842	      "force": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
72bd4805-4261-4bac-aafd-2a6bb3c6e715	      "firstRowIsHeader": true,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
55633b7d-0b71-429f-8c9e-1c13e467ff1d	      "skipLastUpdated": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
5d7cf6d9-5387-4ffb-922c-a397bef387f0	      "mergeDataValues": false,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
1621b960-e460-4929-864d-d584df7ec57c	      "skipCache": false	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
0307b5d6-52d2-4779-8066-88af550bda9d	    },	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
c349e230-aefd-48b5-b23a-aeaae981806b	    "description": "Import process completed successfully",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
a88cc1c5-0f76-46d5-bba4-a81fd51d4486	    "importCount": {	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
936815be-47e6-4886-8824-2bd940b8a79e	      "imported": 0,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
84f4f569-b042-4f32-83b3-15ea1f108951	      "updated": 0,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
5b436017-e6fa-4944-8a41-8f9cc7d12de8	      "ignored": 1,	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
f91777bb-fb35-4ae1-bc7d-0716c85989f5	      "deleted": 0	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
4833f16d-0db5-4964-9463-0de066e494d0	    },	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
4ae52018-f56a-4d71-932e-e61a500e0e51	    "conflicts": [	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
16c6f92b-658b-4dbb-a558-9be98d10c6c5	      {	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
0dd517d2-8aa4-472f-83f7-7b45ffa2878e	        "object": "Gmq3mzyN1MQ",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
a9a1e0d8-19f1-432c-b09f-af1912192b20	        "objects": {	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
a442519b-3c6f-49c8-ad84-3981bfe888f9	          "dataElement": "Gmq3mzyN1MQ"	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
db0f7823-615d-45df-92d2-10f6ba74f4d5	        },	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
af3ff744-61aa-4f39-ae22-cfbf484f578a	        "value": "Data element not found or not accessible: `Gmq3mzyN1MQ`",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
ae346b6d-7955-4c1a-b9ac-8aca6878df42	        "errorCode": "E7610",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
0cd5c9ec-8adf-4ff9-811b-50b411a51d97	        "property": "dataElement",	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
c2218475-2bba-47c3-8423-0e21f0234713	        "indexes": [	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
bbb7bdb1-7ac6-42a4-b206-726d1d120d30	          0	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
cd0205a4-e7c8-49be-b5cc-21422dae877f	        ]	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
b3322f9d-cb1f-4f87-bb5f-c7fef53a8a2b	      }	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
22588e67-1602-4aaa-84a7-723fd769c9a2	    ],	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
bca1e476-4353-4d06-a173-f74023860106	    "dataSetComplete": "false"	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
1fd952e5-11ad-42a7-a470-8a612f66f27b	  }	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
c28d3c4f-b4ef-414a-adbd-efa7edfbc79a	}	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
68db3484-0902-49cc-aef1-4ce6f0cf69c8	✗ Error at Thu Jul 27 2023 06:28:06 GMT+0000 (Coordinated Universal Time):	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
90b703bc-b854-4e79-bfc7-d84115651e8c	∟ Request failed with status code 409	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
780e316f-b310-41e2-a641-6462f5a94b9a	[R/T] ✘ Error in runtime execution!	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
70761dfb-159c-4a3c-bc33-4ad75f651b97	[R/T] ✘ [object Object]	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
f36af267-78af-4ccc-8b7f-044e22d74282	[CLI] ✘ Error: runtime exception	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
40499aaf-27d2-4e84-a86b-855c99cc87bf	[CLI] ✘ Took 569ms.	\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
65e2219b-c4e8-45f6-a8a9-6e0cc7056722		\N	75c3ea23-d765-47cc-b346-0fc2dcc17943	2023-07-27 06:28:06
54fb02f8-0edb-4339-b57d-85e556defdbb	[CLI] ℹ Versions:	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
e383cd73-65d4-4a7d-9e15-08170b4b47c2	         ▸ node.js                   18.12.0	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
22612f4d-0dde-4e89-9bac-f55b22f92f5d	         ▸ cli                       0.0.35	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
8899448c-8449-416c-b926-2ea2fd5c0ac6	         ▸ runtime                   0.0.21	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
e71437ca-374a-41a3-a068-44b2932b2c2e	         ▸ compiler                  0.0.29	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
dececec6-939d-42c6-81a2-321d80472793	         ▸ @openfn/language-dhis2    4.0.2	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
e67462ba-91ce-4746-97fa-053fe2909a86	[CLI] ✔ Loaded state from /tmp/state-1690439349-7-bbbde0.json	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
9b60122b-c6bd-4356-9fc7-3fd3411b38a1	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
441a01da-48ec-41b2-8a6d-c5dcc159faee	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
23779ceb-8ce4-4a20-a987-bb7c23b5cfc1	[CLI] ✔ Compiled job from /tmp/expression-1690439349-7-uea9ql.js	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
c87a616d-fd2e-4981-aa60-9cf53fc2cd31	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
1e076c32-9591-4246-ab1c-e98724b6f233	Preparing create operation...	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
46caca77-3d53-4b9c-8cbd-5cecaabb346a	Using latest available version of the DHIS2 api on this server.	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
517010b3-b8eb-4e59-894d-79759a28b49d	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
50bba8d8-565d-48fc-ae86-db1a82b47112	✓ Success at Thu Jul 27 2023 06:29:10 GMT+0000 (Coordinated Universal Time):	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
34da4d75-c936-4079-9ead-60e279db4df8	∟ Created dataValueSets with response {	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
3f3e6ddc-54f3-4696-8522-c61b4bae02d4	  "httpStatus": "OK",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
38017c02-799d-4470-b325-5b9a2befd280	  "httpStatusCode": 200,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
b3a9cae5-d2e8-4e34-849f-ed0a2be00423	  "status": "OK",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
0faa9add-8262-4be9-b74a-dafa2d2e6424	  "message": "Import was successful.",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
013b6e4e-e276-41a8-827c-767c45d7503f	  "response": {	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
e46e20aa-7a7a-4eef-a932-4a96e9e3eebc	    "responseType": "ImportSummary",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
c077f2e1-cdce-48dd-8a54-1c9dc2640392	    "status": "SUCCESS",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
d35cbe89-ae77-40f9-808b-27e6fb450c0e	    "importOptions": {	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
19a4fbfc-eae4-4644-bcf8-c78f09e44a49	      "idSchemes": {},	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
59d0ba04-3504-44d6-a3e9-49a7e28ec379	      "dryRun": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
6046580c-60a9-4127-b128-dfca5d686ea4	      "async": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
d4e2c49b-24cb-422a-b12e-d77bd6994d3d	      "importStrategy": "CREATE_AND_UPDATE",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
f34110c3-8993-411d-84ed-6584ec89e7eb	      "mergeMode": "REPLACE",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
2b44108a-e3e2-4c81-9607-6cc00e9a425a	      "reportMode": "FULL",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
b69ca558-651d-4f4f-9a9f-8fa913498a3a	      "skipExistingCheck": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
ba3407a3-4bf6-4c2c-bb20-5d55e84828ed	      "sharing": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
ed049b04-34f3-4ce6-9e1e-4566067a27c4	      "skipNotifications": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
d38ca801-24eb-4f1d-a16c-04dc828fbaa2	      "skipAudit": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
b45a88e3-0b9e-4159-ae41-891dde87925c	      "datasetAllowsPeriods": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
0a8464bb-b946-435c-8d26-2b04ac9dfad0	      "strictPeriods": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
6f856617-12d0-4c14-89ea-26c57f394976	      "strictDataElements": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
edb92e1e-ca98-4157-8ab5-e9323adef558	      "strictCategoryOptionCombos": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
eaabe9bf-6434-4cb2-9396-b0aef37061e1	      "strictAttributeOptionCombos": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
950a579a-29c8-4b6d-991a-335ede340835	      "strictOrganisationUnits": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
04cee7df-abb5-4fe9-bb9b-69b26441bbba	      "requireCategoryOptionCombo": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
e323b3ee-43fc-4068-8094-65f3aec489e3	      "requireAttributeOptionCombo": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
d6004840-4b96-496b-ab4a-49b3c95a3e5b	      "skipPatternValidation": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
a4d98a5c-eb4d-4cba-9c4c-a45e788dfde7	      "ignoreEmptyCollection": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
3f4c0681-daab-47a9-8e6c-d6e0b111bce1	      "force": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
852d9539-f30e-4a1e-b2c3-f2b7e5ba27ac	      "firstRowIsHeader": true,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
d7af4051-36f4-4fdf-a92f-270c76e986f5	      "skipLastUpdated": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
a0ef67f4-d5fc-4e51-bc0c-31279b30475d	      "mergeDataValues": false,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
3fd2fc22-8c90-45ac-9deb-7b2912bfdaef	      "skipCache": false	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
23080ba4-ff1e-474a-a5ec-71390f555a1f	    },	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
e9419502-0097-47d9-a77f-e7a934a5d02b	    "description": "Import process completed successfully",	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
ddb5276b-1ff0-4f78-aafb-a03265fee1b9	    "importCount": {	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
44bfd676-e903-4e96-8593-72a610eb4bfb	      "imported": 1,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
42d6a0ec-a282-443e-9531-e5e6ca67234f	      "updated": 0,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
0e925abc-af6f-4d21-9680-9c063849efda	      "ignored": 0,	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
d8e57e4f-8707-4537-b503-24a340fa152b	      "deleted": 0	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
ea23089d-fb78-4318-b1d5-f65ec6afb336	    },	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
be70afa1-dce7-4466-aace-ac8c6d950cb0	    "conflicts": [],	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
e1e89187-9398-492f-b260-593e405f3f23	    "dataSetComplete": "false"	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
ef239ede-c24b-4c06-976b-78fa118d84f7	  }	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
311b7ec2-7722-49e6-b8f6-f1725f563095	}	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
23c2347d-2b7a-4047-b8f1-92145fa22f19	[R/T] ✔ Operation 1 complete in 230ms	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
c4c70f35-fd50-4b3d-a7a6-bec9b8bebe03	[CLI] ✔ Writing output to /tmp/output-1690439349-7-po1qoc.json	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
93064946-5df4-4311-8034-16a74fc8d7ff	[CLI] ✔ Done in 655ms! ✨	\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
7a7f161b-c525-4e83-b700-8f3f2574e8ef		\N	09354671-020c-45d2-a50a-0bc4c165ca69	2023-07-27 06:29:11
15b3bf58-fef7-4165-bbad-83bb54d6aeb9	[CLI] ℹ Versions:	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
a1ceaab2-f0f7-4ffd-8a3b-bec1bcc920df	         ▸ node.js                   18.12.0	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
f5292189-dac6-4c23-845f-43296e934710	         ▸ cli                       0.0.35	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
c457ef10-2580-4671-9cbb-213b28e11b3e	         ▸ runtime                   0.0.21	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
62b22451-79d9-4d72-b05d-9d10601f3669	         ▸ compiler                  0.0.29	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
d47a0df8-75bf-4f2f-8b30-ba074ef17157	         ▸ @openfn/language-dhis2    4.0.2	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
38f88aaf-2522-4e38-8078-113afb0c9167	[CLI] ✔ Loaded state from /tmp/state-1690439467-7-u0c1jj.json	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
37ef6342-bf5a-402d-bee2-dc7cb7d5c9a9	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
d1d4c13d-293f-4a09-ba2d-3fc7f6226d8b	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
dee1bebf-974b-4288-b874-97121bb64c8f	[CLI] ✔ Compiled job from /tmp/expression-1690439467-7-1d1eyo9.js	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
ec257a59-1445-4afb-9ab5-baff22424ead	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
ca28b25c-ba03-4456-82b3-00dd645290aa	Preparing create operation...	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
fafc5b5c-3e4b-4087-8d8e-6b37698f80ba	Using latest available version of the DHIS2 api on this server.	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
c4eef0ba-c594-435c-bbc0-6d6a93e9dd3a	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
b2a7c4bc-e4ef-4ab8-9e6c-ba9bfdbc66eb	{	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
d7c206bf-5deb-4bd9-8919-ca3c2a8a1eaf	  "httpStatus": "Conflict",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
0af59cf5-02ce-4b08-b7a9-d14ad62576a0	  "httpStatusCode": 409,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
c1c944a8-c172-4713-b70e-ac3226db7931	  "status": "WARNING",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
c1bda9c6-2496-4f6c-824b-85aa8b22768d	  "message": "One more conflicts encountered, please check import summary.",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
6e66bb82-7a2d-425f-b891-fed064a5a167	  "response": {	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
a11309fb-ef28-4c1b-80d4-7bd506515b24	    "responseType": "ImportSummary",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
bca768aa-b656-46d7-8c64-c08f18f94f6e	    "status": "WARNING",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
5ed19f9f-ef57-4b86-824b-a59a24377c41	    "importOptions": {	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
3e3b8135-3962-45e1-b7c4-a589876d0899	      "idSchemes": {},	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
158c3442-4ac3-4100-b7f8-3cb23071d928	      "dryRun": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
4f8de60f-30b5-465a-8a07-99b5837b88fe	      "async": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
62a591e9-3542-457b-8b7b-10fef0f0f278	      "importStrategy": "CREATE_AND_UPDATE",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
b7d46011-54c0-494b-9bb1-168041450257	      "mergeMode": "REPLACE",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
632d291a-a3c5-44fa-a70c-c7832cee9eec	      "reportMode": "FULL",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
6ff54e7e-5955-4455-8b9f-0dc012440975	      "skipExistingCheck": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
efbea686-0e6e-4690-9130-de92da04c598	      "sharing": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
f8572cc6-80ef-4f43-b08b-15d8130a7773	      "skipNotifications": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
566abc54-3591-48af-8009-b5bcfd02ccbc	      "skipAudit": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
575caa61-b0e4-456f-a159-1849c241e2a4	      "datasetAllowsPeriods": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
54060b35-ecad-4fad-bd65-ac0f7471a2a2	      "strictPeriods": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
b8688bfb-b966-46ed-bab2-be092fccc1b6	      "strictDataElements": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
d2a4a074-814f-486e-aa04-8d49834e39e5	      "strictCategoryOptionCombos": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
b7ec8862-b216-43ce-9bc7-b5cb78ac3e07	      "strictAttributeOptionCombos": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
a3b6807e-e6fc-4925-b1cf-271ab20cbf85	      "strictOrganisationUnits": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
db5bba42-af3e-4d52-9f36-7e619c63efd5	      "requireCategoryOptionCombo": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
a10e98f1-58e4-408d-9d7a-863c1452c5bb	      "requireAttributeOptionCombo": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
9aba3e6c-4ea6-459b-9af5-20aa2a01454d	      "skipPatternValidation": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
693cd4f6-1889-464f-94ef-fd316f9995fc	      "ignoreEmptyCollection": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
2ea1f8ea-1f0e-4f59-b164-7f2c09c0dccc	      "force": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
b801a87e-6493-4d7c-b505-df3d473b9179	      "firstRowIsHeader": true,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
8e235ebf-ba9b-4a0a-a28e-d7cbdbcdc954	      "skipLastUpdated": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
97e397b6-3597-4c34-b16c-12c462ffc1d6	      "mergeDataValues": false,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
01a7d873-9e26-424a-a497-f29d46a25933	      "skipCache": false	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
6ec7f9a2-6774-4589-a4b6-9c69cb1a8c67	    },	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
c53a01cc-b8a1-4ad1-964a-20cd3de406a5	    "description": "Import process completed successfully",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
97e42f8b-9e33-4849-ab13-1e4ae78645ec	    "importCount": {	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
74a26210-aa70-4065-bf12-7c070003280c	      "imported": 0,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
3d752f52-1539-4ebf-90f9-4c3b4dcbc93a	      "updated": 0,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
06408a88-4bea-4331-bbdf-a4a8a788d54c	      "ignored": 1,	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
5bfa2973-a90e-4a4a-9ad6-e3348aec433c	      "deleted": 0	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
e50f092c-b9e6-49c5-b939-6a3d90d3fbb7	    },	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
d7bc5628-10b9-4933-9770-2b61db34272c	    "conflicts": [	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
20369285-2dcb-4ea3-96ab-40a9f5561c70	      {	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
c1f60626-6340-4b23-abd3-0fb16369c628	        "objects": {},	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
bd7d18cc-d194-4a36-b96f-e31dc347586c	        "value": "Data element not found or not accessible: `null`",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
95cfc10d-9cc6-4adc-999a-1762fe1a21d1	        "errorCode": "E7610",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
ee3c3f4a-1137-4d7a-aa1c-d913d346d74b	        "property": "dataElement",	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
1599d697-0a32-4f8f-abcb-c94b49363a24	        "indexes": [	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
dc00183c-198c-42e4-9b85-459f2bf94728	          0	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
cc1b87b4-174f-4ced-b347-feaa1d9d77b4	        ]	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
a44c3c43-66e4-4330-97f7-41f1dd9af969	      }	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
23825c10-57dd-4a43-a760-c707a9079967	    ],	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
2e63652b-9d83-4329-888d-cd844da2e8c3	    "dataSetComplete": "false"	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
a711cfc1-7fe9-4877-8097-8157d8e52e1e	  }	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
41c19ede-160d-4bf2-9b60-b5e2c08ceabe	}	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
d564bd61-2bc4-4924-be73-cba36b23d854	✗ Error at Thu Jul 27 2023 06:31:08 GMT+0000 (Coordinated Universal Time):	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
1b7fe49d-c246-4c7e-9755-22d80b789e26	∟ Request failed with status code 409	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
9365dc02-9072-4328-aff5-acae36a32202	[R/T] ✘ Error in runtime execution!	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
c690d45b-967d-4830-a893-2c13bcf31a27	[R/T] ✘ [object Object]	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
aebcd9aa-e1d6-43a3-8422-b0ec92a3b460	[CLI] ✘ Error: runtime exception	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
b15c2eb6-fa58-4b58-8ce0-1516e81c27b4	[CLI] ✘ Took 582ms.	\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
8624b1dd-17e6-41fa-a547-099c83a5ff72		\N	3f6bd877-f76b-4dc8-978f-d95eb315050c	2023-07-27 06:31:08
cc36c5b7-86a7-4489-af61-e6ae8f91f49c	[CLI] ℹ Versions:	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
d7789523-1732-4be9-82ca-2f7743ce9157	         ▸ node.js                   18.12.0	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
5d1f52a5-b9ec-4a1d-a1f8-a4302b6a8e78	         ▸ cli                       0.0.35	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
29f0659b-ceb9-45a3-aca7-f4b88c7d85ed	         ▸ runtime                   0.0.21	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
0d147e46-b573-4099-b04a-fff906def4a4	         ▸ compiler                  0.0.29	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
6ba643cb-98a3-427d-9db8-d4ea3565ff0d	         ▸ @openfn/language-dhis2    4.0.2	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
fb75f1c0-a4f7-4fed-8994-45f3c6a7ac6f	[CLI] ✔ Loaded state from /tmp/state-1690439525-7-1otooh0.json	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
f5f13c66-8c1d-46a8-b1aa-0be525ef3e8d	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
615b0db0-3cb6-4e7f-9c28-902e335fdc78	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
a18b42a2-9363-4833-bc0c-aaff6e5c8645	[CLI] ✔ Compiled job from /tmp/expression-1690439525-7-11d6ni3.js	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
b7f1f778-8b42-4331-9f39-7a7a2b2788f3	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
65aeb9ef-9714-4f33-b628-e98da87d3449	Preparing create operation...	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
100eefb6-3337-4b3d-ab4a-bcda19343f6e	Using latest available version of the DHIS2 api on this server.	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
2fadb064-25c7-4bf7-b2e0-1576739bee2f	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
92ef6e0e-1b99-4676-80ff-3d84fdcf2e76	{	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
0a45fedf-04a1-4f82-b1ae-fa40d0948d35	  "httpStatus": "Conflict",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
2aef6eb6-e63f-4563-b83d-d491a0f21afd	  "httpStatusCode": 409,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
16ea3d6d-5eb8-487b-8280-b3d8ecf3cc65	  "status": "WARNING",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
65459ff6-0c90-434f-8c7f-2c215bddc943	  "message": "One more conflicts encountered, please check import summary.",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
b9a1fb8c-4075-450c-b793-5a754ccedde7	  "response": {	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
a0ec2a2c-aa32-45a7-bccf-75ce9e8ad397	    "responseType": "ImportSummary",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
b55de2c0-9c34-4046-af74-ba4c727dc770	    "status": "WARNING",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
ff0bb9b1-7099-44c4-8e3a-490cfb3cb552	    "importOptions": {	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
95129530-f153-4811-9695-0a00a93d6bf5	      "idSchemes": {},	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
32f5be18-a304-415d-9e32-615f67b4e000	      "dryRun": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
33cc88c8-d1a2-4f61-9364-e6b6785627a1	      "async": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
3a6c1520-e8f0-451b-a0e4-e46c10c5627f	      "importStrategy": "CREATE_AND_UPDATE",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
706ef637-6772-42db-837d-0ca8db8c195e	      "mergeMode": "REPLACE",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
9e6ea08d-ed58-46f9-9d2e-95bafe898328	      "reportMode": "FULL",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
452e19a1-fe69-4d9b-a0c4-62303be563af	      "skipExistingCheck": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
2991242a-543f-4c6a-96ab-70c421e41d28	      "sharing": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
76afe14f-7050-4d13-ac11-5ffe0430e695	      "skipNotifications": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
4495f040-0482-4156-96de-44fb931d30c0	      "skipAudit": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
f34d312d-29c7-41ca-bd76-c95dd96220b9	      "datasetAllowsPeriods": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
8d0040bd-7fb1-43b7-9d42-0c1bb7c07032	      "strictPeriods": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
61feca4f-e861-4a05-809a-04bb78affa97	      "strictDataElements": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
540e5448-7cbf-4e45-87b3-615869952616	      "strictCategoryOptionCombos": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
1edb1ca2-2b76-44f7-a7b9-46edb0de6c27	      "strictAttributeOptionCombos": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
b8739046-149e-4d75-868c-28ef13d548b1	      "strictOrganisationUnits": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
8686a83a-73bc-4c28-9f0f-cae0105cd976	      "requireCategoryOptionCombo": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
27bb2040-b476-4e81-b5a4-91c0cc4fe311	      "requireAttributeOptionCombo": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
715c08b1-7916-4250-9e31-261bc2365bda	      "skipPatternValidation": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
f4b0efd2-8035-46ab-9f73-81bbe3aa9f35	      "ignoreEmptyCollection": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
062142ed-8257-423a-9350-6ee56acab3d8	      "force": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
85b35afb-e001-4cb0-9f19-006190780048	      "firstRowIsHeader": true,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
1f41d0fc-2aa3-4aea-a41e-982300e22aa6	      "skipLastUpdated": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
9b735625-43d1-4a02-886f-cbf7acab3e18	      "mergeDataValues": false,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
741f4c74-f0f3-4b40-8dff-e0afa17ed2c1	      "skipCache": false	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
57d7c7d4-596d-45f4-be6e-d0379a40b974	    },	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
8f14c403-9d97-44eb-889e-1597bcbd9dec	    "description": "Import process completed successfully",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
4e023064-fc34-4bc9-9269-4a40938280fa	    "importCount": {	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
8e0240ab-dd20-479e-a9c9-c750ed22f8b1	      "imported": 0,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
9b378b77-0c5d-4c29-bd37-efb76c945088	      "updated": 0,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
3bb212a1-c7d4-4498-8277-4f5af8b20a7d	      "ignored": 1,	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
1076140a-7dfd-4876-a8c1-5b8d0588650c	      "deleted": 0	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
76a7a91b-22f7-4e11-b7ed-4deaffce0fac	    },	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
33bf4423-7742-4dae-8e1f-0b509c8a0456	    "conflicts": [	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
5475c2dc-719f-402d-b927-832dca00ec4b	      {	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
55543395-508e-40a5-974a-bc0027ea44f5	        "objects": {},	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
3c9b6f59-c931-48ba-a7ee-0936fec7e06d	        "value": "Data element not found or not accessible: `null`",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
585753e2-753a-401e-b6d8-be09955963ca	        "errorCode": "E7610",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
9e4f8045-6e21-41aa-9f77-2b6d22683c47	        "property": "dataElement",	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
9c5f46d1-6e04-46a8-8445-08b1ac24bd9b	        "indexes": [	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
39ee0512-7d2f-42aa-b87a-d41aaf8ae6bd	          0	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
e53664d9-1f0b-4fe5-b4d4-21a42c85a758	        ]	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
8598b109-d01e-4ea7-87f0-0462adb424f7	      }	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
03e6a716-32b5-4c18-825b-ec8eb31e7f1c	    ],	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
1c286728-ca5a-4f87-be65-5e89722f7d7a	    "dataSetComplete": "false"	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
99795522-e00a-4087-b286-cffdc1d23992	  }	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
a025824d-639c-4d23-90f3-351f6f07d704	}	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
65e60e97-2a6f-4d8e-b92b-c97fe3fe6c3c	✗ Error at Thu Jul 27 2023 06:32:06 GMT+0000 (Coordinated Universal Time):	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
5977b065-59f8-4ab3-9646-097ea4e79817	∟ Request failed with status code 409	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
2e200dba-1563-450e-8dc8-d279713c87e3	[R/T] ✘ Error in runtime execution!	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
2f1bb1e1-ba9e-4771-b691-83dd9657f82c	[R/T] ✘ [object Object]	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
804e3dcc-216d-424e-9d20-f6de60a09c4d	[CLI] ✘ Error: runtime exception	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
79ef6e11-69ff-4ba1-a035-0126f57cd885	[CLI] ✘ Took 564ms.	\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
69c07883-13d2-462c-b909-cae574e40b2e		\N	f7fcb9e2-ca77-4f23-8ef5-810e672a089c	2023-07-27 06:32:07
3eb7b97d-61a9-4c2f-8906-33d6d864fe07	[CLI] ℹ Versions:	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
9815a97c-f4c5-4498-814f-5e91d447e37e	         ▸ node.js                   18.12.0	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
8079244c-c8ae-4e87-a246-5f39a8fec4ae	         ▸ cli                       0.0.35	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
2fcf0ebb-f8ac-4b2a-a7fa-7aba7830fc5d	         ▸ runtime                   0.0.21	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
547af64c-bae1-427e-bc84-2219fa03a207	         ▸ compiler                  0.0.29	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
4f95b20e-719f-4b0a-ae0e-8f365dddea84	         ▸ @openfn/language-dhis2    4.0.2	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
17068363-2005-4980-be66-9462e74b9213	[CLI] ✔ Loaded state from /tmp/state-1690439706-7-18b4qkg.json	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
130ffa93-26e4-41dd-8dc4-10360ae3bf9c	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
b989d193-c33e-4546-9cd1-db8d8344c198	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
c511be19-5175-493f-9077-2f31d6c6a2d0	[CLI] ✔ Compiled job from /tmp/expression-1690439706-7-1no8s6q.js	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
21f34ec9-4367-40a2-b119-d7d23c7e0853	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
ae833607-55c4-4305-bc88-86121d9c1673	undefined:1	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
bc50958a-ff36-4139-895e-d8a71dd2606f	undefined	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
596ccb69-1bfc-4a28-84de-5a811254fb56	^	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
758f915e-1660-4b9e-8ac7-b221f91b295a		\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
684a4196-cb5c-477c-8f42-bad04a913dc2	SyntaxError: Unexpected token u in JSON at position 0	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
62c89607-000a-45cf-b953-53b2f8c819e8	    at JSON.parse (<anonymous>)	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
510d473e-728a-498b-87e2-d56cb528280b	    at vm:module(0):3:24	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
a378b18f-a69e-4c6b-a5da-038026fe83bb	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
c3aa6655-0b6c-4201-83f7-bade78b08909	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
4b49a53d-565e-4efa-83e5-2b3806f86588	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
91efb335-f36b-4a9d-b92e-a3dd11f36f6a	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
a180026e-0a33-4363-808e-84ec1b4cd65d		\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
c59047e6-1544-478b-88fc-648981bb66d0	Node.js v18.12.0	\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
30ce4754-cfd5-483d-a867-dc2f6ffa85b6		\N	413bee69-1f6a-4d93-978d-a3bf5d47fae2	2023-07-27 06:35:07
11fd46f9-c97f-46fd-974c-aad7aaf07cfd	[CLI] ℹ Versions:	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
3b1c5d90-396e-4b39-94f1-6979d93ba795	         ▸ node.js                   18.12.0	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
39eaf2c9-9ef6-4e83-87e9-39af8e8d74e8	         ▸ cli                       0.0.35	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
28c4e3d2-df55-4ed2-946e-e53b5db2a588	         ▸ runtime                   0.0.21	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
8dfd9292-a6e0-484d-9e5d-e1e4912b5bfe	         ▸ compiler                  0.0.29	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
5e149212-6116-4d9a-b3a1-c1ca7ed888f7	         ▸ @openfn/language-dhis2    4.0.2	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
24d43e96-3258-43e4-b43b-077e19d157ca	[CLI] ✔ Loaded state from /tmp/state-1690439809-7-1kur243.json	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
4a088631-2083-4f59-9285-550a5eecd9ba	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
1f89683d-d0fd-4fc3-9b5d-180f4f4f135d	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
0f00c30d-2ed2-421a-8536-996524e88dcb	[CLI] ✔ Compiled job from /tmp/expression-1690439809-7-1r19u2f.js	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
1b62ca5d-920a-4b6d-97c2-d206c1af95e7	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
d0abffab-23cf-467d-a937-481355f6d577	[CLI] ✔ Writing output to /tmp/output-1690439809-7-119w7qq.json	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
2728e46a-b307-403f-9f1d-bc4cf7545b66	[CLI] ✔ Done in 415ms! ✨	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
1a63680f-7fef-4f74-a8eb-1a515183576a	[JOB] ✘ Error: state.body is empty or undefined.	\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
c2929c6f-4e8c-4a2e-84e3-452e641fc208		\N	61cb5244-ca62-4380-9610-48c05b6169c4	2023-07-27 06:36:50
f872709a-36de-4b68-b5a2-e26dd81fe768	[CLI] ℹ Versions:	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
93d13c01-e014-4471-bc79-a56a8a29a373	         ▸ node.js                   18.12.0	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
9c46ca5c-8201-450d-9023-c9f1dee9825c	         ▸ cli                       0.0.35	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
9c5cb219-4337-48b8-be6b-d3d377ad4d1f	         ▸ runtime                   0.0.21	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
4a635fba-e888-464d-832a-ace3e5308070	         ▸ compiler                  0.0.29	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
c6255e92-e4f7-4520-809c-e0d8c8d10012	         ▸ @openfn/language-dhis2    4.0.2	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
4a32180d-ea8c-4608-830d-7c3b30bb4dfe	[CLI] ✔ Loaded state from /tmp/state-1690439940-7-4xx9sk.json	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
baf8e628-8eef-4c5e-91e0-da0fcb567f5f	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
58257271-0de0-40d2-beee-65e09935bfae	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
3bc5a2d1-2c4c-49a9-a608-22d576dbad70	[CLI] ✔ Compiled job from /tmp/expression-1690439940-7-6txk1q.js	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
20c2eb95-9110-4160-a169-cd6bc19288e0	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
c65c6965-9763-4e70-ac46-e50ec8ab10e1	[CLI] ✔ Writing output to /tmp/output-1690439940-7-lmadcy.json	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
ae19fb45-34e6-4cb5-b50e-201bd74ae123	[CLI] ✔ Done in 424ms! ✨	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
7e32b55b-3de3-47bd-bb27-daa49eaf2087	[JOB] ✘ Error: state.body is empty or undefined.	\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
0dcbd773-b8c2-4fc0-a84c-9b3fd5a87e71		\N	35a56081-cc45-4446-8427-731c4cbabbd6	2023-07-27 06:39:02
c43ae0bb-2baf-423f-a887-466801997165	[CLI] ℹ Versions:	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
77cc763e-8099-49b4-9195-24ac3ffc5eb5	         ▸ node.js                   18.12.0	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
44cfa580-ddef-4b68-b5b9-c5817863d685	         ▸ cli                       0.0.35	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
e301869d-c6fe-4b58-8128-e5bc4f0760f6	         ▸ runtime                   0.0.21	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
3c0df24a-24ff-481b-ba91-48c3824022dd	         ▸ compiler                  0.0.29	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
df12b36e-1a79-438e-90b2-ca7f6a3627a8	         ▸ @openfn/language-dhis2    4.0.2	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
10fd80fc-5118-4955-bfa0-e83eeda51ec7	[CLI] ✔ Loaded state from /tmp/state-1690446703-7-3p4h4d.json	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
d2cbdd53-63f4-4dbc-8a8a-5455b8577bd6	[CLI] ✔ Compiled job from /tmp/expression-1690446703-7-14tel7y.js	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
b5994eb0-6aba-481d-95ba-ab49784f5915	[JOB] ℹ [{"use":"official","family":"Smith","given":["John"]}]	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
7de19a09-6996-44ac-b1e9-ea97046c49f9	[JOB] ℹ {	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
53c67db1-1886-43bb-a2f6-88fdc8750705	  "resourceType": "Patient",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
3ac0a360-1ea4-4cf1-90c6-1c04ecd12f46	  "id": "example",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
1fbe0283-475d-42b1-84b3-5405d9b2653a	  "identifier": [	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
8e584531-2f8b-416c-9fcf-41e60220f9c4	    {	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
56559679-cdd9-4a65-9ebc-498801c27c3f	      "system": "http://example.com/patient-ids",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
02d3b88d-6cd0-400b-9125-8677e489af74	      "value": "12345"	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
6af2edcb-db9b-4b0f-a49a-ee9e4e04e06f	    }	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
9d905193-92ca-4385-9285-9ff7727dbf04	  ],	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
86c30a5d-c2f2-46f7-bc77-0a0329cb6741	  "name": [	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
76263bb4-c1bc-4534-b6d9-4c2dfc206572	    {	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
dd0c4747-0f68-4e75-9e3c-4f9e7d557d90	      "use": "official",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
5824f7e8-33a6-495e-b1d6-ad65699c7074	      "family": "Smith",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
9dc31805-091c-4e55-970c-6a1b688de4c8	      "given": ["John"]	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
5a37921c-afc8-497c-901a-a80e2c1d9895	    }	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
447c93f1-9231-43e8-9e7d-de25c05fe318	  ],	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
90491a97-fecd-42c6-926d-605f252d592d	  "gender": "male",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
fe29d19d-d5aa-4be3-b795-08cc8c0984bd	  "birthDate": "1980-01-15",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
88ad7639-a81b-4f9a-a277-4fa662a437ec	  "address": [	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
27ccd886-adf9-4f82-9906-b69f763062e8	    {	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
9962d3ea-c5e7-4051-8221-8665d4e4023e	      "use": "home",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
17489f56-fd12-4018-96d7-9a17f92a1236	      "line": ["123 Main Street"],	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
97ed3e95-1641-403d-830d-2cc9392449d1	      "city": "Anytown",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
26f9bb27-532a-4f87-8083-278455f35e13	[CLI] ℹ Versions:	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
8d05be9e-3dfb-4722-a2e4-4109856c04a5	         ▸ node.js                   18.12.0	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
ab156f44-c09b-4c6a-a9fa-fd059df85190	         ▸ cli                       0.0.35	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
2ea1406c-d9e0-470e-9871-f41edbbf329c	         ▸ runtime                   0.0.21	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
43f49527-558d-47a9-894b-7834d37e8a1a	         ▸ compiler                  0.0.29	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
b18ea23f-99ae-4bfa-a64e-95e1ce9815c0	         ▸ @openfn/language-dhis2    4.0.2	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
8a0345ff-0605-4848-be4f-2404ff2816b7	[CLI] ✔ Loaded state from /tmp/state-1690440100-7-y7jjbo.json	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
b88bd5dc-a49c-458c-be27-c6c8481b4f73	[CLI] ✔ Compiled job from /tmp/expression-1690440100-7-7px2q4.js	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
1c603e06-8773-4e18-954f-213f69c3ef83	[JOB] ℹ Mahao Molise	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
c71c363d-34c1-4959-80b7-c7a69c1480c1	[CLI] ✔ Writing output to /tmp/output-1690440100-7-1pc3rzh.json	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
d6ce67b9-d2c2-4696-8c36-3cab51fceac3	[CLI] ✔ Done in 182ms! ✨	\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
17b0efaa-9521-4c62-9c23-fdc9551eda32		\N	873c058c-fe77-4d26-933c-12e281fa6abd	2023-07-27 06:41:41
585424c2-7aeb-4e28-a08a-889352dc15ef	      "state": "NY",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
940480e6-6150-462c-ac73-ac75311cbedf	      "postalCode": "12345",	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
68f90f4d-4370-4da0-a64f-302e2e8ff5eb	      "country": "USA"	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
1218ad26-260c-4301-a100-4caf241230fa	    }	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
2dc418ae-db40-4ced-b9e0-9e6afe80a257	  ]	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
b88d3162-e8fa-4d27-a4a8-ca98cb3571df	}	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
8e3fc083-6aa3-40e3-bc70-1096e0d9176a		\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
d562ba9b-1672-4d7f-b9df-64f53826303e	[CLI] ✔ Writing output to /tmp/output-1690446703-7-2monhz.json	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
619fe12a-a9f3-4e62-9afd-dffc5980d1de	[CLI] ℹ Versions:	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
67ec580c-c0b1-46ea-b131-cb6c8cb2986f	         ▸ node.js                   18.12.0	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
ab7884d3-d038-49b7-a07d-c8004b40d7d6	         ▸ cli                       0.0.35	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
89ae511e-6073-46d7-9da5-92bc7555e3e4	         ▸ runtime                   0.0.21	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
5934d502-414e-4e37-98da-5d7c9060f06c	         ▸ compiler                  0.0.29	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
d509a1f5-9f6f-47d1-97e7-9ae1ab2b75c1	         ▸ @openfn/language-dhis2    4.0.2	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
f70b6355-2d03-4079-9e6c-e15f32d9548c	[CLI] ✔ Loaded state from /tmp/state-1690440239-7-2uuemm.json	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
d1085c0f-2a67-493a-80da-28650ce57c86	[CLI] ✔ Compiled job from /tmp/expression-1690440239-7-pfbv1r.js	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
6e60fcb8-5eb3-4c98-84a0-b4e5414fce2a	[JOB] ℹ Mahao Molise	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
58092947-ce9b-41eb-a182-c4b092380041	[CLI] ✔ Writing output to /tmp/output-1690440239-7-k84esn.json	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
218386dc-7b7a-423f-9488-98a55c648eef	[CLI] ✔ Done in 172ms! ✨	\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
647ce904-1481-435b-bd1c-96cfde24fc99		\N	51067e57-1241-4e0b-9c45-cad9f3dc89a4	2023-07-27 06:44:01
98c9edfe-e4a8-420e-8043-f7a18e312d29	[CLI] ✔ Done in 178ms! ✨	\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
22f78c98-591a-4c04-909d-ece45ac35920		\N	0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	2023-07-27 08:31:45
eeeb2048-59e0-4af6-86fc-072e239d3171	[CLI] ℹ Versions:	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
5c4bb19d-94a4-4469-940d-4f4f945adc8d	         ▸ node.js                   18.12.0	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
056c336a-5415-4833-a06a-9728a281be1f	         ▸ cli                       0.0.35	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
49da94d4-6cbe-4127-885c-1584a2bea11b	         ▸ runtime                   0.0.21	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
1101184e-6dae-45c7-b531-942c93bee603	[CLI] ℹ Versions:	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
090048c1-b544-4d6d-8a64-f6326f090686	         ▸ node.js                   18.12.0	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
61f42549-44c7-43fb-84ae-22a6dffba203	         ▸ cli                       0.0.35	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
21391e0d-1a13-419b-9df1-4189b5cd79cc	         ▸ runtime                   0.0.21	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
6df3fe15-f78c-4945-9fcb-34dd3ae09240	         ▸ compiler                  0.0.29	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
7b40f2d1-6bf2-4750-9db0-866f8c7445b3	         ▸ @openfn/language-dhis2    4.0.2	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
b469ccfb-97ba-409d-8664-13e0d7b93aac	[CLI] ✔ Loaded state from /tmp/state-1690440364-7-g3fye.json	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
fe67d96d-eea6-42fe-91e3-05b3f55a45ef	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
dcb3a629-5e0b-4b3d-8c47-38c9b148412c	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
5a284cd5-6bb9-4998-b1da-0e76cdaffe7b	[CLI] ✔ Compiled job from /tmp/expression-1690440364-7-1vgtvor.js	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
472a8e2a-d854-46da-8cf8-dcc2f987629b	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
12aca892-0e7e-4c4a-a244-f59a9825c35c	Preparing create operation...	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
a1a401ae-ba1b-4cfc-801d-7f59ec9a4ca7	Using latest available version of the DHIS2 api on this server.	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
c1a08d5d-cbc5-4e96-99fc-373fae489125	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
e40f7f14-6ed0-44d4-89da-50a0390003a6	✓ Success at Thu Jul 27 2023 06:46:05 GMT+0000 (Coordinated Universal Time):	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
535e03fd-5f36-4146-806c-ad9e3da91c9c	∟ Created dataValueSets with response {	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
d8a2b8d6-d918-4764-824f-210f4534cb61	  "httpStatus": "OK",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
055f9679-0c2e-43c4-9f72-3bb4abb8248f	  "httpStatusCode": 200,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
23a5756d-aff1-4df8-9b2e-a4221da778f3	  "status": "OK",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
0429592a-a7e4-493c-b118-a5fa3340c8b8	  "message": "Import was successful.",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
d88746b2-5582-46b0-b0a0-463292ed8123	  "response": {	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
6a192746-ae29-4582-81c4-1ec1f48d0206	    "responseType": "ImportSummary",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
179b8e0e-962d-43aa-b187-5d0cee7000d5	    "status": "SUCCESS",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
15326d3b-b27b-4633-a172-47cab0ecdc2f	    "importOptions": {	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
d71e4924-2835-4138-afb6-cb33b3abe358	      "idSchemes": {},	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
6b021601-a257-4548-9117-1507415071c4	      "dryRun": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
8d73a143-afe7-404d-8a1d-07a760fa8c3f	      "async": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
cc17111b-3c2d-48e4-86e9-dbf9cd8a950f	      "importStrategy": "CREATE_AND_UPDATE",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
6e2574c8-cbae-4df2-8899-85a9a87a3bf2	      "mergeMode": "REPLACE",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
99f61475-73d2-435c-b0ae-f53ae5b44684	      "reportMode": "FULL",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
f3fecacb-f970-40ed-8174-8a34d88d4b61	      "skipExistingCheck": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
3e08bcb7-27b8-479f-9f2e-83ee2b429360	      "sharing": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
b6f50af1-21e7-4cfc-87f6-7ea9c0cdcb94	      "skipNotifications": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
0ad8ebaf-b745-4095-ac22-d66febdbafb4	      "skipAudit": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
1feb66a8-1721-406e-8c9f-25ed2bbaead8	      "datasetAllowsPeriods": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
786c7335-95c9-4aa0-aa8b-dbc960b1967a	      "strictPeriods": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
9487dd17-5e6d-402c-903e-390dd3e0bcd8	      "strictDataElements": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
253c431b-22f3-4de5-b68f-7cb3333918a3	      "strictCategoryOptionCombos": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
508c1151-f32d-4d27-94b4-1bf186e00a3b	      "strictAttributeOptionCombos": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
1514c523-0e82-42b7-86ce-b630ca1fedb5	      "strictOrganisationUnits": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
0b222957-1fb8-4edc-9a64-3db3be626d5a	      "requireCategoryOptionCombo": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
e295743a-3be5-4552-b09f-24179fbd2496	      "requireAttributeOptionCombo": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
f71e7496-1bb8-4c7f-9693-8a77fb5dd6a0	      "skipPatternValidation": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
a845778c-3d72-4451-accb-794fcebfcfe9	      "ignoreEmptyCollection": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
beb69309-876c-42fc-98c7-87699ae601ac	      "force": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
c3b1eb2b-e9ec-43d7-a1a5-3fecad755f0c	      "firstRowIsHeader": true,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
4efa452e-eb96-4f17-ac37-74f566c06dfe	      "skipLastUpdated": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
bae95b8f-7127-4f74-93cf-ec41ea0fcca4	      "mergeDataValues": false,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
b369fbea-bdad-4fcb-907d-0e5587795312	      "skipCache": false	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
56806662-4dc0-4d10-9404-c68b4a518be0	    },	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
ce48bfde-6a44-4d98-97c6-7e9a59717c13	    "description": "Import process completed successfully",	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
21593495-50d2-42fe-812d-0d4e74dc8215	    "importCount": {	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
46598046-ec60-4e7f-9a7d-1b9403216233	      "imported": 0,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
1696b580-892a-4214-8a8a-f66218acadce	      "updated": 1,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
bb4d4d3e-ddc1-4030-898b-0acf2d93035c	      "ignored": 0,	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
3305369a-bf16-4d5b-a7c6-8ae1d762d83d	      "deleted": 0	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
3c312c3e-7aef-44e9-905b-fe214eda15b1	    },	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
5e4ae866-bdcd-4570-aae1-02e4ed9b4052	    "conflicts": [],	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
605e05da-b602-47b7-a3df-d773f02ccd8a	    "dataSetComplete": "false"	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
a55e37e6-e01c-485d-8db4-3877161db3aa	  }	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
200528d7-9ad0-430c-ad36-7860848091d3	}	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
b327476b-495f-439e-88ff-642b25f8f25c	[R/T] ✔ Operation 1 complete in 159ms	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
3f56e8fc-b3da-4d9c-8120-e383466e4547	[CLI] ✔ Writing output to /tmp/output-1690440364-7-1kikwyv.json	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
c8122ced-1bdf-4cf6-9389-5e6f2007d6c0	[CLI] ✔ Done in 571ms! ✨	\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
6dbde0c1-b9a8-4f9d-a32b-a5c742e262b6		\N	03a5486d-7217-4aa9-92ec-73253c18c425	2023-07-27 06:46:06
a0135665-a66b-4abd-8239-b6c50fcbc698	         ▸ compiler                  0.0.29	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
f61ec70e-e2d0-49cc-9175-7112d60a9cf4	         ▸ @openfn/language-dhis2    4.0.2	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
696e1c71-0a52-4c29-8ea4-623c25ede256	[CLI] ✔ Loaded state from /tmp/state-1690446847-7-12dcpvn.json	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
d9521540-a883-4608-a1fa-2b0a92caf882	[CLI] ✔ Compiled job from /tmp/expression-1690446847-7-17i4zif.js	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
2cd382a4-76d5-4cd8-bce0-b41b1a21ebe8	[JOB] ℹ John	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
7ff70c9f-2103-4b80-b48e-7b42d5646d91	[JOB] ℹ {	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
5f4b4e21-158c-42f1-8c1d-1c67e431f294	  "resourceType": "Patient",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
86cbdfde-f283-4881-afb8-1b7320dcd9c2	[CLI] ℹ Versions:	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
550dc098-85c7-45ab-aec1-20575dc48097	         ▸ node.js                   18.12.0	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
27470d0f-60ae-43cb-8fce-2bd3968ab03d	         ▸ cli                       0.0.35	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
00018e0a-f83c-4e25-a4d0-d217e805df48	         ▸ runtime                   0.0.21	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
83973a5f-c093-4fea-9479-ea013e0ea7d9	         ▸ compiler                  0.0.29	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
89c73bdf-2267-4024-999b-f4074da77ea9	         ▸ @openfn/language-dhis2    4.0.2	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
aa4e08b6-3005-4104-9881-c38123ac7502	[CLI] ✔ Loaded state from /tmp/state-1690440427-7-1gd3mko.json	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
5e9d6cda-2982-4c2b-b3d9-61797ef5b3f8	[CLI] ✔ Compiled job from /tmp/expression-1690440427-7-1ad3l5f.js	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
f84a7ab3-78d3-4d80-a4e1-b72016e6b986	[JOB] ℹ 453	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
61e65002-e2e1-4f67-b8da-05e00b0280de	[CLI] ✔ Writing output to /tmp/output-1690440427-7-1682lu1.json	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
e092c20f-a5f1-43e1-bfe5-68dca74ba1eb	[CLI] ✔ Done in 188ms! ✨	\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
48cb14cd-63c4-4fc7-b454-40fca9acbe7c		\N	4b80b600-9df9-4d26-a0c2-fd58e3cbce27	2023-07-27 06:47:08
eea0dc0a-5946-485d-b8e5-f0824572a978	  "id": "example",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
25c45216-086a-4c05-87bc-49e972a277d5	  "identifier": [	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
47b9611c-9f63-4ead-b8d2-e5663f7e566d	    {	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
e7ba7197-ca27-4fcb-9954-e18aecacb857	      "system": "http://example.com/patient-ids",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
8525b53f-c916-4600-a2e1-0c39dd2e89a1	      "value": "12345"	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
d1993207-330d-4b2c-8389-f252281463c0	    }	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
1ab2c370-8edf-42c2-b006-6164f7220eee	  ],	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
52de75fb-cdd5-4344-8912-dc2bc9223b02	  "name": [	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
1ed251f4-2103-476f-b8fd-b31a788775ac	    {	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
7b433065-4d81-43a5-a5aa-b0ffa1b2a48a	      "use": "official",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
1c12b7c7-a4a7-461a-8478-3de434ad26de	      "family": "Smith",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
5cec5b47-05f5-4de5-85f7-599fcc0bda60	      "given": ["John"]	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
4e074f17-8623-48c8-8fef-7823465a92b0	    }	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
30b9f651-2a95-4f31-8d13-22a6bfbc67c9	  ],	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
3fb8899c-4216-4108-8d20-3aa4d25f3912	  "gender": "male",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
3fa6f257-d995-4821-b5a2-7461807fd89a	  "birthDate": "1980-01-15",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
f36eb9a5-73f8-4cc7-a0d8-567d457f128e	[CLI] ℹ Versions:	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
e286dd52-e4ad-4370-859b-73faded7b641	         ▸ node.js                   18.12.0	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
96972ca2-3ca0-45ad-b4dc-15588bd9a80b	         ▸ cli                       0.0.35	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
6862a6fd-7eb7-477c-bdc8-357f47d74173	         ▸ runtime                   0.0.21	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
e7241f8b-b9f1-4077-a736-a8d1f04b334a	         ▸ compiler                  0.0.29	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
05956be2-9fa5-4284-91a6-c26b6371ccdb	         ▸ @openfn/language-dhis2    4.0.2	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
5dcb02bf-f368-4ec3-b02e-15ea23844887	[CLI] ✔ Loaded state from /tmp/state-1690440893-7-1vpopmu.json	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
f1e57408-08b9-4b1f-a5ea-337cddfa3c38	[CLI] ✔ Compiled job from /tmp/expression-1690440893-7-rpqypv.js	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
cb404f53-f80c-4054-8478-af9e6e3969b6	vm:module(0):1	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
48c08193-07cf-4823-a033-9eb910811ad8	const bodyData = JSON.parse(data.body);	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
453a81fe-854a-4d94-a65b-733ed5c680d9	                            ^	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
6e5e96a2-e639-4288-8188-fba924ae6b51		\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
317af02c-b687-44bd-a524-7ea7bc31e0bd	ReferenceError: data is not defined	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
1616ffa8-d485-43b4-93c2-814323730cab	    at vm:module(0):1:29	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
2f99315a-6507-4040-93a7-64927b4de7b8	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
e1e94122-aa10-417f-a1db-03172f57c637	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
8cbeae16-6a3c-4f87-b7b7-4757d81c955e	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
88fd75f4-9d98-4048-b135-c5cc6d8d1f62	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
32d74dbf-ca1f-41fc-b44b-386be86ae25e		\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
d0b0f32d-8bfe-4862-826a-856e0afb10ea	Node.js v18.12.0	\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
a0e7e233-c89f-4f12-b99f-d53f35b8b159		\N	56c8bf73-9c74-4205-a6f9-ec481010c122	2023-07-27 06:54:54
f82e9603-b8af-406c-9992-ec69567de5fd	[CLI] ℹ Versions:	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
c4f223ed-78e4-413a-9bb9-2b31e0ff0c27	         ▸ node.js                   18.12.0	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
688c8a10-309a-4b72-89ff-031837f157c2	         ▸ cli                       0.0.35	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
d9f95969-3155-4416-bf11-b11ee2a87dd1	         ▸ runtime                   0.0.21	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
5d2e6551-cffd-436f-9b9c-ceab0fe93784	         ▸ compiler                  0.0.29	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
9d170b97-3998-4941-bd1f-a91e813a27b5	         ▸ @openfn/language-dhis2    4.0.2	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
dc2d10b5-9bc7-4337-9eb5-8f3877cc937f	[CLI] ✔ Loaded state from /tmp/state-1690441023-7-1eq8u5.json	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
424415cd-9806-4871-aed1-d8c461242356	[CLI] ✔ Compiled job from /tmp/expression-1690441023-7-njwt9o.js	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
4459fb5b-8953-40a3-8d40-746ec3fa9962	undefined:1	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
86f208bf-39b5-48f1-b0c0-af4262ed218a	undefined	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
381ac5b3-10ee-4f53-b258-a13723d6c5da	^	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
46379fcd-6122-4cfa-8d14-723cc54faf50		\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
d3e162b1-1f20-4ed5-8383-ea62dad014b1	SyntaxError: Unexpected token u in JSON at position 0	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
c68c22e8-c434-4710-8bbd-ef0cb15125b3	    at JSON.parse (<anonymous>)	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
cfeea356-5a03-4012-b085-d5214efdc126	    at vm:module(0):1:23	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
b99b1ec3-5af7-449a-b443-cb8d2bf57e3f	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
c7166e76-3e1f-4f73-b840-0601d230f98a	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
63305ba6-76ef-4ec8-9a2d-cd1a0a9e7cec	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
29aee5e9-1f7b-4a64-9343-df8a062983b7	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
0ebceb2e-a897-4903-b175-5791b923d674		\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
9b4d7d0b-01ee-4893-b6c2-e3691c99643b	  "address": [	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
d1326620-d98e-4614-a228-b197f7ecdeec	    {	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
61bbffa8-a7de-491e-93ce-c2abd6990c53	      "use": "home",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
6fcd40db-d417-4706-880e-5a40f8776646	      "line": ["123 Main Street"],	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
b652694d-a1d3-4e09-b7f5-5e7793dcb3b2	      "city": "Anytown",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
8b01b888-1d09-45f4-b254-9e8e505a0d09	[CLI] ℹ Versions:	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
ef7efaaf-3db4-45b8-b63a-04822639602b	         ▸ node.js                   18.12.0	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
fefaa9e8-cce4-412e-9d44-850a485b620e	         ▸ cli                       0.0.35	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
b6d00297-cdd8-4300-b4a7-dfebadf0f56b	         ▸ runtime                   0.0.21	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
c9d7d95c-876c-4e53-9b27-957dd9997532	         ▸ compiler                  0.0.29	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
145fe519-f73b-4e21-9029-504be1fa9046	         ▸ @openfn/language-dhis2    4.0.2	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
c4a7d1ae-d692-4c12-8014-c42816eff0a8	[CLI] ✔ Loaded state from /tmp/state-1690440454-7-awup7w.json	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
930858a0-d93e-4b9b-a94f-2e323d696ecc	[CLI] ✔ Compiled job from /tmp/expression-1690440454-7-1xa0sbi.js	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
a7443351-cd2f-495e-9007-1072e1866984	[JOB] ℹ undefined	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
8614714b-6788-4b6a-92c1-6a4e3dbe1661	[CLI] ✔ Writing output to /tmp/output-1690440454-7-1a56dam.json	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
b8aba292-3a7b-4a04-8d09-ea73ae562e94	[CLI] ✔ Done in 174ms! ✨	\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
dffe427e-ae35-4347-b6a5-d5ad9c6c8bf4		\N	0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	2023-07-27 06:47:36
0db33af2-2109-4181-beff-e64395a307a7	[CLI] ℹ Versions:	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
a5dce36d-6d6b-4250-91bf-ef79d8c778c6	         ▸ node.js                   18.12.0	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
0e3fe4d9-f69f-44fd-9e6e-ad8bb7ee0301	         ▸ cli                       0.0.35	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
94b12275-03e9-451c-9d78-0011f58ee09b	         ▸ runtime                   0.0.21	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
5cd5ba09-f210-43f5-b335-fb5c5bb34e79	         ▸ compiler                  0.0.29	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
0de416b3-98f5-41ff-b32c-2e07c3f186eb	         ▸ @openfn/language-dhis2    4.0.2	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
bc46d5f0-05d8-4c61-9296-db1bd2e168fd	[CLI] ✔ Loaded state from /tmp/state-1690440508-7-1eu77vd.json	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
542b60d3-fe27-4538-ae24-63f12aa29e40	[CLI] ✔ Compiled job from /tmp/expression-1690440508-7-1c8qkm1.js	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
06fc3eec-0737-4445-837f-12d3487c6549	[JOB] ℹ {"dataElementId":"katOVrpL1eJ","juneValue":453,"organizationUnitId":"BnVfkK2iFFH"}	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
f9f335c0-8d47-4f04-b2b9-2a52e24771aa	[CLI] ✔ Writing output to /tmp/output-1690440508-7-t12cax.json	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
d715e01a-00d2-49df-91b8-59ab63a52708	[CLI] ✔ Done in 185ms! ✨	\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
db21ed54-e829-46ab-b475-25f392278a23		\N	08a52546-820a-46c4-970e-47c864ad374d	2023-07-27 06:48:29
acefa002-7a98-4596-8d87-792295225fbc	[CLI] ℹ Versions:	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
a1899125-1cae-49a3-848b-cbdfec99fe90	         ▸ node.js                   18.12.0	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
3c470ac5-7f9d-4cc5-b23f-111d9e56768f	         ▸ cli                       0.0.35	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
0fa43da9-8258-4644-9564-fecc9d40c604	         ▸ runtime                   0.0.21	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
1adbd537-bc21-45e3-81af-7391f3825957	         ▸ compiler                  0.0.29	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
7b52e115-d3cb-45f3-a3a9-476a5cc3fd14	         ▸ @openfn/language-dhis2    4.0.2	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
b872923e-e23a-4f51-b3b7-5dd025fac494	[CLI] ✔ Loaded state from /tmp/state-1690440600-7-f7ixlf.json	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
3dd1f4fa-f72c-4c11-af70-20566c380b70	[CLI] ✔ Compiled job from /tmp/expression-1690440600-7-1q7euek.js	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
9c55ad0d-573a-441e-be2e-7dd1c520e0a8	[JOB] ℹ {"data":{"dataElementId":"katOVrpL1eJ","juneValue":453,"organizationUnitId":"BnVfkK2iFFH"},"configuration":{"apiVersion":"****","hostUrl":"****","password":"****","username":"****"}}	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
3ac874db-049d-4bfe-8af3-c3b003ebd4e4	[CLI] ✔ Writing output to /tmp/output-1690440600-7-1dl9knk.json	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
b9d42a1d-0d98-4d96-bf94-f01a9a243151	[CLI] ✔ Done in 176ms! ✨	\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
e10da282-5c8d-44bd-a6a3-671410ea8fcb		\N	571c80f8-2c20-446d-b43e-225bf222480a	2023-07-27 06:50:02
48aa2658-b7f4-401e-990a-98fef4a2abd0	      "state": "NY",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
f4eddf75-95c8-4ede-a2f9-b1a0e2806b9f	      "postalCode": "12345",	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
326f942b-8319-4992-ba23-3ae9a577a60b	      "country": "USA"	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
56f47a84-9f13-4552-a941-d0f762f12cf1	    }	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
1a4ede65-f603-4671-9741-82d75e3a534c	  ]	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
d5a4a284-ac25-4b92-9c77-5cea14569b3d	}	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
5cb0204d-9942-4847-bd2e-d9ab1857eddf		\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
23b5b18d-8831-45ed-9114-0702562da599	[CLI] ✔ Writing output to /tmp/output-1690446847-7-1srzm16.json	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
2bb906ed-ffea-47dc-b1ce-7c89be34c8b8	[CLI] ℹ Versions:	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
e0c977c9-3c4d-4415-9a3f-3154a1780b0f	         ▸ node.js                   18.12.0	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
3223fb63-2ef5-4d31-aac5-e3686fd25b13	         ▸ cli                       0.0.35	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
5e4c7013-3d46-4b9b-adf2-39bd15197cb6	         ▸ runtime                   0.0.21	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
d7c9341c-d422-423e-9089-c97cd69a246b	         ▸ compiler                  0.0.29	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
a411b758-ad59-4820-96e0-4709cf4ede2e	         ▸ @openfn/language-dhis2    4.0.2	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
848c7b36-9739-4e31-aa5d-2005c9bbba46	[CLI] ✔ Loaded state from /tmp/state-1690441120-7-s4sk1g.json	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
46fd4bb4-10f7-4993-8509-fe791b14bcff	[CLI] ✔ Compiled job from /tmp/expression-1690441120-7-1jl7v9o.js	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
3dc82304-086f-4e86-83b4-6551a68d49dc	[CLI] ✔ Writing output to /tmp/output-1690441120-7-s2y7y5.json	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
e253d798-2f14-4f26-a29e-8cd413401e70	[CLI] ✔ Done in 190ms! ✨	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
bd87c4ee-c3bb-4647-809f-147cee3cb1fe	[JOB] ✘ Error: state.body is empty or undefined.	\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
54608589-ee23-48d6-81dd-48bb81f20601		\N	c03b645b-7660-4ccf-a855-89d49e29e125	2023-07-27 06:58:42
31cd9dcf-14e1-4a42-a14c-e57813e2bcae	[CLI] ℹ Versions:	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
648bd28c-b6cd-4c9e-a621-a66744645ed7	         ▸ node.js                   18.12.0	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
5cd6b1df-6516-446f-b632-76fc4ba679dc	         ▸ cli                       0.0.35	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
7302e594-2e99-42c9-97ce-b6e7c7107903	         ▸ runtime                   0.0.21	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
b8724f89-d6cd-40b6-8211-d3ea5f442ef5	         ▸ compiler                  0.0.29	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
d864a416-fb64-4edc-a077-de17a2117a02	         ▸ @openfn/language-dhis2    4.0.2	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
83ddec5e-f8ea-4ec7-9472-66c2ec196140	[CLI] ✔ Loaded state from /tmp/state-1690442104-7-smaloa.json	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
d2b32a0b-dc2d-4a3b-b322-c9a146b396c6	[CLI] ✔ Compiled job from /tmp/expression-1690442104-7-b8ga8p.js	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
1e0f60ba-ba6d-4f6c-964f-7fb7c82f0ca7	[JOB] ℹ {"data":{},"configuration":{"apiVersion":"****","hostUrl":"****","password":"****","username":"****"}}	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
3f6ae38c-2d7b-4379-b040-5fbc7b0fc737	[CLI] ✔ Writing output to /tmp/output-1690442104-7-14z9xxv.json	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
6da39824-8083-4aa6-a5e4-54844357d85a	[CLI] ✔ Done in 168ms! ✨	\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
7b949806-ad76-45a8-8137-4517c048064b		\N	b62992fe-9021-410b-9f81-a6da3455cc58	2023-07-27 07:15:06
981bc5f8-c61d-46d1-818c-d4de50d8a8b8	[CLI] ✔ Done in 172ms! ✨	\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
2241e9e0-cc34-4bdc-9c34-b42e938687cc		\N	2269ac9d-ded7-4813-893c-4a24df1560ba	2023-07-27 08:34:09
549959b8-df43-4688-b136-6718df635356	Node.js v18.12.0	\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
ad9241ba-a8d9-40e7-88a4-54543acb55f8		\N	94424bee-028f-4448-ae84-b315d7a181fe	2023-07-27 06:57:04
ae373eee-65dc-4155-9dff-718bc925eeda	[CLI] ℹ Versions:	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
8a10e065-b0af-47ff-aff9-9c94041a65a0	         ▸ node.js                   18.12.0	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
37f4d42f-d9d7-452c-a516-1fefafd76b62	         ▸ cli                       0.0.35	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
cfdb17fc-6e52-4a5a-91cc-31888a4e5ff1	         ▸ runtime                   0.0.21	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
55d9ac31-1954-4d7b-8690-16b2e09dde9b	         ▸ compiler                  0.0.29	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
94769991-8044-41e1-8df3-58b93da53306	         ▸ @openfn/language-dhis2    4.0.2	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
f7e18120-56b8-473b-b34a-b777c626c8ea	[CLI] ✔ Loaded state from /tmp/state-1690447748-7-1qrcck2.json	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
e7fc183c-9a3e-4f70-92fc-feae489e9d6e		\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
d22aa626-53a2-495a-9521-dd5f6a672c0d	[CLI] ✘ Command failed!	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
32fbef0f-cf2d-4a19-aced-a625137cc457	[CLI] ✘ SyntaxError: Unexpected token (3:60)	\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
3ae309ac-971b-40fd-b2e8-75c473a2a04b		\N	46622a53-3638-4674-991c-1e78b9c425ae	2023-07-27 08:49:10
5523ab1d-1a8a-4e29-816a-0fb473f4d870	[CLI] ℹ Versions:	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
980014e1-1e48-44f8-9d0f-e3e0a91a26f2	         ▸ node.js                   18.12.0	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
3c8e5cf2-7d52-487b-867d-d96d3355ec5d	         ▸ cli                       0.0.35	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
02dbbfe8-6f05-400b-acfc-0489a64f31af	         ▸ runtime                   0.0.21	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
82ddd49e-bc11-4af4-9e08-75f83e1e9831	         ▸ compiler                  0.0.29	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
a13b9cdf-384b-406f-a91d-53094ec308eb	         ▸ @openfn/language-dhis2    4.0.2	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
fb6eeadd-5e34-4cd8-84e7-87de5f74780a	[CLI] ✔ Loaded state from /tmp/state-1690442073-7-sc8gyj.json	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
da364bf3-fc3f-4adc-9fa5-a6d44dbe7c7d	[CLI] ✔ Compiled job from /tmp/expression-1690442073-7-1y69cbm.js	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
43b5ab4f-9667-488d-9a8b-5380e89b65e5	[JOB] ℹ {"data":{},"configuration":{"apiVersion":"****","hostUrl":"****","password":"****","username":"****"}}	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
ce86ecda-751d-47b2-83c0-4920993b0528	[CLI] ✔ Writing output to /tmp/output-1690442073-7-1u76ewv.json	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
c619f562-f5aa-4ab2-b553-d919809fda1a	[CLI] ✔ Done in 172ms! ✨	\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
9f0d84b5-c1a6-4057-8bcc-86e3cda209ae		\N	2a8b8c20-6a06-4a86-8f53-01256d256e51	2023-07-27 07:14:35
36f65270-fb63-4d13-950c-f2c9b670fa1d	[CLI] ℹ Versions:	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
aab60670-4570-4812-bf79-1199531e1948	         ▸ node.js                   18.12.0	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
bbe8e523-bdc2-4bca-844b-e23055625551	         ▸ cli                       0.0.35	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
48cabe8d-50cc-4fd2-af34-31c7837d915e	         ▸ runtime                   0.0.21	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
21e730e6-090c-4506-95ae-55d1c2938480	         ▸ compiler                  0.0.29	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
ae746f4f-043c-42c3-8397-521627510fb9	         ▸ @openfn/language-dhis2    4.0.2	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
8a6d5705-fed4-4e3f-afb4-aefffe8d8898	[CLI] ✔ Loaded state from /tmp/state-1690447789-7-1hk379l.json	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
48c682d9-52f9-43b6-9d19-2f2b9d61db18	[CLI] ✔ Compiled job from /tmp/expression-1690447789-7-1io2e23.js	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
fa5be497-129d-4a3f-b9a2-092b4d5ec255	[JOB] ℹ Negative	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
7a2dddbb-bedf-4f72-9f57-14b11623391d	[JOB] ℹ {	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
e8270b0f-ee58-4906-b2a0-c68e8928ae15	  "resourceType": "Observation",	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
4c57163c-611a-4291-93a4-8517a1e92bf0	  "status": "final",	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
304180a2-a150-42df-be2a-10da0ab5e914	  "code": {	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
21349925-ef75-4721-9803-c5befe149f1c	    "coding": [	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
6f164f78-0d78-466c-b4a1-49b9b68f93bc	      {	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
a7c3bd9c-921e-47c1-8cf2-b97c90b6d2e9	        "system": "http://loinc.org",	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
5583116b-7330-4749-814a-956db8d54822	[CLI] ℹ Versions:	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
178ef89f-8784-4586-861a-e85b44d07518	         ▸ node.js                   18.12.0	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
5d36587f-37d9-481f-8c81-594c13a46f5d	         ▸ cli                       0.0.35	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
29eef64a-e76b-4105-98d5-d39c3681ca09	         ▸ runtime                   0.0.21	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
f4b35844-e1b0-4432-914c-c51648c197a2	         ▸ compiler                  0.0.29	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
ce5ea4dd-79f1-4b8e-ba6a-3f491f573f4a	         ▸ @openfn/language-dhis2    4.0.2	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
48482947-259a-4705-bfad-315559f53421	[CLI] ✔ Loaded state from /tmp/state-1690442177-7-1kdrco4.json	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
1aab8efd-c1ae-4a38-9851-b429aa1481c9	[CLI] ✔ Compiled job from /tmp/expression-1690442177-7-1v3nw0p.js	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
12fa7ad7-298a-4fb0-8a86-c6a54f29ade3	[JOB] ℹ {"data":{"method":"POST","path":"/Patient"},"configuration":{"apiVersion":"****","hostUrl":"****","password":"****","username":"****"}}	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
97bfa479-715d-41b7-a709-da455f46d854	[CLI] ✔ Writing output to /tmp/output-1690442177-7-1mso9pm.json	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
d6d316ca-72fa-4b8a-b4b4-669efb57873e	[CLI] ✔ Done in 178ms! ✨	\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
ddf2ce2f-8fb2-47d5-8882-fef33676db46		\N	07834ac1-5493-4e68-ad2d-cd6f32b07cb3	2023-07-27 07:16:18
0a0beb0e-5d03-4f04-8c61-53f89fbb035a	[CLI] ℹ Versions:	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
d389e614-bef3-4eba-87a4-be4fada75a08	         ▸ node.js                   18.12.0	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
e6590e6c-07e7-49d5-a45d-57e393b0d209	         ▸ cli                       0.0.35	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
a4810e02-7e16-489f-8b93-ae18e46165a0	         ▸ runtime                   0.0.21	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
0a2c57e8-333e-49c3-beba-5f26e5835569	         ▸ compiler                  0.0.29	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
d31de7ec-5ef8-4f3c-b614-c278b4cd601c	         ▸ @openfn/language-dhis2    4.0.2	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
e070461b-229e-41b8-bd17-b65992c65283	[CLI] ✔ Loaded state from /tmp/state-1690442337-7-1ymln8y.json	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
76d99b13-3510-4480-a69c-0845c57b3ba8	[CLI] ✔ Compiled job from /tmp/expression-1690442337-7-s10nnb.js	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
5a173d78-0aee-4f8b-a046-9196e09137b8	[JOB] ℹ {"data":{"body":"{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"},"configuration":{"apiVersion":"****","hostUrl":"****","password":"****","username":"****"}}	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
2915e68b-0c66-4833-8b76-430793112dea	[CLI] ✔ Writing output to /tmp/output-1690442337-7-1f2mm8j.json	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
a9413129-1a8d-4666-a26a-e298be742ec5	[CLI] ✔ Done in 183ms! ✨	\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
24a805bf-750c-4755-a4e3-545e08d8a230		\N	2525b5d3-be12-4e41-af8d-bdc71398c135	2023-07-27 07:18:58
b042860f-0d81-44e3-8bf0-b335b1e7636b	        "code": "38372-9",	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
e6fe2d20-a52b-470e-996f-62e0c4c399b9	        "display": "HIV-1 and HIV-2 Ab SerPl Ql"	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
32b764b8-52ef-4f97-8ebd-3cddc8470cfa	      }	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
3362312c-a3cb-4e1b-89ac-c8684c3963cd	    ],	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
3ab072e7-ab45-4988-b316-ee3cc1966bdf	    "text": "HIV Test Result"	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
d1b20705-7d64-4f60-bc99-6d033311bd23	  },	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
5c62ff11-7c1c-42aa-b345-45ecfd5dc18c	  "subject": {	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
612808ef-1652-4f0b-a6a1-7f74e4799ca7	    "reference": "Patient/example"	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
38e970b6-1be8-4ff8-9601-b1ab871da8c7	[CLI] ℹ Versions:	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
dab8628e-3019-4f2c-8173-7698f8db0553	         ▸ node.js                   18.12.0	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
69d667ab-929a-4741-ac93-c7ab36283c7f	         ▸ cli                       0.0.35	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
d9efe3fa-95f9-4a89-97b0-f77358b6cea2	         ▸ runtime                   0.0.21	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
98f7e133-55e2-4714-9d98-ac2ab0707c0c	         ▸ compiler                  0.0.29	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
63fbebb2-98f5-445f-912b-2fc4209bbcd5	         ▸ @openfn/language-dhis2    4.0.2	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
582eea6c-0894-409e-8937-c52cccbb09a1	[CLI] ✔ Loaded state from /tmp/state-1690442743-7-17yabn8.json	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
beb12e7b-93c7-434b-8ea7-4fc9cb7fadad	  },	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
4e05678d-2523-4a90-a3f0-1cb18d40d6fa	  "valueCodeableConcept": {	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
46a9cbe7-30ff-4ecc-bf1b-8e499c087990	    "coding": [	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
6eb8a56e-9618-4f86-b95e-3b4e50ce88b9	      {	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
0b83b32f-6ed7-4796-8452-5413f6646b97	[CLI] ✔ Compiled job from /tmp/expression-1690442743-7-16sxm68.js	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
ca391469-1e78-44c8-8a37-c24da9f8bbe8	[CLI] ✔ Writing output to /tmp/output-1690442743-7-6164o3.json	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
8eaf0378-705b-41c5-88b7-11363313c112	[CLI] ✔ Done in 170ms! ✨	\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
80b4f230-aacd-48fd-8387-46d4d5077c04		\N	3d4f3844-2746-4138-82fa-cb1ce19e9c2c	2023-07-27 07:25:44
9f1d3ef7-9544-4f24-8b64-9e2416444091	[CLI] ℹ Versions:	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
584b1038-690e-422d-9e52-51fde65e8351	         ▸ node.js                   18.12.0	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
5c68b08d-8122-4750-a7ac-2257dd2c3d71	         ▸ cli                       0.0.35	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
fe24f05c-7ecb-47a4-ae0a-69c5b5606d4d	         ▸ runtime                   0.0.21	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
7356d422-136d-4ceb-ae4a-8d1f582178ce	         ▸ compiler                  0.0.29	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
b66901bb-5b19-409e-a9a1-e09f796cbc1b	         ▸ @openfn/language-dhis2    4.0.2	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
32ed059a-42be-4189-9401-79244fc9cc0e	[CLI] ✔ Loaded state from /tmp/state-1690442757-7-cmau5p.json	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
9ef6e697-2047-4c7f-8a38-58f78abfce51	[CLI] ✔ Compiled job from /tmp/expression-1690442757-7-tec5o8.js	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
5ce02c7f-dda1-4d43-a0e0-426b733e19b3	[CLI] ✔ Writing output to /tmp/output-1690442757-7-4av8r0.json	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
3190b7c9-ca07-4a7c-9ae2-1508bed8ceb7	[CLI] ✔ Done in 172ms! ✨	\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
1a3ee74d-ddd4-413e-b032-a68f4cc2fdf8		\N	9af1e6bb-a703-4677-ad6c-bb193493555f	2023-07-27 07:25:58
c2c2a9fe-05e7-47fa-9b36-1b0d07b5d821	[CLI] ℹ Versions:	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
051070e7-599b-42fa-80a2-b0e3a8ac75ef	         ▸ node.js                   18.12.0	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
e9f1c0ee-e11b-4bfd-9b25-168c4df9dd59	         ▸ cli                       0.0.35	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
596b68b8-0bfb-4c4a-b658-17bfb0ca30a6	         ▸ runtime                   0.0.21	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
fb3816f5-3c3d-4add-8169-06163d963e73	         ▸ compiler                  0.0.29	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
993fab4d-f975-4759-a932-9c134318f293	         ▸ @openfn/language-dhis2    4.0.2	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
c946badb-30ba-41ae-b7fa-355e21ad2a79	[CLI] ✔ Loaded state from /tmp/state-1690442817-7-sqgom3.json	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
401d5fe8-483a-4983-a331-9cd5d68e28c4	[CLI] ✔ Compiled job from /tmp/expression-1690442817-7-1tbd8yd.js	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
8b71449c-6957-4eeb-9003-3c6b471c3aaa	[CLI] ✔ Writing output to /tmp/output-1690442817-7-kwoqqr.json	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
9d674a53-8f3a-442d-a606-388d1b82727c	[CLI] ✔ Done in 186ms! ✨	\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
dd28ebea-1107-4f1b-a84c-4309d15c5a92		\N	9c49f307-53dd-47e7-9f93-c6aae3dacc66	2023-07-27 07:26:58
55bbead1-f894-45de-aaf4-4e690bd60318	[CLI] ℹ Versions:	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
885e5774-dc30-4a87-ae39-513ee069a95f	         ▸ node.js                   18.12.0	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
b2171535-4405-474e-ad37-fd8c7ec76d7f	         ▸ cli                       0.0.35	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
13461e22-0b66-4b5c-8353-8d4049d7a3c7	         ▸ runtime                   0.0.21	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
40bcaf0f-b9a6-4e52-9a6f-0da9b861d1a7	         ▸ compiler                  0.0.29	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
27c1a4ad-a1b1-44e5-bf58-cf2f4f75602b	         ▸ @openfn/language-dhis2    4.0.2	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
b036a796-d3a5-4088-9865-d6ef11216367	[CLI] ✔ Loaded state from /tmp/state-1690442838-7-1di69ho.json	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
36575a3f-9163-4b1c-bdde-9e5330e6eeb6	[CLI] ✔ Compiled job from /tmp/expression-1690442838-7-zsglbx.js	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
71d612a0-25ef-44e3-a293-26153c73a1ff	[JOB] ℹ {"body":"{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
08d22635-d49b-4854-a7e7-29d56b81d063	[CLI] ✔ Writing output to /tmp/output-1690442838-7-19i5feg.json	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
4f1e9b7a-6b71-471f-a696-bcce427c04bc	[CLI] ✔ Done in 166ms! ✨	\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
9735c392-3145-447a-9400-0fb40e050e02		\N	116d76b9-4626-407d-aff2-95fab7dfc76d	2023-07-27 07:27:20
333afce3-d223-4153-bc37-5538690e432a	[CLI] ℹ Versions:	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
88831ab7-8578-4f59-95a3-b0413b96ecf4	         ▸ node.js                   18.12.0	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
5288fb66-430a-4616-b327-34c6592fe639	         ▸ cli                       0.0.35	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
28aae4d2-3554-4ef1-8c00-1ce18334dd32	         ▸ runtime                   0.0.21	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
9cad0565-0413-4367-955b-b79aa4f06be9	         ▸ compiler                  0.0.29	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
aa156785-219b-47d6-89db-4a07a789ec5b	         ▸ @openfn/language-dhis2    4.0.2	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
52583884-95a0-46fc-86c0-53ae10bc28ad	[CLI] ✔ Loaded state from /tmp/state-1690442936-7-agodam.json	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
9773a630-45ce-40b7-816d-321325c0a368	[CLI] ✔ Compiled job from /tmp/expression-1690442936-7-1q4dqwg.js	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
9b03040a-94e6-48eb-9597-1a257f45fcf1	[JOB] ℹ {	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
1882a85c-c6b4-4486-8593-42386e73b5da	    "dataElementId": "katOVrpL1eJ",	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
3f76ba3d-d71e-41fc-a5b8-494986ed44b2	    "organizationUnitId": "BnVfkK2iFFH",	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
59cfe787-6477-450e-9cbf-4d7b56bc2f59	    "juneValue": 453}	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
abbbfbf2-1f8f-48b1-a72e-80bd45b77d9c	[CLI] ✔ Writing output to /tmp/output-1690442936-7-13oqtuc.json	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
40f07c1b-6405-4aed-a856-8f0d230aa5c3	[CLI] ✔ Done in 176ms! ✨	\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
cc50d77d-cf13-4f8c-8a24-4edfdc6f272a		\N	4cc8c32e-4130-4906-bff9-f1bf32479227	2023-07-27 07:28:57
dc9a4b08-463c-4b59-9208-aca7209f3932	[CLI] ℹ Versions:	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
df49ff36-b332-4d0e-afea-c7b45f522f93	         ▸ node.js                   18.12.0	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
cb60e27b-72a0-415e-8c82-964220358662	         ▸ cli                       0.0.35	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
909ddd06-37a4-4c4c-b06f-747ddf0e8b95	         ▸ runtime                   0.0.21	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
05752fdf-e416-4be9-a100-b0746c4548e8	         ▸ compiler                  0.0.29	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
cb68deac-5d2a-415d-a0da-1d85915f58c7	         ▸ @openfn/language-dhis2    4.0.2	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
c31dda26-c2fd-46b9-b40c-9f8b656cbed5	[CLI] ✔ Loaded state from /tmp/state-1690443039-7-1wya8qu.json	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
245b3362-3e25-4ea2-91a0-45e696435e2e	[CLI] ✔ Compiled job from /tmp/expression-1690443039-7-1c0lapf.js	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
f386f25e-6496-4a31-807f-b29cc7fe12fb	[JOB] ℹ {	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
59df3a3a-3606-4705-a91e-10f9a498cb7b	    "dataElementId": "katOVrpL1eJ",	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
aa95cdde-8e01-4830-8c11-aa916efef405	    "organizationUnitId": "BnVfkK2iFFH",	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
19232f2b-96ca-479d-ba13-906ab7b61cc1	    "juneValue": 453	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
7297427a-f952-4de3-adfd-a0df82e43eaa	}	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
72f0c7c8-4104-430b-afa8-d7c933d5af5a	[CLI] ✔ Writing output to /tmp/output-1690443039-7-m6t192.json	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
5f7064b1-cc1c-4b1a-8647-c6d296839fa3	[CLI] ✔ Done in 168ms! ✨	\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
68092d6d-c736-4bc8-af64-088733abd42a		\N	b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	2023-07-27 07:30:40
f2a7c5d4-8b3e-420e-99c7-3b1022e38fb7	[CLI] ℹ Versions:	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
53d572c7-5e33-40ab-bad5-410773b56e90	         ▸ node.js                   18.12.0	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
13efa631-2a3e-45d3-b45e-d8e6d9fed00b	[CLI] ℹ Versions:	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
7ce5c8f1-51ea-4203-8feb-0545db555a24	[CLI] ℹ Versions:	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
3aade099-3cd2-413d-8b65-1d2bf616e558	         ▸ node.js                   18.12.0	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
aa4a407b-fc9e-46d5-a115-c5c59bedecd0	         ▸ cli                       0.0.35	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
e1311c25-3885-4aee-940f-2fae75dac553	         ▸ runtime                   0.0.21	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
a0ef145c-7050-4840-a310-f69077f4cb0c	         ▸ compiler                  0.0.29	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
79ba5b36-20e5-4955-9b3a-557fb6a53e7e	         ▸ @openfn/language-dhis2    4.0.2	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
01570d72-4eea-4a37-afc7-27b3db2485fb	[CLI] ✔ Loaded state from /tmp/state-1690442840-7-blfzbc.json	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
ada73e40-1d1b-4321-a23b-6c00b6deb8d5	[CLI] ✔ Compiled job from /tmp/expression-1690442840-7-pznywm.js	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
7558b5d6-5752-4393-9168-0c2a9a46c03f	[JOB] ℹ {"body":"{\\n    \\"dataElementId\\": \\"katOVrpL1eJ\\",\\n    \\"organizationUnitId\\": \\"BnVfkK2iFFH\\",\\n    \\"juneValue\\": 453}"}	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
e28c45be-e7cc-45fe-ac23-59941fa5366d	[CLI] ✔ Writing output to /tmp/output-1690442840-7-133a44c.json	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
52f010fe-a2a5-4ed0-9bf2-c63342721994	[CLI] ✔ Done in 168ms! ✨	\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
1e4e519e-35cd-440a-9f0d-1f1780c2b7f4		\N	9a0990a8-c786-42f0-af2d-fe9198d2bcfa	2023-07-27 07:27:21
8dc07e7c-33db-49c3-9f22-9764a1f0c7ac	[CLI] ℹ Versions:	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
e52dee03-15c2-4945-ab27-ef5e165c23e7	         ▸ node.js                   18.12.0	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
3df4b08d-77eb-45c5-a836-8344022c91a9	         ▸ cli                       0.0.35	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
8ddd7270-f661-463f-8625-b683307aa774	         ▸ runtime                   0.0.21	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
cac5e2ea-91a6-4be8-86e3-931ac30c9f31	         ▸ compiler                  0.0.29	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
8598f7d1-525a-4680-a36f-cdf1d9ccf960	         ▸ @openfn/language-dhis2    4.0.2	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
9c599912-271d-48ea-a334-b05cf064d64e	[CLI] ✔ Loaded state from /tmp/state-1690442890-7-1d4zpf0.json	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
472c9aa5-3e3b-4c53-bafd-13561c13f60e	[CLI] ✔ Compiled job from /tmp/expression-1690442890-7-1t3q6dg.js	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
28c0c350-5daf-4705-bb1f-361742f8d7f0	[JOB] ℹ {	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
c3b8d2a8-8334-438b-ba4c-0660512db809	    "dataElementId": "katOVrpL1eJ",	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
066581cf-4785-48df-972b-153657364049	    "organizationUnitId": "BnVfkK2iFFH",	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
85a8062a-13b3-4b8f-84a4-4c1650eee992	    "juneValue": 453}	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
fa9986ba-b107-43f6-aba4-e221afc9a28e	[CLI] ✔ Writing output to /tmp/output-1690442890-7-iwnols.json	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
3987a2ec-dc24-41fb-ab72-02a5a6354b35	[CLI] ✔ Done in 171ms! ✨	\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
6157c70f-0e35-41d2-847b-a1f3f448d959		\N	f6f165d0-6782-4687-b3c0-1c54c54761f1	2023-07-27 07:28:11
905ae5a9-489d-4c99-83b5-248b750bc483	        "system": "http://snomed.info/sct",	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
0daf5ae9-2d98-4aec-84e7-e3d504f29f94	        "code": "260385009",	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
6a056069-3e59-47d0-bd86-3d16fffd156d	        "display": "Negative"	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
ee07fb59-42b0-4449-969e-eb43fb215d1a	      }	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
35f8a0d1-aefe-4624-b91e-68474a90b160	    ]	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
a1e3858a-9131-47b2-8c10-27656cbe3dbf	  }	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
9d76e87e-22fa-4788-94dc-152f26cedaf6	}	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
64057f40-174b-4e32-8182-e3f488cf761d	[CLI] ✔ Writing output to /tmp/output-1690447789-7-4d2fdm.json	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
098e8032-3f5d-4114-9df8-9265bdf23793	[CLI] ✔ Done in 189ms! ✨	\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
a65ae6df-1336-4204-a6a2-aaba2ed303ef		\N	d80b9880-0447-41c5-bf7c-3ed047767ed1	2023-07-27 08:49:51
2063dcd0-cbea-4100-b281-a0ab885deaaa	[CLI] ℹ Versions:	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
50bbdba4-7fcc-42d0-8b32-2fdb82292c76	         ▸ node.js                   18.12.0	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
c17a56cc-23e0-4f2b-97a5-19de2feb4c42	         ▸ cli                       0.0.35	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
b4a64430-10ef-415c-85aa-9806babd2d3b	         ▸ runtime                   0.0.21	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
e7089fd3-66ca-4ef6-a5bb-a137ae0216a0	         ▸ compiler                  0.0.29	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
93233199-ba94-418e-b3d3-57ec6c2594ca	         ▸ @openfn/language-dhis2    4.0.2	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
48d9d6a6-7b17-42c6-af2d-cedf3d92f166	[CLI] ✔ Loaded state from /tmp/state-1690442919-7-1t3feoy.json	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
dc6d4be9-3ac7-440f-945f-0e0d24885d21	[CLI] ✔ Compiled job from /tmp/expression-1690442919-7-9w0b12.js	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
c7695714-2a55-4dac-887d-5c5a8c499136	[JOB] ℹ {	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
bb65d91f-85de-45d5-a486-e0dc7873c3e6	    "dataElementId": "katOVrpL1eJ",	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
ad204785-5658-42f0-91b5-51d3c462aee1	    "organizationUnitId": "BnVfkK2iFFH",	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
724df5ce-84b0-4e2d-ac70-e1f16e4471e5	    "juneValue": 453}	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
a6ac4a29-2f88-4aba-8c2a-a83c89324d86	[CLI] ✔ Writing output to /tmp/output-1690442919-7-7lozj5.json	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
624a9404-3373-4bbb-81ba-d11b0c34442b	[CLI] ✔ Done in 168ms! ✨	\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
4479100e-e1cd-47f5-a93c-16e0062c1400		\N	a3e076f3-5493-4101-bf28-12c477a49ca2	2023-07-27 07:28:40
7a7d2a67-fbdf-43f2-9f63-5d387e84d0d7	[CLI] ℹ Versions:	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
0ffc8323-7750-4da7-9bff-b1beda73307d	         ▸ node.js                   18.12.0	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
d420bb10-4833-4869-8172-5b1a32831c9c	         ▸ cli                       0.0.35	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
c51cc630-8277-4ad5-9dbb-17b8be17da20	         ▸ runtime                   0.0.21	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
669d4490-e8ba-471b-bafe-1c8a672a7996	         ▸ compiler                  0.0.29	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
7fd4c505-4155-4125-ab10-ba71d3c1530d	         ▸ @openfn/language-dhis2    4.0.2	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
9585d673-f20c-41df-ab84-32944e9cf404	[CLI] ✔ Loaded state from /tmp/state-1690447980-7-wet965.json	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
0b977741-4499-4fb2-a395-62b42f4730f7	[CLI] ✔ Compiled job from /tmp/expression-1690447980-7-wsl5qg.js	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
7814e17e-cda1-4469-8b88-88e8d414222c	[JOB] ℹ Positive	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
5a9fa28b-6816-4c63-956d-dc8a4b87a481	[JOB] ℹ {	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
17b2274b-5f9f-4006-a55a-3b5706cff6a4	  "resourceType": "Observation",	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
fd43f60b-efd6-4ff5-a62b-196ce1f5ed78	  "status": "final",	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
15e98d25-ab83-43c8-8842-232a8fe371c7	  "code": {	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
9b6613ac-6205-4d55-ae4a-0989f004030e	    "coding": [	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
5c1c13ee-a714-4d3d-8ca0-26b765ad6ff0	      {	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
7613c538-79c7-4d5a-b463-fa79abdb6eac	        "system": "http://loinc.org",	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
0a1303c1-b913-4a19-8033-859d12afd9f2	        "code": "38372-9",	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
0e02f327-a387-4802-a2f9-725f26eb8cb3	        "display": "HIV-1 and HIV-2 Ab SerPl Ql"	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
ed665c08-34aa-4a3a-a5e8-492723a5ab83	      }	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
aba43017-fbca-455e-94a4-267a01efd22e	    ],	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
e4c9d2d1-5b84-4fd1-8010-592f1801feab	    "text": "HIV Test Result"	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
087fda3a-50fb-429b-83ac-d592706de066	  },	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
190f10c2-f6e6-4820-bfa0-49bd51f8730a	  "subject": {	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
1943b4c3-92b4-4014-ad96-49b29254dde1	    "reference": "Patient/example"	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
a2c6c5ad-c1a7-4ae6-a99a-c9214eba78e8	  },	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
520e7994-3175-480f-9478-442ed4ad7c9f	  "valueCodeableConcept": {	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
27f5bce5-4cc2-4f92-99d7-ae011b55b974	    "coding": [	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
6aa8ffc0-f045-4178-9c7b-6e91ed06c20a	      {	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
2857f90b-5508-4bc7-8b66-1c0479de527e	        "system": "http://snomed.info/sct",	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
570805dd-51f3-47af-9c4c-0574e9fd699c	        "code": "165889005",	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
201e0592-23c6-421c-8ff4-1f76b82cf1a2	        "display": "Positive"	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
7e09e15f-60e8-4624-bf54-c75cbf5d84a0	      }	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
655977bf-05be-4086-acb8-ad2a345131d4	    ]	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
5f0c9faa-91ce-444f-9a76-27de6e65dd8c	  }	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
53a922a6-c57f-43e5-995f-e7e8e837fbd0	}	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
af25801f-3646-46c8-b29b-65ba9f7ff911		\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
0cd2c7fe-8b59-493e-92bd-a1ddb471c65b	[CLI] ✔ Writing output to /tmp/output-1690447980-7-1dzc11y.json	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
44dbd8f0-60ce-413f-b4ab-dc5a6eabbee9	[CLI] ✔ Done in 174ms! ✨	\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
09d411f0-3022-41e7-b4c9-5880f770daaa		\N	b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	2023-07-27 08:53:02
4b8a5cf1-1500-48b3-b339-918a38b97028	[CLI] ℹ Versions:	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
1b0cef5d-8194-4087-a247-7fe228f72937	         ▸ node.js                   18.12.0	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
f6dc98d1-85f8-469d-aa06-4a533cd4d4d6	         ▸ cli                       0.0.35	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
836e044c-a12c-4aea-a282-1b0078f504ab	         ▸ runtime                   0.0.21	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
cd20ea18-72ff-423d-bf46-e92b197bac24	         ▸ compiler                  0.0.29	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
fd86b954-f8bf-43dd-abcb-19d510f31d47	         ▸ @openfn/language-dhis2    4.0.2	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
4eeb07b7-3336-4e19-82f7-f3b5f59ef340	[CLI] ✔ Loaded state from /tmp/state-1690443021-7-1rbii6o.json	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
7eda5f61-5e78-4fd0-86e0-bed39924256c	[CLI] ✔ Compiled job from /tmp/expression-1690443021-7-op7eg2.js	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
a3e95416-d259-4361-933c-5db20435f324	[JOB] ℹ {	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
d0f058cc-6c2c-4b10-947c-820be3ffd7f0	    "dataElementId": "katOVrpL1eJ",	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
4ec50a87-d759-453b-9565-63c3ffb14b2b	    "organizationUnitId": "BnVfkK2iFFH",	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
53b8328a-2883-431f-8183-f47b45aa4599	    "juneValue": 453}	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
0b7a0114-bc4d-4f09-b43e-447395d271c5	[CLI] ✔ Writing output to /tmp/output-1690443021-7-13np1bt.json	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
f06c3c3c-6a9d-412a-bff9-4aa384d5acf0	[CLI] ✔ Done in 170ms! ✨	\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
c5fa0831-4774-42f8-ac35-7c3e422e298b		\N	07296471-5dd5-4c18-9a94-5faaf9694baa	2023-07-27 07:30:23
9bcd675e-65ac-4a02-aa49-527c923aee73	         ▸ cli                       0.0.35	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
ca2c6e9f-6a09-4592-9a21-3de75b8b9ea3	         ▸ runtime                   0.0.21	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
951dd31d-6059-4d23-968e-3bcc667a4420	         ▸ compiler                  0.0.29	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
cbf6317a-1a12-4ab0-adbb-d5aaee54ee3d	         ▸ @openfn/language-dhis2    4.0.2	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
8d72ce22-6582-4340-ac15-90783cfb97b4	[CLI] ✔ Loaded state from /tmp/state-1690443068-7-1xsqw0f.json	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
e8e0ff06-dfe5-4273-b1ec-0df8880f41da	[CLI] ✔ Compiled job from /tmp/expression-1690443068-7-exu1fh.js	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
abab5ff1-50ad-4118-bb0e-9e4b9b7a90ff	[JOB] ℹ {	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
c076b023-d98f-42ad-bba5-8ebca4af2137	    "dataElementId": "katOVrpL1eJ",	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
ab140df5-8ab3-40d2-9371-caa0dbeafe6a	    "organizationUnitId": "BnVfkK2iFFH",	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
222b8d48-3dcc-4814-9a31-9b864184514c	    "juneValue": 453	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
f49b3fb4-f9de-4951-b71e-e981fd9a681b	}	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
38e5ea2d-4ca6-4cfb-940e-f53dbeae55d1	[CLI] ✔ Writing output to /tmp/output-1690443068-7-1qsdted.json	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
4f10600d-c5a1-41cd-bcff-bbb14347b66d	[CLI] ✔ Done in 170ms! ✨	\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
a2a7d56d-7cfb-423f-b0dc-8d78094ce434		\N	bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	2023-07-27 07:31:09
16bc38fa-c105-4d47-b91a-2442fb65c036	         ▸ node.js                   18.12.0	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
048c8f0c-0c62-4e07-9708-80d2113e60fc	         ▸ cli                       0.0.35	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
f4f0fb8b-d04e-4ba7-9618-7515996de530	         ▸ runtime                   0.0.21	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
85e49700-ac8e-4048-bcb1-b8dbace7fc46	         ▸ compiler                  0.0.29	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
6c571771-6619-4d88-a5df-fb97ba5cd293	         ▸ @openfn/language-dhis2    4.0.2	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
2597530e-8fde-41a4-b5fc-2f24a7b01fa4	[CLI] ✔ Loaded state from /tmp/state-1690443229-7-gu17u4.json	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
06fe9a5d-778b-488a-81e3-224f363a515f	[CLI] ✔ Compiled job from /tmp/expression-1690443229-7-jnvwau.js	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
a930a80d-3bbf-4979-bb55-2c494bf7a706	vm:module(0):3	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
60c442c2-6a45-474f-95af-fb369951287a	console.log(test);	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
f3dbdd3f-17d7-4240-bba2-8f8d1daa0b66	            ^	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
cd01f839-f3b4-481c-b13e-dcd7027c1e78		\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
1488ffa1-1ee8-45f0-803d-5d70182a68de	ReferenceError: test is not defined	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
54c4ec1b-d1a7-4861-ab97-49a29992e8a0	    at vm:module(0):3:13	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
6c3a21c3-64bb-4c3b-9092-79bee93c4b1c	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
bb846da9-e325-4711-833b-8965b414032c	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
6d7d595a-d0ed-4359-884d-e8bdc26da5e1	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
c241e033-4757-4569-a67b-e118f3f55de5	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
b9fe99e7-04e2-469d-9086-ac10eaf80c56		\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
6c49ca74-0d13-4b54-a913-2e771f406b1c	Node.js v18.12.0	\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
6914243a-6977-4fd3-ae40-53943aba2ce5		\N	6dca7fdc-ccda-48ee-9f0a-a27c411d6367	2023-07-27 07:33:50
2e10187b-95a9-45a5-885f-4a75f10b03c4	[CLI] ℹ Versions:	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
a71aaf25-3e10-4355-82f3-dda2e4e82773	         ▸ node.js                   18.12.0	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
5b28a90a-50fd-4a4e-9e53-bd7438ebaa1c	         ▸ cli                       0.0.35	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
316c1f29-ed1b-4093-b374-dd34835d4ca1	         ▸ runtime                   0.0.21	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
0edb3c18-f6ea-4392-aa88-4d3d26426728	         ▸ compiler                  0.0.29	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
a517aef9-d1ba-4e4d-be3d-5e74595bbf0d	         ▸ @openfn/language-dhis2    4.0.2	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
66303230-6746-4748-8552-13f6ca060f59	[CLI] ✔ Loaded state from /tmp/state-1690443259-7-zwd5cj.json	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
a658f1ac-8943-4062-9579-43a56c4197dc	[CLI] ✔ Compiled job from /tmp/expression-1690443259-7-17x0xug.js	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
c9a75a73-8983-4503-89e7-a994e5f673fd	[JOB] ℹ {	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
54f2dcd3-a093-4353-aba2-9ed2c6be01a7	    "dataElementId": "katOVrpL1eJ",	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
5dcccd83-214a-4d20-82a2-5256d25f2c2e	    "organizationUnitId": "BnVfkK2iFFH",	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
80ca770c-e200-4a43-8caa-0bbeb6c8e488	    "juneValue": 453	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
77cd2e54-c070-4d92-be31-e5d8f38c3347	}	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
e4bddfe1-dfbf-4a1a-a792-ed840161bd34	[JOB] ℹ undefined	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
4ccdfe6c-9c14-4a14-8763-fc55a185f3e4	[JOB] ℹ undefined	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
5cce24d6-a956-400d-9f7f-f5f1f14fae2e	[JOB] ℹ undefined	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
0bee4a1c-581e-4bd6-8ec4-597a70570a58	[CLI] ✔ Writing output to /tmp/output-1690443259-7-iam04d.json	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
ebaf6861-a0ff-4613-9af0-6b691c0301e1	[CLI] ✔ Done in 180ms! ✨	\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
25863d9d-a84d-49ae-b48c-ee010028cbc4		\N	c75d4615-b0e4-459f-8e93-26dd3dd9108f	2023-07-27 07:34:20
f3a72607-a4cf-44f3-8fa4-1ae9bb386ac3	[CLI] ℹ Versions:	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
79c62b40-b567-4155-9c4a-07129b22b1f5	         ▸ node.js                   18.12.0	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
f619a214-9f01-497a-9a1b-5a5ea9fe83d9	         ▸ cli                       0.0.35	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
582860a2-f466-4e0a-861c-10cb0c4bdddf	         ▸ runtime                   0.0.21	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
c1425a7c-569b-42b1-ac5e-e1f7db7f1e6b	         ▸ compiler                  0.0.29	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
a0a40a50-c6c7-4dab-9ef0-f1620a2b3c24	         ▸ @openfn/language-dhis2    4.0.2	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
6ce9982d-81cd-4a76-a190-7910bae5bdd4	[CLI] ✔ Loaded state from /tmp/state-1690443501-7-jcdq5n.json	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
d6dbfa5c-2e8b-4987-a6d3-dc73a7f87998	[CLI] ✔ Compiled job from /tmp/expression-1690443501-7-1lsdtit.js	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
4072f7f0-8765-4f0a-96ad-2cab29d19bb9	[JOB] ℹ {	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
0591e65e-4db3-4057-adcc-11eb67f9db14	    "dataElementId": "katOVrpL1eJ",	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
6b184a20-8efb-496d-8c69-fc9c943575dd	    "organizationUnitId": "BnVfkK2iFFH",	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
19743f57-803c-4fce-b9ea-6b2c6c4aa682	    "juneValue": 453	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
b65997f2-e417-47af-9c8d-fcbaeeb8c3fd	}	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
76fb8d1d-5eaf-49ee-8b7b-217665bd945f	[JOB] ℹ katOVrpL1eJ	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
19d8644a-d541-4b39-b337-b8dfa8326c08	vm:module(0):10	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
d114e9e9-48d6-444a-9fa8-1d4614c32af3	console.log(organizationUnitId);	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
9497c138-60c5-41d4-b625-100c35b35991	            ^	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
264b5650-e122-4289-82fb-795027ed499c		\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
5050ae6a-578e-458e-84b9-5baa15bd794a	ReferenceError: organizationUnitId is not defined	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
69255cdf-2966-49bb-a23d-862e9f609829	    at vm:module(0):10:13	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
df55bfff-6974-4cd2-a55d-ab02a5ac8ddc	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
1043e032-6ce9-465b-9315-3af4fa8ac18e	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
ee0cd41c-7338-430c-b0cc-6d00e16df01f	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
f2cac867-041c-4ace-a195-3c4b68218b8d	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
22217d96-54e5-46ab-a769-87aef904d732		\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
0ea89972-749d-4676-a388-9436de0a5fdd	Node.js v18.12.0	\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
31f6d369-1708-408b-8abc-4de9daecaa39		\N	0635b4ce-5126-444e-8e67-204e0575e655	2023-07-27 07:38:22
0c853679-af90-4546-8b2c-d0e377974bca	[CLI] ℹ Versions:	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
287a68dd-1181-4f30-a84e-57155603cb57	         ▸ node.js                   18.12.0	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
7ba26bb8-5529-41a9-a632-a9ef40ac7d0d	         ▸ cli                       0.0.35	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
d3d6dc85-245e-48c0-8ce4-731c6524869e	         ▸ runtime                   0.0.21	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
5bf7b268-f47e-41f2-8ab6-38616f069dfe	         ▸ compiler                  0.0.29	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
3785ea45-ff8d-4e33-a5d0-9576a4c78a7f	         ▸ @openfn/language-dhis2    4.0.2	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
390edb42-3197-4bd5-94e3-e6647d9fa802	[CLI] ✔ Loaded state from /tmp/state-1690443531-7-o3m8md.json	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
24c00b7e-b3aa-4b8a-8622-1f027e742aa8	[CLI] ✔ Compiled job from /tmp/expression-1690443531-7-a3w9e5.js	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
89ed359c-8268-4abf-b281-a1422f8622be	[JOB] ℹ {	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
c0ea3981-edaa-4a5c-8212-3f86cb05498c	    "dataElementId": "katOVrpL1eJ",	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
cd9ecb17-4296-4911-b371-3cc1272c1e29	    "organizationUnitId": "BnVfkK2iFFH",	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
debc2fe0-bf59-4d80-bea4-6699d7e7c3b1	    "juneValue": 453	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
d0f59c55-ecf6-4745-9ded-91636948250c	}	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
5b2f582d-6017-4715-81c5-26d8ff4f30cc	[JOB] ℹ katOVrpL1eJ	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
a79baa99-30e2-4917-a06d-43b506d6c72b	[CLI] ✔ Writing output to /tmp/output-1690443531-7-1ipbf9n.json	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
4fa9e708-49c6-4a7f-b7e0-1006b59aa87a	[CLI] ✔ Done in 179ms! ✨	\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
5e21596d-f38d-475e-8266-2645360f6d91		\N	e7dd3111-d532-4664-a61a-2f37f5c5bac5	2023-07-27 07:38:52
aae79985-9b5a-4f81-988b-71496bd4dce7	[CLI] ℹ Versions:	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
bfb72969-0ca2-482e-a379-fbd12a5b36de	         ▸ node.js                   18.12.0	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
47a231b8-0ddd-49e2-85b2-225b1772929a	         ▸ cli                       0.0.35	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
70364df6-3d93-4949-ae9a-865e8cb6c544	         ▸ runtime                   0.0.21	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
0fc53429-4585-4f26-88fb-9d07d5005760	         ▸ compiler                  0.0.29	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
185716e5-96f8-4f63-b8a2-f0adb434b00f	         ▸ @openfn/language-dhis2    4.0.2	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
8f273df1-5737-4ced-8e7a-928ed9048f88	[CLI] ✔ Loaded state from /tmp/state-1690444023-7-pp4kp3.json	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
74311737-82a0-4cca-8a2a-4397ed1ee5d2	[CLI] ✔ Compiled job from /tmp/expression-1690444023-7-mvts16.js	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
cd4d174c-f000-4325-b5e4-917883c260c5	[JOB] ℹ {	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
7acc767e-48b4-40f7-86d6-79ba6b82d97c	    "dataElementId": "katOVrpL1eJ",	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
c8242b22-8dc8-4ad5-8b7d-6360bb3761c3	    "organizationUnitId": "BnVfkK2iFFH",	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
cedfc2ac-cc86-408b-a6cf-30dbdd6792fc	    "juneValue": 453	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
013c8629-2328-40a7-b40e-faa638488156	}	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
07e91464-5c86-4e7f-80b4-4eae4b43a354	[JOB] ℹ katOVrpL1eJ	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
c485cc1e-c65f-431d-912a-a399f24e5e0a	[JOB] ℹ BnVfkK2iFFH	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
7f0edf2d-9db7-4567-8494-9cff931581f9	[JOB] ℹ 453	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
4ad74481-afcf-46c4-9b6f-185266e80440	[CLI] ✔ Writing output to /tmp/output-1690444023-7-izw4qk.json	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
291ce6c4-fa95-4a09-b96c-da360705c51f	[CLI] ✔ Done in 183ms! ✨	\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
7832d656-4bb5-46c0-9c46-987c62d7d465		\N	f41251f7-3dc4-4b21-b014-54d24e6dc14d	2023-07-27 07:47:05
d2ff0c5f-7a1a-4f08-be14-022e3ebc734a	[CLI] ℹ Versions:	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
ec795a18-c0f3-4f66-ae4f-c6acebfc9c48	         ▸ node.js                   18.12.0	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
6ecc2c50-f005-4f8a-a4c3-e3b62a02086f	         ▸ cli                       0.0.35	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
f506cf75-c19d-4639-a87f-83b4978e2eb0	         ▸ runtime                   0.0.21	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
99a7d14c-1196-4142-b965-9d84e2453cd4	         ▸ compiler                  0.0.29	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
90f07f22-c57c-4a8f-a300-2d8646b90f76	         ▸ @openfn/language-dhis2    4.0.2	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
3307c49d-7d8f-4b6f-a67b-df0f4bd79105	[CLI] ✔ Loaded state from /tmp/state-1690444095-7-1axqqk3.json	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
464fc68e-2d0d-4437-a5e0-8848800ddcb1	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
8c24286d-8462-4606-a243-c035db179f8a	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
34cd262b-d3dc-4a47-a943-a35ab1115c38	[CLI] ✔ Compiled job from /tmp/expression-1690444095-7-1lx3x1j.js	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
7ab2c426-810a-40a6-ae28-d9be528ded7e	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
4543f8f7-0768-43b4-8923-fb92121b0ee0	[JOB] ℹ {	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
6c697556-4b38-4a5c-8ce3-bf78eb29379d	    "dataElementId": "katOVrpL1eJ",	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
6a795c07-38fd-407e-bfcd-814bf94b6ef7	    "organizationUnitId": "BnVfkK2iFFH",	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
d5345d79-6a78-4636-b806-fc6d406cce8c	    "juneValue": 400	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
13f5c259-e45a-4127-b5bd-41c7dc133c0b	}	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
9df1da64-5294-4b63-aa6c-0bb1444137a4	[JOB] ℹ katOVrpL1eJ	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
ac146710-6513-4663-9c52-4e82c1d83e96	[JOB] ℹ BnVfkK2iFFH	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
a3f10d97-c1ec-4bac-ba98-e70a62704f70	[JOB] ℹ 400	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
0147c6d9-f823-431b-b0ad-528249c6aab1	vm:module(0):20	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
cd1676fd-9973-44a7-9a3b-578d121fdc51	      period: junePeriodId,	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
c166a45f-315d-450c-95e4-9762505d72fd	              ^	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
986ca25c-73c0-42ce-8850-2039c289d6e5		\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
5c93a972-e3e5-4e22-af25-100312fc6518	ReferenceError: junePeriodId is not defined	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
f2b87245-51dd-41e9-9ae0-5b806d1491e3	    at vm:module(0):20:15	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
18a29f02-601f-4b37-8265-cb864c41aca2	    at SourceTextModule.evaluate (node:internal/vm/module:226:23)	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
68e1c709-4549-47d8-9fcb-34ba42225ab0	    at module_loader_default (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:283:16)	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
60512183-9f2c-4f27-8978-239980fe2b2a	    at async prepareJob (file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:378:21)	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
cf117a73-5930-40ca-a396-21aefa1bf896	    at async file:///app/priv/openfn/lib/node_modules/@openfn/cli/node_modules/@openfn/runtime/dist/index.js:303:37	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
bb3957d6-e2ea-4581-ae50-63bc270f03c0		\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
bf267d22-9d3e-41eb-8269-4dfbfa65c626	Node.js v18.12.0	\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
0f694a30-9f89-4a2b-b4bf-22d727bbc264		\N	0f4fbff2-8435-479f-859c-c5b3a7fbd109	2023-07-27 07:48:17
0625bea9-6014-4e77-bf94-b6fc2fba0a6b	[CLI] ℹ Versions:	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
8910e5a9-19a8-4ec4-b127-ff22e4bd80cf	         ▸ node.js                   18.12.0	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
c2e364db-7acf-422c-9931-17fb19fdee4c	         ▸ cli                       0.0.35	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
e8eb0292-9f52-4abe-88af-ca40e469acb3	         ▸ runtime                   0.0.21	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
864cb545-3593-4a29-b4b8-7219878d4003	         ▸ compiler                  0.0.29	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
f58942fd-22e2-4716-9c42-6cbac7514ed0	         ▸ @openfn/language-dhis2    4.0.2	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
f3620cf5-8715-4e4b-b331-314181a3054b	[CLI] ✔ Loaded state from /tmp/state-1690444149-7-imdeuv.json	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
d6fddbb6-1ab6-41ca-8fd8-7c351f3763d6	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
ba512ee6-e530-47d0-81c2-9288abf4f167	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
3a198db9-c7a5-4f62-8324-78497e311847	[CLI] ✔ Compiled job from /tmp/expression-1690444149-7-hkik6f.js	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
aabd4857-012f-484c-8264-fe79dd6a9457	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
8f10f5b9-9a8e-499d-b4b7-a831c105b2e0	[JOB] ℹ {	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
a88398ec-141f-4147-8cbe-388911be9cbf	    "dataElementId": "katOVrpL1eJ",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
4b9e80f2-8313-48aa-ba7c-bbba2f275e25	    "organizationUnitId": "BnVfkK2iFFH",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
d48c9245-f2af-4fe2-9893-d8e7f4fc4252	    "juneValue": 400	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
1354cc66-5b34-49e6-b61d-dac5a888977e	}	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
f64c6495-35b3-4d16-9165-1b7b1d15b3d0	[JOB] ℹ katOVrpL1eJ	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
107d6a14-3bce-4cd3-bf18-5ad9caa2ad7f	[JOB] ℹ BnVfkK2iFFH	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
85dd5137-1667-452c-98ea-92ffc3f2acf0	[JOB] ℹ 400	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
b3b83e39-24df-4944-a914-11d08b6940ed	Preparing create operation...	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
0f654cd0-3ee7-4ad6-a5ba-7e7ff0232f0d	Using latest available version of the DHIS2 api on this server.	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
5bfe70b3-b064-4784-b94b-76897ec99783	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
b0dae27d-925a-4558-b9fe-66c8712488f8	✓ Success at Thu Jul 27 2023 07:49:10 GMT+0000 (Coordinated Universal Time):	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
0cc79f61-d95a-4e44-be6e-169440bd78e3	∟ Created dataValueSets with response {	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
1438dcf3-b1f6-4348-9a8c-ab8e51a4ad61	  "httpStatus": "OK",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
dd9ac75b-5b15-490e-bed0-9032748ccaea	  "httpStatusCode": 200,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
9409b2f4-611d-4a82-9d67-ce67b793246f	  "status": "OK",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
cf5368b3-fdb7-4b03-9ed0-1af59f4c733d	  "message": "Import was successful.",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
9405e098-4717-460c-ad95-0813f9c6101b	  "response": {	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
581d9287-cf26-41e1-9d31-4ae10b84aadf	    "responseType": "ImportSummary",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
f9567891-611f-42a3-bc0b-be5afb37c854	    "status": "SUCCESS",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
be77d51b-f1cb-4452-a72f-8b23cc4182ce	    "importOptions": {	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
dcde691c-447e-428e-9280-3b78d1e6e52e	      "idSchemes": {},	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
940aa928-9773-40eb-83f5-1d4858e10d01	      "dryRun": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
d99b939c-7f91-486f-baa0-b43cf86f0ec6	      "async": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
09ad325b-bd84-47a9-a71a-a41ae6b648ce	      "importStrategy": "CREATE_AND_UPDATE",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
3f8e0f53-c07e-4a5c-be53-81d539d3dbfe	      "mergeMode": "REPLACE",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
4a9baac2-d9a4-4e68-9710-d4f3de047bac	      "reportMode": "FULL",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
2ecaeaa7-cf96-473d-8d93-99f94e95c099	      "skipExistingCheck": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
c32d553d-109d-43f3-8a4a-3a8f8d34b34d	      "sharing": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
4455a814-059b-495a-b812-0160754769fe	      "skipNotifications": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
3ff79bf8-ce44-4dbc-b213-1cafd4732194	      "skipAudit": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
1f97157e-2c9a-410f-975a-5a0806ab3b44	      "datasetAllowsPeriods": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
1937e4ad-2c3a-4fc6-9d66-281ae62a440c	      "strictPeriods": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
20900f1e-d6de-4606-b40f-6eb25eff83a8	      "strictDataElements": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
ccbde457-479d-4bc7-b629-8435d45bd93e	      "strictCategoryOptionCombos": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
07554589-cbab-41b4-8078-794972a976d8	      "strictAttributeOptionCombos": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
196260cc-fc43-4c3c-a322-39b4ec622273	      "strictOrganisationUnits": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
b27af08e-ad99-43af-808b-fdc3f3a1effd	      "requireCategoryOptionCombo": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
14d9cac4-1b70-4082-94e6-c09e12037693	      "requireAttributeOptionCombo": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
5ee29fe2-d9c7-4d77-b360-d811f45aa75f	      "skipPatternValidation": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
4c91a1dd-5387-4320-8be4-7b454a74cf51	      "ignoreEmptyCollection": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
cd0f9a8d-a37b-453f-813f-fefa65944b37	      "force": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
3b2319b8-a82f-431c-a301-b9aca342f9b9	      "firstRowIsHeader": true,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
d1cc7737-3dba-4e52-a28e-55a468912632	      "skipLastUpdated": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
c48e5dde-5f51-4ef1-8c05-a45666458756	      "mergeDataValues": false,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
316c6d9f-ee2a-4875-bedd-06614c6bb568	      "skipCache": false	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
87f795cc-a988-4c72-af48-2e5d4cc5f5d2	    },	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
e9ae3a4a-d713-4f53-9b8e-87552e087f03	    "description": "Import process completed successfully",	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
8bc7ce3b-f631-41b2-9b2b-1ccf09071110	    "importCount": {	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
1116b0db-b3f4-48d0-a418-c8b08d766a71	      "imported": 0,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
91f394f6-8d99-4b04-9d23-8f2184359c31	      "updated": 1,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
fec7fd05-9988-45d9-959b-56bff89201a1	      "ignored": 0,	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
3862f8fc-ee1b-48ed-b643-640054c2a012	      "deleted": 0	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
a1e31fa6-18b0-4df1-b017-9a1c2ac79544	    },	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
2a4292f4-f451-4a9f-b9bd-c929b2d81acf	    "conflicts": [],	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
77ea6c0f-113f-4ebf-952d-aa87536065a9	    "dataSetComplete": "false"	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
8a99807c-3983-4b85-a2f6-1375f967e312	  }	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
64a3428b-f332-48cf-8a49-bd5bf98f4c84	}	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
3101a3ef-3dea-47a8-a58f-b9b8de69140f	[R/T] ✔ Operation 1 complete in 168ms	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
9607eeed-6117-4b16-9990-ce6bb9c9fd7c	[CLI] ✔ Writing output to /tmp/output-1690444149-7-11qmfl8.json	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
74121ea7-b6e0-4a57-be93-b5a63de00c8d	[CLI] ✔ Done in 637ms! ✨	\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
fadba16e-a702-4bfb-9907-4ebff7dbbce8		\N	063e85d3-c988-4b58-8655-dcd6fd654058	2023-07-27 07:49:11
3b462b1e-ccd1-4feb-a202-945eda0fdfcd	[CLI] ℹ Versions:	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
b6d41e20-5f92-40d3-b97b-5300a92de66f	         ▸ node.js                   18.12.0	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
695c1012-6330-4e52-a11f-6f661ffddbe8	         ▸ cli                       0.0.35	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
54203a1c-c4f9-475d-94cc-f4082d3946ad	         ▸ runtime                   0.0.21	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
d1e085a9-d28d-4b0a-af4e-c8bc3ac2f7e5	         ▸ compiler                  0.0.29	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
8ea42e59-daea-4992-be59-ad4ca0a76df8	         ▸ @openfn/language-dhis2    4.0.2	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
2021fdb2-9486-4000-ab97-798aec21f5a2	[CLI] ✔ Loaded state from /tmp/state-1690444295-7-1n5q56q.json	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
881a4633-4c0f-4d0d-b82a-cad2cf4f9ef4	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
22e03f06-9967-433c-8a5d-0fc0785fc94e	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
0c8aa88b-9ba9-45d6-b034-fc722929a143	[CLI] ✔ Compiled job from /tmp/expression-1690444295-7-8xwipf.js	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
47c3f2c2-d25b-467d-b333-76483d2439b9	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
8b131b0b-59af-4ac0-b52d-dca7b29e5261	Preparing create operation...	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
5ca6727f-e68a-4a4f-9df0-6a646d51e64d	Using latest available version of the DHIS2 api on this server.	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
dd2196d7-ac3a-45f3-8c03-eca660aeaf9f	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
113b29ec-02eb-426d-93d4-6dd970d0ac40	✓ Success at Thu Jul 27 2023 07:51:36 GMT+0000 (Coordinated Universal Time):	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
ef020bb7-3ff1-441d-b06f-778b61c8f3eb	∟ Created dataValueSets with response {	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
f1bde3c7-4573-429f-8e62-2dc0da53dabf	  "httpStatus": "OK",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
c934499d-fe9c-4bdb-a842-342fee62568a	  "httpStatusCode": 200,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
3d45f665-1106-4740-bde2-590e83d8f89b	  "status": "OK",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
6de12790-699d-49da-b6d8-4a8c1735b937	  "message": "Import was successful.",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
e48b84a3-6902-409e-9d3b-705137552650	  "response": {	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
50836d8c-6ab2-4aee-abae-ba374fa83a9e	    "responseType": "ImportSummary",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
aa12f832-1ab6-4055-a0b6-e38dcac549e9	    "status": "SUCCESS",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
0cc52ad9-d390-4080-8d0d-dd0b82b568f8	    "importOptions": {	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
217d20fe-ae89-486e-86d5-75ef6912069f	      "idSchemes": {},	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
b90585f7-432d-4661-9e0a-668dfddd770d	      "dryRun": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
e8b21418-71ee-4bf7-b169-fcdca17f2cab	      "async": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
1b0904bf-8bb1-4461-b034-54f002516203	      "importStrategy": "CREATE_AND_UPDATE",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
0c0823d5-f569-4372-b3ca-23bc71d22881	      "mergeMode": "REPLACE",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
000520ad-0261-47cd-aefb-e1b6f1fa0ae1	      "reportMode": "FULL",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
1772c639-d460-4faf-9ceb-1e18647b6d1e	      "skipExistingCheck": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
fbb4acde-8e2f-470d-8f5b-8fcb1e3bfa37	      "sharing": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
c1ad269c-854c-4e1e-a88e-fdeeb902e580	      "skipNotifications": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
883673e6-b817-48f2-beda-28f96776c34c	      "skipAudit": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
94a132d5-d3bb-48a3-b4b1-96d9c871f8f3	      "datasetAllowsPeriods": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
61aab94d-94b7-4414-b83d-6ed23b19c16c	      "strictPeriods": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
eb450775-ab5e-4226-b0f3-80f75b07864c	      "strictDataElements": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
1cc02391-caea-4923-adcb-42e76c003c22	      "strictCategoryOptionCombos": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
8e441ddf-a9f8-4b84-a3b6-f8c0b2816ad5	      "strictAttributeOptionCombos": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
be215af6-75d5-4bf3-a505-2f5589550c1d	      "strictOrganisationUnits": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
8f8c51a4-a30f-40ff-8878-f952119fc04d	      "requireCategoryOptionCombo": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
bcb98382-d888-4f79-a1d3-b941010da137	      "requireAttributeOptionCombo": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
2f87d056-8ef8-4c78-b0de-6cadc6022543	      "skipPatternValidation": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
d95331da-2712-4f49-96aa-af54a028c085	      "ignoreEmptyCollection": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
7d9a5800-6b54-4dfa-a648-d121aa8ad2e0	      "force": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
be90056e-1899-4917-9a98-845bbdc94bc2	      "firstRowIsHeader": true,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
b4e0ea65-db90-4ca9-ac17-ee7eb279e507	      "skipLastUpdated": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
724f0b27-836e-4b58-9630-0f2b87855090	      "mergeDataValues": false,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
d7426029-5d7b-463d-8569-1c7e3c2fb3cb	      "skipCache": false	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
33527f31-b687-4cb8-b554-5e574d6f795f	    },	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
7bcb0c54-ed86-4d7f-8dfd-360e39c21f40	    "description": "Import process completed successfully",	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
7bc10185-d190-428e-a75c-d1bb256aba40	    "importCount": {	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
fe8c3ee6-cbdd-4f93-8355-216969de1d8b	      "imported": 0,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
ec62bf07-4908-4813-b907-af808df1324f	      "updated": 1,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
44216702-be3f-44d6-b680-84237320b05d	      "ignored": 0,	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
3a672084-c596-41d4-b6eb-268b54520dc9	      "deleted": 0	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
87657bc8-f640-419a-b89b-a7418b9783f3	    },	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
ff337c2b-db4b-4ba6-b62c-83bf7464c936	    "conflicts": [],	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
990141b7-0ace-4e76-8519-45a2a2b73506	    "dataSetComplete": "false"	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
943e68c3-2b35-45a2-b39d-1d7c71399a02	  }	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
b4c45464-5691-4512-a92c-753907a6ab12	}	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
fe082a2a-9a74-47d4-8385-d265e5da5642	[R/T] ✔ Operation 1 complete in 174ms	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
237b6644-5b3c-4c20-8cb1-565212b5931e	[CLI] ✔ Writing output to /tmp/output-1690444295-7-ynp1qt.json	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
9ced3968-fc63-48df-b292-fb607309c800	[CLI] ✔ Done in 605ms! ✨	\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
0b01fcba-8e9a-405c-8c85-a02afcc3e530		\N	6760597c-7723-4624-abf6-600f4c53e804	2023-07-27 07:51:37
7e8b2fd7-3b83-4fc8-8f3a-15e12baa6e00	[CLI] ℹ Versions:	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
b9c52a6b-3b2b-4fd2-be39-76354b45a70d	         ▸ node.js                   18.12.0	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
c9fae85c-ffa4-45b2-ba8c-9ac9f18d277c	         ▸ cli                       0.0.35	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
dc83cc61-fd9b-434b-b44c-bdc48fd72895	         ▸ runtime                   0.0.21	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
359bb763-c30f-4023-b818-dd59b1a4a24b	         ▸ compiler                  0.0.29	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
21a7a395-9227-4e91-b12a-23aab9129582	         ▸ @openfn/language-dhis2    4.0.2	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
a0fa3b95-6798-4f93-ad5e-6885d9400228	[CLI] ✔ Loaded state from /tmp/state-1690445283-7-c89y0v.json	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
e64e859b-e03d-481e-b453-80e63a9fb3ce	[CLI] ℹ Added import statement for @openfn/language-dhis2	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
d5a62506-a661-4bd9-a3af-4a441082a5e6	[CLI] ℹ Added export * statement for @openfn/language-dhis2	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
f7792e10-230c-4e55-9341-a707da1187d0	[CLI] ✔ Compiled job from /tmp/expression-1690445283-7-1lhg0i8.js	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
8a10f1f9-7f47-4263-9b6d-bc52b1cea672	[R/T] ℹ Resolved adaptor @openfn/language-dhis2 to version 4.0.2	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
ad17b8c2-d338-46c3-a9b5-1f90c53338c4	Preparing create operation...	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
726a3473-9e2c-4fe6-a197-731b456efcb4	Using latest available version of the DHIS2 api on this server.	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
c53222ff-195a-42ad-a54c-30fc8fb45f17	Sending post request to http://dashboard-visualiser-dhis2:8080/api/dataValueSets	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
2a91a3c9-b67e-4502-b20f-581dc494384b	{	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
1254a28a-e12d-428d-8acd-746789b24a86	  "httpStatus": "Conflict",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
9f319684-248e-4622-9dd1-546c17626d15	  "httpStatusCode": 409,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
45736e00-5187-4f16-9ed4-005561a3956a	  "status": "WARNING",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
f88e3976-78a8-43ed-a75e-26334879f1d2	  "message": "One more conflicts encountered, please check import summary.",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
bf5e07ab-ae3a-4d70-8e37-8ce32f243986	  "response": {	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
5e7bd3be-38b1-4678-91a8-57dfe369596d	    "responseType": "ImportSummary",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
dcf29952-1dfb-4304-a6a6-39262ceff865	    "status": "WARNING",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
70bafd6d-7c48-4ec4-a83f-068190fb142e	    "importOptions": {	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
d114aaed-ad88-4515-88e7-432f921bff66	      "idSchemes": {},	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
8dfb42bd-b730-41da-a822-97c4f4473ba5	      "dryRun": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
d54a961c-d102-4be2-ae63-2e88ed696da3	      "async": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
39ed716a-8006-4968-8ae4-4bffa84683d5	      "importStrategy": "CREATE_AND_UPDATE",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
c0885454-d5fd-4461-8fc3-4f2bee73e4cd	      "mergeMode": "REPLACE",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
0518da9a-9383-45be-9b0a-4100031219cf	      "reportMode": "FULL",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
8651d82e-8981-4797-996a-c571ba84ba3c	      "skipExistingCheck": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
0829437b-4cb2-4f8a-8df1-8f494cdd4d36	      "sharing": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
ce236e7b-281c-46da-9035-a5fbb3735ce2	      "skipNotifications": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
96e83dbb-c201-4d10-a865-aaa94187594f	      "skipAudit": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
461c42a9-4cf8-4b8a-b900-8b0cd28f028b	      "datasetAllowsPeriods": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
5e38c6e6-fc03-4f93-9075-2edd00e38d8e	      "strictPeriods": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
ed5d9925-8448-411b-b865-547a65de02cd	      "strictDataElements": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
94a89ff5-9309-4420-b734-d0ca313bedb0	      "strictCategoryOptionCombos": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
e45c4acc-8bf3-450b-85fb-4f9dedd96d61	      "strictAttributeOptionCombos": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
3ff5d587-cfa8-4df8-9b70-af9cc846a579	      "strictOrganisationUnits": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
fdf7f1f3-3327-4b2f-b9fb-f2185b8eaaa6	      "requireCategoryOptionCombo": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
3494fe8e-77b5-4d35-99e2-96f8ff01069d	      "requireAttributeOptionCombo": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
e9db2bc6-85e7-49ff-9318-0589d1ed5362	      "skipPatternValidation": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
37279fd6-635b-473b-93ee-6633878b7ff0	      "ignoreEmptyCollection": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
6ab33d0e-d8cb-40e9-a1bc-9a29003b2d56	      "force": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
910827a9-a09d-4415-b0d8-b32c60a60688	      "firstRowIsHeader": true,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
abb5cb42-7d84-400f-94c2-17ebf5fc2458	      "skipLastUpdated": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
ce999cdf-6354-4ae5-a84f-92db27a19124	      "mergeDataValues": false,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
349fbba2-a9c7-49d9-bc54-9adbe420b294	      "skipCache": false	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
bd9594e9-a22b-41b9-8719-18177da2a123	    },	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
e48e110e-a1d0-4140-b8c5-d80ab23e44b7	    "description": "Import process completed successfully",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
9c6c1865-f6dd-485b-82e4-1d110d1a1722	    "importCount": {	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
2df91be8-326e-4fe3-9b89-4a0e96e07ad9	      "imported": 0,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
b47cce81-572f-42e5-9e1d-c4fdbe4f7982	      "updated": 0,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
0b1290ff-49d8-4a82-b546-4492b75835b6	      "ignored": 1,	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
04281110-b12c-4d60-8a15-c57def1e95ef	      "deleted": 0	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
72061ed8-bedd-4197-a7ab-6b9be45b8349	    },	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
728d371c-318c-442a-8e32-57c9e4d2de81	    "conflicts": [	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
54d18007-4ef9-480c-b2ee-a43b458c4748	      {	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
d8710807-97d3-4adb-baa6-107db285f250	        "objects": {},	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
a552396a-5133-4907-bfad-c53e5b332a6c	        "value": "Data element not found or not accessible: `null`",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
76999690-f72b-4c21-a738-361bb7e2e51f	        "errorCode": "E7610",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
6633e3ae-ad29-4893-a36a-6d6b1bd00594	        "property": "dataElement",	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
56d366fc-316b-4eff-8ad2-64247ff2a846	        "indexes": [	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
c7e14df8-23b6-4781-b8e6-058d6a61b6e6	          0	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
8ae03fa9-8832-4f3c-a3e0-d363f18e7cc1	        ]	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
529fc89d-d4b1-4435-9377-e166e8dad960	      }	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
cb28ee06-22fe-42af-b507-c0778e46f320	    ],	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
c525fcf2-e01e-4a6f-a405-5ad49dc1794e	    "dataSetComplete": "false"	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
a8faa10f-b1c7-4e30-9cac-61224a8ba488	  }	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
b6b38686-3757-450c-90c1-36a6dd430991	}	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
b6844f8b-a3f8-4c37-ae7a-d2565defbbe2	✗ Error at Thu Jul 27 2023 08:08:04 GMT+0000 (Coordinated Universal Time):	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
83f23876-b553-402e-a9e6-7b74ddb50f23	∟ Request failed with status code 409	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
c382e3b6-7f63-425d-917f-40fa31be4295	[R/T] ✘ Error in runtime execution!	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
5101bbd7-2f0b-4e9a-b4ab-409c41531311	[R/T] ✘ [object Object]	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
6096c6b7-61bf-473d-95dd-4ec71387db4b	[CLI] ✘ Error: runtime exception	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
9cbc8ce1-6246-4e14-a82d-eaa623128fb9	[CLI] ✘ Took 608ms.	\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
d9ebdf41-2651-4121-97d2-304ffafc8a6e		\N	ce4fd870-2c2d-4c6a-81eb-0839adbef749	2023-07-27 08:08:05
1051c738-fba4-4f34-924c-63f60686090b	[CLI] ℹ Versions:	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
fe47c6cb-b516-49e1-b491-fa65addf19ed	         ▸ node.js                   18.12.0	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
153b8655-123d-4564-bc12-042eaf8070be	         ▸ cli                       0.0.35	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
8a43949e-e12f-4152-bfaf-e68a104858ab	         ▸ runtime                   0.0.21	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
9c1549bd-0254-4e34-a33c-f26c05a6720e	         ▸ compiler                  0.0.29	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
0934a8a6-4d1b-435c-a70d-de2d985ee438	         ▸ @openfn/language-dhis2    4.0.2	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
413eba34-1bbc-44a1-874c-69ec2c5cea3f	[CLI] ✔ Loaded state from /tmp/state-1690445542-7-ipydj9.json	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
1af89f88-aae1-47b2-ac69-89489d5eea92		\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
8846eaf1-61cb-41fe-8f56-82f4171393a2	[CLI] ✘ Command failed!	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
36057f95-d0ea-4776-a96d-57c32c4ef703	[CLI] ✘ SyntaxError: Unexpected token (5:43)	\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
09786b15-5bca-4101-8536-a662edcc3a1b		\N	feefa70b-b633-410c-8e70-ed26c19a6e3f	2023-07-27 08:12:24
b5f186f3-1681-4e7c-baa8-84bf48014065	[CLI] ℹ Versions:	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
698dfb97-9ed8-46d0-86f3-449ed02dc493	         ▸ node.js                   18.12.0	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
02fad30d-5d2f-4c9e-a8a8-968ac4e0fab4	         ▸ cli                       0.0.35	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
fa6cbabb-98b0-4e1d-8549-0bb6c30ab166	         ▸ runtime                   0.0.21	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
8bcedfff-eb8b-4421-b31f-a0daa7fca8e2	         ▸ compiler                  0.0.29	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
7086e683-f20a-4fbf-8d5d-78b9ac0eef2a	         ▸ @openfn/language-dhis2    4.0.2	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
aea86866-b203-4667-9ca4-66f727c2e82e	[CLI] ✔ Loaded state from /tmp/state-1690445685-7-uj4xtr.json	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
5babee86-b6a7-41ef-98c5-2f4d407842d7	[CLI] ✔ Compiled job from /tmp/expression-1690445685-7-1b9us9m.js	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
47f53eb3-a8d1-4534-aa0c-28f889425a4d	[JOB] ℹ {	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
095adaf7-3944-4f3e-a1a7-4bd8c2f41410	  "resourceType": "Patient",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
590d47d5-ba50-4cac-9d24-aa2528bd40ae	  "id": "example",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
1873e5fd-504d-4954-8575-ab1f1606618b	  "identifier": [	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
00109544-4719-4edc-bb04-c6ef838f56f4	    {	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
ed4b6bd7-a11e-4e01-bd64-d70f7e19bfbb	      "system": "http://example.com/patient-ids",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
095bfdc9-7bc7-486e-89b3-993eeaedda4e	      "value": "12345"	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
41b265ac-949e-4e87-9e40-064ec3e0af86	    }	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
73508076-1bd9-49c2-a917-9c845911af05	  ],	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
cfa107ae-6cc8-451d-b764-02913c92bd02	  "name": [	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
7fe42c1e-1021-42c0-a5c0-527bee849f35	    {	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
0637f59f-c419-450b-bc00-99409b4c9f0a	      "use": "official",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
0e944d94-a2ff-4e23-a1d2-dc3d3cfa051c	      "family": "Smith",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
ddb3ff73-d72a-47ca-8557-07e1d525a15a	      "given": ["John"]	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
81fd9a27-9379-440f-ab20-94d3cb3fae31	    }	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
fac705a6-d0b2-4966-92e3-971813e9e73a	  ],	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
43da343f-3772-4d33-b76c-e41daac0ce8f	  "gender": "male",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
e1a7f55a-69b7-4639-91bc-bd86a12e81b4	  "birthDate": "1980-01-15",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
10a2d916-4d74-41b6-8e0a-52cd691fd76a	  "address": [	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
acda77bf-dce9-458f-83f0-36c059941551	    {	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
6cee5edc-d3a1-4d29-98f3-c20af9f39f80	      "use": "home",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
195ff4e8-1024-475e-ac60-ccf1f0068c47	      "line": ["123 Main Street"],	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
6ac9499f-62bd-4c04-a0d8-0369e10473a3	      "city": "Anytown",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
bc7e8a31-46e2-4ad2-892d-5ecdad5aa0c4	      "state": "NY",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
4891483a-bc3b-47a9-b966-bded45aa9b8e	      "postalCode": "12345",	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
8b032db8-c6af-4b1a-9c61-502bd5aabc6d	      "country": "USA"	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
36712403-30e0-45cb-994a-bc0bc34b68fc	    }	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
43e7b8c1-36e9-4e2e-a163-0f5ba3b44f9c	  ]	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
c3809668-daf3-4cb9-9143-08bf4a2b9ef8	}	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
9a7f8324-a3e5-4555-baaa-b9fb92683885		\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
84338b1e-8313-4f76-b6f3-06a94e38b541	[CLI] ✔ Writing output to /tmp/output-1690445685-7-yiddiv.json	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
8513cd72-5f37-4dee-bae9-ff499d08fff1	[CLI] ✔ Done in 179ms! ✨	\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
5aa75471-2e01-44d4-9c72-a279c861d12f		\N	a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	2023-07-27 08:14:47
e56d197c-4167-4702-a95b-4c38da03438a	[CLI] ℹ Versions:	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
a95d2163-a4b6-4fc8-987b-c327950d1de9	         ▸ node.js                   18.12.0	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
163261ea-39c0-4f56-87ef-ee7ffa74be40	         ▸ cli                       0.0.35	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
ad1cc038-c8e2-4fea-a368-0c614e376d1a	         ▸ runtime                   0.0.21	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
658981a3-e360-4160-81c1-e356ac08968f	         ▸ compiler                  0.0.29	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
b17a6163-d532-4211-8056-8f57405ca4e3	         ▸ @openfn/language-dhis2    4.0.2	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
958e15d4-76b5-4b47-9775-f540b0c258e8	[CLI] ✔ Loaded state from /tmp/state-1690445858-7-1e0au1y.json	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
e386652d-edd1-4c9a-9d1d-6722ac6a6bf6	[CLI] ✔ Compiled job from /tmp/expression-1690445858-7-1wmnrzx.js	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
b8c8d788-41c8-4814-8b9f-29a436f448f9	[JOB] ℹ undefined	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
98f8ef54-df69-4a98-89c1-624a085a0bce	[CLI] ✔ Writing output to /tmp/output-1690445858-7-n1r9lq.json	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
397240ff-8427-493e-a0ab-35d75615c5d0	[CLI] ✔ Done in 175ms! ✨	\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
7805704d-d36e-40ea-88bb-8cfbe7e79e85		\N	98fe1df9-7f6c-4f66-995c-eaa7e9267781	2023-07-27 08:17:39
f3c1d48d-6fe0-40ac-a4b9-111dbe795b1b	[CLI] ℹ Versions:	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
6d7c4ea3-6aac-43e1-bb48-dd654346764c	         ▸ node.js                   18.12.0	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
f793a3f5-7086-428e-a55f-541a3ed0ae2e	         ▸ cli                       0.0.35	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
e703fabf-87e1-4fd5-bdda-b275553ef84c	         ▸ runtime                   0.0.21	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
c7986866-2fe1-4fd1-b302-d1ad2b26c787	         ▸ compiler                  0.0.29	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
d0693cfd-d670-47b8-8d35-da3284d03b4e	         ▸ @openfn/language-dhis2    4.0.2	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
78e0a21d-eb90-4645-ae69-7977e93cbfae	[CLI] ✔ Loaded state from /tmp/state-1690445902-7-1n6dns4.json	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
f8d791dd-d8a9-48c1-bd5d-36d6332b6bcc	[CLI] ✔ Compiled job from /tmp/expression-1690445902-7-1tfm334.js	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
597f18d4-8656-4cba-9d6d-7b3e4cc36fea	[JOB] ℹ {	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
dde82e77-c585-48fd-8001-ac105a5cf2e3	  "resourceType": "Patient",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
2de62cc3-6913-4e0a-aad3-ebd1979e6387	  "id": "example",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
68988c7a-ffeb-4f6b-85b2-5f2c65318aeb	  "identifier": [	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
ef6d58f2-74a2-4cc8-bbd4-60ddccfe0b17	    {	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
a7304772-79af-4903-9e12-3412527cf48a	      "system": "http://example.com/patient-ids",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
c49f5587-83c1-435d-a702-f406a934d5a1	      "value": "12345"	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
9019f281-a5ec-4b63-93c6-0e331763d2e3	    }	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
dd212a10-d2cd-4299-96ea-db05ae1ab1e8	  ],	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
1e05e862-6748-4f3c-93c1-382e86b4129c	  "name": [	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
f55cd3e3-b10e-4c7f-9d94-649aa87826d2	    {	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
e35e782c-f8a7-49af-b5a0-fa30bff2ae6a	      "use": "official",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
b44ec184-284e-443d-9e72-2ec74f076e88	      "family": "Smith",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
97ca9024-0273-4389-9870-56ef67a70008	      "given": ["John"]	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
448fb5da-9138-4771-b358-c977dfcde83e	    }	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
ed7d0929-698b-4b93-8fc0-015f19da110a	  ],	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
17e37ce9-17ec-4bdf-b052-fabd7607385b	  "gender": "male",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
3247aabf-7e97-4fbf-94ff-b41d3dd5c820	  "birthDate": "1980-01-15",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
493b1693-78f3-4e1e-a5c7-73c1e5cc3aed	  "address": [	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
53b13d04-f7ca-4c6d-8b24-c6d2ab4457b9	    {	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
25d9530d-ff41-4148-9c61-d3a256aef50e	      "use": "home",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
e70d6740-7d3b-4264-b0b3-f7c27fbb2d70	      "line": ["123 Main Street"],	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
fe7a6256-81d8-427c-a3fd-75eccbd2b59c	      "city": "Anytown",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
d04cbb2c-e410-4ca2-9465-4c6e8cbc3c91	      "state": "NY",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
63be8dd4-e79e-4445-81ca-48b48e800a3f	      "postalCode": "12345",	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
fb52330d-b8d0-41c2-9607-3873aa3ad0dd	      "country": "USA"	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
2f924a0e-734d-4901-93c0-c2255ca55fc3	    }	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
baa7bf58-09fd-4b17-9733-6bb024145c39	  ]	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
511c92f2-524c-42de-a6a1-559d3aa835d9	}	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
66c83097-25b1-4efc-996b-6a067fbf8f78		\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
2209581a-f2b8-44d2-a08a-f6f92cc6eca2	[JOB] ℹ undefined	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
32b076a2-d686-4220-9a78-d462454fd2f3	[CLI] ✔ Writing output to /tmp/output-1690445902-7-sdn5p2.json	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
70b2e0e8-5b1e-40a0-9cfd-6bfa00fd8f9d	[CLI] ✔ Done in 181ms! ✨	\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
062c275e-15ac-4374-a0b8-f99dcebafac5		\N	912a8914-a8f9-4d87-9cae-f01fa6ded47d	2023-07-27 08:18:23
c52379b2-2ab0-4a06-9531-5f91a7215a74	[CLI] ℹ Versions:	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
b95b214d-f379-4d5e-8860-c606cd48971b	         ▸ node.js                   18.12.0	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
2f9cd0b9-e41b-4770-987e-bbc16c3e8075	         ▸ cli                       0.0.35	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
c27bc25b-5e52-482b-99ca-0d6910fb7bf3	         ▸ runtime                   0.0.21	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
ba51d982-af66-4156-968c-234f187f8825	         ▸ compiler                  0.0.29	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
25dc04d6-1bd8-45f9-aeb7-8ef16b02884d	         ▸ @openfn/language-dhis2    4.0.2	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
6e74c11d-2f32-4107-a8f2-1dcfb5bb18da	[CLI] ✔ Loaded state from /tmp/state-1690446121-7-1pwlv83.json	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
89f65e83-15ea-4486-a9f0-77fca22ad133		\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
40a29da1-e295-4bd3-a22d-f2b67aeb023e	[CLI] ✘ Command failed!	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
631558e6-307a-4b91-938a-2d74037804b8	[CLI] ✘ SyntaxError: Unexpected token (4:43)	\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
5fa8bbb4-bd3e-44ca-ab80-e9981796b5d1		\N	aeefbf25-7b33-497d-82c1-1015ab3460a0	2023-07-27 08:22:02
db057060-cdb3-4b09-acf3-7dcb9a272784	[CLI] ℹ Versions:	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
2e5d802e-8eaf-4113-bad2-b97818f4d974	[CLI] ℹ Versions:	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
e0ebce8a-a085-4ea8-ad5d-b8499f971ce0	         ▸ node.js                   18.12.0	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
90475501-d5f0-4574-86e3-5cf9303a0903	         ▸ cli                       0.0.35	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
08210c0e-d428-427d-b9b0-04dcfe3ad0ff	         ▸ runtime                   0.0.21	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
43aab1dd-63d7-4ddb-88a3-3532a81803f7	         ▸ compiler                  0.0.29	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
7e07052b-6aa2-4ab6-b6cc-9db6de4961eb	         ▸ @openfn/language-dhis2    4.0.2	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
3439eb46-cca4-474d-8273-8edd1d8cf12d	[CLI] ✔ Loaded state from /tmp/state-1690446262-7-1twzedh.json	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
22c56e78-b2e8-40af-88d3-705566749462		\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
5fab77a0-34e9-4c4a-86a2-6a755e3e32a6	[CLI] ✘ Command failed!	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
27cc1610-5bef-4294-bfdb-e5c07f11e5c2	[CLI] ✘ SyntaxError: Unexpected token (4:43)	\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
9ddb113f-7cbf-4417-968e-0a2377fd5bc4		\N	dc08a046-cf68-45c9-b092-86042ecb7095	2023-07-27 08:24:24
944cf6a0-3ec8-4c29-815b-28eea6590c47	[CLI] ℹ Versions:	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
acadddc2-0764-4250-ae31-22d0ecb75a59	         ▸ node.js                   18.12.0	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
4b77d6a3-eef4-468f-b416-b1275845e254	         ▸ cli                       0.0.35	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
f4870925-8bf7-444d-8ad8-dc15029bcca5	         ▸ runtime                   0.0.21	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
4a68ea5b-b92d-438a-8bde-9e7040a7c706	         ▸ compiler                  0.0.29	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
7b10419b-e31a-49d1-a466-ed7007386722	         ▸ @openfn/language-dhis2    4.0.2	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
1e0e5ae7-a894-4cf3-a8da-11af10269469	[CLI] ✔ Loaded state from /tmp/state-1690446286-7-of866a.json	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
8d557a20-ec35-4700-b60f-73f9ecf1d0e8	[CLI] ✔ Compiled job from /tmp/expression-1690446286-7-85uqc7.js	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
3f4a6f64-004b-4068-982d-4d666b7454b8	[JOB] ℹ {	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
32d8a92d-7540-4a4b-8283-90b33af2f821	  "resourceType": "Patient",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
7265af7d-9d1c-4aa4-bb5d-9b9e6533c173	  "id": "example",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
4c16e367-8590-4f9d-b596-c001a6846e73	  "identifier": [	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
fefae1f7-a4af-4cb7-bac4-0a53d45bf013	    {	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
8b0800b1-ccd4-4e10-9812-0072f797f579	      "system": "http://example.com/patient-ids",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
02b46ec2-2c29-4bdc-a8e1-90935f0bac69	      "value": "12345"	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
19e32a96-8d0f-4dde-b69f-63503d761e9e	    }	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
512ebe63-9f51-4209-9a85-e8990a4a74a6	  ],	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
7fe26991-fb51-4b85-b0fd-f019601a2caf	  "name": [	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
5e5804d5-1763-43d8-827c-ca3726ee1a46	    {	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
296ba279-3c4c-4a9b-905a-cd7d35207421	      "use": "official",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
e4cfa2e2-a4ec-4eb3-8c4c-1dcac0f697ec	      "family": "Smith",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
be08976d-ebd1-43d1-881a-d5d6148b74b0	      "given": ["John"]	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
53e3b6eb-65cc-40cb-bcec-5f4f7ed87abe	    }	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
9f38a83b-36b1-4f0c-9ac2-0059ac6dd911	  ],	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
808ff97f-de88-486d-932e-f5aea82bc5f8	  "gender": "male",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
3995c3d3-6948-4c0d-bbb7-5bb94de3faeb	  "birthDate": "1980-01-15",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
ff50930e-70f3-4806-ac4f-cf6606acace0	  "address": [	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
a8c2d9fa-60ca-4b86-ab9e-1d385d7bdb7d	    {	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
388bdee6-140a-474d-bc10-721eb1b556f5	      "use": "home",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
d9570860-067e-401e-ab5a-a49afe80c63c	      "line": ["123 Main Street"],	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
171c7063-c416-45b1-862b-4ef34336a869	      "city": "Anytown",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
de92276d-fdc9-4a2e-a79a-750620fa6d49	      "state": "NY",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
976790ba-1955-4d4b-a253-d4c01b236ae6	      "postalCode": "12345",	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
353e2111-70fb-416b-b47b-63c072624779	      "country": "USA"	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
824b4b2e-0419-4d00-87fc-9e002978e752	    }	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
559d17b5-2bbf-4246-8adb-c27acc9702ff	  ]	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
7772182d-05d1-46a4-ab71-40b12076452f	}	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
908c08d8-89e5-4865-ad15-6145d2cb0cba		\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
c22e42e3-1826-4a64-88de-c99fd26a9681	[CLI] ✔ Writing output to /tmp/output-1690446286-7-1e5ggsj.json	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
a98a7463-996c-43ef-a567-2087b23aef90	[CLI] ✔ Done in 183ms! ✨	\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
ee355b1e-09ed-4a77-a896-99029abce670		\N	2f0cc66d-7372-4e98-b553-22b1537a783f	2023-07-27 08:24:47
8197052b-6888-4d1c-a17d-cbbcd04b0873	         ▸ node.js                   18.12.0	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
bf6c454d-8e20-4432-aeb9-eedae73f8179	         ▸ cli                       0.0.35	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
3dc286e1-ef81-4f27-a596-37412427edbf	         ▸ runtime                   0.0.21	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
b365d56c-182a-45db-8bfb-e8c4fe75b4a8	         ▸ compiler                  0.0.29	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
1cb802c7-ae13-4b7e-a9fa-78af5f36957e	         ▸ @openfn/language-dhis2    4.0.2	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
ee13e7f1-85b2-4f68-b6d0-0e881d1c3276	[CLI] ✔ Loaded state from /tmp/state-1690446406-7-wa78xa.json	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
a478ae3c-3ebd-425e-b185-c9a9d52160cf		\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
1871f655-1cae-4faa-9916-2eeba0c542d7	[CLI] ✘ Command failed!	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
7a7faa67-d1f2-453e-b4cf-100528282eb7	[CLI] ✘ SyntaxError: Unexpected token (4:43)	\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
2c1e50cb-7dce-4edc-b85b-2cf99ddbb2ad		\N	53eab82b-fc96-4f59-8bc4-00a777a5894d	2023-07-27 08:26:48
ad8552e7-1ea1-468e-a38f-6b85267e262c	[CLI] ℹ Versions:	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
49aad107-0d1b-40ff-9ab8-61b137920b83	         ▸ node.js                   18.12.0	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
110205e8-058e-4954-8caf-5a08d1398530	         ▸ cli                       0.0.35	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
07b0f31e-e656-4a3a-8952-04a668780d71	         ▸ runtime                   0.0.21	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
c1951e32-cc7e-4d8f-ac9d-9eb1b2280460	         ▸ compiler                  0.0.29	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
29d7d28e-40b4-40cf-b349-3f44f54c57e2	         ▸ @openfn/language-dhis2    4.0.2	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
41ff72b2-5fb9-41f4-92fa-a89136d0cdd0	[CLI] ✔ Loaded state from /tmp/state-1690446664-7-1gqyuse.json	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
d0d899b4-cce8-4f32-87b3-c2ba7c1ec0c5	[CLI] ✔ Compiled job from /tmp/expression-1690446664-7-14fhnnk.js	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
f2ba4884-7877-41ac-ac54-4ddc11c66b86	[JOB] ℹ {	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
0516e3ae-baaa-4a8d-897d-f244525e90a2	  "resourceType": "Patient",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
9ff380fa-cd55-4587-94ab-2f507cfa4b6f	  "id": "example",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
ea292ece-fe8d-41ae-b57a-f3c857720ca1	  "identifier": [	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
c1e7a478-bc5b-46f3-9049-99c141fbd546	    {	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
3dc2301d-9fa2-4f06-83ab-7f2ce72c6c34	      "system": "http://example.com/patient-ids",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
e77dc467-7e95-43da-8566-99bcd6eda347	      "value": "12345"	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
f5d27ea6-ebcf-4592-81b3-4ea36d5a647f	    }	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
60b74a0a-65b0-4086-9bed-489f35f2ef9d	  ],	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
138a4629-cc8d-4f9d-8706-ccb87da551dd	  "name": [	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
39950fa7-911e-4276-9803-6ae6a28b8226	    {	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
f70d3007-61c2-4648-a3e2-c81698709c8e	      "use": "official",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
6daef5b3-f311-4951-86a0-f6b3d4fcdb2c	      "family": "Smith",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
2339e4e9-967e-4241-846f-b316c588f7bd	      "given": ["John"]	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
e92ae5ab-0a2f-433a-81d4-ffeb5da24eaa	    }	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
c3bc7843-c6b5-4a63-aa66-ad49bb4f8a69	  ],	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
9913e579-35bf-4cb1-9a33-417f9c47e0f7	  "gender": "male",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
25c010a3-4618-47d5-b97b-0970c87172a3	  "birthDate": "1980-01-15",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
ab46f316-8976-416c-8e18-8f02029007e4	  "address": [	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
1b3f4999-f017-40e2-8228-1d60549d881a	    {	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
acb0b3cb-10f5-472c-9cb7-7deebf2ba94f	      "use": "home",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
e9fbe04a-750c-4440-ab54-f80b88464079	      "line": ["123 Main Street"],	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
e776d44d-bbcb-4811-a4b8-7886e77e1143	      "city": "Anytown",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
4f123c23-7c95-4ff2-8610-62d1859fe8de	      "state": "NY",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
cbf60a5c-f127-4e6d-96f2-4911431ec42e	      "postalCode": "12345",	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
d3e30f43-9e31-4201-ba0b-f1ca51a79afe	      "country": "USA"	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
f17eec9e-d027-4dff-bb80-56c390788d58	    }	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
b895b478-ee6e-422c-811b-3cb7167a099d	  ]	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
6d1d057b-6cdd-41d5-adc4-a2e43b81cc7e	}	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
87b3644c-caf4-46a4-988b-ba0e7ac5f784		\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
df72244e-137b-4a07-8fbf-81b129dfd2c1	[CLI] ✔ Writing output to /tmp/output-1690446664-7-1lomkol.json	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
78e3585c-9b50-4a0e-945e-9763e7c52e39	[CLI] ✔ Done in 168ms! ✨	\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
9192780c-38c4-4137-a19b-6d0a26866fe3		\N	034ce120-b21c-4dac-a412-4ccf0744192c	2023-07-27 08:31:06
\.


--
-- Data for Name: oban_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oban_jobs (id, state, queue, worker, args, errors, attempt, max_attempts, inserted_at, scheduled_at, attempted_at, completed_at, attempted_by, discarded_at, priority, tags, meta, cancelled_at) FROM stdin;
9217	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:47:59.91579	2023-07-31 05:47:59.91579	2023-07-31 05:48:00.024118	2023-07-31 05:48:00.026548	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9300	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:28:59.580428	2023-07-31 06:28:59.580428	2023-07-31 06:28:59.685906	2023-07-31 06:28:59.688601	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9299	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:28:59.580428	2023-07-31 06:28:59.580428	2023-07-31 06:28:59.685973	2023-07-31 06:28:59.688727	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9218	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:47:59.91579	2023-07-31 05:47:59.91579	2023-07-31 05:48:00.024051	2023-07-31 05:48:00.026707	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9245	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:01:59.968972	2023-07-31 06:01:59.968972	2023-07-31 06:02:00.085009	2023-07-31 06:02:00.097091	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9271	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:14:59.563507	2023-07-31 06:14:59.563507	2023-07-31 06:14:59.673268	2023-07-31 06:14:59.681373	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9246	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:01:59.968972	2023-07-31 06:01:59.968972	2023-07-31 06:02:00.085095	2023-07-31 06:02:00.098015	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9272	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:14:59.563507	2023-07-31 06:14:59.563507	2023-07-31 06:14:59.673371	2023-07-31 06:14:59.681758	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
4245	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "ec8cea33-dcb7-4d5e-9be1-3905d309bc53"}	{"{\\"at\\": \\"2023-07-26T15:07:51.340008Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-26 15:07:50.015944	2023-07-26 15:07:50.015944	2023-07-26 15:07:50.117677	\N	{lightning@2a36b3cbe206}	2023-07-26 15:07:51.338673	1	{}	{}	\N
9317	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:37:59.439428	2023-07-31 06:37:59.439428	2023-07-31 06:37:59.550317	2023-07-31 06:37:59.555732	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9211	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:44:59.609318	2023-07-31 05:44:59.609318	2023-07-31 05:44:59.721837	2023-07-31 05:44:59.723791	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9212	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:44:59.609318	2023-07-31 05:44:59.609318	2023-07-31 05:44:59.721786	2023-07-31 05:44:59.724889	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9318	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:37:59.439428	2023-07-31 06:37:59.439428	2023-07-31 06:37:59.550756	2023-07-31 06:37:59.556412	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9235	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:56:59.819408	2023-07-31 05:56:59.819408	2023-07-31 05:56:59.929555	2023-07-31 05:56:59.934264	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6144	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "e994de02-7e3d-4cc3-87f7-5e96462e56e4"}	{"{\\"at\\": \\"2023-07-27T06:44:31.534489Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:44:30.541284	2023-07-27 06:44:30.541284	2023-07-27 06:44:30.643182	\N	{lightning@2a36b3cbe206}	2023-07-27 06:44:31.533788	1	{}	{}	\N
9236	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:56:59.819408	2023-07-31 05:56:59.819408	2023-07-31 05:56:59.929667	2023-07-31 05:56:59.934516	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9261	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:10:00.406613	2023-07-31 06:10:00.406613	2023-07-31 06:10:00.520805	2023-07-31 06:10:00.525644	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9284	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:21:00.148918	2023-07-31 06:21:00.148918	2023-07-31 06:21:00.257173	2023-07-31 06:21:00.261905	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9262	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:10:00.406613	2023-07-31 06:10:00.406613	2023-07-31 06:10:00.520714	2023-07-31 06:10:00.525917	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9283	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:21:00.148918	2023-07-31 06:21:00.148918	2023-07-31 06:21:00.257277	2023-07-31 06:21:00.261675	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9273	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:15:59.992844	2023-07-31 06:15:59.992844	2023-07-31 06:16:00.107658	2023-07-31 06:16:00.110939	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9274	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:15:59.992844	2023-07-31 06:15:59.992844	2023-07-31 06:16:00.10754	2023-07-31 06:16:00.111176	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9247	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:03:00.406826	2023-07-31 06:03:00.406826	2023-07-31 06:03:00.514401	2023-07-31 06:03:00.519267	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9219	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:49:00.350189	2023-07-31 05:49:00.350189	2023-07-31 05:49:00.457909	2023-07-31 05:49:00.462157	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9220	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:49:00.350189	2023-07-31 05:49:00.350189	2023-07-31 05:49:00.457989	2023-07-31 05:49:00.46223	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9248	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:03:00.406826	2023-07-31 06:03:00.406826	2023-07-31 06:03:00.514332	2023-07-31 06:03:00.521711	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9301	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:30:00.003417	2023-07-31 06:30:00.003417	2023-07-31 06:30:00.111921	2023-07-31 06:30:00.116768	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9302	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:30:00.003417	2023-07-31 06:30:00.003417	2023-07-31 06:30:00.112005	2023-07-31 06:30:00.117012	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6074	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "29a79a36-f66f-4118-aeb8-a39fba494483"}	{"{\\"at\\": \\"2023-07-27T06:18:06.798449Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:18:05.416885	2023-07-27 06:18:05.416885	2023-07-27 06:18:05.519335	\N	{lightning@2a36b3cbe206}	2023-07-27 06:18:06.797856	1	{}	{}	\N
9286	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:21:59.580598	2023-07-31 06:21:59.580598	2023-07-31 06:21:59.690578	2023-07-31 06:21:59.698892	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9285	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:21:59.580598	2023-07-31 06:21:59.580598	2023-07-31 06:21:59.690473	2023-07-31 06:21:59.699218	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9319	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:38:59.872313	2023-07-31 06:38:59.872313	2023-07-31 06:38:59.980639	2023-07-31 06:38:59.98463	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9263	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:10:59.843655	2023-07-31 06:10:59.843655	2023-07-31 06:10:59.954915	2023-07-31 06:10:59.959358	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9264	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:10:59.843655	2023-07-31 06:10:59.843655	2023-07-31 06:10:59.955174	2023-07-31 06:10:59.9598	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6130	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "ed6012ba-b48a-4929-989c-dc59f18d9d76"}	{"{\\"at\\": \\"2023-07-27T06:40:30.262930Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:40:29.248422	2023-07-27 06:40:29.248422	2023-07-27 06:40:29.350984	\N	{lightning@2a36b3cbe206}	2023-07-27 06:40:30.262255	1	{}	{}	\N
9213	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:46:00.043413	2023-07-31 05:46:00.043413	2023-07-31 05:46:00.153734	2023-07-31 05:46:00.164298	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9214	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:46:00.043413	2023-07-31 05:46:00.043413	2023-07-31 05:46:00.153792	2023-07-31 05:46:00.165495	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9239	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:58:59.679074	2023-07-31 05:58:59.679074	2023-07-31 05:58:59.79626	2023-07-31 05:58:59.800346	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9240	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:58:59.679074	2023-07-31 05:58:59.679074	2023-07-31 05:58:59.796353	2023-07-31 05:58:59.801745	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9320	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:38:59.872313	2023-07-31 06:38:59.872313	2023-07-31 06:38:59.980722	2023-07-31 06:38:59.986061	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9303	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:30:59.431198	2023-07-31 06:30:59.431198	2023-07-31 06:30:59.535528	2023-07-31 06:30:59.539314	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9276	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:16:59.43068	2023-07-31 06:16:59.43068	2023-07-31 06:16:59.535613	2023-07-31 06:16:59.538386	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9249	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:03:59.83533	2023-07-31 06:03:59.83533	2023-07-31 06:03:59.941814	2023-07-31 06:03:59.945815	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9221	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:49:59.779191	2023-07-31 05:49:59.779191	2023-07-31 05:49:59.896513	2023-07-31 05:49:59.908437	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9222	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:49:59.779191	2023-07-31 05:49:59.779191	2023-07-31 05:49:59.896423	2023-07-31 05:49:59.908987	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9250	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:03:59.83533	2023-07-31 06:03:59.83533	2023-07-31 06:03:59.941946	2023-07-31 06:03:59.946722	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9275	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:16:59.43068	2023-07-31 06:16:59.43068	2023-07-31 06:16:59.535667	2023-07-31 06:16:59.539773	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9304	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:30:59.431198	2023-07-31 06:30:59.431198	2023-07-31 06:30:59.535468	2023-07-31 06:30:59.539598	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9265	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:12:00.276411	2023-07-31 06:12:00.276411	2023-07-31 06:12:00.386075	2023-07-31 06:12:00.387942	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9225	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:51:59.646671	2023-07-31 05:51:59.646671	2023-07-31 05:51:59.754221	2023-07-31 05:51:59.75606	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9226	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:51:59.646671	2023-07-31 05:51:59.646671	2023-07-31 05:51:59.754176	2023-07-31 05:51:59.756779	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9207	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:42:59.759457	2023-07-31 05:42:59.759457	2023-07-31 05:42:59.863316	2023-07-31 05:42:59.865159	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9266	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:12:00.276411	2023-07-31 06:12:00.276411	2023-07-31 06:12:00.38602	2023-07-31 06:12:00.388949	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9287	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:23:00.010418	2023-07-31 06:23:00.010418	2023-07-31 06:23:00.121285	2023-07-31 06:23:00.123255	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9288	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:23:00.010418	2023-07-31 06:23:00.010418	2023-07-31 06:23:00.121332	2023-07-31 06:23:00.12388	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9215	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:46:59.479918	2023-07-31 05:46:59.479918	2023-07-31 05:46:59.596295	2023-07-31 05:46:59.600538	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9216	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:46:59.479918	2023-07-31 05:46:59.479918	2023-07-31 05:46:59.59639	2023-07-31 05:46:59.601755	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9241	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:00:00.114818	2023-07-31 06:00:00.114818	2023-07-31 06:00:00.226884	2023-07-31 06:00:00.229838	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9242	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:00:00.114818	2023-07-31 06:00:00.114818	2023-07-31 06:00:00.226816	2023-07-31 06:00:00.230378	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9295	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:26:59.72011	2023-07-31 06:26:59.72011	2023-07-31 06:26:59.82748	2023-07-31 06:26:59.830884	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9296	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:26:59.72011	2023-07-31 06:26:59.72011	2023-07-31 06:26:59.827589	2023-07-31 06:26:59.831578	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9243	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:00:59.546968	2023-07-31 06:00:59.546968	2023-07-31 06:00:59.653635	2023-07-31 06:00:59.657707	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9244	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:00:59.546968	2023-07-31 06:00:59.546968	2023-07-31 06:00:59.653513	2023-07-31 06:00:59.658937	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9277	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:17:59.857271	2023-07-31 06:17:59.857271	2023-07-31 06:17:59.972479	2023-07-31 06:17:59.976113	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9278	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:17:59.857271	2023-07-31 06:17:59.857271	2023-07-31 06:17:59.972398	2023-07-31 06:17:59.977225	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9251	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:05:00.259595	2023-07-31 06:05:00.259595	2023-07-31 06:05:00.374846	2023-07-31 06:05:00.378762	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9223	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:51:00.222233	2023-07-31 05:51:00.222233	2023-07-31 05:51:00.325514	2023-07-31 05:51:00.329627	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9252	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:05:00.259595	2023-07-31 06:05:00.259595	2023-07-31 06:05:00.37495	2023-07-31 06:05:00.38067	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9305	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:31:59.85417	2023-07-31 06:31:59.85417	2023-07-31 06:31:59.959537	2023-07-31 06:31:59.964393	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9306	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:31:59.85417	2023-07-31 06:31:59.85417	2023-07-31 06:31:59.959632	2023-07-31 06:31:59.964313	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9224	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:51:00.222233	2023-07-31 05:51:00.222233	2023-07-31 05:51:00.325437	2023-07-31 05:51:00.329991	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9313	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:35:59.564917	2023-07-31 06:35:59.564917	2023-07-31 06:35:59.67988	2023-07-31 06:35:59.684532	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9201	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:39:59.446688	2023-07-31 05:39:59.446688	2023-07-31 05:39:59.554155	2023-07-31 05:39:59.555993	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9202	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:39:59.446688	2023-07-31 05:39:59.446688	2023-07-31 05:39:59.554093	2023-07-31 05:39:59.556569	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9254	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:05:59.695969	2023-07-31 06:05:59.695969	2023-07-31 06:05:59.800551	2023-07-31 06:05:59.806131	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9253	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:05:59.695969	2023-07-31 06:05:59.695969	2023-07-31 06:05:59.800435	2023-07-31 06:05:59.806466	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9289	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:23:59.442863	2023-07-31 06:23:59.442863	2023-07-31 06:23:59.546958	2023-07-31 06:23:59.548941	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9204	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:40:59.879782	2023-07-31 05:40:59.879782	2023-07-31 05:40:59.996018	2023-07-31 05:41:00.00101	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9290	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:23:59.442863	2023-07-31 06:23:59.442863	2023-07-31 06:23:59.547011	2023-07-31 06:23:59.549349	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9314	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:35:59.564917	2023-07-31 06:35:59.564917	2023-07-31 06:35:59.679788	2023-07-31 06:35:59.685111	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9297	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:28:00.15192	2023-07-31 06:28:00.15192	2023-07-31 06:28:00.259266	2023-07-31 06:28:00.26286	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9209	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:44:00.18258	2023-07-31 05:44:00.18258	2023-07-31 05:44:00.288223	2023-07-31 05:44:00.291773	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9210	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:44:00.18258	2023-07-31 05:44:00.18258	2023-07-31 05:44:00.288295	2023-07-31 05:44:00.292253	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9267	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:12:59.707585	2023-07-31 06:12:59.707585	2023-07-31 06:12:59.815361	2023-07-31 06:12:59.817212	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9268	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:12:59.707585	2023-07-31 06:12:59.707585	2023-07-31 06:12:59.81541	2023-07-31 06:12:59.818197	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9298	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:28:00.15192	2023-07-31 06:28:00.15192	2023-07-31 06:28:00.259364	2023-07-31 06:28:00.263716	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6129	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "fa9df57e-5340-4946-ab36-001f1a8ca704"}	{"{\\"at\\": \\"2023-07-27T06:40:19.168696Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:40:18.160261	2023-07-27 06:40:18.160261	2023-07-27 06:40:18.262911	\N	{lightning@2a36b3cbe206}	2023-07-27 06:40:19.16808	1	{}	{}	\N
9307	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:33:00.281681	2023-07-31 06:33:00.281681	2023-07-31 06:33:00.387312	2023-07-31 06:33:00.389712	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9255	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:07:00.120573	2023-07-31 06:07:00.120573	2023-07-31 06:07:00.22403	2023-07-31 06:07:00.227391	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6214	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "61ae787f-59d0-4555-a4cc-6bc02293e290"}	{"{\\"at\\": \\"2023-07-27T07:13:50.245331Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 07:13:49.229509	2023-07-27 07:13:49.229509	2023-07-27 07:13:49.331326	\N	{lightning@2a36b3cbe206}	2023-07-27 07:13:50.244612	1	{}	{}	\N
9227	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:53:00.075497	2023-07-31 05:53:00.075497	2023-07-31 05:53:00.191428	2023-07-31 05:53:00.196124	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9279	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:19:00.29368	2023-07-31 06:19:00.29368	2023-07-31 06:19:00.398575	2023-07-31 06:19:00.403947	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9280	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:19:00.29368	2023-07-31 06:19:00.29368	2023-07-31 06:19:00.398454	2023-07-31 06:19:00.404804	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9199	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:39:00.012569	2023-07-31 05:39:00.012569	2023-07-31 05:39:00.120694	2023-07-31 05:39:00.133206	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9256	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:07:00.120573	2023-07-31 06:07:00.120573	2023-07-31 06:07:00.224097	2023-07-31 06:07:00.229234	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9200	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:39:00.012569	2023-07-31 05:39:00.012569	2023-07-31 05:39:00.120583	2023-07-31 05:39:00.134089	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9228	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:53:00.075497	2023-07-31 05:53:00.075497	2023-07-31 05:53:00.191343	2023-07-31 05:53:00.196603	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9259	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:08:59.979977	2023-07-31 06:08:59.979977	2023-07-31 06:09:00.087747	2023-07-31 06:09:00.089885	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9308	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:33:00.281681	2023-07-31 06:33:00.281681	2023-07-31 06:33:00.387361	2023-07-31 06:33:00.390054	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
3717	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "693acdf3-8fdf-4af6-b629-be19e535f72e"}	{"{\\"at\\": \\"2023-07-26T09:07:27.343438Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-26 09:07:25.300407	2023-07-26 09:07:25.300407	2023-07-26 09:07:25.372601	\N	{lightning@2a36b3cbe206}	2023-07-26 09:07:27.342439	1	{}	{}	\N
9208	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:42:59.759457	2023-07-31 05:42:59.759457	2023-07-31 05:42:59.863309	2023-07-31 05:42:59.865772	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9269	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:14:00.132526	2023-07-31 06:14:00.132526	2023-07-31 06:14:00.239813	2023-07-31 06:14:00.243469	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9270	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:14:00.132526	2023-07-31 06:14:00.132526	2023-07-31 06:14:00.239917	2023-07-31 06:14:00.243886	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9291	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:24:59.861084	2023-07-31 06:24:59.861084	2023-07-31 06:24:59.97584	2023-07-31 06:24:59.987647	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9312	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:35:00.133552	2023-07-31 06:35:00.133552	2023-07-31 06:35:00.241894	2023-07-31 06:35:00.253521	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9292	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:24:59.861084	2023-07-31 06:24:59.861084	2023-07-31 06:24:59.97584	2023-07-31 06:24:59.98819	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9293	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:26:00.292789	2023-07-31 06:26:00.292789	2023-07-31 06:26:00.395005	2023-07-31 06:26:00.398552	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9294	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:26:00.292789	2023-07-31 06:26:00.292789	2023-07-31 06:26:00.395064	2023-07-31 06:26:00.398769	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6131	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "f88920d3-1ce2-4356-8f2e-ea71463f2b02"}	{"{\\"at\\": \\"2023-07-27T06:40:49.096578Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:40:48.031541	2023-07-27 06:40:48.031541	2023-07-27 06:40:48.133512	\N	{lightning@2a36b3cbe206}	2023-07-27 06:40:49.095539	1	{}	{}	\N
6134	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "227baba7-97c8-4610-9368-0f94209ef770"}	{"{\\"at\\": \\"2023-07-27T06:41:05.935783Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:41:04.907181	2023-07-27 06:41:04.907181	2023-07-27 06:41:05.008758	\N	{lightning@2a36b3cbe206}	2023-07-27 06:41:05.934907	1	{}	{}	\N
9203	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:40:59.879782	2023-07-31 05:40:59.879782	2023-07-31 05:40:59.996018	2023-07-31 05:40:59.999841	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6138	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "df2e1df2-3252-4c50-bfe4-80df199cd135"}	{"{\\"at\\": \\"2023-07-27T06:42:51.038084Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:42:50.003528	2023-07-27 06:42:50.003528	2023-07-27 06:42:50.105431	\N	{lightning@2a36b3cbe206}	2023-07-27 06:42:51.037419	1	{}	{}	\N
9257	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:07:59.546074	2023-07-31 06:07:59.546074	2023-07-31 06:07:59.657822	2023-07-31 06:07:59.66132	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9309	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:33:59.70778	2023-07-31 06:33:59.70778	2023-07-31 06:33:59.813112	2023-07-31 06:33:59.816918	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6156	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "9d815575-034c-4328-befa-467be5a2f686"}	{"{\\"at\\": \\"2023-07-27T06:48:11.850407Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:48:10.826101	2023-07-27 06:48:10.826101	2023-07-27 06:48:10.927366	\N	{lightning@2a36b3cbe206}	2023-07-27 06:48:11.849787	1	{}	{}	\N
9229	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:53:59.514154	2023-07-31 05:53:59.514154	2023-07-31 05:53:59.623481	2023-07-31 05:53:59.628472	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9230	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:53:59.514154	2023-07-31 05:53:59.514154	2023-07-31 05:53:59.623589	2023-07-31 05:53:59.628827	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9258	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:07:59.546074	2023-07-31 06:07:59.546074	2023-07-31 06:07:59.65789	2023-07-31 06:07:59.66239	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6163	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "f890a6b5-2435-4357-a1cf-1c99e7202cb0"}	{"{\\"at\\": \\"2023-07-27T06:50:22.585757Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:50:21.535235	2023-07-27 06:50:21.535235	2023-07-27 06:50:21.636906	\N	{lightning@2a36b3cbe206}	2023-07-27 06:50:22.585044	1	{}	{}	\N
9310	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:33:59.70778	2023-07-31 06:33:59.70778	2023-07-31 06:33:59.813022	2023-07-31 06:33:59.816927	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6166	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "91856a2b-0ee1-4eb5-beba-3a23e3dbfc58"}	{"{\\"at\\": \\"2023-07-27T06:51:29.265337Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 06:51:28.257678	2023-07-27 06:51:28.257678	2023-07-27 06:51:28.36135	\N	{lightning@2a36b3cbe206}	2023-07-27 06:51:29.264686	1	{}	{}	\N
9311	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:35:00.133552	2023-07-31 06:35:00.133552	2023-07-31 06:35:00.241983	2023-07-31 06:35:00.253103	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6369	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "d5b10206-0858-4a0f-ad82-98577cbdd294"}	{"{\\"at\\": \\"2023-07-27T08:15:24.076586Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 08:15:23.047784	2023-07-27 08:15:23.047784	2023-07-27 08:15:23.149434	\N	{lightning@2a36b3cbe206}	2023-07-27 08:15:24.07598	1	{}	{}	\N
9282	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:19:59.721709	2023-07-31 06:19:59.721709	2023-07-31 06:19:59.824003	2023-07-31 06:19:59.828115	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9231	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:54:59.951804	2023-07-31 05:54:59.951804	2023-07-31 05:55:00.066013	2023-07-31 05:55:00.071606	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6221	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "21746f43-f710-4487-bfa5-889723a63f7c"}	{"{\\"at\\": \\"2023-07-27T07:15:41.081178Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 07:15:40.041611	2023-07-27 07:15:40.041611	2023-07-27 07:15:40.143762	\N	{lightning@2a36b3cbe206}	2023-07-27 07:15:41.080559	1	{}	{}	\N
6222	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "1301de26-6b21-4d02-9342-839d53eafb27"}	{"{\\"at\\": \\"2023-07-27T07:15:59.194667Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 07:15:58.182753	2023-07-27 07:15:58.182753	2023-07-27 07:15:58.284626	\N	{lightning@2a36b3cbe206}	2023-07-27 07:15:59.194083	1	{}	{}	\N
9205	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:42:00.319662	2023-07-31 05:42:00.319662	2023-07-31 05:42:00.4358	2023-07-31 05:42:00.439839	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9232	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:54:59.951804	2023-07-31 05:54:59.951804	2023-07-31 05:55:00.066133	2023-07-31 05:55:00.072948	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
6233	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "2aca759e-461c-4d81-902b-e609fb17df49"}	{"{\\"at\\": \\"2023-07-27T07:19:38.086917Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 07:19:37.074918	2023-07-27 07:19:37.074918	2023-07-27 07:19:37.17633	\N	{lightning@2a36b3cbe206}	2023-07-27 07:19:38.086352	1	{}	{}	\N
6363	discarded	runs	Lightning.Pipeline	{"attempt_run_id": "e54dc6cc-c27e-4658-83bc-42ef8e9e576b"}	{"{\\"at\\": \\"2023-07-27T08:13:26.031809Z\\", \\"error\\": \\"** (Postgrex.Error) ERROR 22001 (string_data_right_truncation) value too long for type character varying(255)\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:913: Ecto.Adapters.SQL.raise_sql_call_error/1\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:756: Ecto.Repo.Schema.apply/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:369: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4\\\\n    (ecto 3.9.4) lib/ecto/repo/schema.ex:265: Ecto.Repo.Schema.insert!/4\\\\n    (elixir 1.14.1) lib/enum.ex:975: Enum.\\\\\\"-each/2-lists^foreach/1-0-\\\\\\"/2\\\\n    (lightning 0.6.7) lib/lightning/pipeline/runner.ex:55: anonymous fn/3 in Lightning.Pipeline.Runner.Handler.on_finish/2\\\\n    (ecto_sql 3.9.2) lib/ecto/adapters/sql.ex:1203: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4\\\\n    (db_connection 2.4.3) lib/db_connection.ex:1611: DBConnection.run_transaction/4\\\\n\\", \\"attempt\\": 1}"}	1	1	2023-07-27 08:13:25.03324	2023-07-27 08:13:25.03324	2023-07-27 08:13:25.134922	\N	{lightning@2a36b3cbe206}	2023-07-27 08:13:26.03111	1	{}	{}	\N
9260	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:08:59.979977	2023-07-31 06:08:59.979977	2023-07-31 06:09:00.087682	2023-07-31 06:09:00.090058	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9206	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:42:00.319662	2023-07-31 05:42:00.319662	2023-07-31 05:42:00.435893	2023-07-31 05:42:00.440835	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9281	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:19:59.721709	2023-07-31 06:19:59.721709	2023-07-31 06:19:59.824003	2023-07-31 06:19:59.827764	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9234	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:56:00.390064	2023-07-31 05:56:00.390064	2023-07-31 05:56:00.500007	2023-07-31 05:56:00.503509	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9233	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:56:00.390064	2023-07-31 05:56:00.390064	2023-07-31 05:56:00.499954	2023-07-31 05:56:00.502974	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9315	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 06:37:00.002067	2023-07-31 06:37:00.002067	2023-07-31 06:37:00.116457	2023-07-31 06:37:00.121191	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9316	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 06:37:00.002067	2023-07-31 06:37:00.002067	2023-07-31 06:37:00.116356	2023-07-31 06:37:00.121405	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9237	completed	scheduler	Lightning.Jobs.Scheduler	{}	{}	1	1	2023-07-31 05:58:00.248321	2023-07-31 05:58:00.248321	2023-07-31 05:58:00.358521	2023-07-31 05:58:00.37032	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
9238	completed	background	ObanPruner	{}	{}	1	10	2023-07-31 05:58:00.248321	2023-07-31 05:58:00.248321	2023-07-31 05:58:00.358607	2023-07-31 05:58:00.371523	{lightning@7469400d1dfa}	\N	1	{}	{}	\N
\.


--
-- Data for Name: oban_peers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oban_peers (name, node, started_at, expires_at) FROM stdin;
Oban	lightning@7469400d1dfa	2023-07-30 11:24:01.119327	2023-07-31 06:39:28.280673
\.


--
-- Data for Name: project_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_credentials (id, project_id, credential_id, inserted_at, updated_at) FROM stdin;
0bac4af3-f4bf-4418-b9b2-1f0bf6c1222e	87ea20f1-7d81-4959-bdba-279147713fb8	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384	2023-07-25 06:22:07	2023-07-25 06:22:07
\.


--
-- Data for Name: project_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_users (id, user_id, project_id, inserted_at, updated_at, role, failure_alert, digest) FROM stdin;
97e765bd-97fc-4c77-b74d-af6bcfca4113	3476f7a9-e02f-4a3d-bc1f-ae3374a882ac	87ea20f1-7d81-4959-bdba-279147713fb8	2023-07-25 06:21:19	2023-07-25 06:21:19	admin	t	weekly
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, name, inserted_at, updated_at, description, scheduled_deletion) FROM stdin;
87ea20f1-7d81-4959-bdba-279147713fb8	test	2023-07-25 06:21:19	2023-07-25 06:21:19	\N	\N
\.


--
-- Data for Name: runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.runs (id, exit_code, started_at, finished_at, inserted_at, updated_at, job_id, input_dataclip_id, output_dataclip_id, previous_id, credential_id) FROM stdin;
974b75fa-f614-4fba-b83d-6f33333907a4	0	2023-07-25 06:29:24.803969	2023-07-25 06:29:27.841766	2023-07-25 06:29:24.68391	2023-07-25 06:29:27.8488	7d95a11a-0c96-461b-8991-f20b6bbbb56b	78f75edc-8704-4e66-ba72-287e2bc5707a	9e770dfb-c0f4-43d6-bccc-0643c6f2180e	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
0837b50c-acea-4b77-a387-2080a1d75385	\N	2023-07-26 15:07:50.124487	2023-07-26 15:07:51.346786	2023-07-26 15:07:50.014529	2023-07-26 15:07:51.34686	7d95a11a-0c96-461b-8991-f20b6bbbb56b	e46fec2d-63c1-44b4-a879-2b44ab16ffd0	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
8431f3de-3a80-4e8e-88dc-f17a581c76f2	1	2023-07-25 06:30:08.364336	2023-07-25 06:30:10.938815	2023-07-25 06:30:08.240641	2023-07-25 06:30:10.938884	7d95a11a-0c96-461b-8991-f20b6bbbb56b	b986bc53-d08c-45d0-b967-84ca470529e9	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
aa29dbe8-e943-483b-99c7-1a9adbfeb323	\N	2023-07-27 06:48:10.934863	2023-07-27 06:48:11.851934	2023-07-27 06:48:10.824699	2023-07-27 06:48:11.851967	7d95a11a-0c96-461b-8991-f20b6bbbb56b	78294e48-1d12-4306-87a9-20c077476fbb	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
f093aeef-e2ac-4f80-b057-76456c21e269	0	2023-07-26 05:46:00.977375	2023-07-26 05:46:04.307992	2023-07-26 05:46:00.86836	2023-07-26 05:46:04.313979	7d95a11a-0c96-461b-8991-f20b6bbbb56b	b9f3e2b7-ae82-46a3-aa82-036a6a03a12b	0dbeefd9-f2ed-4e13-bf4e-a7d44fa54d58	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
461d2ea6-ed8a-4e36-8c28-60166d243eaf	1	2023-07-26 15:14:08.56027	2023-07-26 15:14:10.054052	2023-07-26 15:14:08.45112	2023-07-26 15:14:10.054086	7d95a11a-0c96-461b-8991-f20b6bbbb56b	278fdf91-cef2-41b6-a2db-04848b813787	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
1e0cdee4-1211-4d40-bcb0-a28b6b9555e4	1	2023-07-26 05:48:04.93735	2023-07-26 05:48:07.496122	2023-07-26 05:48:04.828443	2023-07-26 05:48:07.496187	7d95a11a-0c96-461b-8991-f20b6bbbb56b	e67fadbe-1892-4fed-95e8-0771966a9eb0	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
a59e598b-7b62-4a9c-bd43-9b90b30d869c	1	2023-07-26 05:49:21.23569	2023-07-26 05:49:23.673416	2023-07-26 05:49:21.11595	2023-07-26 05:49:23.673452	7d95a11a-0c96-461b-8991-f20b6bbbb56b	e17eb0f6-829d-4c88-99df-7c14d6f0b9fd	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
61cb5244-ca62-4380-9610-48c05b6169c4	0	2023-07-27 06:36:49.271014	2023-07-27 06:36:50.40006	2023-07-27 06:36:49.1615	2023-07-27 06:36:50.402285	7d95a11a-0c96-461b-8991-f20b6bbbb56b	661cae58-607e-4c9d-9da1-9ea117915ca5	c3cfa184-f7e4-47bc-a3c0-4128d779abde	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
f6893628-7602-43ac-b0be-5289ca211fec	1	2023-07-26 05:49:32.278084	2023-07-26 05:49:34.944185	2023-07-26 05:49:32.16953	2023-07-26 05:49:34.944222	7d95a11a-0c96-461b-8991-f20b6bbbb56b	43272d2a-e361-43fe-b603-ab67fa7f8a50	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
c6b434da-281e-438f-bd02-e6d2df807b69	1	2023-07-26 15:17:47.666526	2023-07-26 15:17:49.027322	2023-07-26 15:17:47.557491	2023-07-26 15:17:49.027354	7d95a11a-0c96-461b-8991-f20b6bbbb56b	99605d45-04b4-447d-84d8-e71267e6d6bb	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
d6ecddbf-24b3-4e40-97d5-e6740d9ca45b	1	2023-07-26 05:51:34.113423	2023-07-26 05:51:36.503133	2023-07-26 05:51:33.998232	2023-07-26 05:51:36.503172	7d95a11a-0c96-461b-8991-f20b6bbbb56b	4edeaf5f-02b0-491e-9e7d-80ad9a58cc74	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
beb959da-b5bb-462a-885e-b32c3c693282	1	2023-07-26 05:53:54.808182	2023-07-26 05:53:55.988969	2023-07-26 05:53:54.699199	2023-07-26 05:53:55.98903	7d95a11a-0c96-461b-8991-f20b6bbbb56b	dd809311-24eb-45c5-8443-70782066bd44	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
ff72b382-602a-45b0-b132-86aee9525bc9	\N	2023-07-27 06:18:05.529343	2023-07-27 06:18:06.799982	2023-07-27 06:18:05.415779	2023-07-27 06:18:06.800025	7d95a11a-0c96-461b-8991-f20b6bbbb56b	f96a8cea-c818-4e6d-bf37-777b9fd386d6	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
b24125cf-23ac-40bd-b401-64a361bd421a	0	2023-07-26 05:56:53.51645	2023-07-26 05:56:55.719717	2023-07-26 05:56:53.406283	2023-07-26 05:56:55.722805	7d95a11a-0c96-461b-8991-f20b6bbbb56b	06ed4489-82ef-471b-b5a2-4af563392b4c	ebf662f7-9ca5-4a63-82b1-56b23fad5ecc	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
31cf94cb-e574-4ef6-b825-fd2c2214cf6e	1	2023-07-26 07:58:49.816934	2023-07-26 07:58:51.259864	2023-07-26 07:58:49.707373	2023-07-26 07:58:51.259902	7d95a11a-0c96-461b-8991-f20b6bbbb56b	4d736514-5a33-4381-bc50-52bdb73a4349	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
29e754db-4ad3-4a31-9a60-cb34fb7dd84f	\N	2023-07-27 06:42:50.116128	2023-07-27 06:42:51.039501	2023-07-27 06:42:50.001047	2023-07-27 06:42:51.03954	7d95a11a-0c96-461b-8991-f20b6bbbb56b	837e02bd-483f-48ce-adef-2d285f667606	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
07c4d03c-e63e-40ce-bbbc-ec58d9e25d3c	1	2023-07-27 06:18:13.959498	2023-07-27 06:18:15.216095	2023-07-27 06:18:13.845027	2023-07-27 06:18:15.216129	7d95a11a-0c96-461b-8991-f20b6bbbb56b	72ef3078-6fd5-4e37-91d3-97ddc2069dab	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
d0b92099-5ae9-4863-bb61-733bbec92552	1	2023-07-27 06:18:46.824178	2023-07-27 06:18:48.274597	2023-07-27 06:18:46.709345	2023-07-27 06:18:48.274631	7d95a11a-0c96-461b-8991-f20b6bbbb56b	32d51554-c05b-4d67-8d1e-0690ef2c264b	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
b798c1a9-6aef-4e2b-a676-c9bb5c773f8a	1	2023-07-26 09:07:25.383438	2023-07-26 09:07:27.323794	2023-07-26 09:07:25.299414	2023-07-26 09:07:27.323834	7d95a11a-0c96-461b-8991-f20b6bbbb56b	381fae4c-3492-4a50-b4b0-355fbb36342d	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
fc6ce658-02a5-4d15-b54a-9d9557b3a137	1	2023-07-26 09:07:25.38192	2023-07-26 09:07:27.339015	2023-07-26 09:07:25.296759	2023-07-26 09:07:27.339061	7d95a11a-0c96-461b-8991-f20b6bbbb56b	e31a57a3-8428-4fc8-9184-c3be2aa43284	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
b5bca0d7-bf92-46d7-bf70-6c4972a54952	\N	2023-07-26 09:07:25.383399	2023-07-26 09:07:27.345348	2023-07-26 09:07:25.298553	2023-07-26 09:07:27.345396	7d95a11a-0c96-461b-8991-f20b6bbbb56b	d9350252-0814-4d82-8a73-1d6cd92fae2a	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
e31e68b8-e35b-4c71-8db6-3d5771213484	1	2023-07-26 09:07:25.381945	2023-07-26 09:07:27.418313	2023-07-26 09:07:25.269739	2023-07-26 09:07:27.418353	7d95a11a-0c96-461b-8991-f20b6bbbb56b	c7af9ab3-bf59-4a19-956f-beb50572f1bc	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
cf0da9f9-ae74-455a-a211-bc76f0681b89	1	2023-07-26 09:07:25.38215	2023-07-26 09:07:27.435935	2023-07-26 09:07:25.315278	2023-07-26 09:07:27.435991	7d95a11a-0c96-461b-8991-f20b6bbbb56b	a6e95482-b34c-4e44-a8af-e5cdce431233	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
f95d4a4d-f69c-4be9-8953-472d77aeb963	1	2023-07-26 09:07:42.022765	2023-07-26 09:07:43.376902	2023-07-26 09:07:41.911271	2023-07-26 09:07:43.37694	7d95a11a-0c96-461b-8991-f20b6bbbb56b	246db237-4a7b-40e9-aa6f-6329e3205a93	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
35a56081-cc45-4446-8427-731c4cbabbd6	0	2023-07-27 06:39:00.495821	2023-07-27 06:39:01.66793	2023-07-27 06:39:00.386406	2023-07-27 06:39:01.670071	7d95a11a-0c96-461b-8991-f20b6bbbb56b	111402fe-0f83-4665-8ff4-c8ffbd16e072	5858e087-3514-4986-98b9-74bd2bf3e73d	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
5e7348ac-96d6-4d83-a9b9-b8f4cf35aa4e	1	2023-07-26 09:26:56.820508	2023-07-26 09:26:58.170955	2023-07-26 09:26:56.705596	2023-07-26 09:26:58.171014	7d95a11a-0c96-461b-8991-f20b6bbbb56b	4657f833-23d0-4d81-92ba-d60aee942b19	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
616a5f9c-f573-48d0-b8a4-1cdd987f4310	1	2023-07-27 06:27:08.570994	2023-07-27 06:27:09.889328	2023-07-27 06:27:08.454927	2023-07-27 06:27:09.889365	7d95a11a-0c96-461b-8991-f20b6bbbb56b	23f855e1-770a-41f7-a33c-e85e102cf913	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
f96de5b0-b415-43b5-89aa-8c24cee39b35	1	2023-07-26 09:34:48.449769	2023-07-26 09:34:49.818935	2023-07-26 09:34:48.339756	2023-07-26 09:34:49.818968	7d95a11a-0c96-461b-8991-f20b6bbbb56b	e4081bbc-e64f-44f7-8117-46b91ebed1be	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
ef5f7f1e-9a8d-47c0-bd0b-6c4863948189	1	2023-07-26 09:46:03.35888	2023-07-26 09:46:04.631456	2023-07-26 09:46:03.250201	2023-07-26 09:46:04.631486	7d95a11a-0c96-461b-8991-f20b6bbbb56b	25545201-992f-4163-b937-635918c2bb97	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
75c3ea23-d765-47cc-b346-0fc2dcc17943	1	2023-07-27 06:28:05.066731	2023-07-27 06:28:06.332895	2023-07-27 06:28:04.952434	2023-07-27 06:28:06.332927	7d95a11a-0c96-461b-8991-f20b6bbbb56b	1d58ddbe-d555-426b-8e3d-9009fd041b9d	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
9168922c-29b0-46e5-9294-61b6224d581b	\N	2023-07-27 06:40:18.269145	2023-07-27 06:40:19.17047	2023-07-27 06:40:18.158219	2023-07-27 06:40:19.170511	7d95a11a-0c96-461b-8991-f20b6bbbb56b	0112f43d-47af-4914-8d47-e32a26bb751e	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
09354671-020c-45d2-a50a-0bc4c165ca69	0	2023-07-27 06:29:09.216676	2023-07-27 06:29:10.587619	2023-07-27 06:29:09.107833	2023-07-27 06:29:10.590327	7d95a11a-0c96-461b-8991-f20b6bbbb56b	968f9b3d-b816-4b78-840a-32be384931fe	0ae8cf42-f074-4a77-b3f6-ccd6b7056026	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
3f6bd877-f76b-4dc8-978f-d95eb315050c	1	2023-07-27 06:31:07.132212	2023-07-27 06:31:08.440522	2023-07-27 06:31:07.022995	2023-07-27 06:31:08.44056	7d95a11a-0c96-461b-8991-f20b6bbbb56b	63d31d49-944d-4629-8d74-3fc71b2d33b4	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
4b80b600-9df9-4d26-a0c2-fd58e3cbce27	0	2023-07-27 06:47:07.389943	2023-07-27 06:47:08.282039	2023-07-27 06:47:07.280978	2023-07-27 06:47:08.28478	7d95a11a-0c96-461b-8991-f20b6bbbb56b	cad9851c-c7fe-488f-afc9-2b1b78f71f83	98b338af-605d-4773-84fb-76a79580c6e8	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
f7fcb9e2-ca77-4f23-8ef5-810e672a089c	1	2023-07-27 06:32:05.630387	2023-07-27 06:32:06.929858	2023-07-27 06:32:05.518439	2023-07-27 06:32:06.92989	7d95a11a-0c96-461b-8991-f20b6bbbb56b	97a4fce1-faae-471e-acd7-9b60fd07d53c	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
16b6bd09-1021-4c04-80cd-48ec60a79296	\N	2023-07-27 06:40:29.359739	2023-07-27 06:40:30.26441	2023-07-27 06:40:29.247315	2023-07-27 06:40:30.26446	7d95a11a-0c96-461b-8991-f20b6bbbb56b	6a78b60f-fc3d-43b4-be6d-334a3de33069	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
413bee69-1f6a-4d93-978d-a3bf5d47fae2	1	2023-07-27 06:35:06.028426	2023-07-27 06:35:07.167064	2023-07-27 06:35:05.918684	2023-07-27 06:35:07.167119	7d95a11a-0c96-461b-8991-f20b6bbbb56b	c0c11afd-5975-4feb-9f96-8417035608e6	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
51067e57-1241-4e0b-9c45-cad9f3dc89a4	0	2023-07-27 06:43:59.86737	2023-07-27 06:44:00.755322	2023-07-27 06:43:59.760385	2023-07-27 06:44:00.757764	7d95a11a-0c96-461b-8991-f20b6bbbb56b	15f9abfc-e10a-42b8-b658-65d92187e68c	5bccbdeb-5ac6-487b-af79-5479b64110a9	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
af5a1459-282d-457f-ae73-d3cc13835212	\N	2023-07-27 06:40:48.138937	2023-07-27 06:40:49.099213	2023-07-27 06:40:48.030155	2023-07-27 06:40:49.099273	7d95a11a-0c96-461b-8991-f20b6bbbb56b	fc97f298-cecd-48e3-a61e-647409de18b4	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
c645bcc4-bca9-4de3-9834-c6f4339e606b	\N	2023-07-27 06:41:05.016418	2023-07-27 06:41:05.9378	2023-07-27 06:41:04.905515	2023-07-27 06:41:05.937853	7d95a11a-0c96-461b-8991-f20b6bbbb56b	ab157d1f-4488-4e3e-8019-5cd77423c4fd	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
ebeb3d1d-e4cf-4205-9a34-dc823623aad5	\N	2023-07-27 06:44:30.64885	2023-07-27 06:44:31.536161	2023-07-27 06:44:30.540192	2023-07-27 06:44:31.536194	7d95a11a-0c96-461b-8991-f20b6bbbb56b	e8301efc-2c3d-4e82-bd0e-1df2fd5d56f4	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
873c058c-fe77-4d26-933c-12e281fa6abd	0	2023-07-27 06:41:40.383198	2023-07-27 06:41:41.290094	2023-07-27 06:41:40.26903	2023-07-27 06:41:41.292737	7d95a11a-0c96-461b-8991-f20b6bbbb56b	56831b4c-4cd6-4381-ac4a-93dd34904ee6	9f85cc9b-e0e4-49c9-8542-86c72ea9cfe6	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
a2b3cd73-7b1a-45cc-a0cc-23006cc88c09	\N	2023-07-27 06:50:21.642513	2023-07-27 06:50:22.587388	2023-07-27 06:50:21.533334	2023-07-27 06:50:22.587425	7d95a11a-0c96-461b-8991-f20b6bbbb56b	2f786c50-b7f4-40b1-82b3-a76e91b3f4ac	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
571c80f8-2c20-446d-b43e-225bf222480a	0	2023-07-27 06:50:00.722291	2023-07-27 06:50:01.628756	2023-07-27 06:50:00.607667	2023-07-27 06:50:01.630865	7d95a11a-0c96-461b-8991-f20b6bbbb56b	d3242a13-2739-47bc-9a9d-f81d62e0083d	04d6a1ec-de01-4e94-92a8-48ea01ee1438	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
03a5486d-7217-4aa9-92ec-73253c18c425	0	2023-07-27 06:46:04.340974	2023-07-27 06:46:05.626979	2023-07-27 06:46:04.226805	2023-07-27 06:46:05.629316	7d95a11a-0c96-461b-8991-f20b6bbbb56b	1281f619-965e-46c9-bbea-fd9f152687e7	ebd700e5-3d10-42ef-8bfd-1b2431311cff	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
0a2dcc90-6073-45f9-bb0d-e35b41ff96ef	0	2023-07-27 06:47:34.659746	2023-07-27 06:47:35.629787	2023-07-27 06:47:34.54603	2023-07-27 06:47:35.63223	7d95a11a-0c96-461b-8991-f20b6bbbb56b	e7f80ab2-5de4-4492-9855-ec7dd7203aea	bbc387ef-e036-4a1f-b669-aaffad714992	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
08a52546-820a-46c4-970e-47c864ad374d	0	2023-07-27 06:48:28.566642	2023-07-27 06:48:29.450208	2023-07-27 06:48:28.452537	2023-07-27 06:48:29.45253	7d95a11a-0c96-461b-8991-f20b6bbbb56b	422f0483-3183-45fa-ac6f-b03cb4429545	61d9d605-ff0b-4bb0-a015-fe8d3d2a006a	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
44c8e46b-79f6-47f0-834f-7e2866a83783	\N	2023-07-27 06:51:28.3672	2023-07-27 06:51:29.266862	2023-07-27 06:51:28.249694	2023-07-27 06:51:29.266902	7d95a11a-0c96-461b-8991-f20b6bbbb56b	f4f57b0c-0a7e-4297-ab5a-79ae08143807	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
56c8bf73-9c74-4205-a6f9-ec481010c122	1	2023-07-27 06:54:53.53334	2023-07-27 06:54:54.440941	2023-07-27 06:54:53.417171	2023-07-27 06:54:54.440972	7d95a11a-0c96-461b-8991-f20b6bbbb56b	f44ea5b5-a40d-4e3a-8766-46648b221154	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
94424bee-028f-4448-ae84-b315d7a181fe	1	2023-07-27 06:57:03.240922	2023-07-27 06:57:04.169379	2023-07-27 06:57:03.126774	2023-07-27 06:57:04.169417	7d95a11a-0c96-461b-8991-f20b6bbbb56b	9499a0c0-00e1-45fa-928c-475288dd8d30	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
c03b645b-7660-4ccf-a855-89d49e29e125	0	2023-07-27 06:58:40.732198	2023-07-27 06:58:41.642056	2023-07-27 06:58:40.615952	2023-07-27 06:58:41.644703	7d95a11a-0c96-461b-8991-f20b6bbbb56b	3ac52328-b3d8-482a-a3f8-cef102b98aea	843a372f-7368-4e0c-802d-dcdd0da5d66c	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
6de864c8-2183-4c39-acb6-85ff285a7321	\N	2023-07-27 07:13:49.337361	2023-07-27 07:13:50.246899	2023-07-27 07:13:49.227586	2023-07-27 07:13:50.246935	7d95a11a-0c96-461b-8991-f20b6bbbb56b	3ac52328-b3d8-482a-a3f8-cef102b98aea	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
2a8b8c20-6a06-4a86-8f53-01256d256e51	0	2023-07-27 07:14:33.612697	2023-07-27 07:14:34.522455	2023-07-27 07:14:33.495948	2023-07-27 07:14:34.528313	7d95a11a-0c96-461b-8991-f20b6bbbb56b	71a37a73-4c59-42fc-9224-a53ca4fa967b	4b298224-cd02-45e1-84c8-5bef751f322f	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
b62992fe-9021-410b-9f81-a6da3455cc58	0	2023-07-27 07:15:04.977624	2023-07-27 07:15:05.850171	2023-07-27 07:15:04.861999	2023-07-27 07:15:05.8531	7d95a11a-0c96-461b-8991-f20b6bbbb56b	788e3ec2-6525-48e1-ab49-74c30d3a1372	faf77639-afef-4c77-899e-d6903bcbd2d7	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
9a0990a8-c786-42f0-af2d-fe9198d2bcfa	0	2023-07-27 07:27:20.180593	2023-07-27 07:27:21.079146	2023-07-27 07:27:20.07153	2023-07-27 07:27:21.081307	7d95a11a-0c96-461b-8991-f20b6bbbb56b	ab8a90f7-354d-4954-a28f-8941ff01be1c	b4a2cd35-30f3-4069-a51e-445476d11016	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
347f3570-09ef-4be5-b2df-ff08a8995417	\N	2023-07-27 07:15:40.149504	2023-07-27 07:15:41.082988	2023-07-27 07:15:40.033972	2023-07-27 07:15:41.083031	7d95a11a-0c96-461b-8991-f20b6bbbb56b	fb222e36-ea28-403b-aa78-0424354d2582	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
0f8be2e3-f7f5-45c8-8afb-92feb5d346f6	\N	2023-07-27 07:15:58.291007	2023-07-27 07:15:59.196354	2023-07-27 07:15:58.176766	2023-07-27 07:15:59.196401	7d95a11a-0c96-461b-8991-f20b6bbbb56b	f2f3aede-5f82-4648-a417-b1dbbc12fae6	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
07834ac1-5493-4e68-ad2d-cd6f32b07cb3	0	2023-07-27 07:16:17.492168	2023-07-27 07:16:18.391407	2023-07-27 07:16:17.377058	2023-07-27 07:16:18.393796	7d95a11a-0c96-461b-8991-f20b6bbbb56b	4fe82e58-1836-41d7-becd-adad581bab31	6f3fe41f-d35a-4c62-8263-c17be96af394	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
2525b5d3-be12-4e41-af8d-bdc71398c135	0	2023-07-27 07:18:57.089339	2023-07-27 07:18:57.992868	2023-07-27 07:18:56.974087	2023-07-27 07:18:57.995359	7d95a11a-0c96-461b-8991-f20b6bbbb56b	1261f8ef-2969-4f3b-8a2b-7a75ad7b6f49	a7beabd5-643f-42b7-9fb6-58e2e40e45e9	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
0635b4ce-5126-444e-8e67-204e0575e655	1	2023-07-27 07:38:21.540811	2023-07-27 07:38:22.457209	2023-07-27 07:38:21.431394	2023-07-27 07:38:22.457242	7d95a11a-0c96-461b-8991-f20b6bbbb56b	0eddd5e2-6879-45d8-ae8f-30d05208063c	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
48a9eb7e-9295-4e3d-9db4-189a8e5ddd59	\N	2023-07-27 07:19:37.185897	2023-07-27 07:19:38.088665	2023-07-27 07:19:37.06719	2023-07-27 07:19:38.088698	7d95a11a-0c96-461b-8991-f20b6bbbb56b	ad0c2f39-4df0-4ab8-a372-870eec8d5115	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
3d4f3844-2746-4138-82fa-cb1ce19e9c2c	0	2023-07-27 07:25:43.264952	2023-07-27 07:25:44.14147	2023-07-27 07:25:43.150874	2023-07-27 07:25:44.143763	7d95a11a-0c96-461b-8991-f20b6bbbb56b	4cde9edf-64a3-462b-968e-f95a5c4e1421	6df209ce-7a4c-4611-a9b6-c6528f77f19d	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
9af1e6bb-a703-4677-ad6c-bb193493555f	0	2023-07-27 07:25:57.186888	2023-07-27 07:25:58.061883	2023-07-27 07:25:57.079383	2023-07-27 07:25:58.064238	7d95a11a-0c96-461b-8991-f20b6bbbb56b	46036534-820d-4570-acfe-7c72654f1c84	597ce2d2-b80c-4c38-92de-89bc7ca4739b	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
e7dd3111-d532-4664-a61a-2f37f5c5bac5	0	2023-07-27 07:38:51.335988	2023-07-27 07:38:52.259969	2023-07-27 07:38:51.227725	2023-07-27 07:38:52.262477	7d95a11a-0c96-461b-8991-f20b6bbbb56b	e488206a-ff3e-441a-845a-13a5aafcb7da	7ce59dd0-2126-4f99-9300-9ec81799c099	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
9c49f307-53dd-47e7-9f93-c6aae3dacc66	0	2023-07-27 07:26:57.475701	2023-07-27 07:26:58.370316	2023-07-27 07:26:57.358859	2023-07-27 07:26:58.373533	7d95a11a-0c96-461b-8991-f20b6bbbb56b	627f535f-58b8-4ef4-92f3-b2e3fc48ff73	9f90f92b-4fb0-44e5-9525-7eb7fd02c745	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
98fe1df9-7f6c-4f66-995c-eaa7e9267781	0	2023-07-27 08:17:38.197957	2023-07-27 08:17:39.128392	2023-07-27 08:17:38.089842	2023-07-27 08:17:39.131016	7d95a11a-0c96-461b-8991-f20b6bbbb56b	ee7af87d-a24a-4282-a63d-b31efc420805	a87add1a-422b-44d7-90bd-a31949386114	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
116d76b9-4626-407d-aff2-95fab7dfc76d	0	2023-07-27 07:27:18.63949	2023-07-27 07:27:19.542569	2023-07-27 07:27:18.520803	2023-07-27 07:27:19.545114	7d95a11a-0c96-461b-8991-f20b6bbbb56b	d95bbcab-f155-41ed-abcb-d10dc54155b1	f5732cb8-ac08-485b-938d-862c865bd04d	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
f41251f7-3dc4-4b21-b014-54d24e6dc14d	0	2023-07-27 07:47:03.729621	2023-07-27 07:47:04.614653	2023-07-27 07:47:03.621608	2023-07-27 07:47:04.617197	7d95a11a-0c96-461b-8991-f20b6bbbb56b	ecdf414f-ce82-4f16-8b7e-3db130c3c060	79718ba4-be63-4b29-95e2-82bb11d3ec26	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
f6f165d0-6782-4687-b3c0-1c54c54761f1	0	2023-07-27 07:28:10.158576	2023-07-27 07:28:11.081504	2023-07-27 07:28:10.041709	2023-07-27 07:28:11.084115	7d95a11a-0c96-461b-8991-f20b6bbbb56b	f7d23a77-8e7c-42f8-941d-b42c57820b9a	ea8c1518-3f21-4f59-a3db-a1853bbc40eb	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
a3e076f3-5493-4101-bf28-12c477a49ca2	0	2023-07-27 07:28:39.075912	2023-07-27 07:28:39.998646	2023-07-27 07:28:38.962823	2023-07-27 07:28:40.00099	7d95a11a-0c96-461b-8991-f20b6bbbb56b	c3c0ac32-57be-4403-9870-6f6132c51431	124c9a6c-4597-459c-8b66-bf7f427e1efb	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
0f4fbff2-8435-479f-859c-c5b3a7fbd109	1	2023-07-27 07:48:15.981891	2023-07-27 07:48:17.122128	2023-07-27 07:48:15.872374	2023-07-27 07:48:17.122159	7d95a11a-0c96-461b-8991-f20b6bbbb56b	ab3d146b-3f6d-4848-ab15-bdd78564ebe7	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
4cc8c32e-4130-4906-bff9-f1bf32479227	0	2023-07-27 07:28:56.461856	2023-07-27 07:28:57.343164	2023-07-27 07:28:56.347022	2023-07-27 07:28:57.345677	7d95a11a-0c96-461b-8991-f20b6bbbb56b	7397ea77-b144-431a-93cd-04a662f084ae	16b6f3df-e115-41a3-b855-3e557a902ac4	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
0068cb28-8d1d-48e0-b9aa-3e46a30a0f35	0	2023-07-27 08:31:43.760314	2023-07-27 08:31:44.661353	2023-07-27 08:31:43.651372	2023-07-27 08:31:44.663926	7d95a11a-0c96-461b-8991-f20b6bbbb56b	6333afdc-ed9f-410e-947d-78eff17cd202	ed99ad91-c235-4b26-9cbb-dcea146d1f57	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
912a8914-a8f9-4d87-9cae-f01fa6ded47d	0	2023-07-27 08:18:22.025933	2023-07-27 08:18:22.904584	2023-07-27 08:18:21.918647	2023-07-27 08:18:22.906881	7d95a11a-0c96-461b-8991-f20b6bbbb56b	7aaf0128-e73e-4b89-9b0e-60e31c47ccad	4d6e9237-8519-4226-8a65-435e933fc8d8	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
07296471-5dd5-4c18-9a94-5faaf9694baa	0	2023-07-27 07:30:21.714956	2023-07-27 07:30:22.650885	2023-07-27 07:30:21.599256	2023-07-27 07:30:22.654227	7d95a11a-0c96-461b-8991-f20b6bbbb56b	62341c84-c6ed-4fbc-879c-8b1371ef84b0	5b1380ec-c18f-4787-9ce8-d19ea4ec1e4c	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
063e85d3-c988-4b58-8655-dcd6fd654058	0	2023-07-27 07:49:09.578266	2023-07-27 07:49:10.935501	2023-07-27 07:49:09.465708	2023-07-27 07:49:10.937873	7d95a11a-0c96-461b-8991-f20b6bbbb56b	9b3779e6-16ef-4205-89ef-7ffc63033e8d	d446ff6f-28a2-4286-aa3c-1ed5a0b027d5	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
b9e29cb2-cc4f-4899-8c7d-0a7e494855d8	0	2023-07-27 07:30:39.249556	2023-07-27 07:30:40.1381	2023-07-27 07:30:39.141296	2023-07-27 07:30:40.140489	7d95a11a-0c96-461b-8991-f20b6bbbb56b	f43fd26f-3788-4384-844c-684882b9e930	7ef76446-c1c7-4c36-81cf-1747157b3ce2	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
bbdbbfd3-3b3a-40f7-8fe9-0c26a16b20dd	0	2023-07-27 07:31:08.172571	2023-07-27 07:31:09.058191	2023-07-27 07:31:08.061951	2023-07-27 07:31:09.060953	7d95a11a-0c96-461b-8991-f20b6bbbb56b	182320ba-34ab-445e-b431-73e7ee0c1d1e	7ed4af85-7e73-4862-9a51-cb90e91ab804	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
6760597c-7723-4624-abf6-600f4c53e804	0	2023-07-27 07:51:35.412636	2023-07-27 07:51:36.762219	2023-07-27 07:51:35.30422	2023-07-27 07:51:36.764744	7d95a11a-0c96-461b-8991-f20b6bbbb56b	f52f7b3c-73cb-4b78-84c2-365f90567525	99dada66-0667-4bce-b3c4-5b34c590657b	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
6dca7fdc-ccda-48ee-9f0a-a27c411d6367	1	2023-07-27 07:33:49.283151	2023-07-27 07:33:50.203374	2023-07-27 07:33:49.174186	2023-07-27 07:33:50.203416	7d95a11a-0c96-461b-8991-f20b6bbbb56b	43ca4f8b-7530-4279-aaf8-b6df3a184965	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
aeefbf25-7b33-497d-82c1-1015ab3460a0	1	2023-07-27 08:22:01.525878	2023-07-27 08:22:02.3917	2023-07-27 08:22:01.416776	2023-07-27 08:22:02.391736	7d95a11a-0c96-461b-8991-f20b6bbbb56b	5686b70e-5dca-46f5-af6f-f5d62d68554b	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
c75d4615-b0e4-459f-8e93-26dd3dd9108f	0	2023-07-27 07:34:19.302066	2023-07-27 07:34:20.239769	2023-07-27 07:34:19.193061	2023-07-27 07:34:20.242162	7d95a11a-0c96-461b-8991-f20b6bbbb56b	677766cb-edcb-4aa7-880e-4d3cac3662f8	62d66898-70e2-4434-a50c-51bffc9fad87	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
ce4fd870-2c2d-4c6a-81eb-0839adbef749	1	2023-07-27 08:08:03.592233	2023-07-27 08:08:04.916184	2023-07-27 08:08:03.483118	2023-07-27 08:08:04.916218	7d95a11a-0c96-461b-8991-f20b6bbbb56b	50ab367f-e516-4660-9a49-e990a857055f	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
feefa70b-b633-410c-8e70-ed26c19a6e3f	1	2023-07-27 08:12:22.672352	2023-07-27 08:12:23.540969	2023-07-27 08:12:22.563527	2023-07-27 08:12:23.541	7d95a11a-0c96-461b-8991-f20b6bbbb56b	abb0bff1-8c35-4245-8795-dd7ce3064f85	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
b6a9fddf-0de0-4571-8e03-5fa1e3b31ce0	0	2023-07-27 08:53:00.716564	2023-07-27 08:53:01.60729	2023-07-27 08:53:00.608453	2023-07-27 08:53:01.60975	7d95a11a-0c96-461b-8991-f20b6bbbb56b	0238eb16-6646-4617-8c0c-4465d4d220e6	c6f846f6-7188-4e70-8464-4122dec45e21	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
4998acfe-f9a9-490f-8156-6072366471db	\N	2023-07-27 08:13:25.140966	2023-07-27 08:13:26.033439	2023-07-27 08:13:25.03154	2023-07-27 08:13:26.033484	7d95a11a-0c96-461b-8991-f20b6bbbb56b	79bc61d7-e699-4959-9a31-12d8680e448b	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
dc08a046-cf68-45c9-b092-86042ecb7095	1	2023-07-27 08:24:22.989679	2023-07-27 08:24:23.901396	2023-07-27 08:24:22.878297	2023-07-27 08:24:23.901432	7d95a11a-0c96-461b-8991-f20b6bbbb56b	73258b70-d859-4076-9e27-720dd66e0f97	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
a8bd8484-69dc-47e0-acf5-b5dbd3ff2f99	0	2023-07-27 08:14:45.706915	2023-07-27 08:14:46.572068	2023-07-27 08:14:45.595862	2023-07-27 08:14:46.575009	7d95a11a-0c96-461b-8991-f20b6bbbb56b	8e78c335-4d8e-41c1-a534-dc3312c019af	84cbe25b-fba6-4475-8372-06ccda9fb247	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
ea2a4f7d-e4d3-4625-a787-26dc9618c349	\N	2023-07-27 08:15:23.155852	2023-07-27 08:15:24.078056	2023-07-27 08:15:23.045955	2023-07-27 08:15:24.07809	7d95a11a-0c96-461b-8991-f20b6bbbb56b	1296f035-ac2a-46e8-8227-1189603d077a	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
2269ac9d-ded7-4813-893c-4a24df1560ba	0	2023-07-27 08:34:07.656712	2023-07-27 08:34:08.555418	2023-07-27 08:34:07.549145	2023-07-27 08:34:08.558209	7d95a11a-0c96-461b-8991-f20b6bbbb56b	fdf727bc-42db-42ac-8fdb-7f3b73e85ff5	7dd1fced-6b00-4e02-9b82-577ae7e2794d	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
2f0cc66d-7372-4e98-b553-22b1537a783f	0	2023-07-27 08:24:46.505473	2023-07-27 08:24:47.419143	2023-07-27 08:24:46.396157	2023-07-27 08:24:47.42148	7d95a11a-0c96-461b-8991-f20b6bbbb56b	86f00d0e-5a27-4c8e-9102-d40ad934b138	93254576-e038-4872-8289-74d6dcff2f6f	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
53eab82b-fc96-4f59-8bc4-00a777a5894d	1	2023-07-27 08:26:46.778097	2023-07-27 08:26:47.621693	2023-07-27 08:26:46.670032	2023-07-27 08:26:47.621724	7d95a11a-0c96-461b-8991-f20b6bbbb56b	112b53b4-eff6-4bd0-9fd6-6cfff76edc6c	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
46622a53-3638-4674-991c-1e78b9c425ae	1	2023-07-27 08:49:08.830584	2023-07-27 08:49:09.69416	2023-07-27 08:49:08.721745	2023-07-27 08:49:09.694192	7d95a11a-0c96-461b-8991-f20b6bbbb56b	4d64e972-c47e-429c-8341-68857626f583	\N	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
034ce120-b21c-4dac-a412-4ccf0744192c	0	2023-07-27 08:31:04.950391	2023-07-27 08:31:05.847728	2023-07-27 08:31:04.842098	2023-07-27 08:31:05.851012	7d95a11a-0c96-461b-8991-f20b6bbbb56b	fd9b7303-05cd-42a4-8fab-c9c0697646d3	117101fa-ab8c-4cc2-8d39-0b9d91940db0	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
d80b9880-0447-41c5-bf7c-3ed047767ed1	0	2023-07-27 08:49:49.914311	2023-07-27 08:49:50.818196	2023-07-27 08:49:49.806052	2023-07-27 08:49:50.820934	7d95a11a-0c96-461b-8991-f20b6bbbb56b	6269d2c0-b4ee-4600-94d2-bec0fa157e95	f1f938c6-6d46-4273-afbc-6183e28b3836	\N	5d568db2-1ee9-4dc7-9d1a-99e7fd0c5384
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
ee8127a3-0d1c-43f1-9cbd-a7b74ff33582	\N	\N	2023-07-25 06:22:31	2023-07-25 06:22:31	\N	webhook	\N	4a22a2f6-06ff-4035-96f9-5f607b371b99
\.


--
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tokens (id, user_id, token, context, sent_to, inserted_at, last_used_at) FROM stdin;
5a0526e8-b2ca-40ec-96a5-f402e8e93792	3476f7a9-e02f-4a3d-bc1f-ae3374a882ac	\\xf278d34749429431dee4f71017c14887234dabf58e639f4d55717baae2b2cc23	session	\N	2023-07-25 06:21:02	\N
f4736371-6196-4db7-9e0b-d1297cca23ac	3476f7a9-e02f-4a3d-bc1f-ae3374a882ac	\\x04091ca5cfd6a40c5d026196513a8b958d50d454600b4f2841b6586746950ecb	session	\N	2023-07-31 06:23:42	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, first_name, last_name, email, hashed_password, confirmed_at, inserted_at, updated_at, role, disabled, scheduled_deletion) FROM stdin;
3476f7a9-e02f-4a3d-bc1f-ae3374a882ac	Mahao	Molise	test@mail.com	$2b$12$gZYSwYdvcfh.vhGxBF4Useq8pJ71ALe5cPN1yiJo8Clwev9qY.3Sq	\N	2023-07-25 06:21:02	2023-07-25 06:21:02	superuser	f	\N
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_orders (id, workflow_id, reason_id, inserted_at, updated_at) FROM stdin;
b5ecbcc2-db15-40cd-a9d8-00bedbb26b82	4a22a2f6-06ff-4035-96f9-5f607b371b99	0d742fec-f283-47c9-9dec-e86e47ea8304	2023-07-25 06:29:25	2023-07-25 06:29:25
6dc5422e-17ec-4012-9325-8b3ee68ad38b	4a22a2f6-06ff-4035-96f9-5f607b371b99	c2bc616a-322c-4a29-899b-ed523ad90ed2	2023-07-25 06:30:08	2023-07-25 06:30:08
4740b990-10b8-4391-8239-9356c242e4da	4a22a2f6-06ff-4035-96f9-5f607b371b99	d8fcbd5d-296f-4618-96bd-158935cf37b6	2023-07-26 05:46:01	2023-07-26 05:46:01
9fad25ce-f782-4de2-92bf-1824f5975a72	4a22a2f6-06ff-4035-96f9-5f607b371b99	a12c0063-2a0d-4d7b-b52f-f0dee3f0686f	2023-07-26 05:48:05	2023-07-26 05:48:05
be100a28-bdac-4e71-b0e5-8d6e20ef69e2	4a22a2f6-06ff-4035-96f9-5f607b371b99	91de8e96-8078-4845-a851-e8e9d7bcc544	2023-07-26 05:49:21	2023-07-26 05:49:21
1a859c19-7fee-450d-aa58-40606812a50e	4a22a2f6-06ff-4035-96f9-5f607b371b99	9d7566f3-ad99-454d-8d64-dac4200b9ffc	2023-07-26 05:49:32	2023-07-26 05:49:32
514e6562-55c3-4d79-b190-0592affc6bdb	4a22a2f6-06ff-4035-96f9-5f607b371b99	d5edcdbc-bd45-4223-888f-0f85050ec715	2023-07-26 05:51:34	2023-07-26 05:51:34
d65ef4cc-e871-401b-8a3b-f1a2789e46c7	4a22a2f6-06ff-4035-96f9-5f607b371b99	9a14a552-f11d-49fc-b4a2-5cde676ba923	2023-07-26 05:53:55	2023-07-26 05:53:55
93a89fb7-3d08-49fb-b8c6-0d7604a57720	4a22a2f6-06ff-4035-96f9-5f607b371b99	ff067f1b-b872-4d7e-b7b7-557817261136	2023-07-26 05:56:53	2023-07-26 05:56:53
b8caeff0-269e-495e-8f27-35e6d2fe63e8	4a22a2f6-06ff-4035-96f9-5f607b371b99	7f7ded00-a8e0-48e0-aba8-cbfc00a303f5	2023-07-26 07:58:50	2023-07-26 07:58:50
785d8286-35ad-44a5-85cb-f6385bde997d	4a22a2f6-06ff-4035-96f9-5f607b371b99	54baccef-78d8-465b-8380-2d4df0ab4792	2023-07-26 09:07:25	2023-07-26 09:07:25
80ae92f2-ba40-4de5-a603-8a69b5ebd5ea	4a22a2f6-06ff-4035-96f9-5f607b371b99	50ccca0c-b31c-40c1-a60d-679940aeb7a1	2023-07-26 09:07:25	2023-07-26 09:07:25
cc05cd0f-7fc0-417b-ae89-d32f696ccd7b	4a22a2f6-06ff-4035-96f9-5f607b371b99	7f986400-f591-4d7d-aed7-2690713eb5a5	2023-07-26 09:07:25	2023-07-26 09:07:25
553d3ffb-0f27-4f7f-9667-dcee8c28597e	4a22a2f6-06ff-4035-96f9-5f607b371b99	8e8cbeda-b641-4ab6-94a5-7199a271ad00	2023-07-26 09:07:25	2023-07-26 09:07:25
3b5a3fb7-233b-41da-980d-aeb6f9da6cf3	4a22a2f6-06ff-4035-96f9-5f607b371b99	8d968629-62b2-4b2d-9a75-881bc08e356d	2023-07-26 09:07:25	2023-07-26 09:07:25
8e69461d-774a-4494-984a-5c4f66b1110d	4a22a2f6-06ff-4035-96f9-5f607b371b99	3096e234-b162-4cd9-b392-5949d7c1789d	2023-07-26 09:07:42	2023-07-26 09:07:42
2929b30a-486f-4a54-85f2-eb67e7138b65	4a22a2f6-06ff-4035-96f9-5f607b371b99	17c29e50-4a3b-42f1-a5a5-8c6aa73d404d	2023-07-26 09:26:57	2023-07-26 09:26:57
466a6217-f8ec-4e08-9108-9d458a91c1fe	4a22a2f6-06ff-4035-96f9-5f607b371b99	c4a4b565-0c45-4a67-bff8-dd55828f5405	2023-07-26 09:34:48	2023-07-26 09:34:48
1d5d5db6-d3e4-4087-bc4a-dfcdd288c0f4	4a22a2f6-06ff-4035-96f9-5f607b371b99	bd528715-5e26-4402-91d8-3dd227269bbe	2023-07-26 09:46:03	2023-07-26 09:46:03
bea7762c-0307-4875-8842-491d33d4fdaa	4a22a2f6-06ff-4035-96f9-5f607b371b99	3c61d981-bf45-4914-9830-9bdedfdf6d28	2023-07-26 15:07:50	2023-07-26 15:07:50
5bb0f21f-2795-457d-a76c-0a9461004d8d	4a22a2f6-06ff-4035-96f9-5f607b371b99	96940490-ca82-45e8-b498-21248beb0d0c	2023-07-26 15:14:08	2023-07-26 15:14:08
a522af9f-bd5f-48ab-8c57-45d46d9f529b	4a22a2f6-06ff-4035-96f9-5f607b371b99	5afd3365-e738-4d02-a1d5-c7882e557102	2023-07-26 15:17:48	2023-07-26 15:17:48
b4486eb4-27ce-40c2-b539-071d5bffd294	4a22a2f6-06ff-4035-96f9-5f607b371b99	c9565fc7-c042-4bd7-bce8-b9a9f465ed10	2023-07-27 06:18:05	2023-07-27 06:18:05
cd272489-0778-4b70-aae5-9f54d5a70bbc	4a22a2f6-06ff-4035-96f9-5f607b371b99	20e6552c-0fee-4b0d-8bd0-beaeb2db0c2d	2023-07-27 06:18:14	2023-07-27 06:18:14
6bc87d27-b7e0-4124-a9d7-e23edc55908e	4a22a2f6-06ff-4035-96f9-5f607b371b99	e5bb532b-04c1-4c73-8640-309903a73238	2023-07-27 06:18:47	2023-07-27 06:18:47
9dd205f1-664f-4c66-997f-5b172740f0e9	4a22a2f6-06ff-4035-96f9-5f607b371b99	4815ea2a-ed65-4d06-a634-3e8d990b50ff	2023-07-27 06:27:08	2023-07-27 06:27:08
ff44234e-2b15-4216-9caf-5ee576027546	4a22a2f6-06ff-4035-96f9-5f607b371b99	2c8609f4-899e-4ace-b6c9-d781fbe30f59	2023-07-27 06:28:05	2023-07-27 06:28:05
6ceb7e92-d070-4c22-90a4-8380bf5ed7f4	4a22a2f6-06ff-4035-96f9-5f607b371b99	80acfc3f-064b-4049-bcea-faaab2619c52	2023-07-27 06:29:09	2023-07-27 06:29:09
68f647f9-606b-4f4c-9d4a-1b1b4630ab04	4a22a2f6-06ff-4035-96f9-5f607b371b99	56f48551-d13c-4e7a-8dcf-423678717324	2023-07-27 06:31:07	2023-07-27 06:31:07
adf216af-660b-4f60-a217-87f24138496e	4a22a2f6-06ff-4035-96f9-5f607b371b99	ff7e2ee3-fa46-4546-a0af-7117fa450d78	2023-07-27 06:32:06	2023-07-27 06:32:06
89b3472e-22dc-4565-b48d-e1ff50bffc57	4a22a2f6-06ff-4035-96f9-5f607b371b99	de07949a-55a6-4074-ba30-6b2d8e8523cc	2023-07-27 06:35:06	2023-07-27 06:35:06
3319debb-0dad-4c13-bb60-1ba311076764	4a22a2f6-06ff-4035-96f9-5f607b371b99	6868d4a6-c868-4598-9f08-6cebc5a0fa77	2023-07-27 06:36:49	2023-07-27 06:36:49
5dd0192b-83c0-4779-a2e1-4ba4c0a44cdf	4a22a2f6-06ff-4035-96f9-5f607b371b99	63202682-62b3-48d1-a932-26b843cfafbb	2023-07-27 06:39:00	2023-07-27 06:39:00
d52cfafe-ecdc-45b0-bb4f-f6b4a2be8931	4a22a2f6-06ff-4035-96f9-5f607b371b99	9628f4da-c079-4944-a86e-7a98bb9f9a4a	2023-07-27 06:40:18	2023-07-27 06:40:18
97c499e1-3fe4-4ea0-93dc-8543560b4775	4a22a2f6-06ff-4035-96f9-5f607b371b99	16ead63c-a0d8-4049-af34-68e1d160e4da	2023-07-27 06:40:29	2023-07-27 06:40:29
e8ed8347-67f1-4a4b-97b6-2c7933fb314d	4a22a2f6-06ff-4035-96f9-5f607b371b99	98ed0ae8-70de-4a7b-8fc0-f6c5feca99c7	2023-07-27 06:40:48	2023-07-27 06:40:48
4c1d2de2-51e0-41fe-aa43-9f4fd06b8037	4a22a2f6-06ff-4035-96f9-5f607b371b99	5b7443bf-699a-4213-808c-4e763ad3fb03	2023-07-27 06:41:05	2023-07-27 06:41:05
252bf34c-fb4d-4f5a-ac13-98f6e8734080	4a22a2f6-06ff-4035-96f9-5f607b371b99	89d9eb26-c82e-433d-8443-1deb8b019235	2023-07-27 06:41:40	2023-07-27 06:41:40
2bd0feaa-8981-4163-9821-f02e56eff6d4	4a22a2f6-06ff-4035-96f9-5f607b371b99	f8969fda-9ff4-4729-929f-3c6463b8e15d	2023-07-27 06:42:50	2023-07-27 06:42:50
5478f70b-5c15-4505-b89f-90a0fd5a4e25	4a22a2f6-06ff-4035-96f9-5f607b371b99	b3640cc8-3e38-453d-9731-2e05f15a5a8d	2023-07-27 06:44:00	2023-07-27 06:44:00
fa4d8616-5285-4b2d-943c-5bb4f73b162b	4a22a2f6-06ff-4035-96f9-5f607b371b99	7995e693-b4e1-4e4d-aed5-94b271a2f2cc	2023-07-27 06:44:31	2023-07-27 06:44:31
e3f0a6a9-ca62-4460-bea5-33ba13cee562	4a22a2f6-06ff-4035-96f9-5f607b371b99	0d5f7ec8-d510-40c7-95e4-8f71b0a5170c	2023-07-27 06:46:04	2023-07-27 06:46:04
90d1ecc3-21be-4896-9d7a-4683dc43494b	4a22a2f6-06ff-4035-96f9-5f607b371b99	fec9a645-1767-4e12-8da2-41a0b7e4e20c	2023-07-27 06:47:07	2023-07-27 06:47:07
71123b87-b8e4-4d45-96ae-2e1be433eb01	4a22a2f6-06ff-4035-96f9-5f607b371b99	25f0ef3f-65df-417d-bce4-36f68ac2ac7d	2023-07-27 06:47:35	2023-07-27 06:47:35
08afc029-9579-4806-83f6-b67d8c78ce20	4a22a2f6-06ff-4035-96f9-5f607b371b99	cb5c0d84-2862-4d8c-aab9-f8d23606ea98	2023-07-27 06:48:11	2023-07-27 06:48:11
ecd74208-83a5-4580-87cb-d8d2cb2e1a53	4a22a2f6-06ff-4035-96f9-5f607b371b99	e4a5933e-a677-4a68-9875-9ae16c4f2f1d	2023-07-27 06:48:28	2023-07-27 06:48:28
d15318fe-7aa3-4f8e-9196-392b359c8ac3	4a22a2f6-06ff-4035-96f9-5f607b371b99	0601a2c2-cf25-4b66-a310-4afa23ef387b	2023-07-27 06:50:01	2023-07-27 06:50:01
63685fbd-0a68-4a70-aa6e-6e55ec1e24a9	4a22a2f6-06ff-4035-96f9-5f607b371b99	2e6ccc64-848b-47d3-a5e3-f830fe151b10	2023-07-27 06:50:22	2023-07-27 06:50:22
d29c9269-e564-4771-b2bb-6cccbac8c433	4a22a2f6-06ff-4035-96f9-5f607b371b99	8b774587-0575-4491-b802-ff7a0ab5f727	2023-07-27 06:51:28	2023-07-27 06:51:28
27a5cce9-8899-4836-b665-fd02a59749ca	4a22a2f6-06ff-4035-96f9-5f607b371b99	e2384c72-ca1f-4a5f-af77-d38af9673b9b	2023-07-27 06:54:53	2023-07-27 06:54:53
c3fec4e2-8a9a-4f5a-bf1b-3c240f701cf9	4a22a2f6-06ff-4035-96f9-5f607b371b99	7c717808-a649-4b7e-9396-7c1405b379c8	2023-07-27 06:57:03	2023-07-27 06:57:03
cc90f1c6-f8a7-4f96-a073-ad4e2efe3c1f	4a22a2f6-06ff-4035-96f9-5f607b371b99	809c2742-63c6-493f-99be-a5dd064ca6af	2023-07-27 06:58:41	2023-07-27 06:58:41
41ac5d16-70ab-441e-a03c-3f570e145baa	4a22a2f6-06ff-4035-96f9-5f607b371b99	81a17849-a495-4207-8c27-460a5c48dd6f	2023-07-27 07:13:49	2023-07-27 07:13:49
f69540de-ea59-49cd-9fa2-0787b2faa16c	4a22a2f6-06ff-4035-96f9-5f607b371b99	60c41762-c480-4d4b-a223-533457a8c8e4	2023-07-27 07:14:33	2023-07-27 07:14:33
5c7557c8-439f-43fa-a8c2-b615fe65a578	4a22a2f6-06ff-4035-96f9-5f607b371b99	0669320d-eed4-4d55-b087-7dd61eab4c2f	2023-07-27 07:15:05	2023-07-27 07:15:05
a60a30c4-161d-4374-a9e2-55427b27c71b	4a22a2f6-06ff-4035-96f9-5f607b371b99	3cdf8a5f-6e51-4e2c-b2bc-e2881b277c29	2023-07-27 07:15:40	2023-07-27 07:15:40
42ed8878-bbde-4870-aff1-c73f0b038861	4a22a2f6-06ff-4035-96f9-5f607b371b99	e7894ee8-1b76-4b13-aa20-4a6196ee4840	2023-07-27 07:15:58	2023-07-27 07:15:58
cb3bc7f5-968a-430f-8aff-bd9545c40179	4a22a2f6-06ff-4035-96f9-5f607b371b99	d6a39721-b2ea-4be2-8426-273543bb450a	2023-07-27 07:16:17	2023-07-27 07:16:17
f65aad6a-350b-4f8a-9097-1c0132be1f73	4a22a2f6-06ff-4035-96f9-5f607b371b99	127e2de4-9300-442a-a42e-2a2afb079322	2023-07-27 07:18:57	2023-07-27 07:18:57
39f7166f-1bb0-43c0-bc53-1ad38ba4785e	4a22a2f6-06ff-4035-96f9-5f607b371b99	79d5918c-904f-48d0-8abb-9001a07f6183	2023-07-27 07:19:37	2023-07-27 07:19:37
b97f3034-9d62-435b-942f-4d782c55d248	4a22a2f6-06ff-4035-96f9-5f607b371b99	98e79e63-d8d6-41e3-83e6-8f6b76cf7c57	2023-07-27 07:25:43	2023-07-27 07:25:43
d3ce0d7b-9490-4136-be55-1403fc30e9d2	4a22a2f6-06ff-4035-96f9-5f607b371b99	9d7b421b-50e8-4201-8e91-580b89540a85	2023-07-27 07:25:57	2023-07-27 07:25:57
08f96169-82dc-4954-925e-6dfecccf9478	4a22a2f6-06ff-4035-96f9-5f607b371b99	86b6b3e6-17dc-4ec9-bcf3-55a6f3b6c49e	2023-07-27 07:26:57	2023-07-27 07:26:57
8f8de3b0-8d4f-4735-b826-afa105f4f655	4a22a2f6-06ff-4035-96f9-5f607b371b99	1a25ba43-6b01-4688-8b16-195a8e9f9859	2023-07-27 07:27:19	2023-07-27 07:27:19
35ba402c-8bcb-4dd3-a269-b2e14be0adc9	4a22a2f6-06ff-4035-96f9-5f607b371b99	b548218b-7d2f-46d3-8186-552ca71a2a0d	2023-07-27 07:27:20	2023-07-27 07:27:20
7547c2a3-09b7-4235-a30d-e99598700b5b	4a22a2f6-06ff-4035-96f9-5f607b371b99	ac878ac0-d635-442d-9000-ea4fce52a8a6	2023-07-27 07:28:10	2023-07-27 07:28:10
3dba995b-a6a5-4015-a89c-002f0e6ad87d	4a22a2f6-06ff-4035-96f9-5f607b371b99	7ea1a6ec-082d-4204-b90c-0d01c381848b	2023-07-27 07:28:39	2023-07-27 07:28:39
99975691-d77b-4784-8759-4e0cfaf92b20	4a22a2f6-06ff-4035-96f9-5f607b371b99	917e750d-1690-45c1-9f22-fefddbb4c4fb	2023-07-27 07:28:56	2023-07-27 07:28:56
219c6068-7156-447b-a117-281fb8066ce2	4a22a2f6-06ff-4035-96f9-5f607b371b99	94d64584-6429-41a5-b81f-aeb75742385b	2023-07-27 07:30:22	2023-07-27 07:30:22
c667ea3b-8a9a-4bb8-a6d5-68a0dc73d799	4a22a2f6-06ff-4035-96f9-5f607b371b99	05a73236-0da6-4f4f-82a1-d8d1890e8a24	2023-07-27 07:30:39	2023-07-27 07:30:39
2b85f8df-31cc-45e2-bc4c-7c1bdd6b8656	4a22a2f6-06ff-4035-96f9-5f607b371b99	c48ce525-aebd-4438-a3f5-0b0bc21c3f04	2023-07-27 07:31:08	2023-07-27 07:31:08
f256071d-54a0-4b9c-8561-0f39f47e45b0	4a22a2f6-06ff-4035-96f9-5f607b371b99	638a0a5b-c37b-4e69-be99-63e3615120d1	2023-07-27 07:33:49	2023-07-27 07:33:49
b4ec2bc1-ecf8-40c5-a328-58df83ece7e1	4a22a2f6-06ff-4035-96f9-5f607b371b99	171022ac-75ab-4d23-84aa-4b0dbb189d9c	2023-07-27 07:34:19	2023-07-27 07:34:19
92b3dcc4-18cd-4339-8d0b-01ec63a9e4e9	4a22a2f6-06ff-4035-96f9-5f607b371b99	b9cc5901-8ab7-4eb8-9c3d-be0da796c56f	2023-07-27 07:38:21	2023-07-27 07:38:21
2dcd0769-9d15-45ea-83ce-9c99ab608700	4a22a2f6-06ff-4035-96f9-5f607b371b99	6dc5cb0d-f98f-4bff-b64d-4bb74bf29e57	2023-07-27 07:38:51	2023-07-27 07:38:51
681f06e8-4d32-4cb5-92bb-1eb9515ffe1d	4a22a2f6-06ff-4035-96f9-5f607b371b99	c533b930-1723-4594-8cac-dfb1184e64eb	2023-07-27 07:47:04	2023-07-27 07:47:04
3c07392b-86af-4323-97a5-6a8dcc85e62d	4a22a2f6-06ff-4035-96f9-5f607b371b99	002b5b51-0633-4cd2-b299-2cd315995079	2023-07-27 07:48:16	2023-07-27 07:48:16
344e63b8-c3ca-4e7e-bd82-1e68f880c110	4a22a2f6-06ff-4035-96f9-5f607b371b99	682b2a61-46d5-46bd-81cd-84fe943d8e89	2023-07-27 07:49:09	2023-07-27 07:49:09
d6a23fcd-33b1-4d8f-9f8b-e0ef21ed231c	4a22a2f6-06ff-4035-96f9-5f607b371b99	6b08a7cf-3611-44b6-9f3d-8ee6095f9d83	2023-07-27 07:51:35	2023-07-27 07:51:35
7aada6e3-e354-4c26-b912-f8770d9a7972	4a22a2f6-06ff-4035-96f9-5f607b371b99	dc28c6e0-688f-4f8e-ad61-1ff73bede2af	2023-07-27 08:08:03	2023-07-27 08:08:03
4bf4f273-361f-48ba-99eb-c9e3dbb9010f	4a22a2f6-06ff-4035-96f9-5f607b371b99	156ad6c3-bfe5-4184-92dc-0ad76929e7e0	2023-07-27 08:12:23	2023-07-27 08:12:23
972a50da-40a8-4037-bdb2-0f78cf2458b7	4a22a2f6-06ff-4035-96f9-5f607b371b99	656db25b-99fa-4102-8713-a4fa9d058a4b	2023-07-27 08:13:25	2023-07-27 08:13:25
eb61b56b-1449-4f75-9e29-385b9fa8d240	4a22a2f6-06ff-4035-96f9-5f607b371b99	c5b9e474-f4bc-4c9d-95b1-30c7aa905c2e	2023-07-27 08:14:46	2023-07-27 08:14:46
817310ae-32ce-46e0-82f5-ba7eb4d13f23	4a22a2f6-06ff-4035-96f9-5f607b371b99	a583b766-4d3f-4250-8948-27903ff374c1	2023-07-27 08:15:23	2023-07-27 08:15:23
04e4d0cf-d8ff-4aa3-96ae-8c83ca3d3ce4	4a22a2f6-06ff-4035-96f9-5f607b371b99	79ba2b37-8a90-418f-87f3-c7bcd4b0df46	2023-07-27 08:17:38	2023-07-27 08:17:38
71afb63c-03a1-4aeb-adf0-fba0879e459b	4a22a2f6-06ff-4035-96f9-5f607b371b99	c41b5eca-57e8-4804-ab4d-8eae7b875ab1	2023-07-27 08:18:22	2023-07-27 08:18:22
a8a2a87c-219e-4d9d-8c00-e2de303c998f	4a22a2f6-06ff-4035-96f9-5f607b371b99	d2162ad8-4d5e-4a5c-9c39-d97a2f6996ba	2023-07-27 08:22:01	2023-07-27 08:22:01
86867801-592d-4632-a8d2-77c8f1c1fd6d	4a22a2f6-06ff-4035-96f9-5f607b371b99	18c01c13-6093-49ff-9eaa-70a394715255	2023-07-27 08:24:23	2023-07-27 08:24:23
d849e9cf-dd46-425c-b8d2-bda32374367f	4a22a2f6-06ff-4035-96f9-5f607b371b99	0bcd3348-356b-4058-8f8c-ad28967dce5b	2023-07-27 08:24:46	2023-07-27 08:24:46
d3483d43-612c-42a3-bfc9-fdbc621d3ebe	4a22a2f6-06ff-4035-96f9-5f607b371b99	6e8ccdf6-a8b6-41d7-b0f3-7c665ce0eeed	2023-07-27 08:49:09	2023-07-27 08:49:09
a9614879-5f35-44cc-b392-8c73a8ab8ead	4a22a2f6-06ff-4035-96f9-5f607b371b99	1ec13a34-9c1d-47c0-84d0-0a4bf2c533ce	2023-07-27 08:26:47	2023-07-27 08:26:47
78a1bcf6-e08d-4a50-869f-a062405eb465	4a22a2f6-06ff-4035-96f9-5f607b371b99	d387dd89-e5a8-4b5d-ba61-b4c12d7aed76	2023-07-27 08:31:05	2023-07-27 08:31:05
9f82c0e7-3d7d-4ec5-9cc5-f13961aaf8bd	4a22a2f6-06ff-4035-96f9-5f607b371b99	baea932d-db62-46f6-ac73-baf03907011c	2023-07-27 08:31:44	2023-07-27 08:31:44
333fcb7c-1ae2-44ff-aadd-866d48430f14	4a22a2f6-06ff-4035-96f9-5f607b371b99	6f69396b-f947-45dc-9309-9f1af2743af5	2023-07-27 08:34:08	2023-07-27 08:34:08
d7041627-a98d-4b3c-8945-23831c072f0d	4a22a2f6-06ff-4035-96f9-5f607b371b99	e3ec3fcc-b838-4899-be38-d55a34736de0	2023-07-27 08:49:50	2023-07-27 08:49:50
df32fa60-f53a-4b44-a8e9-2f12e7f8c0f7	4a22a2f6-06ff-4035-96f9-5f607b371b99	11d0d2bb-b50a-415e-92d3-525fdd3cd41e	2023-07-27 08:53:01	2023-07-27 08:53:01
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
4a22a2f6-06ff-4035-96f9-5f607b371b99	late-haze-5584	2023-07-25 06:21:28	2023-07-25 06:21:28	87ea20f1-7d81-4959-bdba-279147713fb8	\N
\.


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oban_jobs_id_seq', 9320, true);


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

