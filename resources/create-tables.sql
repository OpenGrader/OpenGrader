--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.2

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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: pgsodium; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgsodium;


ALTER SCHEMA pgsodium OWNER TO postgres;

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgsodium WITH SCHEMA pgsodium;


--
-- Name: EXTENSION pgsodium; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgsodium IS 'Pgsodium is a modern cryptography library for Postgres.';


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.email', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
	)::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.role', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
	)::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.sub', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
	)::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  schema_is_cron bool;
BEGIN
  schema_is_cron = (
    SELECT n.nspname = 'cron'
    FROM pg_event_trigger_ddl_commands() AS ev
    LEFT JOIN pg_catalog.pg_namespace AS n
      ON ev.objid = n.oid
  );

  IF schema_is_cron
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;

  END IF;

END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_collect_response(request_id bigint, async boolean) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_collect_response(request_id bigint, async boolean) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_collect_response(request_id bigint, async boolean) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_collect_response(request_id bigint, async boolean) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: postgres
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  insert into public."user" (auth_id, email)
  values (new.id, new.email);
  return new;
end;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: install_available_extensions_and_test(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.install_available_extensions_and_test() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE extension_name TEXT;
allowed_extentions TEXT[] := string_to_array(current_setting('supautils.privileged_extensions'), ',');
BEGIN 
  FOREACH extension_name IN ARRAY allowed_extentions 
  LOOP
    SELECT trim(extension_name) INTO extension_name;
    /* skip below extensions check for now */
    CONTINUE WHEN extension_name = 'pgroonga' OR  extension_name = 'pgroonga_database' OR extension_name = 'pgsodium';
    CONTINUE WHEN extension_name = 'plpgsql' OR  extension_name = 'plpgsql_check' OR extension_name = 'pgtap';
    CONTINUE WHEN extension_name = 'supabase_vault' OR extension_name = 'wrappers';
    RAISE notice 'START TEST FOR: %', extension_name;
    EXECUTE format('DROP EXTENSION IF EXISTS %s CASCADE', quote_ident(extension_name));
    EXECUTE format('CREATE EXTENSION %s CASCADE', quote_ident(extension_name));
    RAISE notice 'END TEST FOR: %', extension_name;
  END LOOP;
    RAISE notice 'EXTENSION TESTS COMPLETED..';
    return true;
END;
$$;


ALTER FUNCTION public.install_available_extensions_and_test() OWNER TO postgres;

--
-- Name: is_instructor(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_instructor(uid uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN 'INSTRUCTOR' in (select distinct role from membership where "user" = (select id from "user" where auth_id = uid limit 1));
  END;
   $$;


ALTER FUNCTION public.is_instructor(uid uuid) OWNER TO postgres;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
    select string_to_array(name, '/') into _parts;
    select _parts[array_length(_parts,1)] into _filename;
    -- @todo return the last part instead of 2
    return split_part(_filename, '.', 2);
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[1:array_length(_parts,1)-1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(regexp_split_to_array(objects.name, ''/''), 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(regexp_split_to_array(objects.name, ''/''), 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    from_ip_address inet,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: assignment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assignment (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    section bigint NOT NULL,
    title character varying NOT NULL,
    description text,
    is_open boolean DEFAULT true NOT NULL,
    is_late boolean DEFAULT false NOT NULL,
    input_file text,
    output_file text,
    language text,
    args text
);


ALTER TABLE public.assignment OWNER TO postgres;

--
-- Name: assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.assignment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.assignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    "submission_nano_ID" text,
    name text,
    line_number bigint,
    comment_text text,
    line_content text,
    assignment_id bigint
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: TABLE comments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.comments IS 'Stores instructor comments';


--
-- Name: COLUMN comments.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.name IS 'Stores the name of the commentator.';


--
-- Name: COLUMN comments.line_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.line_number IS 'Stores the commented line number.';


--
-- Name: COLUMN comments.comment_text; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.comment_text IS 'Text that instructor comments';


--
-- Name: COLUMN comments.line_content; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.line_content IS 'The line that was commented on.';


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.comments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    department character varying,
    number character varying
);


ALTER TABLE public.course OWNER TO postgres;

--
-- Name: TABLE course; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.course IS 'contains information about different classes at the course level - i.e. CSCE4110';


--
-- Name: COLUMN course.department; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course.department IS 'four letter string representing the department the course belongs in - like "CSCE"';


--
-- Name: COLUMN course.number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course.number IS 'four digit course number - like "4110"

Why a string? We don''t do numeric options on this, and number types should only be used when that''s the case (think currency). When we''re using something like zip codes, where the numbers _could_ be replaced by letters, we should use strings.';


--
-- Name: course_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.course ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: flag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flag (
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    display_name character varying NOT NULL
);


ALTER TABLE public.flag OWNER TO postgres;

--
-- Name: membership; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.membership (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    "user" bigint NOT NULL,
    section bigint NOT NULL,
    role character varying DEFAULT 'STUDENT'::character varying NOT NULL
);


ALTER TABLE public.membership OWNER TO postgres;

--
-- Name: TABLE membership; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.membership IS 'maps users to sections with their roles';


--
-- Name: membership_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.membership ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.membership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    display_name character varying NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: TABLE role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.role IS 'user types';


--
-- Name: section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.section (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    course bigint NOT NULL,
    section_number character varying
);


ALTER TABLE public.section OWNER TO postgres;

--
-- Name: TABLE section; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.section IS 'contains information about sections of a course';


--
-- Name: section_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.section ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: student_Submission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."student_Submission" (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    "course_ID" bigint NOT NULL,
    "assignment_ID" bigint NOT NULL,
    "file_Name" text NOT NULL,
    "nanoID" text NOT NULL,
    "user_ID" bigint NOT NULL,
    "file_Path" text NOT NULL
);


ALTER TABLE public."student_Submission" OWNER TO postgres;

--
-- Name: TABLE "student_Submission"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."student_Submission" IS 'Table to track user submissions';


--
-- Name: student_Submission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."student_Submission" ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."student_Submission_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: submission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.submission (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    assignment bigint NOT NULL,
    student bigint NOT NULL,
    is_late boolean DEFAULT false NOT NULL,
    score bigint,
    flags character varying[],
    submission_loc text,
    feedback text
);


ALTER TABLE public.submission OWNER TO postgres;

--
-- Name: submission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.submission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: test_cases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_cases (
    assignment_id bigint NOT NULL,
    input_file text,
    case_id bigint NOT NULL,
    output_file text,
    weight bigint
);


ALTER TABLE public.test_cases OWNER TO postgres;

--
-- Name: test_cases_case_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.test_cases ALTER COLUMN case_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.test_cases_case_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    given_name character varying,
    family_name character varying,
    email character varying,
    euid character varying,
    auth_id uuid,
    can_create_class boolean DEFAULT false NOT NULL
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: TABLE "user"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."user" IS 'contains information about students, instructors, graders, TAs';


--
-- Name: COLUMN "user".auth_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."user".auth_id IS 'ID for the user in Supabase authentication';


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."user" ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[]
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (provider, id);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: assignment assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (id);


--
-- Name: flag flag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flag
    ADD CONSTRAINT flag_pkey PRIMARY KEY (name);


--
-- Name: membership membership_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership
    ADD CONSTRAINT membership_pkey PRIMARY KEY ("user", section);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (name);


--
-- Name: section section_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_pkey PRIMARY KEY (id);


--
-- Name: student_Submission student_Submission_nanoID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."student_Submission"
    ADD CONSTRAINT "student_Submission_nanoID_key" UNIQUE ("nanoID");


--
-- Name: student_Submission student_Submission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."student_Submission"
    ADD CONSTRAINT "student_Submission_pkey" PRIMARY KEY ("nanoID");


--
-- Name: submission submission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_pkey PRIMARY KEY (id);


--
-- Name: test_cases test_Cases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_cases
    ADD CONSTRAINT "test_Cases_pkey" PRIMARY KEY (case_id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_token_session_id; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_token_session_id ON auth.refresh_tokens USING btree (session_id);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: assignment assignment_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_section_fkey FOREIGN KEY (section) REFERENCES public.section(id);


--
-- Name: comments comments_submission_nano_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_submission_nano_ID_fkey" FOREIGN KEY ("submission_nano_ID") REFERENCES public."student_Submission"("nanoID") ON DELETE CASCADE;


--
-- Name: membership membership_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership
    ADD CONSTRAINT membership_role_fkey FOREIGN KEY (role) REFERENCES public.role(name);


--
-- Name: membership membership_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership
    ADD CONSTRAINT membership_section_fkey FOREIGN KEY (section) REFERENCES public.section(id);


--
-- Name: membership membership_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership
    ADD CONSTRAINT membership_user_fkey FOREIGN KEY ("user") REFERENCES public."user"(id);


--
-- Name: section section_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_course_fkey FOREIGN KEY (course) REFERENCES public.course(id);


--
-- Name: student_Submission student_Submission_user_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."student_Submission"
    ADD CONSTRAINT "student_Submission_user_ID_fkey" FOREIGN KEY ("user_ID") REFERENCES public."user"(id);


--
-- Name: submission submission_assignment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_assignment_fkey FOREIGN KEY (assignment) REFERENCES public.assignment(id);


--
-- Name: submission submission_student_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_student_fkey FOREIGN KEY (student) REFERENCES public."user"(id);


--
-- Name: test_cases test_cases_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_cases
    ADD CONSTRAINT test_cases_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignment(id) ON DELETE CASCADE;


--
-- Name: user user_auth_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id);


--
-- Name: buckets buckets_owner_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_owner_fkey FOREIGN KEY (owner) REFERENCES auth.users(id);


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: objects objects_owner_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_owner_fkey FOREIGN KEY (owner) REFERENCES auth.users(id);


--
-- Name: assignment Allow Upload; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow Upload" ON public.assignment FOR INSERT WITH CHECK (true);


--
-- Name: role Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.role FOR SELECT USING (true);


--
-- Name: user Enable update for users based on email; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on email" ON public."user" FOR UPDATE USING ((auth.uid() = auth_id)) WITH CHECK ((auth.uid() = auth_id));


--
-- Name: test_cases Enable write access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable write access for all users" ON public.test_cases FOR INSERT WITH CHECK (true);


--
-- Name: membership Instructors may insert into their own classes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Instructors may insert into their own classes" ON public.membership FOR INSERT TO authenticated WITH CHECK ((section IN ( SELECT membership_1.section
   FROM public.membership membership_1
  WHERE ((membership_1."user" = ( SELECT "user".id
           FROM public."user"
          WHERE ("user".auth_id = auth.uid())
         LIMIT 1)) AND ((membership_1.role)::text = 'INSTRUCTOR'::text)))));


--
-- Name: assignment; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.assignment ENABLE ROW LEVEL SECURITY;

--
-- Name: assignment authenticated read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated read" ON public.assignment FOR SELECT TO authenticated USING (true);


--
-- Name: course authenticated read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated read" ON public.course FOR SELECT TO authenticated USING (true);


--
-- Name: membership authenticated read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated read" ON public.membership FOR SELECT TO authenticated USING (true);


--
-- Name: section authenticated read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated read" ON public.section FOR SELECT TO authenticated USING (true);


--
-- Name: submission authenticated read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated read" ON public.submission FOR SELECT TO authenticated USING (true);


--
-- Name: user authenticated read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated read" ON public."user" FOR SELECT TO authenticated USING (true);


--
-- Name: course; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.course ENABLE ROW LEVEL SECURITY;

--
-- Name: flag; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.flag ENABLE ROW LEVEL SECURITY;

--
-- Name: assignment instructor delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "instructor delete" ON public.assignment FOR DELETE USING ((section IN ( SELECT membership_1.section
   FROM public.membership membership_1
  WHERE ((membership_1."user" = ( SELECT "user".id
           FROM public."user"
          WHERE ("user".auth_id = auth.uid())
         LIMIT 1)) AND ((membership_1.role)::text = 'INSTRUCTOR'::text)))));


--
-- Name: section instructor writes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "instructor writes" ON public.section TO authenticated USING ((id IN ( SELECT membership_1.section
   FROM public.membership membership_1
  WHERE ((membership_1."user" = ( SELECT "user".id
           FROM public."user"
          WHERE ("user".auth_id = auth.uid())
         LIMIT 1)) AND ((membership_1.role)::text = 'INSTRUCTOR'::text))))) WITH CHECK ((id IN ( SELECT membership_1.section
   FROM public.membership membership_1
  WHERE ((membership_1."user" = ( SELECT "user".id
           FROM public."user"
          WHERE ("user".auth_id = auth.uid())
         LIMIT 1)) AND ((membership_1.role)::text = 'INSTRUCTOR'::text)))));


--
-- Name: membership instructors can delete from own classes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "instructors can delete from own classes" ON public.membership FOR DELETE TO authenticated USING ((section IN ( SELECT membership_1.section
   FROM public.membership membership_1
  WHERE ((membership_1."user" = ( SELECT "user".id
           FROM public."user"
          WHERE ("user".auth_id = auth.uid())
         LIMIT 1)) AND ((membership_1.role)::text = 'INSTRUCTOR'::text)))));


--
-- Name: membership instructors may update roles within their own class; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "instructors may update roles within their own class" ON public.membership FOR UPDATE TO authenticated USING ((section IN ( SELECT membership_1.section
   FROM public.membership membership_1
  WHERE ((membership_1."user" = ( SELECT "user".id
           FROM public."user"
          WHERE ("user".auth_id = auth.uid())
         LIMIT 1)) AND ((membership_1.role)::text = 'INSTRUCTOR'::text))))) WITH CHECK ((section IN ( SELECT membership_1.section
   FROM public.membership membership_1
  WHERE ((membership_1."user" = ( SELECT "user".id
           FROM public."user"
          WHERE ("user".auth_id = auth.uid())
         LIMIT 1)) AND ((membership_1.role)::text = 'INSTRUCTOR'::text)))));


--
-- Name: membership; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.membership ENABLE ROW LEVEL SECURITY;

--
-- Name: role; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.role ENABLE ROW LEVEL SECURITY;

--
-- Name: section; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.section ENABLE ROW LEVEL SECURITY;

--
-- Name: submission; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.submission ENABLE ROW LEVEL SECURITY;

--
-- Name: test_cases; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.test_cases ENABLE ROW LEVEL SECURITY;

--
-- Name: user; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public."user" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Allow Upload 9la5bd_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Allow Upload 9la5bd_0" ON storage.objects FOR SELECT USING ((bucket_id = 'spec-storage'::text));


--
-- Name: objects Allow Upload 9la5bd_1; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Allow Upload 9la5bd_1" ON storage.objects FOR INSERT WITH CHECK ((bucket_id = 'spec-storage'::text));


--
-- Name: objects Allow Upload sxj5fq_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Allow Upload sxj5fq_0" ON storage.objects FOR INSERT TO anon WITH CHECK ((bucket_id = 'assignments'::text));


--
-- Name: objects Upload to Assignments; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Upload to Assignments" ON storage.objects FOR INSERT WITH CHECK ((bucket_id = 'assignments'::text));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA graphql_public; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA graphql_public TO postgres;
GRANT USAGE ON SCHEMA graphql_public TO anon;
GRANT USAGE ON SCHEMA graphql_public TO authenticated;
GRANT USAGE ON SCHEMA graphql_public TO service_role;


--
-- Name: SCHEMA pgsodium; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA pgsodium FROM supabase_admin;
REVOKE USAGE ON SCHEMA pgsodium FROM PUBLIC;
GRANT ALL ON SCHEMA pgsodium TO postgres;
GRANT USAGE ON SCHEMA pgsodium TO PUBLIC;


--
-- Name: SCHEMA pgsodium_masks; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA pgsodium_masks FROM supabase_admin;
REVOKE USAGE ON SCHEMA pgsodium_masks FROM pgsodium_keyiduser;
GRANT ALL ON SCHEMA pgsodium_masks TO postgres;
GRANT USAGE ON SCHEMA pgsodium_masks TO pgsodium_keyiduser;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT ALL ON SCHEMA storage TO postgres;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;
GRANT ALL ON FUNCTION auth.email() TO postgres;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;
GRANT ALL ON FUNCTION auth.role() TO postgres;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;
GRANT ALL ON FUNCTION auth.uid() TO postgres;


--
-- Name: FUNCTION algorithm_sign(signables text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION sign(payload json, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION try_cast_double(inp text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION url_decode(data text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_decode(data text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION url_encode(data bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION verify(token text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION comment_directive(comment_ text); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO postgres;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO anon;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO authenticated;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO service_role;


--
-- Name: FUNCTION exception(message text); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.exception(message text) TO postgres;
GRANT ALL ON FUNCTION graphql.exception(message text) TO anon;
GRANT ALL ON FUNCTION graphql.exception(message text) TO authenticated;
GRANT ALL ON FUNCTION graphql.exception(message text) TO service_role;


--
-- Name: FUNCTION get_schema_version(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.get_schema_version() TO postgres;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO anon;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO authenticated;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO service_role;


--
-- Name: FUNCTION increment_schema_version(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.increment_schema_version() TO postgres;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO anon;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO authenticated;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO service_role;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: postgres
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: TABLE key; Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON TABLE pgsodium.key FROM supabase_admin;
REVOKE ALL ON TABLE pgsodium.key FROM pgsodium_keymaker;
GRANT ALL ON TABLE pgsodium.key TO postgres;
GRANT ALL ON TABLE pgsodium.key TO pgsodium_keymaker;


--
-- Name: TABLE valid_key; Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON TABLE pgsodium.valid_key FROM supabase_admin;
REVOKE ALL ON TABLE pgsodium.valid_key FROM pgsodium_keyholder;
REVOKE SELECT ON TABLE pgsodium.valid_key FROM pgsodium_keyiduser;
GRANT ALL ON TABLE pgsodium.valid_key TO postgres;
GRANT ALL ON TABLE pgsodium.valid_key TO pgsodium_keyholder;
GRANT ALL ON TABLE pgsodium.valid_key TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_aead_det_decrypt(ciphertext bytea, additional bytea, key bytea, nonce bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(ciphertext bytea, additional bytea, key bytea, nonce bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(ciphertext bytea, additional bytea, key bytea, nonce bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(ciphertext bytea, additional bytea, key bytea, nonce bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(ciphertext bytea, additional bytea, key bytea, nonce bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_aead_det_encrypt(message bytea, additional bytea, key bytea, nonce bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key bytea, nonce bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key bytea, nonce bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key bytea, nonce bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key bytea, nonce bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_encrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_aead_det_keygen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() TO pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() TO service_role;


--
-- Name: FUNCTION crypto_aead_det_noncegen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_noncegen() FROM PUBLIC;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_noncegen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_det_noncegen() FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_noncegen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_noncegen() TO PUBLIC;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_noncegen() TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_decrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_encrypt(message bytea, additional bytea, nonce bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_aead_ietf_keygen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_keygen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_keygen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_keygen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_keygen() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_aead_ietf_noncegen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_noncegen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_aead_ietf_noncegen() FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_noncegen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_aead_ietf_noncegen() TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_auth(message bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth(message bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth(message bytea, key bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_auth(message bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth(message bytea, key bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_auth(message bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth(message bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth(message bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_auth(message bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth(message bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_auth_hmacsha256(message bytea, secret bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256(message bytea, secret bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256(message bytea, secret bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256(message bytea, secret bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256(message bytea, secret bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_auth_hmacsha256(message bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256(message bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256(message bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256(message bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256(message bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_auth_hmacsha256_keygen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_keygen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_keygen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_keygen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_keygen() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_auth_hmacsha256_verify(hash bytea, message bytea, secret bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_verify(hash bytea, message bytea, secret bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_verify(hash bytea, message bytea, secret bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_verify(hash bytea, message bytea, secret bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_verify(hash bytea, message bytea, secret bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_auth_hmacsha256_verify(hash bytea, message bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_verify(hash bytea, message bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_verify(hash bytea, message bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_verify(hash bytea, message bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha256_verify(hash bytea, message bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_auth_hmacsha512(message bytea, secret bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512(message bytea, secret bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512(message bytea, secret bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512(message bytea, secret bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512(message bytea, secret bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_auth_hmacsha512(message bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512(message bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512(message bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512(message bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512(message bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_auth_hmacsha512_verify(hash bytea, message bytea, secret bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512_verify(hash bytea, message bytea, secret bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512_verify(hash bytea, message bytea, secret bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512_verify(hash bytea, message bytea, secret bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512_verify(hash bytea, message bytea, secret bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_auth_hmacsha512_verify(hash bytea, message bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512_verify(hash bytea, message bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512_verify(hash bytea, message bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512_verify(hash bytea, message bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_hmacsha512_verify(hash bytea, message bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_auth_keygen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_keygen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_keygen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_keygen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_keygen() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_auth_verify(mac bytea, message bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_verify(mac bytea, message bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_verify(mac bytea, message bytea, key bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_verify(mac bytea, message bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_verify(mac bytea, message bytea, key bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_auth_verify(mac bytea, message bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_auth_verify(mac bytea, message bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_auth_verify(mac bytea, message bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_verify(mac bytea, message bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_auth_verify(mac bytea, message bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_box(message bytea, nonce bytea, public bytea, secret bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_box(message bytea, nonce bytea, public bytea, secret bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_box(message bytea, nonce bytea, public bytea, secret bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_box(message bytea, nonce bytea, public bytea, secret bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_box(message bytea, nonce bytea, public bytea, secret bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_box_new_keypair(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_box_new_keypair() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_box_new_keypair() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_box_new_keypair() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_box_new_keypair() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_box_noncegen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_box_noncegen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_box_noncegen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_box_noncegen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_box_noncegen() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_box_open(ciphertext bytea, nonce bytea, public bytea, secret bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_box_open(ciphertext bytea, nonce bytea, public bytea, secret bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_box_open(ciphertext bytea, nonce bytea, public bytea, secret bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_box_open(ciphertext bytea, nonce bytea, public bytea, secret bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_box_open(ciphertext bytea, nonce bytea, public bytea, secret bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_box_seed_new_keypair(seed bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_box_seed_new_keypair(seed bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_box_seed_new_keypair(seed bytea) FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_box_seed_new_keypair(seed bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_box_seed_new_keypair(seed bytea) TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_generichash(message bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_generichash(message bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_generichash(message bytea, key bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_generichash(message bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_generichash(message bytea, key bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_generichash_keygen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_generichash_keygen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_generichash_keygen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_generichash_keygen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_generichash_keygen() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_kdf_derive_from_key(subkey_size bigint, subkey_id bigint, context bytea, primary_key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_kdf_derive_from_key(subkey_size bigint, subkey_id bigint, context bytea, primary_key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_kdf_derive_from_key(subkey_size bigint, subkey_id bigint, context bytea, primary_key bytea) FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_kdf_derive_from_key(subkey_size bigint, subkey_id bigint, context bytea, primary_key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_kdf_derive_from_key(subkey_size bigint, subkey_id bigint, context bytea, primary_key bytea) TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_kdf_keygen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_kdf_keygen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_kdf_keygen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_kdf_keygen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_kdf_keygen() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_kx_new_keypair(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_kx_new_keypair() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_kx_new_keypair() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_kx_new_keypair() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_kx_new_keypair() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_kx_new_seed(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_kx_new_seed() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_kx_new_seed() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_kx_new_seed() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_kx_new_seed() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_kx_seed_new_keypair(seed bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_kx_seed_new_keypair(seed bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_kx_seed_new_keypair(seed bytea) FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_kx_seed_new_keypair(seed bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_kx_seed_new_keypair(seed bytea) TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_secretbox(message bytea, nonce bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox(message bytea, nonce bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox(message bytea, nonce bytea, key bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox(message bytea, nonce bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox(message bytea, nonce bytea, key bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_secretbox(message bytea, nonce bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox(message bytea, nonce bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox(message bytea, nonce bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox(message bytea, nonce bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox(message bytea, nonce bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_secretbox_keygen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox_keygen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox_keygen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox_keygen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox_keygen() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_secretbox_noncegen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox_noncegen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox_noncegen() FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox_noncegen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox_noncegen() TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_secretbox_open(ciphertext bytea, nonce bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox_open(ciphertext bytea, nonce bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox_open(ciphertext bytea, nonce bytea, key bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox_open(ciphertext bytea, nonce bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox_open(ciphertext bytea, nonce bytea, key bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_secretbox_open(message bytea, nonce bytea, key_id bigint, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox_open(message bytea, nonce bytea, key_id bigint, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_secretbox_open(message bytea, nonce bytea, key_id bigint, context bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox_open(message bytea, nonce bytea, key_id bigint, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_secretbox_open(message bytea, nonce bytea, key_id bigint, context bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_shorthash(message bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_shorthash(message bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_shorthash(message bytea, key bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.crypto_shorthash(message bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_shorthash(message bytea, key bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION crypto_shorthash_keygen(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_shorthash_keygen() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_shorthash_keygen() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_shorthash_keygen() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_shorthash_keygen() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_sign_final_create(state bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_sign_final_create(state bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_sign_final_create(state bytea, key bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_final_create(state bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_final_create(state bytea, key bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_sign_final_verify(state bytea, signature bytea, key bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_sign_final_verify(state bytea, signature bytea, key bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_sign_final_verify(state bytea, signature bytea, key bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_final_verify(state bytea, signature bytea, key bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_final_verify(state bytea, signature bytea, key bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_sign_init(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_sign_init() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_sign_init() FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_init() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_init() TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_sign_new_keypair(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_sign_new_keypair() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_sign_new_keypair() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_new_keypair() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_new_keypair() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_sign_update(state bytea, message bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_sign_update(state bytea, message bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_sign_update(state bytea, message bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_update(state bytea, message bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_update(state bytea, message bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_sign_update_agg1(state bytea, message bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_sign_update_agg1(state bytea, message bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_sign_update_agg1(state bytea, message bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_update_agg1(state bytea, message bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_update_agg1(state bytea, message bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_sign_update_agg2(cur_state bytea, initial_state bytea, message bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_sign_update_agg2(cur_state bytea, initial_state bytea, message bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_sign_update_agg2(cur_state bytea, initial_state bytea, message bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_update_agg2(cur_state bytea, initial_state bytea, message bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_sign_update_agg2(cur_state bytea, initial_state bytea, message bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_signcrypt_new_keypair(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_new_keypair() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_new_keypair() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_new_keypair() TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_new_keypair() TO pgsodium_keymaker;


--
-- Name: FUNCTION crypto_signcrypt_sign_after(state bytea, sender_sk bytea, ciphertext bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_sign_after(state bytea, sender_sk bytea, ciphertext bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_sign_after(state bytea, sender_sk bytea, ciphertext bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_sign_after(state bytea, sender_sk bytea, ciphertext bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_sign_after(state bytea, sender_sk bytea, ciphertext bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_signcrypt_sign_before(sender bytea, recipient bytea, sender_sk bytea, recipient_pk bytea, additional bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_sign_before(sender bytea, recipient bytea, sender_sk bytea, recipient_pk bytea, additional bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_sign_before(sender bytea, recipient bytea, sender_sk bytea, recipient_pk bytea, additional bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_sign_before(sender bytea, recipient bytea, sender_sk bytea, recipient_pk bytea, additional bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_sign_before(sender bytea, recipient bytea, sender_sk bytea, recipient_pk bytea, additional bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_signcrypt_verify_after(state bytea, signature bytea, sender_pk bytea, ciphertext bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_after(state bytea, signature bytea, sender_pk bytea, ciphertext bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_after(state bytea, signature bytea, sender_pk bytea, ciphertext bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_after(state bytea, signature bytea, sender_pk bytea, ciphertext bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_after(state bytea, signature bytea, sender_pk bytea, ciphertext bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_signcrypt_verify_before(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, recipient_sk bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_before(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, recipient_sk bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_before(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, recipient_sk bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_before(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, recipient_sk bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_before(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, recipient_sk bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION crypto_signcrypt_verify_public(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, ciphertext bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_public(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, ciphertext bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_public(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, ciphertext bytea) FROM pgsodium_keyholder;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_public(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, ciphertext bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.crypto_signcrypt_verify_public(signature bytea, sender bytea, recipient bytea, additional bytea, sender_pk bytea, ciphertext bytea) TO pgsodium_keyholder;


--
-- Name: FUNCTION derive_key(key_id bigint, key_len integer, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.derive_key(key_id bigint, key_len integer, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.derive_key(key_id bigint, key_len integer, context bytea) FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.derive_key(key_id bigint, key_len integer, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.derive_key(key_id bigint, key_len integer, context bytea) TO pgsodium_keymaker;


--
-- Name: FUNCTION pgsodium_derive(key_id bigint, key_len integer, context bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.pgsodium_derive(key_id bigint, key_len integer, context bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.pgsodium_derive(key_id bigint, key_len integer, context bytea) FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.pgsodium_derive(key_id bigint, key_len integer, context bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.pgsodium_derive(key_id bigint, key_len integer, context bytea) TO pgsodium_keymaker;


--
-- Name: FUNCTION randombytes_buf(size integer); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.randombytes_buf(size integer) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.randombytes_buf(size integer) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.randombytes_buf(size integer) TO postgres;
GRANT ALL ON FUNCTION pgsodium.randombytes_buf(size integer) TO pgsodium_keyiduser;


--
-- Name: FUNCTION randombytes_buf_deterministic(size integer, seed bytea); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.randombytes_buf_deterministic(size integer, seed bytea) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.randombytes_buf_deterministic(size integer, seed bytea) FROM pgsodium_keymaker;
REVOKE ALL ON FUNCTION pgsodium.randombytes_buf_deterministic(size integer, seed bytea) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.randombytes_buf_deterministic(size integer, seed bytea) TO postgres;
GRANT ALL ON FUNCTION pgsodium.randombytes_buf_deterministic(size integer, seed bytea) TO pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.randombytes_buf_deterministic(size integer, seed bytea) TO pgsodium_keyiduser;


--
-- Name: FUNCTION randombytes_new_seed(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.randombytes_new_seed() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.randombytes_new_seed() FROM pgsodium_keymaker;
GRANT ALL ON FUNCTION pgsodium.randombytes_new_seed() TO postgres;
GRANT ALL ON FUNCTION pgsodium.randombytes_new_seed() TO pgsodium_keymaker;


--
-- Name: FUNCTION randombytes_random(); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.randombytes_random() FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.randombytes_random() FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.randombytes_random() TO postgres;
GRANT ALL ON FUNCTION pgsodium.randombytes_random() TO pgsodium_keyiduser;


--
-- Name: FUNCTION randombytes_uniform(upper_bound integer); Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON FUNCTION pgsodium.randombytes_uniform(upper_bound integer) FROM supabase_admin;
REVOKE ALL ON FUNCTION pgsodium.randombytes_uniform(upper_bound integer) FROM pgsodium_keyiduser;
GRANT ALL ON FUNCTION pgsodium.randombytes_uniform(upper_bound integer) TO postgres;
GRANT ALL ON FUNCTION pgsodium.randombytes_uniform(upper_bound integer) TO pgsodium_keyiduser;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION install_available_extensions_and_test(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.install_available_extensions_and_test() TO anon;
GRANT ALL ON FUNCTION public.install_available_extensions_and_test() TO authenticated;
GRANT ALL ON FUNCTION public.install_available_extensions_and_test() TO service_role;


--
-- Name: FUNCTION is_instructor(uid uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_instructor(uid uuid) TO anon;
GRANT ALL ON FUNCTION public.is_instructor(uid uuid) TO authenticated;
GRANT ALL ON FUNCTION public.is_instructor(uid uuid) TO service_role;


--
-- Name: FUNCTION extension(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.extension(name text) TO anon;
GRANT ALL ON FUNCTION storage.extension(name text) TO authenticated;
GRANT ALL ON FUNCTION storage.extension(name text) TO service_role;
GRANT ALL ON FUNCTION storage.extension(name text) TO dashboard_user;
GRANT ALL ON FUNCTION storage.extension(name text) TO postgres;


--
-- Name: FUNCTION filename(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.filename(name text) TO anon;
GRANT ALL ON FUNCTION storage.filename(name text) TO authenticated;
GRANT ALL ON FUNCTION storage.filename(name text) TO service_role;
GRANT ALL ON FUNCTION storage.filename(name text) TO dashboard_user;
GRANT ALL ON FUNCTION storage.filename(name text) TO postgres;


--
-- Name: FUNCTION foldername(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.foldername(name text) TO anon;
GRANT ALL ON FUNCTION storage.foldername(name text) TO authenticated;
GRANT ALL ON FUNCTION storage.foldername(name text) TO service_role;
GRANT ALL ON FUNCTION storage.foldername(name text) TO dashboard_user;
GRANT ALL ON FUNCTION storage.foldername(name text) TO postgres;


--
-- Name: FUNCTION get_size_by_bucket(); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.get_size_by_bucket() TO postgres;


--
-- Name: FUNCTION search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) TO postgres;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.update_updated_at_column() TO postgres;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT ALL ON TABLE auth.audit_log_entries TO postgres;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.flow_state TO postgres;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.identities TO postgres;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT ALL ON TABLE auth.instances TO postgres;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_amr_claims TO postgres;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_challenges TO postgres;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_factors TO postgres;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT ALL ON TABLE auth.refresh_tokens TO postgres;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.saml_providers TO postgres;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.saml_relay_states TO postgres;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.schema_migrations TO dashboard_user;
GRANT ALL ON TABLE auth.schema_migrations TO postgres;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sessions TO postgres;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sso_domains TO postgres;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sso_providers TO postgres;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT ALL ON TABLE auth.users TO postgres;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE seq_schema_version; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE graphql.seq_schema_version TO postgres;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO anon;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO authenticated;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO service_role;


--
-- Name: TABLE decrypted_key; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON TABLE pgsodium.decrypted_key TO pgsodium_keyholder;


--
-- Name: SEQUENCE key_key_id_seq; Type: ACL; Schema: pgsodium; Owner: postgres
--

REVOKE ALL ON SEQUENCE pgsodium.key_key_id_seq FROM supabase_admin;
REVOKE ALL ON SEQUENCE pgsodium.key_key_id_seq FROM pgsodium_keymaker;
GRANT ALL ON SEQUENCE pgsodium.key_key_id_seq TO postgres;
GRANT ALL ON SEQUENCE pgsodium.key_key_id_seq TO pgsodium_keymaker;
GRANT ALL ON SEQUENCE pgsodium.key_key_id_seq TO pgsodium_keyiduser;


--
-- Name: TABLE masking_rule; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON TABLE pgsodium.masking_rule TO pgsodium_keyholder;


--
-- Name: TABLE mask_columns; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON TABLE pgsodium.mask_columns TO pgsodium_keyholder;


--
-- Name: TABLE assignment; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.assignment TO anon;
GRANT ALL ON TABLE public.assignment TO authenticated;
GRANT ALL ON TABLE public.assignment TO service_role;


--
-- Name: SEQUENCE assignment_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.assignment_id_seq TO anon;
GRANT ALL ON SEQUENCE public.assignment_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.assignment_id_seq TO service_role;


--
-- Name: TABLE comments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.comments TO anon;
GRANT ALL ON TABLE public.comments TO authenticated;
GRANT ALL ON TABLE public.comments TO service_role;


--
-- Name: SEQUENCE comments_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.comments_id_seq TO anon;
GRANT ALL ON SEQUENCE public.comments_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.comments_id_seq TO service_role;


--
-- Name: TABLE course; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.course TO anon;
GRANT ALL ON TABLE public.course TO authenticated;
GRANT ALL ON TABLE public.course TO service_role;


--
-- Name: SEQUENCE course_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.course_id_seq TO anon;
GRANT ALL ON SEQUENCE public.course_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.course_id_seq TO service_role;


--
-- Name: TABLE flag; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.flag TO anon;
GRANT ALL ON TABLE public.flag TO authenticated;
GRANT ALL ON TABLE public.flag TO service_role;


--
-- Name: TABLE membership; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.membership TO anon;
GRANT ALL ON TABLE public.membership TO authenticated;
GRANT ALL ON TABLE public.membership TO service_role;


--
-- Name: SEQUENCE membership_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.membership_id_seq TO anon;
GRANT ALL ON SEQUENCE public.membership_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.membership_id_seq TO service_role;


--
-- Name: TABLE role; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.role TO anon;
GRANT ALL ON TABLE public.role TO authenticated;
GRANT ALL ON TABLE public.role TO service_role;


--
-- Name: TABLE section; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.section TO anon;
GRANT ALL ON TABLE public.section TO authenticated;
GRANT ALL ON TABLE public.section TO service_role;


--
-- Name: SEQUENCE section_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.section_id_seq TO anon;
GRANT ALL ON SEQUENCE public.section_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.section_id_seq TO service_role;


--
-- Name: TABLE "student_Submission"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."student_Submission" TO anon;
GRANT ALL ON TABLE public."student_Submission" TO authenticated;
GRANT ALL ON TABLE public."student_Submission" TO service_role;


--
-- Name: SEQUENCE "student_Submission_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."student_Submission_id_seq" TO anon;
GRANT ALL ON SEQUENCE public."student_Submission_id_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."student_Submission_id_seq" TO service_role;


--
-- Name: TABLE submission; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.submission TO anon;
GRANT ALL ON TABLE public.submission TO authenticated;
GRANT ALL ON TABLE public.submission TO service_role;


--
-- Name: SEQUENCE submission_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.submission_id_seq TO anon;
GRANT ALL ON SEQUENCE public.submission_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.submission_id_seq TO service_role;


--
-- Name: TABLE test_cases; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.test_cases TO anon;
GRANT ALL ON TABLE public.test_cases TO authenticated;
GRANT ALL ON TABLE public.test_cases TO service_role;


--
-- Name: SEQUENCE test_cases_case_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.test_cases_case_id_seq TO anon;
GRANT ALL ON SEQUENCE public.test_cases_case_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.test_cases_case_id_seq TO service_role;


--
-- Name: TABLE "user"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."user" TO anon;
GRANT ALL ON TABLE public."user" TO authenticated;
GRANT ALL ON TABLE public."user" TO service_role;


--
-- Name: SEQUENCE user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_id_seq TO anon;
GRANT ALL ON SEQUENCE public.user_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.user_id_seq TO service_role;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres;


--
-- Name: TABLE migrations; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.migrations TO anon;
GRANT ALL ON TABLE storage.migrations TO authenticated;
GRANT ALL ON TABLE storage.migrations TO service_role;
GRANT ALL ON TABLE storage.migrations TO postgres;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT ALL ON SEQUENCES  TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pgsodium GRANT ALL ON SEQUENCES  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT ALL ON TABLES  TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pgsodium GRANT ALL ON TABLES  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON SEQUENCES  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON FUNCTIONS  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON TABLES  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE SCHEMA')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

